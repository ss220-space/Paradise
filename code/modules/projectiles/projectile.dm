/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/weapons/projectiles.dmi'
	icon_state = "bullet"
	density = FALSE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE //There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	item_flags = ABSTRACT
	pass_flags = PASSTABLE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	movement_type = FLYING
	animate_movement = NO_STEPS
	hitsound = 'sound/weapons/pierce.ogg'
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
	var/yo = null
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
	var/Angle = null
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
	/// BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here.
	var/damage_type = BRUTE
	/// Determines if the projectile will skip any damage inflictions.
	var/nodamage = FALSE
	/// Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb	//Cael - bio and rad are also valid
	var/flag = BULLET
	var/projectile_type = "/obj/item/projectile"
	/// This will de-increment every step. When 0, it will delete the projectile.
	var/range = 50
	/// Determines the reflectability level of a projectile, either REFLECTABILITY_NEVER, REFLECTABILITY_PHYSICAL, REFLECTABILITY_ENERGY in order of ease to reflect.
	var/reflectability = REFLECTABILITY_PHYSICAL
	/// Full log text. gets filled in fire() type, damage, reagents e.t.c.
	var/fire_log_text
	/// Whether print to admin attack logs or just keep it in the diary. example: laser tag or practice lasers
	var/log_override = FALSE

	//Effects
	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/slur = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/stamina = 0
	var/jitter = 0
	var/knockdown = 0

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
	var/hit_crawling_mobs_chance = 0


/obj/item/projectile/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/item/projectile/proc/Range()
	range--
	if(damage && tile_dropoff)
		damage = max(0, damage - tile_dropoff) // decrement projectile damage based on dropoff value for each tile it moves
	if(stamina && tile_dropoff_s)
		stamina = max(0, stamina - tile_dropoff_s) // as above, but with stamina
	if(range <= 0 && loc)
		on_range()
	if(!damage && !stamina && (tile_dropoff || tile_dropoff_s))
		on_range()


/**
 * If we want there to be effects when they reach the end of their range
 */
/obj/item/projectile/proc/on_range()
	qdel(src)


/obj/item/projectile/proc/prehit(atom/target)
	return TRUE


/obj/item/projectile/proc/on_hit(atom/target, blocked = 0, hit_zone)
	var/turf/target_loca = get_turf(target)
	var/hitx
	var/hity

	if(target == original)
		hitx = target.pixel_x + p_x - 16
		hity = target.pixel_y + p_y - 16
	else
		hitx = target.pixel_x + rand(-8, 8)
		hity = target.pixel_y + rand(-8, 8)

	if(!nodamage && (damage_type == BRUTE || damage_type == BURN) && iswallturf(target_loca) && prob(75))
		var/turf/simulated/wall/W = target_loca
		if(impact_effect_type)
			new impact_effect_type(target_loca, hitx, hity)

		W.add_dent(WALL_DENT_SHOT, hitx, hity)
		return FALSE

	if(!isliving(target))
		if(impact_effect_type)
			new impact_effect_type(target_loca, hitx, hity)
		return FALSE

	var/mob/living/L = target
	var/mob/living/carbon/human/H
	var/organ_hit_text = ""
	if(blocked < 100) // not completely blocked
		if(!nodamage && damage && L.blood_volume && damage_type == BRUTE)
			var/splatter_dir = dir
			if(starting)
				splatter_dir = get_dir(starting, target_loca)
			if(isalien(L))
				new /obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter(target_loca, splatter_dir)
			else
				var/blood_color = "#C80000"
				if(ishuman(target))
					H = target
					blood_color = H.dna.species.blood_color
				new /obj/effect/temp_visual/dir_setting/bloodsplatter(target_loca, splatter_dir, blood_color)

			if(prob(33))
				var/list/shift = list("x" = 0, "y" = 0)
				var/turf/step_over = get_step(target_loca, splatter_dir)

				if(step_over)
					if(get_splatter_blockage(step_over, target, splatter_dir, target_loca)) //If you can't cross the tile or any of its relevant obstacles...
						shift = pixel_shift_dir(splatter_dir) //Pixel shift the blood there instead (so you can't see wallsplatter through walls).
					else
						target_loca = step_over
					L.add_splatter_floor(target_loca, shift_x = shift["x"], shift_y = shift["y"])
					if(istype(H))
						for(var/mob/living/carbon/human/M in step_over) //Bloody the mobs who're infront of the spray.
							M.bloody_hands(H)
							/* Uncomment when bloody_body stops randomly not transferring blood colour.
							M.bloody_body(H) */

		else if(impact_effect_type)
			new impact_effect_type(target_loca, hitx, hity)
		if(L.has_limbs)
			organ_hit_text = " in \the [parse_zone(def_zone)]"

		if(suppressed)
			playsound(loc, hitsound, 5, 1, -1)
			to_chat(L, "<span class='userdanger'>You're shot by \a [src][organ_hit_text]!</span>")
		else
			if(hitsound)
				var/volume = vol_by_damage()
				playsound(loc, hitsound, volume, 1, -1)
			L.visible_message("<span class='danger'>[L] is hit by \a [src][organ_hit_text]!</span>", \
								"<span class='userdanger'>[L] is hit by \a [src][organ_hit_text]!</span>")	//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter

		if(L.mind && firer?.mind?.objectives)
			for(var/datum/objective/pain_hunter/objective in firer.mind.get_all_objectives())
				if(L.mind == objective.target)
					objective.take_damage(damage, damage_type)

	var/were_affects_applied = L.apply_effects(blocked, stun, weaken, paralyze, irradiate, slur, stutter, eyeblur, drowsy, stamina, jitter, knockdown)

	if(!log_override && firer && original)
		add_attack_logs(firer, L, "Shot[organ_hit_text][blocked ? " blocking [blocked]%" : null]. [fire_log_text]")

	return were_affects_applied


