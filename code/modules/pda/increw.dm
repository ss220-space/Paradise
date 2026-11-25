GLOBAL_LIST_INIT(increw_call_ringtones, list(
	INCREW_DEFAULT_CALL_RINGTONE = 'sound/machines/twobeep_high.ogg',
	"Гитара скелета" = 'sound/misc/guitar_rifs/skeleton_guitar_riff.ogg',
	"Гитарный рифф №2" = 'sound/misc/guitar_rifs/guitar_riff_2.ogg',
	"Гитарный рифф №4" = 'sound/misc/guitar_rifs/guitar_riff_4.ogg',
	"Ретро-джингл" = 'sound/effects/achievement/beeps_jingle.ogg',
	"Колокольчики" = 'sound/effects/achievement/glockenspiel_ping.ogg',
	"Фанфара" = 'sound/effects/achievement/tada_fanfare.ogg',
	"Пианино" = 'sound/effects/piano_hit.ogg',
	"Терминал" = 'sound/machines/terminal_processing.ogg',
	"Аркада" = 'sound/items/PDA/mario_1up.ogg',
))

/datum/data/pda/app/increw
	name = "InCrew"
	icon = "comments"
	notify_icon = "comments"
	template = "pda_raingor_messenger"

	/// Chat open on this PDA.
	var/datum/weakref/selected_chat_ref
	var/history_before
	var/list/contact_search
	var/show_public_groups = FALSE
	var/datum/increw_call_member/call_member
	var/datum/weakref/login_profile
	var/login_paused = FALSE
	/// Stored on this PDA's InCrew app.
	var/call_ringtone = INCREW_DEFAULT_CALL_RINGTONE

/datum/data/pda/app/increw/Destroy()
	if(call_member)
		call_member.call_session.remove_member(call_member.profile)
	clear_login()
	return ..()

/datum/data/pda/app/increw/stop()
	open_chat(null)
	return ..()

/datum/data/pda/app/increw/proc/get_profile(mob/user, manual_login = FALSE)
	if(!isliving(user) || pda.loc != user)
		return null

	if(login_paused && !manual_login)
		return null

	var/datum/messenger_account/profile = login_profile?.resolve()

	var/obj/item/card/id/card = pda.id
	if(!card || card.loc != pda)
		return profile
	if(!card.associated_account_number || !card.registered_name)
		if(!manual_login)
			clear_login()
		return null
	if(profile?.matches_card(card))
		return profile

	var/datum/money_account/account = attempt_account_access_nosec(card.associated_account_number)
	if(QDELETED(account) || account.owner_name != card.registered_name)
		if(!manual_login)
			clear_login()
		return null

	clear_login()
	profile = account.get_messenger_profile()
	login_profile = WEAKREF(profile)
	return profile

/datum/data/pda/app/increw/proc/clear_login()
	login_profile = null
	login_paused = FALSE
	open_chat(null)

/datum/data/pda/app/increw/proc/is_signed_in_as(datum/messenger_account/profile, mob/user)
	if(pda.loc != user || login_profile?.resolve() != profile)
		return FALSE
	var/obj/item/card/id/card = pda.id
	return card?.loc != pda || profile.matches_card(card)

