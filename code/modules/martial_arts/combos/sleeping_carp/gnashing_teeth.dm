/datum/martial_combo/sleeping_carp/gnashing_teeth
	name = "Скрежешущие зубы"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Каждый второй последовательный удар наносит 20 урона, который может отрубить конечность и вы кричите боевые фразы, вселяющие страх в сердца врагов."

/datum/martial_combo/sleeping_carp/gnashing_teeth/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("метко ударяет", "махает кулаком словно плавником и плавно, но жестоко атакует", "бьет, словно кусает", "неудержимо уничтожает")
	target.visible_message("<span class='danger'>[user] [atk_verb] [target]!</span>",
					"<span class='userdanger'>[user] [atk_verb] тебя!</span>")
	if(atk_verb == "метко ударяет")
		playsound(get_turf(target), 'sound/effects/hit_punch.ogg', 25, TRUE, -1)
	if(atk_verb == "бьет, словно кусает")
		playsound(get_turf(target), 'sound/weapons/bite.ogg', 25, TRUE, -1)
	if(atk_verb == "махает кулаком словно плавником и плавно, но жестоко атакует") // да, это специально так длинно что пиздец
		playsound(get_turf(target), 'sound/effects/hit_kick.ogg', 25, TRUE, -1)
	if(atk_verb == "неудержимо уничтожает")
		playsound(get_turf(target), 'sound/effects/hulk_hit_airlock.ogg', 25, TRUE, -1)
	add_attack_logs(user, target, "Melee attacked with martial-art [MA] : Gnashing Teeth", ATKLOG_ALL)
	target.apply_damage(20, BRUTE, user.zone_selected, sharp = TRUE)
	if(target.health >= 0)
		user.say(pick("ХЯ!", "ХА!!", "ЧУУ!", "ВУА!", "КЬЯ!", "ХА!", "ХИЯ!", "УДАР КАРПА!", "УКУС КАРПА!"))
	else
		user.say(pick("БАНЗАААЙ!!!!", "КИИЯЯЯ!!!!", "хочу пиццы", "ХЛЫСТ ПЛАВНИКА!!!!", "МОЕ ВРЕМЯ - СЕЙЧАС!!!!!", "КАВАБАНГА!!!!")) // COWABUNGA
	return MARTIAL_COMBO_DONE
