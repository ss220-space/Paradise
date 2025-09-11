GLOBAL_LIST_EMPTY(allfaxes)
GLOBAL_LIST_INIT(admin_departments, list("Central Command"))
GLOBAL_LIST_INIT(hidden_admin_departments, list("Syndicate"))
GLOBAL_LIST_INIT(hidden_ussp, list("USSP Central Committee"))
GLOBAL_LIST_EMPTY(alldepartments)
GLOBAL_LIST_EMPTY(hidden_departments)
GLOBAL_LIST_EMPTY(fax_blacklist)

/obj/machinery/photocopier/faxmachine
	name = "fax machine"
	desc = "Небольшая машинка для работы с факсами. Не смотря на свой размер, обладает большой силой."
	icon = 'icons/obj/library.dmi'
	icon_state = "fax"
	insert_anim = "faxsend"
	pass_flags = PASSTABLE
	pixel_y = 2
	var/fax_network = "Локальная Факсимильная сеть"
	/// If true, prevents fax machine from sending messages to NT machines
	var/syndie_restricted = FALSE
	var/ussp_restricted = FALSE
	/// Can we send messages off-station?
	var/long_range_enabled = FALSE
	req_access = list(ACCESS_LAWYER, ACCESS_HEADS, ACCESS_ARMORY)

	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200

	/// ID card inserted into the machine, used to log in with
	var/obj/item/card/id/scan = null

	/// Whether the machine is "logged in" or not
	var/authenticated = FALSE
	/// Next world.time at which this fax machine can send a message to CC/syndicate
	var/sendcooldown = 0
	/// After sending a message to CC/syndicate, cannot send another to them for this many deciseconds
	var/cooldown_time = 1800
	/// After sending a message to local faxes, cannot send another to them for this many deciseconds
	var/cooldown_time_local = 50

	/// Our department, determines whether this machine gets faxes sent to a department
	var/department = UNKNOWN_STATUS_RUS

	/// Target department to send outgoing faxes to
	var/destination

/obj/machinery/photocopier/faxmachine/get_ru_names()
	return list(
		NOMINATIVE = "факс",
		GENITIVE = "факса",
		DATIVE = "факсу",
		ACCUSATIVE = "факс",
		INSTRUMENTAL = "факсом",
		PREPOSITIONAL = "факсе"
	)

/obj/machinery/photocopier/faxmachine/New()
	..()
	GLOB.allfaxes += src
	update_network()

/obj/machinery/photocopier/faxmachine/proc/update_network()
	if(department != UNKNOWN_STATUS_RUS)
		if(!(("[department]" in GLOB.alldepartments) || ("[department]" in GLOB.hidden_departments) || ("[department]" in GLOB.admin_departments) || ("[department]" in GLOB.hidden_admin_departments) || ("[department]" in GLOB.hidden_ussp)))
			GLOB.alldepartments |= department

/obj/machinery/photocopier/faxmachine/longrange
	name = "long range fax machine"
	fax_network = "Блюспейс факсимильная сеть Центрального Командования"
	long_range_enabled = TRUE

/obj/machinery/photocopier/faxmachine/longrange/syndie
	name = "syndicate long range fax machine"
	emagged = TRUE
	syndie_restricted = TRUE
	req_access = list(ACCESS_SYNDICATE)
	//No point setting fax network, being emagged overrides that anyway.

/obj/machinery/photocopier/faxmachine/longrange/syndie/update_network()
	if(department != UNKNOWN_STATUS_RUS)
		GLOB.hidden_departments |= department

/obj/machinery/photocopier/faxmachine/longrange/ussp
	name = "USSP long range fax machine"
	fax_network = "Блюспейс факсимильная сеть СССП"
	ussp_restricted = TRUE
	req_access = list(ACCESS_USSP_MARINE_CAPTAIN)
	idle_power_usage = 60
	active_power_usage = 300

/obj/machinery/photocopier/faxmachine/longrange/ussp/update_network()
	if(department != UNKNOWN_STATUS_RUS)
		GLOB.hidden_ussp |= department

/obj/machinery/photocopier/faxmachine/attack_hand(mob/user)
	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/photocopier/faxmachine/attack_ghost(mob/user)
	ui_interact(user)


