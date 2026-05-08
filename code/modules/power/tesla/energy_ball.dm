#define TESLA_DEFAULT_ENERGY (695.304 MEGA JOULES * 0.01)
#define TESLA_MINI_ENERGY (347.652 MEGA JOULES * 0.01) // Has a weird scaling thing so this is a lie for now (doesn't generate power anyways).

// Zap constants, speeds up targeting
#define COIL (ROD + 1)
#define ROD (RIDE + 1)
#define RIDE (LIVING + 1)
#define LIVING (APC + 1)
#define APC (MACHINERY + 1)
#define MACHINERY (BLOB + 1)
#define BLOB (STRUCTURE + 1)
#define STRUCTURE (1)

/// The Tesla engine
/obj/energy_ball
	name = "energy ball"
	desc = "Энергетический шар."
	icon = 'icons/obj/engines_and_power/tesla/energy_ball.dmi'
	icon_state = "energy_ball"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = TRUE
	plane = MASSIVE_OBJ_PLANE
	plane = ABOVE_LIGHTING_PLANE
	light_range = 6
	move_resist = INFINITY
	obj_flags = DANGEROUS_POSSESSION
	pixel_x = -ICON_SIZE_X
	pixel_y = -ICON_SIZE_Y
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags = SUPERMATTER_IGNORES

	/// Current energy of the ball. Affects creation/removal of miniballs and zap power.
	var/energy
	/// Target towards which the ball moves with some probability.
	var/target
	/// List of miniballs orbiting this ball.
	var/list/orbiting_balls = list()
	/// TRUE if this is a miniball (does not spawn new balls nor generate power).
	var/miniball = FALSE
	/// Power produced (not used in this snippet).
	var/produced_power
	/// Energy threshold above which the ball spawns a new miniball.
	var/energy_to_raise = 32
	/// Energy threshold below which one orbiting miniball is removed.
	var/energy_to_lower = -20
	/// List of objects already shocked in the current cycle to avoid double shocks.
	var/list/shocked_things = list()

/obj/energy_ball/get_ru_names()
	return list(
		NOMINATIVE = "энергетический шар",
		GENITIVE = "энергетического шара",
		DATIVE = "энергетическому шару",
		ACCUSATIVE = "энергетический шар",
		INSTRUMENTAL = "энергетическим шаром",
		PREPOSITIONAL = "энергетическом шаре",
	)

/obj/energy_ball/Initialize(mapload, starting_energy = 50, is_miniball = FALSE)
	. = ..()

	energy = starting_energy
	miniball = is_miniball
	START_PROCESSING(SSobj, src)

	if(is_miniball)
		return

	set_light(10, 7, "#5e5edd")
	var/turf/spawned_turf = get_turf(src)
	message_admins("A tesla has been created at [ADMIN_VERBOSEJMP(spawned_turf)].")
	investigate_log("was created at [AREACOORD(spawned_turf)].", INVESTIGATE_ENGINE)

/obj/energy_ball/Destroy()
	if(orbiting && istype(orbiting, /obj/energy_ball))
		var/obj/energy_ball/parent_energy_ball = orbiting
		parent_energy_ball.orbiting_balls -= src

	QDEL_LIST(orbiting_balls)
	STOP_PROCESSING(SSobj, src)

	return ..()

/obj/energy_ball/process()
	if(orbiting)
		energy = 0 // ensure we dont have miniballs of miniballs
	else
		handle_energy()
		move(4 + length(orbiting_balls) * 1.5)
		playsound(loc, 'sound/magic/lightningbolt.ogg', 100, TRUE, extrarange = 30)

		pixel_x = 0
		pixel_y = 0
		shocked_things.Cut(1, length(shocked_things) / 1.3)
		var/list/shocking_info = list()
		tesla_zap(source = src, zap_range = 3, power = TESLA_DEFAULT_ENERGY, shocked_targets = shocking_info, zap_flags = ZAP_TESLA_FLAGS)

		pixel_x = -32
		pixel_y = -32
		for(var/ball in orbiting_balls)
			var/range = rand(1, clamp(length(orbiting_balls), 2, 3))
			var/list/temp_shock = list()
			// We zap off the main ball instead of ourselves to make things looks proper
			tesla_zap(source = src, zap_range = range, power = TESLA_MINI_ENERGY / 7 * range, shocked_targets = temp_shock, zap_flags = ZAP_TESLA_FLAGS)
			shocking_info += temp_shock
		shocked_things += shocking_info

