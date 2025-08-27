/datum/martial_combo/judo/judothrow
	name = "Бросок"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Схватите противника и бросьте его на пол, нанося урон выносливости."


/datum/martial_combo/judo/judothrow/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	if(IS_HORIZONTAL(user) || IS_HORIZONTAL(target))
		return MARTIAL_COMBO_FAIL

	target.visible_message(span_warning("[user] бросает [target] на пол!"), \
						span_userdanger("[user] бросает вас на пол!"))
	playsound(get_turf(user), 'sound/weapons/slam.ogg', 40, TRUE, -1)
	target.apply_damage(25, STAMINA)
	target.Knockdown(7 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Бросок", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
