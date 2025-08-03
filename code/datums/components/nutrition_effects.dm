/datum/component/nutrition_effects

/datum/component/nutrition_effects/Initialize()
	. = ..()

	if(!ishuman(parent) || HAS_TRAIT(parent, TRAIT_NO_HUNGER) || HAS_TRAIT(parent, TRAIT_NO_NUTRITION_EFFECTS))
		return COMPONENT_INCOMPATIBLE


/datum/component/nutrition_effects/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(parent, COMSIG_HUMAN_NUTRITION_UPDATE, PROC_REF(on_nutrition_level_update))
	RegisterSignal(parent, COMSIG_HUMAN_NUTRITION_UPDATE_SLOWDOWN, PROC_REF(nutrition_update_slowdown))
	RegisterSignal(parent, COMSIG_HUMAN_SPECIES_CHANGED, PROC_REF(on_species_changed))


/datum/component/nutrition_effects/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_LIVING_LIFE,
		COMSIG_HUMAN_NUTRITION_UPDATE,
		COMSIG_HUMAN_NUTRITION_UPDATE_SLOWDOWN,
		COMSIG_HUMAN_SPECIES_CHANGED,
	))


/// Regenerates [blood_regen] and [stamina_regen] per tick based on nutrition level, currently works only for level "full"
/datum/component/nutrition_effects/proc/on_life(mob/living/carbon/human/human, deltatime, times_fired)
	SIGNAL_HANDLER

	if(isnull(human) || QDELETED(human))
		return

	if(human.current_nutrition_level != /datum/nutrition_level/full)
		return

	human.adjustStaminaLoss(human.current_nutrition_level.stamina_regen)
	human.AdjustBlood(human.current_nutrition_level.blood_regen)


/// Applies nutrition level effects (including speed mods) to the human
/datum/component/nutrition_effects/proc/on_nutrition_level_update(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(isnull(human) || QDELETED(human))
		return

	// safety check for when we changed species but somehow didn't get rid of the component yet
	if(HAS_TRAIT(human, TRAIT_NO_HUNGER) || HAS_TRAIT(human, TRAIT_NO_NUTRITION_EFFECTS))
		return

	human.set_max_stamina(BASE_MAX_STAMINA + human.current_nutrition_level.max_stamina_bonus)
	human.sound_environment_override = human.current_nutrition_level.sound_env
	nutrition_update_slowdown(human)


/// Updates movespeed and toolspeed modifiers based on current nutrition level,
/// these who have TRAIT_NO_NUTRITION_EFFECTS dont use this
/datum/component/nutrition_effects/proc/nutrition_update_slowdown(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(isnull(human) || QDELETED(human))
		return

	human.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod, multiplicative_slowdown = human.dna?.species?.toolspeedmod + human.current_nutrition_level.tool_speed_mod)
	human.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_surgery_mod, multiplicative_slowdown = human.dna?.species?.surgeryspeedmod + human.current_nutrition_level.tool_speed_mod)
	human.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hunger, multiplicative_slowdown = human.current_nutrition_level.move_speed_mod)


/// Handles situations like human transforming into shadowling or diona or whatever the species that shouldn't use nutrition effects
/datum/component/nutrition_effects/proc/on_species_changed(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(isnull(human) || QDELETED(human))
		return

	// if the component allowed for new species, they should keep it if already have one, if not - they will get it in set_species()
	if(!HAS_TRAIT(human, TRAIT_NO_HUNGER) && !HAS_TRAIT(human, TRAIT_NO_NUTRITION_EFFECTS))
		on_nutrition_level_update()
		return

	// we don't change level for TRAIT_NO_HUNGER because it's already handled on trait added
	if(HAS_TRAIT(human, TRAIT_NO_NUTRITION_EFFECTS))
		human.current_nutrition_level = initial(human.current_nutrition_level)

	human.max_stamina = initial(human.max_stamina)
	human.sound_environment_override = initial(human.sound_environment_override)
	// resets all speed mods, because initial nutrition level for all species has no bonuses/penalties
	nutrition_update_slowdown(human)
	Destroy()

