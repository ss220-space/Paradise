/obj/item/eftpos
	name = "EFTPOS"
	desc = "Swipe your ID card to make purchases electronically."
	icon = 'icons/obj/device.dmi'
	icon_state = "eftpos"
	w_class = WEIGHT_CLASS_SMALL
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	var/machine_name = ""
	var/transaction_locked = 0
	var/transaction_paid = 0
	var/transaction_amount = 0
	var/transaction_purpose = "Default charge"
	var/access_code = 0
	var/obj/machinery/computer/account_database/linked_db
	var/datum/money_account/linked_account
	var/num_check = 0
	var/last_change = 0
	var/change_delay = 100
	var/duty_mode = FALSE
	var/during_paid = FALSE
	var/emagged = FALSE

/obj/item/eftpos/sec
	name = "Security EFTPOS"
	desc = "Swipe your ID card to pay taxes."
	icon_state = "eftpos_sec"
	transaction_purpose = "Payment of the fine (fee)"
	transaction_amount = 500
	duty_mode = TRUE

/obj/item/eftpos/cyborg
	name = "Service EFTPOS"
	desc = "Swipe a crew ID card to pay taxes."
	transaction_purpose = "Payment for the glory of NanoTrasen!"

/obj/item/paper/check
	desc = "Printed by the financial terminal."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_eftpos"

/obj/item/paper/check/update_icon_state()
	return


/obj/item/paper/check/AltClick(mob/living/carbon/human/user)
	if(ishuman(user) && user.is_in_hands(src))
		to_chat(user, span_warning("Paper is too small! You fail to fold [src] into the shape of a plane!"))


/obj/item/eftpos/Initialize(mapload)
	machine_name = "[station_name()]"
	if (duty_mode)
		machine_name += " Security"
	machine_name += " EFTPOS #[GLOB.num_financial_terminals++]"
	reconnect_database()
	//by default, connect to the station account
	//the user of the EFTPOS device can change the target account though, and no-one will be the wiser (except whoever's being charged)
	linked_account = GLOB.station_account
	return ..()

