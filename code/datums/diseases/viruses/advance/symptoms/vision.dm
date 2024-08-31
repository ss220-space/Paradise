/*
//////////////////////////////////////

Hyphema (Eye bleeding)

	Slightly noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity.
	Critical Level.

Bonus
	Causes blindness.

//////////////////////////////////////
*/

/datum/symptom/visionloss

	name = "Hyphema"
	id = "visionloss"
	stealth = -1
	resistance = -4
	stage_speed = -4
	transmittable = -3
	level = 5
	severity = 4

/datum/symptom/visionloss/Activate(datum/disease/virus/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		var/obj/item/organ/internal/eyes/eyes = M.get_int_organ(/obj/item/organ/internal/eyes)
		if(!eyes) //NO EYES, NO PROBLEM! Rip out your eyes today to prevent future blindness!
			return
		switch(A.stage)
			if(1, 2)
				to_chat(M, span_warning("Your eyes itch."))
			if(3, 4)
				to_chat(M, span_warning("<b>Your eyes burn!</b>"))
				M.EyeBlurry(40 SECONDS)
				eyes.internal_receive_damage(1)
			else
				to_chat(M, span_userdanger("Your eyes burn horrificly!"))
				M.EyeBlurry(60 SECONDS)
				eyes.internal_receive_damage(5)
				if(eyes.damage >= 10)
					if(!HAS_TRAIT_FROM(M, TRAIT_NEARSIGHTED, name))
						ADD_TRAIT(M, TRAIT_NEARSIGHTED, name)
						if(!HAS_TRAIT_NOT_FROM(M, TRAIT_NEARSIGHTED, name))
							M.update_nearsighted_effects()
					if(prob(eyes.damage - 10 + 1) && !HAS_TRAIT_FROM(M, TRAIT_BLIND, name))
						ADD_TRAIT(M, TRAIT_BLIND, name)
						if(!HAS_TRAIT_NOT_FROM(M, TRAIT_BLIND, name))
							M.update_blind_effects()
							to_chat(M, span_userdanger("You go blind!"))

