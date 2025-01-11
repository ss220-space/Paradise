/datum/devilinfo
	/// Devil's truename
	var/truename
	/// Ban of our devil. 
	var/datum/devil_ban/ban
	/// Obligation of our devil.
	var/datum/devil_obligation/obligation
	/// Banish of our devil. Used to dust him. Works only with devil_banishment element
	var/datum/devil_banish/banish
	/// Bane of our devil. Used to make devil weaker
	var/datum/devil_bane/bane

/datum/devilinfo/New(name = randomDevilName())
	truename = name

	randomdevilbane()
	randomdevilobligation()

	randomdevilban()
	randomdevilbanish()

/datum/devilinfo/Destroy(force)
	QDEL_NULL(banish)
	QDEL_NULL(bane)

	QDEL_NULL(ban)
	QDEL_NULL(obligation)

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
	var/new_obligation =  pick(subtypesof(/datum/devil_obligation))
	obligation = new new_obligation()

/datum/devilinfo/proc/randomdevilban()
	var/new_ban = pick(subtypesof(/datum/devil_ban))
	ban = new new_ban()

/datum/devilinfo/proc/randomdevilbane()
	var/new_bane = pick(subtypesof(/datum/devil_bane))
	bane = new new_bane()

/datum/devilinfo/proc/randomdevilbanish()
	var/new_banish = pick(subtypesof(/datum/devil_banish))
	banish = new new_banish()
