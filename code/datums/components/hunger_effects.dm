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
	var/mob/living/carbon/human/target = parent
	if(!istype(target))
		return
	if(!length(GLOB.hunger_levels))
		var/list/levels = list()
		for(var/htype in subtypesof(/datum/hunger_level))
			levels += new htype
		GLOB.hunger_levels = sortTim(levels, /proc/hunger_levels_update)
	var/current_nutrition = target.nutrition
	var/datum/hunger_level/selected_level
	for(var/datum/hunger_level/level as anything in GLOB.hunger_levels)
		if(current_nutrition >= level.min_nutrition)
			selected_level = level
		else
			break
	if(selected_level == current_level)
		return
	current_level = selected_level
	target.remove_movespeed_modifier(/datum/movespeed_modifier/hunger)
	target.remove_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod)
	if(!isnull(current_level?.move_mod))
		target.add_or_update_variable_movespeed_modifier(
			/datum/movespeed_modifier/hunger,
			multiplicative_slowdown = current_level.move_mod
		)
	var/base_toolspeed = target.dna.species.toolspeedmod
	var/new_toolspeed = base_toolspeed + (current_level?.tool_mod || 0)
	if(new_toolspeed != base_toolspeed)
		target.add_or_update_variable_actionspeed_modifier(
			/datum/actionspeed_modifier/species_tool_mod,
			multiplicative_slowdown = new_toolspeed
		)
	else
		target.remove_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod)
	target.sound_environment_override = current_level?.sound_env || SOUND_ENVIRONMENT_NONE
	if(!isnull(current_level?.stamina_max))
		target.setStaminaMax(current_level.stamina_max)

/datum/component/hunger_effects/proc/on_life()
	var/mob/living/carbon/human/target = parent
	if(!istype(target) || !current_level)
		return
	if(current_level.regen_stamina && target.getStaminaLoss() > 0)
		target.adjustStaminaLoss(-0.5, TRUE)
	if(current_level.regen_blood)
		target.blood_volume = min(target.blood_volume + 0.2, BLOOD_VOLUME_NORMAL)
