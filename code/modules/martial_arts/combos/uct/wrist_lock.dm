/**
 * Скручивание кисти: дизарм, граб, дизарм
 * Выбивает оружие с рук, наносит по 5 брут урона нацеленной или случайной кисти.
 * Требует 3 уровень безоружного боя.
 */
/datum/martial_combo/uct/wrist_lock
	name = "Скручивание кисти"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Выкручивает кисть жертвы и выбивает оружие с рук."

/datum/martial_combo/uct/wrist_lock/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	target.visible_message(span_warning("[user] выкручивает кисть [target]!"), \
						span_userdanger("[user] выкручивает вашу кисть!"))

	playsound(get_turf(user), 'sound/weapons/throwhard.ogg', 40, TRUE, -1)
	target.drop_l_hand()
	target.drop_r_hand()
	target.apply_damage(5, BRUTE, def_zone = BODY_ZONE_PRECISE_L_HAND)
	target.apply_damage(5, BRUTE, def_zone = BODY_ZONE_PRECISE_R_HAND)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Скручивание кисти", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
