/**
 * Контроль коленом: граб, граб, харм, граб
 * Только по лежачей цели, наносит 50 урона стамине, берет цель в синий захват и наносит 30 окси урона.
 * Требует 5 уровень безоружного боя.
 */
/datum/martial_combo/uct/knee_on_belly
	name = "Контроль коленом"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Надавливание коленом по шее жертвы, позволяет контроллировать цель."

/datum/martial_combo/uct/knee_on_belly/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	. = MARTIAL_COMBO_FAIL
	if(!IS_HORIZONTAL(target))
		return

	var/old_grab_state = user.grab_state
	var/grabbed = target.grabbedby(user, supress_message = TRUE)
	if(grabbed && old_grab_state < GRAB_AGGRESSIVE)
		target.visible_message(span_warning("[user] сдавливает шею [target] коленом!"), \
							span_userdanger("[user] сдавливает вашу шею коленом!"))
		playsound(get_turf(user), 'sound/weapons/kolotushka_smash.ogg', 40, TRUE, -1)
		target.apply_damage(50, STAMINA)
		target.apply_damage(30, OXY)
		target.grippedby(user, grab_state_override = GRAB_AGGRESSIVE)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Контроль коленом", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
