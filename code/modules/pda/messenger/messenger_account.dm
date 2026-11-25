/datum/messenger_account
	var/datum/money_account/owner
	var/list/chats = list()
	/// Other profile -> private chat.
	var/list/private_chats
	/// Chat -> unread count.
	var/list/unread_chats
	/// Account UID -> name. Kept for chat history.
	var/list/blocked_accounts
	var/datum/increw_call/active_call
	COOLDOWN_DECLARE(call_cooldown)
	COOLDOWN_DECLARE(photo_retry)

/datum/messenger_account/New(datum/money_account/owner)
	src.owner = owner
	return ..()

/datum/messenger_account/Destroy()
	active_call?.remove_member(src)
	for(var/datum/messenger_chat/chat as anything in chats)
		if(!chat.is_group || chat.owner == src)
			qdel(chat)
		else
			chat.remove_member(src)
	private_chats = null
	owner = null
	return ..()

/datum/messenger_account/proc/get_photo()
	if(!owner.photo && COOLDOWN_FINISHED(src, photo_retry))
		owner.set_photo()
		COOLDOWN_START(src, photo_retry, INCREW_PHOTO_RETRY)
	return owner.photo

/datum/messenger_account/proc/get_ui_data()
	return list(
		"id" = owner.UID(),
		"name" = owner.owner_name,
		"photo" = get_photo(),
	)

/datum/messenger_account/proc/blocks(datum/money_account/account)
	return length(blocked_accounts) && (account?.UID() in blocked_accounts)

/datum/messenger_account/proc/can_contact(datum/messenger_account/other)
	return !blocks(other.owner) && !other.blocks(owner)

/datum/messenger_account/proc/matches_card(obj/item/card/id/card)
	return card && card.associated_account_number == owner.account_number && card.registered_name == owner.owner_name

/datum/messenger_account/proc/notify_direct_message(datum/messenger_chat/chat, datum/messenger_account/sender, message)
	LAZYSET(unread_chats, chat, (unread_chats?[chat] || 0) + 1)
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
