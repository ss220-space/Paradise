/datum/martial_combo/cqc/pressure
	name = "Подавление"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Вы крадёте оружие цели и наносите ей большой урон по стамине."

/datum/martial_combo/cqc/pressure/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target == user)
		return MARTIAL_COMBO_DONE_BASIC_HIT
	target.visible_message(
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] выхватыва[PLUR_ET_YUT(user)] оружие из рук [target.declent_ru(ACCUSATIVE)]!"), \
		span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] крад[PLUR_YOT_UT(user)] ваше оружие!"))
	var/obj/item/item = target.get_active_hand()
	if(item && target.drop_from_active_hand())
		user.put_in_hands(item, ignore_anim = FALSE)
	target.apply_damage(45, STAMINA)
	playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Pressure", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
