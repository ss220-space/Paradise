/// Is this a hitscan projectile or not, if so move like one
#define MOVES_HITSCAN -1
/// How many pixels to move the muzzle flash up so your character doesn't look like they're shitting out lasers.
#define MUZZLE_EFFECT_PIXEL_INCREMENT 17

/obj/projectile
	name = "projectile"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "bullet"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE //There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	pass_flags = PASSTABLE | PASSPROJECTILE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	movement_type = FLYING
	animate_movement = NO_STEPS
	//The sound this plays on impact.
	var/hitsound = 'sound/weapons/pierce.ogg'
	var/hitsound_wall = ""
	/// Body part at which the projectile was aimed.
	var/def_zone = ""
	/// Mob who shot projectile.
	var/mob/firer = null
	/// The gun or object projectile came from.
	var/atom/firer_source_atom = null
	var/obj/item/ammo_casing/ammo_casing = null
	/// Used to determine sound and attack message.
	var/suppressed = FALSE
	/// Initial target x coordinate offset of the projectile
	var/yo = null
	/// Initial target y coordinate offset of the projectile
	var/xo = null
	var/current = null
	/// Original target clicked.
	var/atom/original = null
	/// Projectile's starting turf.
	var/turf/starting = null
	/// List of atoms we have passed through, don't try to hit them again.
	var/list/permutated
	/// Used for suspending the projectile midair.
	var/paused = FALSE
	/// The pixel location X of the tile that the player clicked. Default is the center.
	var/p_x = 16
	/// The pixel location Y of the tile that the player clicked. Default is the center.
	var/p_y = 16
	/// Amount of deciseconds it takes for projectile to travel.
	var/speed = 0.5
	/// The current angle of the projectile. Initially null, so if the arg is missing from [/fire()], we can calculate it from firer and target as fallback.
	var/Angle = null
	/// Angle at the moment of firing
	var/original_angle = 0
	/// Amount (in degrees) of projectile spread.
	var/spread = 0
	/// If set to `TRUE` [/obj/item/hardsuit_taser_proof] upgrage will block this projectile.
	var/shockbull = FALSE

	var/ignore_source_check = FALSE

	var/damage = 10
	/// How much damage should be decremented as the bullet moves.
	var/tile_dropoff = 0
	/// How much stamina damage should be decremented as the bullet moves.
	var/tile_dropoff_s = 0
	/// How much armour penetration should be decremented as the bullet moves.
	var/tile_dropoff_penetration = 0
	/// BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here.
	var/damage_type = BRUTE
	/// Determines if the projectile will skip any damage inflictions.
	var/nodamage = FALSE
	/// Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb	//Cael - bio and rad are also valid
	var/flag = BULLET
	///How much armor this projectile pierces.
	var/armour_penetration = 0
	var/projectile_type = "/obj/projectile"
	/// This will de-increment every step. When 0, it will delete the projectile.
	var/range = 50
	/// Original range upon being fired/reflected
	var/maximum_range
	/// Determines the reflectability level of a projectile, either REFLECTABILITY_NEVER, REFLECTABILITY_PHYSICAL, REFLECTABILITY_ENERGY in order of ease to reflect.
	var/reflectability = REFLECTABILITY_PHYSICAL
	/// Full log text. gets filled in fire() type, damage, reagents e.t.c.
	var/fire_log_text
	/// Whether print to admin attack logs or just keep it in the diary. example: laser tag or practice lasers
	var/log_override = FALSE
	/// Does the projectile increase fire stacks / immolate mobs on hit? Applies fire stacks equal to the number on hit.
	var/immolate = 0

	// Status effects applied on hit
	var/stun = 0 SECONDS
	var/weaken = 0 SECONDS
	var/paralyze = 0 SECONDS
	var/stutter = 0 SECONDS
	var/slur = 0 SECONDS
	var/eyeblur = 0 SECONDS
	var/drowsy = 0 SECONDS
	var/min_stamina = 0 SECONDS
	var/stamina = 0 SECONDS
	var/jitter = 0 SECONDS
	var/knockdown = 0 SECONDS
	var/confused = 0 SECONDS

	/// Number of times an object can pass through an object. -1 is infinite
	var/forcedodge = 0
	/// The higher the number, the greater the bonus to dismembering. 0 will not dismember at all.
	var/dismemberment = 0
	/// What type of impact effect to show when hitting something
	var/impact_effect_type
	var/ricochets = 0
	var/ricochets_max = 2
	var/ricochet_chance = 30

	/// For when you want your projectile to have a chain coming out of the gun
	var/chain = null

	/// Last world.time the projectile proper moved
	var/last_projectile_move = 0
	/// Left over ticks in movement calculation
	var/time_offset = 0
	/// The projectile's trajectory
	var/datum/point_precise/vector/trajectory
	/// Instructs forceMove to NOT reset our trajectory to the new location!
	var/trajectory_ignore_forcemove = FALSE

	/// Does this projectile do extra damage to / break shields?
	var/shield_buster = FALSE
	/// Does this projectile ignores def zone calculations. Used for sniper bullets.
	var/forced_accuracy = FALSE

	/// If `TRUE`, projectile with dismemberment will cut limbs instead of gib them
	var/dismember_limbs = FALSE
	/// If `TRUE`, projectile with dismemberment will forcefully cut head instead of gibbing them
	var/dismember_head = FALSE
	/// Probability to hit lying non-dead mobs
	var/hit_crawling_mobs_chance = 33

	/// Has the projectile been fired?
	var/has_been_fired = FALSE

	// Hitscan logic
	/// Wherever this projectile is hitscan. Hitscan projectiles are processed until the end of their path instantly upon being fired and leave a tracer in their path
	var/hitscan = FALSE
	/// Assoc list of datum/point_precise or datum/point_precise/vector, start = end. Used for hitscan effect generation.
	var/list/beam_segments
	/// Last turf an angle was changed in for hitscan projectiles.
	var/turf/last_angle_set_hitscan_store
	var/datum/point_precise/beam_index
	/// Last turf touched during hitscanning.
	var/turf/hitscan_last

	/// Hitscan tracer effect left behind the projectile
	var/tracer_type
	/// Hitscan muzzle effect spawned on the firer
	var/muzzle_type
	/// Hitscan impact effect spawned on the target
	var/impact_type

	// Fancy hitscan lighting effects!
	var/hitscan_light_intensity = 1.5
	var/hitscan_light_range = 0.75
	var/hitscan_light_color_override
	var/muzzle_flash_intensity = 3
	var/muzzle_flash_range = 1.5
	var/muzzle_flash_color_override
	var/impact_light_intensity = 3
	var/impact_light_range = 2
	var/impact_light_color_override
	var/hitscan_duration = 0.3 SECONDS

