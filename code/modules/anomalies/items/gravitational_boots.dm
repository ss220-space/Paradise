/obj/item/clothing/shoes/magboots/gravity
	name = "gravitational boots"
	ru_names = list(
		NOMINATIVE = "гравитационные ботинки", \
		GENITIVE = "гравитационных ботинок", \
		DATIVE = "гравитационным ботинкам", \
		ACCUSATIVE = "гравитационные ботинки", \
		INSTRUMENTAL = "гравитационными ботинками", \
		PREPOSITIONAL = "гравитационных ботинках"
	)
	desc = "Эти экспериментальные магбутсы обходят замедление обычных, за счет миниатюрных гравитационных в подошвах. \
			К сожалению, для работы им необходимо ядро гравитационной аномалии."
	gender = PLURAL
	icon_state = "gravboots0"
	actions_types = list(/datum/action/item_action/toggle, /datum/action/item_action/gravity_jump) //combination of magboots and jumpboots
	strip_delay = 10 SECONDS
	put_on_delay = 10 SECONDS
	slowdown_active = 0
	base_icon_state = "gravboots"
	magpulse_name = "micro gravitational traction system"
	var/datum/martial_art/grav_stomp/style
	var/jumpdistance = 5
	var/jumpspeed = 3
	var/recharging_rate = 6 SECONDS
	var/recharging_time = 0 // Time until next dash
	var/dash_cost = 1000 // Cost to dash.
	var/power_consumption_rate = 30 // How much power is used by the boots each cycle when magboots are active
	var/obj/item/assembly/signaler/core/gravitational/core = null
	var/obj/item/stock_parts/cell/cell = null


/obj/item/clothing/shoes/magboots/gravity/Initialize()
	. = ..()
	style = new()


/obj/item/clothing/shoes/magboots/gravity/Destroy()
	QDEL_NULL(style)
	QDEL_NULL(cell)
	QDEL_NULL(core)
	return ..()

/obj/item/clothing/shoes/magboots/gravity/examine(mob/user)
	. = ..()
	if(core && cell)
		. += span_notice("[declent_ru(NOMINATIVE)] полностью функциональны!")
		. += span_notice("Ботинки заряжены на [round(cell.percent())]%.")
	else if(core)
		. += span_warning("В них установлено ядро ​​гравитационной аномалии, но не установлена батарейка.")
	else if(cell)
		. += span_warning("В них установлена батарейка, но не установлено ядро гравитационной аномалии.")
	else
		. += span_warning("В них не хватает ядра гравитационной аномалии и батарейки.")


/obj/item/clothing/shoes/magboots/gravity/toggle_magpulse(mob/user, silent = FALSE)
	if(silent && (!cell || !core || cell.charge <= power_consumption_rate && !magpulse))
		return

	if(!cell)
		user.balloon_alert(user, "нет батарейки")
		return

	if(cell.charge <= power_consumption_rate && !magpulse)
		user.balloon_alert(user, "недостаточно заряда")
		return

	if(!core)
		user.balloon_alert(user, "нет ядра")
		return

	return ..()


/obj/item/clothing/shoes/magboots/gravity/process()
	if(!cell) //There should be a cell here, but safety first
		return

	if(cell.charge <= power_consumption_rate * 2)
		if(ishuman(loc))
			var/mob/living/carbon/human/user = loc
			to_chat(user, span_warning("[declent_ru(NOMINATIVE)] израсходовали весь заряд и отключились!"))
			toggle_magpulse(user, silent = TRUE)
	else
		cell.use(power_consumption_rate)

/obj/item/clothing/shoes/magboots/gravity/screwdriver_act(mob/living/user, obj/item/I)
	if(!cell)
		to_chat(user, span_warning("Внутри нет батарейки!"))
		return

	if(magpulse)
		to_chat(user, span_warning("Сначала выключите [declent_ru(ACCUSATIVE)]!"))
		return

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	cell.forceMove_turf()
	user.put_in_hands(cell, ignore_anim = FALSE)
	to_chat(user, span_notice("Вы достали [cell.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]."))
	cell.update_icon()
	cell = null
	update_icon()


