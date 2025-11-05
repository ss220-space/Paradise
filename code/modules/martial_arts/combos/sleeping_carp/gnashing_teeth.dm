/datum/martial_combo/sleeping_carp/gnashing_teeth
	name = "Скрежет Зубов"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Каждый твой второй последовательный удар наносит дополнительный урон."

/datum/martial_combo/sleeping_carp/gnashing_teeth/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target == user)
		return MARTIAL_COMBO_DONE_BASIC_HIT
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("с силой пина[PLUR_ET_YUT(user)]", "жестоко руб[PLUR_IT_YAT(user)]", "сильно бь[PLUR_YOT_YUT(user)]")
	target.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] [atk_verb] [target.declent_ru(ACCUSATIVE)]!"),
					span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] [atk_verb] тебя!"))
	playsound(get_turf(target), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Gnashing Teeth", ATKLOG_ALL)
	target.apply_damage(20, BRUTE, user.zone_selected, sharp = TRUE)
	if(target.health >= 0)
		user.say(pick("ХУ+АХ", "ХЬЯ!", "Ч+УУ!", "ВУ+О!", "КЬЯ!", "ХА!", "ХЬЁХ!", "УД+АР К+АРПА!", "УК+УС К+АРПА!"))
	else
		user.say(pick("БАНЗ+АААЙ!", "КЬ+ЯЯЯ!", "ТЫ УЖЕ МЁРТВ!", "СЛАДКИХ СНОВ!", "УВИДИМСЯ НА ТОЙ СТОРОНЕ!"))
	return MARTIAL_COMBO_DONE
