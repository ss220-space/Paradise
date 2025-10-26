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

	if(incapacitated() || HAS_TRAIT(src, TRAIT_IMMOBILIZED) || HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		if(provide_feedback)
			to_chat(src, span_warning("Вы не можете ползать по вентиляции в текущем состоянии!"))
		return FALSE

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
		for(var/obj/item/item as anything in get_equipped_items(INCLUDE_POCKETS))
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
		if(HAS_TRAIT_FROM(src, TRAIT_VENTCRAWLING_EXIT, UNIQUE_TRAIT_SOURCE(ventcrawl_target)))
			return
		if(!can_ventcrawl(ventcrawl_target))
			return FALSE
		to_chat(src, span_notice("Вы начинаете вылезать из вентиляции..."))
		ADD_TRAIT(src, TRAIT_VENTCRAWLING_EXIT, UNIQUE_TRAIT_SOURCE(ventcrawl_target))
		if(!do_after(src, 1 SECONDS, target = ventcrawl_target))
			REMOVE_TRAIT(src, TRAIT_VENTCRAWLING_EXIT, UNIQUE_TRAIT_SOURCE(ventcrawl_target))
			return FALSE
		REMOVE_TRAIT(src, TRAIT_VENTCRAWLING_EXIT, UNIQUE_TRAIT_SOURCE(ventcrawl_target))
		if(has_client && isnull(client))
			return FALSE
		if(!can_ventcrawl(ventcrawl_target))
			return FALSE
		return stop_ventcrawling()

	//Entrance here
	if(!can_ventcrawl(ventcrawl_target, entering = TRUE))
		return FALSE

	var/crawl_overlay = image('icons/effects/vent_indicator.dmi', "arrow", ABOVE_MOB_LAYER, dir = get_dir(src.loc, ventcrawl_target.loc))
	//ventcrawl_target.flick_overlay_static(image('icons/effects/vent_indicator.dmi', "arrow", ABOVE_MOB_LAYER, dir = get_dir(src.loc, ventcrawl_target.loc)), 2 SECONDS)
	ventcrawl_target.add_overlay(crawl_overlay)
	visible_message(
		span_notice("[name] начина[PLUR_ET_UT(src)] залезать в вентиляцию..."),
		span_notice("Вы начинаете залезать в вентиляцию..."),
	)
	if(!do_after(src, 4.5 SECONDS, target = ventcrawl_target))
		ventcrawl_target?.cut_overlay(crawl_overlay)
		return FALSE
	ventcrawl_target?.cut_overlay(crawl_overlay)
	if(has_client && isnull(client))
		return FALSE
	if(!can_ventcrawl(ventcrawl_target, entering = TRUE))
		return FALSE
	ventcrawl_target.flick_overlay_static(image('icons/effects/vent_indicator.dmi', "insert", ABOVE_MOB_LAYER), 1 SECONDS)
	return move_into_vent(ventcrawl_target)


/**
 * Moves living mob directly into the vent as a ventcrawler
 *
 * Arguments:
 * * ventcrawl_target - The vent into which we are moving the mob
 * * message - if TRUE shows visible message to everyone
 *
 * Returns `TRUE` on success.
 */
/mob/living/proc/move_into_vent(obj/machinery/atmospherics/ventcrawl_target, message = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(message)
		visible_message(
		span_notice("[name] залез[GEND_LA_LO_LI(src)] в вентиляцию!"),
		span_notice("Вы залезли в вентиляцию."),
	)
	abstract_move(ventcrawl_target)
	LAZYINITLIST(pipes_shown)
	ADD_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
	update_pipe_vision()
	return TRUE


/**
 * Moves living mob to the turf contents and cleanse ventcrawling stuff
 *
 * Arguments:
 * * message - if TRUE shows visible message to everyone
 *
 * Returns `TRUE` on success.
 */
/mob/living/proc/stop_ventcrawling(message = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(!is_ventcrawling(src))
		return FALSE
	var/turf/new_turf = get_turf(src)
	forceMove(new_turf)
	REMOVE_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
	update_pipe_vision()
	LAZYNULL(pipes_shown)
	SET_PLANE(src, PLANE_TO_TRUE(src.plane), new_turf)
	if(message)
		visible_message(
			span_notice("[name] вылез[GEND_LA_LO_LI(src)] из вентиляции!"),
			span_notice("Вы вылезли из вентиляции."),
		)
	return TRUE


/**
 * Everything related to pipe vision on ventcrawling is handled by update_pipe_vision().
 * Called on exit, entrance, and pipenet differences (e.g. moving to a new pipenet).
 * One important thing to note however is that the movement of the client's eye is handled by the relaymove() proc in /obj/machinery/atmospherics.
 * We move first and then call update. Dont flip this around
 */
/mob/living/proc/update_pipe_vision(full_refresh = FALSE)
	if(!isnull(ai_controller) && isnull(client)) // we don't care about pipe vision if we have an AI controller with no client (typically means we are clientless).
		return

	LAZYINITLIST(pipes_shown)

	// Take away all the pipe images if we're not doing anything with em
	if(isnull(client) || !HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) || !istype(loc, /obj/machinery/atmospherics) || !(movement_type & VENTCRAWLING))
		for(var/current_image in pipes_shown)
			canon_client.images -= current_image
		pipes_shown.Cut()
		pipetracker = null
		if(!hud_used)
			return
		for(var/atom/movable/screen/plane_master/lighting as anything in hud_used.get_true_plane_masters(LIGHTING_PLANE))
			lighting.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, "#4d4d4d")
		for(var/atom/movable/screen/plane_master/pipecrawl as anything in hud_used.get_true_plane_masters(PIPECRAWL_IMAGES_PLANE))
			pipecrawl.hide_plane(src)
		return

	// We're gonna color the lighting plane to make it darker while ventcrawling, so things look nicer
	// This is a bit hacky but it makes the background darker, which has a nice effect
	for(var/atom/movable/screen/plane_master/lighting as anything in hud_used.get_true_plane_masters(LIGHTING_PLANE))
		lighting.add_atom_colour("#4d4d4d", TEMPORARY_COLOUR_PRIORITY)

	for(var/atom/movable/screen/plane_master/pipecrawl as anything in hud_used.get_true_plane_masters(PIPECRAWL_IMAGES_PLANE))
		pipecrawl.unhide_plane(src)

	var/obj/machinery/atmospherics/current_location = loc
	var/list/our_pipenets = current_location.return_pipenets()

	// We on occasion want to do a full rebuild. this lets us do that
	if(full_refresh)
		for(var/current_image in pipes_shown)
			client.images -= current_image
		pipes_shown.Cut()
		pipetracker = null

	if(!pipetracker)
		pipetracker = new()

	var/turf/our_turf = get_turf(src)
	// We're getting the smallest "range" arg we can pass to the spatial grid and still get all the stuff we need
	// We preload a bit more then we need so movement looks ok
	var/list/view_range = getviewsize(client.view)
	pipetracker.set_bounds(view_range[1] + 1, view_range[2] + 1)

	var/list/entered_exited_pipes = pipetracker.recalculate_type_members(our_turf, SPATIAL_GRID_CONTENTS_TYPE_ATMOS)
	var/list/pipes_gained = entered_exited_pipes[1]
	var/list/pipes_lost = entered_exited_pipes[2]

	for(var/obj/machinery/atmospherics/pipenet_part as anything in pipes_lost)
		if(!pipenet_part.pipe_vision_img)
			continue
		client.images -= pipenet_part.pipe_vision_img
		pipes_shown -= pipenet_part.pipe_vision_img

	for(var/obj/machinery/atmospherics/pipenet_part as anything in pipes_gained)
		// If the machinery is not part of our net or is not meant to be seen, continue
		var/list/thier_pipenets = pipenet_part.return_pipenets()
		if(!length(thier_pipenets & our_pipenets))
			continue
		if(!(pipenet_part.vent_movement & VENTCRAWL_CAN_SEE))
			continue

		if(!pipenet_part.pipe_vision_img)
			var/turf/their_turf = get_turf(pipenet_part)
			pipenet_part.pipe_vision_img = image(pipenet_part, pipenet_part.loc, dir = pipenet_part.dir)
			SET_PLANE(pipenet_part.pipe_vision_img, PIPECRAWL_IMAGES_PLANE, their_turf)
		client.images += pipenet_part.pipe_vision_img
		pipes_shown += pipenet_part.pipe_vision_img

