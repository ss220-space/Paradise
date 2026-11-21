/obj/machinery/floodlight
	name = "emergency floodlight"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floodlight_off"
	density = TRUE
	max_integrity = 100
	integrity_failure = 80
	light_power = 20
	light_range = 14
	light_on = FALSE
	var/on = FALSE
	var/obj/item/stock_parts/cell/high/cell = null
	var/use = 5
	var/unlocked = FALSE
	var/open = FALSE
	var/battery_powered = TRUE

/obj/machinery/floodlight/get_ru_names()
	return alist(
		NOMINATIVE = "прожектор",
		GENITIVE = "прожектора",
		DATIVE = "прожектору",
		ACCUSATIVE = "прожектор",
		INSTRUMENTAL = "прожектором",
		PREPOSITIONAL = "прожекторе",
	)

/obj/machinery/floodlight/get_cell()
	return cell

/obj/machinery/floodlight/Initialize(mapload)
	. = ..()
	if(battery_powered)
		cell = new(src)
	if(on && cell && cell.charge > 0)
		set_light(l_on = TRUE)
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/floodlight/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/machinery/floodlight/examine(mob/user)
	. = ..()
	if(!battery_powered)
		return
	if(!unlocked)
		. += span_notice("Панель <b>прикручена</b> наглухо.")
	else
		if(open)
			. += span_notice("Панель <b>открыта</b>, внутрь можно вставить батарею.")
		else
			. += span_notice("Панель можно <b>открыть</b> или <b>прикрутить</b> обратно.")

/obj/machinery/floodlight/update_icon_state()
	icon_state = "floodlight_[on ? "on" : "off"]"

	if(!open)
		return
	if(cell)
		icon_state += "_cell"
	else
		icon_state += "_empty"

/obj/machinery/floodlight/process()
	if(!on)
		return

	if(cell && !cell.use(use))
		on = FALSE
		update_icon(UPDATE_ICON_STATE)
		set_light(l_on = FALSE)
		visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] выключается из-за нехватки энергии!"))

/obj/machinery/floodlight/attack_ai()
	return

