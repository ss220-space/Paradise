#define WATER_POISON_CHANCE 5 // За пять стаканов по 30u, шанс отравиться с шансом 78%; За один стакан с 30u, шанс отравиться 26%

/datum/reagent
	var/hydration_factor = -0.5 * REAGENTS_METABOLISM

/datum/reagent/on_mob_life(mob/living/M)
	. = ..()
	M.adjust_hydration(hydration_factor) // For thirst and hydration

//WATER!
/datum/reagent/water
	hydration_factor = 10 * REAGENTS_METABOLISM
	var/dirty = FALSE

/datum/reagents/proc/dirty_water()
	var/datum/reagent/water/water = locate() in reagent_list
	if(water)
		water.dirty = TRUE

/datum/reagents/proc/clear_dirty_water()
	var/datum/reagent/water/water = locate() in reagent_list
	if(water)
		water.dirty = FALSE

/datum/reagents/proc/is_dirty_water()
	var/datum/reagent/water/water = locate() in reagent_list
	if(water)
		return water.dirty
	return FALSE

/datum/reagent/water/reaction_mob(mob/living/M, method, volume)
	. = ..()
	if(!config.water_poison)
		return
	if(!dirty)
		return
	if((NO_THIRST in M.dna.species.species_traits) || !M.dna.species.water_poisonable)
		return
	if(method == REAGENT_INGEST && prob(WATER_POISON_CHANCE))
		M.ForceContractDisease(new /datum/disease/water_poisoning(0))

/datum/chemical_reaction/water_disinfection
	name = "Water"
	id = "water"
	result = "water"
	required_reagents = list("water" = 1, "charcoal" = 1)
	result_amount = 1
	mix_sound = null

/datum/chemical_reaction/water_disinfection/on_reaction(datum/reagents/holder, created_volume)
	. = ..()
	holder.clear_dirty_water()

/obj/structure/reagent_dispensers/watertank/Initialize(mapload)
	. = ..()
	reagents.dirty_water()

/obj/structure/reagent_dispensers/watertank/high/Initialize(mapload)
	. = ..()
	reagents.dirty_water()

/obj/structure/mopbucket/full/Initialize(mapload)
	. = ..()
	reagents.dirty_water()

//DRINKS!
/datum/reagent/consumable/drink
	hydration_factor = 6 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/cold
	hydration_factor = 4 * REAGENTS_METABOLISM

//ALCOHOL!
/datum/reagent/consumable/ethanol
	hydration_factor = 1 * REAGENTS_METABOLISM

//FOOD!

/datum/reagent/consumable/hot_coco
	hydration_factor = 4 * REAGENTS_METABOLISM

/datum/reagent/consumable/hot_ramen
	hydration_factor = 4 * REAGENTS_METABOLISM

/datum/reagent/consumable/mugwort
	hydration_factor = 6 * REAGENTS_METABOLISM

/datum/reagent/consumable/chicken_soup
	hydration_factor = 1 * REAGENTS_METABOLISM

#undef WATER_POISON_CHANCE
