/datum/martial_combo/krav_maga/lung_punch
	name = "Удар по лёгким"
	explaination_text = "Сильный удар по торсу оппонента, на некоторое время восстановление его выносливости будет замедлено."

/datum/martial_combo/krav_maga/lung_punch/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(user.a_intent == INTENT_HELP)
		return FALSE
	if(HAS_TRAIT(target, TRAIT_KRAVMAGA_DEBUFF))
		return FALSE
	target.visible_message(
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] сильно бь[pluralize_ru(user.gender, "ёт", "ют")] [target.declent_ru(ACCUSATIVE)] по торсу!"), \
		span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] сильно бь[pluralize_ru(user.gender, "ёт", "ют")] тебе по торсу! Ты не можешь дышать!")
	)
	playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	target.apply_damage(10, OXY)
	target.apply_status_effect(STATUS_EFFECT_LUNGPUNCH)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Lung Punch", ATKLOG_ALL)
	user.mind.martial_art.in_stance = FALSE
	return MARTIAL_COMBO_DONE_CLEAR_COMBOS
