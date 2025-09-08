// Armor plates.
// Can be attached to armor. Give bonus armor for laser and bullet


//MARK: Basic armor plate

/obj/item/armor_plate
	name = "armor plate"
	desc = "Базовая бронеплита, если вы видите этот текст, значит этой плите не сделали нормально описание."
	description_info = "Бронепробитие — это способность поражающего элемента (пули, снаряда) преодолеть защиту цели, определяемая его кинетической энергией, материалом и конструкцией (например, стальным сердечником). Защита классифицируется по уровням (классам брони) от I (легкие пистолетные пули) до V (мощные винтовочные бронебойные патроны). Каждый класс соответствует определённым типам угроз: так, бронежилет класса III остановит пулю АК-47, но будет пробит бронебойным патроном, для которого требуется класс IV или выше."
	icon = 'icons/obj/armor/plates.dmi'
	icon_state = "ceramicplate_light"
	/// Plate class
	var/plate_slot = ARMOR_PLATE_SLOT_HANDMADE
	/// Ballistic protection class
	var/ballistic_class = BALLISTIC_ARMOR_CLASS_NONE
	/// Laser protection class
	var/laser_class = LASER_ARMOR_CLASS_NONE
	/// Current integrity, default set armor_max_integrity value
	var/armor_integrity
	/// Armor integrity when armor begin decreasing protection
	var/armor_protection_integrity = 100
	/// Armor maximal integrity
	var/armor_max_integrity = 150
	/// Repair resource type
	var/repair_type = null
	/// Repair coefficient
	var/repair_coefficient = 0.6
	/// Covered body parts by plate
	body_parts_covered = UPPER_TORSO


/obj/item/armor_plate/Initialize(mapload)
	. = ..()
	armor_integrity = armor_max_integrity


/// Calculate armor efficient percent in range 0-1
/obj/item/armor_plate/proc/get_armor_efficient()
	return clamp(armor_integrity / armor_protection_integrity, 0, 1)

/// Take armor damage proc
/obj/item/armor_plate/proc/take_armor_damage(damage_amount)
	armor_integrity = max(armor_integrity - damage_amount, 0)

/// Try attach armor plate to suit
/obj/item/armor_plate/proc/try_attach_to_clothing(mob/user, obj/item/clothing/suit)
	if(plate_slot > suit.allowed_armor_plate)
		balloon_alert(user, "не совместимо")
		return FALSE
	if(suit == user.get_item_by_slot(suit.slot_flags))
		balloon_alert(user, "нужно сначала снять с себя!")
		return FALSE
	balloon_alert(user, "установка бронеплиты...")
	if(!do_after(user, 5 SECONDS, suit))
		return FALSE
	if(!user.drop_transfer_item_to_loc(src, suit)) // Make absolutely sure this accessory is removed from hands
		return FALSE
	forceMove(suit)
	suit.armor_plate = src
	balloon_alert(user, "бронеплита установлена")
	return TRUE


/// Try remove armor plate from suit
/obj/item/armor_plate/proc/try_detach_from_clothing(mob/living/user, obj/item/clothing/suit, obj/item/tool)
	if(!suit.can_remove_armor_plate)
		balloon_alert(user, "нельзя снять бронеплиту!")
		return FALSE
	if(suit == user.get_item_by_slot(suit.slot_flags))
		balloon_alert(user, "нужно сначала снять с себя!")
		return FALSE
	balloon_alert(user, "снятие бронеплиты...")
	if(!tool.use_tool(suit, user, 5 SECONDS, volume = tool.tool_volume))
		return FALSE
	balloon_alert(user, "бронеплита снята")
	forceMove(user.loc)
	user.put_in_hands(src)
	suit.armor_plate = null
	return TRUE


/obj/item/armor_plate/proc/get_examine_text()
	. = span_notice("Установлен[genderize_decode(gender, "", "а", "о", "ы")] [declent_ru(NOMINATIVE)]. ")
	. += span_notice(get_armor_text())
	. += span_notice(get_integrity_text())

