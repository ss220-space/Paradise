/*
//////////////////////////////////////

Toxification syndrome

//////////////////////////////////////
*/

/datum/symptom/infection

	name = "Toxification syndrome"
	id = "infection"
	stealth = -1
	resistance = -3
	stage_speed = -4
	transmittable = -3
	level = 5
	severity = 5
	var/germs_multiplier = 1

/datum/symptom/infection/Start(datum/disease/virus/advance/A)
	var/mob/living/carbon/human/H = A.affected_mob
	if(istype(H))
		germs_multiplier = 6 + sqrtor0(25 + A.totalTransmittable()) //~~10 on average
		H.physiology.germs_growth_mod *= germs_multiplier

/datum/symptom/infection/Activate(datum/disease/virus/advance/A)
	..()
	var/mob/living/carbon/human/M = A.affected_mob

	if(prob(SYMPTOM_ACTIVATION_PROB*3))
		switch(A.stage)
			if(3, 4, 5)
				to_chat(M, span_warning(pick("You feel like something is not right within you",\
					"Why my inners start hurting?",\
					"Where did the pain come from?",\
					"I smell awful"\
				)))
				if(prob(10))
					M.emote("groan", "pale")
	if(prob((A.stage - 2) - M.count_infected_organs() / 4))
		var/obj/item/organ/organ = safepick(M.internal_organs + M.bodyparts)
		if(organ && organ.germ_level < INFECTION_LEVEL_ONE)
			organ.germ_level = INFECTION_LEVEL_ONE
	return

/datum/symptom/infection/End(datum/disease/virus/advance/A)
	var/mob/living/carbon/human/H = A.affected_mob
	if(germs_multiplier)
		H.physiology.germs_growth_mod /= germs_multiplier

