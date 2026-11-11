#define SLOT_SYMBOL_SEVEN "seven"
#define SLOT_SYMBOL_BAR "bar"
#define SLOT_SYMBOL_BELL "bell"
#define SLOT_SYMBOL_CHERRY "cherry"
#define SLOT_SYMBOL_LEMON "lemon"
#define SLOT_SYMBOL_GEM "gem"
#define SLOT_SYMBOL_STAR "star"

GLOBAL_LIST_EMPTY(slotmachine_prizes)

/// Slot machine reels
GLOBAL_LIST_INIT(slotmachine_reel_symbols, list(
	SLOT_SYMBOL_SEVEN,
	SLOT_SYMBOL_BAR,
	SLOT_SYMBOL_BELL,
	SLOT_SYMBOL_CHERRY,
	SLOT_SYMBOL_LEMON,
	SLOT_SYMBOL_GEM,
	SLOT_SYMBOL_STAR,
))

/datum/slotmachine_prize
	/// Unique prize identifier
	var/id
	/// Drop chance, must be in range 0-100
	var/chance
	/// Basic credits prize (emagged credits multiply to EMAGGED_SLOT_MACHINE_PRIZE_MOD)
	var/credits = 0
	/// Winning reel symbol (null for a lose)
	var/symbol
	/// How many reels for win (0 for a lose)
	var/match_count = 0
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
	return

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
	symbol = SLOT_SYMBOL_LEMON
	match_count = 2
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
	symbol = SLOT_SYMBOL_CHERRY
	match_count = 2
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
	symbol = SLOT_SYMBOL_BELL
	match_count = 3
	resultlvl = "green"
	say_phrase = "Победитель!"
	sound = 'sound/goonstation/misc/bell.ogg'

/datum/slotmachine_prize/medium/apply_emagged_effect(obj/machinery/computer/slot_machine/slotmachine, mob/user)
	slotmachine.give_custom_prize(user, /obj/item/storage/box/random_syndi)

/datum/slotmachine_prize/big
	id = "big"
	chance = 0.38
	credits = 1000
	symbol = SLOT_SYMBOL_BAR
	match_count = 3
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
	symbol = SLOT_SYMBOL_SEVEN
	match_count = 3
	resultlvl = "teal"
	custom_result_prefix = "ДЖЕКПОТ! "
	say_phrase = "ДЖЕКПОТ!"
	sound = 'sound/goonstation/misc/airraid_loop.ogg'

/datum/slotmachine_prize/jackpot/apply_effect(obj/machinery/computer/slot_machine/slotmachine, mob/user, prize_credits)
	GLOB.minor_announcement.announce(
		message = "Поздравляем [user.name] с выигрышем джекпота в [prize_credits] кредитов!",
		new_title = "Обладатель джекпота!"
	)

/datum/slotmachine_prize/jackpot/apply_emagged_effect(obj/machinery/computer/slot_machine/slotmachine, mob/user)
	slotmachine.give_custom_prize(user, /obj/item/radio/uplink)

/obj/machinery/computer/slot_machine
	name = "slot machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/economy.dmi'
	icon_state = "slots-off"
	circuit = /obj/item/circuitboard/arcade/slotmachine
	var/plays = 0
	var/working = 0
	var/datum/money_account/account = null
	var/result = null
	var/resultlvl = null
	/// Reel symbols shown in UI
	var/list/reels = list(SLOT_SYMBOL_SEVEN, SLOT_SYMBOL_BAR, SLOT_SYMBOL_CHERRY)
	/// reel indexes that form win combination
	var/list/winning_reels = list()
	/// Last credited prize amount
	var/credits = 0
	/// Last prize identifier
	var/prize_id = null

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
	data["reels"] = reels
	data["winning_reels"] = winning_reels
	data["credits"] = credits
	data["prize"] = prize_id
	data["spin_id"] = plays
	data["multiplier"] = get_prize_coefficient()
	data["paytable"] = get_paytable()
	return data

