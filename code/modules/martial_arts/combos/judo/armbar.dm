/datum/martial_combo/judo/armbar
	name = "Болевой"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Возьмите сбитого с ног противника в болевой захват, обезоружив его."


/datum/martial_combo/judo/armbar/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	if(!IS_HORIZONTAL(target))
		return MARTIAL_COMBO_FAIL

	target.visible_message(span_warning("[user] проводит приём, в результате которого [target] оказывается в болевом захвате!"), \
							span_userdanger("[user] берёт вас на болевой!"))

	playsound(get_turf(user), 'sound/weapons/slashmiss.ogg', 40, TRUE, -1)
	if(!IS_HORIZONTAL(user))
		target.drop_l_hand()
		target.drop_r_hand()

	target.apply_damage(45, STAMINA)
	target.apply_status_effect(STATUS_EFFECT_ARMBAR)
	target.Knockdown(5 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Болевой", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
