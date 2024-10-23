/datum/martial_combo/sleeping_carp/head_kick
	name = "Head Kick"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Пинает оппонента в голову, нанося приличный урон и заставляя выбросить вещь из активной руки."

/datum/martial_combo/sleeping_carp/head_kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		target.visible_message("<span class='warning'>[user] бьет [target] в голову!</span>", \
						  "<span class='userdanger'>[user] бьет вас ногой в челюсть!</span>")
		target.apply_damage(20, BRUTE, "head")
		objective_damage(user, target, 20, BRUTE)
		target.drop_from_active_hand()
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 50, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Head Kick", ATKLOG_ALL)
		if(prob(60))
			user.say(pick("УАХУААА!", "КИЯ!", "БИИИЯ!", "ПЛАВНИКОМ В ЛИЦО!", "УКУС В ГОЛОВУ!", "УДАР ПО ГОООЛОВЕ!"))
		target.Weaken(6 SECONDS)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
