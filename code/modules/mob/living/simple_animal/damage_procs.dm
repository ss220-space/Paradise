/**
 * Proc-adjuster for all damage types, simple mob can have.
 * Any passed damage will be reduced by resists and converted to bruteloss afterwards.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * damagetype - What type of damage was inflicted. Used only to apply resists.
 * * forced - "Force" exactly the damage dealt. This means it skips any damage modifiers.
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/simple_animal/proc/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		var/oldbruteloss = bruteloss
		bruteloss = 0
		if(oldbruteloss != 0)
			updatehealth("adjustHealth")
		return STATUS_UPDATE_NONE
	if(!(damage_type in damage_coeff))
		damage_type = BRUTE
	if(!forced && amount > 0)
		amount *= ((100 - clamp(blocked + get_blocking_resistance(amount, damage_type), 0, 100)) / 100)
		amount *= get_incoming_damage_modifier(amount, damage_type)
		if(amount <= 0)
			return STATUS_UPDATE_NONE
	var/oldbruteloss = bruteloss
	bruteloss = clamp(round(bruteloss + amount, DAMAGE_PRECISION), 0, maxHealth)
	if(oldbruteloss == bruteloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustHealth")


/**
 * Proc-setter for all damage types, simple mob can have.
 * Any passed damage will be converted to bruteloss. No resists will be applied.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/simple_animal/proc/setHealth(amount, updating_health = TRUE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		var/oldbruteloss = bruteloss
		bruteloss = 0
		if(oldbruteloss != 0)
			updatehealth("setHealth")
		return STATUS_UPDATE_NONE
	var/oldbruteloss = bruteloss
	bruteloss = clamp(round(amount, DAMAGE_PRECISION), 0, maxHealth)
	if(oldbruteloss == bruteloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("setHealth")


/mob/living/simple_animal/get_incoming_damage_modifier(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	sharp = FALSE,
	used_weapon = null,
)
	. = ..()
	. *= damage_coeff[damagetype] || 0


/mob/living/simple_animal/adjustBruteLoss(
	amount = 0,
	updating_health = TRUE,
	def_zone = null,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
	sharp = FALSE,
	silent = FALSE,
	affect_robotic = TRUE,
)
	return adjustHealth(amount, updating_health, blocked, BRUTE, forced)


/mob/living/simple_animal/adjustFireLoss(
	amount = 0,
	updating_health = TRUE,
	def_zone = null,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
	sharp = FALSE,
	silent = FALSE,
	affect_robotic = TRUE,
)
	return adjustHealth(amount, updating_health, blocked, BURN, forced)


/mob/living/simple_animal/adjustOxyLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	return adjustHealth(amount, updating_health, blocked, OXY, forced)


/mob/living/simple_animal/setOxyLoss(amount, updating_health = TRUE)
	return setHealth(amount, updating_health)


/mob/living/simple_animal/adjustToxLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	return adjustHealth(amount, updating_health, blocked, TOX, forced)


/mob/living/simple_animal/setToxLoss(amount, updating_health = TRUE)
	return setHealth(amount, updating_health)


/mob/living/simple_animal/adjustCloneLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	return adjustHealth(amount, updating_health, blocked, CLONE, forced)


/mob/living/simple_animal/setCloneLoss(amount, updating_health = TRUE)
	return setHealth(amount, updating_health)


/mob/living/simple_animal/adjustStaminaLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	return adjustHealth(amount, updating_health, blocked, STAMINA, forced)


/mob/living/simple_animal/setStaminaLoss(amount, updating_health = TRUE)
	return setHealth(amount, updating_health)


