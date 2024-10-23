/datum/martial_combo/sleeping_carp/elbow_drop
	name = "Elbow Drop"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Вы прыгаете на оппонента локтём ударяя по спине. Нанося приличный урон, и если враг в критическом состоянии - мгновенно убиваете его."

/datum/martial_combo/sleeping_carp/elbow_drop/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.body_position == LYING_DOWN)
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		target.visible_message("<span class='warning'>[user] ударяет локтем [target]!</span>", \
						  "<span class='userdanger'>[user] piledrives you with [user.p_their()] elbow!</span>")
		if(target.health <= HEALTH_THRESHOLD_CRIT)
			target.death() //FINISH HIM!
		target.apply_damage(50, BRUTE, "chest")
		objective_damage(user, target, 50, BRUTE)
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 75, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Elbow Drop", ATKLOG_ALL)
		if(prob(80))
			user.say(pick("БАНЗАЙ!", "КИЯЯЯЯ!", "Я ХОЧУ ПИЦЦЫ!", "ТЫ МЕНЯ НЕ УВИДИШЬ!", "МОЕ ВРЕМЯ СЕЙЧАС!", "КОВАБАНГА!"))
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
