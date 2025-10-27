/datum/martial_combo/sleeping_carp/crashing_kick
	name = "Сокрушающий Волны Пинок"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Ты пинаешь оппонента прямо в торс, отправляя его в полёт."

/datum/martial_combo/sleeping_carp/crashing_kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target == user) // no you cannot kick yourself across rooms
		return MARTIAL_COMBO_DONE_BASIC_HIT
	user.do_attack_animation(target, ATTACK_EFFECT_KICK)
	target.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] пина[PLUR_ET_UT(user)] [target.declent_ru(ACCUSATIVE)] прямо в торс, отправляя [GEND_HIS_HER(target)] в полёт!"),
				span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] пинком в грудь отправляет тебя в полёт!"))
	playsound(target, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	target.throw_at(throw_target, 7, 14, user)
	target.apply_damage(15, BRUTE, BODY_ZONE_CHEST)
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Crashing Waves Kick", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