/**
 * Checks whether the place we want to splatter blood is blocked (i.e. by windows).
 */
/obj/item/projectile/proc/get_splatter_blockage(turf/step_over, atom/target, splatter_dir, target_loca)
	var/turf/step_cardinal = !(splatter_dir in list(NORTH, SOUTH, EAST, WEST)) ? get_step(target_loca, get_cardinal_dir(target_loca, step_over)) : null

	if(step_over.density && !step_over.CanPass(target, get_dir(step_over, target))) //Preliminary simple check.
		return TRUE
	for(var/atom/movable/border_obstacle in step_over) //Check to see if we're blocked by a (non-full) window or some such. Do deeper investigation if we're splattering blood diagonally.
		if(border_obstacle.flags&ON_BORDER && get_dir(step_cardinal ? step_cardinal : target_loca, step_over) ==  turn(border_obstacle.dir, 180))
			return TRUE


/obj/item/projectile/proc/vol_by_damage()
	if(damage)
		return clamp((damage) * 0.67, 30, 100)// Multiply projectile damage by 0.67, then clamp the value between 30 and 100
	else
		return 50 //if the projectile doesn't do damage, play its hitsound at 50% volume


/obj/item/projectile/Bump(atom/bumped_atom)
	. = ..()

	if(check_ricochet(bumped_atom) && check_ricochet_flag(bumped_atom) && ricochets < ricochets_max && is_reflectable(REFLECTABILITY_PHYSICAL))
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
			def_zone = ran_zone(def_zone, max(100 - (7 * distance), 5)) //Lower accurancy/longer range tradeoff. 7 is a balanced number to use.
		else
			def_zone = pick(list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)) // If we were aiming at one target but another one got hit, no accuracy is applied

	if(isturf(bumped_atom) && hitsound_wall)
		var/volume = clamp(vol_by_damage() + 20, 0, 100)
		if(suppressed)
			volume = 5
		playsound(loc, hitsound_wall, volume, 1, -1)
	else if(ishuman(bumped_atom))
		var/mob/living/carbon/human/bumped_human = bumped_atom
		var/obj/item/organ/external/organ = bumped_human.get_organ(check_zone(def_zone))
		if(isnull(organ))
			return FALSE

	prehit(bumped_atom)
	var/permutation = bumped_atom.bullet_act(src, def_zone) // searches for return value, could be deleted after run so check A isn't null
	if(permutation == -1 || forcedodge)// the bullet passes through a dense object!
		if(forcedodge > 0)
			forcedodge -= 1
		loc = bumped_turf
		if(bumped_atom)
			LAZYADD(permutated, bumped_atom)
		return FALSE
	else
		if(bumped_atom && bumped_atom.density && !ismob(bumped_atom) && !(bumped_atom.flags & ON_BORDER)) //if we hit a dense non-border obj or dense turf then we also hit one of the mobs on that tile.
			var/list/mobs_list = list()
			for(var/mob/living/mob in bumped_turf)
				mobs_list += mob
			if(mobs_list.len)
				var/mob/living/picked_mob = pick(mobs_list)
				prehit(picked_mob)
				picked_mob.bullet_act(src, def_zone)
	qdel(src)


/obj/item/projectile/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE //Bullets don't drift in space


/obj/item/projectile/process()
	if(!loc || !trajectory)
		return PROCESS_KILL
	if(paused || !isturf(loc))
		last_projectile_move = world.time
		return
	var/elapsed_time_deciseconds = (world.time - last_projectile_move) + time_offset
	time_offset = 0
	var/required_moves = FLOOR(elapsed_time_deciseconds / speed, 1)
	if(required_moves > SSprojectiles.global_max_tick_moves)
		var/overrun = required_moves - SSprojectiles.global_max_tick_moves
		required_moves = SSprojectiles.global_max_tick_moves
		time_offset += overrun * speed
	time_offset += MODULUS(elapsed_time_deciseconds, speed)

	for(var/i in 1 to required_moves)
		pixel_move(1)


