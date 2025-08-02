/**
 * Values from the official Paradise multiplied by 2.
 * Previously, Tesla produced 1-2 MW, I think this is too little.
 */
#define TESLA_DEFAULT_POWER 3476520
#define TESLA_MINI_POWER 1738260

//Zap constants, speeds up targeting
#define COIL (ROD + 1)
#define ROD (RIDE + 1)
#define RIDE (LIVING + 1)
#define LIVING (APC + 1)
#define APC (MACHINERY + 1)
#define MACHINERY (BLOB + 1)
#define BLOB (STRUCTURE + 1)
#define STRUCTURE (1)

/// The Tesla engine
/obj/singularity/energy_ball
	name = "energy ball"
	desc = "Энергетический шар."
	ru_names = list(
		NOMINATIVE = "энергетический шар",
		GENITIVE = "энергетического шара",
		DATIVE = "энергетическому шару",
		ACCUSATIVE = "энергетический шар",
		INSTRUMENTAL = "энергетическим шаром",
		PREPOSITIONAL = "энергетическом шаре"
	)
	icon = 'icons/obj/engines_and_power/tesla/energy_ball.dmi'
	icon_state = "energy_ball"
	density = TRUE
	plane = ABOVE_LIGHTING_PLANE
	light_range = 6
	move_resist = INFINITY
	pixel_x = -32
	pixel_y = -32
	warps_projectiles = FALSE
	energy = 0

	// Garbage due to inheritance from the singularity.
	current_size = STAGE_TWO
	move_self = TRUE
	grav_pull = 0
	dissipate = FALSE
	dissipate_delay = 5
	dissipate_strength = 1

	var/list/orbiting_balls = list()
	var/miniball = FALSE
	var/produced_power
	var/energy_to_raise = 32
	var/energy_to_lower = -20
	var/list/shocked_things = list()

/obj/singularity/energy_ball/Initialize(mapload, starting_energy = 50, is_miniball = FALSE)
	. = ..()

	energy = starting_energy
	miniball = is_miniball

	if(is_miniball)
		return

	set_light(10, 7, "#5e5edd")
	var/turf/spawned_turf = get_turf(src)
	message_admins("A tesla has been created at [ADMIN_VERBOSEJMP(spawned_turf)].")
	investigate_log("was created at [AREACOORD(spawned_turf)].", INVESTIGATE_ENGINE)

/obj/singularity/energy_ball/ex_act(severity, target)
	return

/obj/singularity/energy_ball/consume(severity, target)
	return

/obj/singularity/energy_ball/Destroy()
	if(orbiting && istype(orbiting, /obj/singularity/energy_ball))
		var/obj/singularity/energy_ball/parent_energy_ball = orbiting
		parent_energy_ball.orbiting_balls -= src

	QDEL_LIST(orbiting_balls)

	return ..()

/obj/singularity/energy_ball/admin_investigate_setup()
	if(miniball)
		return //don't annnounce miniballs
	..()

/obj/singularity/energy_ball/process()
	if(orbiting)
		energy = 0 // ensure we dont have miniballs of miniballs
	else
		handle_energy()

		move_basketball(4 + length(orbiting_balls) * 1.5)

		playsound(loc, 'sound/magic/lightningbolt.ogg', 100, TRUE, extrarange = 30)

		pixel_x = 0
		pixel_y = 0
		shocked_things.Cut(1, length(shocked_things) / 1.3)
		var/list/shocking_info = list()
		tesla_zap(source = src, zap_range = 3, power = TESLA_DEFAULT_POWER, shocked_targets = shocking_info)

		pixel_x = -32
		pixel_y = -32
		for(var/ball in orbiting_balls)
			var/range = rand(1, clamp(length(orbiting_balls), 2, 3))
			var/list/temp_shock = list()
			//We zap off the main ball instead of ourselves to make things looks proper
			tesla_zap(source = src, zap_range = range, power = TESLA_MINI_POWER / 7 * range, shocked_targets = temp_shock)
			shocking_info += temp_shock
		shocked_things += shocking_info

/obj/singularity/energy_ball/examine(mob/user)
	. = ..()
	if(length(orbiting_balls))
		. += "Вокруг вращается [length(orbiting_balls)] мини-шар[declension_ru(length(orbiting_balls), "", "а", "ов")]."

