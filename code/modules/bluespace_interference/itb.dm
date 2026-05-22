#define ITB_TAMPER_SECURE 0
#define ITB_TAMPER_PANEL_OPEN 1
#define ITB_TAMPER_WIRES_CUT 2
#define ITB_TAMPER_LOCK_BYPASSED 3
#define ITB_TAMPER_TIME (2 SECONDS)
#define ITB_TAMPER_FAILURE_CHANCE 25
#define ITB_SCREWDRIVER_FAILURE_DAMAGE 10
#define ITB_SHOCK_FAILURE_DAMAGE 15

/obj/item/clothing/neck/itb
	name = "ITB"
	desc = "Тюремный ошейник-блокиратор телепортации. В закрытом состоянии предотвращает любую телепортацию и схожее перемещение владельца."
	icon_state = "ITB"
	item_state = "neck_ITB"
	body_parts_covered = NONE
	resistance_flags = FIRE_PROOF

	var/locked = FALSE
	var/security_lock = TRUE
	var/tamper_stage = ITB_TAMPER_SECURE
	var/mob/living/wearer

/obj/item/clothing/neck/itb/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)
	register_context()

/obj/item/clothing/neck/itb/Destroy()
	remove_interference()
	wearer = null
	return ..()

/obj/item/clothing/neck/itb/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, override_state = null, override_file = null, use_item_state = FALSE)
	if(!isinhands && !override_state)
		override_state = "neck_ITB"
	return ..()

/obj/item/clothing/neck/itb/examine(mob/user)
	. = ..()
	. += span_notice("Замок [locked ? "закрыт" : "открыт"].")
	switch(tamper_stage)
		if(ITB_TAMPER_SECURE)
			. += span_notice("Сервисная панель <b>закручена</b>.")
		if(ITB_TAMPER_PANEL_OPEN)
			. += span_warning("Сервисная панель открыта.")
			. += span_notice("Открытую управляющую проводку можно <b>перерезать</b>, либо <i>закрутить</i> панель обратно.")
		if(ITB_TAMPER_WIRES_CUT)
			. += span_warning("Управляющая проводка перерезана.")
			. += span_notice("Повреждённую проводку можно <b>импульсировать мультитулом</b>, чтобы обойти замок, либо починить <i>мотком проводов</i>.")
		if(ITB_TAMPER_LOCK_BYPASSED)
			. += span_warning("Замок был обойдён.")
			. += span_notice("Перерезанную проводку нужно починить <i>мотком проводов</i>, прежде чем панель можно будет закрепить.")

/obj/item/clothing/neck/itb/attack_self(mob/user)
	to_chat(user, span_notice("Используйте ПКМ по [src], чтобы закрыть или открыть замок."))

