/obj/item/gun_module/under
	slot = ATTACHMENT_SLOT_UNDER

/**
 * MARK: Flashlight
 */

/obj/item/gun_module/under/flashlight
	var/obj/item/flashlight/seclite/internal
	var/buffered_overlay_on

/obj/item/gun_module/under/flashlight/Destroy()
	. = ..()
	if(buffered_overlay_on)
		QDEL_NULL(buffered_overlay_on)
	if(QDELETED(internal))
		QDEL_NULL(internal)

/obj/item/gun_module/under/flashlight/Initialize(mapload)
	. = ..()
	internal = new()
	internal.forceMove(src)
	internal.set_light_flags(internal.light_flags | LIGHT_ATTACHED)

/obj/item/gun_module/under/flashlight/attack_self(mob/user)
	. = ..()
	internal.attack_self(user)
	update_icon()

/obj/item/gun_module/under/flashlight/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.set_gun_light(internal)
	RegisterSignal(target_gun, COMSIG_GUN_LIGHT_TOGGLE, PROC_REF(udate_icon_and_overlay))

/obj/item/gun_module/under/flashlight/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.set_gun_light(null)
	internal.forceMove(src)
	internal.set_light_flags(internal.light_flags | LIGHT_ATTACHED)
	UnregisterSignal(target_gun, COMSIG_GUN_LIGHT_TOGGLE)

/obj/item/gun_module/under/flashlight/proc/udate_icon_and_overlay()
	SIGNAL_HANDLER
	if(!gun)
		return
	gun.add_attachment_overlay(src)

/obj/item/gun_module/under/flashlight/update_icon_state()
	if(internal.on)
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun_module/under/flashlight/create_overlay()
	if(!internal.on)
		return ..()
	if(!buffered_overlay_on)
		buffered_overlay_on = mutable_appearance(icon, overlay_state + "_on", layer = FLOAT_LAYER - 1)
	return buffered_overlay_on

/obj/item/gun_module/under/flashlight/pistol
	name = "pistol underbarrel light"
	desc = "Фонарь, предназначенный для установки на цевьё пистолета. Несовместим с другими классами оружия."
	icon_state = "light"
	item_state = "light"
	overlay_state = "light_o"
	class = GUN_MODULE_CLASS_PISTOL_UNDER
	overlay_offset = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0)
	custom_price = PAYCHECK_LOWER

/obj/item/gun_module/under/flashlight/pistol/get_ru_names()
	return list(
		NOMINATIVE = "подствольный фонарь для пистолетов",
		GENITIVE = "подствольного фонаря для пистолетов",
		DATIVE = "подствольному фонарю для пистолетов",
		ACCUSATIVE = "подствольный фонарь для пистолетов",
		INSTRUMENTAL = "подствольным фонарём для пистолетов",
		PREPOSITIONAL = "подствольном фонаре для пистолетов",
	)

/obj/item/gun_module/under/flashlight/rifle
	name = "rifle underbarrel light"
	desc = "Фонарь, предназначенный для установки на цевьё. Несовместим с пистолетами."
	icon_state = "light_s"
	item_state = "light_s"
	overlay_state = "light_s_o"
	class = GUN_MODULE_CLASS_SHOTGUN_UNDER | GUN_MODULE_CLASS_RIFLE_UNDER
	overlay_offset = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0)
	custom_price = 1.5 * PAYCHECK_LOWER

/obj/item/gun_module/under/flashlight/rifle/get_ru_names()
	return list(
		NOMINATIVE = "подствольный фонарь",
		GENITIVE = "подствольного фонаря",
		DATIVE = "подствольному фонарю",
		ACCUSATIVE = "подствольный фонарь",
		INSTRUMENTAL = "подствольным фонарём",
		PREPOSITIONAL = "подствольном фонаре",
	)

/**
 * MARK: Handguard
 */

/obj/item/gun_module/under/hand
	var/bonus_accuracy = 15
	var/spread_reduction = 0.30
	var/spread_decrease = 0

/obj/item/gun_module/under/hand/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.accuracy.add_accuracy(bonus_accuracy)
	if(!target_gun.accuracy.max_spread)
		return
	spread_decrease = initial(target_gun.accuracy.max_spread) * spread_reduction
	target_gun.accuracy.max_spread = target_gun.accuracy.max_spread - spread_decrease

/obj/item/gun_module/under/hand/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.accuracy.add_accuracy(-bonus_accuracy)
	target_gun.accuracy.max_spread += spread_decrease
	spread_decrease = 0

