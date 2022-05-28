//TODO: ПЕРЕНЕСТИ КАК АБИЛКУ
/datum/martial_combo/plasma_fist/plasma_breath
	name = "Плазмо-дыхание"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HELP)
	explaination_text = "Выдывливает воздух из лёгких, заменяя её плазмой и заставляя её изрыгнуть!"

/datum/martial_combo/plasma_fist/plasma_breath/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='danger'>[user] отбрасыва[pluralize_ru(user.gender,"ет","ют")] [target] плазменным толчком!</span>", \
								"<span class='userdanger'>[user] отбрасыва[pluralize_ru(user.gender,"ет","ют")] вас плазменным толчком, приводя в замешательство!</span>")
	playsound(target.loc, 'sound/weapons/resonator_fire.ogg', 50, 1, -1)
	if (prob(50)) //с 50% шансом выдаст фразу
		user.say(pick("ПЛАЗМЕННОЕ ДЫХАНИЕ!", "ЗАПАХ ПЛАЗМЫ!", "ВЫПУСТИ ПЛАЗМУ!", "ПУСТИ ДУХ ПЛАЗМЫ!", "НЕ ДЕРЖИ В СЕБЕ ПЛАЗМУ!", "ЛЁГКАЯ ПЛАЗМА!", "ПЛАЗМА В ЛЁГКИХ!"))

	var/turf/simulated/target_turf = get_turf(target)
	if(istype(target_turf))
		var/spawn_contents = LINDA_SPAWN_TOXINS //| LINDA_SPAWN_HEAT
		var/spawn_amount = rand(15,30)
		target_turf.atmos_spawn_air(spawn_contents, spawn_amount)
		target_turf.air_update_turf()

	target.LoseBreath(5)	 //потеря дыхания
	target.Jitter(5)		 //дрожь
	target.adjustToxLoss(60) //получение токсинов. Плазмаменам повезло.
	target.apply_damage(60, OXY)
	user.say("ХЬЙА!")
	return MARTIAL_COMBO_DONE
