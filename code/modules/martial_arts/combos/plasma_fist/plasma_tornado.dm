//TODO: ПЕРЕНЕСТИ КАК АБИЛКУ
/datum/martial_combo/plasma_fist/plasma_tornado
	name = "Плазма-торнадо"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Распыляет плазму вокруг, поджигая всех кто находится рядом. Прием требующий мастерства."

/datum/martial_combo/plasma_fist/plasma_tornado/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.say("ПЛАЗМЕННЫЙ ВИХРЬ!")
	INVOKE_ASYNC(src, .proc/do_tornado_effect, user)

	var/list/turfs = list()
	var/list/thrownatoms = list()
	var/spawn_contents = LINDA_SPAWN_TOXINS //| LINDA_SPAWN_HEAT
	var/spawn_amount = rand(10,20)
	var/count_spawn = 0		//избегаем абуза получаемого при получении слишком большого числа объектов + ослабевание торнадо
	for(var/turf/T in range(1,user))
		turfs.Add(T)
		for(var/atom/movable/AM in T)
			thrownatoms += AM
		//создаем плазму
		var/turf/simulated/target_turf = T
		if(istype(target_turf) && count_spawn <= spawn_amount)
			count_spawn++
			target_turf.atmos_spawn_air(spawn_contents, (spawn_amount - count_spawn))
			target_turf.air_update_turf()

	for(var/atom/movable/AM as anything in thrownatoms)
		if(isliving(AM))
			var/mob/living/target_live = AM
			if (target_live != user && !target.mind?.martial_art?.fire_resistance)	//мы же не хотим тоже получить дебафы
				target_live.adjustToxLoss(30) //получение немного токсинов
				target_live.Jitter(30)		//дрожь
				target_live.adjust_fire_stacks(20)
				target_live.IgniteMob()		//поджег

	var/obj/effect/proc_holder/spell/aoe_turf/repulse/R = new(null)
	R.cast(turfs)
	return MARTIAL_COMBO_DONE

/datum/martial_combo/plasma_fist/plasma_tornado/proc/do_tornado_effect(mob/living/carbon/human/user)
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		user.dir = i
		playsound(user.loc, 'sound/weapons/resonator_blast.ogg', 25, 1, -1)
		sleep(1)
