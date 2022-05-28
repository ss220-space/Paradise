/datum/martial_combo/plasma_fist/plasma_fist
	name = "Плазменный кулак"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Выбивает мозги из оппонента, разрывая его тело на части, если он достаточно поражен и прожжен. Иначе он будет контужен!"
	combo_text_override = "Harm, Disarm, Disarm, Disarm, Grab, switch hands, Harm"

/datum/martial_combo/plasma_fist/plasma_fist/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if (target.health <= HEALTH_THRESHOLD_CRIT && target.getFireLoss() >= 100 && target.get_organ("head"))
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		//playsound(target.loc, 'sound/weapons/blastcannon.ogg', 20, 1, -1, 15) //звук взрыва при вышибании
		playsound(user.loc, 'sound/weapons/resonator_blast.ogg', 50, 1, -1, 35)
		user.say(pick("ПЛАЗМЕННЫЙ КУЛАК!", "ДЫХАНИЕ ПЛАЗМЫ!", "АННИГИЛЯТОРНАЯ ПЛАЗМА!", "И ТОЛЬКО ПЛАЗМА ПО СТЕНАМ!"))
		target.visible_message("<span class='danger'>[user] аннигилиру[pluralize_ru(user.gender,"ет","ют")] [target] ТЕХНИКОЙ ПЛАЗМЕННОГО КУЛАКА, разрывая на части!</span>", \
								"<span class='userdanger'>[user] аннигилиру[pluralize_ru(user.gender,"ет","ют")] вас ТЕХНИКОЙ ПЛАЗМЕННОГО КУЛАКА, разрывая на части!</span>")

		playsound(target.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)

		//вышибаем мозги и прочие внутренние органы в голове
		var/obj/item/organ/external/head/head_organ = target.get_organ("head")
		head_organ.droplimb(0, DROPLIMB_SHARP)
		head_organ.drop_organs()
		gibs(target.loc, target.dna) //с сохранением ДНК
	//если условия комбинации не были достигнуты, nо поджигает цель
	else
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		playsound(user.loc, 'sound/weapons/resonator_blast.ogg', 50, 1, -1, 35)
		user.say(pick("ГОЛОВНАЯ БОЛЬ!", "ПЛАЗМЕННЫЙ ВНУТРЕННИЙ ВЗРЫВ!", "ВЗРЫВ ИЗНУТРИ!", "ВСПЫШКА В ЧЕРЕПУШКЕ!", "ВНУТРЕННЕЕ ДАВЛЕНИЕ!"))
		target.visible_message("<span class='danger'>[user] нанос[pluralize_ru(user.gender,"ит","ят")] сокрушительный удар в голову [target] ТЕХНИКОЙ ПЛАЗМЕННОГО КУЛАКА! Его голову перекосило...</span>", \
								"<span class='userdanger'>[user] нанос[pluralize_ru(user.gender,"ит","ят")] вам сокрушительный удар в голову ТЕХНИКОЙ ПЛАЗМЕННОГО КУЛАКА! Ваша голова только что чуть не взорвалась!</span>")
		target.LoseBreath(4)		//потеря дыхания
		target.AdjustEyeBlind(3) 	//потеря зрения
		target.AdjustEyeBlurry(16)	//блюр зрения
		target.Jitter(25)			//дрожь
		target.AdjustConfused(8)	//потерянность (ходьба в разные стороны)
		target.AdjustSlowed(12)		//замедление
		target.adjust_fire_stacks(5)	//мгновенная вспышка на секунду
		target.IgniteMob()				//поджигаем

	return MARTIAL_COMBO_DONE
