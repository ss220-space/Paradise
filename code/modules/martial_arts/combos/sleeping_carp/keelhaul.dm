/datum/martial_combo/sleeping_carp/keelhaul
	name = "Утопление"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Вбивает оппонента в пол ударом ногой по голове, оглушая на 6 секунд, а если цель уже лежит - наносит 60 урона стамине!"

/datum/martial_combo/sleeping_carp/keelhaul/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_KICK)
	playsound(get_turf(target), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	if(!target.stat && target.body_position != LYING_DOWN)
		target.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
		objective_damage(user, target, 10, BRUTE)
		target.adjustBrainLoss(5)
		target.Weaken(6 SECONDS)
		target.visible_message("<span class='warning'>[user] бьет [target] ногой по голове, впечатывая лицо в пол!</span>",
						"<span class='userdanger'>Вы получили удар ногой по голове от [user], вы теперь целуете пол!</span>")
	else
		target.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
		objective_damage(user, target, 5, BRUTE)
		target.adjustBrainLoss(5)
		target.emote("scream")
		target.visible_message("<span class='warning'>[user] пинает [target] по голове, оставляя корчиться в боли!</span>",
							"<span class='userdanger'>Вы пропустили пинок по голове от [user], и вы корчитесь от боли!</span>")
	target.apply_damage(61, STAMINA) //fuck you unathi
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Keelhaul", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
