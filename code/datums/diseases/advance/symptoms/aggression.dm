/*
//////////////////////////////////////

Uncontrollable Aggression

//////////////////////////////////////
*/

/datum/symptom/aggression

	name = "Uncontrollable Aggression"
	id = "aggression"
	stealth = -4
	resistance = 2
	stage_speed = -3
	transmittable = 1
	level = 6

/datum/symptom/aggression/Activate(datum/disease/advance/A)
	..()
	var/mob/living/carbon/human/aggressor = A.affected_mob
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		switch(A.stage)
			if(2, 3)
				to_chat(aggressor, "<span class='danger'>[pick("че", "надо", "блять")]</span>")
			if(4)
				to_chat(aggressor, "<span class='danger'>[pick("я", "люблю", "вульп")]</span>")
			if(5)
				if(aggressor.incapacitated())
					aggressor.visible_message("<span class='danger'>[aggressor] spasms and twitches!</span>")
					return
				aggressor.visible_message("<span class='danger'>[aggressor] thrashes around violently!</span>")
				if(aggressor.get_item_by_slot(slot_l_hand))
					return
				for(var/mob/living/carbon/human/H in range(1, aggressor))
					if(aggressor == H)
						continue
					aggressor.dna.species.harm(aggressor, H)
					break
	return