/obj/singularity/energy_ball/proc/move_basketball(move_amount) // We need to get the gods and Tesla out of the inheritance from Singa. What a vicious piece of shit that is.
	var/list/dirs = GLOB.alldirs.Copy()
	if(length(shocked_things))
		for(var/i in 1 to 30)
			var/atom/real_thing = pick(shocked_things)
			dirs += get_dir(src, real_thing) //Carry some momentum yeah? Just a bit tho
	for(var/i in 0 to move_amount)
		var/move_dir = pick(dirs) //ensures teslas don't just sit around
		if(target && prob(10))
			move_dir = get_dir(src,target)
		var/turf/turf_to_move = get_step(src, move_dir)
		if(can_move(turf_to_move))
			forceMove(turf_to_move)
			setDir(move_dir)
			for(var/mob/living/carbon/mob_to_dust in loc)
				dust_mobs(mob_to_dust)

/obj/singularity/energy_ball/proc/handle_energy()
	if(energy >= energy_to_raise)
		energy_to_lower = energy_to_raise - 20
		energy_to_raise = energy_to_raise * 1.25

		playsound(src.loc, 'sound/magic/lightning_chargeup.ogg', 100, TRUE, extrarange = 30)
		addtimer(CALLBACK(src, PROC_REF(new_mini_ball)), 100)

	else if(energy < energy_to_lower && length(orbiting_balls))
		energy_to_raise = energy_to_raise / 1.25
		energy_to_lower = (energy_to_raise / 1.25) - 20

		var/Orchiectomy_target = pick(orbiting_balls)
		qdel(Orchiectomy_target)

/obj/singularity/energy_ball/proc/new_mini_ball()
	if(!loc)
		return

	var/obj/singularity/energy_ball/miniball = new(loc, 0, TRUE)

	miniball.transform *= pick(0.3, 0.4, 0.5, 0.6, 0.7)
	var/list/icon_dimensions = get_icon_dimensions(icon)

	var/orbitsize = (icon_dimensions["width"] + icon_dimensions["height"]) * pick(0.4, 0.5, 0.6, 0.7, 0.8)
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)
	miniball.orbit(src, orbitsize, pick(FALSE, TRUE), rand(10, 25), pick(3, 4, 5, 6, 36))

/obj/singularity/energy_ball/Bump(atom/bumped_atom, effect_applied = TRUE)
	. = ..()
	if(.)
		return .
	dust_mobs(bumped_atom)

/obj/singularity/energy_ball/Bumped(atom/movable/moving_atom, effect_applied = TRUE)
	. = ..()
	dust_mobs(moving_atom)

/obj/singularity/energy_ball/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("That was a shockingly dumb idea."))
	var/obj/item/organ/internal/brain/rip_u = jedi.get_int_organ(/obj/item/organ/internal/brain)
	jedi.ghostize(jedi)
	if(rip_u)
		qdel(rip_u)
	jedi.investigate_log("had [jedi.p_their()] brain dusted by touching [src] with telekinesis.", INVESTIGATE_DEATHS)
	jedi.death()
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/singularity/energy_ball/orbit(obj/singularity/energy_ball/target)
	if(istype(target))
		target.orbiting_balls += src
		GLOB.poi_list -= src
	. = ..()

	if(istype(target))
		target.orbiting_balls -= src
	if(!loc)
		qdel(src)

/obj/singularity/energy_ball/proc/dust_mobs(atom/source)
	if(!isliving(source))
		return
	var/mob/living/living = source
	if(living.incorporeal_move || HAS_TRAIT(living, TRAIT_GODMODE))
		return
	if(!iscarbon(source))
		return
	for(var/obj/machinery/power/grounding_rod/rod in orange(src, 2))
		if(rod.anchored)
			return
	var/mob/living/carbon/carbon = source
	carbon.investigate_log("has been dusted by an energy ball.", INVESTIGATE_DEATHS)
	carbon.dust()

