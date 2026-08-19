#define ARMORID "armor-[piercing]-[slashing]-[blunt]-[absorption]-[laser]-[energy]-[bomb]-[bio]-[fire]-[acid]-[magic]"
/// Assosciative list of type -> armor. Used to ensure we always hold a reference to default armor datums
GLOBAL_LIST_INIT(armor_by_type, generate_armor_type_cache())
GLOBAL_LIST_EMPTY(armor_cache)

/proc/getArmor(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, fire = 0, acid = 0, magic = 0, piercing, slashing, blunt, absorption)
	if(isnull(piercing))
		piercing = bullet
	if(isnull(slashing))
		slashing = melee
	if(isnull(blunt))
		blunt = melee
	if(isnull(absorption))
		absorption = round((melee + bullet) / 2)
	var/armor_id = ARMORID
	var/list/cached_armor_cache = GLOB.armor_cache
	. = cached_armor_cache[armor_id]
	if(!.)
		var/datum/armor/new_armor = new(melee, bullet, laser, energy, bomb, bio, fire, acid, magic, piercing, slashing, blunt, absorption)
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
	/// Legacy melee rating. Used as a fallback for blunt/slashing if those are unset.
	var/melee
	/// Legacy bullet rating. Used as a fallback for piercing if that is unset.
	var/bullet
	var/piercing
	var/slashing
	var/blunt
	var/absorption
	var/laser
	var/energy
	var/bomb
	var/bio
	var/fire
	var/acid
	var/magic

/datum/armor/New(melee_value, bullet_value, laser_value, energy_value, bomb_value, bio_value, fire_value, acid_value, magic_value, piercing_value, slashing_value, blunt_value, absorption_value)
	melee = melee_value || melee || 0
	bullet = bullet_value || bullet || 0
	piercing = !isnull(piercing_value) ? piercing_value : (piercing || bullet || 0)
	slashing = !isnull(slashing_value) ? slashing_value : (slashing || melee || 0)
	blunt = !isnull(blunt_value) ? blunt_value : (blunt || melee || 0)
	if(!isnull(absorption_value))
		absorption = absorption_value
	else if(isnull(absorption))
		absorption = round((melee + bullet) / 2)
	else
		absorption = absorption || 0
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
	return ..()

/// Gets the rating of armor for the specified rating
/datum/armor/proc/getRating(rating)
	switch(rating)
		if(MELEE)
			return max(blunt, slashing, melee)
		if(BULLET)
			return max(piercing, bullet)
	if(!(rating in ARMOR_LIST_ALL()))
		CRASH("Attempted to get a rating '[rating]' that doesnt exist")
	return vars[rating]

/datum/armor/proc/modifyRating(melee_value = 0, bullet_value = 0, laser_value = 0, energy_value = 0, bomb_value = 0, bio_value = 0, fire_value = 0, acid_value = 0, magic_value = 0, piercing_value = 0, slashing_value = 0, blunt_value = 0, absorption_value = 0)
	var/new_piercing = piercing + piercing_value
	if(bullet_value && !piercing_value)
		new_piercing += bullet_value
	var/new_slashing = slashing + slashing_value
	if(melee_value && !slashing_value)
		new_slashing += melee_value
	var/new_blunt = blunt + blunt_value
	if(melee_value && !blunt_value)
		new_blunt += melee_value
	return getArmor(melee + melee_value, bullet + bullet_value, laser + laser_value, energy + energy_value, bomb + bomb_value, bio + bio_value, fire + fire_value, acid + acid_value, magic + magic_value, new_piercing, new_slashing, new_blunt, absorption + absorption_value)

/datum/armor/proc/modifyAllRatings(modifier = 0)
	return getArmor(melee + modifier, bullet + modifier, laser + modifier, energy + modifier, bomb + modifier, bio + modifier, fire + modifier, acid + modifier, magic + modifier, piercing + modifier, slashing + modifier, blunt + modifier, absorption + modifier)

