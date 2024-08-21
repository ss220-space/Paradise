/mob/living/proc/can_be_blob()
	return FALSE

/mob/living/proc/burst_blob_on_die()
	burst_blob_mob()

/mob/living/proc/burst_blob_in_mob()
	if(!ismob(loc))
		return
	burst_blob_mob()

/mob/living/proc/add_blob_atmos_immunity()
	return

/mob/living/proc/remove_blob_atmos_immunity()
	return

/mob/living/proc/burst_blob_mob()
	if(dusted)
		return
	if(!(mind && SSticker && SSticker.mode && can_be_blob()))
		return
	if(mind.special_role == SPECIAL_ROLE_BLOB && !was_bursted)
		var/datum/antagonist/blob_infected/blob = mind.has_antag_datum(/datum/antagonist/blob_infected)
		var/mob/living/simple_animal/borer/borer = has_brain_worms()
		if(borer)
			borer.leave_host()
			borer.death()
		blob?.burst_blob(TRUE)

/mob/living/simple_animal/can_be_blob()
	return TRUE


/mob/living/simple_animal/add_blob_atmos_immunity()
	old_atmos_requirements = atmos_requirements
	atmos_requirements = BLOB_INFECTED_ATMOS_REC
	minbodytemp = 0
	return ..()


/mob/living/simple_animal/remove_blob_atmos_immunity()
	atmos_requirements = old_atmos_requirements
	minbodytemp = initial(minbodytemp)
	return ..()

/mob/living/carbon/human/can_be_blob()
	if(!dna)
		return FALSE
	return !(dna.species.name in BLOB_RESTRICTED_SPECIES)

/mob/living/carbon/human/add_blob_atmos_immunity()
	var/datum/species/S = dna.species
	if(NO_BREATHE in S.species_traits)
		S.no_breathe_exist = TRUE
	else
		S.species_traits |= NO_BREATHE
	S.cold_level_1 = -INFINITY
	S.cold_level_2 = -INFINITY
	S.cold_level_3 = -INFINITY
	S.warning_low_pressure = -INFINITY
	S.hazard_low_pressure = -INFINITY
	S.hazard_high_pressure = INFINITY
	S.warning_high_pressure = INFINITY

/mob/living/carbon/human/remove_blob_atmos_immunity()
	var/datum/species/S = dna.species
	if(!S.no_breathe_exist)
		S.species_traits -= NO_BREATHE
	S.cold_level_1 = initial(S.cold_level_1)
	S.cold_level_2 = initial(S.cold_level_2)
	S.cold_level_3 = initial(S.cold_level_3)
	S.warning_low_pressure = initial(S.warning_low_pressure)
	S.hazard_low_pressure = initial(S.hazard_low_pressure)


/mob/living/simple_animal/imp/can_be_blob()
	return FALSE

/mob/living/simple_animal/borer/can_be_blob()
	return FALSE

/mob/living/simple_animal/demon/can_be_blob()
	return FALSE

/mob/living/simple_animal/revenant/can_be_blob()
	return FALSE

/mob/living/simple_animal/bot/can_be_blob()
	return FALSE

/mob/living/simple_animal/spiderbot/can_be_blob()
	return FALSE

/mob/living/simple_animal/ascendant_shadowling/can_be_blob()
	return FALSE

/mob/living/simple_animal/mouse/clockwork/can_be_blob()
	return FALSE

/mob/living/simple_animal/mouse/fluff/clockwork/can_be_blob()
	return FALSE

/mob/living/simple_animal/pet/dog/corgi/borgi/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/swarmer/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/guardian/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/blob/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/morph/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/construct/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/clockwork/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/alien/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/asteroid/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/malf_drone/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/statue/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/retaliate/syndirat/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/skeleton/retaliate/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/poison/terror_spider/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/megafauna/ancient_robot/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/megafauna/legion/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/megafauna/swarmer_swarm_beacon/can_be_blob()
	return FALSE