/obj/projectile/Initialize(mapload)
	. = ..()
	maximum_range = range
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/projectile/Destroy()
	if(hitscan)
		finalize_hitscan_and_generate_tracers()
	STOP_PROCESSING(SSprojectiles, src)
	if(ammo_casing)
		if(ammo_casing.BB == src)
			ammo_casing.BB = null
		ammo_casing =  null
	firer_source_atom = null
	firer = null
	if(trajectory)
		QDEL_NULL(trajectory)
	if(beam_index)
		QDEL_NULL(beam_index)
	return ..()

/obj/projectile/proc/Range()
	range--
	if(damage && tile_dropoff)
		damage = max(0, damage - tile_dropoff) // decrement projectile damage based on dropoff value for each tile it moves
	if(stamina && tile_dropoff_s)
		stamina = max(min_stamina, stamina - tile_dropoff_s) // as above, but with stamina
	if(tile_dropoff_penetration)
		armour_penetration = clamp(armour_penetration - tile_dropoff_penetration, -100, 100)
	if(range <= 0 && loc)
		on_range()
	if(!damage && !stamina && (tile_dropoff || tile_dropoff_s))
		on_range()

/**
 * If we want there to be effects when they reach the end of their range
 */
/obj/projectile/proc/on_range()
	qdel(src)

/obj/projectile/proc/prehit(atom/target)
	return TRUE

