/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "auth_off"

	var/active = FALSE // This gets set to TRUE on all devices except the one where the initial request was made.
	var/event
	var/swiping = FALSE // on swiping screen?
	var/list/ert_chosen = list()
	var/confirm_delay = 5 SECONDS // time allowed for a second person to confirm a swipe.
	var/busy = FALSE // Busy when waiting for authentication or an event request has been sent from this device.
	var/obj/machinery/keycard_auth/event_source
	var/mob/event_triggered_by
	var/mob/event_confirmed_by
	var/ert_reason

	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

	req_access = list(ACCESS_KEYCARD_AUTH)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/keycard_auth/attack_ai(mob/user as mob)
	to_chat(user, "<span class='warning'>The station AI is not to interact with these devices.</span>")
	return


/obj/machinery/keycard_auth/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(I.GetID())
		add_fingerprint(user)
		if(stat & (NOPOWER|BROKEN))
			to_chat(user, span_warning("The [name] is not powered or broken."))
			return ATTACK_CHAIN_PROCEED
		if(!check_access(I))
			to_chat(user, span_warning("Access denied."))
			playsound(loc, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
			return ATTACK_CHAIN_PROCEED
		if(active)
			//This is not the device that made the initial request. It is the device confirming the request.
			if(event_source)
				event_source.event_confirmed_by = user
				SStgui.update_uis(event_source)
				SStgui.update_uis(src)
		else if(swiping)
			if(event == "Emergency Response Team" && !ert_reason)
				to_chat(user, span_warning("Supply a reason for calling the ERT first."))
				return ATTACK_CHAIN_PROCEED
			event_triggered_by = user
			SStgui.update_uis(src)
			broadcast_request() //This is the device making the initial event request. It needs to broadcast to other devices
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/keycard_auth/update_icon_state()
	if(event_triggered_by || event_source)
		icon_state = "auth_on"
	else
		icon_state = "auth_off"


/obj/machinery/keycard_auth/update_overlays()
	. = ..()
	underlays.Cut()

	if(event_triggered_by || event_source)
		underlays += emissive_appearance(icon, "auth_lightmask", src)


/obj/machinery/keycard_auth/power_change(forced = FALSE)
	if(!..())
		return
	update_icon()

/obj/machinery/keycard_auth/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/keycard_auth/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/keycard_auth/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KeycardAuth", name)
		ui.open()


/obj/machinery/keycard_auth/ui_data()
	var/list/data = list()
	data["redAvailable"] = GLOB.security_level == SEC_LEVEL_RED ? FALSE : TRUE
	data["swiping"] = swiping
	data["busy"] = busy
	data["event"] = active && event_source && event_source.event ? event_source.event : event
	data["ertreason"] = active && event_source && event_source.ert_reason ? event_source.ert_reason : ert_reason
	data["isRemote"] = active ? TRUE : FALSE
	data["hasSwiped"] = event_triggered_by ? TRUE : FALSE
	data["hasConfirm"] = event_confirmed_by || (active && event_source && event_source.event_confirmed_by) ? TRUE : FALSE
	return data

/obj/machinery/keycard_auth/ui_act(action, params)
	if(..())
		return
	if(busy)
		to_chat(usr, "<span class='warning'>This device is busy.</span>")
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return
	. = TRUE
	switch(action)
		if("ert")
			ert_reason = tgui_input_text(usr, "Reason for ERT Call:", "Call ERT", encode = FALSE) // we strip this later in ERT_Announce
		if("reset")
			reset()
		if("triggerevent")
			event = params["triggerevent"]
			if(GLOB.security_level > SEC_LEVEL_RED && event == "Red Alert") //if gamma, epsilon or delta
				to_chat(usr, "<span class='warning'>CentCom security measures prevent you from changing the alert level.</span>")
				return
			swiping = TRUE

	add_fingerprint(usr)

/obj/machinery/keycard_auth/proc/reset()
	active = FALSE
	event = null
	swiping = FALSE
	event_source = null
	event_triggered_by = null
	event_confirmed_by = null
	busy = FALSE
	update_icon()


/obj/machinery/keycard_auth/proc/broadcast_request()
	update_icon()
	for(var/obj/machinery/keycard_auth/KA in GLOB.machines)
		if(KA == src)
			continue
		KA.receive_request(src)

	addtimer(CALLBACK(src, PROC_REF(confirm_and_trigger)), confirm_delay)


/obj/machinery/keycard_auth/proc/confirm_and_trigger()
	if(event_confirmed_by)
		trigger_event(event)
		add_game_logs("triggered and [key_name_log(event_confirmed_by)] confirmed event [event]", event_triggered_by)
		message_admins("[key_name_admin(event_triggered_by)] triggered and [key_name_admin(event_confirmed_by)] confirmed event [event]", 1)
	reset()


/obj/machinery/keycard_auth/proc/receive_request(obj/machinery/keycard_auth/source)
	if(stat & (BROKEN|NOPOWER))
		return
	reset()

	event_source = source
	busy = TRUE
	active = TRUE
	SStgui.update_uis(src)
	update_icon()

	addtimer(CALLBACK(src, PROC_REF(reset)), confirm_delay)


/obj/machinery/keycard_auth/proc/trigger_event()
	switch(event)
		if("Red Alert")
			set_security_level(SEC_LEVEL_RED)
		if("Grant Emergency Maintenance Access")
			make_maint_all_access()
		if("Revoke Emergency Maintenance Access")
			revoke_maint_all_access()
		if("Activate Station-Wide Emergency Access")
			make_station_all_access()
		if("Deactivate Station-Wide Emergency Access")
			revoke_station_all_access()
		if("Emergency Response Team")
			if(is_ert_blocked())
				atom_say("Все Отряды Быстрого Реагирования распределены и не могут быть вызваны в данный момент.")
				return
			atom_say("Запрос ОБР отправлен!")
			GLOB.command_announcer.autosay("ERT request transmitted. Reason: [ert_reason]", name)
			print_centcom_report(ert_reason, station_time_timestamp() + " ERT Request")

			var/fullmin_count = 0
			for(var/client/C in GLOB.admins)
				if(check_rights(R_EVENT, 0, C.mob))
					fullmin_count++
			if(fullmin_count)
				addtimer(CALLBACK(src, PROC_REF(remind_admins), ert_reason, event_triggered_by), 5 MINUTES)
				GLOB.ert_request_answered = TRUE
				ERT_Announce(ert_reason , event_triggered_by, 0)
				ert_reason = null
				SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("ert", "called"))
			else
				var/list/excludemodes = list(/datum/game_mode/nuclear, /datum/game_mode/blob)
				if(SSticker.mode.type in excludemodes)
					return
				var/list/excludeevents = list(/datum/event/blob)
				for(var/datum/event/E in SSevents.active_events|SSevents.finished_events)
					if(E.type in excludeevents)
						return
				trigger_armed_response_team(new /datum/response_team/amber) // No admins? No problem. Automatically send a code amber ERT.


