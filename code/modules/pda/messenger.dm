/datum/data/pda/app/messenger
	name = "Messenger"
	icon = "comments-o"
	notify_icon = "comments"
	title = "SpaceMessenger V4.1.0"
	template = "pda_messenger"

	var/toff = 0 //If 1, messenger disabled
	var/list/tnote = list()  //Current Texts
	var/last_text //No text spamming

	var/m_hidden = 0 // Is the PDA hidden from the PDA list?
	var/active_conversation = null // New variable that allows us to only view a single conversation.
	var/list/conversations = list()    // For keeping up with who we have PDA messsages from.

/datum/data/pda/app/messenger/start()
	. = ..()
	unnotify()

/datum/data/pda/app/messenger/update_ui(mob/user as mob, list/data)
	data["silent"] = pda.silent						// does the pda make noise when it receives a message?
	data["toff"] = toff									// is the messenger function turned off?
	// Yes I know convo is awful, but it lets me stay inside the 80 char TGUI line limit
	data["active_convo"] = active_conversation	// Which conversation are we following right now?

	has_back = active_conversation
	if(active_conversation)
		data["messages"] = tnote
		for(var/c in tnote)
			if(c["target"] == active_conversation)
				var/obj/item/pda/device = locateUID(c["target"])
				data["convo_device"] = QDELETED(device) ? "Error#1133: Unable to find UserName." : "[device.owner] ([device.ownjob])"
				break
	else
		var/list/convopdas = list()
		var/list/pdas = list()
		for(var/A in GLOB.PDAs)
			var/obj/item/pda/P = A
			var/datum/data/pda/app/messenger/recipient_messenger = P.find_program(/datum/data/pda/app/messenger)

			if(!P.owner || recipient_messenger.toff || P == pda || recipient_messenger.m_hidden)
				continue
			if(conversations.Find("[P.UID()]"))
				convopdas.Add(list(list("Name" = "[P]", "uid" = "[P.UID()]", "Detonate" = "[P.detonate]", "inconvo" = "1")))
			else
				pdas.Add(list(list("Name" = "[P]", "uid" = "[P.UID()]", "Detonate" = "[P.detonate]", "inconvo" = "0")))

		data["convopdas"] = convopdas
		data["pdas"] = pdas

		var/list/plugins = list()
		if(pda.cartridge)
			for(var/A in pda.cartridge.messenger_plugins)
				var/datum/data/pda/messenger_plugin/P = A
				plugins += list(list(name = P.name, icon = P.icon, uid = "[P.UID()]"))
		data["plugins"] = plugins

		if(pda.cartridge)
			data["charges"] = pda.cartridge.charges ? pda.cartridge.charges : 0

/datum/data/pda/app/messenger/ui_act(action, list/params)
	if(..())
		return

	unnotify()

	var/play_beep = TRUE

	. = TRUE


	switch(action)
		if("Toggle Messenger")
			toff = !toff
		if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
			pda.silent = !pda.silent
		if("Clear")//Clears messages
			if(params["option"] == "All")
				tnote.Cut()
				conversations.Cut()
			if(params["option"] == "Convo")
				var/list/new_tnote = list()
				for(var/i in tnote)
					if(i["target"] != active_conversation)
						new_tnote[++new_tnote.len] = i
				tnote = new_tnote
				conversations.Remove(active_conversation)

			active_conversation = null
		if("Message")
			play_beep = FALSE
			var/obj/item/pda/target_pda = locateUID(params["target"])
			create_message(target_pda, usr)
			if(params["target"] in conversations)            // Need to make sure the message went through, if not welp.
				active_conversation = params["target"]
		if("Select Conversation")
			var/P = params["target"]
			for(var/n in conversations)
				if(P == n)
					active_conversation = P
		if("Messenger Plugin")
			if(!params["target"] || !params["plugin"])
				return

			var/obj/item/pda/P = locateUID(params["target"])
			if(!P)
				to_chat(usr, "PDA not found.")

			var/datum/data/pda/messenger_plugin/plugin = locateUID(params["plugin"])
			if(plugin && (plugin in pda.cartridge.messenger_plugins))
				plugin.messenger = src
				plugin.user_act(usr, P)
		if("Back")
			active_conversation = null

	if(play_beep && !pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)


