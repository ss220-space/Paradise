/datum/martial_combo/cqc/pressure
	name = "Подавление"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Вы крадёте оружие оппонента и наносите большой урон по стамине."

/datum/martial_combo/cqc/pressure/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] дав[PLUR_IT_YAT(user)] рукой шею [target.declent_ru(ACCUSATIVE)]!"))
	var/obj/item/item = target.get_active_hand()
	if(item && target.drop_from_active_hand())
		user.put_in_hands(item, ignore_anim = FALSE)
	target.apply_damage(45, STAMINA)
	playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Pressure", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
