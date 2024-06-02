/datum/antagonist/survivalist
	name = "Survivalist"
	special_role = "survivalist"
	var/greet_message = ""


/datum/antagonist/survivalist/give_objectives()
	add_objective(/datum/objective/survive)


/datum/antagonist/survivalist/greet()
	. = ..()
	return . += span_notice("[greet_message]")


/datum/antagonist/survivalist/guns
	greet_message = "Wreak havoc upon the station as much you can. You no longer obey the NT, you have enough power to do this!"


/datum/antagonist/survivalist/guns/give_objectives()
	add_objective(/datum/objective/steal_five_of_type/summon_guns)
	..()


/datum/antagonist/survivalist/magic
	name = "Amateur Magician"
	greet_message = "Wreak havoc upon the station as much you can. You no longer obey the NT, you have enough power to do this!"


/datum/antagonist/survivalist/magic/greet()
	..()
	return . += span_notice("As a wonderful magician, you should remember that spellbooks don't mean anything if they are used up.")


/datum/antagonist/survivalist/magic/give_objectives()
	add_objective(/datum/objective/steal_five_of_type/summon_magic)
	..()

