/mob/living/proc/check_devil_bane_multiplier(obj/item/weapon, mob/living/attacker)
	var/datum/antagonist/devil/devilInfo = mind.has_antag_datum(/datum/antagonist/devil)
	switch(devilInfo.bane)
		if(BANE_WHITECLOTHES)
			if(!ishuman(attacker))
				return 0

			var/mob/living/carbon/human/H = attacker
			if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = H.w_uniform
				if(GLOB.whiteness[U.type])
					visible_message("<span class='warning'>[src] seems to have been harmed by the purity of [attacker]'s clothes.</span>", "<span class='notice'>Unsullied white clothing is disrupting your form.</span>")
					return GLOB.whiteness[U.type] + 1

		if(BANE_TOOLBOX)
			if(istype(weapon,/obj/item/storage/toolbox))
				visible_message("<span class='warning'>The [weapon] seems unusually robust this time.</span>", "<span class='notice'>The [weapon] is your unmaking!</span>")
				return 2.5 // Will take four hits with a normal toolbox.

		if(BANE_HARVEST)
			if(istype(weapon,/obj/item/reagent_containers/food/snacks/grown/) || istype(weapon,/obj/item/grown))
				visible_message("<span class='warning'>The spirits of the harvest aid in the exorcism.</span>", "<span class='notice'>The harvest spirits are harming you.</span>")
				Weaken(4 SECONDS)
				qdel(weapon)
				return 2

	return 1

/mob/living/proc/owns_soul()
	if(!mind)
		return FALSE
		
	return mind.soulOwner == mind

/mob/living/proc/return_soul()
	if(!mind)
		return

	mind.soulOwner = mind
	mind.damnation_type = 0

	var/datum/antagonist/devil/devil = mind?.has_antag_datum(/datum/antagonist/devil)
	if(!devil)
		return 
	
	devil.remove_soul(mind)

/mob/living/proc/has_bane(banetype)
	var/datum/antagonist/devil/devil = mind?.has_antag_datum(/datum/antagonist/devil)
	if(!devil)
		return TRUE
			
	return devil.bane == banetype

/mob/living/proc/check_weakness(obj/item/weapon, mob/living/attacker)
	var/datum/antagonist/devil/devil = mind?.has_antag_datum(/datum/antagonist/devil)
	if(!devil)
		return TRUE

	return check_devil_bane_multiplier(weapon, attacker)

/mob/living/proc/check_acedia()
	if(!mind?.objectives)
		return FALSE

	for(var/datum/objective/sintouched/acedia/A in mind.objectives)
		return TRUE

	return FALSE

/proc/devilInfo(name)
	if(GLOB.allDevils[lowertext(name)])
		return GLOB.allDevils[lowertext(name)]

	var/datum/fakeDevil/devil = new /datum/fakeDevil(name)
	GLOB.allDevils[lowertext(name)] = devil

	return devil

/proc/randomDevilName()
	var/name = ""
	if(prob(65))
		if(prob(35))
			name = pick(GLOB.devil_pre_title)

		name += pick(GLOB.devil_title)

	var/probability = 100
	name += pick(GLOB.devil_syllable)
    
	while(prob(probability))
		name += pick(GLOB.devil_syllable)
		probability -= 20

	if(prob(40))
		name += pick(GLOB.devil_suffix)

	return name

/proc/randomdevilobligation()
	return pick(OBLIGATION_FOOD, OBLIGATION_FIDDLE, OBLIGATION_DANCEOFF, OBLIGATION_GREET, OBLIGATION_PRESENCEKNOWN, OBLIGATION_SAYNAME, OBLIGATION_ANNOUNCEKILL, OBLIGATION_ANSWERTONAME)

/proc/randomdevilban()
	return pick(BAN_HURTWOMAN, BAN_CHAPEL, BAN_HURTPRIEST, BAN_AVOIDWATER, BAN_HURTLIZARD, BAN_HURTANIMAL)

/proc/randomdevilbane()
	return pick(BANE_SALT, BANE_LIGHT, BANE_IRON, BANE_WHITECLOTHES, BANE_SILVER, BANE_HARVEST, BANE_TOOLBOX)

/proc/randomdevilbanish()
	return pick(BANISH_WATER, BANISH_COFFIN, BANISH_FORMALDYHIDE, BANISH_RUNES, BANISH_CANDLES, BANISH_DESTRUCTION, BANISH_FUNERAL_GARB)