/obj/item/clothing/shoes/magboots/gravity/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		add_fingerprint(user)
		if(cell)
			to_chat(user, span_warning("В [declent_ru(PREPOSITIONAL)] уже есть батарейка."))
			return ATTACK_CHAIN_PROCEED

		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()

		to_chat(user, span_notice("Вы установили [I.declent_ru(ACCUSATIVE)] в [declent_ru(NOMINATIVE)]."))
		cell = I
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(iscoregrav(I))
		add_fingerprint(user)
		if(core)
			to_chat(user, span_warning("В [declent_ru(PREPOSITIONAL)] уже есть [core.declent_ru(NOMINATIVE)]."))
			return ATTACK_CHAIN_PROCEED

		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()

		to_chat(user, span_notice("Вы установили [I.declent_ru(ACCUSATIVE)] в [declent_ru(NOMINATIVE)]. Они немного потеплели."))
		core = I
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/clothing/shoes/magboots/gravity/click_alt(mob/user)
	if(!user.contains(src))
		return ..()

	if(!core)
		user.balloon_alert(user, "нет ядра")
		return

	user.put_in_active_hand(core)
	core = null
	user.balloon_alert(user, "ядро извлечено")

/obj/item/clothing/shoes/magboots/gravity/equipped(mob/user, slot, initial)
	. = ..()

	if(!ishuman(user))
		return

	if(slot == ITEM_SLOT_FEET && cell && core)
		style.bonus_damage = 10 * core.get_strenght() / 150
		style.teach(user, TRUE)


/obj/item/clothing/shoes/magboots/gravity/dropped(mob/living/carbon/human/user, slot, silent = FALSE)
	. = ..()
	if(!ishuman(user) || slot != ITEM_SLOT_FEET)
		return .

	style.remove(user)
	if(!magpulse)
		return

	if(!silent)
		to_chat(user, span_notice("Как только вы сняли [declent_ru(NOMINATIVE)] они автоматически деактивировались."))

	toggle_magpulse(user, silent = TRUE)


/obj/item/clothing/shoes/magboots/gravity/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_FEET)
		return TRUE

/obj/item/clothing/shoes/magboots/gravity/proc/dash(mob/user, action)
	if(!isliving(user))
		return

	if(!cell)
		user.balloon_alert(user, "нет батарейки")
		return

	if(cell.charge <= dash_cost)
		user.balloon_alert(user, "недостаточно заряда")
		return

	if(!core)
		user.balloon_alert(user, "нет ядра")
		return

	if(recharging_time > world.time)
		user.balloon_alert(user, "идет перезарядка")
		return

	if(user.throwing)
		user.balloon_alert(user, "нет опоры")
		return

	var/jump_mult = core.get_strenght() / 150
	var/cur_jumpdistance = jumpdistance * jump_mult
	var/cur_jumpjumpspeed = jumpspeed * jump_mult
	var/turf/T = get_step(get_turf(user), user.dir)
	for(var/i = 1 to cur_jumpdistance)
		if(!T.can_enter(user))
			cur_jumpjumpspeed = max(3, cur_jumpjumpspeed * ((i - 1) / cur_jumpdistance))
			cur_jumpdistance = i - 1
			break

		T = get_step(T, user.dir)

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction
	ADD_TRAIT(user, TRAIT_MOVE_FLYING, ITEM_GRAV_BOOTS_TRAIT)
	var/after_jump_callback = CALLBACK(src, PROC_REF(after_jump), user)
	if(user.throw_at(target, cur_jumpdistance, cur_jumpjumpspeed, spin = FALSE, diagonals_first = TRUE, callback = after_jump_callback))
		playsound(src, 'sound/effects/stealthoff.ogg', 50, 1, 1)
		user.visible_message(span_warning("[user] прыгает вперед!"))
		recharging_time = world.time + recharging_rate
		cell.use(dash_cost)
		return

	after_jump(user)
	to_chat(user, span_warning("Что-то помешало вам прыгнуть!"))

/obj/item/clothing/shoes/magboots/gravity/proc/after_jump(mob/user)
	REMOVE_TRAIT(user, TRAIT_MOVE_FLYING, ITEM_GRAV_BOOTS_TRAIT)

/obj/item/clothing/shoes/magboots/gravity/suicide_act(mob/user)
	if(!cell || !core)
		return ..()

	user.visible_message(span_suicide("[user] прижимает подошвы [declent_ru(GENITIVE)] к своему торсу с двух сторон и активирует. Похоже [genderize_ru(user.gender, "он", "она", "оно", "они")] пыта[genderize_ru(user.gender, "е", "е", "е", "ю")]тся убить себя!"))
	user.visible_message(span_suicide("[user] взрывается из-за возникшего гравитационного колодца!"), \
						span_suicide("Вы взрываетесь из-за возникшего гравитационного колодца!"),
						span_suicide("Вы слышите громкий, гулкий хлопок!"))
	user.gib()
	return OBLITERATION
