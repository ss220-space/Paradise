#define EMAGGED_SLOT_MACHINE_PRIZE_MOD 5
#define EMAGGED_SLOT_MACHINE_GIB_CHANCE 10
#define EMAGGED_SLOT_MACHINE_ROBOT_BREAK_COMPONENT_CHANCE 20


/datum/slotmachine_prize
	var/credits = 0
	var/resultlvl = "red"
	var/custom_result_prefix = ""
	var/custom_result
	var/say_phrase
	var/sound = 'sound/machines/ping.ogg'

/datum/slotmachine_prize/proc/get_credits(emagged)
	if(emagged)
		return credits * EMAGGED_SLOT_MACHINE_PRIZE_MOD
	return credits

/datum/slotmachine_prize/proc/apply_effect(obj/machinery/slot_machine/slotmachine, mob/user, prize_credits)
	//Do nothing by default

datum/slotmachine_prize/proc/apply_emagged_effect(obj/machinery/slot_machine/slotmachine, mob/user)
	//Do nothing by default


/datum/slotmachine_prize/lose
	resultlvl = "orange"
	custom_result = "Неудача!"

/datum/slotmachine_prize/lose/apply_emagged_effect(obj/machinery/slot_machine/slotmachine, mob/user)
	if(!isliving(user))
		return
	var/mob/living/target = user
	target.adjust_slot_machine_lose_effect()


/datum/slotmachine_prize/minimal
	credits = 50
	resultlvl = "green"
	say_phrase = "Победитель!"

/datum/slotmachine_prize/minimal/apply_emagged_effect(obj/machinery/slot_machine/slotmachine, mob/user)
	//TODO implement
	to_chat(user, "Вы получаете случайный предмет на 5 TK")


/datum/slotmachine_prize/small
	credits = 200
	resultlvl = "green"
	say_phrase = "Победитель!"

/datum/slotmachine_prize/small/apply_emagged_effect(obj/machinery/slot_machine/slotmachine, mob/user)
	//TODO implement
	to_chat(user, "Вы получаете случайный предмет до 20 TK")


/datum/slotmachine_prize/medium
	credits = 500
	resultlvl = "green"
	say_phrase = "Победитель!"
	sound = 'sound/goonstation/misc/bell.ogg'

/datum/slotmachine_prize/medium/apply_emagged_effect(obj/machinery/slot_machine/slotmachine, mob/user)
	//TODO implement
	to_chat(user, "Вы получаете сюрплус крейт на 3 предмета за 20 TK")


/datum/slotmachine_prize/big
	credits = 1000
	resultlvl = "green"
	say_phrase = "Большой победитель!"
	sound = 'sound/goonstation/misc/klaxon.ogg'

/datum/slotmachine_prize/big/apply_emagged_effect(obj/machinery/slot_machine/slotmachine, mob/user)
	//TODO implement
	to_chat(user, "Вы получаете случайный предмет за 30-60 TK")


/datum/slotmachine_prize/jackpot
	credits = 10000
	resultlvl = "teal"
	custom_result_prefix = "ДЖЕКПОТ! "
	say_phrase = "ДЖЕКПОТ!"
	sound = 'sound/goonstation/misc/airraid_loop.ogg'

/datum/slotmachine_prize/jackpot/apply_effect(obj/machinery/slot_machine/slotmachine, mob/user, prize_credits)
	GLOB.minor_announcement.announce("Поздравляем [user.name] с выигрышем джекпота в [prize_credits] кредитов!", "Обладатель джекпота!")

/datum/slotmachine_prize/jackpot/apply_emagged_effect(obj/machinery/slot_machine/slotmachine, mob/user)
	to_chat(user, "Вы получаете аплинк на 100 TK")
	slotmachine.give_custom_prize(user, /obj/item/uplink)

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
	var/list/prizes = list()

/obj/machinery/slot_machine/Initialize(mapload)
	. = ..()
	prizes["jackpot"] = new /datum/slotmachine_prize/jackpot()
	prizes["big"] = new /datum/slotmachine_prize/big()
	prizes["medium"] = new /datum/slotmachine_prize/medium()
	prizes["small"] = new /datum/slotmachine_prize/small()
	prizes["minimal"] = new /datum/slotmachine_prize/minimal()
	prizes["lose"] = new /datum/slotmachine_prize/lose()

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

/obj/machinery/slot_machine/proc/apply_emagged_lose_effect(mob/user)
	if(!isliving(user))
		return
	var/mob/living/target = user
	target.adjust_slot_machine_lose_effect()

/obj/machinery/slot_machine/proc/spin_slots(mob/user)
	if(!istype(user))
		return
	var/resultId = detect_result()
	var/datum/slotmachine_prize/prizedatum = prizes[resultId]
	var/credits = prizedatum.get_credits(emagged)
	if (prizedatum.custom_result)
		result = prizedatum.custom_result
	else
		result = "[prizedatum.custom_result_prefix] Вы выиграли [credits] кредитов!"
	resultlvl = prizedatum.resultlvl
	if (prizedatum.say_phrase)
		atom_say("[prizedatum.say_phrase] Игрок [user.name] выиграл [credits] кредитов!")
	if(credits > 0)
		win_money(credits, prizedatum.sound)
	prizedatum.apply_effect(src, user, credits)
	if(emagged)
		prizedatum.apply_emagged_effect(src, user)
	working = FALSE
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src) // Push a UI update

/obj/machinery/slot_machine/proc/detect_result()
	switch(rand(1,5000))
		if(1)
			return "jackpot"
		if(2 to 20)
			return "big"
		if(21 to 100)
			return "medium"
		if(101 to 500)
			return "small"
		if(501 to 1000)
			return "minimal"
		else
			return "lose"

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

/obj/machinery/slot_machine/proc/cusom_minimal_prize(mob/user)
	to_chat(user, "Вы получаете случайный предмет на 5 TK")

/obj/machinery/slot_machine/proc/cusom_small_prize(mob/user)
	to_chat(user, "Вы получаете случайный предмет до 20 TK")

/obj/machinery/slot_machine/proc/cusom_medium_prize(mob/user)
	to_chat(user, "Вы получаете сюрплус крейт на 3 предмета за 20 TK")

/obj/machinery/slot_machine/proc/cusom_big_prize(mob/user)
	to_chat(user, "Вы получаете случайный предмет за 30-60 TK")

/obj/machinery/slot_machine/proc/cusom_jackpot_prize(mob/user)
	to_chat(user, "Вы получаете аплинк на 100 TK")
	give_custom_prize(user, /obj/item/uplink)

/obj/machinery/slot_machine/proc/give_custom_prize(mob/user, obj/item/prize)
	var/item = new prize(get_turf(src)) // Create item on slot machine turf
	var/mob/living/carbon/human/carbon_user = user
	if(istype(carbon_user)) // If living carbon - put in hands
		carbon_user.put_in_any_hand_if_possible(item)
