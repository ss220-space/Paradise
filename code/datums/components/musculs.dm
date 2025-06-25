/datum/component/musculs
	/// Max level of strength for this musculs owner.
	var/max_species_strength = STRENGTH_LEVEL_IDEAL
	/// Default level of strength for this race.
	var/default_strength = STRENGTH_LEVEL_NORMAL
	/// How stronger or weaker females are for this race.
	var/strength_female_delta = 0
	/// If FALSE, strength of body can't be changed.
	var/can_become_stronger = TRUE
	/// Strength level. Changes some parameters, such as melee damage. 2 - the same as old.
	var/strength = -1 // Changes in on_species_gain()
	/// Points of strength that this body already has. They are used to change the strength level.
	var/strength_points = 0


/datum/component/musculs/Initialize(max_species_strength, default_strength, strength_female_delta = 0, can_become_stronger = TRUE)
	..()

	if(max_species_strength)
		src.max_species_strength = max_species_strength

	if(default_strength)
		src.default_strength = default_strength

	src.strength_female_delta = strength_female_delta
	src.can_become_stronger = can_become_stronger


#define REQ_STAMINA_FOR_STRENGTH_POINT		25
#define REQ_NUTRITION_FOR_STRENGTH_POINT 	25
#define MIN_NUTRITION_FOR_STRENGTH_CHANGE	NUTRITION_LEVEL_STARVING

/datum/component/musculs/proc/try_add_strength_points(mob/living/user, delta)
	if(user.nutrition < MIN_NUTRITION_FOR_STRENGTH_CHANGE)
		to_chat(user, span_warning("Вы слишком голодны!"))
		return FALSE

	if(user.getStaminaLoss() + delta * REQ_STAMINA_FOR_STRENGTH_POINT > MAX_STAMINA_LOSS)
		to_chat(user, span_warning("Вы слишком устали!"))
		return FALSE

	if(!can_become_stronger)
		return TRUE

	user.adjustStaminaLoss(delta * REQ_STAMINA_FOR_STRENGTH_POINT)
	user.adjust_nutrition(-delta * REQ_NUTRITION_FOR_STRENGTH_POINT)

	var/has_steroids = user.reagents.has_reagent(/datum/reagent/steroids::id)
	var/has_protein = user.reagents.has_reagent(/datum/reagent/consumable/nutriment/protein::id)
	if(has_steroids)
		delta *= 2
	else if(has_protein)
		delta *= 1.3

	strength_points += delta
	try_upgrade_strength(user)
	if(strength >= get_max_strength_level())
		strength_points = 0

	return TRUE


/datum/component/musculs/proc/try_upgrade_strength(mob/living/carbon/human/user)
	if(strength >= get_max_strength_level())
		return

	if(strength_points < GLOB.strength_req_to_upgrade[strength])
		return

	strength_points -= GLOB.strength_req_to_upgrade[strength]
	strength++
	user.update_body(TRUE)


/datum/component/musculs/proc/get_max_strength_level()
	if(HAS_TRAIT(src, TRAIT_GENE_STRONG))
		return STRENGTH_LEVEL_SUPERHUMAN

	if(HAS_TRAIT(src, TRAIT_GENE_WEAK))
		return STRENGTH_LEVEL_WEAK

	return max_species_strength


/datum/component/musculs/proc/get_strength()
	var/result = strength
	if(HAS_TRAIT(src, TRAIT_GENE_STRONG))
		result = max(result, 4)

	if(HAS_TRAIT(src, TRAIT_GENE_WEAK))
		result = min(result, 1)

	return result


/datum/component/musculs/proc/get_strength_level_part()
	var/level = get_strength()
	if(level == STRENGTH_LEVEL_SUPERHUMAN)
		return 0

	return strength_points / GLOB.strength_req_to_upgrade[level]


/datum/component/musculs/proc/get_strength_grab_speed_modifier()
	var/strength_level_part = get_strength_level_part()
	var/level = get_strength()
	if(strength_level_part == 0)
		return GLOB.strength_grab_speed_modifiers[level]

	return GLOB.strength_grab_speed_modifiers[level] + \
		(GLOB.strength_grab_speed_modifiers[level + 1] - GLOB.strength_grab_speed_modifiers[level]) * strength_level_part


/datum/component/musculs/proc/get_strength_pull_slowdown_modifier()
	var/strength_level_part = get_strength_level_part()
	var/level = get_strength()
	if(strength_level_part == 0)
		return GLOB.strength_pull_slowdown_modifiers[level]

	return GLOB.strength_pull_slowdown_modifiers[level] + \
		(GLOB.strength_pull_slowdown_modifiers[level + 1] - GLOB.strength_pull_slowdown_modifiers[level]) * strength_level_part


/datum/component/musculs/proc/get_strength_melee_damage_delta()
	var/strength_level_part = get_strength_level_part()
	var/level = get_strength()
	if(strength_level_part == 0)
		return GLOB.strength_melee_damage_deltas[level]

	return GLOB.strength_melee_damage_deltas[level] + \
		(GLOB.strength_melee_damage_deltas[level + 1] - GLOB.strength_melee_damage_deltas[level]) * strength_level_part


#undef REQ_STAMINA_FOR_STRENGTH_POINT
#undef REQ_NUTRITION_FOR_STRENGTH_POINT
#undef MIN_NUTRITION_FOR_STRENGTH_CHANGE
