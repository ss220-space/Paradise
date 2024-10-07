
/**
 * Applies damage to this mob.
 *
 * Arguments:
 * * damage - Amount of damage.
 * * damagetype - What type of damage to do. one of [BRUTE], [BURN], [TOX], [OXY], [STAMINA], [CLONE], [BRAIN].
 * * def_zone - What body zone is being hit. Or a reference to what bodypart is being hit.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * sharp - Sharpness of the weapon.
 * * used_weapon - Item that is attacking [src].
 * * spread_damage - For humans, spreads the damage across all bodyparts rather than just the targeted zone.
 * * forced - "Force" exactly the damage dealt. This means it skips any damage modifiers. Also will not apply fractures or internal bleedings.
 * * silent - If TRUE will not spam red messages in chat.
 * * updating_health - If TRUE calls update health in associative damage proc.
 * * update_damage_icon - If TRUE updates mob's damage icon. Mostly used in tandem with [apply_damages][/mob/living/proc/apply_damages].
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/apply_damage(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	blocked = 0,
	sharp = FALSE,
	used_weapon = null,
	spread_damage = FALSE,
	forced = FALSE,
	silent = FALSE,
	updating_health = TRUE,
	update_damage_icon = TRUE,
)
	SHOULD_CALL_PARENT(TRUE)

	. = STATUS_UPDATE_NONE
	if(damage <= 0)
		return .

	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMAGE, damage, damagetype, def_zone, blocked, sharp, used_weapon, spread_damage, forced)

	switch(damagetype)
		if(BRUTE)
			if(isexternalorgan(def_zone))
				var/obj/item/organ/external/bodypart = def_zone
				var/brute_was = bodypart.brute_dam
				if(bodypart.external_receive_damage(damage, 0, blocked, sharp, used_weapon, forced = forced, updating_health = FALSE, silent = silent) && update_damage_icon)
					UpdateDamageIcon()
				if(QDELETED(bodypart) || bodypart.loc != src || bodypart.brute_dam != brute_was)
					. |= STATUS_UPDATE_HEALTH
					if(updating_health)
						updatehealth("apply damage")
			else
				. |= adjustBruteLoss(damage, updating_health, def_zone, blocked, forced, used_weapon, sharp, silent)
		if(BURN)
			if(isexternalorgan(def_zone))
				var/obj/item/organ/external/bodypart = def_zone
				var/burn_was = bodypart.burn_dam
				if(bodypart.external_receive_damage(0, damage, blocked, sharp, used_weapon, forced = forced, updating_health = FALSE, silent = silent) && update_damage_icon)
					UpdateDamageIcon()
				if(QDELETED(bodypart) || bodypart.loc != src || bodypart.burn_dam != burn_was)
					. |= STATUS_UPDATE_HEALTH
					if(updating_health)
						updatehealth("apply damage")
			else
				. |= adjustFireLoss(damage, updating_health, def_zone, blocked, forced, used_weapon, sharp, silent)
		if(TOX)
			. |= adjustToxLoss(damage, updating_health, blocked, forced, used_weapon)
		if(OXY)
			. |= adjustOxyLoss(damage, updating_health, blocked, forced, used_weapon)
		if(CLONE)
			. |= adjustCloneLoss(damage, updating_health, blocked, forced, used_weapon)
		if(STAMINA)
			. |= adjustStaminaLoss(damage, updating_health, blocked, forced, used_weapon)
		if(BRAIN)
			. |= adjustBrainLoss(damage, updating_health, blocked, forced, used_weapon)


/// Collects all possible flat damage resistances
/mob/living/proc/get_blocking_resistance(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	sharp = FALSE,
	used_weapon = null,
)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)

	var/list/resistances = list()
	SEND_SIGNAL(src, COMSIG_MOB_APPLY_BLOCKING_RESISTANCES, resistances, damage, damagetype, def_zone, sharp, used_weapon)

	. = 0
	for(var/new_resist in resistances)
		. += new_resist


/// Collects all possible modifiers for damagetypes
/mob/living/proc/get_incoming_damage_modifier(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	sharp = FALSE,
	used_weapon = null,
)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)

	var/list/damage_mods = list()
	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, damage_mods, damage, damagetype, def_zone, sharp, used_weapon)

	. = 1 * get_vampire_bonus(damagetype)
	for(var/new_mod in damage_mods)
		. *= new_mod


/// Applies multiple damages at once via [apply_damage][/mob/living/proc/apply_damage]
/mob/living/proc/apply_damages(
	brute = 0,
	burn = 0,
	tox = 0,
	oxy = 0,
	clone = 0,
	stamina = 0,
	brain = 0,
	def_zone = null,
	blocked = 0,
	sharp = FALSE,
	used_weapon = null,
	spread_damage = FALSE,
	forced = FALSE,
	silent = FALSE,
	updating_health = TRUE,
)
	SHOULD_CALL_PARENT(TRUE)

	. = STATUS_UPDATE_NONE
	var/should_update_health = FALSE
	var/should_update_damage_icon = FALSE
	var/def_zone_external = isexternalorgan(def_zone)
	if(brute)
		. |= apply_damage(brute, BRUTE, def_zone, blocked, sharp, used_weapon, spread_damage, forced, silent, FALSE, FALSE)
		if(.)
			if(updating_health)
				should_update_health = TRUE
			if(def_zone_external)
				should_update_damage_icon = TRUE
	if(burn)
		. |= apply_damage(burn, BURN, def_zone, blocked, sharp, used_weapon, spread_damage, forced, silent, FALSE, FALSE)
		if(.)
			if(updating_health)
				should_update_health = TRUE
			if(def_zone_external)
				should_update_damage_icon = TRUE
	if(tox)
		. |= apply_damage(tox, TOX, def_zone, blocked, sharp, used_weapon, spread_damage, forced, silent, FALSE, FALSE)
		if(. && updating_health)
			should_update_health = TRUE
	if(oxy)
		. |= apply_damage(oxy, OXY, def_zone, blocked, sharp, used_weapon, spread_damage, forced, silent, FALSE, FALSE)
		if(. && updating_health)
			should_update_health = TRUE
	if(clone)
		. |= apply_damage(clone, CLONE, def_zone, blocked, sharp, used_weapon, spread_damage, forced, silent, FALSE, FALSE)
		if(. && updating_health)
			should_update_health = TRUE
	if(stamina)
		. |= apply_damage(stamina, STAMINA, def_zone, blocked, sharp, used_weapon, spread_damage, forced, silent, FALSE, FALSE)
		if(. && updating_health)
			should_update_health = TRUE
	if(brain)
		. |= apply_damage(brain, BRAIN, def_zone, blocked, sharp, used_weapon, spread_damage, forced, silent, FALSE, FALSE)
		if(. && updating_health)
			should_update_health = TRUE
	if(should_update_health)
		updatehealth("apply_damages")
	if(should_update_damage_icon)
		UpdateDamageIcon()


/**
 * Simply a wrapper for calling mob adjustXLoss() procs to heal a certain damage type,
 * when you don't know what damage type you're healing exactly.
 */
