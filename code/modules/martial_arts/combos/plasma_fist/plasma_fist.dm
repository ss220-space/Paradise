/datum/martial_combo/plasma_fist/plasma_fist
	name = "Плазменный Кулак"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Выбивает мозги из оппонента, разрывая его тело на части."

/datum/martial_combo/plasma_fist/plasma_fist/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	playsound(target.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	user.say("ПЛАЗМЕННЫЙ КУЛАК!")
	target.visible_message("<span class='danger'>[user] поразил[genderize_ru(user.gender,"","а","о","и")] [target] ТЕХНИКОЙ ПЛАЗМЕННОГО КУЛАКА!</span>", \
								"<span class='userdanger'>[user] поразил[genderize_ru(user.gender,"","а","о","и")] [target] ТЕХНИКОЙ ПЛАЗМЕННОГО КУЛАКА!</span>")
	target.gib()
	return MARTIAL_COMBO_DONE
