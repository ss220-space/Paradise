/datum/data/pda/app/bank
	name = "Raingor Interstellar Banking" // this is the perfect name for a bank. (do not change)
	title = "Raingor Interstellar Banking"
	icon = "university"
	template = "pda_bank"
	update = PDA_APP_UPDATE_SLOW

	/// Snapshot
	var/last_login_card_id

/datum/data/pda/app/bank/update_ui(mob/user, list/data)
	var/datum/money_account/owner_bank_account = get_account_with_name(pda.owner)
	var/list/transactions_list = list()
	var/list/possible_targets = list()
	var/list/subs_list = list()
	var/list/available_sub_list = list()

	if(owner_bank_account == null)
		data["name"] = "unknown"
		data["balance"] = 0
		data["transactions"] = list()
		return

	data["name"] = owner_bank_account.owner_name

	// Login and get access
	pda.ui_login_data(data, user)
	var/datum/ui_login/login = pda.ui_login_get()

	if(!pda.id && !(data["loginState"]["logged_in"]))
		return

	if(pda.id)
		last_login_card_id = pda.id

	var/obj/item/card/id/checked_card = pda.id || last_login_card_id

	if(!checked_card)
		return

	login.id = checked_card
	login.name = checked_card.registered_name
	login.rank = checked_card.assignment
	login.access = checked_card.access
	login.law_level = checked_card.law_level
	login.logged_in = TRUE

	if(!data["loginState"]["logged_in"])
		return

	for(var/datum/transaction/account_transaction as anything in owner_bank_account.transaction_log)
		transactions_list.Add(list(list(
			"date" = account_transaction.date,
			"time" = account_transaction.time,
			"target_name" = account_transaction.target_name,
			"purpose" = account_transaction.purpose,
			"amount" = account_transaction.amount,
			"source_terminal" = account_transaction.source_terminal
		)))

	for(var/datum/money_account/target_account as anything in GLOB.all_money_accounts)
		if(!target_account.suspended && !(target_account.owner_name == owner_bank_account.owner_name))
			possible_targets.Add(target_account.owner_name)

	/// This list will store the names of subscriptions to which a person has already subscribed
	/// or interacted, so as not to re-create the subscription.
	var/list/active_sub_names = list()

	// We collect all subscriptions that were registered in a person's name.
	// We use this to create a separate list in TGUI.
	for(var/datum/subscription/registered_sub as anything in GLOB.all_subscriptions)
		/// Check if the player is either a subscriber or a recipient
		var/is_player_involved = (registered_sub.subscriber_account == owner_bank_account) || (registered_sub.recipient_account == owner_bank_account)

		if(is_player_involved)
			active_sub_names.Add(registered_sub.subscription_name)

			var/counterpart_name = "Неизвестно"

			if(registered_sub.subscriber_account == owner_bank_account)
				counterpart_name = registered_sub.recipient_account.owner_name
			else
				counterpart_name = registered_sub.subscriber_account.owner_name

			subs_list.Add(list(registered_sub.get_base_subscription_ui_data(counterpart_name,
				(registered_sub.subscriber_account == owner_bank_account) ? "outgoing" : "incoming")))

	// subscriptions that can be purchased
	for(var/datum/subscription/purchased_subscription as anything in GLOB.available_subscriptions)
		if(purchased_subscription.subscription_name in active_sub_names)
			continue

		// check for "forced subscription"
		if(purchased_subscription.secure)
			continue

		available_sub_list.Add(list(purchased_subscription.get_template_subscription_ui_data()))

	data["balance"] = owner_bank_account.money
	data["transactions"] = transactions_list
	// Here are the names of the people/terminals where you can transfer money
	data["targets"] = possible_targets
	// Subscriptions that are already registered in the user's name
	data["subscriptions"] = subs_list
	// Subscriptions that are NOT registered in the user's name and for them
	// you will need to create a new one
	data["availableSubs"] = available_sub_list
	data["account_suspended"] = owner_bank_account.suspended

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

			//If you have additional parameters, write them something like this:
			// if(sub_type == /datum/subscription/salary_modifier)
			//	    body
			//	    extra_params["modifier"] = modifier

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

