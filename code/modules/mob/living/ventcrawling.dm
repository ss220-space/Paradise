/// Checks if the mob is able to enter the vent, and provides feedback if they are unable to.
/mob/living/proc/can_ventcrawl(obj/machinery/atmospherics/ventcrawl_target, provide_feedback = TRUE, entering = FALSE)
	if(QDELETED(ventcrawl_target) || QDELETED(src))
		return FALSE

	// Cache the vent_movement bitflag var from atmos machineries
	var/vent_movement = ventcrawl_target.vent_movement

	if(!Adjacent(ventcrawl_target))
		return FALSE

	if(!is_ventcrawler(src))
		return FALSE

	if(entering)
		var/datum/pipeline/vent_parent = ventcrawl_target.returnPipenet()
		if(!(vent_parent && (length(vent_parent.members))))
			if(provide_feedback)
				to_chat(src, span_warning("Эта вентиляция ни к чему не подключена!"))
			return FALSE

	if(incapacitated())
		if(provide_feedback)
			to_chat(src, span_warning("Вы не можете ползать по вентиляции в текущем состоянии!"))
		return FALSE
	/*
	if(stat)
		if(provide_feedback)
			to_chat(src, span_warning("You must be conscious to do this!"))
		return
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		if(provide_feedback)
			to_chat(src, span_warning("You currently can't move into the vent!"))
		return
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		if(provide_feedback)
			to_chat(src, span_warning("You need to be able to use your hands to ventcrawl!"))
		return
	*/
	if(has_buckled_mobs())
		if(provide_feedback)
			to_chat(src, span_warning("Вы не можете ползать по вентиляции, пока на вас находятся другие существа!"))
		return FALSE

	if(buckled)
		if(provide_feedback)
			to_chat(src, span_warning("Вы не можете ползать по вентиляции, пока пристёгнуты!"))
		return FALSE

	if(ventcrawl_target.welded)
		if(provide_feedback)
			to_chat(src, span_warning("Вы не можете пролезть через заваренную вентиляцию!"))
		return FALSE

	if(!(vent_movement & VENTCRAWL_ENTRANCE_ALLOWED))
		if(provide_feedback)
			to_chat(src, span_warning("Вы не можете пролезть через эту вентиляцию!"))
		return FALSE

	if(HAS_TRAIT(src, TRAIT_VENTCRAWLER_ITEM_BASED))
		var/item_allowed = FALSE
		for(var/obj/item/item as anything in get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
			if(item.used_for_ventcrawling(src, provide_feedback))
				item_allowed = TRUE
				break
		if(!item_allowed)
			return FALSE

	return TRUE


/// Handles the entrance and exit on ventcrawling
/mob/living/proc/handle_ventcrawl(obj/machinery/atmospherics/ventcrawl_target)
	// clientless mobs can do this too! this is just stored in case the client disconnects while we sleep in do_after.
	var/has_client = !isnull(client)

	//Handle the exit here
	if(HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) && is_ventcrawling(src) && (movement_type & VENTCRAWLING))
		if(!can_ventcrawl(ventcrawl_target))
			return
		to_chat(src, span_notice("Вы начинаете вылезать из вентиляции..."))
		if(!do_after(src, 1 SECONDS, target = ventcrawl_target))
			return
		if(has_client && isnull(client))
			return
		if(!can_ventcrawl(ventcrawl_target))
			return
		stop_ventcrawling()
		return VENTCRAWL_OUT_SUCCESS

	//Entrance here
	if(!can_ventcrawl(ventcrawl_target, entering = TRUE))
		return

	var/crawl_overlay = image('icons/effects/vent_indicator.dmi', "arrow", ABOVE_MOB_LAYER, dir = get_dir(src.loc, ventcrawl_target.loc))
	//ventcrawl_target.flick_overlay_static(image('icons/effects/vent_indicator.dmi', "arrow", ABOVE_MOB_LAYER, dir = get_dir(src.loc, ventcrawl_target.loc)), 2 SECONDS)
	ventcrawl_target.add_overlay(crawl_overlay)
	visible_message(
		span_notice("[name] начина[pluralize_ru(gender,"ет", "ют")] залезать в вентиляцию..."),
		span_notice("Вы начинаете залезать в вентиляцию..."),
	)
	if(!do_after(src, 4.5 SECONDS, target = ventcrawl_target))
		ventcrawl_target?.cut_overlay(crawl_overlay)
		return
	ventcrawl_target?.cut_overlay(crawl_overlay)
	if(has_client && isnull(client))
		return
	if(!can_ventcrawl(ventcrawl_target, entering = TRUE))
		return
	ventcrawl_target.flick_overlay_static(image('icons/effects/vent_indicator.dmi', "insert", ABOVE_MOB_LAYER), 1 SECONDS)
	move_into_vent(ventcrawl_target)
	return VENTCRAWL_IN_SUCCESS


/**
 * Moves living mob directly into the vent as a ventcrawler
 *
 * Arguments:
 * * ventcrawl_target - The vent into which we are moving the mob
 */
/mob/living/proc/move_into_vent(obj/machinery/atmospherics/ventcrawl_target, message = TRUE)
	if(message)
		visible_message(
		span_notice("[name] залез[genderize_ru(gender, "", "ла", "ло", "ли")] в вентиляцию!"),
		span_notice("Вы залезли в вентиляцию."),
	)
	//forceMove(ventcrawl_target)
	loc = ventcrawl_target
	ADD_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
	update_pipe_vision()


/**
 * Moves living mob to the turf contents and cleanse ventcrawling stuff
 *
 * Arguments:
 * * message - if TRUE shows visible message to everyone
 */
/mob/living/proc/stop_ventcrawling(message = TRUE)
	if(!is_ventcrawling(src))
		return FALSE
	forceMove(get_turf(src))
	REMOVE_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
	update_pipe_vision()
	if(message)
		visible_message(
			span_notice("[name] вылез[genderize_ru(gender, "", "ла", "ло", "ли")] из вентиляции!"),
			span_notice("Вы вылезли из вентиляции."),
		)
	return TRUE


/**
 * Everything related to pipe vision on ventcrawling is handled by update_pipe_vision().
 * Called on exit, entrance, and pipenet differences (e.g. moving to a new pipenet).
 * One important thing to note however is that the movement of the client's eye is handled by the relaymove() proc in /obj/machinery/atmospherics.
 * We move first and then call update. Dont flip this around
 */
/mob/living/proc/update_pipe_vision()
	if(isnull(client))
		return

	if(LAZYLEN(pipes_shown))
		for(var/current_image in pipes_shown)
			client.images -= current_image
		LAZYNULL(pipes_shown)

	if(!HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) || !is_ventcrawling(src) || !(movement_type & VENTCRAWLING))
		return

	var/list/total_members = list()
	var/obj/machinery/atmospherics/current_location = loc
	for(var/datum/pipeline/location_pipeline as anything in current_location.return_pipenets())
		total_members |= location_pipeline.members
		total_members |= location_pipeline.other_atmosmch

	if(!length(total_members))
		return

	for(var/obj/machinery/atmospherics/pipenet_part as anything in total_members)
		if(!(pipenet_part.vent_movement & VENTCRAWL_CAN_SEE))
			continue

		if(!pipenet_part.pipe_vision_img)
			pipenet_part.update_pipe_image()

		client.images += pipenet_part.pipe_vision_img
		LAZYADD(pipes_shown, pipenet_part.pipe_vision_img)




