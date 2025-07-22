/datum/martial_combo/judo/wheelthrow
	name = "Бросок через себя"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Перекиньте взятого на болевой приём противника через плечо или прижмите его к полу. \
						Если противник ранее не был взят на болевой, этот приём не сработает!"


/datum/martial_combo/judo/wheelthrow/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	if(!IS_HORIZONTAL(target) || !target.has_status_effect(STATUS_EFFECT_ARMBAR))
		return MARTIAL_COMBO_FAIL

	if(!IS_HORIZONTAL(user))
		target.visible_message(span_warning("[user] перекидывает [target] через плечо и бросает на пол!"), \
								span_userdanger("[user] перекидывает вас через плечо и бросает на пол!"))
		playsound(get_turf(user), 'sound/magic/tail_swing.ogg', 40, TRUE, -1)
		target.SpinAnimation(10, 1)
	else
		target.visible_message(span_warning("[user] хватает [target], и прижимает к полу!"), \
								span_userdanger("[user] хватает вас и прижимает к полу!"))
		playsound(get_turf(user), 'sound/weapons/slam.ogg', 40, TRUE, -1)

	target.apply_damage(120, STAMINA)
	target.Knockdown(15 SECONDS)
	target.SetConfused(10 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Бросок через себя", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
