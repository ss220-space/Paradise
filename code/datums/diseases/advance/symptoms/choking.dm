/*
//////////////////////////////////////

Choking

	Very very noticable.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity tremendously.
	Moderate Level.

Bonus
	Inflicts spikes of oxyloss

//////////////////////////////////////
*/

/datum/symptom/choking

	name = "Удушье"
	stealth = -3
	resistance = -2
	stage_speed = -2
	transmittable = -4
	level = 3
	severity = 3

/datum/symptom/choking/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				to_chat(M, "<span class='warning'>[pick("Вам становится трудно дышать.", "Ваше дыхание тяжелеет.")]</span>")
			if(3, 4)
				to_chat(M, "<span class='warning'><b>[pick("Кажется, воздух просто не успевает попадать вам в лёгкие.", "Вам становится очень трудно дышать.")]</span>")
				Choke_stage_3_4(M, A)
				M.emote("gasp")
			else
				to_chat(M, "<span class='userdanger'>[pick("Вы задыхаетесь!", "Вы не можете дышать!")]</span>")
				Choke(M, A)
				M.emote("gasp")
	return

/datum/symptom/choking/proc/Choke_stage_3_4(mob/living/M, datum/disease/advance/A)
	var/get_damage = sqrtor0(21+A.totalStageSpeed()*0.5)+sqrtor0(16+A.totalStealth())
	M.adjustOxyLoss(get_damage)
	return 1

/datum/symptom/choking/proc/Choke(mob/living/M, datum/disease/advance/A)
	var/get_damage = sqrtor0(21+A.totalStageSpeed()*0.5)+sqrtor0(16+A.totalStealth()*5)
	M.adjustOxyLoss(get_damage)
	return 1
