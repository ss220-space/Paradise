// Addition goals shuttle

////////////////////////////////////////
// MARK:	Machinery
////////////////////////////////////////

/area/shuttle/addition_goals
	icon_state = "shuttle3"
	name = "Addition Goals Shuttle"

/obj/machinery/computer/shuttle/addition_goals
	name = "Addition Goal Shuttle Console"
	desc = "Используется для вызова и отправки шаттла дополнительных целей смены."
	shuttleId = "addition_goal"
	possible_destinations = "graveyard_church;addition_goal_dock"




////////////////////////////////////////
// MARK:	System logic
////////////////////////////////////////

/// Try send shuttle to station (call shuttle)
/datum/controller/subsystem/addition_goals/proc/send_shuttle_to_station(mob/user)
	SSshuttle.moveShuttle(shuttle.id, AGS_SHUTTLE_STATION_DOCK, FALSE, user)

/// Try send shuttle to centrom (return shuttle)
/datum/controller/subsystem/addition_goals/proc/send_shuttle_to_centcom(mob/user)
	SSshuttle.moveShuttle(shuttle.id, AGS_SHUTTLE_CENTCOM_DOCK, FALSE, user)

/// Get text where shuttle docked
/datum/controller/subsystem/addition_goals/proc/get_shuttle_location()
	if(!shuttle)
		return "Неизвестно"
	var/dock_id = shuttle.getDockedId()
	switch(dock_id)
		if(AGS_SHUTTLE_CENTCOM_DOCK)
			return "На ЦК"
		if(AGS_SHUTTLE_STATION_DOCK)
			return "На станции"
		else
			return shuttle.getStatusText()

/// Check shuttle ready to call (docked in centcom sector)
/datum/controller/subsystem/addition_goals/proc/is_shuttle_in_centcom()
	if(!shuttle)
		return FALSE
	var/dock_id = shuttle.getDockedId()
	return dock_id == AGS_SHUTTLE_CENTCOM_DOCK

/// Check shuttle ready to return (docked in station sector)
/datum/controller/subsystem/addition_goals/proc/is_shuttle_in_station()
	if(!shuttle)
		return FALSE
	var/dock_id = shuttle.getDockedId()
	return dock_id == AGS_SHUTTLE_STATION_DOCK

/// Collect shuttle floor turfs
/datum/controller/subsystem/addition_goals/proc/get_shuttle_turfs()
	. = list()
	if(!shuttle)
		return
	var/turf/shuttle_anchor = shuttle.loc
	//TODO change it
	for(var/x = 1; x <= 5; x++)
		for(var/y=-5; y <= 1; y++)
			var/turf/shuttle_turf = locate(shuttle_anchor.x + x, shuttle_anchor.y + y, shuttle_anchor.z)
			. += shuttle_turf

/// Clear all objects in shuttle
/datum/controller/subsystem/addition_goals/proc/clear_shuttle_turfs()
	if(!shuttle)
		return
	var/list/turfs = get_shuttle_turfs()
	for(var/turf/turf in turfs)
		//open all containers before delete
		for(var/atom/movable/content in turf.contents)
			if(istype(content, /obj/structure/closet))
				var/obj/structure/closet/closet = content
				closet.open()
		//delete all
		for(var/atom/movable/content in turf.contents)
			if(istype(content, /obj/machinery/computer/shuttle/addition_goals)) //this is shuttle computer
				continue
			if(istype(content, /obj/machinery/light)) //this is shuttle lamps
				continue
			if(istype(content, /mob/living/))
				var/mob/living/living = content
				if(living.mind)
					var/list/safe_turfs = get_safe_random_station_turf()
					var/turf/teleport_target = pick(safe_turfs)
					living.forceMove(teleport_target)
					living.AdjustWeakened(5 SECONDS)
					continue
			//TODO implement high-risk items check here
			qdel(content)



/// Only for test
/datum/controller/subsystem/addition_goals/proc/toggle_shuttle(mob/user)
	. = FALSE
	if(!shuttle)
		return
	var/dock_id = shuttle.getDockedId()
	switch(dock_id)
		if(AGS_SHUTTLE_CENTCOM_DOCK)
			send_shuttle_to_station(user)
			return TRUE
		if(AGS_SHUTTLE_STATION_DOCK)
			send_shuttle_to_centcom(user)
			return TRUE
