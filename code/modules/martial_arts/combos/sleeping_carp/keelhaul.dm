/datum/martial_combo/sleeping_carp/keelhaul
	name = "Килхаул"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Ты прибиваешь оппонента к полу, дополнительно нанося урон по стамине!"

/datum/martial_combo/sleeping_carp/keelhaul/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target == user)
		return MARTIAL_COMBO_DONE_BASIC_HIT
	user.do_attack_animation(target, ATTACK_EFFECT_KICK)
	playsound(get_turf(target), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	if(!IS_HORIZONTAL(target))
		target.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
		target.Knockdown(6 SECONDS)
		target.visible_message(span_warning("Ударом в голову, [user.declent_ru(NOMINATIVE)] прибива[PLUR_ET_YUT(user)] [target.declent_ru(ACCUSATIVE)] к полу!"),
						span_userdanger("Вас сбили с ног!"))
	else
		target.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
		target.drop_l_hand()
		target.drop_r_hand()
		target.visible_message(span_warning("[DECLENT_RU_CAP(user, NOMINATIVE)] бь[PLUR_YOT_YUT(user)] [target.declent_ru(ACCUSATIVE)] в голову, оставляя корчиться от боли!"),
							span_userdanger("Вы корчитесь от боли из-за пинка в голову!"))
	target.apply_damage(60, STAMINA)
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Keelhaul", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
