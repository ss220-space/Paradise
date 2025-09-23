// Armor plates.
// Can be attached to armor. Give bonus armor for laser and bullet

//MARK: Basic armor plate
/obj/item/armor_plate
	name = "armor plate"
	desc = "Базовая бронеплита, которую вы не должны были увидеть. Сообщите о баге."
	description_info = "Бронепробитие — это способность поражающего элемента (пули, снаряда) преодолеть защиту цели, \
						определяемая его кинетической энергией, материалом и конструкцией (например, стальным сердечником). \
						Защита классифицируется по уровням (классам брони) от 1 (лёгкие пистолетные пули) до 7 (крупнокалиберные бронебойные патроны). \
						Каждый класс соответствует определённым типам угроз: так, бронежилет 5 класса остановит пулю АК-814, но будет пробит бронебойным патроном, для защиты от которого требуется класс 6 или выше."
	gender = FEMALE
	icon = 'icons/obj/armor/plates.dmi'
	lefthand_file = 'icons/mob/inhands/plates_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/plates_righthand.dmi'
	/// Plate type for status icon overlay
	var/status_icon_type
	/// Plate class
	var/plate_slot = ARMOR_PLATE_SLOT_HANDMADE
	/// Ballistic protection class
	var/ballistic_class = BALLISTIC_ARMOR_CLASS_NONE
	/// Laser protection class
	var/laser_class = LASER_ARMOR_CLASS_NONE
	/// Repair resource type
	var/repair_type = null
	/// Repair coefficient
	var/repair_coefficient = 10
	/// Covered body parts by plate
	body_parts_covered = UPPER_TORSO
	/// Armor plate slowdown
	var/equipped_slowdown = 0
	//becase stpd linter
	max_integrity = 0
	var/obj/item/clothing/attached_suit = null


/// Calculate armor efficient percent in range 0-1
/obj/item/armor_plate/proc/get_armor_efficient()
	return clamp(obj_integrity / integrity_failure, 0, 1)

/// Take armor damage proc
/obj/item/armor_plate/proc/take_armor_damage(damage_amount, mob/living/user, obj/item/clothing/suit)
	take_damage(damage_amountб sound_effect = FALSE)
	update_break_icon(src, suit, user)

/obj/item/armor_plate/default_welder_repair(mob/user, obj/item/I)
	return FALSE

/obj/item/armor_plate/obj_destruction(damage_flag)
	if(attached_suit)
		return
	return ..()

/// Try attach armor plate to suit
/obj/item/armor_plate/proc/try_attach_to_clothing(mob/user, obj/item/clothing/suit)
	if(suit.armor_plate)
		balloon_alert(user, "внутри есть другая плита!")
		return
	if(plate_slot > suit.allowed_armor_plate)
		balloon_alert(user, "несовместимо!")
		return FALSE
	if(suit == user.get_item_by_slot(suit.slot_flags))
		balloon_alert(user, "сначала снимите с себя!")
		return FALSE
	balloon_alert(user, "установка бронеплиты...")
	playsound(suit, 'sound/items/velcro/velcro_open.ogg', 30, TRUE, ignore_walls = FALSE)
	if(!do_after(user, 5 SECONDS, user, interaction_key = suit, max_interact_count = 1))
		return FALSE
	if(!user.drop_transfer_item_to_loc(src, suit)) // Make absolutely sure this accessory is removed from hands
		return FALSE
	playsound(suit, 'sound/items/velcro/velcro_close.ogg', 30, TRUE, ignore_walls = FALSE)
	forceMove(suit)
	suit.armor_plate = src
	suit.slowdown += equipped_slowdown
	attached_suit = suit
	balloon_alert(user, "бронеплита установлена")
	subscribe_equip_signal(suit)
	return TRUE

/obj/item/armor_plate/proc/subscribe_equip_signal(obj/item/clothing/suit)
	RegisterSignal(suit, COMSIG_CLOTHING_EQUIP, PROC_REF(update_break_icon))
	RegisterSignal(suit, COMSIG_CLOTHING_UNEQUIP, PROC_REF(update_break_icon))