/obj/projectile/proc/on_hit(atom/target, blocked = 0, hit_zone)
	var/turf/target_loca = get_turf(target)
	var/hitx
	var/hity

	if(firer_source_atom)
		SEND_SIGNAL(firer_source_atom, COMSIG_PROJECTILE_ON_HIT, firer, target, Angle, hit_zone, blocked)
	SEND_SIGNAL(src, COMSIG_PROJECTILE_SELF_ON_HIT, firer, target, Angle, hit_zone, blocked)

	if(target == original)
		hitx = target.pixel_x + p_x - 16
		hity = target.pixel_y + p_y - 16
	else
		hitx = target.pixel_x + rand(-8, 8)
		hity = target.pixel_y + rand(-8, 8)

	if(!nodamage && (damage_type == BRUTE || damage_type == BURN) && iswallturf(target_loca) && prob(75))
		var/turf/simulated/wall/W = target_loca
		if(impact_effect_type && !hitscan)
			new impact_effect_type(target_loca, hitx, hity)

		W.add_dent(WALL_DENT_SHOT, hitx, hity)
		return FALSE

	if(!isliving(target))
		if(impact_effect_type && !hitscan)
			new impact_effect_type(target_loca, hitx, hity)
		return FALSE

	var/mob/living/L = target
	var/mob/living/carbon/human/H
	var/organ_hit_text = ""
	if(blocked < 100) // not completely blocked
		if(!nodamage && damage && L.blood_volume && damage_type == BRUTE)
			var/splatter_dir = Angle
			if(starting)
				splatter_dir = !isnull(Angle) ? Angle : round(get_angle(starting, target_loca), 1)
			if(isalien(L) || isfacehugger(L))
				new /obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter(target_loca, splatter_dir)
			else
				var/blood_color = BLOOD_COLOR_RED
				if(ishuman(target))
					H = target
					blood_color = H.dna.species.blood_color
				new /obj/effect/temp_visual/dir_setting/bloodsplatter(target_loca, splatter_dir, blood_color)

			if(prob(33))
				var/list/shift = list("x" = 0, "y" = 0)
				var/turf/step_over = get_step(target_loca, splatter_dir)

				if(step_over)
					if(get_splatter_blockage(step_over, target, splatter_dir, target_loca)) //If you can't cross the tile or any of its relevant obstacles...
						shift = pixel_shift_dir(angle2dir_cardinal(splatter_dir)) //Pixel shift the blood there instead (so you can't see wallsplatter through walls).
					else
						target_loca = step_over
					L.add_splatter_floor(target_loca, shift_x = shift["x"], shift_y = shift["y"])
					if(istype(H))
						for(var/mob/living/carbon/human/M in step_over) //Bloody the mobs who're infront of the spray.
							M.bloody_hands(H)
							/* Uncomment when bloody_body stops randomly not transferring blood colour.
							M.bloody_body(H) */

		else if(impact_effect_type && !hitscan)
			new impact_effect_type(target_loca, hitx, hity)
		if(L.has_limbs && def_zone)
			organ_hit_text = "в [GLOB.body_zone[def_zone][ACCUSATIVE]]!"

		if(suppressed)
			playsound(loc, hitsound, 5, TRUE, -1)
			to_chat(L, span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] попадает вам [organ_hit_text]"))
		else
			if(hitsound)
				var/volume = vol_by_damage()
				playsound(loc, hitsound, volume, TRUE, -1)
			var/hit_text = pick("получа[PLUR_ET_YUT(L)] попадание",
								"ранен[GEND_A_O_Y(L)]",
								"получа[PLUR_ET_YUT(L)] ранение",
								"поражён[GEND_A_O_Y(L)]",
								"прошибает")
			L.visible_message(span_danger("[DECLENT_RU_CAP(L, NOMINATIVE)] [hit_text] [declent_ru(INSTRUMENTAL)] [organ_hit_text]"), \
								span_userdanger("В вас попали [declent_ru(INSTRUMENTAL)] [organ_hit_text]"),
								projectile_message = TRUE)	//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter

		if(immolate)
			L.adjust_fire_stacks(immolate)
			L.IgniteMob()

		if(L?.mind && firer?.mind?.objectives)
			for(var/datum/objective/pain_hunter/objective in firer.mind.get_all_objectives())
				if(L.mind == objective.target)
					objective.take_damage(damage, damage_type)

	var/were_affects_applied = apply_effect_on_hit(L, blocked, def_zone)

	if(!log_override && firer && original)
		add_attack_logs(firer, L, "Shot [organ_hit_text][blocked ? " blocking [blocked]%" : null]. [fire_log_text]")

	return were_affects_applied

