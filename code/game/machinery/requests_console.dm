/******************** Requests Console ********************/
/** Originally written by errorage, updated by: Carn, needs more work though. I just added some security fixes */

#define RQ_NONEW_MESSAGES 0
#define RQ_NORMALPRIORITY 1
#define RQ_HIGHPRIORITY 2

GLOBAL_LIST_EMPTY(req_console_assistance)
GLOBAL_LIST_EMPTY(req_console_supplies)
GLOBAL_LIST_EMPTY(req_console_information)
GLOBAL_LIST_EMPTY(allRequestConsoles)

/obj/machinery/requests_console
	name = "Requests Console"
	desc = "A console intended to send requests to different departments on the station."
	anchored = TRUE
	icon = 'icons/obj/machines/terminals.dmi'
	icon_state = "req_comp_off"
	max_integrity = 300
	armor = list("melee" = 70, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 90)
	var/department = "Unknown" //The list of all departments on the station (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/list/message_log = list() //List of all messages
	var/departmentType = 0 		//Bitflag. Zero is reply-only. Map currently uses raw numbers instead of defines.
	var/newmessagepriority = RQ_NONEW_MESSAGES
		// RQ_NONEWMESSAGES = no new message
		// RQ_NORMALPRIORITY = normal priority
		// RQ_HIGHPRIORITY = high priority
	var/screen = RCS_MAINMENU
	var/silent = FALSE // set to TRUE for it not to beep all the time
	var/announcementConsole = FALSE
		// FALSE = This console cannot be used to send department announcements
		// TRUE = This console can send department announcementsf
	var/announceAuth = 0 //Will be set to 1 when you authenticate yourself for announcements
	var/msgVerified = "" //Will contain the name of the person who varified it
	var/msgStamped = "" //If a message is stamped, this will contain the stamp name
	var/message = ""
	var/recipient = ""; //the department which will be receiving the message
	var/priority = -1 ; //Priority of the message being sent
	var/datum/announcement/announcement = new
	var/list/shipping_log = list()
	var/ship_tag_name = ""
	var/ship_tag_index = 0
	var/print_cooldown = 0	//cooldown on shipping label printer, stores the  in-game time of when the printer will next be ready
	var/obj/item/radio/Radio
	var/radiochannel = ""
	var/list/connected_apps = list()


/obj/machinery/requests_console/Initialize(mapload)
	Radio = new /obj/item/radio(src)
	Radio.listening = TRUE
	Radio.config(list("Engineering", "Medical", "Supply", "Command", "Science", "Service", "Security", "AI Private" = FALSE))
	Radio.follow_target = src
	. = ..()

	announcement.title = "[department] announcement"
	announcement.newscast = FALSE
	announcement.log = TRUE

	name = "[department] Requests Console"
	GLOB.allRequestConsoles += src
	if(departmentType & RC_ASSIST)
		GLOB.req_console_assistance |= department
	if(departmentType & RC_SUPPLY)
		GLOB.req_console_supplies |= department
	if(departmentType & RC_INFO)
		GLOB.req_console_information |= department
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/requests_console/Destroy()
	GLOB.allRequestConsoles -= src
	var/lastDeptRC = TRUE
	for(var/obj/machinery/requests_console/Console in GLOB.allRequestConsoles)
		if(Console.department == department)
			lastDeptRC = FALSE
			break
	if(lastDeptRC)
		if(departmentType & RC_ASSIST)
			GLOB.req_console_assistance -= department
		if(departmentType & RC_SUPPLY)
			GLOB.req_console_supplies -= department
		if(departmentType & RC_INFO)
			GLOB.req_console_information -= department
	QDEL_NULL(Radio)
	for(var/datum/data/pda/app/request_console/app as anything in connected_apps)
		app.on_rc_destroyed(src)
	return ..()

/obj/machinery/requests_console/attack_ghost(user as mob)
	if(stat & NOPOWER)
		return

	ui_interact(user)

/obj/machinery/requests_console/attack_hand(user as mob)
	if(..(user))
		return
	ui_interact(user)


/obj/machinery/requests_console/power_change(forced = FALSE)
	. = ..()
	if(.)
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/requests_console/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return

	. += "req_comp[newmessagepriority]"
	underlays += emissive_appearance(icon, "req_comp_lightmask", src)


/obj/machinery/requests_console/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RequestConsole", "[department] Request Console")
		ui.open()

