/datum/data/pda/app/main_menu
	icon = "home"
	template = "pda_main_menu"
	hidden = 1

/datum/data/pda/app/main_menu/update_ui(mob/user as mob, list/data)
	title = pda.name

	data["app"]["is_home"] = TRUE

	data["apps"] = pda.shortcut_cache
	data["categories"] = pda.shortcut_cat_order
	data["pai"] = !isnull(pda.pai)				// pAI inserted?

	var/list/notifying = list()
	for(var/datum/data/pda/P in pda.notifying_programs)
		notifying["[P.UID()]"] = TRUE
	data["notifying"] = notifying

/datum/data/pda/app/main_menu/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("UpdateInfo")
			pda.ownjob = pda.id.assignment
			pda.ownrank = pda.id.rank
			pda.owner = pda.id.registered_name
			pda.update_appearance(UPDATE_NAME)
			if(!pda.silent)
				playsound(pda, 'sound/machines/terminal_processing.ogg', 15, TRUE)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), pda, 'sound/machines/terminal_success.ogg', 15, TRUE), 1.3 SECONDS)
		if("pai")
			if(pda.pai)
				if(pda.pai.loc != pda)
					pda.pai = null
				else
					switch(text2num(params["option"]))
						if(1)		// Configure pAI device
							pda.pai.attack_self(usr)
						if(2)		// Eject pAI device
							var/turf/T = get_turf(pda.loc)
							if(T)
								pda.pai.forceMove(T)
								pda.pai = null
								playsound(pda, 'sound/machines/terminal_eject.ogg', 50, TRUE)

/datum/data/pda/app/notekeeper
	name = "Notekeeper"
	icon = "sticky-note-o"
	template = "pda_notes"

	var/note

/datum/data/pda/app/notekeeper/start()
	. = ..()
	if(!note)
		note = "Congratulations, your station has chosen the [pda.model_name]!"

/datum/data/pda/app/notekeeper/update_ui(mob/user as mob, list/data)
	data["note"] = html_decode(note)	/// current pda notes

/datum/data/pda/app/notekeeper/ui_act(action, params)
	if(..())
		return

	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

	. = TRUE

	switch(action)
		if("Edit")
			var/n = tgui_input_text(usr, "Please enter message", name, note, multiline = TRUE, encode = FALSE)
			if(isnull(n))
				return

			if(pda.loc == usr)
				note = n
			else
				pda.close(usr)

/datum/data/pda/app/manifest
	name = "Crew Manifest"
	icon = "user"
	template = "pda_manifest"
	update = PDA_APP_UPDATE_SLOW

/datum/data/pda/app/manifest/update_ui(mob/user as mob, list/data)
	GLOB.data_core.get_manifest_json()
	data["manifest"] = GLOB.PDA_Manifest

/datum/data/pda/app/atmos_scanner
	name = "Atmospheric Scan"
	icon = "fire"
	template = "pda_atmos_scan"
	category = "Utilities"
	update = PDA_APP_UPDATE_SLOW

