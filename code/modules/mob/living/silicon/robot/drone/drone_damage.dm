//Redefining some robot procs, since drones can't be repaired and really shouldn't take component damage.
/mob/living/silicon/robot/drone/take_overall_damage(
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
		return ..()

	. = STATUS_UPDATE_NONE

	brute = abs(brute)
	burn = abs(burn)
	if(!forced)
		brute *= ((100 - clamp(blocked + get_blocking_resistance(brute, BRUTE, null, sharp, used_weapon), 0, 100)) / 100)
		brute *= get_incoming_damage_modifier(brute, BRUTE, null, sharp, used_weapon)
		burn *= ((100 - clamp(blocked + get_blocking_resistance(burn, BURN, null, sharp, used_weapon), 0, 100)) / 100)
		burn *= get_incoming_damage_modifier(burn, BURN, null, sharp, used_weapon)
	if(brute <= 0 && burn <= 0)
		return .

	var/old_bruteloss = bruteloss
	var/old_fireloss = fireloss
	bruteloss = round(bruteloss + brute, DAMAGE_PRECISION)
	fireloss = round(fireloss + burn, DAMAGE_PRECISION)

	if(old_bruteloss != bruteloss || old_fireloss != fireloss)
		if(updating_health)
			updatehealth("take overall damage")
		return STATUS_UPDATE_HEALTH


/mob/living/silicon/robot/drone/heal_overall_damage(
	brute = 0,
	burn = 0,
	updating_health = TRUE,
	internal = FALSE,
	affect_robotic = FALSE,
)
	. = STATUS_UPDATE_HEALTH

	brute = abs(brute)
	burn = abs(burn)

	var/old_bruteloss = bruteloss
	var/old_fireloss = fireloss
	bruteloss = round(max(bruteloss - brute, 0), DAMAGE_PRECISION)
	fireloss = round(max(fireloss - burn, 0), DAMAGE_PRECISION)

	if(old_bruteloss != bruteloss || old_fireloss != fireloss)
		if(updating_health)
			updatehealth("heal overall damage")
		return STATUS_UPDATE_HEALTH


/mob/living/silicon/robot/drone/take_organ_damage/take_organ_damage(
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
	return take_overall_damage(brute, burn, blocked, forced, updating_health, used_weapon, sharp, silent, affect_robotic)


/mob/living/silicon/robot/drone/heal_organ_damage(
	brute = 0,
	burn = 0,
	updating_health = TRUE,
	internal = FALSE,
	affect_robotic = FALSE,
)
	return heal_overall_damage(brute, burn, updating_health, affect_robotic = affect_robotic)


/mob/living/silicon/robot/drone/getFireLoss()
	return fireloss


/mob/living/silicon/robot/drone/getBruteLoss()
	return bruteloss

