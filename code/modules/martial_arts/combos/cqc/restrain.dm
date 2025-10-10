/datum/martial_combo/cqc/restrain
	name = "Захват"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Ты обездвиживаешь оппонента. Продолжи комбо 'обезоруживанием' чтобы усыпить противника."

/datum/martial_combo/cqc/restrain/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	var/datum/martial_art/cqc/CQC = MA
	if(!istype(CQC))
		return MARTIAL_COMBO_FAIL
	if(CQC.restraining)
		return MARTIAL_COMBO_FAIL
	if(!target.stat)
		target.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] захватыва[pluralize_ru(user.gender, "ет", "ют")] и обездвижива[pluralize_ru(user.gender, "ет", "ют")] [target.declent_ru(ACCUSATIVE)]!"), \
							span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] захватыва[pluralize_ru(user.gender, "ет", "ют")] и обездвижива[pluralize_ru(user.gender, "ет", "ют")] тебя!"))
		target.apply_damage(30, STAMINA)
		target.Stun(2 SECONDS)
		CQC.restraining = TRUE
		addtimer(CALLBACK(CQC, TYPE_PROC_REF(/datum/martial_art/cqc, drop_restraining)), 50, TIMER_UNIQUE)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Restrain", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
