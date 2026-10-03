GLOBAL_VAR_INIT(normal_ooc_colour, "#275FC5")
GLOBAL_VAR_INIT(member_ooc_colour, "#035417")
GLOBAL_VAR_INIT(devs_ooc_colour, "#129c00")
GLOBAL_VAR_INIT(mentor_ooc_colour, "#00B0EB")
GLOBAL_VAR_INIT(moderator_ooc_colour, "#184880")
GLOBAL_VAR_INIT(admin_ooc_colour, "#b82e00")

GAME_VERB(/client, ooc, VERB_OOC, VERB_CATEGORY_OOC)
	VERB_ARG(msg, VERB_ARG_TYPE_TEXT, VERB_ARG_SOURCE_INPUT)
	if(!mob)
		return
	if(is_guest_key(key))
		to_chat(src, span_danger("Guests may not use OOC."), MESSAGE_TYPE_WARNING, confidential = TRUE)
		return

	if(!check_rights(R_ADMIN|R_MOD, FALSE))
		if(!CONFIG_GET(flag/ooc_allowed))
			to_chat(src, span_danger("OOC is globally muted."), MESSAGE_TYPE_WARNING, confidential = TRUE)
			return
		if(!CONFIG_GET(flag/dooc_allowed) && (mob.stat == DEAD))
			to_chat(usr, span_danger("OOC for dead mobs has been turned off."), MESSAGE_TYPE_WARNING, confidential = TRUE)
			return
		if(check_mute(ckey, MUTE_OOC))
			to_chat(src, span_danger("You cannot use OOC (muted)."), MESSAGE_TYPE_WARNING, confidential = TRUE)
			return

	if(!msg)
		msg = typing_input(src.mob, "", "ooc \"text\"")

	msg = trim(sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN)))

	if(!msg)
		return

	if(!(prefs.toggles & PREFTOGGLE_CHAT_OOC))
		to_chat(src, span_danger("You have OOC muted."))
		return

	if(!check_rights(R_ADMIN|R_MOD, FALSE))
		if(!CONFIG_GET(flag/ooc_allowed))
			to_chat(src, span_danger("OOC is globally muted."))
			return
		if(handle_spam_prevention(msg, MUTE_OOC, OOC_COOLDOWN))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<b>Advertising other servers is not allowed.</b>")
			log_admin("[key_name_log(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return
		if(findtext(msg, "https://") || findtext(msg, "http://"))
			if(!findtext(msg, "ss220.space"))
				to_chat(src, "<b>Advertising other sites is not allowed.</b>")
				log_admin("[key_name_log(src)] has attempted to advertise in OOC: [msg]")
				message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
				return

	msg = handle_emojis(msg)

	add_ooc_logs(src, msg)

	var/display_colour = GLOB.normal_ooc_colour
	if(holder && !holder.fakekey)
		display_colour = GLOB.mentor_ooc_colour
		if(check_rights(R_MOD, FALSE) && !check_rights(R_ADMIN, FALSE))
			display_colour = GLOB.moderator_ooc_colour
		else if(check_rights(R_ADMIN, FALSE))
			if(CONFIG_GET(flag/allow_admin_ooccolor))
				display_colour = src.prefs.ooccolor
			else
				display_colour = GLOB.admin_ooc_colour
		else if(check_rights(R_VIEWRUNTIMES, FALSE))
			display_colour = GLOB.devs_ooc_colour

	if(prefs.unlock_content)
		if(display_colour == GLOB.normal_ooc_colour)
			if(prefs.toggles & PREFTOGGLE_MEMBER_PUBLIC)
				display_colour = GLOB.member_ooc_colour

	for(var/client/C in GLOB.clients)
		if(C.prefs.toggles & PREFTOGGLE_CHAT_OOC)
			var/display_name = key
			var/list/key_tags
			var/key_prefix = ""
			var/visible_unlock = prefs.unlock_content && (prefs.toggles & PREFTOGGLE_MEMBER_PUBLIC)
			if(visible_unlock)
				LAZYADD(key_tags, "byond_member")

			if(donator_level > 0 && prefs.toggles & PREFTOGGLE_DONATOR_PUBLIC)
				LAZYADD(key_tags, "donator")

			if(LAZYLEN(key_tags))
				var/datum/asset/spritesheet_batched/chat/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
				for(var/icon_name in key_tags)
					key_prefix = "[key_prefix][sheet.icon_tag(icon_name)]"
			key_prefix = "<span style='vertical-align: text-top; padding-right: 0.2em'>[key_prefix]</span>"

			display_name = "[key_prefix][display_name]"

			if(holder)
				if(holder.fakekey)
					if(C.holder && C.holder.rights & R_ADMIN)
						display_name = "[holder.fakekey]/([key])"
					else
						display_name = holder.fakekey

			if(!CONFIG_GET(flag/disable_ooc_emoji))
				msg = span_emojienabled("[msg]")
			to_chat(C, span_ooc("<span style='color:[display_colour];'>[span_prefix("OOC: ")]<em>[display_name]:</em> [span_message(msg)]</span>"))

/proc/toggle_ooc()
	CONFIG_SET(flag/ooc_allowed, !CONFIG_GET(flag/ooc_allowed))
	if(CONFIG_GET(flag/ooc_allowed))
		to_chat(world, span_bold("Канал OOC стал доступен всем!"))
		log_and_message_admins("OOC was toggled on automatically.")
	else
		to_chat(world, span_bold("Канал OOC отключён для всех!"))
		log_and_message_admins("OOC was toggled off automatically.")

/proc/auto_toggle_ooc(on)
	if(CONFIG_GET(flag/auto_toggle_ooc_during_round) && CONFIG_GET(flag/ooc_allowed) != on)
		toggle_ooc()

GAME_VERB_DESC(/client, looc, VERB_LOOC, "Local OOC, seen only by those in view.", VERB_CATEGORY_OOC)
	VERB_ARG(msg, VERB_ARG_TYPE_TEXT, VERB_ARG_SOURCE_INPUT)

	if(!mob)
		return
	if(is_guest_key(key))
		to_chat(src, span_danger("Guests may not use LOOC."), MESSAGE_TYPE_WARNING, confidential = TRUE)
		return

	if(!check_rights(R_ADMIN|R_MOD, FALSE))
		if(!CONFIG_GET(flag/looc_allowed))
			to_chat(src, span_danger("LOOC is globally muted."), MESSAGE_TYPE_WARNING, confidential = TRUE)
			return
		if(!CONFIG_GET(flag/dooc_allowed) && (mob.stat == DEAD))
			to_chat(usr, span_danger("LOOC for dead mobs has been turned off."), MESSAGE_TYPE_WARNING, confidential = TRUE)
			return
		if(check_mute(ckey, MUTE_OOC))
			to_chat(src, span_danger("You cannot use LOOC (muted)."), MESSAGE_TYPE_WARNING, confidential = TRUE)
			return

	if(!msg)
		msg = typing_input(src.mob, "Local OOC, seen only by those in view.", "looc \"text\"")

	msg = trim(sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN)))
	if(!msg)
		return

	if(!(prefs.toggles & PREFTOGGLE_CHAT_LOOC))
		to_chat(src, span_danger("You have LOOC muted."))
		return

	if(!check_rights(R_ADMIN|R_MOD, FALSE))
		if(handle_spam_prevention(msg, MUTE_OOC, OOC_COOLDOWN))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<b>Advertising other servers is not allowed.</b>")
			log_admin("[key_name_log(src)] has attempted to advertise in LOOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in LOOC: [msg]")
			return
		if(findtext(msg, "https://") || findtext(msg, "http://"))
			if(!findtext(msg, "ss220.space"))
				to_chat(src, "<b>Advertising other sites is not allowed.</b>")
				log_admin("[key_name_log(src)] has attempted to advertise in OOC: [msg]")
				message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
				return

	var/msg_runechat = msg
	msg = handle_emojis(msg)

	add_ooc_logs(src, msg, TRUE)

	var/mob/source = mob.get_looc_source()
	var/list/heard = get_hearers_in_view(7, source)

	var/display_name = key
	if(holder?.fakekey)
		display_name = holder.fakekey
	if(mob.stat != DEAD)
		display_name = mob.name

	for(var/client/target in GLOB.clients)
		if(target.prefs.toggles & PREFTOGGLE_CHAT_LOOC)
			var/prefix = ""
			var/admin_stuff = ""
			var/send = 0

			if(target in GLOB.admins)
				if(check_rights(R_ADMIN|R_MOD, FALSE, target.mob))
					admin_stuff += "/([key])"
					if(target != src)
						admin_stuff += " ([admin_jump_link(mob)])"

			if(target.mob in heard)
				send = 1
				if(isAI(target.mob))
					prefix = " (Core)"

			else if(isAI(target.mob)) // Special case
				var/mob/living/silicon/ai/A = target.mob
				if(A.eyeobj in hearers(7, source))
					send = 1
					prefix = " (Eye)"

			if(!send && (target in GLOB.admins))
				if(check_rights(R_ADMIN|R_MOD, FALSE, target.mob))
					send = 1
					prefix = "(R)"

			if(send)
				to_chat(target, span_ooc(span_looc("LOOC[span_prefix("[prefix]: ")]<em>[display_name][admin_stuff]:</em> [span_message(msg)]")))

				if(target.mob && target.prefs.toggles3 & PREFTOGGLE_3_RUNECHAT_LOOC)
					var/mob/source_mob = mob.get_looc_source()
					target.mob.create_chat_message(source_mob, "<b>LOOC:</b> [msg_runechat]", list("looc"), null)

/mob/proc/get_looc_source()
	return src

/mob/living/silicon/ai/get_looc_source()
	if(eyeobj)
		return eyeobj
	return src

//Checks admin notice
GAME_VERB_DESC(/client, admin_notice, "Adminnotice", "Check the admin notice if it has been set", VERB_CATEGORY_OOC)
	if(GLOB.admin_notice)
		to_chat(src, "[span_boldnotice("Admin Notice:")]\n \t [GLOB.admin_notice]")
	else
		to_chat(src, span_notice("There are no admin notices at the moment."))
