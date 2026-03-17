/datum/data/pda/app/messenger
	name = "InCrew"
	icon = "comments-o"
	title = "InCrew"
	notify_icon = "comments"
	template = "pda_raingor_messenger"

	/// I used money_account as the user account
	/// this will allow me to add card login if necessary
	var/datum/messenger_account/last_login_owner

	/// Using this flag we make it possible to log in and out of the messenger
	var/can_login = FALSE

/datum/data/pda/app/messenger/update_ui(mob/user, list/data)
	var/datum/messenger_account/owner_messenger_account = login_in_messenger()

	can_login = (owner_messenger_account)

	data["can_login"] = can_login
	data["owner_messenger_account"] = get_account_info(owner_messenger_account)

	var/list/chats = list()
	for(var/datum/messenger_chat/user_chat as anything in owner_messenger_account.active_chat)
		chats.Add(user_chat.get_ui_data())

	data["chats"] = chats

/datum/data/pda/app/messenger/proc/login_in_messenger()
	// Сhecking for the presence of a bank account
	var/datum/money_account/owner_money_account = get_account_with_name(pda.owner)
	if(!owner_money_account)
		return null

	// Checking the existence of a Messenger account using a bank account
	var/datum/messenger_account/owner_messenger_account = owner_money_account.messenger_profile
	if(!owner_messenger_account)
		return null

	// Determine the currently inserted ID card
	var/current_id = pda.id

	if(!current_id || last_login_owner)
		return null

	last_login_owner = pda.id
	return owner_messenger_account
