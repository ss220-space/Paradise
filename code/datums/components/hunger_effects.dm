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
	var/current_nutrition = target.nutrition
	var/datum/hunger_level/new_level = find_hunger_level(current_nutrition)
	current_level = new_level
	apply_hunger_effects(target)

/datum/component/hunger_effects/proc/find_hunger_level(nutrition)
	var/list/valid_levels = list()
	for(var/level_type in GLOB.hunger_levels)
		var/datum/hunger_level/level = GLOB.hunger_levels[level_type]
		valid_levels += level
	sortTim(valid_levels, /proc/hunger_levels_update)
	for(var/datum/hunger_level/level in valid_levels)
		if(nutrition >= level.min_nutrition)
			return level
	return GLOB.hunger_levels[/datum/hunger_level/starving]

/proc/hunger_levels_update(datum/hunger_level/A, datum/hunger_level/B)
	return B.min_nutrition - A.min_nutrition

/datum/component/hunger_effects/proc/apply_hunger_effects(mob/living/carbon/human/target)
	target.remove_movespeed_modifier(/datum/movespeed_modifier/hunger)
	target.remove_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod)
	if(!isnull(current_level?.move_mod) && current_level.move_mod != 0)
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
		target.set_stamina_max(current_level.stamina_max)

/datum/component/hunger_effects/proc/on_life()
	var/mob/living/carbon/human/target = parent
	if(!istype(target) || !current_level)
		return
	if(current_level.regen_stamina && target.getStaminaLoss() > 0)
		target.adjustStaminaLoss(-0.5, TRUE)
	if(current_level.regen_blood)
		target.blood_volume = min(target.blood_volume + 0.2, BLOOD_VOLUME_NORMAL)
