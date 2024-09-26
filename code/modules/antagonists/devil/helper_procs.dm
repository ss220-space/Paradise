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
