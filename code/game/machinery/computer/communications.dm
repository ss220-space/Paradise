#define COMM_SCREEN_MAIN		1
#define COMM_SCREEN_STAT		2
#define COMM_SCREEN_MESSAGES	3

#define COMM_AUTHENTICATION_NONE	0
#define COMM_AUTHENTICATION_MIN		1
#define COMM_AUTHENTICATION_MAX		2

#define COMM_MSGLEN_MINIMUM 6
#define COMM_CCMSGLEN_MINIMUM 20

// The communications computer
/obj/machinery/computer/communications
	name = "communications console"
	desc = "This allows the Captain to contact Central Command, or change the alert level. It also allows the command staff to call the Escape Shuttle."
	icon_keyboard = "tech_key"
	icon_screen = "comm"
	req_access = list(ACCESS_HEADS)
	circuit = /obj/item/circuitboard/communications
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg

	var/authenticated = COMM_AUTHENTICATION_NONE
	var/menu_state = COMM_SCREEN_MAIN
	var/ai_menu_state = COMM_SCREEN_MAIN
	var/aicurrmsg

	var/message_cooldown
	var/centcomm_message_cooldown
	var/tmp_alertlevel = 0

	var/stat_msg1
	var/stat_msg2
	var/display_type = "blank"
	var/display_icon

	var/datum/announcement/priority/crew_announcement = new

	light_color = LIGHT_COLOR_LIGHTBLUE

/obj/machinery/computer/communications/New()
	GLOB.shuttle_caller_list += src
	..()
	crew_announcement.newscast = 0

/obj/machinery/computer/communications/proc/is_authenticated(var/mob/user, var/message = 1)
	if(authenticated == COMM_AUTHENTICATION_MAX)
		return COMM_AUTHENTICATION_MAX
	else if(user.can_admin_interact())
		return COMM_AUTHENTICATION_MAX
	else if(authenticated)
		return COMM_AUTHENTICATION_MIN
	else
		if(message)
			to_chat(user, span_warning("Access denied."))
			playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return COMM_AUTHENTICATION_NONE

