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
		D.cure(need_immunity = need_immunity)

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

/**
 * Checking mob's protection against disease D by the chosen method in chosen zone
 * Returns:
 * * TRUE - mob has protected from the virus
 * * FALSE - otherwise
 */
/mob/proc/CheckVirusProtection(datum/disease/virus/V, act_type = BITES|CONTACT|AIRBORNE, zone)
	if(prob(15/V.permeability_mod))
		return TRUE

	if(satiety > 0 && prob(satiety/10))
		return TRUE

	if((act_type & BITES) && CheckBitesProtection(V, zone))
		return TRUE

	if((act_type & CONTACT) && CheckContactProtection(V, zone))
		return TRUE

	if((act_type & AIRBORNE) && CheckAirborneProtection(V, zone))
		return TRUE

	return FALSE

//Returns TRUE, if mob protected
/mob/proc/CheckBitesProtection(datum/disease/virus/V, zone)
	return FALSE

/mob/proc/CheckContactProtection(datum/disease/virus/V, zone)
	return FALSE

/mob/proc/CheckAirborneProtection(datum/disease/virus/V, zone)
	return FALSE

/mob/living/CheckBitesProtection(datum/disease/virus/V, zone = BODY_ZONE_CHEST)
	return ..() || prob(run_armor_check(zone, "melee") / V.permeability_mod)

/mob/living/carbon/human/CheckContactProtection(datum/disease/virus/V, zone)
	if(..())
		return TRUE

	var/zone_text
	if(!zone)
		zone_text = pick(40; "head", 40; "chest", 10; "l_arm", 10; "l_leg")
	else
		if(istype(zone, /obj/item/organ/external))
			var/obj/item/organ/external/E = zone
			zone_text = E.limb_name
		else
			zone_text = zone

	switch(zone_text)
		if("head", "eyes", "mouth")
			if(ClothingVirusProtection(head) || ClothingVirusProtection(wear_mask))
				return TRUE
		if("chest", "groin", "tail", "wing")
			if(ClothingVirusProtection(wear_suit) || ClothingVirusProtection(slot_w_uniform))
				return TRUE
		if("l_arm", "r_arm", "l_hand", "r_hand")
			if(istype(wear_suit) && (wear_suit.body_parts_covered & HANDS) && ClothingVirusProtection(wear_suit))
				return TRUE
			if(ClothingVirusProtection(gloves))
				return TRUE
		if("l_leg", "r_leg", "l_foot", "r_foot")
			if(istype(wear_suit) && (wear_suit.body_parts_covered & FEET) && ClothingVirusProtection(wear_suit))
				return TRUE
			if(ClothingVirusProtection(shoes))
				return TRUE

	return FALSE

/mob/living/CheckAirborneProtection(datum/disease/virus/V, zone)
	//permeability_mod == 0 => 100% defense; permeability_mod == 2 => 0% defense
	if(..() || internal || prob(50 * (2 - V.permeability_mod)))
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/ClothingVirusProtection(obj/item/Clothing)
	//permeability_coefficient == 0.01 => 100% defense; permeability_coefficient == 1 => 1% defense
	if(istype(Clothing) && prob(100 * (1.01 - Clothing.permeability_coefficient)))
		return TRUE
	return FALSE