/mob/living/proc/heal_damage_type(
	heal_amount = 0,
	damagetype = BRUTE,
	updating_health = TRUE,
	affect_robotic = FALSE,
)
	heal_amount = -abs(heal_amount)
	switch(damagetype)
		if(BRUTE)
			return adjustBruteLoss(heal_amount, updating_health, affect_robotic = affect_robotic)
		if(BURN)
			return adjustFireLoss(heal_amount, updating_health, affect_robotic = affect_robotic)
		if(TOX)
			return adjustToxLoss(heal_amount, updating_health)
		if(OXY)
			return adjustOxyLoss(heal_amount, updating_health)
		if(CLONE)
			return adjustCloneLoss(heal_amount, updating_health)
		if(STAMINA)
			return adjustStaminaLoss(heal_amount, updating_health)
		if(BRAIN)
			return adjustBrainLoss(heal_amount, updating_health)


/// Heal multiple damages at once via [heal_damage_type][/mob/living/proc/heal_damage_type]
/mob/living/proc/heal_damages(
	brute = 0,
	burn = 0,
	tox = 0,
	oxy = 0,
	clone = 0,
	stamina = 0,
	brain = 0,
	updating_health = TRUE,
	affect_robotic = FALSE,
)
	. = STATUS_UPDATE_NONE
	if(brute)
		. |= heal_damage_type(brute, BRUTE, FALSE, affect_robotic)
	if(burn)
		. |= heal_damage_type(burn, BURN, FALSE, affect_robotic)
	if(tox)
		. |= heal_damage_type(tox, TOX, FALSE)
	if(oxy)
		. |= heal_damage_type(oxy, OXY, FALSE)
	if(clone)
		. |= heal_damage_type(clone, CLONE, FALSE)
	if(stamina)
		. |= heal_damage_type(stamina, STAMINA, FALSE)
	if(brain)
		. |= heal_damage_type(brain, BRAIN, FALSE)
	if(. && updating_health)
		updatehealth("heal_damages")


