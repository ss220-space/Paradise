/datum/martial_combo/sleeping_carp/keelhaul
	name = "Утопление"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Вбивает оппонента в пол ударом ногой по голове, нанося урон стамине!"

/datum/martial_combo/sleeping_carp/keelhaul/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_KICK)
	playsound(get_turf(target), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	if(!target.IsWeakened() && !target.resting && !target.stat)
		target.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
		target.adjustBrainLoss(5)
		target.Weaken(4 SECONDS)
		target.visible_message("<span class='warning'>[user] бьет [target] ногой по голове, впечатывая лицо в пол!</span>",
						"<span class='userdanger'>Вы получили удар ногой по голове от [user], вы теперь целуете пол!</span>")
	else
		target.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
		target.adjustBrainLoss(5)
		target.apply_damage(20, STAMINA)
		target.emote("scream")
		target.visible_message("<span class='warning'>[user] пинает [target] по голове, оставляя корчиться в боли!</span>",
							"<span class='userdanger'>Вы пропустили пинок по голове от [user], и вы корчитесь от боли!</span>")
	target.apply_damage(40, STAMINA)
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Keelhaul", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