/obj/projectile/proc/apply_effect_on_hit(mob/living/target, blocked = 0, hit_zone)
	return target.apply_effects(blocked, stun, weaken, paralyze, slur, stutter, eyeblur, drowsy, stamina, jitter, knockdown, confused)

/**
 * Checks whether the place we want to splatter blood is blocked (i.e. by windows).
 */
/obj/projectile/proc/get_splatter_blockage(turf/step_over, atom/target, splatter_dir, target_loca)
	var/turf/step_cardinal = !(splatter_dir in GLOB.cardinal) ? get_step(target_loca, get_cardinal_dir(target_loca, step_over)) : null

	if(step_over.density && !step_over.CanPass(target, get_dir(step_over, target))) //Preliminary simple check.
		return TRUE
	for(var/atom/movable/border_obstacle in step_over) //Check to see if we're blocked by a (non-full) window or some such. Do deeper investigation if we're splattering blood diagonally.
		if(border_obstacle.flags&ON_BORDER && get_dir(step_cardinal ? step_cardinal : target_loca, step_over) ==  turn(border_obstacle.dir, 180))
			return TRUE

/obj/projectile/proc/vol_by_damage()
	if(damage)
		return clamp((damage) * 0.67, 30, 100)// Multiply projectile damage by 0.67, then clamp the value between 30 and 100
	else
		return 50 //if the projectile doesn't do damage, play its hitsound at 50% volume

/obj/projectile/proc/store_hitscan_collision(datum/point_precise/point_cache)
	beam_segments[beam_index] = point_cache
	beam_index = point_cache
	beam_segments[beam_index] = null

/obj/projectile/Bump(atom/bumped_atom)
	. = ..()

	if(check_ricochet(bumped_atom) && check_ricochet_flag(bumped_atom) && ricochets < ricochets_max && is_reflectable(REFLECTABILITY_PHYSICAL))
		if(hitscan && ricochets_max > 10)
			ricochets_max = 10 // I do not want a chucklefuck editing this higher, sorry.
		ricochets++
		if(bumped_atom.handle_ricochet(src))
			on_ricochet(bumped_atom)
			ignore_source_check = TRUE
			range = initial(range)
			return TRUE
	if(firer && !ignore_source_check)
		if(bumped_atom == firer || (bumped_atom == firer.loc && ismecha(bumped_atom))) //cannot shoot yourself or your mech
			loc = bumped_atom.loc
			return FALSE

	var/turf/bumped_turf = get_turf(bumped_atom)
	var/distance = get_dist(bumped_turf, starting) // Get the distance between the turf shot from and the mob we hit and use that for the calculations.
	if(!forced_accuracy)
		if(get_dist(bumped_atom, original) <= 1)
			var/hit_chance = calculate_randomize_def_zone_chance(src, distance)
			def_zone = ran_zone(def_zone, hit_chance)
		else
			def_zone = ran_zone(def_zone, probability = 0) // If we were aiming at one target but another one got hit, no accuracy is applied

	if(isturf(bumped_atom) && hitsound_wall)
		var/volume = clamp(vol_by_damage() + 20, 0, 100)
		if(suppressed)
			volume = 5
		playsound(loc, hitsound_wall, volume, TRUE, -1)
	else if(ishuman(bumped_atom))
		var/mob/living/carbon/human/bumped_human = bumped_atom
		var/obj/item/organ/external/organ = bumped_human.get_organ(check_zone(def_zone))
		if(isnull(organ))
			return FALSE

	if(HAS_TRAIT(src, TRAIT_SHRAPNEL))
		shrapnel_hit(bumped_atom)
		return

	prehit(bumped_atom)

	var/permutation = bumped_atom.bullet_act(src, def_zone) // searches for return value, could be deleted after run so check A isn't null
	if(permutation == -1 || forcedodge == -1 ||forcedodge >= 1) // the bullet passes through a dense object!
		if(forcedodge >= 1)
			forcedodge -= 1
		loc = bumped_turf
		if(bumped_atom)
			LAZYADD(permutated, bumped_atom)
		return FALSE
	else
		if(bumped_atom?.density && !ismob(bumped_atom) && !(bumped_atom.flags & ON_BORDER)) //if we hit a dense non-border obj or dense turf then we also hit one of the mobs on that tile.
			var/list/mobs_list = list()
			for(var/mob/living/mob in bumped_turf)
				mobs_list += mob
			if(length(mobs_list))
				var/mob/living/picked_mob = pick(mobs_list)
				prehit(picked_mob)
				picked_mob.bullet_act(src, def_zone)
	qdel(src)