/obj/machinery/requests_console/ui_data(mob/user)
	var/list/data = list()

	data["department"] = department
	data["screen"] = screen
	data["message_log"] = message_log
	data["newmessagepriority"] = newmessagepriority
	data["silent"] = silent
	data["announcementConsole"] = announcementConsole

	data["assist_dept"] = GLOB.req_console_assistance
	data["supply_dept"] = GLOB.req_console_supplies
	data["info_dept"]   = GLOB.req_console_information
	data["ship_dept"]	= GLOB.TAGGERLOCATIONS

	data["message"] = message
	data["recipient"] = recipient
	data["priortiy"] = priority
	data["msgStamped"] = msgStamped
	data["msgVerified"] = msgVerified
	data["announceAuth"] = announceAuth
	data["shipDest"] = ship_tag_name
	data["shipping_log"] = shipping_log

	return data

/obj/machinery/requests_console/ui_act(action, list/params)
	if(..())
		return

	add_fingerprint(usr)

	. = TRUE

	switch(action)
		if("writeInput")
			if(reject_bad_text(params["write"]))
				recipient = params["write"] //write contains the string of the receiving department's name

				var/new_message = tgui_input_text(usr, "Write your message:", "Awaiting Input", encode = FALSE)
				if(isnull(new_message))
					reset_message(FALSE)
					return
				message = new_message
				screen = RCS_MESSAUTH
				switch(params["priority"])
					if(1)
						priority = RQ_NORMALPRIORITY
					if(2)
						priority = RQ_HIGHPRIORITY
					else
						priority = RQ_NONEW_MESSAGES

		if("writeAnnouncement")
			var/new_message = tgui_input_text(usr, "Write your message:", "Awaiting Input", encode = FALSE)
			if(isnull(new_message))
				return
			message = new_message

		if("sendAnnouncement")
			if(!announcementConsole)
				return
			announcement.Announce(message, msg_sanitized = TRUE)
			reset_message(TRUE)

		if("department")
			if(!message)
				return
			var/log_msg = message
			var/pass = FALSE
			screen = RCS_SENTFAIL
			for(var/M in GLOB.message_servers)
				var/obj/machinery/message_server/MS = M
				if(!MS.active)
					continue
				MS.send_rc_message(ckey(params["department"]), department, log_msg, msgStamped, msgVerified, priority)
				pass = TRUE
			if(pass)
				screen = RCS_SENTPASS
				if(recipient in ENGI_ROLES)
					radiochannel = "Engineering"
				else if(recipient in SEC_ROLES)
					radiochannel = "Security"
				else if(recipient in MISC_ROLES)
					radiochannel = "Service"
				else if(recipient in MED_ROLES)
					radiochannel = "Medical"
				else if(recipient in COM_ROLES)
					radiochannel = "Command"
				else if(recipient in SCI_ROLES)
					radiochannel = "Science"
				else if(recipient == RC_AI)
					radiochannel = "AI Private"
				else if(recipient == RC_CARGO_BAY)
					radiochannel = "Supply"
				write_to_message_log("Message sent to [recipient] at [station_time_timestamp()] - [message]")
				Radio.autosay("Alert; a new requests console message received for [recipient] from [department]", null, "[radiochannel]")
			else
				atom_say("Сервер не обнаружен!")

		//Handle screen switching
		if("setScreen")
			// Ensures screen cant be set higher or lower than it should be
			var/tempScreen = round(clamp(text2num(params["setScreen"]), 0, 10), 1)
			if(tempScreen == RCS_ANNOUNCE && !announcementConsole)
				return
			if(tempScreen == RCS_VIEWMSGS)
				for(var/obj/machinery/requests_console/Console in GLOB.allRequestConsoles)
					if(Console.department == department)
						Console.newmessagepriority = RQ_NONEW_MESSAGES
						Console.update_icon(UPDATE_OVERLAYS)
			if(tempScreen == RCS_MAINMENU)
				reset_message()
			screen = tempScreen

		if("shipSelect")
			ship_tag_name = params["shipSelect"]
			ship_tag_index = GLOB.TAGGERLOCATIONS.Find(ship_tag_name)

		//Handle Shipping Label Printing
		if("printLabel")
			var/error_message
			if(!ship_tag_index)
				error_message = "Пожалуйста, выберите пункт назначения."
			else if(!msgVerified)
				error_message = "Пожалуйста, проверьте ID отправителя."
			else if(world.time < print_cooldown)
				error_message = "Пожалуйста, предоставьте принтеру время для подготовки следующей транспортной этикетки."
			if(error_message)
				atom_say("[error_message]")
				return
			print_label(ship_tag_name, ship_tag_index)
			shipping_log += "Shipping Label printed for [ship_tag_name] - [msgVerified]"
			reset_message(TRUE)

		//Handle silencing the console
		if("toggleSilent")
			silent = !silent