/obj/machinery/computer/communications/proc/change_security_level(var/new_level)
	tmp_alertlevel = new_level
	var/old_level = GLOB.security_level
	if(!tmp_alertlevel) tmp_alertlevel = SEC_LEVEL_GREEN
	if(tmp_alertlevel < SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN
	if(tmp_alertlevel > SEC_LEVEL_BLUE) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
	set_security_level(tmp_alertlevel)
	if(GLOB.security_level != old_level)
		//Only notify the admins if an actual change happened
		add_game_logs("has changed the security level to [get_security_level()].", usr)
		message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
	tmp_alertlevel = 0

/obj/machinery/computer/communications/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!is_secure_level(z))
		to_chat(usr, span_warning("Unable to establish a connection: You're too far away from the station!"))
		return

	. = TRUE

	if(action == "auth")
		if(!ishuman(usr))
			to_chat(usr, span_warning("Access denied."))
			playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
			return FALSE
		// Logout function.
		if(authenticated != COMM_AUTHENTICATION_NONE)
			authenticated = COMM_AUTHENTICATION_NONE
			crew_announcement.announcer = null
			setMenuState(usr, COMM_SCREEN_MAIN)
			return
		// Login function.
		var/list/access = usr.get_access()
		if(allowed(usr))
			authenticated = COMM_AUTHENTICATION_MIN
		if(ACCESS_CAPTAIN in access)
			authenticated = COMM_AUTHENTICATION_MAX
			var/mob/living/carbon/human/H = usr
			var/obj/item/card/id = H.get_id_card()
			if(istype(id))
				crew_announcement.announcer = GetNameAndAssignmentFromId(id)
		if(authenticated == COMM_AUTHENTICATION_NONE)
			to_chat(usr, span_warning("You need to wear your ID."))
		return

	// All functions below this point require authentication.
	if(!is_authenticated(usr))
		return FALSE

	switch(action)
		if("main")
			setMenuState(usr, COMM_SCREEN_MAIN)

		if("newalertlevel")
			if(isAI(usr) || isrobot(usr))
				to_chat(usr, span_warning("Firewalls prevent you from changing the alert level."))
				return
			else if(usr.can_admin_interact())
				change_security_level(text2num(params["level"]))
				return
			else if(!ishuman(usr))
				to_chat(usr, span_warning("Security measures prevent you from changing the alert level."))
				return

			var/mob/living/carbon/human/H = usr
			var/obj/item/card/id/I = H.get_id_card()
			if(istype(I))
				if((GLOB.security_level > SEC_LEVEL_RED) && !(ACCESS_CENT_GENERAL in I.access)) //if gamma, epsilon or delta and no centcom access. Decline it
					to_chat(usr, span_warning("CentCom security measures prevent you from changing the alert level."))
					return
				if(ACCESS_HEADS in I.access)
					change_security_level(text2num(params["level"]))
				else
					to_chat(usr, span_warning("You are not authorized to do this."))
				setMenuState(usr, COMM_SCREEN_MAIN)
			else
				to_chat(usr, span_warning("You need to wear your ID."))

		if("announce")
			if(is_authenticated(usr) == COMM_AUTHENTICATION_MAX)
				if(message_cooldown > world.time)
					to_chat(usr, span_warning("Please allow at least one minute to pass between announcements."))
					return
				var/input = input(usr, "Please write a message to announce to the station crew.", "Priority Announcement") as message|null
				if(!input || message_cooldown > world.time || ..() || !(is_authenticated(usr) == COMM_AUTHENTICATION_MAX))
					return
				if(length(input) < COMM_MSGLEN_MINIMUM)
					to_chat(usr, span_warning("Message '[input]' is too short. [COMM_MSGLEN_MINIMUM] character minimum."))
					return
				crew_announcement.Announce(input)
				message_cooldown = world.time + 600 //One minute

		if("callshuttle")
			var/input = clean_input("Please enter the reason for calling the shuttle.", "Shuttle Call Reason.","")
			if(!input || ..() || !is_authenticated(usr))
				return
			call_shuttle_proc(usr, input)
			if(SSshuttle.emergency.timer)
				post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
			setMenuState(usr, COMM_SCREEN_MAIN)

		if("cancelshuttle")
			if(isAI(usr) || isrobot(usr))
				to_chat(usr, span_warning("Firewalls prevent you from recalling the shuttle."))
				return
			var/response = tgui_alert(usr, "Are you sure you wish to recall the shuttle?", "Confirm", list("Yes", "No"))
			if(response == "Yes")
				cancel_call_proc(usr)
				if(SSshuttle.emergency.timer)
					post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
			setMenuState(usr, COMM_SCREEN_MAIN)

		if("messagelist")
			currmsg = null
			aicurrmsg = null
			if(params["msgid"])
				setCurrentMessage(usr, text2num(params["msgid"]))
			setMenuState(usr, COMM_SCREEN_MESSAGES)

		if("delmessage")
			if(params["msgid"])
				currmsg = text2num(params["msgid"])
			var/response = alert("Are you sure you wish to delete this message?", "Confirm", "Yes", "No")
			if(response == "Yes")
				if(currmsg)
					var/id = getCurrentMessage()
					var/title = messagetitle[id]
					var/text  = messagetext[id]
					messagetitle.Remove(title)
					messagetext.Remove(text)
					if(currmsg == id)
						currmsg = null
					if(aicurrmsg == id)
						aicurrmsg = null
			setMenuState(usr, COMM_SCREEN_MESSAGES)

		if("status")
			setMenuState(usr, COMM_SCREEN_STAT)

		// Status display stuff
		if("setstat")
			display_type = params["statdisp"]
			switch(display_type)
				if("message")
					display_icon = null
					post_status(STATUS_DISPLAY_MESSAGE, stat_msg1, stat_msg2)
				if("alert")
					display_icon = params["alert"]
					post_status(STATUS_DISPLAY_ALERT, params["alert"])
				else
					display_icon = null
					post_status(display_type)
			setMenuState(usr, COMM_SCREEN_STAT)

		if("setmsg1")
			stat_msg1 = tgui_input_text(ui.user, "Line 1", stat_msg1, "Enter Message Text", encode = FALSE)
			setMenuState(usr, COMM_SCREEN_STAT)

		if("setmsg2")
			stat_msg2 = tgui_input_text(ui.user, "Line 2", stat_msg2, "Enter Message Text", encode = FALSE)
			setMenuState(usr, COMM_SCREEN_STAT)

		if("nukerequest")
			if(is_authenticated(usr) == COMM_AUTHENTICATION_MAX)
				if(centcomm_message_cooldown > world.time)
					to_chat(usr, span_warning("Arrays recycling. Please stand by."))
					return
				var/input = tgui_input_text(ui.user, "Please enter the reason for requesting the nuclear self-destruct codes. Misuse of the nuclear request system will not be tolerated under any circumstances. Transmission does not guarantee a response.", "Self Destruct Code Request.")
				if(isnull(input) || ..() || !(is_authenticated(ui.user) >= COMM_AUTHENTICATION_MAX))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(usr, span_warning("Message '[input]' is too short. [COMM_CCMSGLEN_MINIMUM] character minimum."))
					return
				Nuke_request(input, usr)
				to_chat(usr, span_notice("Request sent."))
				add_game_logs("has requested the nuclear codes from Centcomm: [input]", usr)
				GLOB.priority_announcement.Announce("Коды активации ядерной боеголовки на станции были запрошены [usr]. Решение о подтверждении или отклонении данного запроса будет отправлено в ближайшее время.", "Запрошены коды активации ядерной боеголовки.",'sound/AI/commandreport.ogg')
				centcomm_message_cooldown = world.time + 6000 // 10 minutes
			setMenuState(usr, COMM_SCREEN_MAIN)

		if("MessageCentcomm")
			if(is_authenticated(usr) == COMM_AUTHENTICATION_MAX)
				if(centcomm_message_cooldown > world.time)
					to_chat(usr, span_warning("Arrays recycling. Please stand by."))
					return
				var/input = tgui_input_text(ui.user, "Please choose a message to transmit to Centcomm via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "CentComm Message")
				if(!input || ..() || !(is_authenticated(usr) == COMM_AUTHENTICATION_MAX))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(usr, span_warning("Message '[input]' is too short. [COMM_CCMSGLEN_MINIMUM] character minimum."))
					return
				Centcomm_announce(input, usr)
				print_centcom_report(input, station_time_timestamp() + " Captain's Message")
				to_chat(usr, "Message transmitted.")
				add_game_logs("has made a Centcomm announcement: [input]", usr)
				centcomm_message_cooldown = world.time + 6000 // 10 minutes
			setMenuState(usr, COMM_SCREEN_MAIN)

		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((is_authenticated(usr) == COMM_AUTHENTICATION_MAX) && (src.emagged))
				if(centcomm_message_cooldown > world.time)
					to_chat(usr, "Arrays recycling.  Please stand by.")
					return
				var/input = tgui_input_text(ui.user, "Please choose a message to transmit to \[ABNORMAL ROUTING CORDINATES\] via quantum entanglement. Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "Send Message")
				if(!input || ..() || !(is_authenticated(usr) == COMM_AUTHENTICATION_MAX))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(usr, span_warning("Message '[input]' is too short. [COMM_CCMSGLEN_MINIMUM] character minimum."))
					return
				Syndicate_announce(input, usr)
				to_chat(usr, "Message transmitted.")
				add_game_logs("has made a Syndicate announcement: [input]", usr)
				centcomm_message_cooldown = world.time + 6000 // 10 minutes
			setMenuState(usr, COMM_SCREEN_MAIN)

		if("RestoreBackup")
			to_chat(usr, "Backup routing data restored!")
			src.emagged = 0
			setMenuState(usr, COMM_SCREEN_MAIN)



/obj/machinery/computer/communications/emag_act(user as mob)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		src.emagged = 1
		if(user)
			to_chat(user, span_notice("You scramble the communication routing circuits!"))
		SStgui.update_uis(src)

/obj/machinery/computer/communications/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/communications/attack_hand(var/mob/user as mob)
	if(..(user))
		return

	if(stat & (NOPOWER|BROKEN))
		return

	if(!is_secure_level(src.z))
		to_chat(user, span_warning("Unable to establish a connection: You're too far away from the station!"))
		return

	ui_interact(user)

/obj/machinery/computer/communications/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CommunicationsComputer", name)
		ui.open()

/obj/machinery/computer/communications/ui_data(mob/user)
	var/list/data = list()
	data["is_ai"]         = isAI(user) || isrobot(user)
	data["menu_state"]    = data["is_ai"] ? ai_menu_state : menu_state
	data["emagged"]       = emagged
	data["authenticated"] = is_authenticated(user, 0)
	data["authmax"] = data["authenticated"] == COMM_AUTHENTICATION_MAX ? TRUE : FALSE

	data["stat_display"] =  list(
		"type"   = display_type,
		"icon"   = display_icon,
		"line_1" = (stat_msg1 ? stat_msg1 : "-----"),
		"line_2" = (stat_msg2 ? stat_msg2 : "-----"),

		"presets" = list(
			list("name" = "blank",    "label" = "Clear",       "desc" = "Blank slate"),
			list("name" = "shuttle",  "label" = "Shuttle ETA", "desc" = "Display how much time is left."),
			list("name" = "message",  "label" = "Message",     "desc" = "A custom message.")
		),

		"alerts"=list(
			list("alert" = "default",   "label" = "Nanotrasen",  "desc" = "Oh god."),
			list("alert" = "redalert",  "label" = "Red Alert",   "desc" = "Nothing to do with communists."),
			list("alert" = "lockdown",  "label" = "Lockdown",    "desc" = "Let everyone know they're on lockdown."),
			list("alert" = "biohazard", "label" = "Biohazard",   "desc" = "Great for virus outbreaks and parties."),
		)
	)

	data["security_level"] = GLOB.security_level
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			data["security_level_color"] = "green";
		if(SEC_LEVEL_BLUE)
			data["security_level_color"] = "blue";
		if(SEC_LEVEL_RED)
			data["security_level_color"] = "red";
		else
			data["security_level_color"] = "purple";
	data["str_security_level"] = capitalize(get_security_level())
	data["levels"] = list(
		list("id" = SEC_LEVEL_GREEN, "name" = "Green", "icon" = "dove"),
		list("id" = SEC_LEVEL_BLUE,  "name" = "Blue", "icon" = "eye"),
	)

	var/list/msg_data = list()
	for(var/i = 1; i <= messagetext.len; i++)
		msg_data.Add(list(list("title" = messagetitle[i], "body" = messagetext[i], "id" = i)))

	data["messages"]        = msg_data

	data["current_message"] = null
	data["current_message_title"] = null
	if((data["is_ai"] && aicurrmsg) || (!data["is_ai"] && currmsg))
		data["current_message"] = data["is_ai"] ? messagetext[aicurrmsg] : messagetext[currmsg]
		data["current_message_title"] = data["is_ai"] ? messagetitle[aicurrmsg] : messagetitle[currmsg]

	data["lastCallLoc"]     = SSshuttle.emergencyLastCallLoc ? format_text(SSshuttle.emergencyLastCallLoc.name) : null
	data["msg_cooldown"] = message_cooldown ? (round((message_cooldown - world.time) / 10)) : 0
	data["cc_cooldown"] = centcomm_message_cooldown ? (round((centcomm_message_cooldown - world.time) / 10)) : 0

	var/secondsToRefuel = SSshuttle.secondsToRefuel()
	data["esc_callable"] = SSshuttle.emergency.mode == SHUTTLE_IDLE && !secondsToRefuel ? TRUE : FALSE
	data["esc_recallable"] = SSshuttle.emergency.mode == SHUTTLE_CALL ? TRUE : FALSE
	data["esc_status"] = FALSE
	if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
		var/timeleft = SSshuttle.emergency.timeLeft()
		data["esc_status"] = SSshuttle.emergency.mode == SHUTTLE_CALL ? "ETA:" : "RECALLING:"
		data["esc_status"] += " [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]"
	else if(secondsToRefuel)
		data["esc_status"] = "Refueling: [secondsToRefuel / 60 % 60]:[add_zero(num2text(secondsToRefuel % 60), 2)]"
	data["esc_section"] = data["esc_status"] || data["esc_callable"] || data["esc_recallable"] || data["lastCallLoc"]
	return data

/obj/machinery/computer/communications/proc/setCurrentMessage(var/mob/user,var/value)
	if(isAI(user) || isrobot(user))
		aicurrmsg = value
	else
		currmsg = value

/obj/machinery/computer/communications/proc/getCurrentMessage(var/mob/user)
	if(isAI(user) || isrobot(user))
		return aicurrmsg
	else
		return currmsg

/obj/machinery/computer/communications/proc/setMenuState(var/mob/user,var/value)
	if(isAI(user) || isrobot(user))
		ai_menu_state=value
	else
		menu_state=value

/proc/call_shuttle_proc(mob/user, reason)
	if(GLOB.sent_strike_team == TRUE || GLOB.security_level == SEC_LEVEL_EPSILON)
		to_chat(user, span_warning("Central Command will not allow the shuttle to be called. Consider all contracts terminated."))
		return

	if(SSticker?.mode?.blob_stage >= BLOB_STAGE_FIRST && SSshuttle.emergencyNoEscape)
		to_chat(user, span_warning("Under directive 7-10, [station_name()] is quarantined until further notice."))
		return

	if(SSshuttle.emergencyNoEscape)
		to_chat(user, span_warning("The emergency shuttle may not be sent at this time. Please try again later."))
		return

	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		to_chat(user, span_warning("The emergency shuttle may not be called while returning to Central Command."))
		return


	SSshuttle.requestEvac(user, reason)
	add_game_logs("has called the shuttle: [reason]", user)
	message_admins("[key_name_admin(user)] has called the shuttle.")

	return

/proc/init_shift_change(mob/user, force = 0)
	// if force is 0, some things may stop the shuttle call
	if(!force)
		if(SSshuttle.emergencyNoEscape)
			to_chat(user, "Central Command does not currently have a shuttle available in your sector. Please try again later.")
			return

		if(GLOB.sent_strike_team == TRUE || GLOB.security_level == SEC_LEVEL_EPSILON)
			to_chat(user, "Central Command will not allow the shuttle to be called. Consider all contracts terminated.")
			return

		if(world.time < 54000) // 30 minute grace period to let the game get going
			to_chat(user, "The shuttle is refueling. Please wait another [round((54000-world.time)/600)] minutes before trying again.")
			return

		if(SSticker.mode.name == "epidemic")
			to_chat(user, "Under directive 7-10, [station_name()] is quarantined until further notice.")
			return

	if(seclevel2num(get_security_level()) >= SEC_LEVEL_RED) // There is a serious threat we gotta move no time to give them five minutes.
		SSshuttle.emergency.request(null, 0.5, null, " Automatic Crew Transfer", 1)
		SSshuttle.emergency.canRecall = FALSE
	else
		SSshuttle.emergency.request(null, 1, null, " Automatic Crew Transfer", 0)
		SSshuttle.emergency.canRecall = FALSE
	if(user)
		add_game_logs("has called the shuttle.", user)
		message_admins("[key_name_admin(user)] has called the shuttle - [formatJumpTo(user)].")
	return


/proc/cancel_call_proc(mob/user)
	if(SSticker.mode.name == "meteor")
		return

	if(SSshuttle.cancelEvac(user))
		add_game_logs("has recalled the shuttle.", user)
		message_admins("[ADMIN_LOOKUPFLW(user)] has recalled the shuttle .")
	else
		to_chat(user, span_warning("Central Command has refused the recall request!"))
		add_game_logs("has tried and failed to recall the shuttle.", user)
		message_admins("[ADMIN_LOOKUPFLW(user)] has tried and failed to recall the shuttle.")


/proc/post_status(mode, data1, data2)
	if(usr && mode == STATUS_DISPLAY_MESSAGE)
		log_and_message_admins("set status screen message: [data1] [data2]")

	for(var/obj/machinery/status_display/display as anything in GLOB.status_displays)
		if(display.is_supply)
			continue

		display.set_mode(mode)
		switch(mode)
			if(STATUS_DISPLAY_MESSAGE)
				display.set_message(data1, data2)
			if(STATUS_DISPLAY_ALERT)
				display.set_picture(data1)

		display.update()


/obj/machinery/computer/communications/Destroy()
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	return ..()

/obj/item/circuitboard/communications/New()
	GLOB.shuttle_caller_list += src
	..()

/obj/item/circuitboard/communications/Destroy()
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	return ..()

/proc/print_command_report(text = "", title = "Central Command Update", add_to_records = TRUE, var/datum/station_goal/goal = null)
	for(var/obj/machinery/computer/communications/C in GLOB.shuttle_caller_list)
		if(!(C.stat & (BROKEN|NOPOWER)) && is_station_contact(C.z))
			var/obj/item/paper/P = new (C.loc)
			P.name = "paper- '[title]'"
			P.info = text
			if(add_to_records)
				C.messagetitle.Add("[title]")
				C.messagetext.Add(text)
			if(goal)
				P.stamp(/obj/item/stamp/navcom)
				goal.papers_list.Add(P)

/proc/print_centcom_report(text = "", title = "Incoming Message")
	for(var/obj/machinery/computer/communications/C in GLOB.shuttle_caller_list)
		if(!(C.stat & (BROKEN|NOPOWER)) && is_admin_level(C.z))
			var/obj/item/paper/P = new /obj/item/paper(C.loc)
			P.name = "paper- '[title]'"
			P.info = text
			P.update_icon()
			C.messagetitle.Add("[title]")
			C.messagetext.Add(text)


