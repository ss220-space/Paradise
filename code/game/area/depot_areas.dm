
/area/syndicate_depot
	name = "Suspicious Supply Depot"
	icon_state = "dark"
	tele_proof = 1
	area_flags = NONE
	holomap_should_draw = FALSE

/area/syndicate_depot/core
	icon_state = "red"
	has_gravity = STANDARD_GRAVITY

	var/local_alarm = FALSE // Level 1: Local alarm tripped, bot spawned, red fire overlay activated
	var/called_backup = FALSE // Level 2: Remote alarm tripped. Bot may path through depot. Backup spawned.
	var/used_self_destruct = FALSE // Level 3: Self destruct activated. Depot will be destroyed shortly.

	var/run_started = FALSE
	var/run_finished = FALSE

	// Soft UID-based refs
	var/list/guard_list = list()
	var/list/hostile_list = list()
	var/list/dead_list = list()
	var/list/peaceful_list = list()
	var/list/shield_list = list()

	var/list/alert_log = list() // no refs, just a simple list of text strings

	var/used_lockdown = FALSE
	var/destroyed = FALSE
	var/something_looted = FALSE
	var/on_peaceful = FALSE
	var/peace_betrayed = FALSE
	var/detected_mech = FALSE
	var/detected_pod = FALSE
	var/detected_double_agent = FALSE
	var/mine_trigger_count = 0
	var/perimeter_shield_status = FALSE
	var/obj/machinery/computer/syndicate_depot/syndiecomms/comms_computer = null
	var/obj/structure/fusionreactor/reactor

/area/syndicate_depot/core/proc/update_state()
	if(destroyed)
		invisibility = INVISIBILITY_MAXIMUM
	else if(on_peaceful)
		invisibility = INVISIBILITY_LIGHTING
	else if(used_self_destruct)
		invisibility = INVISIBILITY_LIGHTING
	else if(called_backup)
		invisibility = INVISIBILITY_LIGHTING
	else if(local_alarm)
		invisibility = INVISIBILITY_LIGHTING
	else
		invisibility = INVISIBILITY_MAXIMUM
	update_icon(UPDATE_ICON_STATE)

/area/syndicate_depot/core/update_icon_state()
	if(invisibility == INVISIBILITY_MAXIMUM)
		icon_state = null
		return
	else if(on_peaceful)
		icon_state = "green"
	else if(used_self_destruct)
		icon_state = "radiation"
	else if(called_backup)
		icon_state = "red"
	else if(local_alarm)
		icon_state = "bluenew"

/area/syndicate_depot/core/proc/reset_alert()

	if(used_self_destruct)
		for(var/obj/effect/overload/overload in src)
			new /obj/structure/fusionreactor(overload.loc)
			qdel(overload)

	if(on_peaceful)
		peaceful_mode(FALSE, TRUE)

	local_alarm = FALSE
	called_backup = FALSE
	unlock_computers()
	used_self_destruct = FALSE

	run_started = FALSE
	run_finished = FALSE

	despawn_guards()
	hostile_list = list()
	dead_list = list()
	peaceful_list = list()

	something_looted = FALSE
	detected_mech = FALSE
	detected_pod = FALSE
	detected_double_agent = FALSE
	mine_trigger_count = 0
	update_state()

	if(!istype(reactor))
		for(var/obj/structure/fusionreactor/fusionreactor in src)
			reactor = fusionreactor
			fusionreactor.has_overloaded = FALSE

	for(var/obj/machinery/door/airlock/airlock in machinery_cache)
		if(airlock.density && airlock.locked)
			spawn(0)
				airlock.unlock()

	alert_log += "Alert level reset."

