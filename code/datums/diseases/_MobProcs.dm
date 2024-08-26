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
	return ..() || prob(run_armor_check(zone, "melee") / V.permeability_mod)

/mob/living/carbon/human/CheckContactProtection(datum/disease/virus/V, zone)
	if(..())
		return TRUE

	var/zone_text
	if(!zone)
		zone_text = pick(40; BODY_ZONE_HEAD, 40; BODY_ZONE_CHEST, 10; BODY_ZONE_L_ARM, 10; BODY_ZONE_L_LEG)
	else
		if(istype(zone, /obj/item/organ/external))
			var/obj/item/organ/external/E = zone
			zone_text = E.limb_zone
		else
			zone_text = zone

	switch(zone_text)
		if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH)
			if(ClothingVirusProtection(head) || ClothingVirusProtection(wear_mask))
				return TRUE
		if(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_TAIL, BODY_ZONE_WING)
			if(ClothingVirusProtection(wear_suit) || ClothingVirusProtection(w_uniform))
				return TRUE
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
			if(istype(wear_suit) && (wear_suit.body_parts_covered & HANDS) && ClothingVirusProtection(wear_suit))
				return TRUE
			if(ClothingVirusProtection(gloves))
				return TRUE
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			if(istype(wear_suit) && (wear_suit.body_parts_covered & FEET) && ClothingVirusProtection(wear_suit))
				return TRUE
			if(ClothingVirusProtection(shoes))
				return TRUE

	return FALSE

/mob/living/carbon/human/CheckAirborneProtection(datum/disease/virus/V, zone)
	if(..())
		return TRUE

	var/internals_mod = internal ? 1 : 0.2
	var/permeability_mod = clamp((2 - V.permeability_mod), 0.1, 1)
	var/mask_protection_mod = 1
	if(wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH))
		mask_protection_mod = 0.5
		if(istype(wear_mask, /obj/item/clothing/mask/breath))
			mask_protection_mod = 0.7
		if(istype(wear_mask, /obj/item/clothing/mask/gas))
			mask_protection_mod = 0.9
		if(istype(wear_mask, /obj/item/clothing/mask/surgical) || istype(wear_mask, /obj/item/clothing/mask/breath/medical))
			mask_protection_mod = 0.99

	if(prob(100 * permeability_mod * internals_mod * mask_protection_mod))
		return TRUE

	return FALSE

/mob/living/carbon/human/proc/ClothingVirusProtection(obj/item/Clothing)
	//permeability_coefficient == 0.01 => 99% defense; permeability_coefficient == 1 => 0% defense
	if(istype(Clothing) && prob(100 * (1 - Clothing.permeability_coefficient)))
		return TRUE
	return FALSE
