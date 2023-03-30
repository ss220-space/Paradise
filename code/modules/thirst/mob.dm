/mob
	var/hydration = HYDRATION_LEVEL_GOOD + 50
	var/thirst_drain = THIRST_FACTOR

///Adjust the hydration of a mob
/mob/proc/adjust_hydration(change)
	hydration = clamp(hydration + change, 0, HYDRATION_LEVEL_FULL)

/mob/living/carbon/human/adjust_hydration(change)
	if((NO_THIRST in dna.species.species_traits) || mind?.vampire)
		return FALSE
	. = ..()

///Force set the mob hydration
/mob/proc/set_hydration(change)
	hydration = clamp(change, 0, HYDRATION_LEVEL_FULL)

/mob/living/carbon/human/set_hydration(change)
	if((NO_THIRST in dna.species.species_traits) || mind?.vampire)
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

		if(!ismachineperson(src) && !isLivingSSD(src) && hydration < HYDRATION_LEVEL_INEFFICIENT)
			var/datum/disease/D = new /datum/disease/critical/dehydration
			ForceContractDisease(D)

/mob/make_vampire()
	. = ..()
	hydration = initial(hydration)
	clear_alert("hydration", clear_override = TRUE)

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(!.)
		return
	if(hydration && stat != DEAD)
		adjust_hydration(-(thirst_drain * 0.1))
		if(m_intent == MOVE_INTENT_RUN)
			adjust_hydration(-(thirst_drain * 0.1))

/mob/living/carbon/human/proc/handle_thirst_alerts()
	if((NO_THIRST in dna.species.species_traits) || mind?.vampire)
		return
	switch(hydration)
		if(HYDRATION_LEVEL_MEDIUM to INFINITY)
			clear_alert("hydration")
		if(HYDRATION_LEVEL_SMALL to HYDRATION_LEVEL_MEDIUM)
			throw_alert("hydration", /obj/screen/alert/water/thirsty)
		else
			throw_alert("hydration", /obj/screen/alert/water/dehydrated)

/mob/living/rejuvenate()
	. = ..()
	set_hydration(initial(hydration))

/mob/living/carbon/eat(obj/item/reagent_containers/food/toEat, mob/user, bitesize_override)
	. = ..()
	if(!.)
		return

/obj/screen/alert/water/full
	name = "Full"
	desc = "You feel full and satisfied, but you shouldn't drink much more."
	icon_state = "water_full"

/obj/screen/alert/water/well_hydrated
	name = "Well Hydrated"
	desc = "You feel quite satisfied, but you may be able to drink a bit more."
	icon_state = "water_well_hydrated"

/obj/screen/alert/water/hydrated
	name = "Hydrated"
	desc = "You feel moderately satisfied, but a bit more water may not hurt."
	icon_state = "water_hydrated"

/obj/screen/alert/water/thirsty
	name = "Thirsty"
	desc = "Some water would be good right about now."
	icon_state = "water_thirsty"

/obj/screen/alert/water/dehydrated
	name = "Dehydrated"
	desc = "You're severely dehydrated. The thirst pains make moving around a chore."
	icon_state = "water_dehydrated"
