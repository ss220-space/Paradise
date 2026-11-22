GLOBAL_LIST_EMPTY(increw_public_groups)

/datum/messenger_chat
	var/name
	var/description
	/// Group owner.
	var/datum/messenger_account/owner
	var/is_group = FALSE
	var/is_public = FALSE
	/// Account UID -> profile.
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
	if(is_public)
		GLOB.increw_public_groups -= UID()

	if(!is_group && length(members) == 2)
		var/datum/messenger_account/first = members[members[1]]
		var/datum/messenger_account/second = members[members[2]]
		LAZYREMOVE(first.private_chats, second)
		LAZYREMOVE(second.private_chats, first)

	for(var/member_id in members.Copy())
		remove_member(members[member_id])
	messages = null
	owner = null
	return ..()

/datum/messenger_chat/proc/set_public(public)
	if(!is_group || !isnum(public) || (public != TRUE && public != FALSE) || is_public == public)
		return FALSE

	is_public = public
	if(is_public)
		GLOB.increw_public_groups[UID()] = src
	else
		GLOB.increw_public_groups -= UID()
	return TRUE

/datum/messenger_chat/proc/add_member(datum/messenger_account/member)
	var/member_id = member.owner.UID()
	if(members[member_id])
		return FALSE
	members[member_id] = member
	member.chats[UID()] = src
	return TRUE

/datum/messenger_chat/proc/remove_member(datum/messenger_account/member)
	members -= member.owner.UID()
	member.chats -= UID()

/datum/messenger_chat/proc/add_message(message, datum/messenger_account/sender)
	messages += list(list(
		"id" = length(messages) + 1,
		"text_message" = message,
		"timestamp" = station_time_timestamp(),
		"sender_id" = sender?.owner.UID(),
		"sender_name" = sender ? sender.owner.owner_name : "InCrew",
	))

/datum/messenger_chat/proc/get_display_name(datum/messenger_account/viewer)
	if(is_group)
		return name

	for(var/member_id in members)
		var/datum/messenger_account/member = members[member_id]
		if(member != viewer)
			return "Личная переписка с [member.owner.owner_name]"
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
	)

/datum/messenger_chat/proc/get_details()
	var/list/member_rows = list()
	for(var/member_id in members)
		var/datum/messenger_account/member = members[member_id]
		member_rows += list(member.get_ui_data())
	return list("chat_id" = UID(), "chat_members" = member_rows, "messages" = messages)