/// Try remove armor plate from suit
/obj/item/armor_plate/proc/try_detach_from_clothing(mob/living/user, obj/item/clothing/suit)
	if(!suit.can_remove_armor_plate)
		balloon_alert(user, "бронеплиту нельзя извлечь!")
		return FALSE
	if(suit == user.get_item_by_slot(suit.slot_flags))
		balloon_alert(user, "сначала снимите с себя!")
		return FALSE
	balloon_alert(user, "извлечение бронеплиты...")
	playsound(suit, 'sound/items/velcro/velcro_open.ogg', 30, TRUE, ignore_walls = FALSE)
	if(!do_after(user, 5 SECONDS, user, interaction_key = suit, max_interact_count = 1))
		return FALSE
	playsound(suit, 'sound/items/velcro/velcro_close.ogg', 30, TRUE, ignore_walls = FALSE)
	forceMove(user.loc)
	suit.armor_plate = null
	suit.slowdown -= equipped_slowdown
	attached_suit = null
	UnregisterSignal(suit, list(COMSIG_CLOTHING_EQUIP, COMSIG_CLOTHING_UNEQUIP))
	if(obj_integrity <= 0)
		user.balloon_alert(user, "плита рассыпается в руках!")
		qdel(src)
	else
		user.put_in_hands(src)
		balloon_alert(user, "бронеплита извлечена")
	return TRUE


/obj/item/armor_plate/proc/get_examine_text(integrated_armor = FALSE)
	if(integrated_armor)
		. = span_notice("Встроенный бронеэлемент.")
	else
		. = span_notice("Установлен[genderize_ru(gender, "", "а", "о", "ы")] <b>[declent_ru(NOMINATIVE)]</b>. ")
	. += span_notice("\n– [get_armor_text()]")
	. += span_notice("\n– [get_integrity_text()]")

/obj/item/armor_plate/proc/get_armor_text()
	. = ""
	if(ballistic_class > BALLISTIC_ARMOR_CLASS_NONE)
		. += "Обеспечивает <b>баллистическую</b> защиту <b>[GLOB.ballistic_armor_class_name["[ballistic_class]"]] класса</b>"
	if(laser_class > BALLISTIC_ARMOR_CLASS_NONE)
		if(ballistic_class > BALLISTIC_ARMOR_CLASS_NONE)
			. += " и"
		else
			. += "Обеспечивает"
		. += " <b>лазерную</b> защиту <b>[GLOB.laser_armor_class_name["[laser_class]"]] класса</b>"
	. += ". "

/obj/item/armor_plate/proc/get_integrity_text()
	var/integrity_text
	if(obj_integrity == max_integrity)
		integrity_text = "В идеальном состоянии."
	else if(obj_integrity > integrity_failure)
		integrity_text = "Имеется пара царапин."
	else if(obj_integrity > 0.75 * integrity_failure)
		integrity_text = "Имеются незначительные повреждения."
	else if(obj_integrity > 0.50 * integrity_failure)
		integrity_text = "Имеются изрядные повреждения."
	else if(obj_integrity > 0.25 * integrity_failure)
		integrity_text = "Имеются сильные повреждения."
	else if(obj_integrity > 0)
		integrity_text = "Имеются критические повреждения."
	else
		integrity_text = "Уничтожен[genderize_ru(gender, "", "а", "о", "ы")] и не предоставля[pluralize_ru(gender, "ет", "ют")] защиту."
	return "<b>[integrity_text]</b>"

/obj/item/armor_plate/examine(mob/user)
	. = ..()
	. += span_notice(get_armor_text())
	. += span_notice(get_integrity_text())


