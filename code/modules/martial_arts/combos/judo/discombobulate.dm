/datum/martial_combo/judo/discombobulate
	name = "Оглушить"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Нанесите удар ладонью по уху противника, ненадолго оглушив его."


/datum/martial_combo/judo/discombobulate/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	target.visible_message(span_warning("[user] резко бьёт [target] по уху ладонью!"), \
						span_userdanger("[user] бьёт вас ладонью по уху!"))
	playsound(get_turf(user), 'sound/weapons/slap.ogg', 40, TRUE, -1)
	target.apply_damage(10, STAMINA)
	target.AdjustConfused(5 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Оглушить", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
