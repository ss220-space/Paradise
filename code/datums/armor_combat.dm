/**
 * Kinetic armor resolution.
 *
 * Penetration is a chance, not a flat subtract. On a successful pen the original damage class is applied.
 * On a failed pen the hit is applied as blunt kinetic vs impact absorption.
 */

/datum/armor_hit_result
	var/penetrated = FALSE
	var/brute_damage = 0
	var/stamina_damage = 0
	var/applied_damage_class = BLUNT
	var/absorption = 0
	var/pen_chance = 0
	var/armor_rating = 0
	/// TRUE if a penetration roll was made (false for stamina skip_penetration).
	var/rolled_penetration = FALSE

/datum/armor_hit_result/proc/did_damage()
	return brute_damage > 0 || stamina_damage > 0

/// Maps legacy MELEE/BULLET flags onto the kinetic damage classes.
/proc/normalize_damage_class(damage_class)
	switch(damage_class)
		if(MELEE)
			return BLUNT
		if(BULLET)
			return PIERCING
		if(PIERCING, SLASHING, BLUNT)
			return damage_class
	return BLUNT

/// Logistic penetration chance.
/// pen_chance = 100 / (1 + exp(-0.24 * (AP - Armor + 5.8)))
/proc/calculate_armor_penetration_chance(armour_penetration, armor_rating)
	var/delta = armour_penetration - armor_rating + ARMOR_PENETRATION_CHANCE_BIAS
	var/exponent = clamp(-ARMOR_PENETRATION_CHANCE_STEEPNESS * delta, -ARMOR_PENETRATION_EXPONENT_CLAMP, ARMOR_PENETRATION_EXPONENT_CLAMP)
	return clamp(100 / (1 + (NUM_E ** exponent)), 0, 100)

/// blunt_damage = round(kinetic_force * (1 - absorption/100) / 20)
/proc/calculate_kinetic_blunt_damage(kinetic_force, absorption)
	return round(max(0, kinetic_force * (1 - clamp(absorption, 0, 100) / 100)) / KINETIC_BLUNT_DAMAGE_DIVISOR, DAMAGE_PRECISION)

/// Resolves a kinetic hit into brute / stamina amounts without applying them.
/// skip_penetration - stamina melee (batons, telescopic) never rolls pen and always uses absorption.
/// is_projectile - bullets convert softness into bonus damage on pen; melee does not.
/// structural - object integrity hits. Failed pen is absorbed kinetic force.
/proc/resolve_kinetic_hit(armor_rating, absorption, damage, armour_penetration, kinetic_force, softness = 0, skip_penetration = FALSE, is_projectile = FALSE, damage_class = BLUNT, structural = FALSE)
	RETURN_TYPE(/datum/armor_hit_result)

	var/datum/armor_hit_result/result = new
	result.armor_rating = armor_rating
	result.absorption = clamp(absorption, 0, 100)
	result.applied_damage_class = normalize_damage_class(damage_class)

	var/softness_factor = clamp(softness, 0, 100) / 100
	var/force = isnull(kinetic_force) ? damage : kinetic_force

	if(skip_penetration)
		if(structural)
			result.brute_damage = round(max(0, force * (1 - result.absorption / 100)), DAMAGE_PRECISION)
		else
			result.stamina_damage = calculate_kinetic_blunt_damage(force, result.absorption)
		return result

	result.pen_chance = calculate_armor_penetration_chance(armour_penetration, armor_rating)
	result.rolled_penetration = TRUE
	result.penetrated = prob(result.pen_chance)

	if(result.penetrated)
		result.brute_damage = damage
		if(is_projectile && !structural)
			result.brute_damage += damage * softness_factor
		return result

	result.applied_damage_class = BLUNT
	if(structural)
		result.brute_damage = round(max(0, force * (1 - result.absorption / 100)), DAMAGE_PRECISION)
		return result

	var/blunt_damage = calculate_kinetic_blunt_damage(force, result.absorption)
	result.stamina_damage = blunt_damage * softness_factor
	result.brute_damage = blunt_damage * (1 - softness_factor)
	return result

/// Applies a kinetic (brute/stamina) attack after rolling armor penetration.
/// Returns the [datum/armor_hit_result], or null if nothing was applied.
/mob/living/proc/apply_kinetic_attack(
	damage,
	def_zone,
	damage_class = BLUNT,
	armour_penetration = 0,
	kinetic_force,
	softness = 0,
	used_weapon = null,
	damtype = BRUTE,
	skip_penetration = FALSE,
	silent = FALSE,
	is_projectile = FALSE,
)
	if(damage <= 0 && (isnull(kinetic_force) || kinetic_force <= 0))
		last_kinetic_hit = null
		return null

	if(damtype != BRUTE && damtype != STAMINA)
		last_kinetic_hit = null
		var/legacy_armor = run_armor_check(def_zone, damage_class, armour_penetration = armour_penetration)
		apply_damage(damage, damtype, def_zone, legacy_armor, used_weapon = used_weapon)
		return null

	var/resolved_class = normalize_damage_class(damage_class)
	var/armor_rating = getarmor(def_zone, resolved_class)
	var/absorption = getarmor(def_zone, ABSORPTION)
	if(damtype == STAMINA && !is_projectile)
		skip_penetration = TRUE

	var/datum/armor_hit_result/result = resolve_kinetic_hit(
		armor_rating,
		absorption,
		damage,
		armour_penetration,
		isnull(kinetic_force) ? damage : kinetic_force,
		softness,
		skip_penetration,
		is_projectile,
		resolved_class,
	)

	if(!silent)
		announce_kinetic_hit(result, def_zone)

	if(result.brute_damage > 0)
		apply_damage(
			result.brute_damage,
			BRUTE,
			def_zone,
			blocked = 0,
			sharp = IS_SHARP_DAMAGE_CLASS(result.applied_damage_class),
			used_weapon = used_weapon,
			damage_class = result.applied_damage_class,
			armor_penetrated = result.penetrated,
		)
	if(result.stamina_damage > 0)
		apply_damage(result.stamina_damage, STAMINA, def_zone, blocked = 0, used_weapon = used_weapon)

	if(result.penetrated && result.brute_damage > 0)
		on_armor_penetrated(used_weapon, def_zone, result)
		if(isobj(used_weapon))
			var/obj/weapon_obj = used_weapon
			weapon_obj.on_armor_penetrated(src, def_zone, result.brute_damage)

	last_kinetic_hit = result
	return result

/mob/living/proc/announce_kinetic_hit(datum/armor_hit_result/result, def_zone)
	if(!result?.rolled_penetration)
		return
	if(result.penetrated)
		if(result.armor_rating > ARMOR_NOTICE_THRESHOLD)
			to_chat(src, span_userdanger("Ваша броня пробита!"))
		return
	to_chat(src, span_userdanger("Ваша броня не пробита!"))

/mob/living/proc/on_armor_penetrated(used_weapon, def_zone, datum/armor_hit_result/result)
	return

/mob/living/proc/get_melee_damage_class()
	return BLUNT
