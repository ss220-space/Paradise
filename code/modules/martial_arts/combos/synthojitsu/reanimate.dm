/datum/martial_combo/synthojitsu/reanimate
	name = "Реанимировать"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HELP)
	explaination_text = "Перезапускает сердце ударом тока. Использовать с осторожностью."

/datum/martial_combo/synthojitsu/reanimate/perform_combo(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/MA)
	if(target.stat == DEAD)
		to_chat(user, "<span class='danger'>[target] никак не реагирует!</span>")
		return MARTIAL_COMBO_FAIL
	if(target.undergoing_cardiac_arrest())
		to_chat(user, "<span class='notice'>[target] глубоко вдохнул[genderize_ru(user.gender,"","а","о","и")]!</span>")
		target.adjustOxyLoss(-100)
		target.set_heartattack(FALSE)
		user.adjust_nutrition(-75)
		target.shock_internal_organs(100)
		target.visible_message("<span class='warning'>[user] ударил[genderize_ru(user.gender,"","а","о","и")] током [target]!</span>", \
				"<span class='userdanger'>[user] ударил[genderize_ru(user.gender,"","а","о","и")] вас током!</span>")
		playsound(get_turf(user), 'sound/weapons/egloves.ogg', 50, 1, -1)
		target.apply_damage(10, BURN)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : defib", ATKLOG_ALL)
		. = MARTIAL_COMBO_DONE
	else
		to_chat(user, "<span class='notice'>[target] не требует ударом тока. Прервано...</span>")
		return MARTIAL_COMBO_FAIL