/obj/item/armor_plate/attackby(obj/item/item, mob/user, params)
	if(!repair_type)
		return ..()
	if(!istype(item, repair_type))
		return ..()
	var/obj/item/stack/resource = item
	var/can_repair_integrity = max(0, integrity_failure - obj_integrity)
	if(!can_repair_integrity)
		balloon_alert(user, "невозможно отремонтировать!")
		return ..()
	var/repair_integrity = min(repair_coefficient * resource.get_amount(), can_repair_integrity)
	var/consumed_resource = round(repair_integrity / repair_coefficient, 1)
	if(!consumed_resource)
		balloon_alert(user, "недостаточно ресурсов!")
		return ..()
	balloon_alert(user, "ремонт бронеплиты...")
	if(!do_after(user, 15 SECONDS, user, interaction_key = src, max_interact_count = 1))
		return ATTACK_CHAIN_BLOCKED_ALL
	if(resource.amount > consumed_resource)
		resource.use(consumed_resource)
	else
		qdel(item)
	repair_integrity = consumed_resource * repair_coefficient
	obj_integrity += repair_integrity
	balloon_alert(user, "отремонтировано")
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/item/armor_plate/proc/update_break_icon(datum/source, obj/item/clothing/suit, mob/user)
	SIGNAL_HANDLER

	if(suit.status_overlays)
		suit.status_overlays.Cut()
	if(!(user.get_slot_by_item(suit) & suit.slot_flags))
		suit.update_icon(UPDATE_OVERLAYS)
		return

	LAZYINITLIST(suit.status_overlays)

	// armor plate type icon
	var/plate_break = obj_integrity <= 0
	if(plate_break)
		suit.status_overlays += mutable_appearance(icon, "status_[status_icon_type]_break")
	else
		suit.status_overlays += mutable_appearance(icon, "status_[status_icon_type]_ok")

	// armor plate status overlay
	var/plate_state = obj_integrity >= integrity_failure ? "good" : (obj_integrity > 0.25 * integrity_failure ? "normal" : "bad")
	suit.status_overlays += mutable_appearance(icon, "status_overlay_[plate_state]")

	suit.update_icon(UPDATE_OVERLAYS)


// MARK: Balance
/// Datum for armor penetration table
/datum/armor_penetration_balance
	/// delta = armor - penetration
	var/penetration_delta
	/// Armor damage multiplicator in range 0-1
	var/armor_damage
	/// Mob damage multiplicator in range 0-1
	var/mob_damage

/datum/armor_penetration_balance/New(penetration_delta, armor_damage, mob_damage)
	. = ..()
	src.penetration_delta = penetration_delta
	src.armor_damage = armor_damage
	src.mob_damage = mob_damage

/// Ballistic armor penetration table
GLOBAL_LIST_INIT(ballistic_armor_penetration_table, list(
	new /datum/armor_penetration_balance(penetration_delta=3, armor_damage=0.25, mob_damage=0.00), //armor > penetration
	new /datum/armor_penetration_balance(penetration_delta=2, armor_damage=0.50, mob_damage=0.00),
	new /datum/armor_penetration_balance(penetration_delta=1, armor_damage=0.75, mob_damage=0.05),
	new /datum/armor_penetration_balance(penetration_delta=0, armor_damage=1.00, mob_damage=0.25), // armor = penetration
	new /datum/armor_penetration_balance(penetration_delta=-1, armor_damage=1.25, mob_damage=0.50),
	new /datum/armor_penetration_balance(penetration_delta=-2, armor_damage=1.50, mob_damage=0.66),
	new /datum/armor_penetration_balance(penetration_delta=-3, armor_damage=2.00, mob_damage=0.80),
	new /datum/armor_penetration_balance(penetration_delta=-4, armor_damage=2.00, mob_damage=1.00), //armor < penetration
))

/// Laser armor penetration table
GLOBAL_LIST_INIT(laser_armor_penetration_table, list(
	new /datum/armor_penetration_balance(penetration_delta=3, armor_damage=0.25, mob_damage=0.00), //armor > penetration
	new /datum/armor_penetration_balance(penetration_delta=2, armor_damage=0.50, mob_damage=0.00),
	new /datum/armor_penetration_balance(penetration_delta=1, armor_damage=0.75, mob_damage=0.05),
	new /datum/armor_penetration_balance(penetration_delta=0, armor_damage=1.00, mob_damage=0.25), // armor = penetration
	new /datum/armor_penetration_balance(penetration_delta=-1, armor_damage=1.25, mob_damage=0.50),
	new /datum/armor_penetration_balance(penetration_delta=-2, armor_damage=1.50, mob_damage=0.75),
	new /datum/armor_penetration_balance(penetration_delta=-3, armor_damage=2.00, mob_damage=1.00), //armor < penetration
))

/proc/calculate_armor_plate_penetration(obj/item/armor_plate/plate, penetration_level, damagetype = BULLET)
	var/datum/armor_penetration_balance/balance = find_armor_plate_penetration_balance(plate, penetration_level, damagetype)
	if(!balance)
		return 0
	return (1 - balance.mob_damage) * plate.get_armor_efficient() * 100

/proc/damage_armor_plate(obj/item/armor_plate/plate, penetration_level, damagetype = BULLET, damage, mob/living/user, obj/item/clothing/suit)
	var/datum/armor_penetration_balance/balance = find_armor_plate_penetration_balance(plate, penetration_level, damagetype)
	if(!balance)
		return
	var/calculated_damage = round(balance.armor_damage * damage, 0.1)
	plate.take_armor_damage(calculated_damage, user, suit)