/obj/projectile/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE //Bullets don't drift in space

/obj/projectile/process()
	if(!loc || !trajectory)
		return PROCESS_KILL
	if(paused || !isturf(loc))
		last_projectile_move = world.time
		return
	var/elapsed_time_deciseconds = (world.time - last_projectile_move) + time_offset
	time_offset = 0
	var/required_moves = hitscan ? MOVES_HITSCAN : FLOOR(elapsed_time_deciseconds / speed, 1)
	if(required_moves == MOVES_HITSCAN)
		required_moves = SSprojectiles.global_max_tick_moves
	if(required_moves > SSprojectiles.global_max_tick_moves)
		var/overrun = required_moves - SSprojectiles.global_max_tick_moves
		required_moves = SSprojectiles.global_max_tick_moves
		time_offset += overrun * speed
	time_offset += MODULUS(elapsed_time_deciseconds, speed)

	for(var/i in 1 to required_moves)
		pixel_move(1)

/obj/projectile/proc/shrapnel_hit(atom/target)
	return

/obj/projectile/proc/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	if(!loc || !trajectory)
		return
	last_projectile_move = world.time
	// Keep on course
	if(!hitscanning)
		var/matrix/matrix = new
		matrix.Turn(Angle)
		transform = matrix
	// Iterate
	var/forcemoved = FALSE
	for(var/i in 1 to SSprojectiles.global_iterations_per_move)
		if(QDELETED(src))
			return
		trajectory.increment(trajectory_multiplier)
		var/turf/T = trajectory.return_turf()
		if(!istype(T))
			// if we've gone off of the map, we need to step back once so that hitscanning projectiles have a valid end turf
			trajectory.increment(-trajectory_multiplier)
			qdel(src)
			return
		if(T.z != loc.z)
			trajectory_ignore_forcemove = TRUE
			forceMove(T)
			trajectory_ignore_forcemove = FALSE
			if(!hitscanning)
				pixel_x = trajectory.return_px()
				pixel_y = trajectory.return_py()
			forcemoved = TRUE
			hitscan_last = loc
		else if(T != loc)
			step_towards(src, T)
			hitscan_last = loc
		if(original && (original.layer >= PROJECTILE_HIT_THRESHOLD_LAYER && !isliving(original)))
			if(loc == get_turf(original) && !(original in permutated))
				Bump(original)
	if(QDELETED(src)) //deleted on last move
		return
	if(!hitscanning && !forcemoved)
		pixel_x = trajectory.return_px() - trajectory.mpx * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		pixel_y = trajectory.return_py() - trajectory.mpy * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		animate(src, pixel_x = trajectory.return_px(), pixel_y = trajectory.return_py(), time = 1, flags = ANIMATION_END_NOW)
	Range()

