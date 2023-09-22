/*
//////////////////////////////////////

Fragile Bones Syndrome

//////////////////////////////////////
*/

/datum/symptom/bones

	name = "Fragile Bones Syndrome"
	id = "bones"
	stealth = -3
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6
	severity = 5
	var/bonefragility_multiplier = 2
	var/fragile_bones_chance = 3
	var/done = FALSE

/datum/symptom/bones/Activate(datum/disease/advance/A)
	..()
	var/mob/living/carbon/human/M = A.affected_mob
	if(prob(SYMPTOM_ACTIVATION_PROB * 4))
		switch(A.stage)
			if(1, 2)
				to_chat(M, span_warning(pick("You hear, that something crunches",\
						"It seems that something crunched",\
						"Some bad feeling in the [pick("leg","foot","arm","hand","shoulder","spine","neck")]",\
						"It seems that my finger bent abnormally",\
						span_italics("crunch..."))))

			if(3,4)
				switch(rand(1, 3))
					if(1)
						playsound(M, "bonebreak", 15, 1)
						M.visible_message(span_warning("You seem to hear a crunching sound from [M]"),\
								span_warning("You hear, that something crunches inside you!"))
					if(2)
						to_chat(M, span_warning("You feel terrible pain in your [pick("leg","foot","arm","hand","shoulder","spine","neck")]"))
					if(3)
						M.Slowed(1 SECONDS)
						M.visible_message(span_warning("[M] is limping"), span_warning("Your leg doesn't hold its shape at all!"))

			if(5)
				switch(rand(1, 2))
					if(1)
						to_chat(M, span_danger(pick("You feel like your body is crumbling!",\
							"Something crunched loudly",\
							"You feel terrible pain in your [pick("leg","foot","arm","hand","shoulder","spine","neck")]",\
							"It's like you're spreading out on the floor")))
					if(2)
						playsound(M, "bonebreak", 50, 1)
						M.visible_message(span_userdanger(span_italics("CRUNCH")))

				if(!done)
					M.dna.species.bonefragility *= bonefragility_multiplier
					M.dna.species.fragile_bones_chance += fragile_bones_chance
					done = TRUE

	return

/datum/symptom/bones/End(datum/disease/advance/A)
	var/mob/living/carbon/human/M = A.affected_mob
	M.dna.species.bonefragility /= bonefragility_multiplier
	M.dna.species.fragile_bones_chance -= fragile_bones_chance
