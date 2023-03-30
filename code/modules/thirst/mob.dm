/mob
	var/hydration = HYDRATION_LEVEL_GOOD + 50
	var/thirst_drain = THIRST_FACTOR

///Adjust the hydration of a mob
/mob/proc/adjust_hydration(change)
	hydration = clamp(hydration + change, 0, HYDRATION_LEVEL_FULL)

/mob/living/carbon/human/adjust_hydration(change)
	if(NO_THIRST in dna.species.species_traits || (mind && (mind in SSticker?.mode?.vampires)))
		return FALSE
	. = ..()

///Force set the mob hydration
/mob/proc/set_hydration(change)
	hydration = clamp(change, 0, HYDRATION_LEVEL_FULL)

/mob/living/carbon/human/set_hydration(change)
	if(NO_THIRST in dna.species.species_traits || (mind && (mind in SSticker?.mode?.vampires)))
		return FALSE
	. = ..()

/mob/living/carbon/human/set_species(datum/species/new_species, default_colour, delay_icon_update, skip_same_check, retain_damage)
	. = ..()
	if(!.)
		return
	thirst_drain = dna.species.thirst_drain

/mob/living/carbon/human/handle_chemicals_in_body()
	. = ..()
	if(!(NO_THIRST in dna.species.species_traits))
		if(hydration >= 0 && stat != DEAD)
			handle_thirst_alerts()
		var/thirst_rate = thirst_drain
		//satiety????
		adjust_hydration(-thirst_rate)

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(!.)
		return
	if(hydration && stat != DEAD)
		adjust_hydration(-(thirst_drain * 0.1))
		if(m_intent == MOVE_INTENT_RUN)
			adjust_hydration(-(thirst_drain * 0.1))

/mob/living/carbon/human/proc/handle_thirst_alerts()
	if(NO_THIRST in dna.species.species_traits)
		return
	switch(hydration)
		if(HYDRATION_LEVEL_WELL_FED to INFINITY)
			throw_alert("hydration", /obj/screen/alert/water/full)
		if(HYDRATION_LEVEL_GOOD to HYDRATION_LEVEL_WELL_FED)
			throw_alert("hydration", /obj/screen/alert/water/well_fed)
		if(HYDRATION_LEVEL_MEDIUM to HYDRATION_LEVEL_GOOD)
			throw_alert("hydration", /obj/screen/alert/water/fed)
		if(HYDRATION_LEVEL_SMALL to HYDRATION_LEVEL_MEDIUM)
			throw_alert("hydration", /obj/screen/alert/water/hungry)
		else
			throw_alert("hydration", /obj/screen/alert/water/starving)

/mob/living/rejuvenate()
	. = ..()
	set_hydration(initial(hydration))

/mob/living/carbon/eat(obj/item/reagent_containers/food/toEat, mob/user, bitesize_override)
	. = ..()
	if(!.)
		return

/obj/screen/alert/water/fat
	name = "Fat"
	desc = "You ate too much food, lardass. Run around the station and lose some weight."
	icon_state = "fat"

/obj/screen/alert/water/full
	name = "Full"
	desc = "You feel full and satisfied, but you shouldn't eat much more."
	icon_state = "full"

/obj/screen/alert/water/well_fed
	name = "Well Fed"
	desc = "You feel quite satisfied, but you may be able to eat a bit more."
	icon_state = "well_fed"

/obj/screen/alert/water/fed
	name = "Fed"
	desc = "You feel moderately satisfied, but a bit more food may not hurt."
	icon_state = "fed"

/obj/screen/alert/water/hungry
	name = "Hungry"
	desc = "Some food would be good right about now."
	icon_state = "hungry"

/obj/screen/alert/water/starving
	name = "Starving"
	desc = "You're severely malnourished. The hunger pains make moving around a chore."
	icon_state = "starving"


//handle_stomach ???
//adjust_nutrition - моли, големы, дионы, слайм конечности, нимфы,
//nutrition
	//ui_nutrition ???
	//vomit
	//makeAntiCluwne
	//вампирам выдать
	//галюны пофиксить
	//devoured
	//selfDrink
	//eat


//food_poisoning
//tuberculosis
//blood virus
//ethanol
