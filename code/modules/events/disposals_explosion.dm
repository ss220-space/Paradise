/*
	Disposals explosion
	Marks a disposals pipe for a violent trash explosion if not repaired in time
*/

GLOBAL_LIST_EMPTY(disposals_pipe_areas)

/datum/event/disposals_explosion
	name = "Взрыв мусоропровода"
	announceWhen = 20
	endWhen = 80 // Should be plenty of time to find it
	var/obj/structure/disposalpipe/segment/bursting_pipe = null
	var/area/picked_disposals_pipe_area = null

// Predicates for the pick_area and pick_area_turf proc
/datum/event/disposals_explosion/proc/area_has_disposals_pipe(area/picked_area)
	for(var/turf/picked_turf in picked_area)
		if(has_disposals_pipe(picked_turf))
			return TRUE
	return FALSE

/datum/event/disposals_explosion/proc/has_disposals_pipe(turf/picked_turf)
	for(var/obj/structure/disposalpipe/segment/picked_pipe in picked_turf)
		return TRUE
	return FALSE

/datum/event/disposals_explosion/proc/pick_disposal_pipe_in_area()
	if(!length(GLOB.disposals_pipe_areas))
		return

	picked_disposals_pipe_area = pick(GLOB.disposals_pipe_areas)

	var/list/disposal_pipe_in_area = list()

	for(var/turf/picked_turf in picked_disposals_pipe_area)
		for(var/obj/structure/disposalpipe/segment/disposal_pipe in picked_turf)
			disposal_pipe_in_area += disposal_pipe

	if(!length(disposal_pipe_in_area))
		return

	bursting_pipe = pick(disposal_pipe_in_area)

// Event listener for the marked pipe's destruction
/datum/event/disposals_explosion/proc/pipe_destroyed()
	SIGNAL_HANDLER

	UnregisterSignal(bursting_pipe, COMSIG_OBJ_DECONSTRUCT)

	bursting_pipe = null
	kill()

/datum/event/disposals_explosion/proc/cache_disposals_pipe_area()
	if(length(GLOB.disposals_pipe_areas))
		return

	for(var/area/station_area in SSmapping.existing_station_areas)
		if(!area_has_disposals_pipe(station_area))
			continue
		GLOB.disposals_pipe_areas += station_area

/datum/event/disposals_explosion/setup()
	cache_disposals_pipe_area()

	if(!length(GLOB.disposals_pipe_areas))
		log_debug("[name] event failed to start. No disposals pipes on found.")
		kill()
		return

	pick_disposal_pipe_in_area()

	if(!bursting_pipe)
		log_debug("[name] event failed to start. No disposals pipes on found.")
		kill()
		return

	RegisterSignal(bursting_pipe, COMSIG_OBJ_DECONSTRUCT, PROC_REF(pipe_destroyed))

	bursting_pipe.explodes = TRUE

/datum/event/disposals_explosion/announce()
	GLOB.minor_announcement.announce(
		message = "Зафиксировано повышенное давление в сегменте трубопровода в зоне [picked_disposals_pipe_area]. Инженерному отделу рекомендуется устранить неисправность как можно скорее, пока это не привело к разрыву данного сегмента мусоропровода.",
		new_title = ANNOUNCE_TITLE_DISPOSAL_EXPLOSION_RU,
	)

/datum/event/disposals_explosion/tick()
	if(QDELETED(bursting_pipe))
		kill()
		return

	// Make some noise as a clue
	if(prob(40) && bursting_pipe.explodes)
		playsound(bursting_pipe, 'sound/machines/hiss.ogg', 40, 0, 0)

/datum/event/disposals_explosion/end()
	if(QDELETED(bursting_pipe))
		return

	UnregisterSignal(bursting_pipe, COMSIG_OBJ_DECONSTRUCT)

	if(bursting_pipe.explodes)
		var/obj/structure/disposalholder/trash_holder = new()

		for(var/i in 0 to rand(5, 8))
			var/chosen_trash = pick(valid_subtypesof(/obj/item/trash))
			var/obj/item/trash/random_trash = new chosen_trash()
			random_trash.forceMove(trash_holder)

		trash_holder.forceMove(bursting_pipe)

		playsound(bursting_pipe, SFX_EXPLOSION, 40, 0, 0, 5)

		bursting_pipe.deconstruct(FALSE)