/obj/energy_ball/examine(mob/user)
	. = ..()
	if(length(orbiting_balls))
		. += "Вокруг вращается [length(orbiting_balls)] мини-шар[DECL_CREDIT(length(orbiting_balls))]."

/obj/energy_ball/proc/move(move_amount)
	var/list/dirs = GLOB.alldirs.Copy()
	if(length(shocked_things))
		for(var/i in 1 to 30)
			var/atom/real_thing = pick(shocked_things)
			dirs += get_dir(src, real_thing) // Carry some momentum yeah? Just a bit tho
	for(var/i in 0 to move_amount)
		var/move_dir = pick(dirs) // ensures teslas don't just sit around
		if(target && prob(10))
			move_dir = get_dir(src, target)
		var/turf/turf_to_move = get_step(src, move_dir)
		if(can_move(turf_to_move))
			forceMove(turf_to_move)
			setDir(move_dir)
			for(var/mob/living/carbon/mob_to_dust in loc)
				dust_mobs(mob_to_dust)

/obj/energy_ball/proc/can_move(turf/to_move)
	if(!to_move)
		return FALSE

	for(var/_thing in to_move)
		var/atom/thing = _thing
		if(SEND_SIGNAL(thing, COMSIG_ATOM_SINGULARITY_TRY_MOVE) & SINGULARITY_TRY_MOVE_BLOCK)
			return FALSE

	return TRUE

/obj/energy_ball/proc/handle_energy()
	if(energy >= energy_to_raise)
		energy_to_lower = energy_to_raise - 20
		energy_to_raise = energy_to_raise * 1.25

		playsound(loc, 'sound/magic/lightning_chargeup.ogg', 100, TRUE, extrarange = 30)
		addtimer(CALLBACK(src, PROC_REF(new_mini_ball)), 10 SECONDS)

	else if(energy < energy_to_lower && length(orbiting_balls))
		energy_to_raise = energy_to_raise / 1.25
		energy_to_lower = (energy_to_raise / 1.25) - 20

		var/orchiectomy_target = pick(orbiting_balls)
		qdel(orchiectomy_target)

/obj/energy_ball/proc/new_mini_ball()
	if(!loc)
		return

	var/obj/energy_ball/miniball = new /obj/energy_ball(
		loc,
		/* starting_energy = */ 0,
		/* is_miniball = */ TRUE
	)

	miniball.transform *= pick(0.3, 0.4, 0.5, 0.6, 0.7)
	var/list/icon_dimensions = get_icon_dimensions(icon)

	var/orbitsize = (icon_dimensions["width"] + icon_dimensions["height"]) * pick(0.4, 0.5, 0.6, 0.7, 0.8)
	orbitsize -= (orbitsize / ICON_SIZE_ALL) * (ICON_SIZE_ALL * 0.25)
	miniball.orbit(src, orbitsize, pick(FALSE, TRUE), rand(10, 25), pick(3, 4, 5, 6, 36))

/obj/energy_ball/Bump(atom/bumped_atom, effect_applied = TRUE)
	. = ..()
	dust_mobs(bumped_atom)

/obj/energy_ball/Bumped(atom/movable/moving_atom, effect_applied = TRUE)
	. = ..()
	dust_mobs(moving_atom)

/obj/energy_ball/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("That was a shockingly dumb idea."))
	var/obj/item/organ/internal/brain/jedi_brain = jedi.get_int_organ(/obj/item/organ/internal/brain)
	jedi.ghostize(jedi)
	if(jedi_brain)
		qdel(jedi_brain)
	jedi.investigate_log("had [jedi] brain dusted by touching [src] with telekinesis.", INVESTIGATE_DEATHS)
	jedi.death()
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/energy_ball/orbit(obj/energy_ball/target)
	if(istype(target))
		target.orbiting_balls += src
	return ..()