/obj/projectile/proc/fire(setAngle)
	if(setAngle)
		Angle = setAngle

	if(!log_override && firer && original)
		fire_log_text += "Projectile: <small>'[type]'</small> | Harm: [nodamage ? "<small>NO DAMAGE</small>" : "<small>[uppertext(damage_type)] = </small>[damage]"]"
		if(reagents?.reagent_list)
			var/reagent_note
			var/list/temp = reagents.reagent_list.Copy()
			for(var/datum/reagent/R in temp)
				temp -= R
				reagent_note += "<small>[R] = </small>[R.volume]u"
				if(length(temp))
					reagent_note += ", "
			fire_log_text += " | Reagents: [reagent_note]"

		add_attack_logs(firer, original, "Fired at. [fire_log_text]")

	if(!current || loc == current)
		current = locate(clamp(x + xo, 1, world.maxx), clamp(y + yo, 1, world.maxy), z)
	if(isnull(Angle))
		Angle = round(get_angle(src, current))
	original_angle = Angle
	if(spread)
		Angle += (rand() - 0.5) * spread
	if(firer && ismob(firer) && firer.a_intent != INTENT_HELP)
		hit_crawling_mobs_chance =  100
	// Turn right away
	var/matrix/M = new
	M.Turn(Angle)
	transform = M
	// Start flying
	trajectory = new(x, y, z, pixel_x, pixel_y, Angle, SSprojectiles.global_pixel_speed)
	last_projectile_move = world.time
	has_been_fired = TRUE
	if(hitscan)
		process_hitscan()
	START_PROCESSING(SSprojectiles, src)
	pixel_move(1, FALSE)

/obj/projectile/proc/reflect_back(atom/source, list/position_modifiers = list(0, 0, 0, 0, 0, -1, 1, -2, 2))
	if(!starting)
		return
	var/new_x = starting.x + pick(position_modifiers)
	var/new_y = starting.y + pick(position_modifiers)
	var/turf/curloc = get_turf(source)
	if(!curloc)
		return

	if(ismob(source))
		firer = source // The reflecting mob will be the new firer

	// redirect the projectile
	original = locate(new_x, new_y, z)
	starting = curloc
	current = curloc
	yo = new_y - curloc.y
	xo = new_x - curloc.x
	hit_crawling_mobs_chance = 100
	set_angle(get_angle(curloc, original))

/obj/projectile/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(arrived.density && !(pass_flags & PASSMOB) && isliving(arrived))
		Bump(arrived)

/obj/projectile/proc/dumbfire(dir)
	current = get_ranged_target_turf(src, dir, world.maxx) //world.maxx is the range. Not sure how to handle this better.
	fire()

/obj/projectile/proc/on_ricochet(atom/A)
	return

/obj/projectile/proc/check_ricochet(atom/A)
	if(prob(ricochet_chance))
		return TRUE
	return FALSE

/obj/projectile/proc/check_ricochet_flag(atom/A)
	if((flag == ENERGY || flag == LASER) && (A.flags_ricochet & RICOCHET_SHINY))
		return TRUE

	if((flag == BOMB || flag == BULLET) && (A.flags_ricochet & RICOCHET_HARD))
		return TRUE

	if(flag == BULLET && (A.flags_ricochet & RICOCHET_BALLISTIC))
		return TRUE

	return FALSE

/obj/projectile/set_angle(new_angle)
	..()
	Angle = new_angle
	if(trajectory)
		trajectory.set_angle(new_angle)
	if(has_been_fired && hitscan && isloc(loc) && (loc != last_angle_set_hitscan_store))
		last_angle_set_hitscan_store = loc
		var/datum/point/point_cache = new (src)
		point_cache = trajectory.copy_to()
		store_hitscan_collision(point_cache)
	return TRUE

/obj/projectile/proc/set_angle_centered(new_angle)
	set_angle(new_angle)
	var/list/coordinates = trajectory.return_coordinates()
	trajectory.set_location(coordinates[1], coordinates[2], coordinates[3]) // Sets the trajectory to the center of the tile it bounced at
	if(has_been_fired && hitscan && isloc(loc)) // Handles hitscan projectiles
		last_angle_set_hitscan_store = loc
		var/datum/point_precise/point_cache = new (src)
		point_cache.initialize_location(coordinates[1], coordinates[2], coordinates[3]) // Take the center of the hitscan collision tile
		store_hitscan_collision(point_cache)
	return TRUE

/obj/projectile/experience_pressure_difference()
	return // Immune to gas flow.

/obj/projectile/forceMove(atom/target)
	. = ..()
	if(QDELETED(src)) // we coulda bumped something
		return
	if(trajectory && !trajectory_ignore_forcemove && isturf(target))
		if(hitscan)
			finalize_hitscan_and_generate_tracers(FALSE)
		trajectory.initialize_location(target.x, target.y, target.z, 0, 0)
		if(hitscan)
			record_hitscan_start(RETURN_PRECISE_POINT(src))