/datum/data/pda/app/increw/update_ui(mob/user, list/data)
	var/datum/messenger_account/profile = get_profile(user)
	if(pda.loc == user)
		refresh_alert(profile)
	data["can_login"] = !!profile
	var/obj/item/card/id/card = pda.id
	data["can_sign_in"] = login_paused && pda.loc == user && card?.loc == pda && card.associated_account_number && card.registered_name
	data["active_chat"] = null
	data["public_groups"] = null
	data["call"] = null
	data["contact_search"] = null
	if(!profile)
		data["owner_messenger_account"] = null
		data["chats"] = null
		data["blocked_contacts"] = null
		return

	var/list/chats = list()
	for(var/datum/messenger_chat/chat as anything in profile.chats)
		if(chat.is_visible_to(profile))
			chats += list(chat.get_summary(profile))

	data["owner_messenger_account"] = profile.get_ui_data()
	data["ringtone"] = call_ringtone
	data["ringtone_options"] = assoc_to_keys(GLOB.increw_call_ringtones)
	var/datum/economy_process/subscription/increw_plus/plan = get_increw_plus_subscription()
	var/has_plus = profile.has_increw_plus()
	data["plus"] = list(
		"active" = has_plus,
		"available" = !QDELETED(plan) && !QDELETED(plan.recipient_account) && !plan.recipient_account.suspended && profile.owner != plan.recipient_account,
		"cost" = plan?.cost || INCREW_PLUS_COST,
		"minutes" = (plan?.interval || INCREW_PLUS_INTERVAL) / (1 MINUTES),
	)
	data["chats"] = chats
	data["contact_search"] = contact_search
	var/list/blocked_contacts = list()
	for(var/account_id, account_name in profile.blocked_accounts)
		blocked_contacts += list(list("id" = account_id, "name" = account_name))
	data["blocked_contacts"] = blocked_contacts
	data["max_group_members"] = INCREW_MAX_GROUP_MEMBERS
	data["call_busy"] = !!profile.active_call
	if(call_member?.profile == profile && call_member.user == user && call_member.is_available())
		data["call"] = call_member.call_session.get_ui_data(call_member)

	if(show_public_groups && has_plus)
		var/list/public_groups = list()
		for(var/datum/messenger_chat/chat as anything in GLOB.increw_public_groups)
			public_groups += list(chat.get_summary(profile, include_preview = FALSE))
		data["public_groups"] = public_groups

	var/datum/messenger_chat/selected_chat = selected_chat_ref?.resolve()
	if(selected_chat?.is_visible_to(profile))
		data["active_chat"] = selected_chat.get_details(profile, history_before)

