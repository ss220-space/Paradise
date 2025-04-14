/**find and set
 * Finds an item near themselves, sets a blackboard key as it. Very useful for ais that need to use machines or something.
 * if you want to do something more complicated than find a single atom, change the search_tactic() proc
 * cool tip: search_tactic() can set lists
 */
/datum/ai_behavior/find_and_set
	action_cooldown = 5 SECONDS
	///search range in how many tiles around the pawn to look for the path
	var/search_range = 7
	//optional, don't use if you're changing search_tactic()
	var/locate_path
	var/bb_key_to_set

/datum/ai_behavior/find_and_set/perform(seconds_per_tick, datum/ai_controller/controller, set_key, locate_path, search_range)
	. = ..()
	var/find_this_thing = search_tactic(controller, locate_path, search_range)
	if(find_this_thing)
		controller.set_blackboard_key(set_key, find_this_thing)
		finish_action(controller, TRUE)
	else
		finish_action(controller, FALSE)

/datum/ai_behavior/find_and_set/proc/search_tactic(datum/ai_controller/controller, locate_paths, search_range = 3)
	return locate(locate_path) in oview(search_range, controller.pawn)

/**
 * Variant of find and set that takes a list of things to find.
 */
/datum/ai_behavior/find_and_set/in_list

/datum/ai_behavior/find_and_set/in_list/search_tactic(datum/ai_controller/controller, locate_paths, search_range)
	var/list/found = typecache_filter_list(oview(search_range, controller.pawn), locate_paths)
	if(length(found))
		return pick(found)

/**
 * Variant of find and set that also requires the item to be edible. checks hands too
 */
/datum/ai_behavior/find_and_set/edible

/datum/ai_behavior/find_and_set/edible/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/living_pawn = controller.pawn
	var/list/food_candidates = list()
	for(var/held_candidate as anything in list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand()))
		if(!held_candidate || !IsEdible(held_candidate))
			continue
		food_candidates += held_candidate

	var/list/local_results = locate(locate_path) in oview(search_range, controller.pawn)
	for(var/local_candidate in local_results)
		if(!IsEdible(local_candidate))
			continue
		food_candidates += local_candidate
	if(food_candidates.len)
		return pick(food_candidates)

/datum/ai_behavior/find_and_set/edible/proc/IsEdible(obj/item/held_candidate)
	if(istype(held_candidate, /obj/item/reagent_containers/food))
		return TRUE
	if(istype(held_candidate, /obj/item/reagent_containers/food/drinks/drinkingglass))
		var/obj/item/reagent_containers/food/drinks/drinkingglass/glass = held_candidate
		if(glass.reagents.total_volume) // The glass has something in it, time to drink the mystery liquid!
			return TRUE
	return FALSE

/**
 * Variant of find and set that only checks in hands, search range should be excluded for this
 */
/datum/ai_behavior/find_and_set/in_hands

/datum/ai_behavior/find_and_set/in_hands/search_tactic(datum/ai_controller/controller, locate_path)
	var/mob/living/living_pawn = controller.pawn
	return locate(locate_path) in list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand())
