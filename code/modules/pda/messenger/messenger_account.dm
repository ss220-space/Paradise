/datum/messenger_account
	var/datum/money_account/owner
	/// Chat UID -> chat.
	var/list/chats = list()
	/// Other profile -> private chat.
	var/list/private_chats

/datum/messenger_account/New(datum/money_account/owner)
	src.owner = owner
	return ..()

/datum/messenger_account/Destroy()
	for(var/chat_id in chats.Copy())
		var/datum/messenger_chat/chat = chats[chat_id]
		if(!chat.is_group || chat.owner == src)
			qdel(chat)
		else
			chat.remove_member(src)
	private_chats = null
	owner = null
	return ..()

/datum/messenger_account/proc/get_ui_data()
	owner.set_photo()
	return list(
		"id" = owner.UID(),
		"name" = owner.owner_name,
		"photo" = owner.photo,
	)
