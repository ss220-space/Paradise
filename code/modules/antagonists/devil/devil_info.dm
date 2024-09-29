/datum/devilinfo
	var/truename
	var/obligation
	var/ban

	var/datum/devil_banish/banish
	var/datum/devil_bane/bane

/datum/devilinfo/New(name = randomDevilName())
	truename = name
	randomdevilbane()
	obligation = randomdevilobligation()
	ban = randomdevilban()
	randomdevilbanish()

/datum/devilinfo/Destroy(force)
	QDEL_NULL(banish)
	QDEL_NULL(bane)

	return ..()

/datum/devilinfo/proc/randomDevilName()
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

/datum/devilinfo/proc/randomdevilobligation()
	return pick(OBLIGATION_FOOD, OBLIGATION_FIDDLE, OBLIGATION_DANCEOFF, OBLIGATION_GREET, OBLIGATION_PRESENCEKNOWN, OBLIGATION_SAYNAME, OBLIGATION_ANNOUNCEKILL, OBLIGATION_ANSWERTONAME)

/datum/devilinfo/proc/randomdevilban()
	return pick(BAN_HURTWOMAN, BAN_CHAPEL, BAN_HURTPRIEST, BAN_AVOIDWATER, BAN_HURTLIZARD, BAN_HURTANIMAL)

/datum/devilinfo/proc/randomdevilbane()
	var/list/banes = list()

	for(var/datum/devil_bane/bane as anything in subtypesof(/datum/devil_bane))
		if(!bane.name)
			continue

		LAZYADD(banes, bane)

	var/new_bane = pick(banes)
	bane = new new_bane()

/datum/devilinfo/proc/randomdevilbanish()
	var/list/banishes = list()

	for(var/datum/devil_banish/banish as anything in subtypesof(/datum/devil_banish))
		if(!banish.name)
			continue

		LAZYADD(banishes, banish)

	var/new_banish = pick(banishes)
	banish = new new_banish()
