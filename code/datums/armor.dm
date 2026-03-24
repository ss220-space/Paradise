#define ARMORID "armor-[melee]-[bullet]-[laser]-[energy]-[bomb]-[bio]-[fire]-[acid]-[magic]"
/// Assosciative list of type -> armor. Used to ensure we always hold a reference to default armor datums
GLOBAL_LIST_INIT(armor_by_type, generate_armor_type_cache())
GLOBAL_LIST_EMPTY(armor_cache)

/proc/getArmor(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, fire = 0, acid = 0, magic = 0)
	var/armor_id = ARMORID
	var/list/cached_armor_cache = GLOB.armor_cache
	. = cached_armor_cache[armor_id]
	if(!.)
		var/datum/armor/new_armor = new (melee, bullet, laser, energy, bomb, bio, fire, acid, magic)
		cached_armor_cache[armor_id] = new_armor
		. = new_armor

/proc/generate_armor_type_cache()
	var/list/armor_cache = list()
	for(var/datum/armor/armor_type as anything in subtypesof(/datum/armor))
		armor_type = new armor_type
		armor_cache[armor_type.type] = armor_type
	return armor_cache

/**
 * Gets an armor type datum using the given type
 */
/proc/get_armor_by_type(armor_type)
	var/armor = GLOB.armor_by_type[armor_type]
	if(armor)
		return armor
	if(armor_type == /datum/armor)
		CRASH("Attempted to get the base armor type, you probably meant to use /datum/armor/none")
	CRASH("Attempted to get an armor type that did not exist! '[armor_type]'")

/// Sets the armor of this atom to the specified armor
/obj/proc/set_armor(datum/armor/armor)
	var/datum/armor/obj_armor = src.armor
	if(obj_armor == armor)
		return
	if(obj_armor && !((obj_armor.type in GLOB.armor_by_type) || (obj_armor.tag in GLOB.armor_cache)))
		qdel(obj_armor)
	src.armor = ispath(armor) ? get_armor_by_type(armor) : armor

/datum/armor
	var/melee
	var/bullet
	var/laser
	var/energy
	var/bomb
	var/bio
	var/fire
	var/acid
	var/magic

/datum/armor/New(melee_value, bullet_value, laser_value, energy_value, bomb_value, bio_value, fire_value, acid_value, magic_value)
	melee = melee_value || melee || 0
	bullet = bullet_value || bullet || 0
	laser = laser_value || laser || 0
	energy = energy_value || energy || 0
	bomb = bomb_value || bomb || 0
	bio = bio_value || bio || 0
	fire = fire_value || fire || 0
	acid = acid_value || acid || 0
	magic = magic_value || magic || 0
	tag = ARMORID

/datum/armor/Destroy(force)
	GLOB.armor_cache -= tag
	GLOB.armor_by_type -= type
	tag = null
	return ..()


/datum/armor/proc/modifyRating(melee_value = 0, bullet_value = 0, laser_value = 0, energy_value = 0, bomb_value = 0, bio_value = 0, fire_value = 0, acid_value = 0, magic_value = 0)
	return getArmor(melee + melee_value, bullet + bullet_value, laser + laser_value, energy + energy_value, bomb + bomb_value, bio + bio_value, fire + fire_value, acid + acid_value, magic + magic_value)

/datum/armor/proc/modifyAllRatings(modifier = 0)
	return getArmor(melee + modifier, bullet + modifier, laser + modifier, energy + modifier, bomb + modifier, bio + modifier, fire + modifier, acid + modifier, magic + modifier)

/datum/armor/proc/setRating(melee_value, bullet_value, laser_value, energy_value, bomb_value, bio_value, fire_value, acid_value, magic_value)
	return getArmor((isnull(melee_value) ? melee : melee_value),\
					(isnull(bullet_value) ? bullet : bullet_value),\
					(isnull(laser_value) ? laser : laser_value),\
					(isnull(energy_value) ? energy : energy_value),\
					(isnull(bomb_value) ? bomb : bomb_value),\
					(isnull(bio_value) ? bio : bio_value),\
					(isnull(fire_value) ? fire : fire_value),\
					(isnull(acid_value) ? acid : acid_value),\
					(isnull(magic_value) ? magic : magic_value))

/datum/armor/proc/getRating(attack_flag)
	if(!(attack_flag in ARMOR_LIST_ALL()))
		CRASH("Attempted to get a rating '[attack_flag]' that doesnt exist")
	return vars[attack_flag]

/datum/armor/proc/getList()
	return list(MELEE = melee, BULLET = bullet, LASER = laser, ENERGY = energy, BOMB = bomb, BIO = bio, FIRE = fire, ACID = acid, MAGIC = magic)

/datum/armor/proc/attachArmor(datum/armor/AA)
	return getArmor(melee + AA.melee, bullet + AA.bullet, laser + AA.laser, energy + AA.energy, bomb + AA.bomb, bio + AA.bio, fire + AA.fire, acid + AA.acid, magic + AA.magic)

/datum/armor/proc/detachArmor(datum/armor/AA)
	return getArmor(melee - AA.melee, bullet - AA.bullet, laser - AA.laser, energy - AA.energy, bomb - AA.bomb, bio - AA.bio, fire - AA.fire, acid - AA.acid, magic - AA.magic)

/datum/armor/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, tag))
		return FALSE
	. = ..()
	tag = ARMORID // update tag in case armor values were edited

#undef ARMORID