/obj/item/gun_module/under/hand/simple
	name = "rifle hand"
	desc = "Прямая рукоятка, предназначенная для установки на нижнюю планку цевья. Повышает удобство стрельбы."
	gender = FEMALE
	icon_state = "hand"
	item_state = "hand"
	overlay_state = "hand_o"
	class = GUN_MODULE_CLASS_SHOTGUN_UNDER | GUN_MODULE_CLASS_RIFLE_UNDER
	overlay_offset = list(ATTACHMENT_OFFSET_X = 1, ATTACHMENT_OFFSET_Y = 0)
	bonus_accuracy = 10
	spread_reduction = 0.20
	custom_price = 2 * PAYCHECK_LOWER

/obj/item/gun_module/under/hand/simple/get_ru_names()
	return list(
		NOMINATIVE = "прямая рукоятка",
		GENITIVE = "прямой рукоятки",
		DATIVE = "прямую рукоятку",
		ACCUSATIVE = "прямая рукоятка",
		INSTRUMENTAL = "прямой рукояткой",
		PREPOSITIONAL = "прямой рукоятке",
	)

/obj/item/gun_module/under/hand/angle
	name = "rifle angle hand"
	desc = "Угловая рукоятка, предназначенная для установки на нижнюю планку цевья. Повышает удобство стрельбы."
	gender = FEMALE
	icon_state = "hand_a"
	item_state = "hand_a"
	overlay_state = "hand_a_o"
	class = GUN_MODULE_CLASS_SHOTGUN_UNDER | GUN_MODULE_CLASS_RIFLE_UNDER
	overlay_offset = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0)
	custom_price = 3 * PAYCHECK_LOWER

/obj/item/gun_module/under/hand/angle/get_ru_names()
	return list(
		NOMINATIVE = "угловая рукоятка",
		GENITIVE = "угловой рукоятки",
		DATIVE = "угловой рукоятке",
		ACCUSATIVE = "угловую рукоятку",
		INSTRUMENTAL = "угловой рукояткой",
		PREPOSITIONAL = "угловой рукоятке",
	)

/**
 * MARK: Laser Sight
 */

/obj/item/gun_module/under/laser
	name = "laser sight"
	desc = "Лазерный целеуказатель, предназначенный для установки на цевьё. Повышает точность стрельбы и понижает разброс при стрельбе."
	icon_state = "laser"
	item_state = "laser"
	overlay_state = "laser_o"
	class = GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_SHOTGUN_UNDER | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_SNIPER_UNDER
	overlay_offset = list(ATTACHMENT_OFFSET_X = -1, ATTACHMENT_OFFSET_Y = 1)
	var/enable = FALSE
	var/buffered_overlay_on
	var/bonus_accuracy = 10
	var/spread_decrease = 0
	var/datum/component/laser_sight/component_type
	custom_price = 2 * PAYCHECK_LOWER

/obj/item/gun_module/under/laser/Destroy()
	. = ..()
	if(buffered_overlay_on)
		QDEL_NULL(buffered_overlay_on)

/obj/item/gun_module/under/laser/create_overlay()
	if(!enable)
		return ..()
	if(!buffered_overlay_on)
		buffered_overlay_on = mutable_appearance(icon, overlay_state + "_on", layer = FLOAT_LAYER - 1)
	return buffered_overlay_on

/obj/item/gun_module/under/laser/update_icon_state()
	if(enable)
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun_module/under/laser/on_attach(obj/item/gun/target_gun, mob/user)
	RegisterSignal(target_gun, COMSIG_GUN_AFTER_LASER_SIGHT_TOGGLE, PROC_REF(laser_sight_toggle))
	gun.AddComponent(component_type)

/obj/item/gun_module/under/laser/on_detach(obj/item/gun/target_gun, mob/user)
	var/datum/component/comp = target_gun.GetComponent(component_type)
	QDEL_NULL(comp)
	UnregisterSignal(target_gun, COMSIG_GUN_AFTER_LASER_SIGHT_TOGGLE)

/obj/item/gun_module/under/laser/proc/laser_sight_toggle(datum/source, mob/user, enable)
	SIGNAL_HANDLER

	src.enable = enable
	if(gun)
		gun.add_attachment_overlay(src)
		update_icon()
	if(enable)
		add_bonus_accuracy()
		return
	remove_bonus_accuracy()