/// Things that we don't want to shock.
GLOBAL_LIST_INIT(blacklisted_tesla_types, typecacheof(list(
	/obj/machinery/atmospherics,
	/obj/machinery/portable_atmospherics,
	/obj/machinery/power/emitter,
	/obj/machinery/field/generator,
	/mob/living/simple_animal,
	/obj/machinery/particle_accelerator/control_box,
	/obj/structure/particle_accelerator/fuel_chamber,
	/obj/structure/particle_accelerator/particle_emitter/center,
	/obj/structure/particle_accelerator/particle_emitter/left,
	/obj/structure/particle_accelerator/particle_emitter/right,
	/obj/structure/particle_accelerator/power_box,
	/obj/structure/particle_accelerator/end_cap,
	/obj/machinery/field/containment,
	/obj/structure/disposalpipe,
	/obj/structure/disposaloutlet,
	// /obj/machinery/disposal/delivery_chute,
	/obj/machinery/camera,
	/obj/structure/sign,
	/obj/machinery/gateway,
	/obj/structure/lattice,
	/obj/structure/grille,
	/obj/structure/cable,
	/obj/machinery/the_singularitygen/tesla,
	/obj/machinery/constructable_frame/machine_frame
	)))

/// Things that we want to shock.
GLOBAL_LIST_INIT(things_to_shock, typecacheof(list(
	/obj/machinery,
	/mob/living,
	/obj/structure,
	/obj/vehicle
	)))

/proc/tesla_zap(atom/source, zap_range = 3, power, cutoff = 1e3, zap_flags = ZAP_DEFAULT_FLAGS, list/shocked_targets = list())
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

	// Ok so we are making an assumption here. We assume that view() still calculates from the center out.
	// This means that if we find an object we can assume it is the closest one of its type. This is somewhat of a speed increase.
	// This also means we have no need to track distance, as the doview() proc does it all for us.

	// Darkness fucks oview up hard. I've tried dview() but it doesn't seem to work
	// I hate existance
	for(var/atom/A as anything in typecache_filter_multi_list_exclusion(oview(zap_range + 2, source), GLOB.things_to_shock, GLOB.blacklisted_tesla_types))
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(shocked_targets, A))
			continue

		// NOTE: these type checks are safe because CURRENTLY the range family of procs returns turfs in least to greatest distance order
		// This is unspecified behavior tho, so if it ever starts acting up just remove these optimizations and include a distance check

		else if(closest_type >= COIL)
			continue //no need checking these other things

		else if(istype(A, /obj/machinery/power/tesla_coil))
			if(!HAS_TRAIT(A, TRAIT_BEING_SHOCKED))
				closest_type = COIL
				closest_atom = A

		else if(closest_type >= ROD)
			continue

		else if(istype(A, /obj/machinery/power/grounding_rod))
			closest_type = ROD
			closest_atom = A

		else if(closest_type >= RIDE)
			continue

		else if(istype(A, /obj/vehicle))
			var/obj/vehicle/ridden/R = A
			if(R.can_buckle && !HAS_TRAIT(R, TRAIT_BEING_SHOCKED))
				closest_type = RIDE
				closest_atom = A

		else if(closest_type >= LIVING)
			continue

		else if(isliving(A))
			var/mob/living/L = A
			if(L.stat != DEAD && !HAS_TRAIT(L, TRAIT_TESLA_SHOCKIMMUNE) && !HAS_TRAIT(L, TRAIT_BEING_SHOCKED))
				closest_type = LIVING
				closest_atom = A

		else if(closest_type >= APC)
			continue

		else if(isapc(A))
			closest_type = APC
			closest_atom = A

		else if(closest_type >= MACHINERY)
			continue

		else if(ismachinery(A))
			if(!HAS_TRAIT(A, TRAIT_BEING_SHOCKED))
				closest_type = MACHINERY
				closest_atom = A

		else if(closest_type >= BLOB)
			continue

		else if(istype(A, /obj/structure/blob))
			if(!HAS_TRAIT(A, TRAIT_BEING_SHOCKED))
				closest_type = BLOB
				closest_atom = A

		else if(closest_type >= STRUCTURE)
			continue

		else if(isstructure(A))
			if(!HAS_TRAIT(A, TRAIT_BEING_SHOCKED))
				closest_type = STRUCTURE
				closest_atom = A

	//Alright, we've done our loop, now lets see if was anything interesting in range
	if(!closest_atom)
		return
	//common stuff
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
		closest_mob.electrocute_act(shock_damage, "тесла шар", 1, SHOCK_TESLA | ((zap_flags & ZAP_MOB_STUN) ? NONE : SHOCK_NOSTUN))
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

#undef TESLA_DEFAULT_POWER
#undef TESLA_MINI_POWER
