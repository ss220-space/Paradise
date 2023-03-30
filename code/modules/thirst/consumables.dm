/datum/reagent/consumable
	var/hydration_factor = 0

/datum/reagent/consumable/drink
	hydration_factor = 2 * REAGENTS_METABOLISM

/datum/reagent/consumable/ethanol
	var/remove_hydration = 2

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(M.hydration)
		if(prob(60))
			M.adjust_hydration(-remove_hydration)
	return ..() | update_flags
