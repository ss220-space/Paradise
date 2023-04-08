/datum/reagent
	var/hydration_factor = -0.5 * REAGENTS_METABOLISM

/datum/reagent/on_mob_life(mob/living/M)
	. = ..()
	M.adjust_hydration(hydration_factor) // For thirst and hydration

//WATER!
/datum/reagent/water
	hydration_factor = 10 * REAGENTS_METABOLISM

//DRINKS!
/datum/reagent/consumable/drink
	hydration_factor = 6 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/cold
	hydration_factor = 4 * REAGENTS_METABOLISM

//ALCOHOL!
/datum/reagent/consumable/ethanol
	hydration_factor = -1 * REAGENTS_METABOLISM

//FOOD!

/datum/reagent/consumable/hot_coco
	hydration_factor = 4 * REAGENTS_METABOLISM

/datum/reagent/consumable/hot_ramen
	hydration_factor = 4 * REAGENTS_METABOLISM

/datum/reagent/consumable/mugwort
	hydration_factor = 6 * REAGENTS_METABOLISM

/datum/reagent/consumable/chicken_soup
	hydration_factor = 1 * REAGENTS_METABOLISM

