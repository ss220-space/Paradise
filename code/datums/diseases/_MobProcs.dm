/mob/proc/HasDisease(disease_type_or_instance)
	var/datum/disease/D1
	if(ispath(disease_type_or_instance))
		D1 = new disease_type_or_instance()
	else
		D1 = disease_type_or_instance
		if(!istype(D1))
			return FALSE

	for(var/datum/disease/D2 in diseases)
		if(D2.IsSame(D1))
			return TRUE
	return FALSE

/mob/proc/CureAllDiseases(need_immunity = TRUE)
	for(var/datum/disease/D in diseases)
		D.cure(need_immunity)

/**
 * A special checks for this type of mob
 *
 * Returns:
 * * TRUE - if can contract disease
 * * FALSE - otherwise
 */
/mob/proc/CanContractDisease(datum/disease/D)
	return TRUE

/mob/living/carbon/human/CanContractDisease(datum/disease/D)
	if((VIRUSIMMUNE in dna.species.species_traits) && !D.ignore_immunity)
		return FALSE
	for(var/thing in D.required_organs)
		if(!((locate(thing) in bodyparts) || (locate(thing) in internal_organs)))
			return FALSE
	return ..()