/proc/find_armor_plate_penetration_balance(obj/item/armor_plate/plate, penetration_level, damagetype = BULLET)
	var/list/table
	var/penetration_delta
	if(damagetype == BULLET)
		table = GLOB.ballistic_armor_penetration_table
		penetration_delta = plate.ballistic_class - penetration_level
	else if(damagetype == LASER)
		table = GLOB.laser_armor_penetration_table
		penetration_delta = plate.laser_class - penetration_level
	else
		return null
	var/datum/armor_penetration_balance/select = null
	for(var/datum/armor_penetration_balance/row as anything in table)
		if(row.penetration_delta == penetration_delta)
			return row
		if(!select || (row.penetration_delta < 0 && row.penetration_delta < select.penetration_delta) || (row.penetration_delta > 0 && row.penetration_delta > select.penetration_delta))
			select = row
	return select


// MARK: Handmade armor plates
/obj/item/armor_plate/handmade_steel
	name = "handmade steel armor plate"
	desc = "Бронеплита из приваренных друг к другу стальных пластин, созданная кустарным способом. \
			Предназначена для защиты от пистолетных калибров и осколков. \
			Тяжёлая и недолговечная, но лучше, чем ничего."
	icon_state = "steelplate_handmade"
	status_icon_type = "steel"
	ballistic_class = BALLISTIC_ARMOR_CLASS_I
	integrity_failure = 75
	max_integrity = 75

/obj/item/armor_plate/handmade_steel/get_ru_names()
	return list(
		NOMINATIVE = "самодельная стальная бронеплита",
		GENITIVE = "самодельной стальной бронеплиты",
		DATIVE = "самодельной стальной бронеплите",
		ACCUSATIVE = "самодельную стальную бронеплиту",
		INSTRUMENTAL = "самодельной стальной бронеплитой",
		PREPOSITIONAL = "самодельной стальной бронеплите"
	)

/obj/item/armor_plate/handmade_steel/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/handmade_ablative
	name = "handmade ablative armor plate"
	desc = "Бронеплита из приваренных друг к другу листов стекла, созданная кустарным способом. \
			Предназначена для защиты от маломощных энергетических снарядов. \
			Тяжёлая и недолговечная, но лучше, чем ничего."
	icon_state = "reflectorplate_handmade"
	status_icon_type = "ablative"
	laser_class = LASER_ARMOR_CLASS_LIGHT
	integrity_failure = 75
	max_integrity = 75

/obj/item/armor_plate/handmade_ablative/get_ru_names()
	return list(
		NOMINATIVE = "самодельная противолазерная бронеплита",
		GENITIVE = "самодельной противолазерной бронеплиты",
		DATIVE = "самодельной противолазерной бронеплите",
		ACCUSATIVE = "самодельную противолазерную бронеплиту",
		INSTRUMENTAL = "самодельной противолазерной бронеплитой",
		PREPOSITIONAL = "самодельной противолазерной бронеплите"
	)

/obj/item/armor_plate/handmade_ablative/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/kevlar
	name = "kevlar armor plate"
	desc = "Бронеплита из кевлара, предназначенная для защиты от пистолетных калибров и осколков. \
			Лёгкая и достаточно дешёвая."
	icon_state = "kevlar"
	status_icon_type = "ceramic"
	ballistic_class = BALLISTIC_ARMOR_CLASS_II
	integrity_failure = 75
	max_integrity = 100
	repair_type = /obj/item/stack/sheet/plastic
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/armor_plate/kevlar/get_ru_names()
	return list(
		NOMINATIVE = "кевларовая бронеплита",
		GENITIVE = "кевларовой бронеплиты",
		DATIVE = "кевларовой бронеплите",
		ACCUSATIVE = "кевларовую бронеплиту",
		INSTRUMENTAL = "кевларовой бронеплитой",
		PREPOSITIONAL = "кевларовой бронеплите"
	)

/obj/item/armor_plate/kevlar/helmet
	body_parts_covered = HEAD


// MARK: Light armor plates

