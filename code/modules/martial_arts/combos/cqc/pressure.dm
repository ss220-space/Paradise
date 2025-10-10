/datum/martial_combo/cqc/pressure
	name = "Подавление"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Ты крадешь оружие оппонента и наносишь большой урон по стамине"

/datum/martial_combo/cqc/pressure/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] дав[pluralize_ru(user.gender, "ит", "ят")] рукой шею [target.declent_ru(ACCUSATIVE)]!"))
	var/obj/item/I = target.get_active_hand()
	if(I && target.drop_from_active_hand())
		user.put_in_hands(I, ignore_anim = FALSE)
	target.apply_damage(45, STAMINA)
	playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Pressure", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