/obj/item/armor_plate/proc/get_armor_text()
	. = ""
	if(ballistic_class > BALLISTIC_ARMOR_CLASS_NONE)
		. += "Обеспечивает баллистическую защиту от [GLOB.ballistic_armor_class_name["[ballistic_class]"]]"
	if(laser_class > BALLISTIC_ARMOR_CLASS_NONE)
		if(ballistic_class > BALLISTIC_ARMOR_CLASS_NONE)
			. += " и "
		else
			. += "Обеспечивает "
		. += " лазерную защиту от [GLOB.laser_armor_class_name["[laser_class]"]]"
	. += ". "

/obj/item/armor_plate/proc/get_integrity_text()
	if(armor_integrity == armor_max_integrity)
		return "Бронеплита совсем новая."
	else if(armor_integrity > armor_protection_integrity)
		return "На бронеплите имеется пара царапин."
	else if(armor_integrity > 0.75 * armor_protection_integrity)
		return "Бронеплита имеет незначительные повреждения."
	else if(armor_integrity > 0.50 * armor_protection_integrity)
		return "Бронеплита повреждена."
	else if(armor_integrity > 0.25 * armor_protection_integrity)
		return "Бронеплита сильно повреждена."
	else if(armor_integrity > 0)
		return "Бронеплита почти сломана."
	return "Бронеплита сломана и уже не защитит."

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
	var/can_repair_integrity = max(0, armor_protection_integrity - armor_integrity)
	if(!can_repair_integrity)
		balloon_alert(user, "невозможно отремонтировать")
		return ..()
	var/repair_integrity = min(repair_coefficient * resource.get_amount(), can_repair_integrity)
	var/consumed_resource = round(repair_integrity / repair_coefficient, 1)
	if(!consumed_resource)
		balloon_alert(user, "не хватает ресурсов")
		return ..()
	if(!do_after(user, 5 SECONDS, src))
		return ATTACK_CHAIN_BLOCKED_ALL
	if(resource.amount > consumed_resource)
		resource.use(consumed_resource)
	else
		qdel(item)
	repair_integrity = consumed_resource * repair_coefficient
	armor_protection_integrity += repair_integrity
	balloon_alert(user, "отремонтировано")
	return ATTACK_CHAIN_BLOCKED_ALL


// MARK: Balance procs

/proc/calculate_armor_plate_penetration(obj/item/armor_plate/plate, penetration_level, damagetype = BULLET)
	if(damagetype == BULLET)
		return calculate_armor_plate_penetration_for_bullet(plate, penetration_level)
	if(damagetype == LASER)
		return calculate_armor_plate_penetration_for_laser(plate, penetration_level)
	return 0

/proc/calculate_armor_plate_penetration_for_bullet(obj/item/armor_plate/plate, penetration_level)
	var/penetration_delta = plate.ballistic_class - penetration_level
	switch(penetration_delta)
		if(0)
			return 75 * plate.get_armor_efficient()
		if(1)
			return 95 * plate.get_armor_efficient()
		if(2 to 100)
			return 100 * plate.get_armor_efficient()
		if(-1)
			return 50 * plate.get_armor_efficient()
		if(-2)
			return 34 * plate.get_armor_efficient()
		if(-3)
			return 20 * plate.get_armor_efficient()
	return 0

/proc/calculate_armor_plate_penetration_for_laser(obj/item/armor_plate/plate, penetration_level)
	var/penetration_delta = plate.laser_class - penetration_level
	switch(penetration_delta)
		if(0)
			return 75 * plate.get_armor_efficient()
		if(1)
			return 95 * plate.get_armor_efficient()
		if(2 to 100)
			return 100 * plate.get_armor_efficient()
		if(-1)
			return 50 * plate.get_armor_efficient()
		if(-2)
			return 25 * plate.get_armor_efficient()
	return 0