/obj/item/armor_plate/light_steel
	name = "light steel armor plate"
	desc = "Бронеплита из баллистической стали, предназначенная для защиты от пистолетных калибров и осколков. \
			Легковесная и не сковывает движения носящего, что компенсируется относительно слабым классом защиты."
	icon_state = "steelplate_light"
	status_icon_type = "steel"
	plate_slot = ARMOR_PLATE_SLOT_LIGHT
	ballistic_class = BALLISTIC_ARMOR_CLASS_III
	integrity_failure = 200
	max_integrity = 250
	repair_type = /obj/item/stack/sheet/metal
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/armor_plate/light_steel/get_ru_names()
	return list(
		NOMINATIVE = "лёгкая стальная бронеплита",
		GENITIVE = "лёгкой стальной бронеплиты",
		DATIVE = "лёгкой стальной бронеплите",
		ACCUSATIVE = "лёгкую стальную бронеплиту",
		INSTRUMENTAL = "лёгкой стальной бронеплитой",
		PREPOSITIONAL = "лёгкой стальной бронеплите"
	)

/obj/item/armor_plate/light_steel/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/light_ablative
	name = "light ablative armor plate"
	desc = "Бронеплита из светоотражающих элементов, \
			предназначенная для защиты от маломощных энергетических снарядов. \
			Легковесная и не сковывает движения носящего, что компенсируется относительно слабым классом защиты."
	icon_state = "reflectorplate_light"
	status_icon_type = "ablative"
	plate_slot = ARMOR_PLATE_SLOT_LIGHT
	laser_class = LASER_ARMOR_CLASS_LIGHT
	integrity_failure = 200
	max_integrity = 250
	repair_type = /obj/item/stack/sheet/plasmarglass
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/armor_plate/light_ablative/get_ru_names()
	return list(
		NOMINATIVE = "лёгкая противолазерная бронеплита",
		GENITIVE = "лёгкой противолазерной бронеплиты",
		DATIVE = "лёгкой противолазерной бронеплите",
		ACCUSATIVE = "лёгкую противолазерную бронеплиту",
		INSTRUMENTAL = "лёгкой противолазерной бронеплитой",
		PREPOSITIONAL = "лёгкой противолазерной бронеплите"
	)

/obj/item/armor_plate/light_ablative/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/light_ceramic
	name = "light ceramic armor plate"
	desc = "Бронеплита из керамики, предназначенная для защиты от промежуточных калибров. \
			Легковесная и не сковывает движения носящего, \
			однако хорошо защищает относительно других плит той же весовой категории."
	icon_state = "ceramicplate_light"
	status_icon_type = "ceramic"
	plate_slot = ARMOR_PLATE_SLOT_LIGHT
	ballistic_class = BALLISTIC_ARMOR_CLASS_IV
	integrity_failure = 175
	max_integrity = 200
	repair_type = /obj/item/stack/sheet/mineral/titanium
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/armor_plate/light_ceramic/get_ru_names()
	return list(
		NOMINATIVE = "лёгкая керамическая бронеплита",
		GENITIVE = "лёгкой керамической бронеплиты",
		DATIVE = "лёгкой керамической бронеплите",
		ACCUSATIVE = "лёгкую керамическую бронеплиту",
		INSTRUMENTAL = "лёгкой керамической бронеплитой",
		PREPOSITIONAL = "лёгкой керамической бронеплите"
	)

/obj/item/armor_plate/light_ceramic/helmet
	body_parts_covered = HEAD


// MARK: Medium armor plates

/obj/item/armor_plate/medium_steel
	name = "medium steel armor plate"
	desc = "Бронеплита из баллистической стали, предназначенная для защиты от винтовочных калибров. \
			Обеспечивает баланс между защитой пользователя и удобством ношения."
	icon_state = "steelplate_medium"
	status_icon_type = "steel"
	plate_slot = ARMOR_PLATE_SLOT_MEDIUM
	ballistic_class = BALLISTIC_ARMOR_CLASS_V
	integrity_failure = 300
	max_integrity = 350
	repair_type = /obj/item/stack/sheet/plasteel
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	equipped_slowdown = 0.25

/obj/item/armor_plate/medium_steel/get_ru_names()
	return list(
		NOMINATIVE = "средняя стальная бронеплита",
		GENITIVE = "средней стальной бронеплиты",
		DATIVE = "средней стальной бронеплите",
		ACCUSATIVE = "среднюю стальную бронеплиту",
		INSTRUMENTAL = "средней стальной бронеплитой",
		PREPOSITIONAL = "средней стальной бронеплите"
	)

