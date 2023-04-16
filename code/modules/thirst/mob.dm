/mob
	var/hydration = HYDRATION_LEVEL_GOOD + 50
	var/thirst_drain = THIRST_FACTOR

///Adjust the hydration of a mob
/mob/proc/adjust_hydration(change)
	if(!config.hydration_enabled)
		return
	hydration = clamp(hydration + change, 0, HYDRATION_LEVEL_FULL)

/mob/living/carbon/human/adjust_hydration(change)
	if((NO_THIRST in dna.species.species_traits) || mind?.vampire)
		return FALSE
	. = ..()

///Force set the mob hydration
/mob/proc/set_hydration(change)
	if(!config.hydration_enabled)
		return
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
	if(!config.hydration_enabled)
		return
	if(NO_THIRST in dna.species.species_traits)
		if(hydration >= 0 && stat != DEAD)
			handle_thirst_alerts()
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

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(!config.hydration_enabled)
		return
	if(!.)
		return
	if(hydration && stat != DEAD)
		adjust_hydration(-(thirst_drain * 0.1))
		if(m_intent == MOVE_INTENT_RUN)
			adjust_hydration(-(thirst_drain * 0.1))

/mob/living/carbon/human/proc/handle_thirst_alerts()
	if(!hydration_alert)
		return
	if((NO_THIRST in dna.species.species_traits) || mind?.vampire || !config.hydration_enabled)
		hydration_alert.icon_state = null
		return
	switch(hydration)
		if(HYDRATION_LEVEL_WELL_FED to INFINITY)
			hydration_alert.icon_state = "water_full"
		if(HYDRATION_LEVEL_GOOD to HYDRATION_LEVEL_WELL_FED)
			hydration_alert.icon_state = "water_well_hydrated"
		if(HYDRATION_LEVEL_MEDIUM to HYDRATION_LEVEL_GOOD)
			hydration_alert.icon_state = "water_hydrated"
		if(HYDRATION_LEVEL_SMALL to HYDRATION_LEVEL_MEDIUM)
			hydration_alert.icon_state = "water_thirsty"
		else
			hydration_alert.icon_state = "water_dehydrated"

/mob/living/rejuvenate()
	. = ..()
	set_hydration(initial(hydration))
