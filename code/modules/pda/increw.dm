#define INCREW_MAX_GROUP_MEMBERS 50

/datum/data/pda/app/increw
	name = "InCrew"
	icon = "comments"
	notify_icon = "comments"
	template = "pda_raingor_messenger"

	/// Chat open on this PDA.
	var/selected_chat_id

/datum/data/pda/app/increw/stop()
	selected_chat_id = null
	return ..()

/datum/data/pda/app/increw/proc/get_profile()
	var/obj/item/card/id/card = pda.id
	if(!card?.associated_account_number || !card.registered_name)
		return null

	var/datum/money_account/account = attempt_account_access_nosec(card.associated_account_number)
	if(QDELETED(account) || account.owner_name != card.registered_name)
		return null

	return account.get_messenger_profile()

/datum/data/pda/app/increw/update_ui(mob/user, list/data)
	var/datum/messenger_account/profile = get_profile()
	data["can_login"] = !!profile
	data["active_chat"] = null
	if(!profile)
		selected_chat_id = null
		return

	var/list/chats = list()
	for(var/chat_id in profile.chats)
		var/datum/messenger_chat/chat = profile.chats[chat_id]
		chats += list(chat.get_summary(profile))

	var/list/contacts = list()
	for(var/datum/money_account/account as anything in GLOB.all_money_accounts)
		if(account == profile.owner || QDELETED(account) || !account.owner_name)
			continue
		contacts += list(list(
			"label" = account.owner_name,
			"value" = account.UID(),
			"has_private_chat" = !!account.messenger_profile && !!profile.private_chats?[account.messenger_profile],
		))

	data["owner_messenger_account"] = profile.get_ui_data()
	data["chats"] = chats
	data["contacts"] = contacts

	var/datum/messenger_chat/selected_chat = selected_chat_id ? profile.chats[selected_chat_id] : null
	if(selected_chat)
		data["active_chat"] = selected_chat.get_details()

/datum/data/pda/app/increw/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	var/datum/messenger_account/profile = get_profile()
	if(!profile)
		return FALSE

	switch(action)
		if("create_private_chat")
			var/datum/messenger_account/target = get_target(params["target"])
			if(!target || target == profile || profile.private_chats?[target])
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
			var/list/members = params["members"]
			if(!istext(name) || !istext(description) || !islist(members) || length(members) >= INCREW_MAX_GROUP_MEMBERS)
				return FALSE
			name = trim(name, 81)
			if(!name)
				return FALSE
			var/datum/messenger_chat/chat = new(name, trim(description, 301), profile)
			chat.add_member(profile)
			for(var/target_id as anything in members)
				var/datum/messenger_account/target = get_target(target_id)
				if(target)
					chat.add_member(target)
			selected_chat_id = chat.UID()
			return TRUE
		if("close_chat")
			selected_chat_id = null
			return TRUE

	var/chat_id = params["chatId"]
	if(!istext(chat_id))
		return FALSE
	var/datum/messenger_chat/chat = profile.chats[chat_id]
	if(!chat)
		return FALSE

	switch(action)
		if("open_chat")
			selected_chat_id = chat_id
			return TRUE
		if("send_message")
			var/message = params["message"]
			if(!istext(message))
				return FALSE
			message = trim(message, MAX_MESSAGE_LEN + 1)
			if(!message)
				return FALSE
			chat.add_message(message, profile)
			log_pda("(InCrew) [profile.owner.owner_name] sent \"[html_encode(message)]\" in [html_encode(chat.get_display_name(profile))]", ui.user)
			return TRUE
		if("delete_chat")
			if(!chat.is_group || chat.owner == profile)
				qdel(chat)
				return TRUE
		if("leave_chat")
			if(chat.is_group && chat.owner != profile)
				chat.remove_member(profile)
				chat.add_message("[profile.owner.owner_name] покинул(-а) группу.")
				return TRUE
		if("add_member_to_chat")
			if(chat.owner != profile || length(chat.members) >= INCREW_MAX_GROUP_MEMBERS)
				return FALSE
			var/datum/messenger_account/target = get_target(params["target"])
			if(target && chat.add_member(target))
				chat.add_message("[profile.owner.owner_name] добавил(-а) в группу [target.owner.owner_name].")
				return TRUE
		if("remove_member_from_chat")
			var/target_id = params["target"]
			if(chat.owner != profile || !istext(target_id))
				return FALSE
			var/datum/messenger_account/target = chat.members[target_id]
			if(target && target != profile)
				chat.remove_member(target)
				chat.add_message("[profile.owner.owner_name] исключил(-а) из группы [target.owner.owner_name].")
				return TRUE
	return FALSE

/datum/data/pda/app/increw/proc/get_target(target_id)
	if(!istext(target_id) || !length(target_id))
		return null
	for(var/datum/money_account/account as anything in GLOB.all_money_accounts)
		if(!QDELETED(account) && account.unique_datum_id == target_id)
			return account.get_messenger_profile()
	return null

#undef INCREW_MAX_GROUP_MEMBERS
