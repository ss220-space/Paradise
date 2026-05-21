#define BSIG_P_POWER_DRAIN 100

/obj/item/clothing/gloves/bsig_personal
	name = "BSIG-P"
	desc = "Персональный генератор блюспейс-помех, встроенный в наручный браслет. В активном состоянии предотвращает блюспейс-смещение владельца."
	icon_state = "BSIG-P"
	item_state = "BSIG-P"
	siemens_coefficient = 0.25
	clothing_flags = NONE
	actions_types = list(/datum/action/item_action/toggle)

	var/active = FALSE
	var/obj/item/stock_parts/cell/cell
	var/mob/living/wearer

/obj/item/clothing/gloves/bsig_personal/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, override_state = null, override_file = null, use_item_state = FALSE)
	if(!isinhands && !override_state)
		override_state = "bsig"
	return ..()

/obj/item/clothing/gloves/bsig_personal/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell/high/plus(src)

/obj/item/clothing/gloves/bsig_personal/Destroy()
	set_active(FALSE)
	QDEL_NULL(cell)
	wearer = null
	return ..()

/obj/item/clothing/gloves/bsig_personal/get_cell()
	return cell

/obj/item/clothing/gloves/bsig_personal/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("Заряд установленной батареи: <b>[round(cell.percent())]%</b>.")
	else
		. += span_warning("Батарея не установлена.")
	. += span_notice("Сейчас [src] [active ? "активен" : "неактивен"].")

/obj/item/clothing/gloves/bsig_personal/attack_self(mob/user)
	if(active)
		set_active(FALSE)
		to_chat(user, span_notice("Вы выключаете [src]."))
		return

	if(!cell)
		to_chat(user, span_warning("В [src] не установлена батарея."))
		return
	if(cell.charge < BSIG_P_POWER_DRAIN)
		to_chat(user, span_warning("Батарея [src] разряжена."))
		return
	if(!is_worn_on_hands(user))
		to_chat(user, span_warning("[src] нужно надеть на руку, чтобы активировать."))
		return

	set_wearer(user)
	set_active(TRUE)
	to_chat(user, span_notice("Вы включаете [src]."))

/obj/item/clothing/gloves/bsig_personal/ui_action_click(mob/user, datum/action/action, leftclick)
	attack_self(user)

/obj/item/clothing/gloves/bsig_personal/item_action_slot_check(slot, mob/user, datum/action/action)
	return slot == ITEM_SLOT_GLOVES

/obj/item/clothing/gloves/bsig_personal/equipped(mob/living/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_GLOVES)
		return
	set_wearer(user)
	if(active)
		apply_interference()
		START_PROCESSING(SSobj, src)

/obj/item/clothing/gloves/bsig_personal/dropped(mob/living/user, slot, silent = FALSE)
	if(slot == ITEM_SLOT_GLOVES)
		remove_interference()
		wearer = null
		if(active)
			STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/gloves/bsig_personal/process(seconds_per_tick)
	if(!active)
		return PROCESS_KILL

	if(!wearer || QDELETED(wearer) || !is_worn_on_hands(wearer))
		remove_interference()
		wearer = null
		return PROCESS_KILL

	if(!cell || !cell.use(BSIG_P_POWER_DRAIN * seconds_per_tick))
		var/mob/living/old_wearer = wearer
		set_active(FALSE)
		if(old_wearer)
			to_chat(old_wearer, span_warning("[src] выключается из-за разряда батареи."))
		return PROCESS_KILL

/obj/item/clothing/gloves/bsig_personal/attackby(obj/item/I, mob/living/user, params)
	if(iscell(I))
		add_fingerprint(user)
		if(cell)
			balloon_alert(user, "батарея уже установлена")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		cell = I
		balloon_alert(user, "батарея установлена")
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/clothing/gloves/bsig_personal/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	eject_cell(user)

/obj/item/clothing/gloves/bsig_personal/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	eject_cell(user)

/obj/item/clothing/gloves/bsig_personal/proc/eject_cell(mob/user)
	if(!cell)
		balloon_alert(user, "нет батареи")
		return
	set_active(FALSE)
	var/obj/item/stock_parts/cell/old_cell = cell
	cell = null
	old_cell.forceMove(drop_location())
	user.put_in_hands(old_cell)
	balloon_alert(user, "батарея извлечена")

/obj/item/clothing/gloves/bsig_personal/proc/set_active(new_active)
	if(active == new_active)
		return
	active = new_active
	if(active)
		apply_interference()
		START_PROCESSING(SSobj, src)
	else
		remove_interference()
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/gloves/bsig_personal/proc/set_wearer(mob/living/new_wearer)
	if(wearer == new_wearer)
		return
	remove_interference()
	wearer = new_wearer

/obj/item/clothing/gloves/bsig_personal/proc/apply_interference()
	if(!active || !wearer || !is_worn_on_hands(wearer))
		return
	ADD_TRAIT(wearer, TRAIT_NO_TELEPORT, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/gloves/bsig_personal/proc/remove_interference()
	if(!wearer)
		return
	REMOVE_TRAIT(wearer, TRAIT_NO_TELEPORT, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/gloves/bsig_personal/proc/is_worn_on_hands(mob/user)
	if(!user)
		return FALSE
	return user.get_slot_by_item(src) == ITEM_SLOT_GLOVES

#undef BSIG_P_POWER_DRAIN
