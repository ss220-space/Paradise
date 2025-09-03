#define EMAGGED_SLOT_MACHINE_PRIZE_MOD 5
#define EMAGGED_SLOT_MACHINE_GIB_CHANCE 10
#define EMAGGED_SLOT_MACHINE_ROBOT_BREAK_COMPONENT_CHANCE 20


GLOBAL_LIST_EMPTY(slotmachine_prizes)


/datum/slotmachine_prize
	/// Unique prize identifier
	var/id
	/// Drop chance, must be in range 0-100
	var/chance
	/// Basic credits prize (emagged credits multiply to EMAGGED_SLOT_MACHINE_PRIZE_MOD)
	var/credits = 0
	/// Color of prize text in ui
	var/resultlvl = "red"
	/// Prefix for prize text in ui (not use if custom_result not null)
	var/custom_result_prefix = ""
	/// Custom prize text in ui
	var/custom_result
	/// Machine say phrase (null if not need say)
	var/say_phrase
	/// Machine sound
	var/sound = 'sound/machines/ping.ogg'
	/// List of available prizes, only for emagged slotmachine
	var/list/available_prizes = list()

/datum/slotmachine_prize/New(list/allowed_uplink_items)
	..()

/datum/slotmachine_prize/proc/get_credits(emagged)
	if(emagged)
		return credits * EMAGGED_SLOT_MACHINE_PRIZE_MOD
	return credits

/datum/slotmachine_prize/proc/apply_effect(obj/machinery/computer/slot_machine/slotmachine, mob/user, prize_credits)
	//Do nothing by default

/datum/slotmachine_prize/proc/apply_emagged_effect(obj/machinery/computer/slot_machine/slotmachine, mob/user)
	if(!length(available_prizes))
		to_chat(user, "Кажется ваш приз затерялся в блюспейс аномалии!")
		return
	var/item_path = pick(available_prizes)
	slotmachine.give_custom_prize(user, item_path)

/datum/slotmachine_prize/lose
	id = "lose"
	chance = 80
	resultlvl = "orange"
	custom_result = "Неудача!"

/datum/slotmachine_prize/lose/apply_emagged_effect(obj/machinery/computer/slot_machine/slotmachine, mob/user)
	if(!isliving(user))
		return
	var/mob/living/target = user
	var/gibbed = target.adjust_slot_machine_lose_effect()
	if(!gibbed)
		return
	var/location = slotmachine.loc
	do_sparks(3, TRUE, slotmachine)
	qdel(slotmachine)
	new /obj/item/stack/sheet/metal(location, 5)
	new /obj/item/shard(location)
	new /obj/item/shard(location)
	explosion(location, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 1, adminlog = TRUE, cause = "Emagged slotmachine self-destroy")


/datum/slotmachine_prize/minimal
	id = "minimal"
	chance = 10
	credits = 50
	resultlvl = "green"
	say_phrase = "Победитель!"


/datum/slotmachine_prize/minimal/New(list/allowed_uplink_items)
	..(allowed_uplink_items)
	for(var/datum/uplink_item/uplink_item as anything in allowed_uplink_items)
		if(uplink_item.cost <= 5)
			available_prizes += uplink_item.item


/datum/slotmachine_prize/small
	id = "small"
	chance = 8
	credits = 200
	resultlvl = "green"
	say_phrase = "Победитель!"

/datum/slotmachine_prize/small/New(list/allowed_uplink_items)
	..(allowed_uplink_items)
	for(var/datum/uplink_item/uplink_item as anything in allowed_uplink_items)
		if(uplink_item.cost > 5 && uplink_item.cost <= 20)
			available_prizes += uplink_item.item


/datum/slotmachine_prize/medium
	id = "medium"
	chance = 1.6
	credits = 500
	resultlvl = "green"
	say_phrase = "Победитель!"
	sound = 'sound/goonstation/misc/bell.ogg'

/datum/slotmachine_prize/medium/apply_emagged_effect(obj/machinery/computer/slot_machine/slotmachine, mob/user)
	slotmachine.give_custom_prize(user, /obj/item/storage/box/random_syndi)


/datum/slotmachine_prize/big
	id = "big"
	chance = 0.38
	credits = 1000
	resultlvl = "green"
	say_phrase = "Большой победитель!"
	sound = 'sound/goonstation/misc/klaxon.ogg'

/datum/slotmachine_prize/big/New(list/allowed_uplink_items)
	..(allowed_uplink_items)
	for(var/datum/uplink_item/uplink_item as anything in allowed_uplink_items)
		if(uplink_item.cost >= 30 && uplink_item.cost <= 60)
			available_prizes += uplink_item.item


/datum/slotmachine_prize/jackpot
	id = "jackpot"
	chance = 0.02
	credits = 10000
	resultlvl = "teal"
	custom_result_prefix = "ДЖЕКПОТ! "
	say_phrase = "ДЖЕКПОТ!"
	sound = 'sound/goonstation/misc/airraid_loop.ogg'

/datum/slotmachine_prize/jackpot/apply_effect(obj/machinery/computer/slot_machine/slotmachine, mob/user, prize_credits)
	GLOB.minor_announcement.announce("Поздравляем [user.name] с выигрышем джекпота в [prize_credits] кредитов!", "Обладатель джекпота!")

