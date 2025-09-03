// Armor plates.
// Can be attached to armor. Give bonus armor for laser and bullet


//MARK: Basic armor plate

/obj/item/armor_plate
	name = "armor plate"
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
	var/repair_type = /obj/item/stack/sheet/plasteel
	/// Repair coefficient
	var/repair_coefficient = 0.6
	/// Covered body parts by plate
	body_parts_covered = UPPER_TORSO


/obj/item/armor_plate/Initialize(mapload)
	. = ..()
	armor_integrity = armor_max_integrity


/// Calculate armor efficient percent in range 0-100
/obj/item/armor_plate/proc/get_armor_efficient()
	return clamp(armor_integrity / armor_protection_integrity * 100, 0, 100)

/// Take armor damage proc
/obj/item/armor_plate/proc/take_armor_damage(damage_amount)
	armor_integrity = max(armor_integrity - damage_amount, 0)

/// Try attach armor plate to suit
/obj/item/armor_plate/proc/try_attach_to_suit(mob/user, obj/item/clothing/suit/suit)
	if(plate_slot > suit.allowed_armor_plate)
		balloon_alert(user, "не совместимо")
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
/obj/item/armor_plate/proc/try_detach_from_suit(mob/living/user, obj/item/clothing/suit/suit, obj/item/tool)
	if(!suit.can_remove_armor_plate)
		balloon_alert(user, "нельзя снять бронеплиту!")
		return FALSE
	balloon_alert(user, "снятие бронеплиты...")
	if(!tool.use_tool(suit, user, 5 SECONDS, volume = tool.tool_volume))
		return FALSE
	balloon_alert(user, "бронеплита снята")
	forceMove(user.loc)
	user.put_in_hands(src)
	suit.armor_plate = null
	return TRUE


/obj/item/armor_plate/proc/get_suit_examine_text()
	. = span_notice("Установлен[genderize_decode(gender, "", "а", "о", "ы")] [declent_ru(NOMINATIVE)]. ")
	if(armor_integrity == armor_max_integrity)
		. += span_notice("Бронеплита совсем новая.")
	else if(armor_integrity > armor_protection_integrity)
		. += span_notice("На бронеплите имеется пара царапин.")
	else if(armor_integrity > 0.75 * armor_protection_integrity)
		. += span_notice("Бронеплита имеет незначительные повреждения.")
	else if(armor_integrity > 0.50 * armor_protection_integrity)
		. += span_notice("Бронеплита повреждена.")
	else if(armor_integrity > 0.25 * armor_protection_integrity)
		. += span_notice("Бронеплита сильно повреждена.")
	else
		. += span_notice("Бронеплита почти сломана.")


/obj/item/armor_plate/attackby(obj/item/item, mob/user, params)
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


// MARK: Light armor plates

/obj/item/armor_plate/light_steel
	name = "light steel armor plate"
	icon_state = "steelplate_light"
	plate_slot = ARMOR_PLATE_SLOT_LIGHT
	ballistic_class = BALLISTIC_ARMOR_CLASS_II
	laser_class = LASER_ARMOR_CLASS_NONE
	armor_protection_integrity = 100
	armor_max_integrity = 150
	repair_type = /obj/item/stack/sheet/metal
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/armor_plate/light_ceramic
	name = "light ceramic armor plate"
	icon_state = "ceramicplate_light"
	plate_slot = ARMOR_PLATE_SLOT_LIGHT
	ballistic_class = BALLISTIC_ARMOR_CLASS_IIIA
	laser_class = LASER_ARMOR_CLASS_NONE
	armor_protection_integrity = 75
	armor_max_integrity = 100
	repair_type = /obj/item/stack/sheet/mineral/titanium
	body_parts_covered = UPPER_TORSO|LOWER_TORSO


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


// MARK: Medium armor plates

/obj/item/armor_plate/medium_steel
	name = "medium steel armor plate"
	icon_state = "steelplate_medium"
	plate_slot = ARMOR_PLATE_SLOT_MEDIUM
	ballistic_class = BALLISTIC_ARMOR_CLASS_III
	laser_class = LASER_ARMOR_CLASS_NONE
	armor_protection_integrity = 200
	armor_max_integrity = 250
	repair_type = /obj/item/stack/sheet/plasteel
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/armor_plate/medium_ceramic
	name = "medium ceramic armor plate"
	icon_state = "ceramicplate_medium"
	plate_slot = ARMOR_PLATE_SLOT_MEDIUM
	ballistic_class = BALLISTIC_ARMOR_CLASS_III
	laser_class = LASER_ARMOR_CLASS_LIGHT
	armor_protection_integrity = 100
	armor_max_integrity = 150
	repair_type = /obj/item/stack/sheet/mineral/titanium
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS


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


// MARK: Heavy armor plates

/obj/item/armor_plate/heavy_steel
	name = "heavy steel armor plate"
	icon_state = "steelplate_heavy"
	plate_slot = ARMOR_PLATE_SLOT_HEAVY
	ballistic_class = BALLISTIC_ARMOR_CLASS_IV
	laser_class = LASER_ARMOR_CLASS_LIGHT
	armor_protection_integrity = 300
	armor_max_integrity = 350
	repair_type = /obj/item/stack/sheet/plasteel
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/armor_plate/heavy_ceramic
	name = "heavy ceramic armor plate"
	icon_state = "ceramicplate_heavy"
	plate_slot = ARMOR_PLATE_SLOT_HEAVY
	ballistic_class = BALLISTIC_ARMOR_CLASS_IV
	laser_class = LASER_ARMOR_CLASS_MEDIUM
	armor_protection_integrity = 200
	armor_max_integrity = 250
	repair_type = /obj/item/stack/sheet/mineral/titanium
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS


/obj/item/armor_plate/heavy_ablative
	name = "heavy ablative armor plate"
	icon_state = "reflectorplate_heavy"
	plate_slot = ARMOR_PLATE_SLOT_HEAVY
	ballistic_class = BALLISTIC_ARMOR_CLASS_IIA
	laser_class = LASER_ARMOR_CLASS_HEAVY
	armor_protection_integrity = 300
	armor_max_integrity = 350
	repair_type = /obj/item/stack/sheet/plasmarglass
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