/area/syndicate_depot/core/proc/increase_alert(reason, mob/triggered)
	if(on_peaceful)
		peaceful_mode(FALSE, FALSE)
		peace_betrayed = TRUE
		add_game_logs("Depot code: DELTA: Depot has been infiltrated by double-agents." + list_show(hostile_list, TRUE), triggered)
		activate_self_destruct("Depot has been infiltrated by double-agents.", TRUE, null)
		return
	if(!local_alarm)
		add_game_logs("Depot code: BLUE: [reason]" + list_show(hostile_list, TRUE), triggered)
		local_alarm(reason, FALSE)
		return
	if(!called_backup)
		add_game_logs("Depot code: RED: [reason]" + list_show(hostile_list, TRUE), triggered)
		call_backup(reason, FALSE)
		return
	if(!used_self_destruct)
		add_game_logs("Depot code: DELTA: [reason]" + list_show(hostile_list, TRUE), triggered)
		activate_self_destruct(reason, FALSE, null)
	update_icon(UPDATE_ICON_STATE)

/area/syndicate_depot/core/proc/locker_looted()
	if(!something_looted)
		something_looted = TRUE
		if(on_peaceful)
			increase_alert("Thieves!")
		if(perimeter_shield_status)
			increase_alert("Perimeter shield breach!")

/area/syndicate_depot/core/proc/armory_locker_looted()
	if(!run_finished && !used_self_destruct)
		if(length(shield_list))
			activate_self_destruct("Armory compromised despite armory shield being online.", FALSE)
			return
		declare_finished()

/area/syndicate_depot/core/proc/turret_died(mob/triggered)
	something_looted = TRUE
	if(on_peaceful)
		increase_alert("Vandals!", triggered)

/area/syndicate_depot/core/proc/mine_triggered(mob/living/M)
	if(mine_trigger_count)
		return TRUE
	mine_trigger_count++
	increase_alert("Intruder detected by sentry mine: [M]", M)

/area/syndicate_depot/core/proc/saw_mech(obj/mecha/E)
	if(detected_mech)
		return
	detected_mech = TRUE
	increase_alert("Hostile mecha detected: [E]", E.occupant)

/area/syndicate_depot/core/proc/saw_pod(obj/spacepod/P)
	if(detected_pod)
		return
	detected_pod = TRUE
	if(!called_backup)
		increase_alert("Hostile spacepod detected: [P]", P.pilot)

/area/syndicate_depot/core/proc/saw_double_agent(mob/living/M)
	if(detected_double_agent)
		return
	detected_double_agent = TRUE
	increase_alert("Hostile double-agent detected: [M]", M)

/area/syndicate_depot/core/proc/peaceful_mode(newvalue, bycomputer)
	if(newvalue)
		add_game_logs("Depot visit: started")
		alert_log += "Code GREEN: visitor mode started."
		ghostlog("The syndicate depot has visitors")
		for(var/mob/living/simple_animal/bot/medbot/syndicate/syndicate in src)
			qdel(syndicate)
		for(var/mob/living/simple_animal/hostile/syndicate/syndicate in src)
			syndicate.a_intent = INTENT_HELP
		for(var/obj/structure/closet/secure_closet/syndicate/depot/depot in src)
			if(depot.opened)
				depot.close()
			if(!depot.locked)
				depot.locked = !depot.locked
			depot.req_access = list(ACCESS_SYNDICATE_LEADER)
			depot.update_icon()
	else
		add_game_logs("Depot visit: ended")
		alert_log += "Visitor mode ended."
		for(var/mob/living/simple_animal/hostile/syndicate/syndicate in src)
			syndicate.a_intent = INTENT_HARM
		for(var/obj/machinery/door/airlock/airlock in machinery_cache)
			airlock.req_access = list(ACCESS_SYNDICATE_LEADER)
		for(var/obj/structure/closet/secure_closet/syndicate/depot/depot in src)
			if(depot.locked)
				depot.locked = !depot.locked
			depot.req_access = list()
			depot.update_icon()
	on_peaceful = newvalue
	if(newvalue)
		announce_here("Depot Visitor","A Syndicate agent is visiting the depot.")
	else
		if(bycomputer)
			message_admins("Syndicate Depot visitor mode deactivated. Visitors:")
			announce_here("Depot Alert","Visit ended. All visting agents signed out.")
		else
			message_admins("Syndicate Depot visitor mode auto-deactivated because visitors robbed depot! Visitors:")
			announce_here("Depot Alert","A visiting agent has betrayed the Syndicate. Shoot all visitors on sight!")
		for(var/mob/mob in list_getmobs(peaceful_list))
			if("syndicate" in mob.faction)
				mob.faction -= "syndicate"
				message_admins("- SYNDI DEPOT VISITOR: [ADMIN_FULLMONTY(mob)]")
				list_add(mob, hostile_list)
		peaceful_list = list()
	update_icon(UPDATE_ICON_STATE)