/obj/item/clothing/neck/itb/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item || !ishuman(user))
		return
	if(!get_worn_target())
		return
	context[SCREENTIP_CONTEXT_RMB] = locked ? "Разблокировать" : "Заблокировать"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/clothing/neck/itb/attack_hand_secondary(mob/user, list/modifiers)
	if(!isliving(user))
		to_chat(user, span_warning("Вам нужна ID-карта с доступом брига для управления [src]."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/mob/living/living_user = user
	var/mob/living/target = get_worn_target()
	if(!target && loc != user)
		to_chat(user, span_warning("[src] должен быть надет, прежде чем его можно будет закрыть или открыть."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(locked)
		do_unlock(living_user, target)
	else
		do_lock(living_user, target)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/neck/itb/proc/get_worn_target()
	if(ishuman(loc))
		var/mob/living/carbon/human/human_wearer = loc
		if(human_wearer.neck == src)
			return human_wearer
		return null
	if(wearer && is_worn())
		return wearer
	return null

/obj/item/clothing/neck/itb/proc/get_active_hand_zone(mob/user)
	return user.hand == ACTIVE_HAND_LEFT ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND

/obj/item/clothing/neck/itb/proc/has_insulated_gloves(mob/living/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_user = user
	var/obj/item/clothing/gloves/gloves = human_user.gloves
	return gloves?.siemens_coefficient == 0

/obj/item/clothing/neck/itb/proc/try_screwdriver_tamper(mob/living/user)
	if(!prob(ITB_TAMPER_FAILURE_CHANCE))
		return TRUE

	to_chat(user, span_warning("Отвёртка срывается в тесном корпусе [src]!"))
	user.apply_damage(ITB_SCREWDRIVER_FAILURE_DAMAGE, BRUTE, get_active_hand_zone(user))
	return FALSE

/obj/item/clothing/neck/itb/proc/try_electrical_tamper(mob/living/user)
	if(!prob(ITB_TAMPER_FAILURE_CHANCE))
		return TRUE

	if(has_insulated_gloves(user))
		to_chat(user, span_warning("[src] выбрасывает искру, но ваши перчатки гасят разряд."))
	else
		to_chat(user, span_warning("Открытая проводка [src] бьёт вас током по руке!"))
		user.apply_damage(ITB_SHOCK_FAILURE_DAMAGE, BURN, get_active_hand_zone(user))
	return FALSE

/obj/item/clothing/neck/itb/equipped(mob/living/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_NECK)
		return
	wearer = user
	refresh_state()

/obj/item/clothing/neck/itb/dropped(mob/living/user, slot, silent = FALSE)
	if(slot == ITEM_SLOT_NECK)
		remove_interference()
		wearer = null
	. = ..()

/obj/item/clothing/neck/itb/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	var/stage_before = tamper_stage
	if(!I.use_tool(src, user, ITB_TAMPER_TIME, volume = I.tool_volume) || tamper_stage != stage_before)
		return
	if(!try_screwdriver_tamper(user))
		return

	switch(tamper_stage)
		if(ITB_TAMPER_SECURE)
			tamper_stage = ITB_TAMPER_PANEL_OPEN
			to_chat(user, span_notice("Вы открываете сервисную панель [src]."))
		if(ITB_TAMPER_PANEL_OPEN)
			tamper_stage = ITB_TAMPER_SECURE
			to_chat(user, span_notice("Вы закрываете сервисную панель [src]."))
		if(ITB_TAMPER_WIRES_CUT, ITB_TAMPER_LOCK_BYPASSED)
			to_chat(user, span_warning("Перед закреплением панели [src] нужно заменить проводку."))

	refresh_state()

/obj/item/clothing/neck/itb/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(tamper_stage != ITB_TAMPER_PANEL_OPEN)
		to_chat(user, span_warning("Сначала нужно открыть сервисную панель [src]."))
		return
	var/stage_before = tamper_stage
	if(!I.use_tool(src, user, ITB_TAMPER_TIME, volume = I.tool_volume) || tamper_stage != stage_before)
		return
	if(!try_electrical_tamper(user))
		return

	tamper_stage = ITB_TAMPER_WIRES_CUT
	to_chat(user, span_notice("Вы перерезаете управляющую проводку [src]."))
	refresh_state()

/obj/item/clothing/neck/itb/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(tamper_stage != ITB_TAMPER_WIRES_CUT)
		to_chat(user, span_warning("Перед обходом замка [src] нужно перерезать управляющую проводку."))
		return
	var/stage_before = tamper_stage
	if(!I.use_tool(src, user, ITB_TAMPER_TIME, volume = I.tool_volume) || tamper_stage != stage_before)
		return
	if(!try_electrical_tamper(user))
		return

	tamper_stage = ITB_TAMPER_LOCK_BYPASSED
	locked = FALSE
	to_chat(user, span_notice("Вы обходите замок [src]."))
	refresh_state()

/obj/item/clothing/neck/itb/attackby(obj/item/I, mob/living/user, params)
	if(iscoil(I))
		if(tamper_stage < ITB_TAMPER_WIRES_CUT)
			to_chat(user, span_warning("Проводка [src] не требует замены."))
			return ATTACK_CHAIN_PROCEED

		var/obj/item/stack/cable_coil/cable = I
		var/stage_before = tamper_stage
		if(!cable.use_tool(src, user, ITB_TAMPER_TIME, volume = cable.tool_volume) || tamper_stage != stage_before)
			return ATTACK_CHAIN_PROCEED
		if(!cable.use(1))
			return ATTACK_CHAIN_PROCEED

		tamper_stage = ITB_TAMPER_PANEL_OPEN
		to_chat(user, span_notice("Вы заменяете управляющую проводку [src]."))
		refresh_state()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/clothing/neck/itb/proc/do_lock(mob/living/user, mob/living/target)
	if(target)
		wearer = target
	if(!is_worn() && loc != user)
		to_chat(user, span_warning("[src] должен быть надет или находиться в руках, прежде чем его можно будет закрыть."))
		return FALSE
	if(tamper_stage != ITB_TAMPER_SECURE)
		to_chat(user, span_warning("[src] нельзя закрыть, пока сервисная панель открыта или повреждена."))
		return FALSE
	if(!has_itb_access(user))
		to_chat(user, span_warning("Для закрытия [src] требуется доступ брига."))
		return FALSE

	locked = TRUE
	to_chat(user, span_notice("[src] закрывается с резким щелчком."))
	refresh_state()
	return TRUE

/obj/item/clothing/neck/itb/proc/do_unlock(mob/living/user, mob/living/target)
	if(target)
		wearer = target
	if(!has_itb_access(user))
		to_chat(user, span_warning("Для открытия [src] требуется доступ брига."))
		return FALSE

	locked = FALSE
	to_chat(user, span_notice("[src] открывается со щелчком."))
	refresh_state()
	return TRUE

/obj/item/clothing/neck/itb/proc/has_itb_access(mob/living/user)
	if(!user)
		return FALSE
	return ACCESS_BRIG in user.get_access()

/obj/item/clothing/neck/itb/proc/refresh_state()
	if(locked && tamper_stage != ITB_TAMPER_LOCK_BYPASSED && is_worn())
		ADD_TRAIT(src, TRAIT_NODROP, UNIQUE_TRAIT_SOURCE(src))
	else
		REMOVE_TRAIT(src, TRAIT_NODROP, UNIQUE_TRAIT_SOURCE(src))

	if(locked && tamper_stage < ITB_TAMPER_WIRES_CUT)
		apply_interference()
	else
		remove_interference()

/obj/item/clothing/neck/itb/proc/apply_interference()
	if(!is_worn())
		return
	ADD_TRAIT(wearer, TRAIT_NO_TELEPORT, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/neck/itb/proc/remove_interference()
	if(!wearer)
		return
	REMOVE_TRAIT(wearer, TRAIT_NO_TELEPORT, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/neck/itb/proc/is_worn()
	if(!wearer && isliving(loc))
		wearer = loc
	if(!wearer)
		return FALSE
	return wearer.get_slot_by_item(src) == ITEM_SLOT_NECK

/proc/has_active_itb_teleport_block(mob/living/target)
	if(!target)
		return FALSE

	var/obj/item/clothing/neck/itb/itb = target.get_item_by_slot(ITEM_SLOT_NECK)
	return istype(itb) && itb.locked && itb.tamper_stage < ITB_TAMPER_WIRES_CUT

#undef ITB_TAMPER_SECURE
#undef ITB_TAMPER_PANEL_OPEN
#undef ITB_TAMPER_WIRES_CUT
#undef ITB_TAMPER_LOCK_BYPASSED
#undef ITB_TAMPER_TIME
#undef ITB_TAMPER_FAILURE_CHANCE
#undef ITB_SCREWDRIVER_FAILURE_DAMAGE
#undef ITB_SHOCK_FAILURE_DAMAGE