/obj/machinery/computer/slot_machine/proc/get_paytable()
	var/list/paytable = list()
	for(var/prize_key in GLOB.slotmachine_prizes)
		var/datum/slotmachine_prize/prize = GLOB.slotmachine_prizes[prize_key]
		if(prize.match_count <= 0 || !prize.symbol)
			continue
		paytable += list(list(
			"id" = prize.id,
			"symbol" = prize.symbol,
			"match" = prize.match_count,
			"credits" = prize.credits,
			"jackpot" = (prize.id == "jackpot"),
		))
	return paytable

/obj/machinery/computer/slot_machine/ui_act(action, params)
	if(..())
		return
	if(issilicon(usr))
		to_chat(usr, span_warning("Обнаружен искусственный интеллект. Согласно регуляции \"Нанотрейзен\" #1023 вмешательство синтетических форм жизни в финансовые операции запрещено."))
		return
	add_fingerprint(usr)

	if(action != "spin")
		return FALSE
	if(working)
		return FALSE
	if(!account || account.money < 50)
		return FALSE
	if(!pay_with_card(usr, 50, "Slot Machine"))
		return FALSE
	plays++
	working = TRUE
	result = null
	resultlvl = null
	winning_reels = list()
	credits = 0
	prize_id = null
	update_icon(UPDATE_ICON_STATE)
	playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	addtimer(CALLBACK(src, PROC_REF(spin_slots), usr), 10)
	return TRUE

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
	if(QDELETED(src))
		return
	working = FALSE
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src) // Push a UI update

/obj/machinery/computer/slot_machine/proc/generate_reels(datum/slotmachine_prize/prizedatum)
	winning_reels = list()
	reels = list()
	if(prizedatum.match_count <= 0 || !prizedatum.symbol)
		var/list/available_symbols = GLOB.slotmachine_reel_symbols.Copy()
		shuffle_inplace(available_symbols)
		reels = list(available_symbols[1], available_symbols[2], available_symbols[3])
		return
	var/list/other_symbols = GLOB.slotmachine_reel_symbols - prizedatum.symbol
	for(var/reel_index in 1 to 3)
		if(reel_index <= prizedatum.match_count)
			reels += prizedatum.symbol
			winning_reels += reel_index
		else
			reels += pick(other_symbols)

/obj/machinery/computer/slot_machine/proc/apply_spin_result(mob/user, datum/slotmachine_prize/prizedatum)
	if(!prizedatum || !istype(prizedatum))
		do_sparks(1, TRUE, src)
		atom_say("Ошибка!")
		return
	var/prize_credits = prizedatum.get_credits(emagged)
	if(prizedatum.custom_result)
		result = prizedatum.custom_result
	else
		result = "[prizedatum.custom_result_prefix] Вы выиграли [prize_credits] кредитов!"
	resultlvl = prizedatum.resultlvl
	credits = prize_credits
	prize_id = prizedatum.id
	generate_reels(prizedatum)
	addtimer(CALLBACK(src, PROC_REF(apply_spin_result_after_anim), user, prizedatum, prize_credits), 10)

/obj/machinery/computer/slot_machine/proc/apply_spin_result_after_anim(mob/user, datum/slotmachine_prize/prizedatum, prize_credits)
	if(prizedatum.say_phrase)
		atom_say("[prizedatum.say_phrase] Игрок [user.name] выиграл [prize_credits] кредитов!")
	if(prize_credits > 0)
		win_money(prize_credits, prizedatum.sound)
	prizedatum.apply_effect(src, user, prize_credits)
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
		if(roll <= current)
			return prize
	// if any other cases
	return GLOB.slotmachine_prizes["lose"]

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

#undef SLOT_SYMBOL_SEVEN
#undef SLOT_SYMBOL_BAR
#undef SLOT_SYMBOL_BELL
#undef SLOT_SYMBOL_CHERRY
#undef SLOT_SYMBOL_LEMON
#undef SLOT_SYMBOL_GEM
#undef SLOT_SYMBOL_STAR