/area/syndicate_depot/core/proc/local_alarm(reason, silent)
	if(local_alarm)
		return
	ghostlog("The syndicate depot has declared code blue.")
	alert_log += "Code BLUE: [reason]"
	local_alarm = TRUE
	if(!silent)
		announce_here("Depot Code BLUE", reason)
		var/list/possible_bot_spawns = list()
		for(var/obj/effect/landmark/landmark in GLOB.landmarks_list)
			if(landmark.name == "syndi_depot_bot")
				possible_bot_spawns |= landmark
		if(length(possible_bot_spawns))
			var/obj/effect/landmark/landmark = pick(possible_bot_spawns)
			new /obj/effect/portal(get_turf(landmark))
			var/mob/living/simple_animal/bot/ed209/syndicate/syndicate = new /mob/living/simple_animal/bot/ed209/syndicate(get_turf(landmark))
			list_add(syndicate, guard_list)
			syndicate.depotarea = src
	update_icon(UPDATE_ICON_STATE)

/area/syndicate_depot/core/proc/call_backup(reason, silent)
	if(called_backup || used_self_destruct)
		return
	ghostlog("The syndicate depot has declared code red.")
	alert_log += "Code RED: [reason]"
	called_backup = TRUE
	lockout_computers()
	for(var/obj/machinery/door/poddoor/poddoor in GLOB.airlocks)
		if(poddoor.density && poddoor.id_tag == "syndi_depot_lvl2" && !poddoor.operating)
			spawn(0)
				poddoor.open()
	if(!silent)
		announce_here("Depot Code RED", reason)

	var/comms_online = FALSE
	if(istype(comms_computer))
		if(!(comms_computer.stat & (NOPOWER|BROKEN)))
			comms_online = TRUE
	if(comms_online)
		spawn(0)
			for(var/obj/effect/landmark/landmark in GLOB.landmarks_list)
				if(prob(50))
					if(landmark.name == "syndi_depot_backup")
						var/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/space/space = new /mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/space(get_turf(landmark))
						space.name = "Syndicate Backup " + "([rand(1, 1000)])"
						space.depotarea = src
						list_add(space, guard_list)
	else if(!silent)
		announce_here("Depot Communications Offline", "Comms computer is damaged, destroyed or depowered. Unable to call in backup from Syndicate HQ.")
	update_icon(UPDATE_ICON_STATE)

/area/syndicate_depot/core/proc/activate_self_destruct(reason, containment_failure, mob/user)
	if(used_self_destruct)
		return
	ghostlog("The syndicate depot is about to self-destruct.")
	alert_log += "Code DELTA: [reason]"
	used_self_destruct = TRUE
	local_alarm = TRUE
	called_backup = TRUE
	activate_lockdown(TRUE)
	lockout_computers()
	update_icon(UPDATE_ICON_STATE)
	despawn_guards()
	if(containment_failure)
		announce_here("Depot Code DELTA", reason)
	else
		announce_here("Depot Code DELTA","[reason] Depot declared lost to hostile forces. Priming self-destruct!")

	if(user)
		var/turf/turf = get_turf(user)
		var/area/area = get_area(turf)
		var/log_msg = "[key_name(user)] has triggered the depot self destruct at [area.name] ([turf.x],[turf.y],[turf.z])"
		message_admins(log_msg)
		add_game_logs(log_msg, user)
		playsound(user, 'sound/machines/alarm.ogg', 100, FALSE, 0)
	else
		add_game_logs("Depot self destruct activated.")
	if(reactor)
		if(!reactor.has_overloaded)
			reactor.overload(containment_failure)
	else
		log_debug("Depot: [src] called activate_self_destruct with no reactor.")
		message_admins(span_adminnotice("Syndicate Depot lacks reactor to initiate self-destruct. Must be destroyed manually via admin bomb(25, 35, 45, 55)."))
	update_icon(UPDATE_ICON_STATE)