/// Returns current mob's damage for passed damage type
/mob/living/proc/get_damage_amount(damagetype = BRUTE)
	switch(damagetype)
		if(BRUTE)
			return getBruteLoss()
		if(BURN)
			return getFireLoss()
		if(TOX)
			return getToxLoss()
		if(OXY)
			return getOxyLoss()
		if(CLONE)
			return getCloneLoss()
		if(STAMINA)
			return getStaminaLoss()
		if(BRAIN)
			return getBrainLoss()


/// Applies passed status effect
/mob/living/proc/apply_effect(effect = 0, effecttype = STUN, blocked = 0, negate_armor = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	blocked = (100-blocked)/100
	if(!effect || (blocked <= 0))
		return FALSE
	switch(effecttype)
		if(STUN)
			Stun(effect * blocked)
		if(WEAKEN)
			Weaken(effect * blocked)
		if(PARALYZE)
			Paralyse(effect * blocked)
		if(IRRADIATE)
			if(HAS_TRAIT(src, TRAIT_RADIMMUNE))
				return FALSE
			var/rad_damage = effect
			if(!negate_armor) // Setting negate_armor overrides radiation armor checks, which are automatic otherwise
				rad_damage = max(effect * ((100-run_armor_check(null, "rad", "Your clothes feel warm.", "Your clothes feel warm."))/100),0)
			radiation += rad_damage
		if(SLUR)
			Slur(effect * blocked)
		if(STUTTER)
			Stuttering(effect * blocked)
		if(EYE_BLUR)
			EyeBlurry(effect * blocked)
		if(DROWSY)
			Drowsy(effect * blocked)
		if(JITTER)
			Jitter(effect * blocked)
		if(KNOCKDOWN)
			Knockdown(effect * blocked)
	updatehealth("apply effect")
	return TRUE


/// Applies multiple status effects at once via [apply_effect][/mob/living/proc/apply_effect]
/mob/living/proc/apply_effects(blocked = 0, stun = 0, weaken = 0, paralyze = 0, irradiate = 0, slur = 0,stutter = 0, eyeblur = 0, drowsy = 0, stamina = 0, jitter = 0, knockdown = 0)
	if(blocked >= 100)
		return FALSE
	if(stun)
		apply_effect(stun, STUN, blocked)
	if(weaken)
		apply_effect(weaken, WEAKEN, blocked)
	if(paralyze)
		apply_effect(paralyze, PARALYZE, blocked)
	if(irradiate)
		apply_effect(irradiate, IRRADIATE, blocked)
	if(slur)
		apply_effect(slur, SLUR, blocked)
	if(stutter)
		apply_effect(stutter, STUTTER, blocked)
	if(eyeblur)
		apply_effect(eyeblur, EYE_BLUR, blocked)
	if(drowsy)
		apply_effect(drowsy, DROWSY, blocked)
	if(stamina)
		apply_damage(stamina, STAMINA, null, blocked)
	if(jitter)
		apply_effect(jitter, JITTER, blocked)
	if(knockdown)
		apply_effect(knockdown, KNOCKDOWN, blocked)
	return TRUE


/// Bruteloss var getter
/mob/living/proc/getBruteLoss()
	return bruteloss


/**
 * Applies brute damage to this mob.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 * * def_zone - What body zone is being hit. Or a reference to what bodypart is being hit.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * forced - "Force" exactly the damage dealt. This means it skips any damage modifiers. Also will not apply fractures or internal bleedings.
 * * used_weapon - Item that is attacking [src].
 * * sharp - Sharpness of the weapon.
 * * silent - If TRUE will not spam red messages in chat.
 * * affect_robotic - If TRUE will apply damage to human robotic bodyparts.
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/adjustBruteLoss(
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
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		var/old_bruteloss = getBruteLoss()
		bruteloss = 0
		if(old_bruteloss != 0)
			updatehealth("adjustBruteLoss")
		return STATUS_UPDATE_NONE
	if(!forced && amount > 0)
		amount *= ((100 - clamp(blocked + get_blocking_resistance(amount, BRUTE, def_zone, sharp, used_weapon), 0, 100)) / 100)
		amount *= get_incoming_damage_modifier(amount, BRUTE, def_zone, sharp, used_weapon)
		if(amount <= 0)
			return STATUS_UPDATE_NONE
	var/old_bruteloss = getBruteLoss()
	bruteloss = max(round(bruteloss + amount, DAMAGE_PRECISION), 0)
	if(old_bruteloss == getBruteLoss())
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustBruteLoss")


/// Fireloss var getter
/mob/living/proc/getFireLoss()
	return fireloss


/**
 * Applies burn damage to this mob.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 * * def_zone - What body zone is being hit. Or a reference to what bodypart is being hit.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * forced - "Force" exactly the damage dealt. This means it skips any damage modifiers. Also will not apply fractures or internal bleedings.
 * * used_weapon - Item that is attacking [src].
 * * sharp - Sharpness of the weapon.
 * * silent - If TRUE will not spam red messages in chat.
 * * affect_robotic - If TRUE will apply damage to human robotic bodyparts.
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/adjustFireLoss(
	amount,
	updating_health = TRUE,
	def_zone = null,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
	sharp = FALSE,
	silent = FALSE,
	affect_robotic = TRUE,
)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		var/old_fireloss = getFireLoss()
		fireloss = 0
		if(old_fireloss != 0)
			updatehealth("adjustFireLoss")
		return STATUS_UPDATE_NONE
	if(!forced && amount > 0)
		amount *= ((100 - clamp(blocked + get_blocking_resistance(amount, BURN, def_zone, sharp, used_weapon), 0, 100)) / 100)
		amount *= get_incoming_damage_modifier(amount, BURN, def_zone, sharp, used_weapon)
		if(amount <= 0)
			return STATUS_UPDATE_NONE
	var/old_fireloss = getFireLoss()
	fireloss = max(round(fireloss + amount, DAMAGE_PRECISION), 0)
	if(old_fireloss == getFireLoss())
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustFireLoss")


/// Oxyloss var getter
/mob/living/proc/getOxyLoss()
	return oxyloss


/**
 * Applies oxy damage to this mob.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * forced - "Force" exactly the damage dealt. This means it skips any damage modifiers.
 * * used_weapon - Item that is attacking [src].
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/adjustOxyLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	if(HAS_TRAIT(src, TRAIT_GODMODE) || HAS_TRAIT(src, TRAIT_NO_BREATH))
		var/old_oxyloss = getOxyLoss()
		oxyloss = 0
		if(old_oxyloss != 0)
			updatehealth("adjustOxyLoss")
		return STATUS_UPDATE_NONE
	if(!forced && amount > 0)
		amount *= ((100 - clamp(blocked + get_blocking_resistance(amount, OXY, used_weapon = used_weapon), 0, 100)) / 100)
		amount *= get_incoming_damage_modifier(amount, OXY, used_weapon = used_weapon)
		if(amount <= 0)
			return STATUS_UPDATE_NONE
	var/old_oxyloss = getOxyLoss()
	oxyloss = max(round(oxyloss + amount, DAMAGE_PRECISION), 0)
	if(old_oxyloss == getOxyLoss())
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustOxyLoss")


/**
 * Sets oxyloss varaiable to passed value. Will not apply any resistance modifiers.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/setOxyLoss(amount = 0, updating_health = TRUE)
	if(HAS_TRAIT(src, TRAIT_GODMODE) || HAS_TRAIT(src, TRAIT_NO_BREATH))
		var/old_oxyloss = getOxyLoss()
		oxyloss = 0
		if(old_oxyloss != 0)
			updatehealth("setOxyLoss")
		return STATUS_UPDATE_NONE
	var/old_oxyloss = getOxyLoss()
	oxyloss = max(round(amount, DAMAGE_PRECISION), 0)
	if(old_oxyloss == getOxyLoss())
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("setOxyLoss")


/// Toxloss var getter
/mob/living/proc/getToxLoss()
	return toxloss


/**
 * Applies toxic damage to this mob.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * forced - "Force" exactly the damage dealt. This means it skips any damage modifiers.
 * * used_weapon - Item that is attacking [src].
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/adjustToxLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		var/old_toxloss = getToxLoss()
		toxloss = 0
		if(old_toxloss != 0)
			updatehealth("adjustToxLoss")
		return STATUS_UPDATE_NONE
	if(!forced && amount > 0)
		amount *= ((100 - clamp(blocked + get_blocking_resistance(amount, TOX, used_weapon = used_weapon), 0, 100)) / 100)
		amount *= get_incoming_damage_modifier(amount, TOX, used_weapon = used_weapon)
		if(amount <= 0)
			return STATUS_UPDATE_NONE
	var/old_toxloss = getToxLoss()
	toxloss = max(round(toxloss + amount, DAMAGE_PRECISION), 0)
	if(old_toxloss == getToxLoss())
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustToxLoss")


/**
 * Sets toxloss varaiable to passed value. Will not apply any resistance modifiers.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/setToxLoss(amount, updating_health = TRUE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		var/old_toxloss = getToxLoss()
		toxloss = 0
		if(old_toxloss != 0)
			updatehealth("setToxLoss")
		return STATUS_UPDATE_NONE
	var/old_toxloss = getToxLoss()
	toxloss = max(round(amount, DAMAGE_PRECISION), 0)
	if(old_toxloss == getToxLoss())
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("setToxLoss")


/// Cloneloss var getter
/mob/living/proc/getCloneLoss()
	return cloneloss


/**
 * Applies clone (genetic) damage to this mob.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * forced - "Force" exactly the damage dealt. This means it skips any damage modifiers.
 * * used_weapon - Item that is attacking [src].
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/adjustCloneLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		var/old_cloneloss = getCloneLoss()
		cloneloss = 0
		if(old_cloneloss != 0)
			updatehealth("adjustCloneLoss")
		return STATUS_UPDATE_NONE
	if(!forced && amount > 0)
		amount *= ((100 - clamp(blocked + get_blocking_resistance(amount, CLONE, used_weapon = used_weapon), 0, 100)) / 100)
		amount *= get_incoming_damage_modifier(amount, CLONE, used_weapon = used_weapon)
		if(amount <= 0)
			return STATUS_UPDATE_NONE
	var/old_cloneloss = getCloneLoss()
	cloneloss = max(round(cloneloss + amount, DAMAGE_PRECISION), 0)
	if(old_cloneloss == getCloneLoss())
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustCloneLoss")


/**
 * Sets cloneloss varaiable to passed value. Will not apply any resistance modifiers.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/setCloneLoss(amount, updating_health = TRUE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		var/old_cloneloss = getCloneLoss()
		cloneloss = 0
		if(old_cloneloss != 0)
			updatehealth("setCloneLoss")
		return STATUS_UPDATE_NONE
	var/old_cloneloss = getCloneLoss()
	cloneloss = max(round(amount, DAMAGE_PRECISION), 0)
	if(old_cloneloss == getCloneLoss())
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("setCloneLoss")


/// Brainloss var getter
/mob/living/proc/getBrainLoss()
	return 0


/**
 * Applies damage to internal organ brain (if found).
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * forced - "Force" exactly the damage dealt. This means it skips any damage modifiers.
 * * used_weapon - Item that is attacking [src].
 *
 * Returns STATUS_UPDATE_STAT if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/adjustBrainLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	return STATUS_UPDATE_NONE


/**
 * Sets the damage for the internal organ brain to passed value (if found). Will not apply any resistance modifiers.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 *
 * Returns STATUS_UPDATE_STAT if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/setBrainLoss(amount, updating_health = TRUE)
	return STATUS_UPDATE_NONE


/// Heartloss var getter
/mob/living/proc/getHeartLoss()
	return 0


/**
 * Applies damage to internal organ heart (if found).
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 *
 * Returns STATUS_UPDATE_STAT if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/adjustHeartLoss(amount, updating_health = TRUE)
	return STATUS_UPDATE_NONE


/**
 * Sets the damage for the internal organ heart to passed value (if found).
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 *
 * Returns STATUS_UPDATE_STAT if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/setHeartLoss(amount, updating_health = TRUE)
	return STATUS_UPDATE_NONE


/// Staminaloss var getter
/mob/living/proc/getStaminaLoss()
	return staminaloss


/**
 * Applies stamina damage to this mob.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * forced - "Force" exactly the damage dealt. This means it skips any damage modifiers.
 * * used_weapon - Item that is attacking [src].
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/adjustStaminaLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		var/old_stamloss = getStaminaLoss()
		staminaloss = 0
		if(old_stamloss != 0)
			updatehealth("adjustStaminaLoss")
		return STATUS_UPDATE_NONE
	if(!forced && amount > 0)
		amount *= ((100 - clamp(blocked + get_blocking_resistance(amount, STAMINA, used_weapon = used_weapon), 0, 100)) / 100)
		amount *= get_incoming_damage_modifier(amount, STAMINA, used_weapon = used_weapon)
		if(amount <= 0)
			return STATUS_UPDATE_NONE
	var/old_stamloss = getStaminaLoss()
	staminaloss = clamp(round(staminaloss + amount, DAMAGE_PRECISION), 0, MAX_STAMINA_LOSS)
	if(old_stamloss == getStaminaLoss())
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_STAMINA
	if(amount > 0)
		stam_regen_start_time = world.time + (STAMINA_REGEN_BLOCK_TIME * stam_regen_start_modifier)
	if(updating_health)
		updatehealth("adjustStaminaLoss")


/**
 * Sets staminaloss varaiable to passed value. Will not apply any resistance modifiers.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * updating_health - If TRUE calls update health on success.
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/setStaminaLoss(amount, updating_health = TRUE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		var/old_stamloss = getStaminaLoss()
		staminaloss = 0
		if(old_stamloss != 0)
			updatehealth("setStaminaLoss")
		return STATUS_UPDATE_NONE
	var/old_stamloss = getStaminaLoss()
	staminaloss = clamp(round(amount, DAMAGE_PRECISION), 0, MAX_STAMINA_LOSS)
	if(old_stamloss == getStaminaLoss())
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_STAMINA
	if(amount > 0)
		stam_regen_start_time = world.time + (STAMINA_REGEN_BLOCK_TIME * stam_regen_start_modifier)
	if(updating_health)
		updatehealth("setStaminaLoss")


/// Maxhealth var getter
/mob/living/proc/getMaxHealth()
	return maxHealth


/// Maxhealth var setter
/mob/living/proc/setMaxHealth(newMaxHealth)
	. = maxHealth
	maxHealth = newMaxHealth


/**
 * Heals ONE external organ, organ gets randomly selected from damagable ones.
 *
 * Arguments:
 * * brute - Amount of brute damage to heal.
 * * burn - Amount of burn damage to heal.
 * * updating_health - If TRUE calls update health on success.
 * * internal - If TRUE will mend fractures and stop internal bleedings.
 * * affect_robotic - If TRUE will apply damage to human robotic bodyparts.
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/heal_organ_damage(
	brute = 0,
	burn = 0,
	updating_health = TRUE,
	internal = FALSE,
	affect_robotic = FALSE,
)
	. = STATUS_UPDATE_NONE
	if(brute)
		. |= adjustBruteLoss(-abs(brute), updating_health = FALSE, affect_robotic = affect_robotic)
	if(burn)
		. |= adjustFireLoss(-abs(burn), updating_health = FALSE, affect_robotic = affect_robotic)
	if(. && updating_health)
		updatehealth("heal organ damage")


/**
 * Damages ONE external organ, organ gets randomly selected from damagable ones.
 *
 * Arguments:
 * * brute - Amount of brute damage to apply.
 * * burn - Amount of burn damage to apply.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * forced - "Force" exactly the damage dealt. This means it skips any damage modifiers. Also will not apply fractures or internal bleedings.
 * * updating_health - If TRUE calls update health on success.
 * * used_weapon - Item that is attacking [src].
 * * sharp - Sharpness of the weapon.
 * * silent - If TRUE will not spam red messages in chat.
 * * affect_robotic - If TRUE will apply damage to human robotic bodyparts.
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/take_organ_damage(
	brute = 0,
	burn = 0,
	blocked = 0,
	forced = FALSE,
	updating_health = TRUE,
	used_weapon = null,
	sharp = FALSE,
	silent = FALSE,
	affect_robotic = TRUE,
)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		var/old_bruteloss = getBruteLoss()
		var/old_fireloss = getFireLoss()
		bruteloss = 0
		fireloss = 0
		if(old_bruteloss != 0 || old_fireloss != 0)
			updatehealth("take organ damage")
		return FALSE
	brute = abs(brute)
	burn = abs(burn)
	if(!forced)
		brute *= ((100 - clamp(blocked + get_blocking_resistance(brute, BRUTE, null, sharp, used_weapon), 0, 100)) / 100)
		brute *= get_incoming_damage_modifier(brute, BRUTE, null, sharp, used_weapon)
		burn *= ((100 - clamp(blocked + get_blocking_resistance(burn, BURN, null, sharp, used_weapon), 0, 100)) / 100)
		burn *= get_incoming_damage_modifier(burn, BURN, null, sharp, used_weapon)
	if(brute <= 0 && burn <= 0)
		return STATUS_UPDATE_NONE
	if(brute)
		. |= adjustBruteLoss(brute, FALSE, null, blocked, forced, used_weapon, sharp, silent, affect_robotic)
	if(burn)
		. |= adjustFireLoss(burn, FALSE, null, blocked, forced, used_weapon, sharp, silent, affect_robotic)
	if(. && updating_health)
		updatehealth("take organ damage")


/**
 * Heals ALL external organs, in random order.
 *
 * Arguments:
 * * brute - Amount of brute damage to heal.
 * * burn - Amount of burn damage to heal.
 * * updating_health - If TRUE calls update health on success.
 * * internal - If TRUE will mend fractures and stop internal bleedings.
 * * affect_robotic - If TRUE will apply damage to human robotic bodyparts.
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/heal_overall_damage(
	brute = 0,
	burn = 0,
	updating_health = TRUE,
	internal = FALSE,
	affect_robotic = FALSE,
)
	. = STATUS_UPDATE_NONE
	if(brute)
		. |= adjustBruteLoss(-abs(brute), updating_health = FALSE, affect_robotic = affect_robotic)
	if(burn)
		. |= adjustFireLoss(-abs(burn), updating_health = FALSE, affect_robotic = affect_robotic)
	if(. && updating_health)
		updatehealth("heal overall damage")


/**
 * Damages ALL external organs, in random order.
 *
 * Arguments:
 * * brute - Amount of brute damage to apply.
 * * burn - Amount of burn damage to apply.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * forced - "Force" exactly the damage dealt. This means it skips any damage modifiers. Also will not apply fractures or internal bleedings.
 * * updating_health - If TRUE calls update health on success.
 * * used_weapon - Item that is attacking [src].
 * * sharp - Sharpness of the weapon.
 * * silent - If TRUE will not spam red messages in chat.
 * * affect_robotic - If TRUE will apply damage to human robotic bodyparts.
 *
 * Returns STATUS_UPDATE_HEALTH if any changes were made, STATUS_UPDATE_NONE otherwise
 */
/mob/living/proc/take_overall_damage(
	brute = 0,
	burn = 0,
	blocked = 0,
	forced = FALSE,
	updating_health = TRUE,
	used_weapon = null,
	sharp = FALSE,
	silent = FALSE,
	affect_robotic = TRUE,
)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		var/old_bruteloss = getBruteLoss()
		var/old_fireloss = getFireLoss()
		bruteloss = 0
		fireloss = 0
		if(old_bruteloss != 0 || old_fireloss != 0)
			updatehealth("take overall damage")
		return STATUS_UPDATE_NONE
	brute = abs(brute)
	burn = abs(burn)
	if(!forced)
		brute *= ((100 - clamp(blocked + get_blocking_resistance(brute, BRUTE, null, sharp, used_weapon), 0, 100)) / 100)
		brute *= get_incoming_damage_modifier(brute, BRUTE, null, sharp, used_weapon)
		burn *= ((100 - clamp(blocked + get_blocking_resistance(burn, BURN, null, sharp, used_weapon), 0, 100)) / 100)
		burn *= get_incoming_damage_modifier(burn, BURN, null, sharp, used_weapon)
	if(brute <= 0 && burn <= 0)
		return STATUS_UPDATE_NONE
	if(brute)
		. |= adjustBruteLoss(brute, FALSE, null, blocked, forced, used_weapon, sharp, silent, affect_robotic)
	if(burn)
		. |= adjustFireLoss(burn, FALSE, null, blocked, forced, used_weapon, sharp, silent, affect_robotic)
	if(. && updating_health)
		updatehealth("take overall damage")


/// TRUE if human has damage on organic bodyparts, FALSE otherwise
/mob/living/proc/has_organic_damage()
	return (maxHealth - health)


/// Heal up to amount damage, in a given order
/mob/living/proc/heal_ordered_damage(amount, list/damage_types)
	. = amount //we'll return the amount of damage healed
	for(var/damagetype in damage_types)
		var/amount_to_heal = min(abs(amount), get_damage_amount(damagetype)) //heal only up to the amount of damage we have
		if(amount_to_heal)
			heal_damage_type(amount_to_heal, damagetype, updating_health = FALSE)
			amount -= amount_to_heal //remove what we healed from our current amount
		if(!amount)
			break
	if(. != amount)
		updatehealth()
	. -= amount //if there's leftover healing, remove it from what we return