/obj/machinery/photocopier/faxmachine/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/card/id))
		add_fingerprint(user)
		if(scan)
			balloon_alert(user, "занято!")
			return ATTACK_CHAIN_PROCEED
		if(!scan(I))
			return ..()
		balloon_alert(user, "вставлено")
		return ATTACK_CHAIN_BLOCKED_ALL
	..()
	if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo) || istype(I, /obj/item/paper_bundle))
		usr.drop_transfer_item_to_loc(I, src)
		copyitem = I
		playsound(loc, 'sound/machines/fax_send.ogg', 50, FALSE)
		to_chat(usr, span_notice("Вы вставляете [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
		flick(insert_anim, src)
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/photocopier/faxmachine/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = 1
		req_access = list()
		if(user)
			to_chat(user, span_notice("Передатчики настраиваются на неизвестный источник!"))
			balloon_alert(user, "взломано")
			playsound(loc, 'sound/machines/fax_emag.ogg', 50, FALSE)
	else if(user)
		balloon_alert(user, "уже взломано!")

/obj/machinery/photocopier/faxmachine/proc/is_authenticated(mob/user)
	if(authenticated)
		return TRUE
	else if(user.can_admin_interact())
		return TRUE
	return FALSE

/obj/machinery/photocopier/faxmachine/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FaxMachine", "Факсимальный аппарат")
		ui.open()

/obj/machinery/photocopier/faxmachine/ui_data(mob/user)
	var/list/data = list()
	data["authenticated"] = is_authenticated(user)
	data["scan_name"] = scan ? scan.name : FALSE
	if(!data["authenticated"])
		data["network"] = "Отключено"
	else if(!emagged)
		data["network"] = fax_network
	else
		data["network"] = "ОШИ*?*%!*"
	data["paper"] = copyitem ? copyitem.name : FALSE
	data["paperinserted"] = copyitem ? TRUE : FALSE
	data["destination"] = destination ? destination : FALSE
	data["sendError"] = FALSE
	if(stat & (BROKEN|NOPOWER))
		data["sendError"] = "Нет питания"
	else if(!data["authenticated"])
		data["sendError"] = "Вход не выпонен"
	else if(!data["paper"])
		data["sendError"] = "Факс пуст"
	else if(!data["destination"])
		data["sendError"] = "Место доставки не установлено"
	else
		var/cooldown_seconds = cooldown_seconds()
		if(cooldown_seconds)
			data["sendError"] = "Перенастройка через [cooldown_seconds] секунд[numeric_ending(cooldown_seconds, "", "у", "ы")]"
	return data


/obj/machinery/photocopier/faxmachine/ui_act(action, params)
	if(..())
		return

	// Do not let click buttons if you're ghost unless you're an admin.
	if (isobserver(usr) && !is_admin(usr))
		return FALSE

	var/is_authenticated = is_authenticated(usr)
	. = TRUE
	switch(action)
		if("scan") // insert/remove your ID card
			scan()
		if("auth") // log in/out
			if(!is_authenticated && scan)
				if(scan.registered_name in GLOB.fax_blacklist)
					atom_say("Вход не выполнен: пользователь занесён в чёрный список факсимильной сети.", FALSE)
					playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
					. = FALSE
				else if(check_access(scan))
					authenticated = TRUE
				else // ID doesn't have access to this machine
					atom_say("Вход не выполнен: ID-карта не обладает необходимым досутпом.", FALSE)
					playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
					. = FALSE
			else if(is_authenticated)
				authenticated = FALSE
		if("paper") // insert/eject paper/paperbundle/photo
			if(copyitem)
				copyitem.forceMove(get_turf(src))
				if(ishuman(usr))
					if(Adjacent(usr))
						usr.put_in_hands(copyitem, ignore_anim = FALSE)
				to_chat(usr, span_notice("Вы достаёте [copyitem.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]."))
				copyitem = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo) || istype(I, /obj/item/paper_bundle))
					usr.drop_transfer_item_to_loc(I, src)
					copyitem = I
					playsound(loc, 'sound/machines/fax_send.ogg', 50, FALSE)
					to_chat(usr, span_notice("Вы вставляете [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
					flick(insert_anim, src)
				else
					to_chat(usr, span_warning("[capitalize(declent_ru(NOMINATIVE))] может принять только бумагу, фото и их стопки."))
					. = FALSE
		if("rename") // rename the item that is currently in the fax machine
			if(copyitem)
				var/n_name = tgui_input_text(usr, "Как вы хотите подписать факс?", "Подпись факса:", copyitem.name)
				if(!n_name)
					return
				if((copyitem && copyitem.loc == src && usr.stat == 0))
					if(istype(copyitem, /obj/item/paper))
						copyitem.name = "[(n_name ? text("[n_name]") : initial(copyitem.name))]"
						copyitem.desc = "Бумага, подписанная как \"" + copyitem.name + "\"."
						if(ru_names)
							ru_names[NOMINATIVE] = "\"[copyitem.name]\""
							ru_names[GENITIVE] = "\"[copyitem.name]\""
							ru_names[DATIVE] = "\"[copyitem.name]\""
							ru_names[ACCUSATIVE] = "\"[copyitem.name]\""
							ru_names[INSTRUMENTAL] = "\"[copyitem.name]\""
							ru_names[PREPOSITIONAL] = "\"[copyitem.name]\""
					else if(istype(copyitem, /obj/item/photo))
						copyitem.name = "[(n_name ? text("[n_name]") : "photo")]"
					else if(istype(copyitem, /obj/item/paper_bundle))
						copyitem.name = "[(n_name ? text("[n_name]") : "paper")]"
					else
						. = FALSE
				else
					. = FALSE
			else
				. = FALSE
		if("dept") // choose which department receives the fax
			if(is_authenticated)
				var/lastdestination = destination
				var/list/combineddepartments = GLOB.alldepartments.Copy()
				if(long_range_enabled)
					combineddepartments += GLOB.admin_departments.Copy()
					if(z == level_name_to_num(CENTCOMM))
						for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
							if(F.ussp_restricted)
								combineddepartments |= F.department
				if(emagged)
					combineddepartments += GLOB.hidden_admin_departments.Copy()
					combineddepartments += GLOB.hidden_departments.Copy()
				if(syndie_restricted)
					combineddepartments = GLOB.hidden_admin_departments.Copy()
					combineddepartments += GLOB.hidden_departments.Copy()
					for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
						if(F.emagged)//we can contact emagged faxes on the station
							combineddepartments |= F.department
				if(ussp_restricted)
					combineddepartments = GLOB.hidden_ussp.Copy()
					for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
						if(F.ussp_restricted)
							combineddepartments |= F.department
				destination = tgui_input_list(usr, "В какой отдел отправить?", "Выберите отдел:", combineddepartments)
				if(!destination)
					destination = lastdestination
		if("send") // actually send the fax
			if(!copyitem || !is_authenticated || !destination)
				return
			if(stat & (BROKEN|NOPOWER))
				return

			var/cooldown_seconds = cooldown_seconds()
			if(cooldown_seconds > 0)
				playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
				to_chat(usr, span_warning("[capitalize(declent_ru(NOMINATIVE))] не сможет работать ещё [cooldown_seconds] секунд[numeric_ending(cooldown_seconds, "", "а", "ы")]."))
				return

			if((destination in GLOB.admin_departments) || (destination in GLOB.hidden_admin_departments) || (destination in GLOB.hidden_ussp))
				sendcooldown = world.time + cooldown_time
				SStgui.update_uis(src)
				send_admin_fax(usr, destination)
			else
				sendcooldown = world.time + cooldown_time_local
				SStgui.update_uis(src)
				sendfax(destination, usr)
	if(.)
		add_fingerprint(usr)


/obj/machinery/photocopier/faxmachine/proc/scan(obj/item/card/id/card)
	if(scan) // Card is in machine
		if(ishuman(usr))
			scan.forceMove(drop_location())
			if(Adjacent(usr))
				usr.put_in_hands(scan, ignore_anim = FALSE)
			scan = null
			SStgui.update_uis(src)
			return TRUE
		scan.forceMove(drop_location())
		scan = null
		SStgui.update_uis(src)
		return TRUE
	if(!usr || !Adjacent(usr))
		return FALSE
	if(!card)
		var/obj/item/I = usr.get_active_hand()
		if(!istype(I, /obj/item/card/id))
			return FALSE
		if(!usr.drop_transfer_item_to_loc(I, src))
			return FALSE
		scan = I
		SStgui.update_uis(src)
		return TRUE
	if(!istype(card))
		return FALSE
	if(!usr.drop_transfer_item_to_loc(card, src))
		return FALSE
	scan = card
	SStgui.update_uis(src)
	return TRUE


/obj/machinery/photocopier/faxmachine/verb/eject_id()
	set name = "Достать ID-карту"
	set src in oview(1)

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(scan)
		to_chat(usr, "Вы вынимаете [scan.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)].")
		scan.forceMove(get_turf(src))
		if(Adjacent(usr))
			usr.put_in_hands(scan, ignore_anim = FALSE)
		scan = null
	else
		balloon_alert(usr, "нечего достать!")

/obj/machinery/photocopier/faxmachine/proc/sendfax(destination, mob/sender)
	use_power(active_power_usage)
	var/success = 0
	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if(F.department == destination)
			success = F.receivefax(copyitem)
	if(success)
		var/datum/fax/F = new /datum/fax()
		F.name = copyitem.name
		F.from_department = department
		F.to_department = destination
		F.origin = src
		F.message = copyitem
		F.sent_by = sender
		F.sent_at = world.time

		atom_say("Сообщение успешно отправлено.", FALSE)
		playsound(src, 'sound/machines/ping.ogg', 50)
	else
		atom_say("При отправке сообщения произошла ошибка.", FALSE)

/obj/machinery/photocopier/faxmachine/proc/receivefax(obj/item/incoming)
	if(stat & (BROKEN|NOPOWER))
		return FALSE

	if(department == UNKNOWN_STATUS_RUS)
		return FALSE //You can't send faxes to "Unknown"

	flick("faxreceive", src)
	playsound(loc, 'sound/machines/fax_recieve.ogg', 50, TRUE)

	// give the sprite some time to flick
	sleep(20)

	if(istype(incoming, /obj/item/paper))
		papercopy(incoming)
	else if(istype(incoming, /obj/item/photo))
		photocopy(incoming)
	else if(istype(incoming, /obj/item/paper_bundle))
		bundlecopy(incoming)
	else
		return FALSE

	use_power(active_power_usage)
	return TRUE

/obj/machinery/photocopier/faxmachine/proc/send_admin_fax(mob/sender, destination)
	use_power(active_power_usage)

	if(!(istype(copyitem, /obj/item/paper) || istype(copyitem, /obj/item/paper_bundle) || istype(copyitem, /obj/item/photo)))
		atom_say("При отправке сообщения произошла ошибка.", FALSE)
		return

	var/datum/fax/admin/A = new /datum/fax/admin()
	A.name = copyitem.name
	A.from_department = department
	A.to_department = destination
	A.origin = src
	A.message = copyitem
	A.sent_by = sender
	A.sent_at = world.time

	//message badmins that a fax has arrived
	switch(destination)
		if("Central Command")
			message_admins(sender, "CENTCOM FAX", destination, copyitem, "#006100")
		if("Syndicate")
			message_admins(sender, "SYNDICATE FAX", destination, copyitem, "#DC143C")
		if("USSP Central Committee")
			message_admins(sender, "USSP FAX", destination, copyitem, "#b60226")
	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if(F.department == destination)
			F.receivefax(copyitem)
	atom_say("Сообщение успешно отправлено.", FALSE)
	playsound(src, 'sound/machines/ping.ogg', 50)

/obj/machinery/photocopier/faxmachine/proc/cooldown_seconds()
	if(sendcooldown < world.time)
		return 0
	return round((sendcooldown - world.time) / 10)

/obj/machinery/photocopier/faxmachine/proc/message_admins(mob/sender, faxname, faxtype, obj/item/sent, font_colour="#9A04D1")
	var/msg = "<span class='boldnotice'><span style='color: [font_colour];>[faxname]: </span> [key_name_admin(sender)] | REPLY: (<a href='byond://?_src_=holder;[faxname == "SYNDICATE FAX" ? "SyndicateReply" : ""]=[sender.UID()][faxname == "USSP FAX" ? "USSPReply" : ""]=[sender.UID()][faxname == "CENTCOM FAX" ? "CentcommReply" : ""]=[sender.UID()]'>RADIO</a>) (<a href='byond://?_src_=holder;AdminFaxCreate=\ref[sender];originfax=\ref[src];faxtype=[faxtype];replyto=\ref[sent]'>FAX</a>) ([ADMIN_SM(sender,"SM")]) | REJECT: (<a href='byond://?_src_=holder;FaxReplyTemplate=[sender.UID()];originfax=\ref[src]'>TEMPLATE</a>) ([ADMIN_BSA(sender,"BSA")]) (<a href='byond://?_src_=holder;EvilFax=[sender.UID()];originfax=\ref[src]'>EVILFAX</a>) </span>: Receiving '[sent.name]' via secure connection... <a href='byond://?_src_=holder;AdminFaxView=\ref[sent]'>view message</a>"
	var/fax_sound = sound('sound/effects/adminhelp.ogg')
	for(var/client/C in GLOB.admins)
		if(check_rights(R_EVENT, 0, C.mob))
			to_chat(C, msg)
			if(C.prefs.sound & SOUND_ADMINHELP)
				SEND_SOUND(C, fax_sound)

	var/datum/discord_webhook_payload/payload = new()
	if(istype(sent, /obj/item/paper))
		var/obj/item/paper/P = sent
		var/data = sanitize_paper(P)
		var/datum/discord_embed/embed = new()
		embed.embed_title = P.name
		embed.embed_content = data
		embed.embed_colour = replacetext(font_colour, "#", "")
		payload.embeds += embed
		payload.webhook_content = "**\[FAX\]** [sender.client.ckey]/([sender.name]) sent a Paper Fax at [get_area(src)]"
		SSdiscord.send2discord_complex(DISCORD_WEBHOOK_REQUESTS, payload)
	else if(istype(sent, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/bundle = sent
		for(var/obj/item/paper/P in bundle)
			var/datum/discord_embed/embed = new()
			embed.embed_title = P.name
			embed.embed_colour = replacetext(font_colour, "#", "")
			embed.embed_content = sanitize_paper(P)
			payload.embeds += embed
		for(var/obj/item/photo/P in bundle)
			var/datum/discord_embed/embed = new()
			embed.embed_title = P.name
			embed.embed_colour = replacetext(font_colour, "#", "")
			embed.embed_content = P.log_text
			payload.embeds += embed
		payload.webhook_content = "**\[FAX\]** [sender.client.ckey]/([sender.name]) sent a Bundle Fax at [get_area(src)]"
		SSdiscord.send2discord_complex(DISCORD_WEBHOOK_REQUESTS, payload)
	else if(istype(sent, /obj/item/photo))
		var/obj/item/photo/P = sent
		var/datum/discord_embed/embed = new()
		embed.embed_title = P.name
		embed.embed_colour = font_colour
		embed.embed_content = P.log_text
		payload.embeds += embed
		payload.webhook_content = "**\[FAX\]** [sender.client.ckey]/([sender.name]) sent a Photo at [get_area(src)]"
		SSdiscord.send2discord_complex(DISCORD_WEBHOOK_REQUESTS, payload)

/obj/machinery/photocopier/faxmachine/proc/sanitize_paper(obj/item/paper/paper) // html to discord markdown-101
	var/text = "[paper.header][paper.info][paper.footer]"
	text = replacetext(text, "<br>", "\n")
	text = replacetext(text, "</u>", "__")
	text = replacetext(text, "<b>", "**")
	text = replacetext(text, "</b>", "**")
	text = replacetext(text, "<i>", "*")
	text = replacetext(text, "</i>", "*")
	text = replacetext(text, "<u>", "__")
	text = replacetext(text, "</u>", "__")
	text = replacetext(text, "<span class=\"paper_field\"></span>", "`_FIELD_`")

	text = replacetext(text, "<h1>", "# ")
	text = replacetext(text, "<H2>", "## ")
	text = replacetext(text, "<H3>", "### ")

	text = replacetext(text, "<li>", "- ")
	text = replacetext(text, "<hr>", "\n`----- Horizontal Rule -----`\n")
	text = replacetext(text, "<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>", "`_TABLE START_`\n")
	text = replacetext(text, "<table>", "`_GRID START_`\n")
	text = replacetext(text, "<tr>", "\n") // starts table, \ns it when splits every cell with |
	text = replacetext(text, "<td>", " | ")
	text = replacetext(text, "<table>", "`_TABLE END_`\n")
	text = replacetext(text, "<img src = ntlogo.png>", "` NT LOGO `\n")
	text = replacetext(text, "<img src = syndielogo.png>", "` SYNDIE LOGO `\n")
	text = replacetextEx(text, "<img src = syndielogo.png>", "` SYNDIE LOGO `\n")
	var/textstamps = paper.stamps
	for(var/obj/item/stamp/stamp_path as anything in paper.stamped)
		if(ispath(stamp_path, /obj/item/stamp/chameleon))
			var/text_stamp = replacetext(textstamps, regex(".*?<img src=large_stamp-(.*?).png>.*"), "$1") // pops from textstamps.
			textstamps = replacetext(textstamps, regex("<img src=large_stamp-.*?.png>"), "")
			text += "` [text_stamp] (CHAMELEON) stamp `"
		else
			text += "` [replacetext(replacetext(initial(stamp_path.name), "rubber", ""), "'s", "")] `"

	return strip_html_properly(text, MAX_PAPER_MESSAGE_LEN, TRUE) //So satisfying that max paper length equals max description disorcd

/obj/machinery/photocopier/faxmachine/proc/become_mimic()
	if(scan)
		scan.forceMove(get_turf(src))
	var/mob/living/simple_animal/hostile/mimic/copy/M = new(loc, src, null, 1) // it will delete src on creation and override any machine checks
	M.name = "angry fax machine"