/area/syndicate_depot/core/proc/activate_lockdown()
	if(used_lockdown)
		return
	used_lockdown = TRUE
	for(var/obj/machinery/door/airlock/airlock in machinery_cache)
		spawn(0)
			airlock.close()
			if(airlock.density && !airlock.locked)
				airlock.lock()

/area/syndicate_depot/core/proc/lockout_computers()
	for(var/obj/machinery/computer/syndicate_depot/syndicate_depot in machinery_cache)
		syndicate_depot.activate_security_lockout()

/area/syndicate_depot/core/proc/unlock_computers()
	for(var/obj/machinery/computer/syndicate_depot/syndicate_depot in machinery_cache)
		syndicate_depot.security_lockout = FALSE

/area/syndicate_depot/core/proc/set_emergency_access(openaccess)
	for(var/obj/machinery/door/airlock/airlock in machinery_cache)
		if(istype(airlock, /obj/machinery/door/airlock/hatch/syndicate/vault))
			continue
		airlock.emergency = !!openaccess
		airlock.update_icon()

/area/syndicate_depot/core/proc/toggle_falsewalls()
	for(var/obj/structure/falsewall/plastitanium/wall in src)
		INVOKE_ASYNC(wall, TYPE_PROC_REF(/obj/structure/falsewall, toggle))

/area/syndicate_depot/core/proc/toggle_teleport_beacon()
	for(var/obj/machinery/bluespace_beacon/syndicate/syndicate in machinery_cache)
		return syndicate.toggle()

/area/syndicate_depot/core/proc/announce_here(a_header = "Depot Defense Alert", a_text = "")
	var/msg_text = "<font size=4 color='red'>[a_header]</font><br><font color='red'>[a_text]</font>"
	var/list/receivers = list()
	for(var/mob/mob in GLOB.mob_list)
		if(!mob.ckey)
			continue
		var/turf/turf = get_turf(mob)
		if(turf?.loc && turf.loc == src)
			receivers |= mob
	for(var/mob/mob in receivers)
		to_chat(mob, msg_text)
		SEND_SOUND(mob, sound('sound/misc/notice1.ogg'))

/area/syndicate_depot/core/proc/shields_up()
	if(length(shield_list))
		return
	for(var/obj/effect/landmark/landmark in GLOB.landmarks_list)
		if(landmark.name == "syndi_depot_shield")
			var/obj/machinery/shieldwall/syndicate/syndicate = new /obj/machinery/shieldwall/syndicate(landmark.loc)
			shield_list += syndicate.UID()
	for(var/obj/structure/closet/secure_closet/syndicate/depot/armory/landmark in src)
		if(landmark.opened)
			landmark.close()
		if(!landmark.locked)
			landmark.locked = !landmark.locked
		landmark.update_icon()
	for(var/obj/machinery/door/airlock/hatch/syndicate/vault/vault in machinery_cache)
		vault.lock()

/area/syndicate_depot/core/proc/shields_key_check()
	if(!length(shield_list))
		return
	if(detected_mech || detected_pod || detected_double_agent)
		return
	shields_down()

/area/syndicate_depot/core/proc/shields_down()
	for(var/shuid in shield_list)
		var/obj/machinery/shieldwall/syndicate/syndicate = locateUID(shuid)
		if(syndicate)
			qdel(syndicate)
	shield_list = list()
	for(var/obj/structure/closet/secure_closet/syndicate/depot/armory/armory in src)
		if(armory.locked)
			armory.locked = !armory.locked
			armory.update_icon()
	for(var/obj/machinery/door/airlock/hatch/syndicate/vault/vault in machinery_cache)
		vault.unlock()

/area/syndicate_depot/core/proc/despawn_guards()
	for(var/mob/thismob in list_getmobs(guard_list))
		new /obj/effect/portal(get_turf(thismob))
		qdel(thismob)
	guard_list = list()