/obj/energy_ball/stop_orbit()
	if(orbiting && istype(orbiting, /obj/energy_ball))
		var/obj/energy_ball/orbitingball = orbiting
		orbitingball.orbiting_balls -= src
	. = ..()
	if(!QDELETED(src))
		qdel(src)

/obj/energy_ball/proc/dust_mobs(atom/source)
	if(!isliving(source))
		return
	var/mob/living/living = source
	if(living.incorporeal_move || HAS_TRAIT(living, TRAIT_GODMODE))
		return
	if(!iscarbon(source))
		return
	for(var/obj/machinery/power/energy_accumulator/grounding_rod/rod in orange(src, 2))
		if(rod.anchored)
			return
	var/mob/living/carbon/carbon = source
	carbon.investigate_log("has been dusted by an energy ball.", INVESTIGATE_DEATHS)
	carbon.dust()

/proc/tesla_zap(atom/source, zap_range = 3, power, cutoff = 4e5, zap_flags = ZAP_DEFAULT_FLAGS, list/shocked_targets = list())
	if(QDELETED(source))
		return
	if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
		LAZYSET(shocked_targets, source, TRUE) // I don't want no null refs in my list yeah?
	. = source.dir
	if(power < cutoff)
		return

	// THIS IS SO FUCKING UGLY AND I HATE IT, but I can't make it nice without making it slower, check*N rather then n. So we're stuck with it.
	var/atom/closest_atom
	var/closest_type = 0
	var/static/list/things_to_shock = zebra_typecacheof(list(
		// Things that we want to shock.
		/mob/living = TRUE,
		/obj/machinery = TRUE,
		/obj/structure = TRUE,

		// Things that we don't want to shock.
		/mob/living/simple_animal/slime = FALSE,
		/obj/machinery/atmospherics = FALSE,
		/obj/machinery/camera = FALSE,
		/obj/machinery/constructable_frame/machine_frame = FALSE,
		/obj/machinery/field/containment = FALSE,
		/obj/machinery/field/generator = FALSE,
		/obj/machinery/gateway = FALSE,
		/obj/machinery/particle_accelerator/control_box = FALSE,
		/obj/machinery/portable_atmospherics = FALSE,
		/obj/machinery/power/emitter = FALSE,
		/obj/machinery/the_singularitygen/tesla = FALSE,
		/obj/structure/cable = FALSE,
		/obj/structure/disposaloutlet = FALSE,
		/obj/structure/disposalpipe = FALSE,
		/obj/structure/grille = FALSE,
		/obj/structure/lattice = FALSE,
		/obj/structure/particle_accelerator/end_cap = FALSE,
		/obj/structure/particle_accelerator/fuel_chamber = FALSE,
		/obj/structure/particle_accelerator/particle_emitter/center = FALSE,
		/obj/structure/particle_accelerator/particle_emitter/left = FALSE,
		/obj/structure/particle_accelerator/particle_emitter/right = FALSE,
		/obj/structure/particle_accelerator/power_box = FALSE,
		/obj/structure/sign = FALSE,
	))

	// Ok so we are making an assumption here. We assume that view() still calculates from the center out.
	// This means that if we find an object we can assume it is the closest one of its type. This is somewhat of a speed increase.
	// This also means we have no need to track distance, as the doview() proc does it all for us.

	// Darkness fucks oview up hard. I've tried dview() but it doesn't seem to work
	// I hate existance
	for(var/atom/target_atom as anything in typecache_filter_list(oview(zap_range + 2, source), things_to_shock))
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(shocked_targets, target_atom))
			continue

		// NOTE: these type checks are safe because CURRENTLY the range family of procs returns turfs in least to greatest distance order
		// This is unspecified behavior tho, so if it ever starts acting up just remove these optimizations and include a distance check

		else if(closest_type >= COIL)
			continue //no need checking these other things

		else if(istype(target_atom, /obj/machinery/power/energy_accumulator/tesla_coil))
			if(!HAS_TRAIT(target_atom, TRAIT_BEING_SHOCKED))
				closest_type = COIL
				closest_atom = target_atom

		else if(closest_type >= ROD)
			continue

		else if(istype(target_atom, /obj/machinery/power/energy_accumulator/grounding_rod))
			closest_type = ROD
			closest_atom = target_atom

		else if(closest_type >= RIDE)
			continue

		else if(isvehicle(target_atom))
			var/obj/vehicle/ridden/target_ridden = target_atom
			if(target_ridden.can_buckle && !HAS_TRAIT(target_ridden, TRAIT_BEING_SHOCKED))
				closest_type = RIDE
				closest_atom = target_atom

		else if(closest_type >= LIVING)
			continue

		else if(isliving(target_atom))
			var/mob/living/target_living = target_atom
			if(target_living.stat != DEAD && !HAS_TRAIT(target_living, TRAIT_TESLA_SHOCKIMMUNE) && !HAS_TRAIT(target_living, TRAIT_BEING_SHOCKED))
				closest_type = LIVING
				closest_atom = target_atom

		else if(closest_type >= APC)
			continue

		else if(isapc(target_atom))
			closest_type = APC
			closest_atom = target_atom

		else if(closest_type >= MACHINERY)
			continue

		else if(ismachinery(target_atom))
			if(!HAS_TRAIT(target_atom, TRAIT_BEING_SHOCKED))
				closest_type = MACHINERY
				closest_atom = target_atom

		else if(closest_type >= BLOB)
			continue

		else if(istype(target_atom, /obj/structure/blob))
			if(!HAS_TRAIT(target_atom, TRAIT_BEING_SHOCKED))
				closest_type = BLOB
				closest_atom = target_atom

		else if(closest_type >= STRUCTURE)
			continue

		else if(isstructure(target_atom))
			if(!HAS_TRAIT(target_atom, TRAIT_BEING_SHOCKED))
				closest_type = STRUCTURE
				closest_atom = target_atom

	// Alright, we've done our loop, now lets see if was anything interesting in range
	if(!closest_atom)
		return
	// Common stuff
	source.Beam(closest_atom, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)
	var/zapdir = get_dir(source, closest_atom)
	if(zapdir)
		. = zapdir

	var/next_range = 2
	if(closest_type == COIL)
		next_range = 5

	if(closest_type == LIVING)
		var/mob/living/closest_mob = closest_atom
		ADD_TRAIT(closest_mob, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
		addtimer(TRAIT_CALLBACK_REMOVE(closest_mob, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
		var/shock_damage = (zap_flags & ZAP_MOB_DAMAGE) ? (min(round(power / 600), 90) + rand(-5, 5)) : 0
		closest_mob.electrocute_act(shock_damage, source, 1, SHOCK_TESLA | ((zap_flags & ZAP_MOB_STUN) ? NONE : SHOCK_NOSTUN))
		if(issilicon(closest_mob))
			var/mob/living/silicon/silicon = closest_mob
			if((zap_flags & ZAP_MOB_STUN) && (zap_flags & ZAP_MOB_DAMAGE))
				silicon.emp_act(EMP_LIGHT)
			next_range = 7 // metallic folks bounce it further
		else
			next_range = 5
		power /= 1.5
	else
		power = closest_atom.zap_act(power, zap_flags)

	if(prob(20))
		var/list/shocked_copy = shocked_targets.Copy()
		tesla_zap(source = closest_atom, zap_range = next_range, power = power * 0.5, cutoff = cutoff, zap_flags = zap_flags, shocked_targets = shocked_copy)
		tesla_zap(source = closest_atom, zap_range = next_range, power = power * 0.5, cutoff = cutoff, zap_flags = zap_flags, shocked_targets = shocked_targets)
		shocked_targets += shocked_copy
		return

	tesla_zap(source = closest_atom, zap_range = next_range, power = power, cutoff = cutoff, zap_flags = zap_flags, shocked_targets = shocked_targets)

#undef COIL
#undef ROD
#undef RIDE
#undef LIVING
#undef APC
#undef MACHINERY
#undef BLOB
#undef STRUCTURE

#undef TESLA_DEFAULT_ENERGY
#undef TESLA_MINI_ENERGY