/obj/item/eftpos/proc/print_check(mob/user)
	playsound(src, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	num_check++
	var/obj/item/paper/check/ch = new(drop_location())
	ch.name = "Receipt: [machine_name]"
	ch.info = {"<tt><b><big>Receipt No.[num_check]</big></b> <br>
		-------------------------------------- <br>
		<b>Transaction purpose:</b> [transaction_purpose] <br>
		<b>Transaction amount:</b> [transaction_amount] <br>
		<b>Recipient account:</b> [linked_account.owner_name] <br>
		<b>Station time:</b> [station_time_timestamp()] <br>
		-------------------------------------- <br>
		This notice does not require a signature.</tt>"}
	ch.stamp(/obj/item/stamp, TRUE, "<i>This paper has been stamped by the [machine_name].</i>")
	user.put_in_hands(ch, ignore_anim = FALSE)

/obj/item/eftpos/proc/print_reference(mob/user)
	playsound(src, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	var/obj/item/paper/check/ref = new(drop_location())
	ref.name = "Reference: [machine_name]"
	ref.info = {"<tt><b><big>EFTPOS Reference</big></b> <br>
		-------------------------------------- <br>
		<b>Access code:</b> [access_code] <br>
		Do not lose or misplace this note.</tt>"}
	ref.stamp(/obj/item/stamp, TRUE, "<i>This paper has been stamped by the [machine_name].</i>")
	user.put_in_hands(ref, ignore_anim = FALSE)

/obj/item/eftpos/proc/reconnect_database()
	var/turf/location = get_turf(src)
	if(!location)
		return

	for(var/obj/machinery/computer/account_database/DB in GLOB.machines)
		if(DB.z == location.z)
			linked_db = DB
			break

/obj/item/eftpos/attack_self(mob/user)
	ui_interact(user)


/obj/item/eftpos/attackby(obj/item/I, mob/user, params)
	var/obj/item/card/id/id_card = I.GetID()
	if(id_card)
		add_fingerprint(user)
		scan_card(id_card, user)
		SStgui.update_uis(src)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/card/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	var/obj/item/active_hand = user.get_active_hand()
	var/obj/item/card/id/id_card = active_hand?.GetID()
	if(!istype(id_card))
		return .
	if(!target.is_type_in_hands(/obj/item/eftpos))
		return .
	. |= ATTACK_CHAIN_SUCCESS
	var/obj/item/eftpos/device = target.is_type_in_hands(/obj/item/eftpos)
	device?.scan_card(id_card, user)


/obj/item/eftpos/emag_act(mob/user)
	emagged = TRUE
	visible_message("<span class='warning'>[user] swipes a card through [src] and sparks fly out of it!</span>")
	do_sparks(1, TRUE, src)
	get_sfx("sparks")
	access_code = rand(1111,9999)
	transaction_purpose = pick(list(
		"WetSkrell.nt subscription activation","Consturction a mausoleum for George Trasen Jr",
		"Purchase of a genital prosthesis made by Xion MFG","Mr.Chang's noodles financial support",
		"For spaaAA@@Aaaace drugs","Membership fee to the trade union of the Syndicate employees",
		"For a brand new speedbike"))
	transaction_amount = pick(list(
		"[rand(0,99999)]",". = ..() RETURN FUCK_NT","IT'S OVER 9000!","three hundred bucks",
		"Nineteen Eighty-Four","alla money frum ur bank acc"))
	if(linked_account && linked_account.security_level == 0)
		//if the security level of the linked account is zero, then globally rewrites the owner's name
		linked_account.owner_name = pick(list(
			"Taargüs Taargüs","n4n07r453n 7074lly 5ux","Maya Normousbutt","Al Coholic","Stu Piddiddiot",
			"Yuri Nator","HAI GUYZ! LEARN HA TO CHANGE SECURITY SETTINGS! LOL!!"))

/obj/item/eftpos/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/eftpos/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EFTPOS", name)
		ui.open()

/obj/item/eftpos/ui_data(mob/user)
	var/list/data = list()
	data["machine_name"] = machine_name
	data["transaction_locked"] = transaction_locked
	data["transaction_paid"] = transaction_paid
	data["transaction_purpose"] = transaction_purpose
	data["transaction_amount"] = transaction_amount
	data["linked_account"] = linked_account ? linked_account.owner_name : null
	return data

/obj/item/eftpos/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	var/mob/user = ui.user

	switch(action)
		if("change_code")
			if(world.timeofday < last_change + change_delay)
				to_chat(user, "[bicon(src)]<span class='notice'> Wait before next access code change.</span>")
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 30, 1)
				return
			last_change = world.timeofday
			if(access_code)
				var/attempt_code = tgui_input_number(user, "Re-enter the current EFTPOS access code:", "Confirm old EFTPOS code", max_value = 9999, min_value = 1000)
				if(!Adjacent(user))
					return
				if(attempt_code != access_code)
					to_chat(user, "[bicon(src)]<span class='notice'> Incorrect code entered.</span>")
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 30, 0)
					return
			var/trycode = tgui_input_number(user, "Enter a new access code for this device:", "Enter new EFTPOS code", max_value = 9999, min_value = 1000)
			if(!Adjacent(user) || !isnull(trycode))
				return
			access_code = trycode
			print_reference(user)
		if("link_account")
			if(duty_mode)
				//prevents editing of this field on the service device
				to_chat(user, "[bicon(src)]<span class='notice'> Feature not available on this device.</span>")
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 30, 1)
				return
			if(!linked_db)
				reconnect_database()
			if(linked_db)
				var/attempt_account_num = tgui_input_number(user, "Enter account number to pay EFTPOS charges into:", "New account number", max_value = 999999, min_value = 100000)
				if(!attempt_account_num)
					return
				var/attempt_pin = tgui_input_number(user, "Enter pin code", "Account pin", max_value = 99999, min_value = 10000)
				if(!Adjacent(user) || !attempt_pin)
					return
				linked_account = attempt_account_access(attempt_account_num, attempt_pin, 2)
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 30, 0)
			else
				to_chat(user, "[bicon(src)]<span class='warning'> Server Error #523 Accounts Database Is Unreachable. Please retry and if the issue persists contact Nanotrasen IT support.</span>")
				playsound(src, 'sound/machines/terminal_alert.ogg', 30, 0)
		if("trans_purpose")
			if (duty_mode)
				to_chat(user, "[bicon(src)]<span class='notice'> Feature not available on this device.</span>")
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 30, 1)
				return
			var/purpose = tgui_input_text(user, "Enter reason for EFTPOS transaction", "Transaction purpose", transaction_purpose, encode = FALSE)
			if(!Adjacent(user) || isnull(purpose))
				return
			transaction_purpose = purpose
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 30, 0)
		if("trans_value")
			var/try_num = tgui_input_number(user, "Enter amount for EFTPOS transaction", "Transaction amount", transaction_amount)
			if(!Adjacent(user) || isnull(try_num))
				return
			transaction_amount = try_num
		if("toggle_lock")
			if(transaction_locked && !transaction_paid)
				//exit from card payment mode or if code 0 (priority exit)
				var/list/access = user.get_access()
				if((ACCESS_CENT_COMMANDER in access) || (ACCESS_CAPTAIN in access) || (ACCESS_HOP in access) || !access_code)
					transaction_locked = 0
					transaction_paid = 0
					playsound(src, 'sound/machines/terminal_prompt.ogg', 30, 0)
					return
				//exit with access code verification
				var/attempt_code = tgui_input_number(user, "Enter EFTPOS access code", "Reset Transaction", max_value = 9999, min_value = 1000)
				if(!Adjacent(user))
					return
				if(attempt_code != access_code)
					to_chat(user, "[bicon(src)]<span class='notice'> That is not a valid code!</span>")
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 30, 0)
					return
				transaction_locked = 0
				transaction_paid = 0
				playsound(src, 'sound/machines/terminal_prompt.ogg', 30, 0)
				return
			if(transaction_locked && transaction_paid)
				//completion of payment with receipt printing
				transaction_locked = 0
				transaction_paid = 0
				print_check(user)
				return
			if(linked_account && !transaction_locked)
				//switches EFTPOS to payment mode if the recipient account is entered
				transaction_locked = 1
				playsound(src, 'sound/machines/terminal_prompt.ogg', 30, 0)
			else
				to_chat(user, "[bicon(src)]<span class='warning'> Client Error #401 No Account Linked To Device.</span>")
				playsound(src, 'sound/machines/terminal_alert.ogg', 30, 0)
		if("scan_card")
			var/obj/item/active_hand = user.get_active_hand()
			var/obj/item/card/id/id_card = active_hand?.GetID()
			if(!istype(id_card))
				return
			scan_card(id_card, user)
		if("reset")
			//reset the access code - requires HoP/captain access
			var/list/access = user.get_access()
			if((ACCESS_CENT_COMMANDER in access)  || (ACCESS_CAPTAIN in access) || (ACCESS_HOP in access))
				access_code = 0
				to_chat(user, "[bicon(src)]<span class='notice'> Access code reset to 0.</span>")
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 30, 0)
			else
				to_chat(user, "[bicon(src)]<span class='warning'> Not allowed ID access.</span>")
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 30, 1)

