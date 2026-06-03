/datum/action/changeling/linglink
	name = "Связь улья"
	desc = "Мы создаём частичку улья в чужой разум для связи с нами."
	helptext = "Если мы найдём подходящий сосуд, то мы сможем наделить его возможность общаться с нами через сеть улья."
	button_icon_state = "hivemind_link"
	power_type = CHANGELING_PURCHASABLE_POWER
	req_human = TRUE

/datum/action/changeling/linglink/can_sting(mob/living/carbon/user, ignore_linking = FALSE)
	if(!..())
		return FALSE

	if(cling.is_linking && !ignore_linking)
		user.balloon_alert(user, "уже часть улья!")
		return FALSE

	if(!user.pulling || user.pull_hand != user.hand)
		user.balloon_alert(user, "нужно схватить сосуд!")
		return FALSE

	if(user.grab_state < GRAB_NECK)
		user.balloon_alert(user, "нужно схватить крепче!")
		return FALSE

	var/mob/living/carbon/human/target = user.pulling
	if(!ishuman(target))
		return FALSE

	if(!target.mind)
		user.balloon_alert(user, "цель неразумна!")
		return FALSE

	if(target.stat == DEAD)
		user.balloon_alert(user, "нужен живой сосуд!")
		return FALSE

	if(target.has_brain_worms())
		user.balloon_alert(user, "в разуме паразит!")
		return FALSE

	if(target.mind.has_antag_datum(/datum/antagonist/changeling))
		user.balloon_alert(user, "в сосуде собрат!")
		return FALSE

	return TRUE

/datum/action/changeling/linglink/sting_action(mob/user)
	var/mob/living/carbon/human/target = user.pulling
	cling.is_linking = TRUE

	var/time = tgui_input_number(user, "На сколько минут нам следует поделиться связью с ульем?", "Связь улья", FALSE, 120, 0)

	if(isnull(time) || time == 0)
		to_chat(user, span_danger("Мы отказались от идеи связать ваши разумы."))
		cling?.is_linking = FALSE
		return

	time = clamp(time, 1, 120)

	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				to_chat(user, span_notice("[target] нам подходит. Во время создания связи нам нельзя двигаться."))
			if(2)
				user.balloon_alert(user, "скрытно втыкаем хоботок")
				to_chat(target, span_userdanger("Вы чувствуете укол, и в ушах начинает звенеть"))
			if(3)
				user.balloon_alert(user, "создаём связь...")
				to_chat(target, span_userdanger("У вас начинается страшная мигрень, и вы слышите собственный крик, но ваш рот закрыт!"))

		if(!do_after(user, 6 SECONDS, target, NONE) || !can_sting(user, TRUE))
			user.balloon_alert(user, "создание связи прервано")
			cling?.is_linking = FALSE
			return FALSE

	user.balloon_alert(user, "связь создана")
	target.balloon_alert(target, "вы чувствуете связь")
	to_chat(target, "[span_changeling("Вы часть коллективной связи улья, общайтесь в ней с помощью [get_language_prefix(LANGUAGE_HIVE_CHANGELING)].")]")

	for(var/mob/ling in GLOB.mob_list)
		if(LAZYIN(ling.languages, GLOB.all_languages[LANGUAGE_HIVE_CHANGELING]))
			ling.balloon_alert(ling, "чужак в сети!")
			to_chat(ling, span_changeling("Мы чувствуем разум [target.real_name] в нашей сети улья"))

	cling?.is_linking = FALSE
	target.add_language(LANGUAGE_HIVE_CHANGELING)
	target.say("'[get_language_prefix(LANGUAGE_HIVE_CHANGELING)]'АААААААААААА!!")
	target.reagents.add_reagent("salbutamol", 40) // So they don't choke to death while you interrogate them

	addtimer(CALLBACK(src, PROC_REF(remove_language), target, user), time MINUTES, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))

	return TRUE

/datum/action/changeling/linglink/proc/remove_language(mob/target, mob/user)
	if(QDELETED(target))
		return

	target.remove_language(LANGUAGE_HIVE_CHANGELING)
	target.balloon_alert(target, "связь улья слабеет")

	if(!QDELETED(user))
		user.balloon_alert(user, "связь ослабевает")
		to_chat(user, span_changeling("Мы больше не можем поддерживать частичку улья в [target.real_name]."))
