/datum/reagent
	var/hydration_factor = 0

/datum/reagent/water
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink
	hydration_factor = 6 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/cold
	hydration_factor = 4 * REAGENTS_METABOLISM

/datum/reagent/consumable/ethanol
	hydration_factor = -1 * REAGENTS_METABOLISM
