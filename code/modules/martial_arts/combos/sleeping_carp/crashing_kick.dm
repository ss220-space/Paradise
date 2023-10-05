/datum/martial_combo/sleeping_carp/crashing_kick
	name = "Удар, Крушащий Волны"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Бьет цель в солнечное сплетение, отправляя в полет. Цель после удара замедлена на 5 секунд."

/datum/martial_combo/sleeping_carp/crashing_kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target != user) // no you cannot kick yourself across rooms
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		target.visible_message("<span class='warning'>[user] бьет [target] в солнечное сплетение, отправляя в полет!</span>",
					"<span class='userdanger'>Вы получили удар в солнечное сплетение от [user], отправляя Вас в полет!</span>")
		playsound(target, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		target.throw_at(throw_target, 10, 14, user)
		target.apply_damage(15, BRUTE, BODY_ZONE_CHEST)
		target.adjustOxyLoss(10) //тебе попали в солнечное сплетение, в конце концов. Как ты вообще жив?
		target.Slowed(5 SECONDS)
		add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Crashing Waves Kick", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
