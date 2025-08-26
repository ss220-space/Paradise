/datum/element/nutrition_effects
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY


/datum/element/nutrition_effects/Attach(datum/target)
	. = ..()

	if(!ishuman(target) || HAS_TRAIT(target, TRAIT_NO_HUNGER) || HAS_TRAIT(target, TRAIT_NO_NUTRITION_EFFECTS))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(target, COMSIG_HUMAN_NUTRITION_UPDATE, PROC_REF(on_nutrition_level_update))
	RegisterSignal(target, COMSIG_HUMAN_NUTRITION_UPDATE_SLOWDOWN, PROC_REF(nutrition_update_slowdown))
	RegisterSignal(target, COMSIG_HUMAN_SPECIES_CHANGED, PROC_REF(on_species_changed))


/datum/element/nutrition_effects/Detach(datum/source)
	. = ..()

	UnregisterSignal(source, list(
		COMSIG_LIVING_LIFE,
		COMSIG_HUMAN_NUTRITION_UPDATE,
		COMSIG_HUMAN_NUTRITION_UPDATE_SLOWDOWN,
		COMSIG_HUMAN_SPECIES_CHANGED,
	))


/// Regenerates [blood_regen] and [stamina_regen] per tick based on nutrition level, currently works only for level "full"
/datum/element/nutrition_effects/proc/on_life(mob/living/carbon/human/human, deltatime, times_fired)
	SIGNAL_HANDLER

	if(isnull(human) || QDELETED(human))
		return

	if(!istype(human.current_nutrition_level, /datum/nutrition_level/full))
		return

	if(human.getStaminaLoss() > 0)
		human.adjustStaminaLoss(human.current_nutrition_level.stamina_regen)

	if(human.blood_volume < BLOOD_VOLUME_NORMAL)
		human.AdjustBlood(human.current_nutrition_level.blood_regen)


/// Applies nutrition level effects (including speed mods) to the human
/datum/element/nutrition_effects/proc/on_nutrition_level_update(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(isnull(human) || QDELETED(human))
		return

	// safety check for when we changed species but somehow didn't get rid of the element yet
	if(HAS_TRAIT(human, TRAIT_NO_HUNGER) || HAS_TRAIT(human, TRAIT_NO_NUTRITION_EFFECTS))
		return

	human.set_max_stamina(BASE_MAX_STAMINA + human.current_nutrition_level.max_stamina_bonus)
	human.sound_environment_override = human.current_nutrition_level.sound_env
	nutrition_update_slowdown(human)


/// Updates movespeed and toolspeed modifiers based on current nutrition level,
/// these who have TRAIT_NO_NUTRITION_EFFECTS dont use this
/datum/element/nutrition_effects/proc/nutrition_update_slowdown(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(isnull(human) || QDELETED(human))
		return

	human.add_or_update_variable_actionspeed_modifier(
			/datum/actionspeed_modifier/species_tool_mod,
			multiplicative_slowdown = human.dna?.species?.toolspeedmod + human.current_nutrition_level.tool_speed_mod
		)
	human.add_or_update_variable_actionspeed_modifier(
			/datum/actionspeed_modifier/species_surgery_mod,
			multiplicative_slowdown = human.dna?.species?.surgeryspeedmod + human.current_nutrition_level.tool_speed_mod
		)
	human.add_or_update_variable_movespeed_modifier(
			/datum/movespeed_modifier/hunger,
			multiplicative_slowdown = human.current_nutrition_level.move_speed_mod
		)


/// Handles situations like human transforming into shadowling or diona or whatever the species that shouldn't use nutrition effects
/datum/element/nutrition_effects/proc/on_species_changed(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(isnull(human) || QDELETED(human))
		return

	// if the element allowed for new species, they should keep it if already have one, if not - they will get it in set_species()
	if(!HAS_TRAIT(human, TRAIT_NO_HUNGER) && !HAS_TRAIT(human, TRAIT_NO_NUTRITION_EFFECTS))
		on_nutrition_level_update(human)
		return COMPONENT_HAS_ELEMENT

	// we don't change level for TRAIT_NO_HUNGER because it's already handled on trait added
	if(HAS_TRAIT(human, TRAIT_NO_NUTRITION_EFFECTS))
		human.current_nutrition_level = initial(human.current_nutrition_level)

	human.set_max_stamina(initial(human.max_stamina))
	human.sound_environment_override = initial(human.sound_environment_override)
	// resets all speed mods, because initial nutrition level for all species has no bonuses/penalties
	nutrition_update_slowdown(human)
	human.RemoveElement(/datum/element/nutrition_effects)

