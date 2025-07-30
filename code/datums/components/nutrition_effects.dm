/datum/component/nutrition_effects
	var/datum/nutrition_level/nutrition_level


/datum/component/nutrition_effects/Initialize()
	..()

	if(!ishuman(parent) || HAS_TRAIT(parent, TRAIT_NO_HUNGER))
		return COMPONENT_INCOMPATIBLE


/datum/component/nutrition_effects/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(parent, COMSIG_HUMAN_NUTRITION_UPDATE, PROC_REF(on_nutrition_update))


/datum/component/nutrition_effects/UnregisterWithParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_LIFE, COMSIG_HUMAN_NUTRITION_UPDATE))


/datum/component/nutrition_effects/proc/on_life()
	SIGNAL_HANDLER
	if(!istype(nutrition_level, /datum/nutrition_level/full))
		return

	parent.adjustStaminaLoss(stamina_regen)
	parent.AdjustBlood(blood_regen)


/datum/component/nutrition_effects/proc/on_nutrition_update(/mob/living/carbon/human/human, nutrition)
	SIGNAL_HANDLER
	// If nutrition level hasn't changed, we do nothing
	if(nutrition_level && \
		nutrition > nutrition_level.decrease_level_threshold && \
		nutrition <= nutrition_level.increase_level_threshold)
		return

	switch(nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			nutrition_level = /datum/nutrition_level/fat
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			nutrition_level = /datum/nutrition_level/full
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			nutrition_level = /datum/nutrition_level/well_fed
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			nutrition_level = /datum/nutrition_level/fed
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			nutrition_level = /datum/nutrition_level/hungry
		if(NUTRITION_LEVEL_HYPOGLYCEMIA to NUTRITION_LEVEL_STARVING)
			nutrition_level = /datum/nutrition_level/starving
		if(1 to NUTRITION_LEVEL_HYPOGLYCEMIA)
			nutrition_level = /datum/nutrition_level/hypoglicemia

	human.update_nutrition_effects(nutrition_level)
