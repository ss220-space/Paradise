/*

TODO:
give money an actual use (QM stuff, vending machines)
send money to people (might be worth attaching money to custom database thing for this, instead of being in the ID)
log transactions

*/

#define DEFAULT_SCREEN 0
#define CHANGE_SECURITY_LEVEL 1
#define TRANSFER_FUNDS 2
#define VIEW_TRANSACTION_LOGS 3
#define CHANGE_INSURANCE_TYPE 4
#define PRINT_DELAY 100
#define LOCKOUT_TIME 120

/obj/machinery/atm
	name = "Nanotrasen automatic teller machine"
	desc = "For all your monetary needs! Just insert your ID card to make a withdrawal or deposit!"
	icon = 'icons/obj/machines/terminals.dmi'
	icon_state = "atm"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	var/obj/machinery/computer/account_database/linked_db
	var/datum/money_account/authenticated_account
	var/number_incorrect_tries = 0
	var/previous_account_number = 0
	var/max_pin_attempts = 3
	var/ticks_left_locked_down = 0
	var/ticks_left_timeout = 0
	var/machine_id = ""
	var/obj/item/card/held_card
	var/editing_security_level = 0
	var/view_screen = DEFAULT_SCREEN
	var/lastprint = 0 // Printer needs time to cooldown

/obj/machinery/atm/New()
	..()
	machine_id = "[station_name()] RT #[GLOB.num_financial_terminals++]"

/obj/machinery/atm/Initialize()
	. = ..()
	reconnect_database()
	update_icon()

/obj/machinery/atm/process()
	if(stat & NOPOWER)
		return

	if(linked_db && ((linked_db.stat & NOPOWER) || !linked_db.activated))
		linked_db = null
		authenticated_account = null
		visible_message("[bicon(src)]<span class='warning'>[src] buzzes rudely, \"Connection to remote database lost.\"</span>")
		SStgui.update_uis(src)

	if(ticks_left_timeout > 0)
		ticks_left_timeout--
		if(ticks_left_timeout <= 0)
			authenticated_account = null
	if(ticks_left_locked_down > 0)
		ticks_left_locked_down--
		if(ticks_left_locked_down <= 0)
			number_incorrect_tries = 0

	if(authenticated_account)
		var/turf/T = get_turf(src)
		if(istype(T) && locate(/obj/item/stack/spacecash) in T)
			var/cash_amount = 0
			for(var/obj/item/stack/spacecash/S in T)
				cash_amount += S.amount
			if(cash_amount)
				playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 50, TRUE)
				for(var/obj/item/stack/spacecash/S in T)
					S.use(S.amount)
				authenticated_account.charge(-cash_amount, null, "Credit deposit", machine_id, "Terminal")

/obj/machinery/atm/proc/reconnect_database()
	for(var/obj/machinery/computer/account_database/DB in GLOB.machines)
		if(DB.z == z && !(DB.stat & NOPOWER) && DB.activated)
			linked_db = DB
			break


/obj/machinery/atm/update_icon_state()
	. = ..()
	if(stat & NOPOWER)
		icon_state = "atm_off"
	else
		icon_state = "atm"


/obj/machinery/atm/power_change(forced = FALSE)
	. = ..()
	if(.)
		update_icon()


/obj/machinery/atm/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return

	underlays += emissive_appearance(icon, "atm_lightmask", src)


/obj/machinery/atm/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || !powered())
		return ..()

	if(istype(I, /obj/item/card))
		add_fingerprint(user)
		if(held_card)
			to_chat(user, span_warning("The [name] is already holding another ID-card."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		held_card = I
		if(authenticated_account && held_card.associated_account_number != authenticated_account.account_number)
			authenticated_account = null
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/spacecash))
		add_fingerprint(user)
		var/obj/item/stack/spacecash/cash = I
		if(!authenticated_account)
			to_chat(user, span_warning("You should insert ID-card and login first."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(cash, src))
			return ..()
		to_chat(user, span_notice("You have inserted [cash] into [src]."))
		playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 50, TRUE)
		authenticated_account.credit(cash.amount, "Credit deposit", machine_id, authenticated_account.owner_name)
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/atm/attack_hand(mob/user)
	if(..())
		return TRUE
	if(issilicon(user))
		to_chat(user, "<span class='warning'>Artificial unit recognized. Artificial units do not currently receive monetary compensation, as per Nanotrasen regulation #1005.</span>")
		return
	if(!linked_db)
		reconnect_database()
	ui_interact(user)

/obj/machinery/atm/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atm/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ATM", name)
		ui.open()