/obj/projectile/proc/is_reflectable(desired_reflectability_level)
	if(reflectability == REFLECTABILITY_NEVER) //You'd trust coders not to try and override never reflectable things, but heaven help us I do not
		return FALSE
	if(reflectability < desired_reflectability_level)
		return FALSE
	return TRUE

/obj/projectile/proc/record_hitscan_start(datum/point_precise/point_cache)
	if(point_cache)
		beam_segments = list()
		beam_index = point_cache
		beam_segments[beam_index] = null //record start.

/obj/projectile/proc/process_hitscan()
	//Safety here is to make hitscan stop if something goes wrong. Why is it equal to range * 10, when range is the maximum amount of tiles it can go? No clue.
	var/safety = range * 10
	record_hitscan_start(RETURN_POINT_VECTOR_INCREMENT(src, Angle, MUZZLE_EFFECT_PIXEL_INCREMENT, 1))

	while(loc && !QDELETED(src))
		if(paused)
			stoplag(1)
			continue

		safety--
		if(safety <= 0)
			if(loc)
				Bump(loc)
			if(!QDELETED(src))
				qdel(src)
			return //Kill!

		pixel_move(1, TRUE)
		// No kevinz I do not care that this is a hitscan weapon, it is not allowed to travel 100 turfs in a tick
		if(CHECK_TICK && QDELETED(src))
			return

/obj/projectile/proc/finalize_hitscan_and_generate_tracers(impacting = TRUE)
	if(trajectory && beam_index)
		var/datum/point_precise/point_cache = trajectory.copy_to()
		beam_segments[beam_index] = point_cache
	generate_hitscan_tracers(null, hitscan_duration, impacting)

/obj/projectile/proc/generate_hitscan_tracers(cleanup = TRUE, duration = 0.3 SECONDS, impacting = TRUE)
	if(!length(beam_segments))
		return

	generate_tracers(duration)
	generate_muzzle_effect(duration)
	generate_impact_effect(duration, impacting)

	if(cleanup)
		cleanup_beam_segments()

/obj/projectile/proc/generate_tracers(duration)
	if(!tracer_type)
		return

	var/tempuid = UID()
	for(var/datum/point_precise/beam_point in beam_segments)
		generate_tracer_between_points(
			beam_point,
			beam_segments[beam_point],
			tracer_type,
			color,
			duration,
			hitscan_light_range,
			hitscan_light_color_override,
			hitscan_light_intensity,
			tempuid
		)

/obj/projectile/proc/generate_muzzle_effect(duration)
	if(!muzzle_type || duration <= 0)
		return

	var/datum/point_precise/start_point = beam_segments[1]
	var/atom/movable/muzzle_effect = new muzzle_type
	start_point.move_atom_to_src(muzzle_effect)

	var/matrix/matrix = new
	matrix.Turn(original_angle)
	muzzle_effect.transform = matrix
	muzzle_effect.color = color

	var/light_color = muzzle_flash_color_override ? muzzle_flash_color_override : color
	muzzle_effect.set_light(muzzle_flash_range, muzzle_flash_intensity, light_color)

	QDEL_IN(muzzle_effect, duration)

/obj/projectile/proc/generate_impact_effect(duration, impacting)
	if(!impacting || !impact_type || duration <= 0)
		return

	var/datum/point_precise/last_point = beam_segments[beam_segments[length(beam_segments)]]
	var/atom/movable/impact_effect = new impact_type
	last_point.move_atom_to_src(impact_effect)

	var/matrix/matrix = new
	matrix.Turn(Angle)
	impact_effect.transform = matrix
	impact_effect.color = color

	var/light_color = impact_light_color_override ? impact_light_color_override : color
	impact_effect.set_light(impact_light_range, impact_light_intensity, light_color)

	QDEL_IN(impact_effect, duration)

/obj/projectile/proc/cleanup_beam_segments()
	QDEL_LIST_ASSOC(beam_segments)

#undef MOVES_HITSCAN
#undef MUZZLE_EFFECT_PIXEL_INCREMENT
