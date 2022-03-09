/*
//////////////////////////////////////

Spontaneous Combustion

	Slightly hidden.
	Lowers resistance tremendously.
	Decreases stage tremendously.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	Ignites infected mob.

//////////////////////////////////////
*/

/datum/symptom/fire

	name = "Самовозгорание"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6
	severity = 5

/datum/symptom/fire/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(3)
				to_chat(M, "<span class='warning'>[pick("Вы чувствуете жар.", "У вас жар.", "Вы слышите потрескивающие звуки.", "Вы чувствуете запах дыма.")]</span>")
			if(4)
				Firestacks_stage_4(M, A)
				M.IgniteMob()
				to_chat(M, "<span class='userdanger'>Ваша кожа вспыхивает пламенем!</span>")
				M.emote("scream")
			if(5)
				Firestacks_stage_5(M, A)
				M.IgniteMob()
				to_chat(M, "<span class='userdanger'>Ваша кожа будто покрывается лавой!</span>")
				M.emote("scream")
	return

/datum/symptom/fire/proc/Firestacks_stage_4(mob/living/M, datum/disease/advance/A)
	var/get_stacks = max((sqrtor0(20 + A.totalStageSpeed() * 2)) - (sqrtor0(16 + A.totalStealth())), 1)
	M.adjust_fire_stacks(get_stacks)
	M.adjustFireLoss(get_stacks * 0.5)
	return 1

/datum/symptom/fire/proc/Firestacks_stage_5(mob/living/M, datum/disease/advance/A)
	var/get_stacks = max((sqrtor0(20 + A.totalStageSpeed() * 3))-(sqrtor0(16 + A.totalStealth())), 1)
	M.adjust_fire_stacks(get_stacks)
	M.adjustFireLoss(get_stacks)
	return 1
