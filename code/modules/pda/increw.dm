#define INCREW_MAX_GROUP_MEMBERS 50

/datum/data/pda/app/increw
	name = "InCrew"
	icon = "comments"
	notify_icon = "comments"
	template = "pda_raingor_messenger"

	/// Chat open on this PDA.
	var/selected_chat_id
	var/show_public_groups = FALSE
	var/datum/increw_call_member/call_member
	var/datum/weakref/login_holder
	var/datum/weakref/login_profile

/datum/data/pda/app/increw/Destroy()
	if(call_member)
		call_member.call_session.remove_member(call_member.profile)
	clear_login()
	return ..()

/datum/data/pda/app/increw/stop()
	selected_chat_id = null
	show_public_groups = FALSE
	return ..()

/datum/data/pda/app/increw/proc/get_profile(mob/user)
	if(!isliving(user) || pda.loc != user)
		return null

	var/datum/messenger_account/profile
	if(login_holder?.resolve() == user)
		profile = login_profile?.resolve()

	var/obj/item/card/id/card = pda.id
	if(!card || card.loc != pda)
		return profile
	if(!card.associated_account_number || !card.registered_name)
		clear_login()
		return null
	if(profile?.matches_card(card))
		return profile

	clear_login()

	var/datum/money_account/account = attempt_account_access_nosec(card.associated_account_number)
	if(QDELETED(account) || account.owner_name != card.registered_name)
		return null

	profile = account.get_messenger_profile()
	login_holder = WEAKREF(user)
	login_profile = WEAKREF(profile)
	RegisterSignal(pda, COMSIG_MOVABLE_MOVED, PROC_REF(check_login_holder))
	return profile

/datum/data/pda/app/increw/proc/clear_login()
	if(login_holder)
		UnregisterSignal(pda, COMSIG_MOVABLE_MOVED)
	login_holder = null
	login_profile = null
	selected_chat_id = null
	show_public_groups = FALSE

/datum/data/pda/app/increw/proc/check_login_holder(obj/item/pda/source)
	SIGNAL_HANDLER
	if(source.loc != login_holder?.resolve())
		clear_login()
		refresh_alert(null)

/datum/data/pda/app/increw/update_ui(mob/user, list/data)
	var/datum/messenger_account/profile = get_profile(user)
	if(pda.loc == user)
		refresh_alert(profile)
	data["can_login"] = !!profile
	data["active_chat"] = null
	data["public_groups"] = null
	data["call"] = null
	if(!profile)
		return

	var/list/chats = list()
	for(var/chat_id in profile.chats)
		var/datum/messenger_chat/chat = profile.chats[chat_id]
		if(chat.is_visible_to(profile))
			chats += list(chat.get_summary(profile))

	var/list/contacts = list()
	var/profile_id = profile.owner.UID()
	for(var/datum/money_account/account as anything in GLOB.all_money_accounts)
		if(account == profile.owner || QDELETED(account) || !account.owner_name)
			continue
		var/account_id = account.UID()
		if(profile.blocks(account_id) || account.messenger_profile?.blocks(profile_id))
			continue
		contacts += list(list(
			"label" = account.owner_name,
			"value" = account_id,
			"has_private_chat" = !!account.messenger_profile && !!profile.private_chats?[account.messenger_profile],
		))

	data["owner_messenger_account"] = profile.get_ui_data()
	data["chats"] = chats
	data["contacts"] = contacts
	var/list/blocked_contacts = list()
	for(var/account_id in profile.blocked_accounts)
		blocked_contacts += list(list("id" = account_id, "name" = profile.blocked_accounts[account_id]))
	data["blocked_contacts"] = blocked_contacts
	data["max_group_members"] = INCREW_MAX_GROUP_MEMBERS
	data["call_busy"] = !!profile.active_call
	if(call_member?.profile == profile && call_member.user == user && call_member.is_available())
		data["call"] = call_member.call_session.get_ui_data(call_member)

	if(show_public_groups)
		var/list/public_groups = list()
		for(var/chat_id in GLOB.increw_public_groups)
			var/datum/messenger_chat/chat = GLOB.increw_public_groups[chat_id]
			public_groups += list(chat.get_summary(profile))
		data["public_groups"] = public_groups

	var/datum/messenger_chat/selected_chat = selected_chat_id ? profile.chats[selected_chat_id] : null
	if(selected_chat?.is_visible_to(profile))
		data["active_chat"] = selected_chat.get_details(profile)