/obj/machinery/requests_console/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || inoperable(MAINT))
		return ..()

	if(istype(I, /obj/item/card/id))
		add_fingerprint(user)
		return login_console(screen, I, src)

	if(istype(I, /obj/item/stamp))
		return stamp_messauth(screen, I, src, user)

	return ..()


/obj/machinery/requests_console/proc/stamp_messauth(screen, obj/item/stamp/stamp, obj/ui_object, mob/user, is_distant=FALSE)
	if(screen == RCS_MESSAUTH)
		if(!is_distant)
			add_fingerprint(user)
		msgStamped = "Stamped with the [stamp.name]"
		SStgui.update_uis(ui_object)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ATTACK_CHAIN_PROCEED

/obj/machinery/requests_console/proc/login_console(screen, obj/item/card/id/id, obj/ui_object, mob/user)
	switch(screen)
		if(RCS_MESSAUTH)
			msgVerified = "Verified by [id.registered_name] ([id.assignment])"
			SStgui.update_uis(ui_object)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		if(RCS_ANNOUNCE)
			if(ACCESS_RC_ANNOUNCE in id.GetAccess())
				announceAuth = TRUE
				announcement.announcer = id.assignment ? "[id.assignment] [id.registered_name]" : id.registered_name
				SStgui.update_uis(ui_object)
				return ATTACK_CHAIN_PROCEED_SUCCESS
			reset_message()
			to_chat(user, span_warning("You are not authorized to send announcements."))
			SStgui.update_uis(ui_object)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		if(RCS_SHIPPING)
			msgVerified = "Sender verified as [id.registered_name] ([id.assignment])"
			SStgui.update_uis(ui_object)
			return ATTACK_CHAIN_PROCEED_SUCCESS
	return ATTACK_CHAIN_PROCEED

/obj/machinery/requests_console/proc/reset_message(mainmenu = FALSE)
	message = ""
	recipient = ""
	priority = RQ_NONEW_MESSAGES
	msgVerified = ""
	msgStamped = ""
	announceAuth = FALSE
	announcement.announcer = ""
	ship_tag_name = ""
	ship_tag_index = FALSE
	if(mainmenu)
		screen = RCS_MAINMENU

/obj/machinery/requests_console/proc/createMessage(source, title, message, priority)
	var/linkedSender
	if(istype(source, /obj/machinery/requests_console))
		var/obj/machinery/requests_console/sender = source
		linkedSender = sender.department
	else
		capitalize(source)
		linkedSender = source
	capitalize(title)
	if(newmessagepriority < priority)
		newmessagepriority = priority
		update_icon(UPDATE_OVERLAYS)
	if(!silent)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, TRUE)
		atom_say(title)

	var/rendered_message
	switch(priority)
		if(RQ_HIGHPRIORITY) // High
			rendered_message = "Высокий приоритет - От: [linkedSender] - [message]"
		else // Normal
			rendered_message = "От: [linkedSender] - [message]"

	if(!isnull(rendered_message))
		write_to_message_log(rendered_message, source == ORE_REDEMPTION)


/obj/machinery/requests_console/proc/write_to_message_log(message, ore_message = FALSE)
	for(var/datum/data/pda/app/request_console/app as anything in connected_apps)
		app.on_rc_message_recieved(src, message, ore_message)
	message_log = list(message) + message_log

/obj/machinery/requests_console/proc/print_label(tag_name, tag_index)
	var/obj/item/shippingPackage/sp = new /obj/item/shippingPackage(get_turf(src))
	sp.sortTag = tag_index
	sp.update_appearance(UPDATE_DESC)
	print_cooldown = world.time + 600	//1 minute cooldown before you can print another label, but you can still configure the next one during this time

#undef RQ_NONEW_MESSAGES
#undef RQ_NORMALPRIORITY
#undef RQ_HIGHPRIORITY
