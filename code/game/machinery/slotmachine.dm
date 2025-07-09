#define EMAGGED_SLOT_MACHINE_PRIZE_MOD 5
#define EMAGGED_SLOT_MACHINE_GIB_CHANCE 10
#define EMAGGED_SLOT_MACHINE_ROBOT_BREAK_COMPONENT_CHANCE 20

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
	var/list/prizes = list("jackpot"=10000, "big"=1000, "medium"=500, "small"=200, "minimal"=50, "none"=0)

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

/obj/machinery/slot_machine/proc/get_prize_coefficient()
	if(emagged)
		return EMAGGED_SLOT_MACHINE_PRIZE_MOD
	return 1

/obj/machinery/slot_machine/proc/give_custom_prize(mob/user, obj/item/prize)
	var/item = new prize(get_turf(src)) // Create item on slot machine turf
	var/mob/living/carbon/human/carbon_user = user
	if(istype(carbon_user)) // If living carbon - put in hands
		carbon_user.put_in_any_hand_if_possible(item)

/obj/machinery/slot_machine/proc/apply_emagged_lose_effect(mob/user)
	if(!isliving(user))
		return
	var/mob/living/target = user
	target.adjust_slot_machine_lose_effect()

/obj/machinery/slot_machine/proc/spin_slots(mob/user)
	if(!istype(user))
		return
	var/userName = user.name
	switch(rand(1,5000))
		if(1)
			var/credits = prizes["jackpot"] * get_prize_coefficient()
			atom_say("ДЖЕКПОТ! Игрок [userName] выиграл [credits] кредитов!")
			GLOB.minor_announcement.announce("Поздравляем [userName] с выигрышем джекпота в [credits] кредитов!", "Обладатель джекпота!")
			result = "ДЖЕКПОТ! Вы выиграли [credits] кредитов!"
			resultlvl = "teal"
			win_money(credits, 'sound/goonstation/misc/airraid_loop.ogg')
			if (emagged)
				give_custom_prize(user, /obj/item/stack/telecrystal/hundred)
		if(2 to 20)
			var/credits = prizes["big"] * get_prize_coefficient()
			atom_say("Большой победитель! Игрок [userName] выиграл [credits] кредитов!")
			result = "Вы выиграли [credits] кредитов!"
			resultlvl = "green"
			win_money(credits, 'sound/goonstation/misc/klaxon.ogg')
			if (emagged)
				give_custom_prize(user, /obj/item/stack/telecrystal/twenty_five)
		if(21 to 100)
			var/credits = prizes["medium"] * get_prize_coefficient()
			atom_say("Победитель! Игрок [userName] выиграл [credits] кредитов!")
			result = "Вы выиграли [credits] кредитов!"
			resultlvl = "green"
			win_money(credits, 'sound/goonstation/misc/bell.ogg')
			if (emagged)
				give_custom_prize(user, /obj/item/stack/telecrystal/five)
		if(101 to 500)
			var/credits = prizes["small"] * get_prize_coefficient()
			atom_say("Победитель! Игрок [userName] выиграл [credits] кредитов!")
			result = "Вы выиграли [credits] кредитов!"
			resultlvl = "green"
			win_money(credits)
		if(501 to 1000)
			var/credits = prizes["minimal"] * get_prize_coefficient()
			atom_say("Победитель! Игрок [userName] выиграл [credits] кредитов!")
			result = "Вы выиграли [credits] кредитов!"
			resultlvl = "green"
			win_money(credits)
		else
			result = "Неудача!"
			resultlvl = "orange"
			if (emagged)
				apply_emagged_lose_effect(user)
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
