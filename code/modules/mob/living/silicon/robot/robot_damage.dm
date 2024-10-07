/mob/living/silicon/robot/updatehealth(reason = "none given", should_log = FALSE)
	..()
	check_module_damage()

/mob/living/silicon/robot/getBruteLoss(repairable_only = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return 0
	var/amount = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed != 0 && (!repairable_only || C.installed != -1)) // Installed ones only and if repair only remove the borked ones
			amount += C.brute_damage
	return amount

/mob/living/silicon/robot/getFireLoss(repairable_only = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return 0
	var/amount = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed != 0 && (!repairable_only || C.installed != -1)) // Installed ones only and if repair only remove the borked ones
			amount += C.electronics_damage
	return amount


/mob/living/silicon/robot/adjustBruteLoss(
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
	if(amount > 0)
		take_overall_damage(amount, 0, blocked, forced, updating_health, used_weapon, sharp, silent, affect_robotic)
	else
		heal_overall_damage(amount, 0, updating_health, FALSE, affect_robotic)
	return STATUS_UPDATE_HEALTH


/mob/living/silicon/robot/adjustFireLoss(
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
	if(amount > 0)
		take_overall_damage(0, amount, blocked, forced, updating_health, used_weapon, sharp, silent, affect_robotic)
	else
		heal_overall_damage(0, amount, updating_health, FALSE, affect_robotic)
	return STATUS_UPDATE_HEALTH


/mob/living/silicon/robot/proc/get_damaged_components(get_brute, get_burn, get_borked = FALSE, get_missing = FALSE)
	var/list/datum/robot_component/parts = list()
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if((C.installed == 1 || (get_borked && C.installed == -1) || (get_missing && C.installed == 0)) && ((get_brute && C.brute_damage) || (get_burn && C.electronics_damage)))
			parts += C
	return parts

/mob/living/silicon/robot/proc/get_missing_components()
	var/list/datum/robot_component/parts = list()
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed == 0)
			parts += C
	return parts

/mob/living/silicon/robot/proc/get_damageable_components()
	var/list/rval = new
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed == 1)
			rval += C
	return rval

/mob/living/silicon/robot/proc/get_armour()
	if(!LAZYLEN(components))
		return 0
	var/datum/robot_component/C = components["armour"]
	if(C && C.installed == 1)
		return C
	return 0


/mob/living/silicon/robot/heal_organ_damage(
	brute = 0,
	burn = 0,
	updating_health = TRUE,
	internal = FALSE,
	affect_robotic = FALSE,
)
	. = STATUS_UPDATE_NONE
	var/list/datum/robot_component/parts = get_damaged_components(brute, burn)
	if(!LAZYLEN(parts))
		return .
	var/datum/robot_component/picked = pick(parts)
	. |= picked.heal_damage(brute, burn, updating_health)


/mob/living/silicon/robot/take_organ_damage(
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

	var/list/components = get_damageable_components()
	if(!LAZYLEN(components))
		return STATUS_UPDATE_NONE

	. = STATUS_UPDATE_HEALTH

	var/datum/robot_component/armour/armour = get_armour()
	if(armour)
		return armour.take_damage(brute, burn, sharp, updating_health)

	var/datum/robot_component/component = pick(components)
	component.take_damage(brute, burn, sharp, updating_health)


/mob/living/silicon/robot/heal_overall_damage(
	brute = 0,
	burn = 0,
	updating_health = TRUE,
	internal = FALSE,
	affect_robotic = FALSE,
)
	brute = abs(brute)
	burn = abs(burn)

	. = STATUS_UPDATE_NONE

	var/list/datum/robot_component/parts = get_damaged_components(brute, burn)
	if(!length(parts))
		return .

	while(parts.len && (brute > 0 || burn > 0) )
		var/datum/robot_component/picked = pick(parts)
		var/brute_per_part = round(brute/parts.len, DAMAGE_PRECISION)
		var/burn_per_part = round(burn/parts.len, DAMAGE_PRECISION)

		. |= picked.heal_damage(brute, burn, updating_health = FALSE)

		brute = max(brute - brute_per_part, 0)
		burn = max(burn - burn_per_part, 0)

		parts -= picked

	if(. && updating_health)
		updatehealth("heal overall damage")


/mob/living/silicon/robot/take_overall_damage(
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

	var/list/datum/robot_component/parts = get_damageable_components()
	if(!length(parts))
		return .

	var/datum/robot_component/armour/armour = get_armour()
	if(armour)
		return armour.take_damage(brute, burn, sharp, updating_health)

	while(parts.len && (brute > 0 || burn > 0) )
		var/datum/robot_component/picked = pick(parts)
		var/brute_per_part = round(brute/parts.len, DAMAGE_PRECISION)
		var/burn_per_part = round(burn/parts.len, DAMAGE_PRECISION)

		. |= picked.take_damage(brute_per_part, burn_per_part, sharp, updating_health = FALSE)

		brute = max(brute - brute_per_part, 0)
		burn = max(burn - burn_per_part, 0)

		parts -= picked

	if(. && updating_health)
		updatehealth("take overall damage")


/mob/living/silicon/robot/get_blocking_resistance(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	sharp = FALSE,
	used_weapon = null,
)
	. = ..()
	. += damage_protection


/mob/living/silicon/robot/get_incoming_damage_modifier(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	sharp = FALSE,
	used_weapon = null,
)
	. = ..()

	switch(damagetype)
		if(BRUTE)
			. *= brute_mod
		if(BURN)
			. *= burn_mod