/datum/data/pda/app/increw/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	if(action == "sign_in")
		if(!login_paused)
			return FALSE
		if(!get_profile(ui.user, manual_login = TRUE))
			to_chat(ui.user, span_warning("InCrew: вставьте ID-карту с привязанным личным счётом."))
			return FALSE
		return TRUE

	var/datum/messenger_account/profile = get_profile(ui.user)
	if(!profile)
		return FALSE

	switch(action)
		if("set_increw_ringtone")
			var/ringtone = params["ringtone"]
			if(!pda.can_use(ui.user) || !istext(ringtone) || !(ringtone in GLOB.increw_call_ringtones))
				return FALSE
			call_ringtone = ringtone
			return TRUE
		if("subscribe_plus")
			if(!pda.can_use(ui.user))
				return FALSE
			var/datum/economy_process/subscription/increw_plus/plan = get_increw_plus_subscription()
			if(QDELETED(plan))
				return FALSE
			return plan.sub(profile.owner)
		if("sign_out")
			login_paused = TRUE
			login_profile = null
			open_chat(null)
			if(call_member?.profile == profile && call_member.user == ui.user)
				call_member.call_session.remove_member(profile)
			refresh_alert(null)
			return TRUE
		if("accept_call", "decline_call", "leave_call", "toggle_call_mic")
			return handle_call_action(action, params["callId"], profile, ui.user)
		if("search_contacts")
			return search_contacts(profile, params)
		if("block_contact")
			var/datum/messenger_account/target = get_target(params["target"])
			if(!target || target == profile || profile.blocks(target.owner))
				return FALSE
			LAZYSET(profile.blocked_accounts, target.owner.UID(), target.owner.owner_name)
			var/datum/messenger_chat/private_chat = profile.private_chats?[target]
			if(private_chat)
				LAZYREMOVE(profile.unread_chats, private_chat)
				LAZYREMOVE(target.unread_chats, private_chat)
				QDEL_NULL(private_chat.active_call)
			return TRUE
		if("unblock_contact")
			var/target_id = params["target"]
			if(!istext(target_id) || !(target_id in profile.blocked_accounts))
				return FALSE
			LAZYREMOVE(profile.blocked_accounts, target_id)
			return TRUE
		if("show_public_groups")
			if(!profile.has_increw_plus())
				return FALSE
			open_chat(null)
			show_public_groups = TRUE
			return TRUE
		if("hide_public_groups")
			show_public_groups = FALSE
			return TRUE
		if("join_public_group")
			return join_public_group(profile, params["chatId"])
		if("create_private_chat")
			var/datum/messenger_account/target = get_target(params["target"])
			if(!target || target == profile || !profile.can_contact(target))
				return FALSE
			var/datum/messenger_chat/existing_chat = profile.private_chats?[target]
			if(existing_chat)
				return open_chat(existing_chat)
			var/datum/messenger_chat/chat = new(null, "Приватный чат с пользователем", null)
			chat.add_member(profile)
			chat.add_member(target)
			LAZYSET(profile.private_chats, target, chat)
			LAZYSET(target.private_chats, profile, chat)
			return open_chat(chat)
		if("create_group_chat")
			if(!profile.has_increw_plus())
				return FALSE
			var/name = params["name"]
			var/description = params["description"]
			var/public = params["isPublic"]
			var/list/members = params["members"]
			if(!istext(name) || !istext(description) || !islist(members) || length(members) >= INCREW_MAX_GROUP_MEMBERS)
				return FALSE
			if(!isnum(public) || (public != TRUE && public != FALSE))
				return FALSE
			name = trim(name, 81)
			if(!name)
				return FALSE
			var/datum/messenger_chat/chat = new(name, trim(description, 301), profile)
			chat.add_member(profile)
			add_initial_members(chat, profile, members)
			if(public)
				chat.set_public(TRUE)
			return open_chat(chat)
		if("close_chat")
			return open_chat(null)

	var/datum/messenger_chat/chat = resolve_increw_uid(params["chatId"])
	if(!istype(chat) || QDELETED(chat) || !chat.is_visible_to(profile))
		return FALSE

	switch(action)
		if("start_call")
			return start_call(profile, chat, ui.user)
		if("open_chat")
			return open_chat(chat)
		if("older_messages")
			var/before = params["before"]
			var/current_before = history_before || length(chat.messages) + 1
			if(selected_chat_ref?.resolve() != chat || !isnum(before) || before != round(before) || before <= 1 || before >= current_before)
				return FALSE
			history_before = before
			return TRUE
		if("latest_messages")
			if(selected_chat_ref?.resolve() != chat || !history_before)
				return FALSE
			history_before = null
			return TRUE
		if("read_chat")
			if(selected_chat_ref?.resolve() != chat || history_before || !profile.unread_chats?[chat] || params["messageId"] != length(chat.messages))
				return FALSE
			LAZYREMOVE(profile.unread_chats, chat)
			refresh_alert(profile)
			return TRUE
		if("send_message")
			var/message = params["message"]
			if(!istext(message))
				return FALSE
			message = trim(message, MAX_MESSAGE_LEN + 1)
			if(!message)
				return FALSE
			if(!chat.add_message(message, profile))
				return FALSE
			log_pda("(InCrew) [profile.owner.owner_name] sent \"[html_encode(message)]\" in [html_encode(chat.get_display_name(profile))]", ui.user)
			return TRUE
		if("delete_chat")
			if(!chat.is_group || chat.owner == profile)
				qdel(chat)
				return TRUE
		if("leave_chat")
			if(chat.is_group && chat.owner != profile)
				chat.remove_member(profile)
				chat.add_message("[profile.owner.owner_name] покинул(-а) группу.", event_actor = profile)
				return TRUE
		if("set_group_visibility")
			if(chat.owner == profile)
				return chat.set_public(params["isPublic"])
		if("add_member_to_chat")
			if(chat.owner != profile || length(chat.members) >= INCREW_MAX_GROUP_MEMBERS)
				return FALSE
			var/datum/messenger_account/target = get_target(params["target"])
			if(target && profile.can_contact(target) && chat.add_member(target))
				chat.add_message("[profile.owner.owner_name] добавил(-а) в группу [target.owner.owner_name].", event_actor = profile)
				return TRUE
		if("remove_member_from_chat")
			if(chat.owner != profile)
				return FALSE
			var/datum/money_account/account = get_contact_account(params["target"])
			var/datum/messenger_account/target = account?.messenger_profile
			if(target && target != profile && (target in chat.members))
				chat.remove_member(target)
				chat.add_message("[profile.owner.owner_name] исключил(-а) из группы [target.owner.owner_name].", event_actor = profile)
				return TRUE
	return FALSE

