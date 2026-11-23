GLOBAL_LIST_EMPTY(increw_public_groups)

/datum/messenger_chat
	var/name
	var/description
	/// Group owner.
	var/datum/messenger_account/owner
	var/is_group = FALSE
	var/is_public = FALSE
	var/datum/increw_call/active_call
	var/list/members = list()
	/// TGUI reuses these rows on refresh.
	var/list/messages = list()

/datum/messenger_chat/New(name, description, datum/messenger_account/owner)
	src.name = name
	src.description = description
	src.owner = owner
	is_group = !!owner
	return ..()

/datum/messenger_chat/Destroy()
	QDEL_NULL(active_call)
	if(is_public)
		GLOB.increw_public_groups -= src

	if(!is_group && length(members) == 2)
		var/datum/messenger_account/first = members[1]
		var/datum/messenger_account/second = members[2]
		LAZYREMOVE(first.private_chats, second)
		LAZYREMOVE(second.private_chats, first)

	for(var/datum/messenger_account/member as anything in members)
		remove_member(member)
	messages = null
	owner = null
	return ..()

/datum/messenger_chat/proc/set_public(public)
	if(!is_group || !isnum(public) || (public != TRUE && public != FALSE) || is_public == public)
		return FALSE

	is_public = public
	if(is_public)
		GLOB.increw_public_groups += src
	else
		GLOB.increw_public_groups -= src
	return TRUE

/datum/messenger_chat/proc/add_member(datum/messenger_account/member)
	if(member in members)
		return FALSE
	members += member
	member.chats += src
	return TRUE

/datum/messenger_chat/proc/remove_member(datum/messenger_account/member)
	active_call?.remove_member(member)
	members -= member
	member.chats -= src
	LAZYREMOVE(member.unread_chats, src)

/datum/messenger_chat/proc/add_message(message, datum/messenger_account/sender, datum/messenger_account/event_actor)
	var/datum/messenger_account/recipient
	if(sender && !is_group)
		recipient = get_private_partner(sender)
		if(!recipient || !sender.can_contact(recipient))
			return FALSE

	messages += list(list(
		"id" = length(messages) + 1,
		"text_message" = message,
		"timestamp" = station_time_timestamp(),
		"sender_id" = sender?.owner.UID(),
		"sender_name" = sender ? sender.owner.owner_name : "InCrew",
		"actor_id" = event_actor?.owner.UID(),
	))
	recipient?.notify_direct_message(src, sender, message)
	return TRUE

/datum/messenger_chat/proc/get_private_partner(datum/messenger_account/viewer)
	for(var/datum/messenger_account/member as anything in members)
		if(member != viewer)
			return member
	return null

/datum/messenger_chat/proc/is_visible_to(datum/messenger_account/viewer)
	if(!(viewer in members))
		return FALSE
	if(is_group)
		return TRUE
	var/datum/messenger_account/partner = get_private_partner(viewer)
	return partner && viewer.can_contact(partner)

/datum/messenger_chat/proc/get_display_name(datum/messenger_account/viewer)
	if(is_group)
		return name

	var/datum/messenger_account/partner = get_private_partner(viewer)
	if(partner)
		return "Личная переписка с [partner.owner.owner_name]"
	return "Личная переписка"

/datum/messenger_chat/proc/get_summary(datum/messenger_account/viewer)
	return list(
		"chat_id" = UID(),
		"name_chat" = get_display_name(viewer),
		"description_chat" = description,
		"is_group" = is_group,
		"is_public" = is_public,
		"owner_id" = owner?.owner.UID(),
		"member_count" = length(members),
		"unread_count" = viewer.unread_chats?[src] || 0,
	)

/datum/messenger_chat/proc/get_details(datum/messenger_account/viewer, before)
	var/list/member_rows = list()
	for(var/datum/messenger_account/member as anything in members)
		if(viewer.blocks(member.owner))
			continue
		member_rows += list(member.get_ui_data())

	var/last_index = before ? before - 1 : length(messages)
	var/list/history = list()
	var/older_before
	if(is_group && length(viewer.blocked_accounts))
		for(var/index = last_index; index >= 1; index--)
			var/list/message = messages[index]
			if((message["sender_id"] in viewer.blocked_accounts) || (message["actor_id"] in viewer.blocked_accounts))
				continue
			if(length(history) == INCREW_HISTORY_SIZE)
				var/list/oldest = history[length(history)]
				older_before = oldest["id"]
				break
			history += list(message)
		reverse_range(history)
	else if(last_index)
		var/start_index = max(1, last_index - INCREW_HISTORY_SIZE + 1)
		history = messages.Copy(start_index, last_index + 1)
		if(start_index > 1)
			older_before = start_index

	return list(
		"chat_id" = UID(),
		"chat_members" = member_rows,
		"messages" = history,
		"older_before" = older_before,
		"showing_latest" = !before,
	)
