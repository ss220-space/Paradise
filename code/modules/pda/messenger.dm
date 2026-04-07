/*
Чо не забыть сделать:
* Убрать уже существующие личные чаты из чатов на выбор
* Сделать защиту на создание дубликатов чатов

*/
/datum/data/pda/app/messenger
	name = "InCrew"
	icon = "comments"
	title = "InCrew"
	notify_icon = "comments"
	template = "pda_raingor_messenger"

	// последний из входящих аккаунтов, снапшот называемый
	var/datum/messenger_account/last_login_owner

	// Используем флаг вместо того, что бы пользоваться логин системой, которая у терминалов.
	var/can_login = FALSE

/datum/data/pda/app/messenger/update_ui(mob/user, list/data)
	// выполняем вход в аккаунт
	var/datum/messenger_account/owner_messenger_account = login_in_messenger(data)

	// Проверяем на то, что если человек не смог залогиниться ему в UI высветило сообщение о обязательном логине
	if(!can_login)
		return

	data["owner_messenger_account"] = owner_messenger_account.get_account_info()

	var/list/chats = list()
	for(var/datum/messenger_chat/user_chat as anything in owner_messenger_account.active_chat)
		chats += list(user_chat.get_ui_data())

	data["chats"] = chats

/datum/data/pda/app/messenger/ui_act(action, params)
	switch(action)
		if("create_private_chat")
			var/target_name = params["target"]
			create_private_chat(target_name, last_login_owner)
		if("sendMessage")
			var/sended_message = params["sendedMessage"]
			var/chat_id = params["chatId"]
			send_message_to_chat(sended_message, chat_id, last_login_owner)

		// if("open_chat")
		// if("delete_chat")

// Логинимся и возвращаем аккаунт, либо выдаем null
/datum/data/pda/app/messenger/proc/login_in_messenger(list/data)
	// Проверяем зашел ли человек в аккаунт в мессенджере
	var/now_id = pda.id
	if(!now_id && !last_login_owner)
		return null

	// Находим человека в базе аккаунтов
	var/datum/money_account/owner_money_account = get_account_with_name(pda.owner)
	if(!owner_money_account)
		return null

	// так как тут выше был money_account запихиваем возможные таргеты
	data["targets"] = get_possible_targets(owner_money_account)

	// берем аккаунт мессенджера из аккаунта человека+
	var/datum/messenger_account/owner_messenger_account = owner_money_account.messenger_profile
	if(!owner_messenger_account)
		return null

	// делаем скриншот, что бы заново не надо было вставлять айди карту
	can_login = TRUE
	last_login_owner = owner_messenger_account
	data["can_login"] = can_login
	return owner_messenger_account

// передает в UI возможные тагреты для создания личных/групповых чатов
/datum/data/pda/app/messenger/proc/get_possible_targets(datum/money_account/exclude_account)
	// делам список с аккаунтами с которыми уже есть чат
	var/list/used_targets = list()
	for(var/datum/messenger_chat/removeable_chat as anything in exclude_account.messenger_profile.active_chat)
		removeable_chat.get_created_private_chat_users(used_targets, exclude_account)

	var/list/possible_targets = list()
	for(var/datum/money_account/target_account as anything in GLOB.all_money_accounts)
		if(!(target_account.owner_name == exclude_account.owner_name) && \
			!check_account_in_list(target_account.messenger_profile, used_targets))
			possible_targets.Add(target_account.owner_name)
	return possible_targets

