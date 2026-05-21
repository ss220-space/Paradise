/datum/action/changeling/absorbDNA
	name = "Поглощение ДНК"
	desc = "Поглощение ДНК нашей жертвы. Для этого потребуется душить её."
	button_icon_state = "absorb_dna"
	power_type = CHANGELING_INNATE_POWER

/datum/action/changeling/absorbDNA/can_sting(mob/living/carbon/user, ignore_absorbing = FALSE)
	if(!..())
		return FALSE

	if(cling.is_absorbing && !ignore_absorbing)
		user.balloon_alert(user, "уже поглощаем")
		return FALSE

	if(!user.pulling || user.pull_hand != user.hand)
		user.balloon_alert(user, "нужно схватить жертву")
		return FALSE

	if(user.grab_state <= GRAB_NECK)
		user.balloon_alert(user, "нужно схватить крепче")
		return FALSE

	return cling.can_absorb_dna(user.pulling)

/datum/action/changeling/absorbDNA/sting_action(mob/user)
	var/mob/living/carbon/human/target = user.pulling
	cling.is_absorbing = TRUE

	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				to_chat(user, span_notice("[target] нам подходит. Во время поглощения нам нельзя двигаться."))
			if(2)
				user.balloon_alert_to_viewers("вытягивает хоботок", "мы вытягиваем хоботок")
			if(3)
				user.balloon_alert_to_viewers("уколол хоботком [target]", "мы воткнули хоботок")
				target.take_overall_damage(40)

		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "[stage]"))
		if(!do_after(user, 6 SECONDS, target, NONE) || !can_sting(user, TRUE))
			user.balloon_alert(user, "поглощение прервано!")
			cling.is_absorbing = FALSE
			return FALSE
	user.balloon_alert_to_viewers("поглощает [target]!", "поглощение успешно")

	if(!cling.get_dna(target.dna))
		cling.absorb_dna(target)

	if(user.nutrition < NUTRITION_LEVEL_WELL_FED)
		user.set_nutrition(min((user.nutrition + target.nutrition), NUTRITION_LEVEL_WELL_FED))

	if(target.mind)//if the victim has got a mind

		target.mind.show_memory(user, FALSE) //I can read your mind, kekeke. Output all their notes.

		//Some of target's recent speech, so the changeling can attempt to imitate them better.
		//Recent as opposed to all because rounds tend to have a LOT of text.
		var/list/recent_speech

		var/say_log_len = LAZYLEN(target.say_log)
		if(say_log_len > CLING_ABSORB_RECENT_SPEECH)
			recent_speech = target.say_log.Copy(say_log_len - CLING_ABSORB_RECENT_SPEECH + 1, 0) //0 so len-LING_ARS+1 to end of list
		else if(say_log_len)
			recent_speech = target.say_log.Copy()

		if(recent_speech)
			user.mind.store_memory("<b>Речевые шаблоны [target].</b>")
			to_chat(user, span_boldnotice("Речевые шаблоны [target]."))
			for(var/spoken_memory in recent_speech)
				user.mind.store_memory("\"[spoken_memory]\"")
				to_chat(user, span_notice("\"[spoken_memory]\""))
			user.mind.store_memory("<b>Мы забыли речевые шаблоны [target].</b>")
			to_chat(user, span_boldnotice("Мы забыли речевые шаблоны [target]."))

		var/datum/antagonist/changeling/target_cling = IS_CHANGELING(target)
		if(target_cling)//If the target was a changeling, suck out their extra juice and objective points!
			cling.chem_charges += min(target_cling.chem_charges, cling.chem_storage)
			cling.chem_storage += CLING_CHEM_STORAGE_STEAL
			cling.absorbed_count += target_cling.absorbed_count

			target_cling.absorbed_count = 0
			target_cling.absorbed_dna.len = 1
			target_cling.chem_storage -= CLING_CHEM_STORAGE_STEAL

	cling.chem_charges = min(cling.chem_charges + 10, cling.chem_storage)

	cling.is_absorbing = FALSE
	cling.can_respec = TRUE
	var/datum/action/changeling/evolution_menu/menu = locate() in user.actions
	SStgui.update_uis(menu)

	target.death(FALSE)
	target.Drain()
	return TRUE

#undef CLING_ABSORB_RECENT_SPEECH