/area/syndicate_depot/core/proc/ghostlog(gmsg)
	if(istype(reactor))
		var/image/alert_overlay = image('icons/obj/flag.dmi', "syndiflag")
		notify_ghosts(gmsg, title = "Depot News", source = reactor.loc, alert_overlay = alert_overlay, action = NOTIFY_JUMP)

/area/syndicate_depot/core/proc/declare_started()
	if(!run_started)
		run_started = TRUE
		add_game_logs("Depot run: started: " + list_show(hostile_list, TRUE))

/area/syndicate_depot/core/proc/declare_finished()
	if(!run_finished && !used_self_destruct)
		run_finished = TRUE
		add_game_logs("Depot run: finished successfully: " + list_show(hostile_list, TRUE))

/area/syndicate_depot/core/proc/list_add(mob/M, list/L)
	if(!istype(M))
		return
	var/mob_uid = M.UID()
	if(mob_uid in L)
		return
	L += mob_uid

/area/syndicate_depot/core/proc/list_remove(mob/M, list/L)
	if(!istype(M))
		return
	var/mob_uid = M.UID()
	if(mob_uid in L)
		L -= mob_uid

/area/syndicate_depot/core/proc/list_includes(mob/M, list/L)
	if(!istype(M))
		return FALSE
	var/mob_uid = M.UID()
	if(mob_uid in L)
		return TRUE
	return FALSE

/**
 * Returns a STRING, containing the NAMES of the mobs in the provided list, JOINED together with ", "
 *
 * E.g. list_show(depotarea.guard_list) returns a string like:
 * "Syndicate Backup (123), Syndicate Backup(456), Syndicate Backup(789)", etc.
 * Arguments:
 * * list/L, the list of UIDs from which to draw members
 * * show_ckeys, bool, if true will display ckeys in addition to names
 */
/area/syndicate_depot/core/proc/list_show(list/L, show_ckeys = FALSE)
	var/list/formatted = list_shownames(L, show_ckeys)
	return formatted.Join(", ")

/**
 * Returns a LIST of the NAMES of the mobs in the provided list.
 *
 * E.g. list_shownames(depotarea.guard_list) returns a list of the names of extra guard mobs in depot.
 * Arguments:
 * * list/L, the list of UIDs from which to draw members
 * * show_ckeys, bool, if true will display ckeys in addition to names
 */
/area/syndicate_depot/core/proc/list_shownames(list/L, show_ckeys = FALSE)
	var/list/names = list()
	for(var/uid in L)
		var/mob/mob = locateUID(uid)
		if(!istype(mob))
			continue
		if(show_ckeys)
			names += "[mob.ckey]([mob])"
		else
			names += "[mob]"
	return names

/**
 * Returns a LIST of the MOBS in one of the depot area's lists.
 *
 * E.g. list_getmobs(depotarea.guard_list) returns a list of the extra guard mobs in the depot.
 * Arguments:
 * * list/L, the list of UIDs from which to draw members
 * * show_ckeys, bool, if true will display ckeys in addition to names
 */
/area/syndicate_depot/core/proc/list_getmobs(list/L, show_ckeys = FALSE)
	var/list/moblist = list()
	for(var/uid in L)
		var/mob/mob = locateUID(uid)
		if(!istype(mob))
			continue
		moblist += mob
	return moblist

/area/syndicate_depot/outer
	name = "Suspicious Asteroid"
	icon_state = "green"

/area/syndicate_depot/perimeter
	name = "Suspicious Asteroid Perimeter"
	icon_state = "yellow"
	var/list/shield_list = list()

/area/syndicate_depot/perimeter/proc/perimeter_shields_up()
	if(length(shield_list))
		return
	for(var/turf/turf in src)
		var/obj/machinery/shieldwall/syndicate/syndicate = new /obj/machinery/shieldwall/syndicate(turf)
		syndicate.alpha = 0
		shield_list += syndicate.UID()

/area/syndicate_depot/perimeter/proc/perimeter_shields_down()
	for(var/shuid in shield_list)
		var/obj/machinery/shieldwall/syndicate/syndicate = locateUID(shuid)
		if(syndicate)
			qdel(syndicate)
	shield_list = list()
