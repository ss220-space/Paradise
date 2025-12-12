#define ICON_MODE_PASSIVE "passive"
#define ICON_MODE_ACTIVE "active"

/obj/item/handheld_defibrillator
	name = "handheld defibrillator"
	desc = "Компактное устройство жёлтого цвета, используемое для экстренной кардиостимуляции."
	gender = MALE
	icon = 'icons/obj/handheld_defibrillator.dmi'
	icon_state = "defib_passive-on"
	item_state = "defib_passive"
	belt_icon = "handheld_defibrillator"
	var/icon_base = "defib"
	var/icon_mode = ICON_MODE_PASSIVE
	/// Can defib penetrate through hardsuits and etc.
	var/shield_ignore = FALSE
	var/cooldown = FALSE
	/// ~10 seconds
	var/charge_time = 100
	/// becomes TRUE for 1 second when used, changes the icon and is the delay between uses in advanced defib
	var/shocking = FALSE
	/// Affects the success rate of defibrillation
	var/is_advanced = FALSE
	/// Current number of charges
	var/charges = 1
	/// Maximum number of charges to which restoration occurs
	var/max_charges = 1


/obj/item/handheld_defibrillator/get_ru_names()
	return list(
		NOMINATIVE = "ручной дефибриллятор",
		GENITIVE = "ручного дефибриллятора",
		DATIVE = "ручному дефибриллятору",
		ACCUSATIVE = "ручной дефибриллятор",
		INSTRUMENTAL = "ручным дефибриллятором",
		PREPOSITIONAL = "ручном дефибрилляторе",
	)

/obj/item/handheld_defibrillator/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/obj/item/handheld_defibrillator/Destroy()
	UnregisterSignal(src, COMSIG_ITEM_DROPPED)
	. = ..()

/obj/item/handheld_defibrillator/attack_self(mob/user)
	. = ..()
	icon_mode = "[icon_mode == ICON_MODE_PASSIVE ? ICON_MODE_ACTIVE : ICON_MODE_PASSIVE]"
	update_icon(UPDATE_ICON_STATE)

/obj/item/handheld_defibrillator/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER  // COMSIG_ITEM_DROPPED
	icon_mode = ICON_MODE_PASSIVE
	update_icon(UPDATE_ICON_STATE)

/obj/item/handheld_defibrillator/update_icon_state()
	if(shocking)
		icon_state = "[icon_base]_[icon_mode]-shock"
		return
	if(max_charges == 1)  // yellow and syndicate
		icon_state = "[icon_base]_[icon_mode][charges == 0 ? "-off" : "-on"]"
	else  // advanced
		icon_state = "[icon_base]_[icon_mode]-[charges]"

/obj/item/handheld_defibrillator/attack(mob/living/carbon/human/H, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!istype(H))
		return ..()
	. = ATTACK_CHAIN_PROCEED
	var/blocked = FALSE
	var/obj/item/I = H.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER)
	if(istype(I, /obj/item/clothing/suit/space) && !shield_ignore)
		if(istype(I, /obj/item/clothing/suit/space/hardsuit))
			var/obj/item/clothing/suit/space/hardsuit/hardsuit = I
			blocked = hardsuit.hit_reaction(user, src, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)

	if(icon_mode == ICON_MODE_PASSIVE)
		balloon_alert(user, "лопасти не разложены!")
		return .

	if(charges == 0 || shocking)
		balloon_alert(user, "всё ещё заряжается!")
		return .

	if((H.health <= HEALTH_THRESHOLD_CRIT) || (H.undergoing_cardiac_arrest()))
		. |= ATTACK_CHAIN_SUCCESS
		H.balloon_alert_to_viewers("провод[PLUR_IT_YAT(user)] дефибрилляцию...", ignored_mobs = user)
		add_attack_logs(user, H, "defibrillated with [src]")
		playsound(get_turf(src), 'sound/weapons/egloves.ogg', 75, TRUE)
		if(!blocked)
			if(H.stat == DEAD)
				H.balloon_alert(user, "цель не реагирует!")
			if(H.stat != DEAD)
				H.set_heartattack(FALSE)
				var/total_damage = H.getBruteLoss() + H.getFireLoss() + H.getToxLoss()
				if(H.health <= HEALTH_THRESHOLD_CRIT)
					if(total_damage >= 90)
						balloon_alert(user, "цель слишком ранена!")   /// not h.balloon_alert so that they don't overlap each other
					if((prob(66)) || (is_advanced))
						H.balloon_alert(user, "дефибрилляция успешна")
						H.adjustOxyLoss(-50)
					else
						H.balloon_alert(user, "цель не реагирует!")

				H.AdjustKnockdown(4 SECONDS)
				H.AdjustStuttering(20 SECONDS)
				to_chat(H, span_danger("Вы чувствуете сильный удар током!"))
				H.shock_internal_organs(100)
		else
			H.balloon_alert(user, "закрыто одеждой!")
		shocking = TRUE
		update_icon(UPDATE_ICON_STATE)
		addtimer(CALLBACK(src, PROC_REF(short_charge)), 1 SECONDS)
		if(charges > 0)
			charges--
			update_icon(UPDATE_ICON_STATE)
			addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time)

	else
		H.balloon_alert(user, "дефибрилляция не требуется!")

