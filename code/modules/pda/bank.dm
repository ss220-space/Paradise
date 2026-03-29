/datum/data/pda/app/bank
	name = "Raingor Interstellar Banking" // this is the perfect name for a bank. (do not change)
	title = "Raingor Interstellar Banking"
	icon = "university"
	template = "pda_bank"
	update = PDA_APP_UPDATE_SLOW

	/// Snapshot
	var/last_login_card_id
	var/last_login_name

/datum/data/pda/app/bank/update_ui(mob/user, list/data)
	// Login and get access
	pda.ui_login_data(data, user)
	var/datum/ui_login/login = pda.ui_login_get()
	var/obj/item/card/id/current_card = pda.id

	// if new card in pda = new session on bank
	if(current_card && current_card != last_login_card_id)
		last_login_card_id = current_card
		last_login_name = current_card.registered_name

	// no card no session return
	if(!current_card && !last_login_card_id)
		login.logged_in = FALSE
		return

	var/obj/item/card/id/active_card = current_card ? current_card : last_login_card_id

	if(!active_card)
		login.logged_in = FALSE
		return

	var/account_name = last_login_name
	var/datum/money_account/owner_bank_account = get_account_with_name(account_name)

	// no acc no login
	if(!owner_bank_account)
		login.logged_in = FALSE
		return

	login.id = active_card
	login.name = active_card.registered_name
	login.rank = active_card.assignment
	login.access = active_card.access
	login.law_level = active_card.law_level
	login.logged_in = TRUE

	data["name"] = owner_bank_account.owner_name
	data["transactions"] = get_transactions_list(owner_bank_account)
	// Here are the names of the people/terminals where you can transfer money
	data["targets"] = get_possible_targets(owner_bank_account)

	var/list/subscriptions_data = get_active_subscriptions(owner_bank_account)

	// Subscriptions that are already registered in the user's name
	data["subscriptions"] = subscriptions_data["subscriptions"]
	// Subscriptions that are NOT registered in the user's name and for them
	// you will need to create a new one
	data["availableSubs"] = get_available_subscriptions(subscriptions_data["names"])
	data["balance"] = owner_bank_account.money
	data["account_suspended"] = owner_bank_account.suspended

/datum/data/pda/app/bank/proc/get_transactions_list(datum/money_account/account)
	var/list/transactions_list = list()
	for(var/datum/transaction/account_transaction as anything in account.transaction_log)
		transactions_list.Add(list(account_transaction.get_ui_data()))
	return transactions_list

/datum/data/pda/app/bank/proc/get_possible_targets(datum/money_account/exclude_account)
	var/list/possible_targets = list()
	for(var/datum/money_account/target_account as anything in GLOB.all_money_accounts)
		if(!target_account.suspended && !(target_account.owner_name == exclude_account.owner_name))
			possible_targets.Add(target_account.owner_name)
	return possible_targets

/datum/data/pda/app/bank/proc/get_active_subscriptions(datum/money_account/user_account)
	var/list/subs_list = list()
	var/list/active_sub_names = list()

	for(var/datum/subscription/registered_sub as anything in GLOB.all_subscriptions)
		var/is_player_involved = (registered_sub.subscriber_account == user_account) || (registered_sub.recipient_account == user_account)

		if(is_player_involved)
			active_sub_names.Add(registered_sub.subscription_name)

			var/counterpart_name = "Неизвестно"
			if(registered_sub.subscriber_account == user_account)
				counterpart_name = registered_sub.recipient_account.owner_name
			else
				counterpart_name = registered_sub.subscriber_account.owner_name

			subs_list.Add(list(registered_sub.get_base_subscription_ui_data(counterpart_name,
				(registered_sub.subscriber_account == user_account) ? "outgoing" : "incoming")))

	return list("names" = active_sub_names, "subscriptions" = subs_list)

/datum/data/pda/app/bank/proc/get_available_subscriptions(list/exclude_names)
	var/list/available_sub_list = list()

	for(var/datum/subscription/purchased_subscription as anything in GLOB.available_subscriptions)
		if(purchased_subscription.subscription_name in exclude_names)
			continue

		if(purchased_subscription.secure)
			continue

		available_sub_list.Add(list(purchased_subscription.get_template_subscription_ui_data()))

	return available_sub_list

/datum/data/pda/app/bank/ui_act(action, params)
	if(pda.ui_login_act(action, params))
		if(action == "login_logout")
			last_login_card_id = null
		return

	switch(action)
		if("transfer")
			var/target = params["target"]
			var/amount = text2num(params["amount"])
			var/purpose = params["purpose"]

			var/datum/money_account/recipient_user = get_account_with_name(target)
			var/datum/money_account/sender_user = get_account_with_name(pda.owner)

			if(!sender_user || !recipient_user || amount <= 0)
				to_chat(usr, span_warning("Ошибка: не удалось выполнить перевод."))
				return

			if(!sender_user.charge(amount, recipient_user, purpose, "Терминал Raingor Interstellar Banking №[rand(111,333)]", target, purpose, pda.owner))
				to_chat(usr, span_warning("Ошибка: не удалось выполнить перевод."))
				return

		if("add_subscription")
			var/sub_type = params["subscription_type"]
			sub_type = text2path(sub_type)
			if(!sub_type)
				to_chat(usr, span_warning("Ошибка: не указан тип подписки."))
				return

			var/datum/money_account/sub_acc = get_account_with_name(pda.owner)
			if(!sub_acc)
				to_chat(usr, span_warning("Ошибка аккаунта."))
				return

			/// additional options for your subscriptions
			var/list/extra_params = list()

			create_subscription(sub_acc, sub_type, extra_params)
			return

		if("cancel_subscription")
			var/available_sub_name = params["subscription_name"]
			var/sub_uid = params["uid"]
			var/datum/subscription/target = locateUID(sub_uid)

			if(!target)
				to_chat(usr, span_warning("Ошибка: подписка '[available_sub_name]' не найдена"))
				return

			target.cancel()
			return

		if("resume_subscription")
			var/available_subscrip_name = params["subscription_name"]
			var/sub_uid = params["uid"]

			if(available_subscrip_name && sub_uid)
				var/datum/subscription/added_subscription = locateUID(sub_uid)
				if(!added_subscription)
					to_chat(usr, span_warning("Ошибка: подписка '[available_subscrip_name]' не найдена."))
					return

				added_subscription.resub()
				return

