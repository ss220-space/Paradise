/datum/martial_combo/plasma_fist/plasma_fist
	name = "Плазменный кулак"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Выбивает мозги из оппонента, разрывая его тело на части, если он он достаточно поражен и прожжен."

/datum/martial_combo/plasma_fist/plasma_fist/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if (target.health <= HEALTH_THRESHOLD_CRIT && target.getFireLoss() >= 100)
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		//playsound(target.loc, 'sound/weapons/blastcannon.ogg', 20, 1, -1, 15) //звук взрыва при вышибании
		playsound(target.loc, 'sound/weapons/resonator_blast.ogg', 50, 1, -1, 35)
		user.say("ПЛАЗМЕННЫЙ КУЛАК!")
		target.visible_message("<span class='danger'>[user] аннигилиру[pluralize_ru(user.gender,"ет","ют")] [target] ТЕХНИКОЙ ПЛАЗМЕННОГО КУЛАКА, разрывая на части!</span>", \
								"<span class='userdanger'>[user] аннигилиру[pluralize_ru(user.gender,"ет","ют")] вас ТЕХНИКОЙ ПЛАЗМЕННОГО КУЛАКА, разрывая на части!</span>")
		target.gib()
	//если условия комбинации не были достигнуты, nо поджигает цель
	else
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		playsound(target.loc, 'sound/weapons/sear.ogg', 50, 1, -1, 5)
		user.say("ПЫЛАЙ ЯРКО!")
		target.visible_message("<span class='danger'>[user] поджига[pluralize_ru(user.gender,"ет","ют")] [target] ТЕХНИКОЙ ПЛАЗМЕННОГО КУЛАКА!</span>", \
								"<span class='userdanger'>[user] поджига[pluralize_ru(user.gender,"ет","ют")] вас ТЕХНИКОЙ ПЛАЗМЕННОГО КУЛАКА!</span>")
		target.adjust_fire_stacks(20)
		target.IgniteMob()

	return MARTIAL_COMBO_DONE
