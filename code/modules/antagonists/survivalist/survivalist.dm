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
	greet_message = "Устройте на станции как можно больше хаоса. Вы больше не подчиняетесь НТ и у вас явно хватит на это сил!"


/datum/antagonist/survivalist/guns/give_objectives()
	add_objective(/datum/objective/steal_five_of_type/summon_guns)
	..()


/datum/antagonist/survivalist/magic
	name = "Amateur Magician"
	greet_message = "Устройте на станции как можно больше хаоса. Вы больше не подчиняетесь НТ и у вас явно хватит на это сил!"


/datum/antagonist/survivalist/magic/greet()
	. = ..()
	. += span_notice("Будучи замечательным волшебником, вы должны помнить, что использованные книги заклинаний не имеют ценности.")


/datum/antagonist/survivalist/magic/give_objectives()
	add_objective(/datum/objective/steal_five_of_type/summon_magic)
	..()

