/obj/effect/proc_holder/spell/mob_cooldown/charge
	name = "Заряд"
	action_icon = 'icons/mob/actions/actions_items.dmi'
	action_icon_state = "sniper_zoom"
	desc = "Если вы это видите, кто-то набагал."
	base_cooldown = 1.5 SECONDS
	/// Delay before the charge actually occurs
	var/charge_delay = 0.3 SECONDS
	/// The amount of turfs we move past the target
	var/charge_past = 2
	/// The maximum distance we can charge
	var/charge_distance = 50
	/// The sleep time before moving in deciseconds while charging
	var/charge_speed = 0.5
	/// The damage the charger does when bumping into something
	var/charge_damage = 30
	/// If we destroy objects while charging
	var/destroy_objects = TRUE
	/// If the current move is being triggered by us or not
	var/actively_moving = FALSE
	/// List of charging mobs
	var/list/charging = list()


/obj/effect/proc_holder/spell/mob_cooldown/charge/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/spell_targeting = new()
	spell_targeting.range = charge_distance
	return spell_targeting


/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/charge_sequence(atom/movable/charger, atom/target_atom, delay, past)
	do_charge(action.owner, target_atom, charge_delay, charge_past)


/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/do_charge(atom/movable/charger, atom/target_atom, delay, past)
	if(!target_atom/* || target_atom == action.owner*/)
		return

	var/chargeturf = get_turf(target_atom)
	if(!chargeturf)
		return

	var/dir = get_dir(charger, target_atom)
	var/turf/target = get_ranged_target_turf(chargeturf, dir, past)
	if(!target)
		return

	if(charger in charging)
		// Stop any existing charging, this'll clean things up properly
		SSmove_manager.stop_looping(charger)

	charging += charger
	actively_moving = FALSE
	//SEND_SIGNAL(action.owner, COMSIG_STARTED_CHARGE)
	RegisterSignal(charger, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump), override = TRUE)
	RegisterSignal(charger, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_move), override = TRUE)
	RegisterSignal(charger, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved), override = TRUE)
	RegisterSignal(charger, COMSIG_LIVING_DEATH, PROC_REF(charge_end), override = TRUE)
	charger.setDir(dir)
	do_charge_indicator(charger, target)

	SLEEP_CHECK_DEATH(charger, delay)

	var/time_to_hit = min(get_dist(charger, target), charge_distance) * charge_speed

	var/datum/move_loop/new_loop = SSmove_manager.home_onto(charger, target, delay = charge_speed, timeout = time_to_hit, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	if(!new_loop)
		return

	RegisterSignal(new_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move), override = TRUE)
	RegisterSignal(new_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move), override = TRUE)
	RegisterSignal(new_loop, COMSIG_QDELETING, PROC_REF(charge_end), override = TRUE)

	// Yes this is disgusting. But we need to queue this stuff, and this code just isn't setup to support that right now. So gotta do it with sleeps
	sleep(time_to_hit + charge_speed)
	charger.setDir(dir)

	return TRUE


/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/pre_move(datum)
	SIGNAL_HANDLER
	// If you sleep in Move() you deserve what's coming to you
	actively_moving = TRUE


/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/post_move(datum)
	SIGNAL_HANDLER
	actively_moving = FALSE


/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/charge_end(datum/source)
	SIGNAL_HANDLER
	var/atom/movable/charger = source
	if(istype(source, /datum/move_loop))
		var/datum/move_loop/move_loop_source = source
		charger = move_loop_source.moving

	UnregisterSignal(charger, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DEATH))
	//SEND_SIGNAL(action.owner, COMSIG_FINISHED_CHARGE)
	actively_moving = FALSE
	charging -= charger


/*
/obj/effect/proc_holder/spell/mob_cooldown/charge/update_status_on_signal(mob/source, new_stat, old_stat)
	. = ..()
	if(new_stat == DEAD)
		SSmove_manager.stop_looping(source) //This will cause the loop to qdel, triggering an end to our charging
*/

/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/do_charge_indicator(atom/charger, atom/charge_target)
	var/turf/target_turf = get_turf(charge_target)
	if(!target_turf)
		return

	new /obj/effect/temp_visual/dragon_swoop/bubblegum(target_turf)
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(charger.loc, charger)
	animate(D, alpha = 0, color = COLOR_RED, transform = matrix()*2, time = 3)


/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/on_move(atom/source, atom/new_loc)
	SIGNAL_HANDLER
	//if(!actively_moving)
	//	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

	new /obj/effect/temp_visual/decoy/fading(source.loc, source)
	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)


/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/on_moved(atom/source)
	SIGNAL_HANDLER
	playsound(source, 'sound/effects/meteorimpact.ogg', 200, TRUE, 2, TRUE)
	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)


/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/DestroySurroundings(atom/movable/charger)
	if(!destroy_objects)
		return

	if(!isanimal(charger))
		return

	for(var/dir in GLOB.cardinal)
		var/turf/next_turf = get_step(charger, dir)
		if(!next_turf)
			continue

		if(next_turf.Adjacent(charger) && (iswallturf(next_turf) || ismineralturf(next_turf)))
			if(!isanimal(charger))
				next_turf.ex_act(EXPLODE_HEAVY)
				continue

			next_turf.attack_animal(charger)
			continue

		for(var/obj/object in next_turf.contents)
			if(!object.Adjacent(charger))
				continue

			if(!ismachinery(object) && !isstructure(object))
				continue

			if(!object.density || object.IsObscured())
				continue

			if(!isanimal(charger))
				object.ex_act(EXPLODE_HEAVY)
				break

			object.attack_animal(charger)
			break


/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/on_bump(atom/movable/source, atom/target)
	SIGNAL_HANDLER
	if(action.owner == target)
		return
	if(destroy_objects)
		if(isturf(target) || isobj(target) && target.density)
			target.ex_act(EXPLODE_HEAVY)

	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
	try_hit_target(source, target)



/// Attempt to hit someone with our charge
/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/try_hit_target(atom/movable/source, atom/target)
	if(can_hit_target(source, target))
		hit_target(source, target, charge_damage)


/// Returns true if we're allowed to charge into this target
/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/can_hit_target(atom/movable/source, atom/target)
	return isliving(target)


/// Actually hit someone
/obj/effect/proc_holder/spell/mob_cooldown/charge/proc/hit_target(atom/movable/source, mob/living/target, damage_dealt)
	target.visible_message(span_danger("[source] slams into [target]!"), span_userdanger("[source] tramples you into the ground!"))
	target.apply_damage(damage_dealt, BRUTE)
	playsound(get_turf(target), 'sound/effects/meteorimpact.ogg', 100, TRUE)
	shake_camera(target, 4, 3)
	shake_camera(source, 2, 3)
