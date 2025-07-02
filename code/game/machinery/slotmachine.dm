#define EMAGGED_SLOT_MACHINE_PRIZE_MOD 5

/obj/machinery/slot_machine
	name = "slot machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/economy.dmi'
	icon_state = "slots-off"
	anchored = TRUE
	density = TRUE
	var/plays = 0
	var/working = 0
	var/datum/money_account/account = null
	var/result = null
	var/resultlvl = null
	var/list/prizes = list(10000, 1000, 500, 200, 50, 0)

/obj/machinery/slot_machine/attack_hand(mob/user as mob)
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/slot_machine/emag_act(mob/user)
	. = ..()
	if(emagged)
		return
	do_sparks(3, TRUE, src)
	to_chat(user, span_warning("Smells like something burnt"))
	emagged = TRUE

/obj/machinery/slot_machine/update_icon_state()
	icon_state = "slots-[working ? "on" : "off"]"


/obj/machinery/slot_machine/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlotMachine", name)
		ui.open()

/obj/machinery/slot_machine/ui_data(mob/user)
	var/list/data = list()
	// Get account
	account = get_card_account(user)

	// Send data
	data["working"] = working
	data["money"] = account ? account.money : null
	data["plays"] = plays
	data["result"] = result
	data["resultlvl"] = resultlvl
	return data

/obj/machinery/slot_machine/ui_act(action, params)
	if(..())
		return
	add_fingerprint(usr)

	if(action == "spin")
		if(working)
			return
		if(!account || account.money < 50)
			return
		if(!pay_with_card(usr, 50, "Slot Machine"))
			return
		plays++
		working = TRUE
		update_icon(UPDATE_ICON_STATE)
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
		addtimer(CALLBACK(src, PROC_REF(spin_slots), usr), 25)

/obj/machinery/slot_machine/proc/get_prize_credits(index)
	if (emagged)
		return prizes[index] * EMAGGED_SLOT_MACHINE_PRIZE_MOD
	return prizes[index]


/obj/machinery/slot_machine/proc/give_custom_prize(mob/living/carbon/human/user, obj/item/prize)
	if(!istype(user))
		return
	var/item = new prize(get_turf(user))
	user.put_in_any_hand_if_possible(item)

/obj/machinery/slot_machine/proc/spin_slots(mob/user)
	if(!istype(user))
		return
	var/userName = user.name
	switch(rand(1,5000))
		if(1)
			var/credits = get_prize_credits(1)
			atom_say("ДЖЕКПОТ! Игрок [userName] выиграл [credits] кредитов!")
			GLOB.event_announcement.Announce("Поздравляем [userName] с выигрышем джекпота в [credits] кредитов!", "Обладатель джекпота!")
			result = "JACKPOT! You win ten thousand credits!"
			resultlvl = "teal"
			win_money(credits, 'sound/goonstation/misc/airraid_loop.ogg')
			if (emagged)
				give_custom_prize(user, /obj/item/uplink)
		if(2 to 20)
			var/credits = get_prize_credits(2)
			atom_say("Большой победитель! Игрок [userName] выиграл [credits] кредитов!")
			result = "You win [credits] credits!"
			resultlvl = "green"
			win_money(credits, 'sound/goonstation/misc/klaxon.ogg')
			if (emagged)
				give_custom_prize(user, /obj/item/stack/telecrystal/twenty_five)
		if(21 to 100)
			var/credits = get_prize_credits(3)
			atom_say("Победитель! Игрок [userName] выиграл [credits] кредитов!")
			result = "You win [credits] credits!"
			resultlvl = "green"
			win_money(credits, 'sound/goonstation/misc/bell.ogg')
			if (emagged)
				give_custom_prize(user, /obj/item/stack/telecrystal/five)
		if(101 to 500)
			var/credits = get_prize_credits(4)
			atom_say("Победитель! Игрок [userName] выиграл [credits] кредитов!")
			result = "You win [credits] credits!"
			resultlvl = "green"
			win_money(credits)
		if(501 to 1000)
			var/credits = get_prize_credits(5)
			atom_say("Победитель! Игрок [userName] выиграл [credits] кредитов!")
			result = "You win [credits] credits!"
			resultlvl = "green"
			win_money(credits)
		else
			result = "No luck!"
			resultlvl = "orange"
			if (emagged)
				var/mob/living/carbon/human/carbon_user = user
				if (istype(carbon_user))
					if (probe(10))
						to_chat(user, "<span class='userdanger'>No... just one more try...</span>")
						user.gib()
					else
						user.visible_message("<span class='warning'>[user] pulls [src]'s lever with a glint in [user.p_their()] eyes!</span>", "<span class='warning'>You feel a draining as you pull the lever, but you know it'll be worth it.</span>")
						user.adjustCloneLoss(5)
	working = FALSE
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src) // Push a UI update

/obj/machinery/slot_machine/proc/win_money(amt, sound='sound/machines/ping.ogg')
	if(sound)
		playsound(loc, sound, 55, 1)
	if(!account)
		return
	account.credit(amt, "Slot Winnings", "Slot Machine", account.owner_name)

/obj/machinery/slot_machine/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I)

#undef EMAGGED_SLOT_MACHINE_PRIZE_MOD