/obj/machinery/atm/ui_data(mob/user)
	var/list/data = list()
	data["view_screen"] = view_screen
	data["machine_id"] = machine_id
	data["held_card_name"] = held_card ? held_card.name : "------"
	data["ticks_left_locked_down"] = ticks_left_locked_down
	data["linked_db"] = linked_db

	data["authenticated_account"] = authenticated_account
	if(authenticated_account)
		data["owner_name"] = authenticated_account.owner_name
		data["money"] = authenticated_account.money
		data["insurance"] = authenticated_account.insurance
		data["insurance_type"] = authenticated_account.insurance_type
		data["security_level"] = authenticated_account.security_level

		var/list/trx = list()
		for(var/datum/transaction/T in authenticated_account.transaction_log)
			trx[++trx.len] = list(
				"date" = T.date,
				"time" = T.time,
				"target_name" = T.target_name,
				"purpose" = T.purpose,
				"amount" = T.amount,
				"source_terminal" = T.source_terminal)
		data["transaction_log"] = trx

	return data

/obj/machinery/atm/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("transfer")
			if(!authenticated_account || !linked_db)
				return
			var/transfer_amount = text2num(params["funds_amount"])
			if(transfer_amount <= 0)
				to_chat(usr, "[bicon(src)]<span class='warning'>That is not a valid amount.</span>")
			else if(transfer_amount <= authenticated_account.money)
				var/target_account_number = text2num(params["target_acc_number"])
				var/transfer_purpose = params["purpose"]
				if(linked_db.charge_to_account(target_account_number, authenticated_account, transfer_purpose, machine_id, transfer_amount))
					to_chat(usr, "[bicon(src)]<span class='notice'>Funds transfer successful.</span>")
				else
					to_chat(usr, "[bicon(src)]<span class='warning'>Funds transfer failed.</span>")
			else
				to_chat(usr, "[bicon(src)]<span class='warning'>You don't have enough funds to do that!</span>")

		if("view_screen")
			var/list/valid_screen = list(DEFAULT_SCREEN, CHANGE_SECURITY_LEVEL, TRANSFER_FUNDS, VIEW_TRANSACTION_LOGS, CHANGE_INSURANCE_TYPE)
			var/screen_proper = text2num(params["view_screen"])
			if(screen_proper in valid_screen)
				view_screen = screen_proper
			else
				message_admins("Warning: possible href exploit by [ADMIN_FULLMONTY(usr)] - Invalid screen number passed into an ATM")
				log_debug("Warning: possible href exploit by [key_name_log(usr)] - Invalid screen number passed into an ATM")

		if("change_security_level")
			if(authenticated_account)
				var/new_sec_level = max(min(params["new_security_level"], 2), 0)
				authenticated_account.security_level = new_sec_level

		if("change_insurance_type")
			if(authenticated_account)
				var/new_insurance_type = params["new_insurance_type"]
				var/req_money = 0
				switch (new_insurance_type)
					if (INSURANCE_TYPE_STANDART)
						req_money = INSURANCE_STANDART_COST
					if (INSURANCE_TYPE_DELUXE)
						req_money = INSURANCE_DELUXE_COST

				if (authenticated_account.charge(req_money))
					usr.balloon_alert("Тип страховки изменен")
					authenticated_account.insurance_type = new_insurance_type
				else
					usr.balloon_alert("Недостаточно средств")

		if("attempt_auth")
			if(linked_db)
				if(!ticks_left_locked_down)
					var/tried_account_num = text2num(params["account_num"])
					if(!tried_account_num && held_card)
						tried_account_num = held_card.associated_account_number
					var/tried_pin = text2num(params["account_pin"])

					authenticated_account = attempt_account_access(tried_account_num, tried_pin, held_card && held_card.associated_account_number == tried_account_num ? 2 : 1)
					if(!authenticated_account)
						number_incorrect_tries++
						if(previous_account_number == tried_account_num)
							if(number_incorrect_tries > max_pin_attempts)
								//lock down the atm
								ticks_left_locked_down = 30
								playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)

								//create an entry in the account transaction log
								var/datum/money_account/failed_account = linked_db.get_account(tried_account_num)
								if(failed_account)
									var/datum/transaction/T = new()
									T.target_name = failed_account.owner_name
									T.purpose = "Unauthorised login attempt"
									T.source_terminal = machine_id
									T.date = GLOB.current_date_string
									T.time = station_time_timestamp()
									failed_account.transaction_log.Add(T)
							else
								to_chat(usr, "[bicon(src)]<span class='warning'>Incorrect pin/account combination entered, [max_pin_attempts - number_incorrect_tries] attempt\s remaining.</span>")
								previous_account_number = tried_account_num
								playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
						else
							to_chat(usr, "[bicon(src)]<span class='warning'>Incorrect pin/account combination entered.</span>")
							number_incorrect_tries = 0
					else
						playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE)
						ticks_left_timeout = LOCKOUT_TIME
						view_screen = DEFAULT_SCREEN

						//create a transaction log entry
						var/datum/transaction/T = new()
						T.target_name = authenticated_account.owner_name
						T.purpose = "Remote terminal access"
						T.source_terminal = machine_id
						T.date = GLOB.current_date_string
						T.time = station_time_timestamp()
						authenticated_account.transaction_log.Add(T)
						to_chat(usr, "[bicon(src)]<span class='notice'>Access granted. Welcome user '[authenticated_account.owner_name].'</span>")
					previous_account_number = tried_account_num

		if("withdrawal")
			var/amount = max(text2num(params["funds_amount"]), 0)
			if(amount <= 0)
				to_chat(usr, "[bicon(src)]<span class='warning'>That is not a valid amount.</span>")
			else if(authenticated_account && amount > 0)
				if(amount <= authenticated_account.money)
					playsound(src, 'sound/machines/chime.ogg', 50, TRUE)

					//remove the money
					if(amount > 100000) // prevent crashes
						to_chat(usr, "<span class='notice'>The ATM's screen flashes, 'Maximum single withdrawl limit reached, defaulting to 100,000.'</span>")
						amount = 100000
					if(authenticated_account.charge(amount, null, "Credit withdrawal", machine_id, authenticated_account.owner_name))
						withdraw_arbitrary_sum(amount)

				else
					to_chat(usr, "[bicon(src)]<span class='warning'>You don't have enough funds to do that!</span>")

		if("insurance")
			var/amount = max(text2num(params["insurance_amount"]), 0)
			if(amount <= 0)
				to_chat(usr, "[bicon(src)]" + span_warning("That is not a valid amount."))
			else if(authenticated_account && amount > 0)
				if(amount <= authenticated_account.money)
					playsound(src, 'sound/machines/chime.ogg', 50, TRUE)

					//remove the money
					if(amount > 100000) // prevent crashes
						to_chat(usr, span_notice("The ATM's screen flashes, 'Лимит единоразового пополнения страховки достигнут, установка пополнения на 100,000.'"))
						amount = 100000
					if(authenticated_account.charge(amount, null, "Insurance replenishment", machine_id, authenticated_account.owner_name))
						replenish_insurance(amount)
				else
					to_chat(usr, "[bicon(src)]" + span_warning("У вас недостаточно кредитов для этого!"))

		if("insurance_replenishment")
			authenticated_account.insurance_auto_replen = !authenticated_account.insurance_auto_replen
			if (authenticated_account.insurance_auto_replen)
				to_chat(usr, "[bicon(src)]" + span_warning("Автопополнение страховки включено!"))
			else
				to_chat(usr, "[bicon(src)]" + span_warning("Автопополнение страховки отключено!"))

		if("balance_statement")
			if(authenticated_account)
				if(world.timeofday < lastprint + PRINT_DELAY)
					to_chat(usr, "<span class='notice'>The [name] flashes an error on its display.</span>")
					return
				lastprint = world.timeofday
				playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
				var/obj/item/paper/R = new(loc)
				R.name = "Account balance: [authenticated_account.owner_name]"
				R.info = {"<b>NT Automated Teller Account Statement</b><br><br>
					<i>Account holder:</i> [authenticated_account.owner_name]<br>
					<i>Account number:</i> [authenticated_account.account_number]<br>
					<i>Balance:</i> $[authenticated_account.money]<br>
					<i>Date and time:</i> [station_time_timestamp()], [GLOB.current_date_string]<br><br>
					<i>Service terminal ID:</i> [machine_id]<br>"}

				//stamp the paper
				R.stamp(/obj/item/stamp, TRUE, "<i>This paper has been stamped by the Automatic Teller Machine.</i>", "stamp-cent")

			playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 50, TRUE)

		if("insert_card")
			if(held_card)
				held_card.forceMove_turf()
				authenticated_account = null
				if(ishuman(usr) && !usr.get_active_hand())
					usr.put_in_hands(held_card, ignore_anim = FALSE)
				held_card = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/card/id))
					usr.drop_transfer_item_to_loc(I, src)
					held_card = I

		if("logout")
			authenticated_account = null

	. = TRUE

//create the most effective combination of notes to make up the requested amount
/obj/machinery/atm/proc/withdraw_arbitrary_sum(arbitrary_sum)
	var/obj/item/stack/spacecash/C = new(drop_location(), arbitrary_sum)
	if(usr)
		usr.put_in_hands(C, ignore_anim = FALSE)

/obj/machinery/atm/proc/replenish_insurance(amount)
	authenticated_account.addInsurancePoints(amount)
