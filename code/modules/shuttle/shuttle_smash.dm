/obj/docking_port/mobile/proc/shuttle_smash(list/mobile_turfs, list/stationary_turfs, mobile_dir)
	var/list/viewers_by_turf = list()
	var/list/things_by_turf = list()

	for(var/i in 1 to length(mobile_turfs))
		var/turf/mobile_turf = mobile_turfs[i]
		var/turf/stationary_turf = stationary_turfs[i]
		if(!mobile_turf || !stationary_turf)
			continue

		for(var/atom/movable/movable in stationary_turf.contents)
			var/movable_name = "[movable.name]"
			if(movable.shuttle_crush_react(stationary_turf, mobile_dir))
				if(!viewers_by_turf[stationary_turf])
					viewers_by_turf[stationary_turf] = get_mobs_in_view(7, stationary_turf, FALSE, FALSE) - movable
				else
					viewers_by_turf[stationary_turf] -= movable
				if(!things_by_turf[stationary_turf])
					things_by_turf[stationary_turf] = list()
				things_by_turf[stationary_turf] += movable_name

			CHECK_TICK

	for(var/turf in viewers_by_turf)
		if(!length(viewers_by_turf[turf]) || !length(things_by_turf[turf]))
			continue
		var/destroyed = capitalize(english_list(things_by_turf[turf]))
		for(var/mob/viewer as anything in viewers_by_turf[turf])
			viewer.show_message(span_warning("[destroyed] gets crushed by a hyperspace ripple!"), EMOTE_VISIBLE)


/**
 * Atom crushed by shuttle feedback.
 * Avoid any visible messages here, since it will clutter the chat tremendously.
 *
 * Return `TRUE` if atom was crushed and it must be noticed by viewers of stationary_turf .
 */
/atom/movable/proc/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	. = FALSE
	pulledby?.stop_pulling()
	if(!skip_ungibable_search)
		drop_ungibbable_items(stationary_turf)
	if(simulated) // Don't qdel lighting overlays, they are static
		qdel(src)


// Mobs

/mob/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	return FALSE


/mob/living/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	if(incorporeal_move || HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	if(!isturf(loc))
		forceMove(stationary_turf)
	. = TRUE
	pulledby?.stop_pulling()
	buckled?.unbuckle_mob(src, force = TRUE)
	to_chat(src, span_userdanger("You feel an immense crushing pressure as the space around you ripples."))
	if(!skip_ungibable_search)
		drop_ungibbable_items(stationary_turf)
	for(var/mob/living/victim in contents)
		victim.shuttle_crush_react(stationary_turf, mobile_dir)
	gib()


/mob/living/silicon/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = TRUE)
	. = ..()	// we are skipping ungibable search, since silicons have no valuables to drop and this only cause bugs with brain removal


/mob/living/silicon/robot/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = TRUE)
	if(module)
		var/obj/item/gripper/our_gripper = locate() in module.modules
		our_gripper?.drop_ungibbable_items(stationary_turf)
	return ..()


/mob/living/silicon/ai/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	return FALSE


/mob/living/carbon/brain/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	return FALSE


// Objects

/obj/mecha/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	var/mob/living/pilot = occupant
	..()
	pilot?.shuttle_crush_react(stationary_turf, mobile_dir, TRUE)
	return TRUE


/obj/spacepod/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	var/list/happy_three_friends = passengers + pilot
	..()
	for(var/mob/living/victim as anything in happy_three_friends)
		victim.shuttle_crush_react(stationary_turf, mobile_dir, TRUE)
	return TRUE


/obj/structure/closet/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	var/list/insides = contents.Copy()
	..()
	for(var/atom/movable/thing as anything in insides)
		thing.shuttle_crush_react(stationary_turf, mobile_dir, TRUE)
	return TRUE


/obj/item/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	if(is_type_in_list(src, GLOB.ungibbable_items_types))
		return FALSE
	..()
	return TRUE


/obj/effect/dummy/chameleon/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	. = FALSE
	var/atom/movable/user = master?.loc
	master?.disrupt()
	if(ismovable(user))
		user.shuttle_crush_react(stationary_turf, mobile_dir)


/obj/effect/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	return FALSE


/atom/movable/screen/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	return FALSE


/obj/docking_port/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	return FALSE


/obj/singularity/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	return FALSE


/obj/machinery/nuclearbomb/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	return FALSE

