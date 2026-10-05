/**
 * Дробилка: дизарм, граб, харм, граб, харм
 * Ломает (вешает закрытый перелом, если уже есть перелом закрытый — усугубляет его до открытого) нацеленную конечность (руки, ноги, пятки, кисти).
 * Если выбрана другая часть тела — ломает случайную из конечностей.
 * Требует 7 уровень безоружного боя.
 */
/datum/martial_combo/uct/leg_slicer
	name = "Дробилка"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Ломает выбранную конечность жертвы."

/datum/martial_combo/uct/leg_slicer/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	var/static/list/valid_zones = list(
		BODY_ZONE_L_ARM, BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG, BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT,
	)
	target.visible_message(span_warning("[user] ломает конечность [target]!"), \
						span_userdanger("[user] ломает вашу конечность!"))

	var/selected_zone = user.zone_selected
	if(!(selected_zone in valid_zones))
		selected_zone = pick(valid_zones)
	var/obj/item/organ/external/affected = target.get_organ(selected_zone)
	if(affected.has_fracture() && affected.fracture == FRACTURE_TYPE_OPEN)
		// already open fracture, randomize
		selected_zone = pick(valid_zones)
		affected = target.get_organ(selected_zone)

	var/fracture_type = FRACTURE_TYPE_CLOSED
	if(affected.has_fracture() && affected.fracture == FRACTURE_TYPE_CLOSED)
		fracture_type = FRACTURE_TYPE_OPEN

	if(affected.fracture(FALSE, fracture_type))
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
	else
		target.apply_damage(40, BRUTE, selected_zone)
		objective_damage(user, target, 40, BRUTE)
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)

	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Дробилка", ATKLOG_ALL)
	playsound(get_turf(user), 'sound/weapons/blunthit_mimejutsu.ogg', 10, TRUE, -1)
	return MARTIAL_COMBO_DONE
