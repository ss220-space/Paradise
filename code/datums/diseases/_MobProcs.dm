
/mob/proc/HasDisease(datum/disease/D)
	for(var/thing in viruses)
		var/datum/disease/DD = thing
		if(D.IsSame(DD))
			return 1
	return 0


/mob/proc/CanContractDisease(datum/disease/D)
	if(stat == DEAD)
		return FALSE

	if(D.GetDiseaseID() in resistances)
		return FALSE

	if(HasDisease(D))
		return FALSE

	if(istype(D, /datum/disease/advance) && count_by_type(viruses, /datum/disease/advance) > 0)
		return FALSE

	for(var/mobtype in D.viable_mobtypes)
		if(istype(src, mobtype))
			return TRUE

	return FALSE


/mob/proc/ContractDisease(datum/disease/D)
	if(!CanContractDisease(D))
		return 0
	D.Contract(src)

/mob/living/carbon/ContractDisease(datum/disease/D)
	if(!CanContractDisease(D))
		return 0

	var/obj/item/clothing/Cl = null
	var/passed = TRUE

	if(prob(15/D.permeability_mod))
		return

	if(satiety > 0 && prob(satiety/10)) // positive satiety makes it harder to contract the disease.
		return

	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src

		switch(pick(40;"head", 40;"body", 10;"hands",  10;"feet"))
			if("head")
				if(isobj(H.head) && !istype(H.head, /obj/item/paper))
					Cl = H.head
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(H.wear_mask))
					Cl = H.wear_mask
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if("body")
				if(isobj(H.wear_suit))
					Cl = H.wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(slot_w_uniform))
					Cl = slot_w_uniform
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if("hands")
				if(isobj(H.wear_suit) && H.wear_suit.body_parts_covered&HANDS)
					Cl = H.wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)

				if(passed && isobj(H.gloves))
					Cl = H.gloves
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if("feet")
				if(isobj(H.wear_suit) && H.wear_suit.body_parts_covered&FEET)
					Cl = H.wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)

				if(passed && isobj(H.shoes))
					Cl = H.shoes
					passed = prob((Cl.permeability_coefficient*100) - 1)


	if(!passed && (D.spread_flags & AIRBORNE) && !internal)
		passed = (prob((50*D.permeability_mod) - 1))

	if(passed)
		D.Contract(src)


/**
 * Forces the mob to contract a virus. If the mob can have viruses. Ignores clothing and other protection
 * Returns TRUE if it succeeds. False if it doesn't
 *
 * Arguments:
 * * D - the disease the mob will try to contract
 */
//Same as ContractDisease, except never overidden clothes checks
/mob/proc/ForceContractDisease(datum/disease/D)
	if(!CanContractDisease(D))
		return FALSE
	D.Contract(src)
	return TRUE


/mob/living/carbon/human/CanContractDisease(datum/disease/D)
	if((VIRUSIMMUNE in dna.species.species_traits) && !D.ignore_immunity)
		return 0
	for(var/thing in D.required_organs)
		if(!((locate(thing) in bodyparts) || (locate(thing) in internal_organs)))
			return 0
	return ..()
