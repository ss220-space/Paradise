/**
 * Extending money_account to messenger_account
 */
/datum/messenger_account
	/// chats the person is a member of
	var/list/datum/messenger_chat/active_chat = list()
	/// Counts how many unread messages there are in each chat.
	var/list/unread_counts = list()
	/// money_account how user account
	var/datum/money_account/owner

/datum/messenger_account/New(datum/money_account/owner_account)
	src.owner = owner_account

/datum/messenger_account/proc/add_chat(datum/messenger_chat/added_chat)
	unread_counts[added_chat.name_chat] = 0
	active_chat += added_chat


/datum/messenger_account/proc/get_account_info()
	var/list/member = list()

	member["name"] = owner.owner_name
	member["account_number"] = owner.account_number

	return member

/proc/increment_unread_counts(datum/messenger_chat/added_chat, datum/messenger_account/owner)
	var/count_unread = owner.unread_counts[added_chat.name_chat]
	count_unread++
	owner.unread_counts[added_chat.name_chat] = count_unread

/**
 * Iterates through the input list,
 * checking whether the account exists in the given list.
 */
/proc/check_account_in_list(datum/messenger_account/checked_account, list/checked_list)
	for(var/datum/messenger_account/selected_account as anything in checked_list)
		if(selected_account.owner.account_number == checked_account.owner.account_number)
			return TRUE
	return FALSE