/datum/slotmachine_prize/jackpot/apply_emagged_effect(obj/machinery/computer/slot_machine/slotmachine, mob/user)
	slotmachine.give_custom_prize(user, /obj/item/radio/uplink)



/obj/machinery/computer/slot_machine
	name = "slot machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/economy.dmi'
	icon_state = "slots-off"
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/arcade/slotmachine
	var/plays = 0
	var/working = 0
	var/datum/money_account/account = null
	var/result = null
	var/resultlvl = null

/obj/machinery/computer/slot_machine/attack_hand(mob/user as mob)
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/slot_machine/emag_act(mob/user)
	. = ..()
	if(emagged)
		return
	do_sparks(3, TRUE, src)
	to_chat(user, span_warning("Smells like something burnt"))
	circuit = /obj/item/circuitboard/broken
	frame.circuit = new circuit(frame)
	emagged = TRUE

/obj/machinery/computer/slot_machine/update_icon_state()
	icon_state = "slots-[working ? "on" : "off"]"


/obj/machinery/computer/slot_machine/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlotMachine", name)
		ui.open()

/obj/machinery/computer/slot_machine/ui_data(mob/user)
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

/obj/machinery/computer/slot_machine/ui_act(action, params)
	if(..())
		return
	if(issilicon(usr))
		to_chat(usr, span_warning("Обнаружен искусственный интеллект. Согласно регуляции НаноТрейзен #1023 вмешательство синтетических форм жизни в финансовые операции запрещено."))
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
		playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
		addtimer(CALLBACK(src, PROC_REF(spin_slots), usr), 25)

/obj/machinery/computer/slot_machine/proc/get_prize_coefficient()
	if(emagged)
		return EMAGGED_SLOT_MACHINE_PRIZE_MOD
	return 1

/obj/machinery/computer/slot_machine/proc/apply_emagged_lose_effect(mob/user)
	if(!isliving(user))
		return
	var/mob/living/target = user
	target.adjust_slot_machine_lose_effect()

/obj/machinery/computer/slot_machine/proc/spin_slots(mob/user)
	if(!istype(user))
		return
	var/prize = detect_result()
	apply_spin_result(user, prize)
	working = FALSE
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src) // Push a UI update

/obj/machinery/computer/slot_machine/proc/apply_spin_result(mob/user, datum/slotmachine_prize/prizedatum)
	if(!prizedatum || !istype(prizedatum))
		do_sparks(1, TRUE, src)
		atom_say("Ошибка!")
		return
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

/obj/machinery/computer/slot_machine/proc/detect_result()
	// Convert prize chance to weigth logic
	var/total = 0
	for(var/prize_id in GLOB.slotmachine_prizes)
		var/datum/slotmachine_prize/prize = GLOB.slotmachine_prizes[prize_id]
		total += prize.chance
	var/roll = rand(1,5000) / 5000 * total  // roll = [0, total]
	var/current = 0
	for(var/prize_id in GLOB.slotmachine_prizes)
		var/datum/slotmachine_prize/prize = GLOB.slotmachine_prizes[prize_id]
		current += prize.chance
		if (roll <= current)
			return prize
	// if any other cases
	return GLOB.slotmachine_prizes["lose"]

/obj/machinery/computer/slot_machine/verb/test_lose()
	set name = "Проверить lose"
	set category = STATPANEL_OBJECT
	apply_spin_result(usr, "lose")

/obj/machinery/computer/slot_machine/verb/test_minimal()
	set name = "Проверить minimal"
	set category = STATPANEL_OBJECT
	apply_spin_result(usr, "minimal")

/obj/machinery/computer/slot_machine/verb/test_small()
	set name = "Проверить small"
	set category = STATPANEL_OBJECT
	apply_spin_result(usr, "small")

/obj/machinery/computer/slot_machine/verb/test_medium()
	set name = "Проверить medium"
	set category = STATPANEL_OBJECT
	apply_spin_result(usr, "medium")

/obj/machinery/computer/slot_machine/verb/test_big()
	set name = "Проверить big"
	set category = STATPANEL_OBJECT
	apply_spin_result(usr, "big")

/obj/machinery/computer/slot_machine/verb/test_jackpot()
	set name = "Проверить jackpot"
	set category = STATPANEL_OBJECT
	apply_spin_result(usr, "jackpot")

/obj/machinery/computer/slot_machine/proc/win_money(amt, sound='sound/machines/ping.ogg')
	if(sound)
		playsound(loc, sound, 55, TRUE)
	if(!account)
		return
	account.credit(amt, "Slot Winnings", "Slot Machine", account.owner_name)

/obj/machinery/computer/slot_machine/proc/give_custom_prize(mob/user, obj/item/prize)
	var/item = new prize(get_turf(src)) // Create item on slot machine turf
	var/mob/living/carbon/human/carbon_user = user
	if(istype(carbon_user)) // If living carbon - put in hands
		carbon_user.put_in_any_hand_if_possible(item)

/obj/machinery/computer/slot_machine/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I)

/obj/machinery/computer/slot_machine/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
