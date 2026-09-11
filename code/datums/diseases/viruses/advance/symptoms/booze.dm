/*
//////////////////////////////////////

Alcochlorians

	Decreases Stealth
	Improves resistance significantly.
	Improves stage speed significantly.
	Decreases transmittablity.

Bonus
	The body generates alcohol.
	From Bacchus with love
//////////////////////////////////////
*/

/datum/symptom/booze

	name = "Алко-хлорианы"
	id = "booze"
	stealth = -4
	resistance = 4
	stage_speed = 3
	transmittable = -2
	level = 3

/datum/symptom/booze/Activate(datum/disease/virus/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 2))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				var/datum/reagent/random_alcohol = pick(/datum/reagent/consumable/ethanol/rum, /datum/reagent/consumable/ethanol/vodka, /datum/reagent/consumable/ethanol/whiskey, /datum/reagent/consumable/ethanol/ale, /datum/reagent/consumable/ethanol/cider, /datum/reagent/consumable/ethanol/mead, /datum/reagent/consumable/ethanol/tequila, /datum/reagent/consumable/ethanol/wine, /datum/reagent/consumable/ethanol/beer)
				M.reagents.add_reagent(random_alcohol, 5) //somewhat safe drinks
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					to_chat(M, span_notice(pick("Вы чувствуете тепло.", "Вы чувствуете радость.", "Вы расслабляетесь на мгновение.")))
	return