/obj/item/projectile/proc/pixel_move(trajectory_multiplier)
	if(!loc || !trajectory)
		return
	last_projectile_move = world.time
	// Keep on course
	var/matrix/M = new
	M.Turn(Angle)
	transform = M
	// Iterate
	var/forcemoved = FALSE
	for(var/i in 1 to SSprojectiles.global_iterations_per_move)
		if(QDELETED(src))
			return
		trajectory.increment(trajectory_multiplier)
		var/turf/T = trajectory.return_turf()
		if(!istype(T))
			qdel(src)
			return
		if(T.z != loc.z)
			trajectory_ignore_forcemove = TRUE
			forceMove(T)
			trajectory_ignore_forcemove = FALSE
			pixel_x = trajectory.return_px()
			pixel_y = trajectory.return_py()
			forcemoved = TRUE
		else if(T != loc)
			step_towards(src, T)
		if(original && (original.layer >= PROJECTILE_HIT_THRESHHOLD_LAYER || ismob(original)))
			if(loc == get_turf(original) && !(original in permutated))
				Bump(original)
	if(QDELETED(src)) //deleted on last move
		return
	if(!forcemoved)
		pixel_x = trajectory.return_px() - trajectory.mpx * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		pixel_y = trajectory.return_py() - trajectory.mpy * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		animate(src, pixel_x = trajectory.return_px(), pixel_y = trajectory.return_py(), time = 1, flags = ANIMATION_END_NOW)
	Range()


/obj/item/projectile/proc/fire(setAngle)
	if(setAngle)
		Angle = setAngle

	if(!log_override && firer && original)
		fire_log_text += "Projectile: <small>'[type]'</small> | Harm: [nodamage ? "<small>NO DAMAGE</small>" : "<small>[uppertext(damage_type)] = </small>[damage]"]"
		if(reagents && reagents.reagent_list)
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
	if(spread)
		Angle += (rand() - 0.5) * spread
	// Turn right away
	var/matrix/M = new
	M.Turn(Angle)
	transform = M
	// Start flying
	trajectory = new(x, y, z, pixel_x, pixel_y, Angle, SSprojectiles.global_pixel_speed)
	last_projectile_move = world.time
	START_PROCESSING(SSprojectiles, src)
	pixel_move(1, FALSE)


/obj/item/projectile/proc/reflect_back(atom/source, list/position_modifiers = list(0, 0, 0, 0, 0, -1, 1, -2, 2))
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
	set_angle(get_angle(curloc, original))


/obj/item/projectile/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(arrived.density && !(pass_flags & PASSMOB) && isliving(arrived))
		Bump(arrived)


/obj/item/projectile/Destroy()
	STOP_PROCESSING(SSprojectiles, src)
	ammo_casing = null
	firer_source_atom = null
	firer = null
	return ..()


/obj/item/projectile/proc/dumbfire(dir)
	current = get_ranged_target_turf(src, dir, world.maxx) //world.maxx is the range. Not sure how to handle this better.
	fire()


/obj/item/projectile/proc/on_ricochet(atom/A)
	return


/obj/item/projectile/proc/check_ricochet(atom/A)
	if(prob(ricochet_chance))
		return TRUE
	return FALSE


/obj/item/projectile/proc/check_ricochet_flag(atom/A)
	if(A.flags & CHECK_RICOCHET)
		return TRUE
	return FALSE


/obj/item/projectile/set_angle(new_angle)
	..()
	Angle = new_angle
	trajectory.set_angle(new_angle)


/obj/item/projectile/proc/set_angle_centered(new_angle)
	set_angle(new_angle)
	var/list/coordinates = trajectory.return_coordinates()
	trajectory.set_location(coordinates[1], coordinates[2], coordinates[3]) // Sets the trajectory to the center of the tile it bounced at


/obj/item/projectile/experience_pressure_difference()
	return


/obj/item/projectile/forceMove(atom/target)
	. = ..()
	if(QDELETED(src)) // we coulda bumped something
		return
	if(trajectory && !trajectory_ignore_forcemove && isturf(target))
		trajectory.initialize_location(target.x, target.y, target.z, 0, 0)


/obj/item/projectile/proc/is_reflectable(desired_reflectability_level)
	if(reflectability == REFLECTABILITY_NEVER) //You'd trust coders not to try and override never reflectable things, but heaven help us I do not
		return FALSE
	if(reflectability < desired_reflectability_level)
		return FALSE
	return TRUE
