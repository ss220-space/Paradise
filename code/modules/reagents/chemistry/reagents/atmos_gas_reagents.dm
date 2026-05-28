/datum/reagent/freon
	name = "Freon"
	id = "freon"
	description = "A powerful heat absorbent."
	metabolization_rate = 0.5 * REAGENTS_METABOLISM  // Because nitrium/freon/hypernoblium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "90560B"
	taste_description = "burning"
	can_synth = FALSE

/datum/reagent/freon/on_mob_metabolize(mob/living/breather)
	breather.add_movespeed_modifier(/datum/movespeed_modifier/reagent/freon)
	return ..()

/datum/reagent/freon/on_mob_end_metabolize(mob/living/breather)
	breather.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/freon)
	return ..()

/datum/reagent/halon
	name = "Halon"
	id = "halon"
	description = "A fire suppression gas that removes oxygen and cools down the area"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	color = "90560B"
	taste_description = "minty"
	metabolized_traits = list(TRAIT_RESIST_HEAT)
	can_synth = FALSE

/datum/reagent/halon/on_mob_metabolize(mob/living/breather)
	breather.add_movespeed_modifier(/datum/movespeed_modifier/reagent/halon)
	return ..()

/datum/reagent/halon/on_mob_end_metabolize(mob/living/breather)
	breather.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/halon)
	return ..()

/datum/reagent/healium
	name = "Healium"
	id = "healium"
	description = "A powerful sleeping agent with healing properties"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	color = "90560B"
	taste_description = "rubbery"
	can_synth = FALSE

/datum/reagent/healium/on_mob_end_metabolize(mob/living/breather)
	breather.SetSleeping(1 SECONDS)
	return ..()

/datum/reagent/healium/on_mob_life(mob/living/breather)
	breather.SetSleeping(30 SECONDS)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= breather.adjustFireLoss(-2 * REM, updating_health = FALSE)
	update_flags |= breather.adjustToxLoss(-5 * REM, updating_health = FALSE)
	update_flags |= breather.adjustBruteLoss(-2 * REM, updating_health = FALSE)
	return ..() | update_flags

/datum/reagent/hypernoblium
	name = "Hyper-Noblium"
	id = "hypernoblium"
	description = "A suppressive gas that stops gas reactions on those who inhale it."
	metabolization_rate = 0.5 * REAGENTS_METABOLISM // Because nitrium/freon/hyper-nob are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "90560B"
	taste_description = "searingly cold"
	can_synth = FALSE

/datum/reagent/hypernoblium/on_mob_life(mob/living/carbon/breather)
	if(isplasmaman(breather))
		breather.apply_status_effect(/datum/status_effect/hypernob_protection)
	return ..()

/datum/reagent/nitrium_high_metabolization
	name = "Nitrosyl plasmide"
	id = "nitrium_high_metabolization"
	description = "A highly reactive byproduct that stops you from sleeping, while dealing increasing toxin damage over time."
	metabolization_rate = 0.5 * REAGENTS_METABOLISM  // Because nitrium/freon/hypernoblium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "E1A116"
	taste_description = "sourness"
	addiction_chance = 50
	metabolized_traits = list(TRAIT_SLEEPIMMUNE)
	can_synth = FALSE

/datum/reagent/nitrium_high_metabolization/on_mob_life(mob/living/carbon/breather)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= breather.adjustStaminaLoss(-4 * REM , updating_health = FALSE)
	update_flags |= breather.adjustToxLoss(0.1 * (current_cycle - 1) * REM , updating_health = FALSE) // 1 toxin damage per cycle at cycle 10
	return ..() | update_flags

/datum/reagent/nitrium_low_metabolization
	name = "Nitrium"
	id = "nitrium_low_metabolization"
	description = "A highly reactive gas that makes you feel faster."
	metabolization_rate = 0.5 * REAGENTS_METABOLISM // Because nitrium/freon/hypernoblium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "90560B"
	taste_description = "burning"
	can_synth = FALSE

/datum/reagent/nitrium_low_metabolization/on_mob_metabolize(mob/living/breather)
	breather.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)
	return ..()

/datum/reagent/nitrium_low_metabolization/on_mob_end_metabolize(mob/living/breather)
	breather.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)
	return ..()

/datum/reagent/pluoxium
	name = "Pluoxium"
	id = "pluoxium"
	description = "A gas that is eight times more efficient than O2 at lung diffusion with organ healing properties on sleeping patients."
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	color = COLOR_GRAY
	taste_description = "irradiated air"
	can_synth = FALSE

/datum/reagent/pluoxium/on_mob_life(mob/living/carbon/breather)
	if(!HAS_TRAIT(breather, TRAIT_KNOCKEDOUT))
		return
	var/update_flags = STATUS_UPDATE_NONE
	for(var/obj/item/organ/organ_being_healed as anything in breather.internal_organs)
		if(!organ_being_healed.damage)
			continue
		organ_being_healed.heal_internal_damage(0.5, robo_repair = FALSE)
		update_flags |= STATUS_UPDATE_HEALTH
	return ..() | update_flags

/datum/reagent/zauker
	name = "Zauker"
	id = "zauker"
	description = "An unstable gas that is toxic to all living beings."
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	color = "90560B"
	taste_description = "bitter"
	can_synth = FALSE

/datum/reagent/zauker/on_mob_life(mob/living/breather)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= breather.adjustBruteLoss(6 * REM, updating_health = FALSE)
	update_flags |= breather.adjustOxyLoss(1 * REM, updating_health = FALSE)
	update_flags |= breather.adjustFireLoss(2 * REM, updating_health = FALSE)
	update_flags |= breather.adjustToxLoss(2 * REM, updating_health = FALSE)
	return ..() | update_flags

/datum/reagent/bz_metabolites
	name = "BZ Metabolites"
	id = "bz_metabolites"
	description = "A harmless metabolite of BZ gas."
	color = "#FAFF00"
	taste_description = "acrid cinnamon"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	can_synth = FALSE

/datum/reagent/bz_metabolites/on_mob_life(mob/living/carbon/target)
	target.Hallucinate(12.5 * REM)
	var/datum/antagonist/changeling/changeling = target?.mind?.has_antag_datum(/datum/antagonist/changeling)
	changeling?.chem_charges -= 5 * REM
	return ..()
