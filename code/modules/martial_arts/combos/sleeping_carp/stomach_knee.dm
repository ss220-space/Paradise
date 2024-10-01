/datum/martial_combo/sleeping_carp/stomach_knee
	name = "Stomach Knee"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Заводит ваше колено в живот оппонента, заставляя его лежать от боли и неровно дышать"
	combo_text_override = "Grab, switch hands, Harm"

/datum/martial_combo/sleeping_carp/stomach_knee/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		target.visible_message("<span class='warning'>[user] пинает коленом [target] прямо в живот!</span>", \
						  "<span class='userdanger'>[user] ударяет вас коленом в живот!</span>")
		target.audible_message("<b>[target]</b> gags!")
		target.AdjustLoseBreath(20 SECONDS)
		target.Weaken(6 SECONDS)
		target.adjustStaminaLoss(15)
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 50, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Stomach Knee", ATKLOG_ALL)
		if(prob(80))
			user.say(pick("ВОХОП!", "КУХ!", "ЯКХУУ!", "ЗАДЕРЖИ ДЫХАНИЕ!", "УДАР КОЛЕНОМ!"))
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
