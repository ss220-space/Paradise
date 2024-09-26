/mob/proc/HasDisease(disease_type_or_instance)
	if(ispath(disease_type_or_instance))
		for(var/datum/disease/D2 in diseases)
			if(D2.type == disease_type_or_instance)
				return TRUE
		return FALSE
	else if(!istype(disease_type_or_instance, /datum/disease))
		return FALSE

	for(var/datum/disease/D2 in diseases)
		if(D2.IsSame(disease_type_or_instance))
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
	if(!D.ignore_immunity && HAS_TRAIT(src, TRAIT_VIRUSIMMUNE))
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

	//virus must to pass all the checks stated in act_type
	if((act_type & BITES) && !CheckBitesProtection(V, zone))
		return FALSE

	if((act_type & CONTACT) && !CheckContactProtection(V, zone))
		return FALSE

	if((act_type & AIRBORNE) && !CheckAirborneProtection(V, zone))
		return FALSE

	return TRUE

//Returns TRUE, if mob protected
/mob/proc/CheckBitesProtection(datum/disease/virus/V, zone)
	return FALSE

/mob/proc/CheckContactProtection(datum/disease/virus/V, zone)
	return FALSE

/mob/proc/CheckAirborneProtection(datum/disease/virus/V, zone)
	return FALSE

/mob/living/CheckBitesProtection(datum/disease/virus/V, zone = BODY_ZONE_CHEST)
	var/x = run_armor_check(zone, MELEE)/V.permeability_mod
	// parabola from (0, 0) to (100, 100)
	return prob(sqrtor0(100*x))

/mob/living/carbon/human/CheckContactProtection(datum/disease/virus/V, zone)
	if(!zone)
		zone = pick(40; BODY_ZONE_HEAD, 40; BODY_ZONE_CHEST, 10; BODY_ZONE_L_ARM, 10; BODY_ZONE_L_LEG)
	if(prob(getarmor(zone, BIO)/V.permeability_mod))
		return TRUE
	return FALSE

/mob/living/carbon/human/CheckAirborneProtection(datum/disease/virus/V, zone)
	var/internals_mod = internal ? 1 : 0.2
	var/permeability_mod = clamp((2 - V.permeability_mod), 0.1, 1)
	var/mask_protection_mod = 0
	if(wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH))
		mask_protection_mod = wear_mask.gas_transfer_coefficient

	if(prob((internals_mod + permeability_mod + mask_protection_mod)/3*100))
		return TRUE

	return FALSE
