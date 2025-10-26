/datum/martial_combo/cqc/consecutive
	name = "Последовательные атаки"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "В основе своей атакующий приём. Большой урон по стамине и небольшой урон травмами."

/datum/martial_combo/cqc/consecutive/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.stat)
		return MARTIAL_COMBO_FAIL
	target.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] нанос[PLUR_IT_YAT(user)] последовательные удары по животу, шее и спине [target.declent_ru(ACCUSATIVE)]"), \
						span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] нанос[PLUR_IT_YAT(user)]] последовательные удары по Вашим животу, шее и спине!"))
	playsound(get_turf(target), 'sound/weapons/cqchit2.ogg', 50, TRUE, -1)
	target.apply_damage(65, STAMINA)
	target.apply_damage(25, BRUTE)
	objective_damage(user, target, 25, BRUTE)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Consecutive", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
