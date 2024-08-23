/datum/blob_atmos_immunities
	/// mob to which the immunity applies
	var/mob/living/affected_mob
	/// valid mob type
	var/mob_type


/datum/blob_atmos_immunities/proc/is_type_suitable(mob/living/affected)
	return mob_type && istype(affected, mob_type)


/datum/blob_atmos_immunities/proc/is_affected_mob(mob/living/affected)
	return is_type_suitable(affected) && !QDELETED(affected_mob) && affected == affected_mob


/datum/blob_atmos_immunities/proc/add_immunity(mob/living/affected)
	if(is_type_suitable(affected))
		affected_mob = affected
		return TRUE
	return FALSE


/datum/blob_atmos_immunities/proc/remove_immunity(mob/living/affected)
	if(is_affected_mob(affected))
		affected_mob = null
		return TRUE
	return FALSE


/datum/blob_atmos_immunities/human
	mob_type = /mob/living/carbon/human
	/// Indicates that the breathless trait was present before the change
	var/no_breathe_exist


/datum/blob_atmos_immunities/human/add_immunity(mob/living/carbon/human/affected)
	if(..(affected))
		var/datum/species/S = affected.dna.species
		if(NO_BREATHE in S.species_traits)
			no_breathe_exist = TRUE
		else
			S.species_traits |= NO_BREATHE
		S.cold_level_1 = BLOB_INFECTED_MIN_BODY_TEMP
		S.cold_level_2 = BLOB_INFECTED_MIN_BODY_TEMP
		S.cold_level_3 = BLOB_INFECTED_MIN_BODY_TEMP
		S.warning_low_pressure = BLOB_INFECTED_MIN_PRESSURE
		S.hazard_low_pressure =  BLOB_INFECTED_MIN_PRESSURE
		return TRUE
	return FALSE


/datum/blob_atmos_immunities/human/remove_immunity(mob/living/carbon/human/affected)
	if(..(affected))
		var/datum/species/S = affected.dna.species
		if(!no_breathe_exist)
			S.species_traits -= NO_BREATHE
		S.cold_level_1 = initial(S.cold_level_1)
		S.cold_level_2 = initial(S.cold_level_2)
		S.cold_level_3 = initial(S.cold_level_3)
		S.warning_low_pressure = initial(S.warning_low_pressure)
		S.hazard_low_pressure = initial(S.hazard_low_pressure)
		return TRUE
	return FALSE


/datum/blob_atmos_immunities/simple_animal
	mob_type = /mob/living/simple_animal
	/// Contains mob atmos that existed before the change
	var/list/old_atmos_requirements


/datum/blob_atmos_immunities/simple_animal/add_immunity(mob/living/simple_animal/affected)
	if(..(affected))
		old_atmos_requirements = affected.atmos_requirements
		affected.atmos_requirements = BLOB_INFECTED_ATMOS_REC
		affected.minbodytemp = BLOB_INFECTED_MIN_BODY_TEMP
		return TRUE
	return FALSE


/datum/blob_atmos_immunities/simple_animal/remove_immunity(mob/living/simple_animal/affected)
	if(..(affected))
		affected.atmos_requirements = old_atmos_requirements
		affected.minbodytemp = initial(affected.minbodytemp)
		return TRUE
	return FALSE

/proc/get_suitable_blob_atmos_immunities(mob/living/affected)
	if(isanimal(affected))
		return new /datum/blob_atmos_immunities/simple_animal()
	if(ishuman(affected))
		return new /datum/blob_atmos_immunities/human()
