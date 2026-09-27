/datum/antagonist/multiverse
	name = "Multiverse Traveller"
	roundend_category = "Путешественниками по мультивселенной"
	show_in_roundend = FALSE
	special_role = SPECIAL_ROLE_MULTIVERSE
	antag_menu_name = "Путешественник по мультивселенной"
	var/datum/mind/summoner
	var/evil = FALSE

/datum/antagonist/multiverse/Destroy(force)
	summoner = null
	return ..()

/datum/antagonist/multiverse/give_objectives()
	var/mob/living/prime = summoner.current
	if(evil)
		add_objective(/datum/objective/hijackclone, "Ensure only [prime.real_name] and [prime.p_their()] copies are on the shuttle!")
		return
	add_objective(/datum/objective/protect, "Protect [prime.real_name], your copy, and help [prime.p_them()] defend the innocent from the mobs of multiverse clones.", summoner)


/datum/antagonist/multiverse/prime
	name = "Multiverse Summoner"
	antag_menu_name = "Призыватель мультивселенной"

/datum/antagonist/multiverse/prime/on_gain()
	special_role = "[owner.current.real_name] Prime"
	return ..()

/datum/antagonist/multiverse/prime/give_objectives()
	var/mob/living/prime = owner.current
	if(evil)
		add_objective(/datum/objective/hijackclone, "Ensure only [prime.real_name] and [prime.p_their()] copies are on the shuttle!")
		return
	add_objective(/datum/objective/survive, "Survive, and help defend the innocent from the mobs of multiverse clones.")

/datum/antagonist/multiverse/prime/greet()
	if(evil)
		return list(span_warning("<b>With your new found power you could easily conquer the station!</b>"))
	return list(span_warning("<b>With your new found power you could easily defend the station!</b>"))


/datum/antagonist/multiverse/prime/summoner
	evil = TRUE

/datum/antagonist/multiverse/prime/summoner/give_objectives()
	add_objective(/datum/objective/hijackclone)

/datum/antagonist/multiverse/prime/summoner/greet()
	return list("<b>You are the multiverse summoner. Activate your blade to summon copies of yourself from another universe to fight by your side.</b>")
