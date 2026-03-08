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
	data["note"] = html_decode(note)	// current pda notes

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
	name = "Raingor Interstellar Banking" // this is the perfect name for a bank. (do not change)
	title = "Raingor Interstellar Banking"
	icon = "university"
	template = "pda_bank"
	category = "General"
	update = PDA_APP_UPDATE_SLOW

// TODO: LOGIN
/datum/data/pda/app/bank/update_ui(mob/user as mob, list/data)
	var/datum/money_account/owner_bank_account = get_account_with_name(pda.owner)
	var/list/transactions_list = list()
	var/list/possible_targets = list()
	var/list/subs_list = list()
	var/list/available_sub_list = list()

	if(owner_bank_account == null)
		data["name"] = "unknow"
		data["balance"] = 0
		data["transactions"] = list()
		return

	for(var/datum/transaction/T in owner_bank_account.transaction_log)
		transactions_list.Add(list(list(
			"date" = T.date,
			"time" = T.time,
			"target_name" = T.target_name,
			"purpose" = T.purpose,
			"amount" = T.amount,
			"source_terminal" = T.source_terminal
		)))

	for(var/datum/money_account/Target_account in GLOB.all_money_accounts)
		if(!Target_account.suspended && !(Target_account.owner_name == owner_bank_account.owner_name))
			possible_targets.Add(Target_account.owner_name)

	//This list will store the names of subscriptions to which a person has already subscribed
	//or interacted, so as not to re-create the subscription.
	var/list/active_sub_names = list()

	// We collect all subscriptions that were registered in a person's name.
	// We use this to create a separate list in TGUI.
	for(var/datum/subscription/Ss in GLOB.all_subscriptions)
		if(!Ss || !Ss.subscriber_account || !Ss.subscriber_account)
			continue

		if(Ss.subscriber_account == owner_bank_account)
			active_sub_names.Add(Ss.subscription_name)
			subs_list.Add(list(list(
				"subscription_name" = Ss.subscription_name,
				"recipient_name" = Ss.recipient_account.owner_name,
				"cost" = Ss.cost,
				"interval" = Ss.interval,
				"status" = Ss.active,
				"description" = Ss.description
			)))

	// subscriptions that can be purchased
	for(var/datum/subscription/S in GLOB.available_subscriptions)
		if(S.subscription_name in active_sub_names)
			continue

		available_sub_list.Add(list(list(
			"available_subscription_name" = S.subscription_name,
			"description" = S.description,
			"cost" = S.cost,
			"interval" = S.interval,
			"provider" = "Нет доступа"
		)))

	data["name"] = owner_bank_account.owner_name
	data["balance"] = owner_bank_account.money
	data["transactions"] = transactions_list
	data["targets"] = possible_targets // Here are the names of the people/terminals where you can transfer money
	data["subscriptions"] = subs_list // Subscriptions that are already registered in the user's name
	data["availableSubs"] = available_sub_list // Subscriptions that are NOT registered in the user's name and for them you will need to create a new one

/datum/data/pda/app/bank/ui_act(action, params)
	switch(action)
		if("transfer")
			var/target = params["target"]
			var/amount = text2num(params["amount"])
			var/purpose = params["purpose"]

			var/datum/money_account/RecipientUser = get_account_with_name(target)
			var/datum/money_account/SenderUser = get_account_with_name(pda.owner)

			// without this u cant use charge_to_account
			var/obj/machinery/computer/account_database/linked_db

			// antidurak protection
			if(!SenderUser)
				return

			if(!RecipientUser)
				return

			if(SenderUser.suspended || RecipientUser.suspended)
				return

			if(amount <= 0)
				return

			if(SenderUser.money < amount)
				return

			// search db account
			// todo: refactor
			for(var/obj/machinery/computer/account_database/DB in SSmachines.get_by_type(/obj/machinery/computer/account_database))
				if(DB.stat & NOPOWER || !DB.activated)
					continue
				linked_db = DB
				break

			if(!linked_db)
				return

			linked_db.charge_to_account(RecipientUser.account_number, SenderUser, purpose, "Терминал Raingor Interstellar Banking", amount)

		if("add_subscription")
			var/available_subscription_name = params["available_subscription_name"]
			var/subscriber_account_name = pda.owner
			var/datum/subscription/existing = find_subscription_with_name(subscriber_account_name, available_subscription_name)
			var/datum/subscription/template = null
			var/datum/money_account/sub_acc = get_account_with_name(subscriber_account_name)

			if(!sub_acc)
				to_chat(usr, span_warning("Ошибка аккаунта."))
				return

			//Is this subscription already issued?
			if(existing)
				to_chat(usr, span_warning("У вас уже есть активная подписка на '[available_subscription_name]'."))
				return

			//Search for a template in available subscriptions
			for(var/datum/subscription/S in GLOB.available_subscriptions)
				if(S && S.subscription_name == available_subscription_name)
					template = S
					break

			if(!template)
				to_chat(usr, span_warning("Ошибка: подписка '[available_subscription_name]' не найдена в каталоге."))
				return

			var/datum/subscription/new_sub = new /datum/subscription(
				sub_acc,           			  // subscriber
				template.recipient_account,   // recipient
				template.cost,                // cost
				template.interval,            // interval
				template.subscription_name,   // name
				template.description          // description
			)

			to_chat(usr, span_notice("Подписка '[available_subscription_name]' успешно оформлена."))
			return

		if("cancel_subscription")
			var/available_subscription_name = params["available_subscription_name"]
			var/subscriber_account_name = pda.owner
			var/datum/subscription/target = find_subscription_with_name(subscriber_account_name, available_subscription_name)

			if(!target)
				to_chat(usr, span_warning("Ошибка: подписка '[available_subscription_name]' не найдена"))
				return

			target.cancel()
			return

		if("resume_subscription")
			var/available_subscription_name = params["available_subscription_name"]
			var/subscriber_account_name = pda.owner


			if(available_subscription_name && subscriber_account_name)
				var/datum/subscription/added_subscription = find_subscription_with_name(subscriber_account_name, available_subscription_name)

				if(!added_subscription)
					to_chat(usr, span_warning("Ошибка: подписка '[available_subscription_name]' не найдена."))
					return

				added_subscription.resub()
				return
