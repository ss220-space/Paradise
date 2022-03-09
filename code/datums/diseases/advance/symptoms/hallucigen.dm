/*
//////////////////////////////////////

Hallucigen

	Very noticable.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittable.
	Critical Level.

Bonus
	Makes the affected mob be hallucinated for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/hallucigen

	name = "Галлюциноген"
	stealth = -2
	resistance = -3
	stage_speed = -3
	transmittable = -1
	level = 5
	severity = 3

/datum/symptom/hallucigen/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				to_chat(M, "<span class='warning'>[pick("Что-то мелькает на границе вашего периферийного зрения, и сразу исчезает.", "Вы слышите лёгкий шёпот из неопределённого источника.", "У вас болит голова.")]</span>")
			if(3, 4)
				to_chat(M, "<span class='warning'><b>[pick("Кто-то вас преследует.", "За вами следят.", "Вы слышите шёпот прямо над ухом.", "К вам приближаются громкие шаги непонятно с какой стороны.")]</b></span>")
			else
				to_chat(M, "<span class='userdanger'>[pick("Он уже здесь…", "Голова наливается тяжестью.", "Они везде! Бегите!", "Оно там… в темноте…")]</span>")
				M.AdjustHallucinate(5)

	return
