/datum/martial_combo/judo/eyepoke
	name = "Удар по глазам"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Ударьте противника по глазам, ослепив его на короткое время. Противники с защитой глаз все равно пострадают."


/datum/martial_combo/judo/eyepoke/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	target.visible_message(span_warning("[user] бьёт [target] по глазам!"), \
						span_userdanger("[user] бьёт вас по глазам!"))
	playsound(get_turf(user), 'sound/weapons/whip.ogg', 40, TRUE, -1)
	target.apply_damage(10, BRUTE)
	target.AdjustEyeBlurry(50, 0, 30 SECONDS)
	target.EyeBlind(2 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Удар по глазам", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
