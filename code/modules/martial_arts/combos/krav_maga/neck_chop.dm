/datum/martial_combo/krav_maga/neck_chop
	name = "Удар по шее"
	explaination_text = "Травмирует шею и ослепляет оппонента, от чего он будет некоторое время промахиваться при попытке атаковать.."

/datum/martial_combo/krav_maga/neck_chop/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(HAS_TRAIT(target, TRAIT_KRAVMAGA_DEBUFF) || user.a_intent == INTENT_HELP)
		return FALSE
	target.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] руб[pluralize_ru(user.gender, "ит", "ят")] ладонью шею [target.declent_ru(ACCUSATIVE)]!"), \
		span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] сильно ударил[genderize_ru(user.gender, "", "а", "и")] по твоей шее, ослепляя тебя!"))
	playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	target.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
	target.apply_status_effect(STATUS_EFFECT_NECKCHOP)
	objective_damage(user, target, 5, BRUTE)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Neck Chop", ATKLOG_ALL)
	user.mind.martial_art.in_stance = FALSE
	return MARTIAL_COMBO_DONE_CLEAR_COMBOS
