#define COMSIG_CARBON_NUTRITION_UPDATE "carbon_nutrition_update"
/datum/component/hunger_effects
	var/datum/hunger_level/current_level

/datum/component/hunger_effects/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_CARBON_NUTRITION_UPDATE, PROC_REF(update_hunger_effects))
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	update_hunger_effects()
	return ..()

/datum/component/hunger_effects/proc/update_hunger_effects()
	var/mob/living/carbon/human/H = parent
	if(!istype(H))
		return

	if(!LAZYLEN(GLOB.hunger_levels))
		InitHungerLevels()

	var/nutrition = H.nutrition
	var/datum/hunger_level/new_level
	var/found = FALSE

	for(var/datum/hunger_level/HL in GLOB.hunger_levels)
		if(nutrition >= HL.min_nutrition)
			new_level = HL
			found = TRUE
		else
			break

	if(!found)
		new_level = null

	if(new_level == current_level)
		return

	current_level = new_level
	H.remove_movespeed_modifier(/datum/movespeed_modifier/hunger)
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod)

	if(!isnull(current_level?.move_mod))
		H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hunger, multiplicative_slowdown = current_level.move_mod)

	var/base_toolspeedmod = H.dna.species.toolspeedmod
	H.toolspeedmod = base_toolspeedmod + (current_level?.tool_mod || 0)

	if(H.toolspeedmod != base_toolspeedmod)
		H.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod, multiplicative_slowdown = H.toolspeedmod)
	else
		H.remove_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod)

	H.sound_environment_override = current_level?.sound_env || SOUND_ENVIRONMENT_NONE

	if(!isnull(current_level?.stamina_max))
		H.setStaminaMax(current_level.stamina_max)

/datum/component/hunger_effects/proc/on_life()
	var/mob/living/carbon/human/H = parent
	if(!istype(H) || !current_level)
		return

	if(current_level.regen_stamina && H.getStaminaLoss() > 0)
		H.adjustStaminaLoss(-0.5, TRUE)

	if(current_level.regen_blood)
		H.blood_volume = min(H.blood_volume + 0.2, BLOOD_VOLUME_NORMAL)