/obj/item/gun_module/under/laser/proc/add_bonus_accuracy()
	gun.accuracy.add_accuracy(bonus_accuracy)
	if(!gun.accuracy.max_spread)
		return
	spread_decrease = initial(gun.accuracy.max_spread) * 0.25
	gun.accuracy.max_spread = gun.accuracy.max_spread - spread_decrease

/obj/item/gun_module/under/laser/proc/remove_bonus_accuracy()
	gun.accuracy.add_accuracy(-bonus_accuracy)
	gun.accuracy.max_spread += spread_decrease
	spread_decrease = 0

/obj/item/gun_module/under/laser/ray
	name = "laser sight (ray)"
	component_type = /datum/component/laser_sight/ray

/obj/item/gun_module/under/laser/ray/get_ru_names()
	return list(
		NOMINATIVE = "лазерный целеуказатель (луч)",
		GENITIVE = "лазерного целеуказателя (луч)",
		DATIVE = "лазерному целеуказателю (луч)",
		ACCUSATIVE = "лазерный целеуказатель (луч)",
		INSTRUMENTAL = "лазерным целеуказателем (луч)",
		PREPOSITIONAL = "лазерном целеуказателе (луч)",
	)

/obj/item/gun_module/under/laser/point
	name = "laser sight (point)"
	component_type = /datum/component/laser_sight/point

/obj/item/gun_module/under/laser/point/get_ru_names()
	return list(
		NOMINATIVE = "лазерный целеуказатель (точка)",
		GENITIVE = "лазерного целеуказателя (точка)",
		DATIVE = "лазерному целеуказателю (точка)",
		ACCUSATIVE = "лазерный целеуказатель (точка)",
		INSTRUMENTAL = "лазерным целеуказателем (точка)",
		PREPOSITIONAL = "лазерном целеуказателе (точка)",
	)


// MARK: Bayonet
/obj/item/gun_module/under/bayonet
	name = "bayonet"
	desc = "Универсальный короткий клинок, оснащенный специальным креплением для монтажа на ствол винтовки. Основное предназначение — нанесение колющего удара в ближнем бою. Компактный дизайн и надежность конструкции делают его эффективным вспомогательным оружием."
	icon_state = "bayonet_short"
	item_state = "knife"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	overlay_state = "bayonet_short_o"
	overlay_offset = list(ATTACHMENT_OFFSET_X = 2, ATTACHMENT_OFFSET_Y = 4)
	class = GUN_MODULE_CLASS_RIFLE_UNDER
	force = 12
	throwforce = 12
	hitsound = 'sound/weapons/bladeslice.ogg'
	custom_price = 2 * PAYCHECK_CREW
	/// Addition force for attached gun
	var/bonus_force = 8
	/// Variable for save gun old hitsound
	var/old_hitsound
	/// Variable for save gun old sharp var
	var/old_sharp

/obj/item/gun_module/under/bayonet/get_ru_names()
	return list(
		NOMINATIVE = "штык-нож",
		GENITIVE = "штык-ножа",
		DATIVE = "штык-ножу",
		ACCUSATIVE = "штык-нож",
		INSTRUMENTAL = "штык-ножом",
		PREPOSITIONAL = "штык-ноже",
	)

/obj/item/gun_module/under/bayonet/long
	name = "long bayonet"
	desc = "Крупногабаритный клинок с удлиненным острием, предназначенный для крепления к оружию. Благодаря длине и прочности лезвия, обеспечивает дополнительную убойную силу при рукопашной атаке. Незаменим в ситуациях, когда стрельба невозможна или затруднительна."
	icon_state = "bayonet_long"
	overlay_state = "bayonet_long_o"
	overlay_offset = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = 4)
	w_class = WEIGHT_CLASS_NORMAL
	force = 15
	custom_price = 3 * PAYCHECK_CREW
	bonus_force = 10

/obj/item/gun_module/under/bayonet/long/get_ru_names()
	return list(
		NOMINATIVE = "длинный штык-нож",
		GENITIVE = "длинного штык-ножа",
		DATIVE = "длинному штык-ножу",
		ACCUSATIVE = "длинный штык-нож",
		INSTRUMENTAL = "длинным штык-ножом",
		PREPOSITIONAL = "длинном штык-ноже",
	)

/obj/item/gun_module/under/bayonet/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.force += bonus_force
	old_sharp = target_gun.sharp
	target_gun.sharp = TRUE
	old_hitsound = target_gun.hitsound
	target_gun.hitsound = hitsound

/obj/item/gun_module/under/bayonet/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.force -= bonus_force
	target_gun.sharp = old_sharp
	target_gun.hitsound = old_hitsound
	old_hitsound = null