/obj/item/armor_plate/medium_steel/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/medium_ablative
	name = "medium ablative armor plate"
	desc = "Бронеплита из светоотражающих элементов, \
			предназначенная для защиты от энергетических снарядов средней мощности. \
			Обеспечивает баланс между защитой пользователя и удобством ношения."
	icon_state = "reflectorplate_medium"
	status_icon_type = "ablative"
	plate_slot = ARMOR_PLATE_SLOT_MEDIUM
	ballistic_class = BALLISTIC_ARMOR_CLASS_I
	laser_class = LASER_ARMOR_CLASS_MEDIUM
	integrity_failure = 300
	max_integrity = 350
	repair_type = /obj/item/stack/sheet/plasmarglass
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	equipped_slowdown = 0.25

/obj/item/armor_plate/medium_ablative/get_ru_names()
	return list(
		NOMINATIVE = "средняя противолазерная бронеплита",
		GENITIVE = "средней противолазерной бронеплиты",
		DATIVE = "средней противолазерной бронеплите",
		ACCUSATIVE = "среднюю противолазерную бронеплиту",
		INSTRUMENTAL = "средней противолазерной бронеплитой",
		PREPOSITIONAL = "средней противолазерной бронеплите"
	)

/obj/item/armor_plate/medium_ablative/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/medium_ceramic
	name = "medium ceramic armor plate"
	desc = "Бронеплита из керамики, предназначенная для защиты от винтовочных калибров. \
			Несколько сковывает движения пользователя, при этом превосходя плиты той же весовой категории \
			по защитным характеристикам."
	icon_state = "ceramicplate_medium"
	status_icon_type = "ceramic"
	plate_slot = ARMOR_PLATE_SLOT_MEDIUM
	ballistic_class = BALLISTIC_ARMOR_CLASS_V
	laser_class = LASER_ARMOR_CLASS_LIGHT
	integrity_failure = 250
	max_integrity = 275
	repair_type = /obj/item/stack/sheet/mineral/titanium
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	equipped_slowdown = 0.2

/obj/item/armor_plate/medium_ceramic/get_ru_names()
	return list(
		NOMINATIVE = "средняя керамическая бронеплита",
		GENITIVE = "средней керамической бронеплиты",
		DATIVE = "средней керамической бронеплите",
		ACCUSATIVE = "среднюю керамическую бронеплиту",
		INSTRUMENTAL = "средней керамической бронеплитой",
		PREPOSITIONAL = "средней керамической бронеплите"
	)

/obj/item/armor_plate/medium_ceramic/helmet
	body_parts_covered = HEAD


// MARK: Heavy armor plates

/obj/item/armor_plate/heavy_steel
	name = "heavy steel armor plate"
	desc = "Бронеплита из баллистической стали, предназначенная для защиты от мощных винтовочных калибров. \
			Тяжёлая и неудобная, что компенсируется высоким классом защиты."
	icon_state = "steelplate_heavy"
	status_icon_type = "steel"
	plate_slot = ARMOR_PLATE_SLOT_HEAVY
	ballistic_class = BALLISTIC_ARMOR_CLASS_VI
	laser_class = LASER_ARMOR_CLASS_LIGHT
	integrity_failure = 400
	max_integrity = 500
	repair_type = /obj/item/stack/sheet/plasteel
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	equipped_slowdown = 0.5

/obj/item/armor_plate/heavy_steel/get_ru_names()
	return list(
		NOMINATIVE = "тяжёлая стальная бронеплита",
		GENITIVE = "тяжёлой стальной бронеплиты",
		DATIVE = "тяжёлой стальной бронеплите",
		ACCUSATIVE = "тяжёлую стальную бронеплиту",
		INSTRUMENTAL = "тяжёлой стальной бронеплитой",
		PREPOSITIONAL = "тяжёлой стальной бронеплите"
	)

/obj/item/armor_plate/heavy_steel/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/heavy_ablative
	name = "heavy ablative armor plate"
	desc = "Бронеплита из светоотражающих элементов, \
			предназначенная для защиты от энергетических снарядов высокой мощности. \
			Тяжёлая и неудобная, что компенсируется высоким классом защиты."
	icon_state = "reflectorplate_heavy"
	status_icon_type = "ablative"
	plate_slot = ARMOR_PLATE_SLOT_HEAVY
	ballistic_class = BALLISTIC_ARMOR_CLASS_II
	laser_class = LASER_ARMOR_CLASS_HEAVY
	integrity_failure = 400
	max_integrity = 500
	repair_type = /obj/item/stack/sheet/plasmarglass
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	equipped_slowdown = 0.5

