// TODO: move to spell actions once they are done

/datum/action/cooldown/bingle
	name = "Бингл что-то"
	desc = "Напишите баг-репорт, если увидели это."
	button_icon = 'icons/mob/bingle/binglepit.dmi'

/datum/action/cooldown/bingle/IsAvailable(feedback = FALSE)
	if(!isbingle(owner))
		return FALSE
	return ..()

/datum/action/cooldown/bingle/create_hole
	name = "Create Bingle Pit"
	desc = "Единожды создаёт яму."
	button_icon_state = "binglepit"
	/// How long does it take to create a hole
	var/creation_time = 5 SECONDS

/datum/action/cooldown/bingle/create_hole/Activate()
	. = ..()
	var/mob/living/user = owner
	var/turf/our_turf = get_turf(user)
	if(isspaceturf(our_turf))
		user.balloon_alert(user, "невозможно в космосе!")
		return
	if(!is_station_level(our_turf.z))
		user.balloon_alert(user, "вне станции!")
		return
	if(!check_for_enough_space(our_turf))
		user.balloon_alert(user, "нет места!")
		return
	if(!do_after(user, creation_time, user, max_interact_count = 1, cancel_on_max = TRUE))
		user.balloon_alert(user, "прервано!")
		return
	if(!check_for_enough_space(our_turf)) // Double check before do_after and after for QOL
		user.balloon_alert(user, "нет места!")
		return
	user.balloon_alert(user, "яма создана")
	Remove(owner) // First we remove, then spawn the hole. Could do it async, but pretty sure it makes it more laggy
	spawn_hole(our_turf, user)

/// Used to check if we have any dense turfs nearby
/datum/action/cooldown/bingle/create_hole/proc/check_for_enough_space(turf/selected_turf)
	for(var/turf/adjacent_turf as anything in RANGE_TURFS(1, selected_turf))
		if(isnull(adjacent_turf) || adjacent_turf.density)
			return FALSE
		if(locate(/obj/structure/bingle_hole) in adjacent_turf)
			return FALSE
		if(locate(/obj/structure/bingle_pit_overlay) in adjacent_turf)
			return FALSE
	return TRUE

/// Spawns the hole and adds the owner to that's hole bingles_by_hole global list
/datum/action/cooldown/bingle/create_hole/proc/spawn_hole(turf/target_turf, mob/living/simple_animal/hostile/bingle/bingle)
	var/obj/structure/bingle_hole/hole = new(target_turf)
	// Add the one who spawned the hole to the assoc list
	var/hole_uid = hole.UID()
	LAZYADDASSOCLIST(GLOB.bingles_by_hole, hole_uid, bingle)
	bingle.spawn_hole_uid = hole_uid// So that they get removed from the list on death
	// Complete the bingle lord objective
	var/datum/antagonist/bingle/lord/lord_datum = bingle.mind.has_antag_datum(/datum/antagonist/bingle/lord)
	if(!lord_datum)
		return
	var/datum/objective/bingle_lord/lord_obj = locate() in lord_datum.objectives
	lord_obj?.completed = TRUE
