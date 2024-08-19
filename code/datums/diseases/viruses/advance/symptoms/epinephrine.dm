/*
//////////////////////////////////////

Inotropical hyperfunction
	Lowers stealth
	Lowers resistance.
	Decreases stage speed slightly.
	Decreases transmittablity.
	Fatal Level.

Bonus
	The body generates epinephrine at low health slowly overdosing host

//////////////////////////////////////
*/

/datum/symptom/epinephrine

	name = "Inotropical Hyperfunction"
	id = "epinephrine"
	stealth = -5
	resistance = -4
	stage_speed = -1
	transmittable = -2
	level = 5

/datum/symptom/epinephrine/Activate(datum/disease/virus/advance/A)
	..()
	var/mob/living/M = A.affected_mob
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		switch(A.stage)
			if(5)
				if(prob(10))
					to_chat(M, span_notice(pick("Your body feels tough.", "You are feeling on edge.")))
	if(A.stage > 4 && M.health <= HEALTH_THRESHOLD_CRIT)
		M.reagents.add_reagent("epinephrine", 0.5)
	if(M.reagents.get_reagent_amount("epinephrine") > 20)
		var/obj/item/organ/internal/heart/heart = M.get_int_organ(/obj/item/organ/internal/heart)
		heart?.internal_receive_damage(1)
	return