// If there is no sender, will ignore cheks for sender.
/datum/data/pda/app/messenger/proc/create_message(obj/item/pda/recipient_pda, mob/living/sender, message)
	if(!message)
		message = tgui_input_text(sender, "Введите сообщение", name)

	if(!message || !istype(recipient_pda))
		return

	if(sender && !in_range(pda, sender) && pda.loc != sender)
		return

	var/datum/data/pda/app/messenger/recipient_messenger = recipient_pda.find_program(/datum/data/pda/app/messenger)

	if(!recipient_messenger || recipient_messenger.toff || toff)
		return

	if(last_text && world.time < last_text + 5)
		return

	if(sender && !pda.can_use(sender))
		return

	last_text = world.time
	// check if telecomms I/O route 1459 is stable
	//var/telecomms_intact = telecomms_process(recipient_pda.owner, owner, message)
	var/obj/machinery/message_server/useMS = find_pda_server()
	if(!can_send_message(message, sender, recipient_pda, useMS))
		return

	useMS.send_pda_message("[recipient_pda.owner]","[pda.owner]","[message]")
	tnote.Add(list(list("sent" = 1, "message" = "[html_decode(message)]", "target" = "[recipient_pda.UID()]")))
	recipient_messenger.tnote.Add(list(list("sent" = 0, "message" = "[html_decode(message)]", "target" = "[pda.UID()]")))
	show_message_to_ghosts(pda, recipient_pda, message)

	if(!conversations.Find("[recipient_pda.UID()]"))
		conversations.Add("[recipient_pda.UID()]")

	if(!recipient_messenger.conversations.Find("[pda.UID()]"))
		recipient_messenger.conversations.Add("[pda.UID()]")

	SStgui.update_uis(src)
	recipient_messenger.notify("[span_bold("Новое сообщение! Отправитель: [pda.owner][pda.ownjob ? " ([pda.ownjob])" : ""], ")]\"[message]\" (<a href='byond://?src=[recipient_messenger.UID()];choice=Message;target=[pda.UID()]'>Ответить</a>)")
	to_chat(sender, "[bicon(pda)] [span_bold("Новое сообщение. Получатель: [recipient_pda.owner][recipient_pda.ownjob ? " ([recipient_pda.ownjob])" : ""], ")]\"[message]\" (<a href='byond://?src=[UID()];choice=Message;target=[recipient_pda.UID()]'>Отправить ещё сообщение</a>)")

	log_pda_message(message, sender, pda, recipient_pda)
	if(pda.silent)
		return

	playsound(pda, 'sound/machines/terminal_success.ogg', 15, TRUE)


/datum/data/pda/app/messenger/proc/show_message_to_ghosts(obj/item/pda/pda, obj/item/pda/recipient_pda, message)
	for(var/mob/mob as anything in GLOB.dead_mob_list)
		if(!isobserver(mob) || !mob.client || !HASBIT(mob.client.prefs.toggles, PREFTOGGLE_CHAT_GHOSTPDA))
			continue

		var/ghost_message = "[span_name("[pda.owner]")] ([ghost_follow_link(pda, ghost = mob)]) [span_gamesay("Сообщение на КПК")] --> [span_name("[recipient_pda.owner]")] ([ghost_follow_link(recipient_pda, ghost = mob)]): [span_message("[message]")]"
		to_chat(mob, "[ghost_message]")


/datum/data/pda/app/messenger/proc/can_send_message(message, sender, recipient_pda, useMS)
	var/turf/sender_pos = sender ? get_turf(sender) : null
	var/turf/recipient_pos = get_turf(recipient_pda)

	// Can the message be sent
	var/sendable = FALSE
	// Can the message be received?
	var/receivable = FALSE

	for(var/obj/machinery/tcomms/core/core in GLOB.tcomms_machines)
		if(!sender || core.zlevel_reachable(sender_pos.z))
			sendable = TRUE

		if(core.zlevel_reachable(recipient_pos.z))
			receivable = TRUE

		// Once both are done, exit the loop
		if(sendable && receivable)
			break

	if(!sendable) // Are we in the range of a receiver?
		to_chat(sender, span_warning("ОШИБКА: Нет связи с сервером."))
		if(pda.silent)
			return

		playsound(pda, 'sound/machines/terminal_error.ogg', 15, TRUE)
		return

	if(!receivable) // Is our recipient in the range of a receiver?
		to_chat(sender, span_warning("ОШИБКА: Нет связи с получателем."))
		if(pda.silent)
			return

		playsound(pda, 'sound/machines/terminal_error.ogg', 15, TRUE)
		return

	if(!useMS || !sendable || !receivable) // only send the message if its going to work
		to_chat(sender, span_warning("ОШИБКА: Сервер не отвечает."))
		if(pda.silent)
			return

		playsound(pda, 'sound/machines/terminal_error.ogg', 15, TRUE)
		return

	return TRUE


/datum/data/pda/app/messenger/proc/log_pda_message(message, sender, pda, atom/recipient_pda)
	log_pda("(PDA: [name]) sent \"[message]\" to [recipient_pda.name]", sender)
	var/log_message = "sent PDA message \"[message]\" using [pda]"
	var/receiver
	if(ishuman(recipient_pda.loc))
		receiver = recipient_pda.loc
		log_message = "[log_message] to [recipient_pda]"
	else
		receiver = recipient_pda
		log_message = "[log_message] (no holder)"

	add_misc_logs(sender, log_message, receiver)


/datum/data/pda/app/messenger/proc/available_pdas()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if(toff)
		to_chat(usr, "Turn on your receiver in order to send messages.")
		return

	for(var/A in GLOB.PDAs)
		var/obj/item/pda/P = A
		var/datum/data/pda/app/messenger/recipient_messenger = P.find_program(/datum/data/pda/app/messenger)

		if(!P.owner || !recipient_messenger || recipient_messenger.hidden || P == pda || recipient_messenger.toff)
			continue

		var/name = P.owner
		if(name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P
	return plist

/datum/data/pda/app/messenger/proc/can_receive()
	return pda.owner && !toff && !hidden

// Handler for the in-chat reply button
/datum/data/pda/app/messenger/Topic(href, href_list)
	if(!pda.can_use(usr))
		return
	unnotify()
	switch(href_list["choice"])
		if("Message")
			var/obj/item/pda/target_pda = locateUID(href_list["target"])
			create_message(target_pda, usr)
			if(href_list["target"] in conversations)            // Need to make sure the message went through, if not welp.
				active_conversation = href_list["target"]
