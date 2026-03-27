/datum/data/pda/app/messenger
	name = "InCrew"
	icon = "comments-o"
	title = "InCrew"
	notify_icon = "comments"
	template = "pda_raingor_messenger"

	// последний из входящих аккаунтов, снапшот называемый
	var/datum/messenger_account/last_login_owner

	// Используем флаг вместо того, что бы пользоваться логин системой, которая у терминалов.
	var/can_login = FALSE

/datum/data/pda/app/messenger/update_ui(mob/user, list/data)
	// выполняем вход в аккаунт
	var/datum/messenger_account/owner_messenger_account = login_in_messenger()
	data["can_login"] = can_login

	// Проверяем на то, что если человек не смог залогиниться ему в UI высветило сообщение о обязательном логине
	if(!can_login)
		return

	data["owner_messenger_account"] = owner_messenger_account.get_account_info()

	var/list/chats = list()
	for(var/datum/messenger_chat/user_chat as anything in owner_messenger_account.active_chat)
		chats.Add(user_chat.get_ui_data())

	data["chats"] = chats

// Логинимся и возвращаем аккаунт, либо выдаем null
/datum/data/pda/app/messenger/proc/login_in_messenger()
	// Проверяем зашел ли человек в аккаунт в мессенджере
	var/now_id = pda.id
	if(!now_id && !last_login_owner)
		return null

	// Находим человека в базе аккаунтов
	var/datum/money_account/owner_money_account = get_account_with_name(pda.owner)
	if(!owner_money_account)
		return null

	// берем аккаунт мессенджера из аккаунта человека+
	var/datum/messenger_account/owner_messenger_account = owner_money_account.messenger_profile
	if(!owner_messenger_account)
		return null

	// делаем скриншот, что бы заново не надо было вставлять айди карту
	can_login = TRUE
	last_login_owner = owner_messenger_account

	return owner_messenger_account
