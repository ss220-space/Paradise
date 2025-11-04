/datum/martial_combo/cqc/slam
	name = "Слэм"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Вы кидаете цель на землю, после чего она некоторое время не сможет встать и ходить прямо."

/datum/martial_combo/cqc/slam/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(IS_HORIZONTAL(target))
		return MARTIAL_COMBO_FAIL
	target.visible_message(
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] кида[PLUR_ET_YUT(user)] [target.declent_ru(ACCUSATIVE)] на землю!"), \
		span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] кида[PLUR_ET_YUT(user)] вас на землю!")
	)
	playsound(get_turf(user), 'sound/weapons/slam.ogg', 50, TRUE, -1)
	target.apply_damage(10, BRUTE)
	objective_damage(user, target, 10, BRUTE)
	target.Knockdown(5 SECONDS)
	target.SetConfused(8 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Slam", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
