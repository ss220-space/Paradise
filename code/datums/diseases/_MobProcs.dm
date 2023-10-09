
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


/mob/proc/CanContractVirus(datum/disease/virus/D)
	if(stat == DEAD && !D.can_spread_to_dead)
		return FALSE

	if(D.GetDiseaseID() in resistances)
		return FALSE

	if(HasDisease(D))
		return FALSE

	if(istype(D, /datum/disease/virus/advance) && count_by_type(diseases, /datum/disease/virus/advance) > 0)
		return FALSE

	for(var/mobtype in D.viable_mobtypes)
		if(istype(src, mobtype))
			return TRUE

	return FALSE

/mob/living/carbon/human/CanContractVirus(datum/disease/virus/D)
	if((VIRUSIMMUNE in dna.species.species_traits) && !D.ignore_immunity)
		return FALSE
	for(var/thing in D.required_organs)
		if(!((locate(thing) in bodyparts) || (locate(thing) in internal_organs)))
			return FALSE
	return ..()
