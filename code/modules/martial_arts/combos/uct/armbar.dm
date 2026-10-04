/**
 * Загиб руки за спину: граб, дизарм, граб, харм
 * Обезоруживает цель (обе руки) и берет его сразу в красный захват
 * Требует 6 уровень безоружного боя.
 */
/datum/martial_combo/uct/armbar
	name = "Загиб руки за спину"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Выкрутить руку жертвы за спину и взять цель в болевой захват."

/datum/martial_combo/uct/armbar/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	target.visible_message(span_warning("[user] выкручивает руку [target] за спину!"), \
						span_userdanger("[user] выкручивает вашу руку за спину!"))

	var/old_grab_state = user.grab_state
	var/grabbed = target.grabbedby(user, supress_message = TRUE)
	if(grabbed && old_grab_state < GRAB_NECK)
		playsound(get_turf(user), 'sound/weapons/grab_mimejutsu.ogg', 40, TRUE, -1)
		target.drop_l_hand()
		target.drop_r_hand()
		target.grippedby(user, grab_state_override = GRAB_NECK)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Загиб руки за спину", ATKLOG_ALL)

	return MARTIAL_COMBO_DONE
