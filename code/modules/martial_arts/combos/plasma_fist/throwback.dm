/datum/martial_combo/plasma_fist/throwback
	name = "Полёт плазмы"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Отбрасывает цель далеко вперед, приводя его в замешательство"

/datum/martial_combo/plasma_fist/throwback/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='danger'>[user] отбрасыва[pluralize_ru(user.gender,"ет","ют")] [target] плазменным толчком!</span>", \
								"<span class='userdanger'>[user] отбрасыва[pluralize_ru(user.gender,"ет","ют")] вас плазменным толчком, приводя в замешательство!</span>")
	//playsound(target.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	playsound(target.loc, 'sound/weapons/plasma_cutter.ogg', 50, 1, -1)
	if (prob(50)) //с 50% шансом выдаст фразу
		user.say(pick("ПЛАЗМЕННЫЙ ТОЛЧОК!", "СДУВАНИЕ ПЛАЗМЫ!", "ПОЛЁТ ПЛАЗМЫ!"))
	else
		user.say("ХЬЙА!")
	var/atom/throw_target = get_edge_target_turf(target, get_dir(target, get_step_away(target, user)))
	target.throw_at(throw_target, 10, 4, user) //отбрасывание на 10 тайлов
	target.LoseBreath(2)	//потеря дыхания
	target.Jitter(15)		//дрожь
	target.apply_damage(40, OXY)
	return MARTIAL_COMBO_DONE
