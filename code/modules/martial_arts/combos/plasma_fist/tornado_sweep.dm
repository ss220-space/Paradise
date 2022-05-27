/datum/martial_combo/plasma_fist/tornado_sweep
	name = "Вихрь торнадо"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Раскидывает всех кто находится рядом."

/datum/martial_combo/plasma_fist/tornado_sweep/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.say("ТОРНАДО-ЗАКРУТКА!")
	INVOKE_ASYNC(src, .proc/do_tornado_effect, user)
	var/obj/effect/proc_holder/spell/aoe_turf/repulse/R = new(null)

	var/list/turfs = list()
	var/list/thrownatoms = list()
	for(var/turf/T in range(1,user))
		turfs.Add(T)
		for(var/atom/movable/AM in T)
			thrownatoms += AM

	for(var/am in thrownatoms)
		var/atom/movable/AM = am
		if(isliving(AM))
			var/mob/living/M = AM
			if (M != user)	//мы же не хотим тоже получить дебафы
				M.LoseBreath(3)	//временная потеря дыхания
				M.Jitter(10)	//дрожь

	R.cast(turfs)
	return MARTIAL_COMBO_DONE

/datum/martial_combo/plasma_fist/tornado_sweep/proc/do_tornado_effect(mob/living/carbon/human/user)
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		user.dir = i
		playsound(user.loc, 'sound/weapons/resonator_blast.ogg', 25, 1, -1)
		sleep(1)
