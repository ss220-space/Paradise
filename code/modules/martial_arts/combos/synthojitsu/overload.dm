/datum/martial_combo/synthojitsu/overload
	name = "Перегрузка"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Ударяет противника током, используя энергию."

/datum/martial_combo/synthojitsu/overload/perform_combo(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/MA)
	. = MARTIAL_COMBO_FAIL
	target.visible_message("<span class='warning'>[user] бь[pluralize_ru(user.gender,"ёт","ют")] током [target]!</span>", \
						"<span class='userdanger'>[user] бь[pluralize_ru(user.gender,"ёт","ют")] вас током!</span>")
	target.apply_damage(10, BRUTE)
	target.Weaken(1)
	target.apply_damage(20, BURN)
	user.adjust_nutrition(-125)
	playsound(get_turf(target), 'sound/magic/lightningbolt.ogg', 50, 1)
	add_attack_logs(user, target, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
