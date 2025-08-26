// Armor plates.
// Can be attached to armor. Give bonus armor for laser and bullet


//MARK: Basic armor plate

/obj/item/armor_plate
	name = "armor plate"
	icon_state = "roman_shield"
	/// Plate class
	var/armor_class = ARMOR_CLASS_ULTRA_LIGHT
	/// Ballistic protection class
	var/ballistic_class = BALLISTIC_ARMOR_CLASS_I
	/// Laser protection class
	var/ballistic_class = LASER_ARMOR_CLASS_I
	/// Current integrity, default set armor_max_integrity value
	var/armor_integrity
	/// Armor integrity when armor begin decreasing
	var/armor_protection_integrity = 100
	/// Armor maximal integrity
	var/armor_max_integrity = 150
	/// Repair resource type
	var/repair_type = /obj/item/stack/sheet/plasteel
	/// Repair coefficient
	var/repair_coefficient = 2


/obj/item/armor_plate/Initialize(mapload)
	. = ..()
	armor_integrity = armor_max_integrity


/// Calculate armor efficient percent in range 0-100
/obj/item/armor_plate/proc/get_armor_efficient()
	return clamp(armor_integrity / armor_protection_integrity * 100, 0, 100)

/obj/item/armor_plate/proc/take_damage(damage_amount)
	armor_integrity = max(armor_integrity - damage_amount, 0)

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
	if(stack.amount > consumed_resource)
		item.use(consumed_resource)
	else
		qdel(item)
	repair_integrity = consumed_resource * repair_coefficient
	armor_protection_integrity += repair_integrity
	balloon_alert(user, "отремонтировано")
	return ATTACK_CHAIN_BLOCKED_ALL

