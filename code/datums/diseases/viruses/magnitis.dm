/datum/disease/virus/magnitis
	name = "Магнитис"
	agent = "Фуккос Миракос"
	desc = "Эта болезнь нарушает магнитное поле вашего тела, заставляя его действовать как мощный магнит. Инъекции железа помогают стабилизировать поле."
	max_stages = 4
	visibility_flags = HIDDEN_HUD
	spread_flags = AIRBORNE
	cure_text = "Железо для живых, нанопаста для роботов"
	cures = list("iron")
	infectable_mobtypes = list(/mob/living/carbon/human, /mob/living/silicon/robot, /mob/living/simple_animal/pet/dog/corgi/borgi)
	ignore_immunity = TRUE
	permeability_mod = 0.75
	severity = MEDIUM

/datum/disease/virus/magnitis/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, span_danger("Вы чувствуете лёгкий разряд, проходящий через ваше тело."))
			if(prob(2))
				move_obj(2, 1)
				move_mobs(2, 1)
		if(3)
			if(prob(3))
				to_chat(affected_mob, span_danger("Вы чувствуете сильный разряд, проходящий через ваше тело."))
			if(prob(3))
				to_chat(affected_mob, span_danger("Вам хочется дурачиться."))
			if(prob(4))
				move_obj(4, rand(1, 2))
				move_mobs(4, rand(1, 2))
		if(4)
			if(prob(5))
				to_chat(affected_mob, span_danger("Вы чувствуете мощный разряд, проходящий через ваше тело."))
			if(prob(5))
				to_chat(affected_mob, span_danger("Вы размышляете о чудесах природы."))
			if(prob(8))
				move_obj(6, rand(1, 3))
				move_mobs(6, rand(1, 3))

/datum/disease/virus/magnitis/proc/move_obj(range, iter)
	playsound(get_turf(affected_mob.loc), 'sound/effects/magnitis.ogg', 100, 1)
	for(var/obj/M in orange(range, affected_mob))
		if(!M.anchored && (M.flags & CONDUCT))
			var/i
			for(i = 0, i < iter, i++)
				step_towards(M, affected_mob)

/datum/disease/virus/magnitis/proc/move_mobs(range, iter)
	for(var/mob/living/L in orange(range, affected_mob))
		if(istype(L, /mob/living/silicon/robot) || \
			istype(L, /mob/living/simple_animal/pet/dog/corgi/borgi) || \
			ismachineperson(L))

			var/i
			for(i = 0, i < iter, i++)
				step_towards(L, affected_mob)

//machinepersons cures with nanopaste, applied at any bodypart
/datum/disease/virus/magnitis/has_cure()
	return ismachineperson(affected_mob) ? FALSE : ..()