/datum/armor/proc/setRating(melee_value, bullet_value, laser_value, energy_value, bomb_value, bio_value, fire_value, acid_value, magic_value, piercing_value, slashing_value, blunt_value, absorption_value)
	var/new_melee = isnull(melee_value) ? melee : melee_value
	var/new_bullet = isnull(bullet_value) ? bullet : bullet_value
	var/new_piercing = isnull(piercing_value) ? (isnull(bullet_value) ? piercing : bullet_value) : piercing_value
	var/new_slashing = isnull(slashing_value) ? (isnull(melee_value) ? slashing : melee_value) : slashing_value
	var/new_blunt = isnull(blunt_value) ? (isnull(melee_value) ? blunt : melee_value) : blunt_value
	var/new_absorption = isnull(absorption_value) ? absorption : absorption_value
	return getArmor(
		new_melee,
		new_bullet,
		(isnull(laser_value) ? laser : laser_value),
		(isnull(energy_value) ? energy : energy_value),
		(isnull(bomb_value) ? bomb : bomb_value),
		(isnull(bio_value) ? bio : bio_value),
		(isnull(fire_value) ? fire : fire_value),
		(isnull(acid_value) ? acid : acid_value),
		(isnull(magic_value) ? magic : magic_value),
		new_piercing,
		new_slashing,
		new_blunt,
		new_absorption,
	)

/datum/armor/proc/getList()
	return list(PIERCING = piercing, SLASHING = slashing, BLUNT = blunt, ABSORPTION = absorption, LASER = laser, ENERGY = energy, BOMB = bomb, BIO = bio, FIRE = fire, ACID = acid, MAGIC = magic)

/datum/armor/proc/attachArmor(datum/armor/AA)
	return getArmor(melee + AA.melee, bullet + AA.bullet, laser + AA.laser, energy + AA.energy, bomb + AA.bomb, bio + AA.bio, fire + AA.fire, acid + AA.acid, magic + AA.magic, piercing + AA.piercing, slashing + AA.slashing, blunt + AA.blunt, absorption + AA.absorption)

/datum/armor/proc/detachArmor(datum/armor/AA)
	return getArmor(melee - AA.melee, bullet - AA.bullet, laser - AA.laser, energy - AA.energy, bomb - AA.bomb, bio - AA.bio, fire - AA.fire, acid - AA.acid, magic - AA.magic, piercing - AA.piercing, slashing - AA.slashing, blunt - AA.blunt, absorption - AA.absorption)

/datum/armor/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, tag))
		return FALSE
	. = ..()
	tag = ARMORID // update tag in case armor values were edited

/// Checks if any of the armor values are non-zero, so this technically also counts negative armor!
/datum/armor/proc/has_any_armor()
	for(var/rating in ARMOR_LIST_ALL())
		if(vars[rating])
			return TRUE
	if(melee || bullet)
		return TRUE
	return FALSE

/**
 * Rounds armor_value down to the nearest 10 and divides it by 10.
 *
 * Arguments:
 * * armor_value - Number we're converting
 */
/proc/armor_to_protection_class(armor_value)
	if(armor_value < 0)
		. = "-"
	. += "[round(abs(armor_value), 10) / 10]"
	return .

/**
 * Returns the client readable name of an armor type
 *
 * Arguments:
 * * armor_type - The type to convert
 */
/proc/armor_to_protection_name(armor_type)
	switch(armor_type)
		if(ACID)
			return "КИСЛОТА"
		if(BIO)
			return "БИОУГРОЗА"
		if(BOMB)
			return "ВЗРЫВЫ"
		if(BULLET)
			return "БАЛЛИСТИКА"
		if(PIERCING)
			return "ПРОНИКАЮЩИЙ"
		if(SLASHING)
			return "РУБЯЩИЙ"
		if(BLUNT)
			return "ДРОБЯЩИЙ"
		if(ABSORPTION)
			return "ИМПУЛЬС"
		if(ENERGY)
			return "ЭНЕРГИЯ"
		if(FIRE)
			return "ОГОНЬ"
		if(LASER)
			return "ЛАЗЕРЫ"
		if(MELEE)
			return "УДАРЫ"
		if(MAGIC)
			return "МАГИЯ"

	CRASH("Unknown armor type '[armor_type]'")

/datum/armor/can_vv_mark()
	return FALSE

/datum/armor/vv_get_dropdown()
	SHOULD_CALL_PARENT(FALSE)
	return list("", "MUST MODIFY ARMOR VALUES ON THE PARENT ATOM")

#undef ARMORID
