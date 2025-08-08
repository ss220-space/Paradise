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
	if(is_funeral_shuttle_on_station())
		send_funeral_shuttle_away(user)
		addtimer(CALLBACK(src, PROC_REF(send_shuttle_to_station_now), user), 15 SECONDS)
	else
		send_shuttle_to_station_now(user)
	set_funeral_shuttle_locked(TRUE)

/// Send shuttle to station now without checks (use send_shuttle_to_station for checks)
/datum/controller/subsystem/addition_goals/proc/send_shuttle_to_station_now(mob/user)
	SSshuttle.moveShuttle(shuttle.id, AGS_SHUTTLE_STATION_DOCK, timed = TRUE, user = user)

/// Try send shuttle to centrom (return shuttle)
/datum/controller/subsystem/addition_goals/proc/send_shuttle_to_centcom(mob/user)
	SSshuttle.moveShuttle(shuttle.id, AGS_SHUTTLE_CENTCOM_DOCK, timed = FALSE, user = user)
	set_funeral_shuttle_locked(FALSE)

/// Try send shuttle to centrom (return shuttle)
/datum/controller/subsystem/addition_goals/proc/send_funeral_shuttle_away(mob/user)
	SSshuttle.moveShuttle(funeral_shuttle.id, AGS_FUNERAL_SHUTTLE_AWAY_DOCK, timed = TRUE, user = user)

/datum/controller/subsystem/addition_goals/proc/set_funeral_shuttle_locked(locked)
	funeral_shuttle.locked_move = locked


/// Get text where shuttle docked
/datum/controller/subsystem/addition_goals/proc/get_shuttle_location()
	if(!shuttle)
		return "Неизвестно"
	var/dock_id = shuttle.getDockedId()
	switch(dock_id)
		if(AGS_SHUTTLE_CENTCOM_DOCK)
			return "Вне станции"
		if(AGS_SHUTTLE_STATION_DOCK)
			return "На станции"
		else
			return shuttle.getStatusText()

/// Check funeral shuttle docked on station
/datum/controller/subsystem/addition_goals/proc/is_funeral_shuttle_on_station()
	. = FALSE
	if(!funeral_shuttle)
		return
	var/dock_id = funeral_shuttle.getDockedId()
	if(dock_id == AGS_SHUTTLE_STATION_DOCK)
		return TRUE

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
	var/turf/shuttle_anchor = shuttle.loc
	var/list/turfs = get_shuttle_turfs()
	turfs += locate(shuttle_anchor.x, shuttle_anchor.y, shuttle_anchor.z) //left airlock
	turfs += locate(shuttle_anchor.x + 6, shuttle_anchor.y, shuttle_anchor.z) //right airlock
	for(var/turf/turf in turfs)
		//open all containers before delete
		for(var/atom/movable/content in turf.contents)
			if(istype(content, /obj/structure/closet))
				var/obj/structure/closet/closet = content
				closet.open()
		//delete all
		for(var/atom/movable/content in turf.contents)
			if(istype(content, /obj/machinery/door/airlock)) //this is airlock
				continue
			if(istype(content, /obj/machinery/light)) //this is shuttle lamps
				continue
			if(is_highrisk_item(content))
				teleportate_item_to_station(content)
				continue
			if(istype(content, /mob/living/))
				var/mob/living/living = content
				if(living.mind) // this is player
					teleportate_player_to_station(living)
					continue
			//TODO implement high-risk items check here
			qdel(content)

/datum/controller/subsystem/addition_goals/proc/is_highrisk_item(item)
	for(var/highrisk_type as anything in GLOB.ungibbable_items_types)
		if(istype(item, highrisk_type))
			return TRUE
	return FALSE

/datum/controller/subsystem/addition_goals/proc/teleportate_item_to_station(atom/movable/content)
	for(var/obj/machinery/computer/addition_goals/console as anything in console_list)
		if(console.loc.z != 3)
			continue //not a station z-level
		teleportate_item_to_location(content, console.loc)
		return
	var/list/safe_turfs = get_safe_random_station_turf()
	var/turf/teleport_target = pick(safe_turfs)
	teleportate_item_to_location(content, teleport_target)

/datum/controller/subsystem/addition_goals/proc/teleportate_item_to_location(atom/movable/content, turf/teleport_target)
	content.forceMove(teleport_target)
	var/datum/money_account/account = GLOB.station_account
	account.credit(round(-1000), "Транспортировка важного предмета на станцию", "Дополнительная цель", account.owner_name)



/datum/controller/subsystem/addition_goals/proc/teleportate_player_to_station(mob/living/user)
	var/list/safe_turfs = get_safe_random_station_turf()
	var/turf/teleport_target = pick(safe_turfs)
	user.forceMove(teleport_target)
	user.AdjustWeakened(5 SECONDS)
	var/credits = 1000
	to_chat(user, span_boldwarning("Вы были отправлены обратно на станцию!"))
	to_chat(user, span_warning("С вашего счета будет списано [credits] кредитов за услуги телепортации."))
	var/datum/money_account/account = get_card_account(user)
	if(!account)
		return
	account.credit(round(-credits), "Транспортные расходы", "Дополнительная цель", account.owner_name)




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