/datum/data/pda/app/increw/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	var/datum/messenger_account/profile = get_profile(ui.user)
	if(!profile)
		return FALSE

	switch(action)
		if("accept_call", "decline_call", "leave_call", "toggle_call_mic")
			return handle_call_action(action, params["callId"], profile, ui.user)
		if("block_contact")
			var/datum/messenger_account/target = get_target(params["target"])
			if(!target || target == profile || profile.blocks(target.owner.UID()))
				return FALSE
			LAZYSET(profile.blocked_accounts, target.owner.UID(), target.owner.owner_name)
			var/datum/messenger_chat/private_chat = profile.private_chats?[target]
			if(private_chat)
				LAZYREMOVE(profile.unread_chats, private_chat.UID())
				LAZYREMOVE(target.unread_chats, private_chat.UID())
				QDEL_NULL(private_chat.active_call)
			return TRUE
		if("unblock_contact")
			var/target_id = params["target"]
			if(!istext(target_id) || !profile.blocks(target_id))
				return FALSE
			LAZYREMOVE(profile.blocked_accounts, target_id)
			return TRUE
		if("show_public_groups")
			show_public_groups = TRUE
			selected_chat_id = null
			return TRUE
		if("hide_public_groups")
			show_public_groups = FALSE
			return TRUE
		if("join_public_group")
			return join_public_group(profile, params["chatId"])
		if("create_private_chat")
			var/datum/messenger_account/target = get_target(params["target"])
			if(!target || target == profile || profile.private_chats?[target] || !profile.can_contact(target))
				return FALSE
			var/datum/messenger_chat/chat = new(null, "Приватный чат с пользователем", null)
			chat.add_member(profile)
			chat.add_member(target)
			LAZYSET(profile.private_chats, target, chat)
			LAZYSET(target.private_chats, profile, chat)
			selected_chat_id = chat.UID()
			return TRUE
		if("create_group_chat")
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
			for(var/target_id as anything in members)
				var/datum/messenger_account/target = get_target(target_id)
				if(target && profile.can_contact(target))
					chat.add_member(target)
			if(public)
				chat.set_public(TRUE)
			selected_chat_id = chat.UID()
			return TRUE
		if("close_chat")
			selected_chat_id = null
			return TRUE

	var/chat_id = params["chatId"]
	if(!istext(chat_id))
		return FALSE
	var/datum/messenger_chat/chat = profile.chats[chat_id]
	if(!chat?.is_visible_to(profile))
		return FALSE

	switch(action)
		if("start_call")
			return start_call(profile, chat, ui.user)
		if("open_chat")
			selected_chat_id = chat_id
			show_public_groups = FALSE
			return TRUE
		if("read_chat")
			if(selected_chat_id != chat_id || !profile.unread_chats?[chat_id] || params["messageId"] != length(chat.messages))
				return FALSE
			LAZYREMOVE(profile.unread_chats, chat_id)
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
			var/target_id = params["target"]
			if(chat.owner != profile || !istext(target_id))
				return FALSE
			var/datum/messenger_account/target = chat.members[target_id]
			if(target && target != profile)
				chat.remove_member(target)
				chat.add_message("[profile.owner.owner_name] исключил(-а) из группы [target.owner.owner_name].", event_actor = profile)
				return TRUE
	return FALSE

/datum/data/pda/app/increw/proc/join_public_group(datum/messenger_account/profile, chat_id)
	if(!istext(chat_id))
		return FALSE
	var/datum/messenger_chat/chat = GLOB.increw_public_groups[chat_id]
	if(!chat)
		return FALSE
	if(!profile.chats[chat_id])
		if(length(chat.members) >= INCREW_MAX_GROUP_MEMBERS || !chat.add_member(profile))
			return FALSE
		chat.add_message("[profile.owner.owner_name] вступил(-а) в группу.", event_actor = profile)
	selected_chat_id = chat_id
	show_public_groups = FALSE
	return TRUE

/datum/data/pda/app/increw/proc/get_target(target_id)
	if(!istext(target_id) || !length(target_id))
		return null
	for(var/datum/money_account/account as anything in GLOB.all_money_accounts)
		if(!QDELETED(account) && account.unique_datum_id == target_id)
			return account.get_messenger_profile()
	return null

/datum/data/pda/app/increw/proc/refresh_alert(datum/messenger_account/profile)
	if(QDELETED(pda))
		return
	if(length(profile?.unread_chats) || (call_member && call_member.profile == profile && !call_member.accepted && !call_member.quiet))
		if(!(src in pda.notifying_programs))
			pda.notifying_programs += src
			pda.update_icon(UPDATE_OVERLAYS)
	else
		unnotify()

/datum/data/pda/app/increw/proc/start_call(datum/messenger_account/profile, datum/messenger_chat/chat, mob/user)
	if(!isliving(user) || user.stat == DEAD || !pda.can_use(user) || !user.client)
		return FALSE
	if(profile.active_call || chat.active_call)
		to_chat(user, span_warning("InCrew: линия занята."))
		return FALSE
	if(!COOLDOWN_FINISHED(profile, call_cooldown))
		to_chat(user, span_warning("InCrew: подождите перед повторным вызовом."))
		return FALSE

	var/list/available_profiles = list()
	for(var/member_id in chat.members)
		var/datum/messenger_account/member = chat.members[member_id]
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

	COOLDOWN_START(profile, call_cooldown, 12 SECONDS)
	var/datum/increw_call/call_session = new(chat, profile, frequency)
	chat.add_message("[profile.owner.owner_name] начал(-а) звонок.", event_actor = profile)
	call_session.add_member(profile, src, accepted = TRUE)
	for(var/datum/messenger_account/target as anything in recipients)
		call_session.add_member(target, recipients[target])
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

#undef INCREW_MAX_GROUP_MEMBERS