/proc/damage_armor_plate(obj/item/armor_plate/plate, penetration_level, damagetype = BULLET, damage)
	var/damage_mod = 0 //damage only for bullet and lasers, others damage types are ignore
	if(damagetype == BULLET)
		damage_mod = calculate_armor_plate_damage_mod_for_bullet(plate, penetration_level)
	if(damagetype == LASER)
		damage_mod = calculate_armor_plate_damage_mod_for_laser(plate, penetration_level)
	var/calculated_damage = damage_mod * damage
	plate.take_armor_damage(calculated_damage)


/proc/calculate_armor_plate_damage_mod_for_bullet(obj/item/armor_plate/plate, penetration_level)
	var/penetration_delta = plate.ballistic_class - penetration_level
	switch(penetration_delta)
		if(0)
			return 1
		if(1)
			return 0.75
		if(2)
			return 0.5
		if(3 to 100)
			return 0.25
		if(-1)
			return 1.25
		if(-2)
			return 1.5
		if(-100 to -3)
			return 2
	return 1

/proc/calculate_armor_plate_damage_mod_for_laser(obj/item/armor_plate/plate, penetration_level)
	var/penetration_delta = plate.laser_class - penetration_level
	switch(penetration_delta)
		if(0)
			return 1
		if(1)
			return 0.75
		if(2)
			return 0.5
		if(3 to 100)
			return 0.25
		if(-1)
			return 1.25
		if(-2)
			return 1.5
		if(-100 to -3)
			return 2
	return 0

// MARK: Handmade armor plates
/obj/item/armor_plate/handmade_steel
	name = "handmade steel armor plate"
	icon_state = "steelplate_light" //TODO need icon
	plate_slot = ARMOR_PLATE_SLOT_HANDMADE
	ballistic_class = BALLISTIC_ARMOR_CLASS_I
	laser_class = LASER_ARMOR_CLASS_NONE
	armor_protection_integrity = 50
	armor_max_integrity = 50
	body_parts_covered = UPPER_TORSO

/obj/item/armor_plate/handmade_steel/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/handmade_ablative
	name = "handmade ablative armor plate"
	icon_state = "reflectorplate_light" //TODO need icon
	plate_slot = ARMOR_PLATE_SLOT_HANDMADE
	ballistic_class = BALLISTIC_ARMOR_CLASS_NONE
	laser_class = LASER_ARMOR_CLASS_LIGHT
	armor_protection_integrity = 50
	armor_max_integrity = 50
	body_parts_covered = UPPER_TORSO

/obj/item/armor_plate/handmade_ablative/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/kevlar
	name = "kevlar armor plate"
	icon_state = "steelplate_light" //TODO need icon
	plate_slot = ARMOR_PLATE_SLOT_HANDMADE
	ballistic_class = BALLISTIC_ARMOR_CLASS_II
	laser_class = LASER_ARMOR_CLASS_NONE
	armor_protection_integrity = 75
	armor_max_integrity = 75
	repair_type = /obj/item/stack/sheet/plastic
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/armor_plate/kevlar/helmet
	body_parts_covered = HEAD

// MARK: Light armor plates

/obj/item/armor_plate/light_steel
	name = "light steel armor plate"
	icon_state = "steelplate_light"
	plate_slot = ARMOR_PLATE_SLOT_LIGHT
	ballistic_class = BALLISTIC_ARMOR_CLASS_III
	laser_class = LASER_ARMOR_CLASS_NONE
	armor_protection_integrity = 100
	armor_max_integrity = 150
	repair_type = /obj/item/stack/sheet/metal
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/armor_plate/light_steel/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/light_ablative
	name = "light ablative armor plate"
	icon_state = "reflectorplate_light"
	plate_slot = ARMOR_PLATE_SLOT_LIGHT
	ballistic_class = BALLISTIC_ARMOR_CLASS_NONE
	laser_class = LASER_ARMOR_CLASS_LIGHT
	armor_protection_integrity = 75
	armor_max_integrity = 100
	repair_type = /obj/item/stack/sheet/plasmarglass
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/armor_plate/light_ablative/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/light_ceramic
	name = "light ceramic armor plate"
	icon_state = "ceramicplate_light"
	plate_slot = ARMOR_PLATE_SLOT_LIGHT
	ballistic_class = BALLISTIC_ARMOR_CLASS_IV
	laser_class = LASER_ARMOR_CLASS_NONE
	armor_protection_integrity = 75
	armor_max_integrity = 100
	repair_type = /obj/item/stack/sheet/mineral/titanium
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/armor_plate/light_ceramic/helmet
	body_parts_covered = HEAD