/obj/machinery/floodlight/attack_hand(mob/user)
	add_fingerprint(user)
	if(open && cell)
		if(user.get_active_hand())
			to_chat(user, span_warning("Ваши руки заняты!"))
			return
		cell.forceMove_turf()
		cell.add_fingerprint(user)
		cell.update_icon(UPDATE_OVERLAYS)
		user.put_in_hands(cell, ignore_anim = FALSE)
		cell = null
		to_chat(user, span_notice("Вы извлекаете батарею."))
		if(on)
			on = FALSE
			visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] выключается из-за нехватки энергии!"))
			set_light(l_on = FALSE)
		update_icon(UPDATE_ICON_STATE)
		return

	if(on)
		on = FALSE
		to_chat(user, span_notice("Вы выключаете свет."))
		set_light(l_on = FALSE)
	else
		if(!cell)
			to_chat(user, span_warning("Вы пытаетесь включить [declent_ru(ACCUSATIVE)], но ничего не происходит! Похоже, <b>батареи нет</b>."))
			return
		if(cell.charge <= 0)
			to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] едва светится! Похоже, <b>батарея пуста</b>."))
			return
		if(!anchored)
			to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] необходимо сначала закрепить!"))
			return
		on = TRUE
		to_chat(user, span_notice("Вы включаете свет."))
		set_light(l_on = TRUE)
		playsound(src, 'sound/machines/light_on.ogg', 50, TRUE)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/floodlight/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(iscell(I))
		add_fingerprint(user)
		if(!open)
			to_chat(user, span_warning("Сначала откройте панель [declent_ru(GENITIVE)]."))
			return ATTACK_CHAIN_PROCEED
		if(cell)
			to_chat(user, span_warning("Внутри уже установлена батарея."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		cell = I
		to_chat(user, span_notice("Вы вставляете батарею."))
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/machinery/floodlight/crowbar_act(mob/living/user, obj/item/I)
	add_fingerprint(user)
	if(!unlocked)
		to_chat(user, span_warning("Крышка прикручена намертво."))
		return TRUE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	if(open)
		to_chat(user, span_notice("Вы захлопываете панель."))
	else
		to_chat(user, span_notice("Вы поддеваете и открываете панель."))
	open = !open
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/floodlight/screwdriver_act(mob/living/user, obj/item/I)
	add_fingerprint(user)
	if(open)
		to_chat(user, span_warning("До винтов не добраться, пока панель открыта."))
		return TRUE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	if(open)
		return

	if(unlocked)
		to_chat(user, span_notice("Вы прикручиваете батарейную панель на место."))
	else
		to_chat(user, span_notice("Вы откручиваете батарейную панель."))
	unlocked = !unlocked
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/floodlight/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(anchored)
		extinguish_light()
	default_unfasten_wrench(user, I)

/obj/machinery/floodlight/extinguish_light(force = FALSE)
	if(on)
		on = FALSE
		set_light(l_on = FALSE)
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/floodlight/colony
	name = "colony floodlight"
	desc = "Мощный прожектор, питающийся от внешнего источника."
	icon = 'icons/obj/structures/big_floodlight.dmi'
	icon_state = "flood_s_off"
	max_integrity = 200
	battery_powered = FALSE
	light_power = 1
	light_range = 8
	on = TRUE
	anchored = TRUE
	var/metal_added = FALSE

/obj/machinery/floodlight/colony/Initialize(mapload)
	. = ..()
	if(on)
		set_light(l_on = TRUE)
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/floodlight/colony/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	if(stat & BROKEN)
		return
	return ..()

/obj/machinery/floodlight/colony/attack_hand(mob/user)
	return

/obj/machinery/floodlight/colony/examine(mob/user)
	. = ..()
	if(stat & BROKEN)
		if(metal_added)
			. += span_notice("Нужно приварить добавленные листы металла.")
		else
			. += span_notice("Нужно добавить 5 листов металла и приварить их.")

/obj/machinery/floodlight/colony/update_icon_state()
	if(stat & BROKEN)
		icon_state = "flood_s_dmg"
	else if(on)
		icon_state = "flood_s_on"
	else
		icon_state = "flood_s_off"

/obj/machinery/floodlight/colony/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(!istype(I, /obj/item/stack/sheet/metal))
		return ..()
	add_fingerprint(user)
	if(!(stat & BROKEN))
		to_chat(user, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] не нуждается в ремонте."))
		return ATTACK_CHAIN_PROCEED
	if(metal_added)
		to_chat(user, span_notice("Металл уже добавлен."))
		return ATTACK_CHAIN_PROCEED
	var/obj/item/stack/sheet/metal/metal = I
	if(!metal.use(5))
		to_chat(user, span_warning("Нужно пять листов металла для ремонта."))
		return ATTACK_CHAIN_PROCEED
	metal_added = TRUE
	to_chat(user, span_notice("Вы добавляете пять листов металла. Теперь нужно приварить их."))
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/machinery/floodlight/colony/wrench_act(mob/living/user, obj/item/I)
	add_fingerprint(user)
	to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] жёстко закреплён и его нельзя открепить."))
	return TRUE

/obj/machinery/floodlight/colony/welder_act(mob/living/user, obj/item/I)
	if(!(stat & BROKEN))
		to_chat(user, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] не нуждается в ремонте."))
		return TRUE
	if(!metal_added)
		to_chat(user, span_warning("Сначала нужно добавить 5 листов металла."))
		return TRUE
	if(!I.tool_use_check(user, 0))
		return TRUE
	WELDER_ATTEMPT_REPAIR_MESSAGE
	CALCULATE_SKILL_MOD(user, CONSTRUCTING_SPEED_MOD, construction_mod)
	if(I.use_tool(src, user, 4 SECONDS * construction_mod, volume = I.tool_volume))
		WELDER_REPAIR_SUCCESS_MESSAGE
		metal_added = FALSE
		stat &= ~BROKEN
		on = TRUE
		set_light(l_on = TRUE)
		update_integrity(max_integrity)
		update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/floodlight/colony/ex_act(severity)
	var/damage_chance = 0
	switch(severity)
		if(0 to EXPLODE_LIGHT)
			damage_chance = 25
		if(EXPLODE_LIGHT to EXPLODE_HEAVY)
			damage_chance = 50
		if(EXPLODE_HEAVY to INFINITY)
			damage_chance = 100
	if(prob(damage_chance))
		obj_break(BOMB)

/obj/machinery/floodlight/colony/obj_break(damage_flag)
	if(stat & BROKEN)
		return
	..()
	playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
	metal_added = FALSE
	if(on)
		on = FALSE
		set_light(l_on = FALSE)
	update_icon(UPDATE_ICON_STATE)
