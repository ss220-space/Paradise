#define EVENT_CLING_GPOINTS 13

/mob/living/simple_animal/hostile/headslug/evented
	icon_state = "headslugevent"
	icon_living = "headslugevent"
	icon_dead = "headslug_deadevent"
	evented = TRUE

/mob/living/simple_animal/hostile/headslug/evented/proc/make_slug_antag()
	mind.assigned_role = SPECIAL_ROLE_HEADSLUG
	mind.add_antag_datum(/datum/antagonist/headslug)

/datum/antagonist/changeling/evented // make buffed changeling
	evented = TRUE
	genetic_points = EVENT_CLING_GPOINTS
	absorbed_dna = list()

/datum/antagonist/changeling/evented/on_gain()
	..()
	var/datum/action/changeling/lesserform/sluglesser = new /datum/action/changeling/lesserform // give new innate power
	sluglesser.power_type = "changeling_innate_power"
	sluglesser.dna_cost = 0
	give_power(sluglesser)
	absorbed_dna = list()

#undef EVENT_CLING_GPOINTS

