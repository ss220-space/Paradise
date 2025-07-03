/datum/component/muscles
	/// Max level of strength for this muscles owner.
	var/max_species_strength = STRENGTH_LEVEL_IDEAL
	/// If FALSE, strength of body can't be changed.
	var/can_become_stronger = TRUE
	/// Strength level. Changes some parameters, such as melee damage. 2 - the same as old.
	var/strength = -1 // Changes in on_species_gain()
	/// Points of strength that this body already has. They are used to change the strength level.
	var/strength_points = 0


/datum/component/muscles/Initialize(max_species_strength = STRENGTH_LEVEL_MAXDEFAULT, default_strength = STRENGTH_LEVEL_DEFAULT, can_become_stronger = TRUE)
	..()
	var/datum/physiology/physiology = parent
	if(!ishuman(physiology.owner))
		return COMPONENT_INCOMPATIBLE

	src.max_species_strength = max_species_strength
	strength = default_strength
	src.can_become_stronger = can_become_stronger


/datum/component/muscles/RegisterWithParent()
	var/datum/physiology/physiology = parent
	var/mob/living/owner = physiology.owner
	RegisterSignal(owner, COMSIG_GET_GRAB_SPEED_MODIFIERS, PROC_REF(get_strength_grab_speed_modifier))
	RegisterSignal(owner, COMSIG_GET_PULL_SLOWDOWN_MODIFIERS, PROC_REF(get_strength_pull_slowdown_modifier))
	RegisterSignal(owner, COMSIG_GET_MELEE_DAMAGE_DELTAS, PROC_REF(get_strength_melee_damage_delta))
	RegisterSignal(owner, COMSIG_MOB_EXERCISED, PROC_REF(try_add_strength_points))
	RegisterSignal(owner, COMSIG_GET_ICON_RENDER_KEY_INFO, PROC_REF(get_icon_render_key_info))
	RegisterSignal(owner, COMSIG_GET_ORGAN_ICON_STATE, PROC_REF(get_organ_icon_state))
	RegisterSignal(owner, COMSIG_STRENGTH_BORDER_UPDATE, PROC_REF(on_strength_border_update))


/datum/component/muscles/UnregisterFromParent()
	var/datum/physiology/physiology = parent
	var/mob/living/owner = physiology.owner
	UnregisterSignal(owner, list(
		COMSIG_GET_GRAB_SPEED_MODIFIERS,
		COMSIG_GET_PULL_SLOWDOWN_MODIFIERS,
		COMSIG_GET_MELEE_DAMAGE_DELTAS,
		COMSIG_MOB_EXERCISED,
		COMSIG_GET_ICON_RENDER_KEY_INFO,
		COMSIG_GET_ORGAN_ICON_STATE,
		COMSIG_STRENGTH_BORDER_UPDATE
	))


/datum/component/muscles/proc/on_strength_border_update(user)
	SIGNAL_HANDLER
	strength = min(strength, get_max_strength_level())


#define REQ_STAMINA_FOR_STRENGTH_POINT		25
#define REQ_NUTRITION_FOR_STRENGTH_POINT 	25
#define MIN_NUTRITION_FOR_STRENGTH_CHANGE	NUTRITION_LEVEL_STARVING

/datum/component/muscles/proc/try_add_strength_points(mob/living/user, delta)
	SIGNAL_HANDLER
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


/datum/component/muscles/proc/try_upgrade_strength(mob/living/carbon/human/user)
	if(strength >= get_max_strength_level())
		return

	if(strength_points < GLOB.strength_req_to_upgrade[strength])
		return

	strength_points -= GLOB.strength_req_to_upgrade[strength]
	strength++
	user.update_body(TRUE)


/datum/component/muscles/proc/get_max_strength_level()
	if(HAS_TRAIT(parent, TRAIT_STRONG_MUSCLES))
		return STRENGTH_LEVEL_SUPERHUMAN

	if(HAS_TRAIT(parent, TRAIT_WEAK_MUSCULS))
		return STRENGTH_LEVEL_WEAK

	return max_species_strength


/datum/component/muscles/proc/get_icon_render_key_info(mob/living/user, list/info)
	SIGNAL_HANDLER
	info.Add(get_strength(user))


/datum/component/muscles/proc/get_organ_icon_state(mob/living/carbon/human/user, obj/item/organ/external/organ, list/icon_state_additions)
	SIGNAL_HANDLER
	if(!istype(user.dna.species, /datum/species/human) || !ischest(organ) && !isgroin(organ))
		return

	icon_state_additions.Add("_[min(4, get_strength(user))]")


/datum/component/muscles/proc/get_strength()
	if(HAS_TRAIT(parent, TRAIT_STRONG_MUSCLES))
		strength = max(strength, STRENGTH_LEVEL_MAXDEFAULT)

	if(HAS_TRAIT(parent, TRAIT_WEAK_MUSCULS))
		strength = min(strength, STRENGTH_LEVEL_WEAK)

	return strength


/datum/component/muscles/proc/get_strength_level_part(mob/living/user)
	var/level = get_strength(user)
	if(level == STRENGTH_LEVEL_SUPERHUMAN)
		return 0

	return strength_points / GLOB.strength_req_to_upgrade[level]


/datum/component/muscles/proc/get_strength_grab_speed_modifier(mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	var/strength_level_part = get_strength_level_part(user)
	var/level = get_strength(user)
	if(strength_level_part == 0)
		modifiers.Add(GLOB.strength_grab_speed_modifiers[level])
		return

	modifiers.Add(GLOB.strength_grab_speed_modifiers[level] + \
		(GLOB.strength_grab_speed_modifiers[level + 1] - GLOB.strength_grab_speed_modifiers[level]) * strength_level_part)


/datum/component/muscles/proc/get_strength_pull_slowdown_modifier(mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	var/strength_level_part = get_strength_level_part(user)
	var/level = get_strength(user)
	if(strength_level_part == 0)
		modifiers.Add(GLOB.strength_pull_slowdown_modifiers[level])
		return

	modifiers.Add(GLOB.strength_pull_slowdown_modifiers[level] + \
		(GLOB.strength_pull_slowdown_modifiers[level + 1] - GLOB.strength_pull_slowdown_modifiers[level]) * strength_level_part)


/datum/component/muscles/proc/get_strength_melee_damage_delta(mob/living/user, list/deltas, obj/item/weapon)
	SIGNAL_HANDLER

	if(weapon && weapon.damtype != BRUTE)
		return

	var/strength_level_part = get_strength_level_part(user)
	var/level = get_strength(user)
	if(strength_level_part == 0)
		deltas.Add(GLOB.strength_melee_damage_deltas[level])
		return

	deltas.Add(GLOB.strength_melee_damage_deltas[level] + \
		(GLOB.strength_melee_damage_deltas[level + 1] - GLOB.strength_melee_damage_deltas[level]) * strength_level_part)


#undef REQ_STAMINA_FOR_STRENGTH_POINT
#undef REQ_NUTRITION_FOR_STRENGTH_POINT
#undef MIN_NUTRITION_FOR_STRENGTH_CHANGE