/datum/data/pda/app/atmos_scanner/update_ui(mob/user as mob, list/data)
	var/list/results = list()
	var/turf/location = get_turf(user.loc)
	if(!isnull(location))
		var/datum/gas_mixture/environment = location.get_readonly_air()

		var/pressure = environment.return_pressure()
		var/total_moles = environment.total_moles()

		if(total_moles)
			var/o2_level = environment.oxygen()/total_moles
			var/n2_level = environment.nitrogen() / total_moles
			var/co2_level = environment.carbon_dioxide() / total_moles
			var/plasma_level = environment.toxins() / total_moles
			var/n2o_level = environment.sleeping_agent() / total_moles
			var/h2_level = environment.hydrogen() / total_moles
			var/h2o_level = environment.water_vapor() / total_moles
			var/unknown_level = 1 - (o2_level + n2_level + co2_level + plasma_level + n2o_level + h2_level)
			results = list(
				list("entry" = "Pressure", "units" = "kPa", "val" = "[round(pressure, 0.1)]", "bad_high" = 120, "poor_high" = 110, "poor_low" = 95, "bad_low" = 80),
				list("entry" = "Temperature", "units" = "C", "val" = "[round(environment.temperature() - T0C, 0.1)]", "bad_high" = 35, "poor_high" = 25, "poor_low" = 15, "bad_low" = 5),
				list("entry" = "Oxygen", "units" = "%", "val" = "[round(o2_level * 100, 0.1)]", "bad_high" = 140, "poor_high" = 135, "poor_low" = 19, "bad_low" = 17),
				list("entry" = "Nitrogen", "units" = "%", "val" = "[round(n2_level * 100, 0.1)]", "bad_high" = 105, "poor_high" = 85, "poor_low" = 50, "bad_low" = 40),
				list("entry" = "Carbon Dioxide", "units" = "%", "val" = "[round(co2_level * 100, 0.1)]", "bad_high" = 10, "poor_high" = 5, "poor_low" = 0, "bad_low" = 0),
				list("entry" = "Plasma", "units" = "%", "val" = "[round(plasma_level * 100, 0.01)]", "bad_high" = 0.5, "poor_high" = 0, "poor_low" = 0, "bad_low" = 0),
				list("entry" = "Nitrous Oxide", "units" = "%", "val" = "[round(n2o_level * 100, 0.01)]", "bad_high" = 0.5, "poor_high" = 0, "poor_low" = 0, "bad_low" = 0),
				list("entry" = "Hydrogen", "units" = "%", "val" = "[round(h2_level * 100, 0.01)]", "bad_high" = 0.5, "poor_high" = 0, "poor_low" = 0, "bad_low" = 0),
				list("entry" = "Water Vapor", "units" = "%", "val" = "[round(h2o_level * 100, 0.1)]", "bad_high" = 100, "poor_high" = 80, "poor_low" = 0, "bad_low" = 0),
				list("entry" = "Other", "units" = "%", "val" = "[round(unknown_level * 100, 0.01)]", "bad_high" = 1, "poor_high" = 0.5, "poor_low" = 0, "bad_low" = 0)
			)

	if(isnull(results))
		results = list(list("entry" = "pressure", "units" = "%", "val" = "0", "bad_high" = 120, "poor_high" = 110, "poor_low" = 95, "bad_low" = 80))

	data["aircontents"] = results

/datum/data/pda/app/bank
	name = "Raingor Interstellar Banking" /// this is the perfect name for a bank. (do not change)
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

	// note for posterity: The ancestors' crappy code doesn't allow
	// using ui_login_act without an object reference,
	// which is pretty sad. I won't take responsibility
	// for the refactor, so we'll rely on pda.

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

			subs_list.Add(list(list(
				"subscription_name" = registered_sub.subscription_name,
				"recipient_name" = counterpart_name,
				"cost" = registered_sub.cost,
				"interval" = registered_sub.interval,
				"status" = registered_sub.active,
				"description" = registered_sub.description,
				"secure" = registered_sub.secure,
				"subscription_type" = registered_sub.subscription_type_path,
				"direction" = (registered_sub.subscriber_account == owner_bank_account) ? "outgoing" : "incoming"
			)))

	// subscriptions that can be purchased
	for(var/datum/subscription/purchased_subscription as anything in GLOB.available_subscriptions)
		if(purchased_subscription.subscription_name in active_sub_names)
			continue

		// check for "forced subscription"
		if(purchased_subscription.secure)
			continue

		available_sub_list.Add(list(list(
			"available_subscription_name" = purchased_subscription.subscription_name,
			"description" = purchased_subscription.description,
			"cost" = purchased_subscription.cost,
			"interval" = purchased_subscription.interval,
			"provider" = "Нет доступа",
			"secure" = purchased_subscription.secure,
			"subscription_type" = purchased_subscription.subscription_type_path
		)))

	data["balance"] = owner_bank_account.money
	data["transactions"] = transactions_list
	/// Here are the names of the people/terminals where you can transfer money
	data["targets"] = possible_targets
	/// Subscriptions that are already registered in the user's name
	data["subscriptions"] = subs_list
	/// Subscriptions that are NOT registered in the user's name and for them
	/// you will need to create a new one
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
			var/sub_account_name = pda.owner
			var/datum/subscription/target = find_subscription_with_name(sub_account_name, available_sub_name)

			if(!target)
				to_chat(usr, span_warning("Ошибка: подписка '[available_sub_name]' не найдена"))
				return

			target.cancel()
			return

		if("resume_subscription")
			var/available_subscrip_name = params["subscription_name"]
			var/subscriber_acc_name = pda.owner

			if(available_subscrip_name && subscriber_acc_name)
				var/datum/subscription/added_subscription = find_subscription_with_name(subscriber_acc_name, available_subscrip_name)

				if(!added_subscription)
					to_chat(usr, span_warning("Ошибка: подписка '[available_subscrip_name]' не найдена."))
					return

				added_subscription.resub()
				return