/datum/data/pda/app/increw/proc/join_public_group(datum/messenger_account/profile, chat_id)
	if(!profile.has_increw_plus())
		return FALSE
	var/datum/messenger_chat/chat = resolve_increw_uid(chat_id)
	if(!istype(chat) || QDELETED(chat) || !chat.is_public)
		return FALSE
	if(!(profile in chat.members))
		if(length(chat.members) >= INCREW_MAX_GROUP_MEMBERS || !chat.add_member(profile))
			return FALSE
		chat.add_message("[profile.owner.owner_name] вступил(-а) в группу.", event_actor = profile)
	return open_chat(chat)

/datum/data/pda/app/increw/proc/open_chat(datum/messenger_chat/chat)
	selected_chat_ref = WEAKREF(chat)
	history_before = null
	contact_search = null
	show_public_groups = FALSE
	return TRUE

/datum/data/pda/app/increw/proc/search_contacts(datum/messenger_account/profile, list/params)
	var/query = params["query"]
	var/picker = params["picker"]
	var/list/excluded = params["excluded"]
	if(!istext(query) || !istext(picker) || length(picker) > 40 || !islist(excluded) || length(excluded) > INCREW_MAX_GROUP_MEMBERS)
		return FALSE
	query = trim(query, 81)
	if(!query)
		return FALSE

	var/list/matches = list()
	for(var/datum/money_account/account as anything in GLOB.all_money_accounts)
		if(account == profile.owner || QDELETED(account) || !account.owner_name || !findtext(account.owner_name, query))
			continue
		var/datum/messenger_account/target = account.messenger_profile
		if(profile.blocks(account) || target?.blocks(profile.owner))
			continue
		if(params["privateOnly"] && target && profile.private_chats?[target])
			continue
		var/account_id = account.UID()
		if(account_id in excluded)
			continue
		matches += list(list("label" = account.owner_name, "value" = account_id))
		if(length(matches) >= INCREW_MAX_CONTACT_RESULTS)
			break

	contact_search = list("query" = query, "picker" = picker, "matches" = matches)
	return TRUE

/datum/data/pda/app/increw/proc/add_initial_members(datum/messenger_chat/chat, datum/messenger_account/profile, list/members)
	for(var/target_id in members)
		var/datum/messenger_account/target = get_target(target_id)
		if(target && target != profile && profile.can_contact(target))
			chat.add_member(target)

/datum/data/pda/app/increw/proc/get_target(target_id)
	var/datum/money_account/account = get_contact_account(target_id)
	return account?.get_messenger_profile()

/datum/data/pda/app/increw/proc/get_contact_account(target_id)
	var/datum/money_account/account = resolve_increw_uid(target_id)
	if(!istype(account) || QDELETED(account) || !(account in GLOB.all_money_accounts))
		return null
	return account

/datum/data/pda/app/increw/proc/resolve_increw_uid(uid)
	// The Rust lookup expects an unpadded base64url UID for eight bytes.
	var/static/regex/uid_format = regex(@"^[A-Za-z0-9_-]{10}[AEIMQUYcgkosw048]$")
	if(!istext(uid) || length(uid) != 11 || !uid_format.Find(uid))
		return null
	return locateUID(uid)