/obj/item/eftpos/proc/scan_card(obj/item/card/id/id_card, mob/user)
	visible_message("<span class='notice'>[user] swipes a card through [src].</span>")

	if(emagged)
		to_chat(user, "[bicon(src)]<span class='warning'>  Client Error #423 Device Locked. Contact NanoTrasen IT support.</span>")
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 1)
		return

	if(!linked_db)
		reconnect_database()
	if(linked_db)
		if(during_paid)
			//This check is necessary to prevent multiple payment transactions when clicking
			to_chat(user, "[bicon(src)]<span class='notice'> End the current operation first.</span>")
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 30, 1)
			return

		if(!transaction_locked || transaction_paid)
			//aborts the procedure if EFTPOS has not been switched to payment mode or the transaction has already been paid
			return

		during_paid = TRUE
		if(tgui_alert(user, "Are you sure you want to pay $[transaction_amount] to: [linked_account.owner_name]", "Confirm transaction", list("Yes", "No")) != "Yes")
			return during_paid = FALSE

		var/datum/money_account/card_account
		if(isrobot(user))
			card_account = attempt_account_access(id_card.associated_account_number, pin_needed = FALSE)
		else
			var/attempt_pin = tgui_input_number(user, "Enter pin code", "EFTPOS transaction", max_value = 9999, min_value = 1000)
			if(!attempt_pin || !Adjacent(user))
				return
			card_account = attempt_account_access(id_card.associated_account_number, attempt_pin, 2)
		if(!card_account || card_account.suspended)
			to_chat(user, "[bicon(src)]<span class='warning'> Server Error #403 Unable To Access Account. Check security settings and try again.</span>")
			playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
			return during_paid = FALSE

		if(transaction_amount > card_account.money)
			to_chat(user, "[bicon(src)]<span class='warning'> Client Error #402 Payment Was Declined. You don't have that much money.</span>")
			playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
			return during_paid = FALSE

		var/transSuccess = card_account.charge(transaction_amount, linked_account, transaction_purpose, machine_name, card_account.owner_name)
		if(transSuccess == TRUE)
			transaction_paid = 1
			during_paid = FALSE
			visible_message("[bicon(src)] The [src] chimes.")
			playsound(src, 'sound/machines/chime.ogg', 50, 0)
	else
		to_chat(user, "[bicon(src)]<span class='warning'> Server Error #523 Accounts Database Is Unreachable. Please retry and if the issue persists contact Nanotrasen IT support.</span>")
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
