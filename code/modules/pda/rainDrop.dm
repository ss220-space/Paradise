GLOBAL_LIST_EMPTY(raindrop_active_offers)

/datum/data/pda/app/rainDrop
	name = "RainDrop"
	icon = "briefcase"
	title = "RainDrop"
	template = "pda_rainDrop"

	/// PDA owner account
	var/datum/rainDrop_account/last_login_owner

	// Используем флаг вместо того, что бы пользоваться логин системой, которая у терминалов.
	var/can_login = FALSE

/datum/data/pda/app/rainDrop/update_ui(mob/user, list/data)
	var/datum/rainDrop_account/owner_rainDrop_account = login_in_messenger(data)
	if(!can_login)
		return

	if(!owner_rainDrop_account)
		return data

	data["account"] = owner_rainDrop_account.get_account_info()

	var/list/offers = list()
	for(var/datum/rainDrop_offer/offer as anything in GLOB.rainDrop_offers)
		offers += list(offer.get_offer_data())

	data["offers"] = offers

/datum/data/pda/app/rainDrop/ui_act(action, list/params)
	switch(action)
		if("create_offer")
			var/title = params["title"]
			var/description = params["description"]
			var/reward = params["reward"]
			create_rainDrop_offer(last_login_owner, title, description, reward)
			return TRUE
		if("take_offer")
			var/id = params["id"]
			var/datum/rainDrop_offer = locateUID(id)
			take_rainDrop_offer(rainDrop_offer, last_login_owner)
			return TRUE
		if("complete_offer")
			var/id = params["id"]
			var/datum/rainDrop_offer = locateUID(id)
			var/rating = params["rating"]
			complete_rainDrop_offer(rainDrop_offer, rating)
			return TRUE
		if("cancel_offer")
			var/id = params["id"]
			var/datum/rainDrop_offer = locateUID(id)
			cancel_rainDrop_offer(rainDrop_offer)
			return TRUE
		if("dispute_offer")
			var/id = params["id"]
			var/datum/rainDrop_offer = locateUID(id)
			dispute_rainDrop_offer(rainDrop_offer)
			return TRUE

// Логинимся и возвращаем аккаунт, либо выдаем null
/datum/data/pda/app/rainDrop/proc/login_in_messenger(list/data)
	// Проверяем зашел ли человек в аккаунт в мессенджере
	var/now_id = pda.id
	if(!now_id && !last_login_owner)
		return null

	// Находим человека в базе аккаунтов
	var/datum/money_account/owner_money_account = get_account_with_name(pda.owner)
	if(!owner_money_account)
		return null

	// так как тут выше был money_account запихиваем возможные таргеты
	data["allTargets"] = get_all_targets(owner_money_account)

	// берем аккаунт мессенджера из аккаунта человека+
	var/datum/rainDrop_account/owner_rainDrop_account = owner_money_account.rainDrop_account
	if(!owner_rainDrop_account)
		return null

	// делаем скриншот, что бы заново не надо было вставлять айди карту
	can_login = TRUE
	last_login_owner = owner_rainDrop_account
	data["can_login"] = can_login
	return owner_rainDrop_account

// передает в UI все таргеты для создания личных/групповых чатов
/datum/data/pda/app/rainDrop/proc/get_all_targets(datum/money_account/exclude_account)
	var/list/all_targets = list()
	for(var/datum/money_account/target_account as anything in GLOB.all_money_accounts)
		if(target_account.owner_name != exclude_account.owner_name)
			all_targets.Add(target_account.owner_name)
	return all_targets
