/datum/messenger_account
	var/datum/money_account/owner
	/// Chat UID -> chat.
	var/list/chats = list()
	/// Other profile -> private chat.
	var/list/private_chats
	var/list/unread_chats
	/// Account UID -> name.
	var/list/blocked_accounts
	var/datum/increw_call/active_call
	COOLDOWN_DECLARE(call_cooldown)

/datum/messenger_account/New(datum/money_account/owner)
	src.owner = owner
	return ..()

/datum/messenger_account/Destroy()
	active_call?.remove_member(src)
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

/datum/messenger_account/proc/blocks(account_id)
	return account_id && !!blocked_accounts?[account_id]

/datum/messenger_account/proc/can_contact(datum/messenger_account/other)
	return !blocks(other.owner.UID()) && !other.blocks(owner.UID())

/datum/messenger_account/proc/matches_card(obj/item/card/id/card)
	return card && card.associated_account_number == owner.account_number && card.registered_name == owner.owner_name

/datum/messenger_account/proc/notify_direct_message(chat_id, datum/messenger_account/sender, message)
	LAZYSET(unread_chats, chat_id, (unread_chats?[chat_id] || 0) + 1)
	var/notice = "[span_bold("InCrew · [html_encode(sender.owner.owner_name)]")]<br>[html_encode(message)]"
	for(var/obj/item/pda/pda as anything in GLOB.PDAs)
		if(!isliving(pda.loc))
			continue
		var/obj/item/card/id/card = pda.id
		if(card?.loc == pda && !matches_card(card))
			continue
		var/datum/data/pda/app/increw/device = pda.find_program(/datum/data/pda/app/increw)
		if(device?.get_profile(pda.loc) == src)
			device.notify(notice)
