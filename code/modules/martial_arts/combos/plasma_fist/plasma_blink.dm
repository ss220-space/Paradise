/datum/martial_combo/plasma_fist/plasma_blink
	name = "Вспышка плазмы"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Наносит ослепительный плазменный удар кулаком в глаза, приводя цель в замешательство"

/datum/martial_combo/plasma_fist/plasma_blink/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	playsound(target.loc, 'sound/weapons/sear.ogg', 50, 1, -1, 5)
	user.say(pick("ПЫЛАЙ ЯРКО!", "ВСПЫШКА!", "ЯРЧЕ ПЛАМЕНИ!", "ПОСМОТРИ НА ГОРЯЩУЮ ПЛАЗМУ!", "ПРОМОРГАЙСЯ!"))
	target.visible_message("<span class='danger'>[user] отслепительно бь[pluralize_ru(user.gender,"ет","ют")] плазменным ударом в глаза [target]!</span>", \
								"<span class='userdanger'>[user] ослепительно бь[pluralize_ru(user.gender,"ет","ют")] вас плазменным ударом в глаза! Ваши глаза горят, вы в замещательстве!</span>")
	target.AdjustEyeBlind(8) 	//потеря зрения
	target.AdjustEyeBlurry(30)	//блюр зрения
	target.Jitter(30)			//дрожь
	target.AdjustSlowed(5)		//замедление
	target.AdjustConfused(15)	//потерянность (ходьба в разные стороны)
	target.adjust_fire_stacks(20)	//стаки для поджигания на 2-3 кувырка
	target.IgniteMob()				//поджигаем
	user.say("ХЬЙА!")
	return MARTIAL_COMBO_DONE
