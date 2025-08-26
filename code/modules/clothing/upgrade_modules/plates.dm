// Armor plates.
// Can be attached to armor. Give bonus armor for laser and bullet


//MARK: Basic armor plate

/obj/item/armor_plate
	name = "armor plate"
	icon_state = "roman_shield"
	/// Plate class
	var/class = ARMOR_CLASS_ULTRA_LIGHT
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

/obj/item/armor_plate/Initialize(mapload)
	. = ..()
	armor_integrity = armor_max_integrity



/obj/item/armor_plate/attack_obj(obj/object, mob/living/user, params)
	if(!istype(object, /obj/item/clothing/suit))
		return ..()
	var/obj/item/clothing/suit/target = object
	if(class > target.allowed_armor_plate)
		balloon_alert(user, "не совместимо!")
		return
	target.armor_plate = src
	src.forceMove(target)
	//TODO apply effect
	//TODO register signals (detach, take damage, etc)


/// Calculate armor efficient percent in range 0-100
/obj/item/armor_plate/proc/get_armor_efficient()
	return clamp(armor_integrity / armor_protection_integrity * 100, 0, 100)