/obj/machinery/keycard_auth/proc/remind_admins(old_reason, event_triggered_by)
	if(GLOB.ert_request_answered)
		GLOB.ert_request_answered = FALSE // For ERT requests that may come later
		return
	ERT_Announce(old_reason, event_triggered_by, repeat_warning = TRUE)


/obj/machinery/keycard_auth/proc/is_ert_blocked()
	return SSticker.mode && SSticker.mode.ert_disabled

GLOBAL_VAR_INIT(maint_all_access, 0)
GLOBAL_VAR_INIT(station_all_access, 0)

// Why are these global procs?
/proc/make_maint_all_access()
	for(var/area/maintenance/A in GLOB.all_areas) // Why are these global lists? AAAAAAAAAAAAAA
		for(var/obj/machinery/door/airlock/D in A.machinery_cache)
			D.emergency = 1
			D.update_icon()
	GLOB.minor_announcement.Announce("Ограничения на доступ к техническим и внешним шл+юзам были сняты.")
	GLOB.maint_all_access = 1
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency maintenance access", "enabled"))

/proc/revoke_maint_all_access()
	for(var/area/maintenance/A in GLOB.all_areas)
		for(var/obj/machinery/door/airlock/D in A.machinery_cache)
			D.emergency = 0
			D.update_icon()
	GLOB.minor_announcement.Announce("Ограничения на доступ к техническим и внешним шл+юзам были возобновлены.")
	GLOB.maint_all_access = 0
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency maintenance access", "disabled"))

/proc/make_station_all_access()
	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(is_station_level(D.z))
			D.emergency = 1
			D.update_icon()
	GLOB.minor_announcement.Announce("Ограничения на доступ ко всем шл+юзам станции были сняты в связи с происходящим кризисом. Статьи о незаконном проникновении по-прежнему действуют, если командование не заявит об обратном.")
	GLOB.station_all_access = 1
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency station access", "enabled"))

/proc/revoke_station_all_access()
	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(is_station_level(D.z))
			D.emergency = 0
			D.update_icon()
	GLOB.minor_announcement.Announce("Ограничения на доступ ко всем шл+юзам станции были вновь возобновлены. Если вы застряли, обратитесь за помощью к ИИ станции, или к коллегам.")
	GLOB.station_all_access = 0
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency station access", "disabled"))
