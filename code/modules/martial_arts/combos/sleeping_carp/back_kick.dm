/datum/martial_combo/sleeping_carp/back_kick
	name = "Back Kick"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Пинает оппонента в спину, заставляя его лежать 6 секунд от боли."

/datum/martial_combo/sleeping_carp/back_kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(user.dir == target.dir && !target.stat && !target.IsWeakened())
		user.do_attack_animation(target, ATTACK_EFFECT_KICK)
		target.visible_message("<span class='warning'>[user] пинает [target] в спину!</span>", \
						  "<span class='userdanger'>[user] ударяет вас в спину, заставляя споткнуться и упасть!</span>")
		step_to(target,get_step(target,target.dir),1)
		target.Weaken(6 SECONDS)
		playsound(get_turf(target), 'sound/weapons/punch1.ogg', 50, 1, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Back Kick", ATKLOG_ALL)
		if(prob(80))
			user.say(pick("СЮРПРИЗ!","УДАР В СПИНУ!","КУААА!", "ВАТААА", "СКИДЫЩ!", "НИКОГДА НЕ ПОВОРАЧИВАЙСЯ СПИНОЙ К ПРОТИВНИКУ!"))
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
