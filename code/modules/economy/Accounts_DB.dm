GLOBAL_VAR(current_date_string)

#define AUT_ACCLST 1
#define AUT_ACCINF 2
#define AUT_ACCNEW 3

/obj/machinery/computer/account_database
	name = "Accounts Uplink Terminal"
	desc = "Access transaction logs, account data and all kinds of other financial records."
	icon_screen = "accounts"
	req_access = list(ACCESS_HOP, ACCESS_CAPTAIN, ACCESS_CENT_COMMANDER)
	light_color = LIGHT_COLOR_GREEN
	var/receipt_num
	var/machine_id = ""
	var/datum/money_account/detailed_account_view
	var/activated = TRUE
	var/const/fund_cap = 1000000
	/// Current UI page
	var/current_page = AUT_ACCLST
	/// Next time a print can be made
	var/next_print = 0

/obj/machinery/computer/account_database/New()
	// Why the fuck are these not in a subsystem? They are global variables for fucks sake
	// If someone ever makes a map without one of these consoles, the entire eco AND date system breaks
	// This upsets me a lot
	// AA Todo: SSeconomy
	// TODO done, SScapitalism
	
	if(!GLOB.current_date_string)
		GLOB.current_date_string = "[time2text(world.timeofday, "DD Month")], [GLOB.game_year]"

	machine_id = "[station_name()] Acc. DB #[GLOB.num_financial_terminals++]"
	..()

/obj/machinery/computer/account_database/proc/accounting_letterhead(report_name)
	var/datum/ui_login/L = ui_login_get()
	return {"
		<center><h1><b>[report_name]</b></h1></center>
		<center><small><i>[station_name()] Accounting Report</i></small></center>
		<u>Generated By:</u> [L?.id?.registered_name ? L.id.registered_name : "Unknown"], [L?.id?.assignment ? L.id.assignment : "Unknown"]<br>
		<hr>
	"}


/obj/machinery/computer/account_database/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(ui_login_attackby(I, user))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/computer/account_database/attack_hand(mob/user)
	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/account_database/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AccountsUplinkTerminal", name)
		ui.open()

/obj/machinery/computer/account_database/ui_data(mob/user)
	var/list/data = list()
	data["currentPage"] = current_page
	data["is_printing"] = (next_print > world.time)
	ui_login_data(data, user)
	if(data["loginState"]["logged_in"])
		switch(current_page)
			if(AUT_ACCLST)
				var/list/accounts = list()
				for(var/i in 1 to length(GLOB.all_money_accounts))
					var/datum/money_account/D = GLOB.all_money_accounts[i]
					accounts.Add(list(list(
						"account_number" = "[D.account_number]",
						"owner_name" = D.owner_name,
						"suspended" = D.suspended ? "SUSPENDED" : "Active",
						"money" = "[D.money]", // needs to be strings because of TGUI localeCompare
						"account_index" = i)))

				data["accounts"] = accounts

			if(AUT_ACCINF)
				data["account_number"] = detailed_account_view.account_number
				data["owner_name"] = detailed_account_view.owner_name
				data["money"] = detailed_account_view.money
				data["suspended"] = detailed_account_view.suspended

				var/list/transactions = list()
				for(var/datum/transaction/T in detailed_account_view.transaction_log)
					transactions.Add(list(list(
						"date" = T.date,
						"time" = T.time,
						"target_name" = T.target_name,
						"purpose" = T.purpose,
						"amount" = T.amount,
						"source_terminal" = T.source_terminal)))

				data["transactions"] = transactions
	return data


/obj/machinery/computer/account_database/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	if(ui_login_act(action, params))
		return

	if(!ui_login_get().logged_in)
		return

	switch(action)
		if("view_account_detail")
			var/index = text2num(params["index"])
			if(index && index > 0 && index <= length(GLOB.all_money_accounts))
				detailed_account_view = GLOB.all_money_accounts[index]
				current_page = AUT_ACCINF

		if("back")
			detailed_account_view = null
			current_page = AUT_ACCLST

		if("toggle_suspension")
			if(detailed_account_view)
				detailed_account_view.suspended = !detailed_account_view.suspended

		if("create_new_account")
			current_page = AUT_ACCNEW

		if("finalise_create_account")
			var/account_name = params["holder_name"]
			var/starting_funds = max(text2num(params["starting_funds"]), 0)
			if(!account_name || !starting_funds)
				return

			starting_funds = clamp(starting_funds, 0, GLOB.station_account.money) // Not authorized to put the station in debt.
			starting_funds = min(starting_funds, fund_cap) // Not authorized to give more than the fund cap.

			var/datum/money_account/M = create_account(account_name, starting_funds, src)
			if(starting_funds > 0)
				GLOB.station_account.charge(starting_funds, null, "New account activation", "", "New account activation", M.owner_name)

			current_page = AUT_ACCLST


		if("print_records")
			// Anti spam measures
			if(next_print > world.time)
				to_chat(usr, "<span class='warning'>The printer is busy spooling. It will be ready in [(next_print - world.time) / 10] seconds.")
				return
			var/text
			playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
			var/obj/item/paper/P = new(loc)
			P.name = "financial account list"
			text = {"
				[accounting_letterhead("Financial Account List")]

				<table>
					<thead>
						<tr>
							<td>Account Number</td>
							<td>Holder</td>
							<td>Balance</td>
							<td>Status</td>
						</tr>
					</thead>
					<tbody>
			"}

			for(var/i in 1 to length(GLOB.all_money_accounts))
				var/datum/money_account/D = GLOB.all_money_accounts[i]
				text += {"
						<tr>
							<td>#[D.account_number]</td>
							<td>[D.owner_name]</td>
							<td>$[D.money]</td>
							<td>[D.suspended ? "Suspended" : "Active"]</td>
						</tr>
				"}

			text += {"
					</tbody>
				</table>
			"}

			P.info = text
			visible_message("<span class='notice'>[src] prints out a report.</span>")
			next_print = world.time + 30 SECONDS

		if("print_account_details")
			// Anti spam measures
			if(next_print > world.time)
				to_chat(usr, "<span class='warning'>The printer is busy spooling. It will be ready in [(next_print - world.time) / 10] seconds.")
				return
			var/text
			playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
			var/obj/item/paper/P = new(loc)
			P.name = "account #[detailed_account_view.account_number] details"
			var/title = "Account #[detailed_account_view.account_number] Details"
			text = {"
				[accounting_letterhead(title)]
				<u>Holder:</u> [detailed_account_view.owner_name]<br>
				<u>Balance:</u> $[detailed_account_view.money]<br>
				<u>Status:</u> [detailed_account_view.suspended ? "Suspended" : "Active"]<br>
				<u>Transactions:</u> ([detailed_account_view.transaction_log.len])<br>
				<table>
					<thead>
						<tr>
							<td>Timestamp</td>
							<td>Target</td>
							<td>Reason</td>
							<td>Value</td>
							<td>Terminal</td>
						</tr>
					</thead>
					<tbody>
				"}

			for(var/datum/transaction/T in detailed_account_view.transaction_log)
				text += {"
							<tr>
								<td>[T.date] [T.time]</td>
								<td>[T.target_name]</td>
								<td>[T.purpose]</td>
								<td>[T.amount]</td>
								<td>[T.source_terminal]</td>
							</tr>
					"}

			text += {"
					</tbody>
				</table>
				"}

			P.info = text
			visible_message("<span class='notice'>[src] prints out a report.</span>")
			next_print = world.time + 30 SECONDS

#undef AUT_ACCLST
#undef AUT_ACCINF
#undef AUT_ACCNEW
