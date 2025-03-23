/mob/living/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	if(client)
		if(check_mute(client.ckey, MUTE_PRAY))
			to_chat(usr, "<span class='warning'>You cannot pray (muted).</span>")
			return
		if(client.handle_spam_prevention(msg, MUTE_PRAY, OOC_COOLDOWN))
			return

	var/image/cross = image('icons/obj/storage.dmi',"bible")
	var/font_color = "purple"
	var/prayer_type = "PRAYER"
	var/deity
	if(job == JOB_TITLE_CHAPLAIN)
		if(SSticker && SSticker.Bible_deity_name)
			deity = SSticker.Bible_deity_name
		cross = image('icons/obj/storage.dmi',"kingyellow")
		font_color = "blue"
		prayer_type = "CHAPLAIN PRAYER"
	else if(iscultist(usr))
		cross = image('icons/obj/storage.dmi',"tome")
		font_color = "red"
		prayer_type = "CULTIST PRAYER"
		deity = SSticker.cultdat.entity_name

	add_game_logs("Prayed to the gods: [msg]", usr)
	GLOB.requests.pray(client, msg, job == JOB_TITLE_CHAPLAIN)
	msg = "<span class='notice'>[bicon(cross)]<b><span style='color: [font_color];'>[prayer_type][deity ? " (to [deity])" : ""][mind && mind.isholy ? " (blessings: [mind.num_blessed])" : ""]:</span> [key_name(src, 1)] ([ADMIN_QUE(src,"?")]) ([ADMIN_PP(src,"PP")]) ([ADMIN_VV(src,"VV")]) ([ADMIN_TP(src,"TP")]) ([ADMIN_SM(src,"SM")]) ([admin_jump_link(src)]) ([ADMIN_SC(src,"SC")]) (<a href='byond://?_src_=holder;Bless=[UID()]'>BLESS</a>) (<a href='byond://?_src_=holder;Smite=[UID()]'>SMITE</a>):</b> [msg]</span>"

	for(var/client/X in GLOB.admins)
		if(check_rights(R_EVENT,0,X.mob))
			to_chat(X, msg)
			if(X.prefs.sound & SOUND_PRAYERNOTIFY)
				SEND_SOUND(X, 'sound/items/PDA/ambicha4-short.ogg')
	to_chat(usr, "Your prayers have been received by the gods.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Pray") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/proc/Centcomm_announce(var/text , var/mob/Sender)
	var/msg = sanitize(copytext_char(text, 1, MAX_MESSAGE_LEN))
	GLOB.requests.message_centcom(Sender.client, msg)
	msg = "<span class='boldnotice'><span style='color: orange;'>CENTCOMM: </span>[key_name(Sender, 1)] ([ADMIN_PP(Sender,"PP")]) ([ADMIN_VV(Sender,"VV")]) ([ADMIN_TP(Sender,"TP")]) ([ADMIN_SM(Sender,"SM")]) ([admin_jump_link(Sender)]) ([ADMIN_BSA(Sender,"BSA")]) ([ADMIN_CENTCOM_REPLY(Sender,"RPLY")])):</span> [msg]"
	for(var/client/X in GLOB.admins)
		if(R_EVENT & X.holder.rights)
			to_chat(X, msg)
			if(X.prefs.sound & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'

/proc/Syndicate_announce(var/text , var/mob/Sender)
	var/msg = sanitize(copytext_char(text, 1, MAX_MESSAGE_LEN))
	GLOB.requests.message_syndicate(Sender.client, msg)
	msg = "<span class='boldnotice'><span style='color: #DC143C;'>SYNDICATE: </span>[key_name(Sender, 1)] ([ADMIN_PP(Sender,"PP")]) ([ADMIN_VV(Sender,"VV")]) ([ADMIN_TP(Sender,"TP")]) ([ADMIN_SM(Sender,"SM")]) ([admin_jump_link(Sender)]) ([ADMIN_BSA(Sender,"BSA")]) ([ADMIN_SYNDICATE_REPLY(Sender,"RPLY")]):</span> [msg]"
	for(var/client/X in GLOB.admins)
		if(check_rights(R_EVENT,0,X.mob))
			to_chat(X, msg)
			if(X.prefs.sound & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'

/proc/HONK_announce(var/text , var/mob/Sender)
	var/msg = sanitize(copytext_char(text, 1, MAX_MESSAGE_LEN))
	GLOB.requests.message_honk(Sender.client, msg)
	msg = "<span class='boldnotice'><span style='color: pink;'>HONK: </span>[key_name(Sender, 1)] ([ADMIN_PP(Sender,"PP")]) ([ADMIN_VV(Sender,"VV")]) ([ADMIN_TP(Sender,"TP")]) ([ADMIN_SM(Sender,"SM")]) ([admin_jump_link(Sender)]) ([ADMIN_BSA(Sender,"BSA")]) (<a href='byond://?_src_=holder;HONKReply=[Sender.UID()]'>RPLY</a>):</span> [msg]"
	for(var/client/X in GLOB.admins)
		if(R_EVENT & X.holder.rights)
			to_chat(X, msg)
			if(X.prefs.sound & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'

/proc/ERT_Announce(text , mob/Sender, repeat_warning)
	var/msg = sanitize(copytext_char(text, 1, MAX_MESSAGE_LEN))
	var/insert_this = list(list(
		"time" = station_time_timestamp(),
		"sender_real_name" = "[Sender.real_name ? Sender.real_name : Sender.name]",
		"sender_uid" = Sender.UID(),
		"message" = msg))
	GLOB.ert_request_messages.Insert(1, insert_this) // insert it to the top of the list
	GLOB.requests.request_ert(Sender.client, msg)
	msg = span_adminnotice("<b><span style='color: orange;'>ЗАПРОС ОБР: </span>[key_name(Sender, 1)] ([ADMIN_PP(Sender,"PP")]) ([ADMIN_VV(Sender,"VV")]) ([ADMIN_TP(Sender,"TP")]) ([ADMIN_SM(Sender,"SM")]) ([admin_jump_link(Sender)]) ([ADMIN_BSA(Sender,"BSA")]) (<a href='byond://?_src_=holder;ErtReply=[Sender.UID()]'>ОТВЕТИТЬ</a>):</b> [msg]")
	if(repeat_warning)
		msg += "<br>[span_adminnotice("<b>ВНИМАНИЕ: запрос ОБР не получил ответа в течении 15 минут!</b>")]"
	for(var/client/X in GLOB.admins)
		if(check_rights(R_ADMIN, FALSE, X.mob))
			to_chat(X, msg)
			if(X.prefs.sound & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'

/proc/Nuke_request(text , mob/Sender)
	var/nuke_code = get_nuke_code()
	var/nuke_status = get_nuke_status()
	var/msg = sanitize(copytext_char(text, 1, MAX_MESSAGE_LEN))
	GLOB.requests.nuke_request(Sender.client, msg)
	msg = "<span class='adminnotice'><b><span style='color: orange;'>NUKE CODE REQUEST: </span>[key_name(Sender)] ([ADMIN_PP(Sender,"PP")]) ([ADMIN_VV(Sender,"VV")]) ([ADMIN_TP(Sender,"TP")]) ([ADMIN_SM(Sender,"SM")]) ([admin_jump_link(Sender)]) ([ADMIN_BSA(Sender,"BSA")]) ([ADMIN_CENTCOM_REPLY(Sender,"RPLY")]):</b> [msg]</span>"
	for(var/client/X in GLOB.admins)
		if(check_rights(R_EVENT,0,X.mob))
			to_chat(X, msg)
			if(nuke_status == NUKE_MISSING)
				to_chat(X, "<span class='userdanger'>The nuclear device is not on station!</span>")
			else
				to_chat(X, "<span class='adminnotice'><b>The nuke code is [nuke_code].</b></span>")
				if(nuke_status == NUKE_CORE_MISSING)
					to_chat(X, "<span class='userdanger'>The nuclear device does not have a core, and will not arm!</span>")
			if(X.prefs.sound & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'
