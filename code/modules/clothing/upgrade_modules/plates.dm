// Armor plates.
// Can be attached to armor. Give bonus armor for laser and bullet


// MARK: Defines
/// Heavy armor plates class. Allow only for specific: Syndicate, Nanotresen spacesuits.
#define ARMOR_PLATE_CLASS_HEAVY 3
/// Medium armor plates class. Allow only for special armors.
#define ARMOR_PLATE_CLASS_MEDIUM 2
/// Light armor plates class. Allow for all suits.
#define ARMOR_PLATE_CLASS_LIGHT 1
/// For deny armor plate in suit.
#define ARMOR_PLATE_CLASS_NONE 0


//MARK: Basic armor plate

/obj/item/armor_plate
	name = "armor plate"
	icon_state = "roman_shield"
	/// Plate class
	var/class = ARMOR_PLATE_CLASS_LIGHT
	/// Bonus bullet armor
	var/bullet = 0
	/// Bonus laser armor
	var/laser = 0


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
