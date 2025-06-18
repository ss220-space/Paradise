/datum/martial_combo/judo/goldenblast
	// This is incredibly stupid. ~I~ Somebody from official Paradise love it.
	name = "Золотая молния"
	steps = list(MARTIAL_COMBO_STEP_HELP, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HELP, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HELP, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HELP)
	explaination_text = "Используя высший уровень Корпоративного Дзюдо, вы можете оглушить противника жизненной энергией или, если точнее, внезапным скачком напряжения перегруженных нанитов в поясе. Но лучше считать, что это именно жизненная энергия..."


/datum/martial_combo/judo/goldenblast/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	target.visible_message(span_warning("[user] бьёт [target] чистой Золотой энергией, вбивая [genderize_ru(target.gender, "его", "её", "его", "их")] в пол!"), \
						span_userdanger("[user] странно жестикулирует, дико кричит и тычет вам прямо в грудь! Вы чувствуете, как гнев <b>ЗОЛОТОЙ МОЛНИИ</b> пронзает ваше тело! Вы полностью парализованы!"))
	playsound(get_turf(target), 'sound/weapons/taser.ogg', 55, TRUE, -1)
	playsound(get_turf(target), 'sound/weapons/tase.ogg', 55, TRUE, -1)
	target.SpinAnimation(10, 1)
	do_sparks(5, FALSE, target)
	user.say("ЗОЛОТАЯ МОЛНИЯ!")
	playsound(get_turf(user), 'sound/weapons/goldenblast.ogg', 60, TRUE, -1)
	target.apply_damage(120, STAMINA)
	target.Knockdown(30 SECONDS)
	target.SetConfused(30 SECONDS)
	shake_camera(target, 3, 1)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Золотая Молния", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