/obj/item/armor_plate/heavy_ablative/get_ru_names()
	return list(
		NOMINATIVE = "тяжёлая противолазерная бронеплита",
		GENITIVE = "тяжёлой противолазерной бронеплиты",
		DATIVE = "тяжёлой противолазерной бронеплите",
		ACCUSATIVE = "тяжёлую противолазерную бронеплиту",
		INSTRUMENTAL = "тяжёлой противолазерной бронеплитой",
		PREPOSITIONAL = "тяжёлой противолазерной бронеплите"
	)

/obj/item/armor_plate/heavy_ablative/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/heavy_ceramic
	name = "heavy ceramic armor plate"
	desc = "Бронеплита из керамики, предназначенная для защиты от мощных винтовочных калибров. \
			Тяжёлая и неудобная, что компенсируется высоким классом защиты. \
			Несколько превосходит плиты той же весовой категории по защитным характеристикам."
	icon_state = "ceramicplate_heavy"
	status_icon_type = "ceramic"
	plate_slot = ARMOR_PLATE_SLOT_HEAVY
	ballistic_class = BALLISTIC_ARMOR_CLASS_VI
	laser_class = LASER_ARMOR_CLASS_MEDIUM
	integrity_failure = 350
	max_integrity = 400
	repair_type = /obj/item/stack/sheet/mineral/titanium
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	equipped_slowdown = 0.4

/obj/item/armor_plate/heavy_ceramic/get_ru_names()
	return list(
		NOMINATIVE = "тяжёлая керамическая бронеплита",
		GENITIVE = "тяжёлой керамической бронеплиты",
		DATIVE = "тяжёлой керамической бронеплите",
		ACCUSATIVE = "тяжёлую керамическую бронеплиту",
		INSTRUMENTAL = "тяжёлой керамической бронеплитой",
		PREPOSITIONAL = "тяжёлой керамической бронеплите"
	)

/obj/item/armor_plate/heavy_ceramic/helmet
	body_parts_covered = HEAD


// MARK: Special

/obj/item/armor_plate/elite
	name = "elite armor plate"
	desc = "Бронеплита из высокотехнологичных комбинированных материалов. \
			Обеспечивает выдающуюся защиту как от баллистических, так и от энергетических снарядов, \
			при этом не сказываясь на мобильности пользователя. Такие выдают самым элитным бойцам."
	icon_state = "eliteplate"
	status_icon_type = "ceramic"
	plate_slot = ARMOR_PLATE_SLOT_MAX
	ballistic_class = BALLISTIC_ARMOR_CLASS_MAX
	laser_class = LASER_ARMOR_CLASS_MAX
	integrity_failure = 400
	max_integrity = 800
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|HANDS|FEET

/obj/item/armor_plate/elite/get_ru_names()
	return list(
		NOMINATIVE = "элитная бронеплита",
		GENITIVE = "элитной бронеплиты",
		DATIVE = "элитной бронеплите",
		ACCUSATIVE = "элитную бронеплиту",
		INSTRUMENTAL = "элитной бронеплитой",
		PREPOSITIONAL = "элитной бронеплите"
	)

/obj/item/armor_plate/elite/helmet
	body_parts_covered = HEAD


/obj/item/armor_plate/special_reflector
	name = "special reflector armor plate"
	desc = "Специальная бронеплита с рефлекторным покрытием для защиты от лазерного оружия."
	icon_state = "reflectorplate_heavy"
	status_icon_type = "ablative"
	plate_slot = ARMOR_PLATE_SLOT_MEDIUM
	laser_class = LASER_ARMOR_CLASS_HEAVY
	integrity_failure = 600
	max_integrity = 600
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|HANDS|FEET

/obj/item/armor_plate/special_reflector/get_ru_names()
	return list(
		NOMINATIVE = "рефлекторная бронеплита",
		GENITIVE = "рефлекторной бронеплиты",
		DATIVE = "рефлекторной бронеплите",
		ACCUSATIVE = "рефлекторную бронеплиту",
		INSTRUMENTAL = "рефлекторной бронеплитой",
		PREPOSITIONAL = "рефлекторной бронеплите"
	)

/obj/item/armor_plate/special_reflector/helmet
	body_parts_covered = HEAD