/obj/item/handheld_defibrillator/proc/short_charge()
	shocking = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/item/handheld_defibrillator/proc/recharge()
	charges++
	update_icon(UPDATE_ICON_STATE)
	playsound(loc, 'sound/weapons/flash.ogg', 75, TRUE)

#undef ICON_MODE_PASSIVE
#undef ICON_MODE_ACTIVE

/obj/item/handheld_defibrillator/syndie
	name = "combat handheld defibrillator"
	desc = "Компактное устройство матово-чёрного цвета, используемое для экстренной кардиостимуляции. \
			За счёт интеграции конденсаторов нового поколения скорость перезарядки была увеличена втрое по сравнению со стандартной моделью. \
			Специализированная боевая версия, используемая элитными тактическими отрядами \"Синдиката\"."
	icon_state = "syndie_defib_passive-on"
	item_state = "syndie_defib_passive"
	icon_base = "syndie_defib"
	charge_time = 30
	shield_ignore = TRUE

/obj/item/handheld_defibrillator/syndie/get_ru_names()
	return list(
		NOMINATIVE = "боевой ручной дефибриллятор",
		GENITIVE = "боевого ручного дефибриллятора",
		DATIVE = "боевому ручному дефибриллятору",
		ACCUSATIVE = "боевой ручной дефибриллятор",
		INSTRUMENTAL = "боевым ручным дефибриллятором",
		PREPOSITIONAL = "боевом ручном дефибрилляторе",
	)

/obj/item/handheld_defibrillator/advanced
	name = "advanced handheld defibrillator"
	desc = "Компактное устройство тёмно-синего цвета с противоударными вставками, предназначенное для экстренной кардиостимуляции. \
			Использование продвинутых конденсаторов и энергомодуля нового поколения позволило повысить скорость перезарядки батареи, \
			а также увеличить её максимальную вместимость до трёх зарядов."
	icon_state = "adv_defib_passive-3"
	item_state = "adv_defib_passive"
	icon_base = "adv_defib"
	belt_icon = "advanced_handheld_defibrillator"
	origin_tech = "materials=6;biotech=6;magnets=5"
	is_advanced = TRUE
	charges = 3
	max_charges = 3
	charge_time = 70

/obj/item/handheld_defibrillator/advanced/get_ru_names()
	return list(
		NOMINATIVE = "продвинутый ручной дефибриллятор",
		GENITIVE = " продвинутого ручного дефибриллятора",
		DATIVE = "продвинутому ручному дефибриллятору",
		ACCUSATIVE = "продвинутый ручной дефибриллятор",
		INSTRUMENTAL = "продвинутым ручным дефибриллятором",
		PREPOSITIONAL = "продвинутом ручном дефибрилляторе",
	)

/obj/item/handheld_defibrillator/advanced/examine(mob/user)
	. = ..()
	. += span_boldnotice("Индикатор заряда: [charges]/[max_charges].")