// MARK: Medium armor plates

/obj/item/armor_plate/medium_steel
	name = "medium steel armor plate"
	icon_state = "steelplate_medium"
	plate_slot = ARMOR_PLATE_SLOT_MEDIUM
	ballistic_class = BALLISTIC_ARMOR_CLASS_V
	laser_class = LASER_ARMOR_CLASS_NONE
	armor_protection_integrity = 200
	armor_max_integrity = 250
	repair_type = /obj/item/stack/sheet/plasteel
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/armor_plate/medium_steel/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/medium_ablative
	name = "medium ablative armor plate"
	icon_state = "reflectorplate_medium"
	plate_slot = ARMOR_PLATE_SLOT_MEDIUM
	ballistic_class = BALLISTIC_ARMOR_CLASS_I
	laser_class = LASER_ARMOR_CLASS_MEDIUM
	armor_protection_integrity = 200
	armor_max_integrity = 250
	repair_type = /obj/item/stack/sheet/plasmarglass
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/armor_plate/medium_ablative/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/medium_ceramic
	name = "medium ceramic armor plate"
	icon_state = "ceramicplate_medium"
	plate_slot = ARMOR_PLATE_SLOT_MEDIUM
	ballistic_class = BALLISTIC_ARMOR_CLASS_V
	laser_class = LASER_ARMOR_CLASS_LIGHT
	armor_protection_integrity = 100
	armor_max_integrity = 150
	repair_type = /obj/item/stack/sheet/mineral/titanium
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/armor_plate/medium_ceramic/helmet
	body_parts_covered = HEAD


// MARK: Heavy armor plates

/obj/item/armor_plate/heavy_steel
	name = "heavy steel armor plate"
	icon_state = "steelplate_heavy"
	plate_slot = ARMOR_PLATE_SLOT_HEAVY
	ballistic_class = BALLISTIC_ARMOR_CLASS_VI
	laser_class = LASER_ARMOR_CLASS_LIGHT
	armor_protection_integrity = 300
	armor_max_integrity = 350
	repair_type = /obj/item/stack/sheet/plasteel
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/armor_plate/heavy_steel/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/heavy_ablative
	name = "heavy ablative armor plate"
	icon_state = "reflectorplate_heavy"
	plate_slot = ARMOR_PLATE_SLOT_HEAVY
	ballistic_class = BALLISTIC_ARMOR_CLASS_II
	laser_class = LASER_ARMOR_CLASS_HEAVY
	armor_protection_integrity = 300
	armor_max_integrity = 350
	repair_type = /obj/item/stack/sheet/plasmarglass
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/armor_plate/heavy_ablative/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/heavy_ceramic
	name = "heavy ceramic armor plate"
	icon_state = "ceramicplate_heavy"
	plate_slot = ARMOR_PLATE_SLOT_HEAVY
	ballistic_class = BALLISTIC_ARMOR_CLASS_VI
	laser_class = LASER_ARMOR_CLASS_MEDIUM
	armor_protection_integrity = 200
	armor_max_integrity = 250
	repair_type = /obj/item/stack/sheet/mineral/titanium
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/armor_plate/heavy_ceramic/helmet
	body_parts_covered = HEAD

/obj/item/armor_plate/elite
	name = "elite armor plate"
	icon_state = "ceramicplate_heavy" //TODO need icon
	plate_slot = ARMOR_PLATE_SLOT_MAX
	ballistic_class = BALLISTIC_ARMOR_CLASS_MAX
	laser_class = LASER_ARMOR_CLASS_MAX
	armor_protection_integrity = 250
	armor_max_integrity = 500
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/armor_plate/elite/helmet
	body_parts_covered = HEAD
