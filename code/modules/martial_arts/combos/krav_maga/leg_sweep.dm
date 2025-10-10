/datum/martial_combo/krav_maga/leg_sweep
	name = "Подсечка"
	explaination_text = "Сильный удар по ноге оппонента, замедляет его на некоторое время."

/datum/martial_combo/krav_maga/leg_sweep/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.stat || IS_HORIZONTAL(target))
		return FALSE
	target.visible_message(
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] бь[pluralize_ru(user.gender, "ёт", "ют")] по ноге [target.declent_ru(ACCUSATIVE)]!"), \
		span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] бь[pluralize_ru(user.gender, "ёт", "ют")] по твоей ноге!")
	)
	var/affecting_leg = pick(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	target.apply_damage(10, BRUTE, affecting_leg)
	objective_damage(user, target, 10, BRUTE)
	target.apply_status_effect(STATUS_EFFECT_LEGSWEEP)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Leg Sweep", ATKLOG_ALL)
	user.mind.martial_art.in_stance = FALSE
	return MARTIAL_COMBO_DONE_CLEAR_COMBOS
