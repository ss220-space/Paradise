/datum/data/pda/app/bank
	name = "Raingor Interstellar Bank"
	title = "Raingor Interstellar Bank"
	icon = "university"
	template = "pda_bank"
	update = PDA_APP_UPDATE_SLOW

	var/last_login_card_id
	var/last_login_name

/datum/data/pda/app/bank/update_ui(mob/user, list/data)
	pda.ui_login_data(data, user)
	var/datum/ui_login/login = pda.ui_login_get()
	var/obj/item/card/id/current_card = pda.id

	if(current_card && current_card != last_login_card_id)
		last_login_card_id = current_card
		last_login_name = current_card.registered_name

	if(!current_card && !last_login_card_id)
		login.logged_in = FALSE
		return

	var/obj/item/card/id/active_card = current_card ? current_card : last_login_card_id

	if(!active_card)
		login.logged_in = FALSE
		return

	var/account_name = last_login_name
	var/datum/money_account/owner_bank_account = get_account_with_name(account_name)

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
	data["targets"] = get_possible_targets(owner_bank_account)

	var/list/subscriptions_data = get_active_subscriptions(owner_bank_account)

	data["subscriptions"] = subscriptions_data
	data["availableSubs"] = get_available_subscriptions(subscriptions_data, owner_bank_account)
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
	var/list/subscriptions = user_account.subscriptions
	for(var/datum/weakref/registered_sub_ref as anything in (subscriptions | user_account.possible_resubscriptions))
		var/datum/economy_process/subscription/registered_sub = registered_sub_ref?.resolve()
		if(!registered_sub)
			continue
		var/list/subscription_ui_data = registered_sub.get_base_subscription_ui_data()
		subscription_ui_data["status"] = (registered_sub_ref in subscriptions)
		subs_list.Add(list(subscription_ui_data))

	return subs_list

/datum/data/pda/app/bank/proc/get_available_subscriptions(list/exclude_names, datum/money_account/owner_bank_account)
	var/list/available_sub_list = list()
	var/datum/money_account/account = owner_bank_account
	var/list/subscriptions = account.subscriptions
	var/list/possible_resubscriptions = account.possible_resubscriptions
	for(var/key, value in GLOB.all_subscriptions)
		var/datum/economy_process/subscription/purchased_subscription = value
		if(purchased_subscription.recipient_account == account)
			continue
		var/datum/weakref/weakref = WEAKREF(purchased_subscription)
		if(weakref in subscriptions)
			continue
		if(weakref in possible_resubscriptions)
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
			var/amount = params["amount"]
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
			var/subscription_uid = params["available_subscription_uid"]
			var/datum/economy_process/subscription/sub = locateUID(subscription_uid)
			if(!sub)
				to_chat(usr, span_warning("Ошибка: подписка не найдена."))
				return

			var/datum/money_account/sub_acc = get_account_with_name(pda.owner)
			if(!sub_acc)
				to_chat(usr, span_warning("Ошибка аккаунта."))
				return

			sub.sub(sub_acc)
			return

		if("cancel_subscription")
			var/sub_uid = params["uid"]
			var/datum/economy_process/subscription/target = locateUID(sub_uid)
			var/datum/money_account/sub_acc = get_account_with_name(pda.owner)
			if(!sub_acc)
				to_chat(usr, span_warning("Ошибка аккаунта."))
				return
			if(!target)
				to_chat(usr, span_warning("Ошибка: подписка не найдена"))
				return

			target.unsub(sub_acc)
			return

		if("resume_subscription")
			var/sub_uid = params["uid"]
			var/datum/money_account/sub_acc = get_account_with_name(pda.owner)
			if(!sub_acc)
				to_chat(usr, span_warning("Ошибка аккаунта."))
				return
			var/datum/economy_process/subscription/added_subscription = locateUID(sub_uid)
			if(!added_subscription)
				to_chat(usr, span_warning("Ошибка: подписка не найдена."))
				return

			added_subscription.sub(sub_acc)
			return