/datum/data/pda/app/increw/proc/refresh_alert(datum/messenger_account/profile)
	if(QDELETED(pda))
		return
	if(length(profile?.unread_chats) || (call_member && call_member.profile == profile && !call_member.accepted && !call_member.quiet))
		if(!(src in pda.notifying_programs))
			pda.notifying_programs += src
			pda.update_icon(UPDATE_OVERLAYS)
	else
		unnotify()

/datum/data/pda/app/increw/proc/get_call_ringtone_sound()
	var/sound_file = GLOB.increw_call_ringtones[call_ringtone] || GLOB.increw_call_ringtones[INCREW_DEFAULT_CALL_RINGTONE]
	return pda.get_ringtone_sound(sound_file)

/datum/data/pda/app/increw/proc/start_call(datum/messenger_account/profile, datum/messenger_chat/chat, mob/user)
	if(!isliving(user) || user.stat == DEAD || !pda.can_use(user) || !user.client)
		return FALSE
	if(!profile.has_increw_plus())
		return FALSE
	if(profile.active_call || chat.active_call)
		to_chat(user, span_warning("InCrew: линия занята."))
		return FALSE
	if(!COOLDOWN_FINISHED(profile, call_cooldown))
		to_chat(user, span_warning("InCrew: подождите перед повторным вызовом."))
		return FALSE

	var/list/available_profiles = list()
	for(var/datum/messenger_account/member as anything in chat.members)
		if(member != profile && !member.active_call && profile.can_contact(member))
			available_profiles["[member.owner.account_number]"] = member
	var/list/recipients = list()
	if(length(available_profiles))
		for(var/obj/item/pda/target_pda as anything in GLOB.PDAs)
			var/mob/living/holder = target_pda.loc
			if(!istype(holder) || !holder.client || holder.stat == DEAD)
				continue
			var/obj/item/card/id/card = target_pda.id
			if(card?.loc == target_pda && !available_profiles["[card.associated_account_number]"])
				continue
			var/datum/data/pda/app/increw/target_device = target_pda.find_program(/datum/data/pda/app/increw)
			if(!target_device || target_device.call_member)
				continue
			var/datum/messenger_account/target = target_device.get_profile(holder)
			if(!target)
				continue
			var/account_number = "[target.owner.account_number]"
			if(available_profiles[account_number] == target)
				recipients[target] = target_device
				available_profiles -= account_number
				if(!length(available_profiles))
					break

	if(!length(recipients))
		to_chat(user, span_warning("InCrew: никто из собеседников сейчас не на связи."))
		return FALSE
	var/frequency = get_increw_call_frequency()
	if(!frequency)
		to_chat(user, span_warning("InCrew: все частоты заняты."))
		return FALSE

	COOLDOWN_START(profile, call_cooldown, INCREW_CALL_COOLDOWN)
	var/datum/increw_call/call_session = new(chat, profile, frequency)
	chat.add_message("[profile.owner.owner_name] начал(-а) звонок.", event_actor = profile)
	call_session.add_member(profile, src, accepted = TRUE)
	for(var/datum/messenger_account/target, target_device in recipients)
		call_session.add_member(target, target_device)
	call_session.ring()
	return TRUE

/datum/data/pda/app/increw/proc/handle_call_action(action, call_id, datum/messenger_account/profile, mob/user)
	if(!call_member || call_member.profile != profile || call_member.user != user || !call_member.is_available())
		return FALSE
	var/datum/increw_call/call_session = call_member.call_session
	if(call_id != call_session.UID())
		return FALSE
	switch(action)
		if("accept_call")
			if(pda.can_use(user))
				return call_session.accept(call_member)
		if("decline_call")
			return call_session.decline(call_member)
		if("leave_call")
			if(!call_member.accepted)
				return FALSE
			return call_session.remove_member(profile)
		if("toggle_call_mic")
			var/obj/item/radio/increw/radio = call_member.radio
			if(radio)
				return radio.set_broadcasting(!radio.get_broadcasting())
	return FALSE
