// Category 2 medicines are medicines that have an ill effect regardless of volume/OD to dissuade doping. Mostly used as emergency chemicals OR to convert damage (and heal a bit in the process). The type is used to prompt borgs that the medicine is harmful.
/datum/reagent/medicine/C2
	harmless = FALSE
	metabolization_rate = 0.2

/******BRUTE******/
/*Suffix: -bital*/
/datum/reagent/medicine/C2/helbital //only REALLY a C2 if you heal the other damages but not being able to outright heal the other guys is close enough to damaging
	name = "Хельбитал"
	id = "helbital"
	description = "Названное в честь норвежской богини Хель, это лекарство залечивает раны пациента тем эффективнее, чем ближе он к смерти. Ожоги, токсины и удушье усиливают исцеление, но эти повреждения должны поддерживаться, пока препарат метаболизируется, иначе лекарство вызовет негативную реакцию."
	color = "#9400D3"
	taste_description = "холода и смерти"
	overdose_threshold = 35
	var/helbent = FALSE
	var/beginning_combo = 0
	var/reaping = FALSE

/datum/reagent/medicine/C2/helbital/on_mob_metabolize(mob/living/affected_mob)
	beginning_combo = affected_mob.getToxLoss() + affected_mob.getOxyLoss() + affected_mob.getFireLoss() //This DOES mean you can cure Tox/Oxy and then do burn to maintain the brute healing that way.
	return ..()

/datum/reagent/medicine/C2/helbital/on_mob_life(mob/living/carbon/M)
	. = TRUE
	var/combo = M.getToxLoss() + M.getOxyLoss() + M.getFireLoss()
	var/healed_this_iteration = FALSE
	if(combo >= beginning_combo)
		M.adjustBruteLoss(FLOOR(combo / -15, 0.1)) //every 15 damage adds 1 per tick
		healed_this_iteration = TRUE
	else
		M.adjustToxLoss((beginning_combo - combo) * 0.1) //If you are just healing instead of converting the damage we'll KINDLY do it for you AND make it the most difficult!

	if(!healed_this_iteration || reaping || !prob(0.005)) //janken with the grim reaper!
		return ..()

	notify_ghosts(
		"[M.real_name] вступил в игру \"камень-ножницы-бумага\" со смертью!",
		source = M,
		title = "Кто победит?",
	)
	reaping = TRUE

	var/list/rock_paper_scissors = list("камень" = "бумага", "бумага" = "ножницы", "ножницы" = "камень") //choice = loses to

	if(M.apply_status_effect(/datum/status_effect/necropolis_curse, CURSE_BLINDING))
		helbent = TRUE

	to_chat(M, "Зловещие духи возникают перед вами, предлагая сыграть «дружескую» игру в камень-ножницы-бумага... на вашу жизнь. Что выбираете?")
	var/rps_choice = tgui_alert(M, "Время сыграть! У вас 60 секунд для выбора!", "Камень-Ножницы-Бумага", rock_paper_scissors, timeout = 1.1 MINUTES)

	if(QDELETED(M))
		reaping = FALSE
		return //good job, you ruined it

	if(!rps_choice)
		to_chat(M, span_hierophant("Вы решаете не испытывать судьбу, но духи остаются... будем надеяться, они скоро уйдут."))
		reaping = FALSE
		return

	var/grim = pick(rock_paper_scissors)
	to_chat(M, span_hierophant("Духи выбрали - [grim], вы выбрали - [rps_choice]."))

	if(grim == rps_choice) //You Tied!
		to_chat(M, span_hierophant("Вы сыграли вничью, и злобные духи исчезают... по крайней мере, на время."))
		reaping = FALSE
		return

	if(rock_paper_scissors[rps_choice] == grim) //You lost!
		to_chat(M, span_hierophant("Вы проигрываете, и злобные духи с жуткими усмешками окружают ваше тело."))
		M.dust()
		return

	to_chat(M, span_hierophant("Вы побеждаете, и злобные духи исчезают, а ваши раны затягиваются."))
	M.client.give_award(/datum/award/achievement/jobs/helbitaljanken, M)
	M.revive()
	M.reagents.del_reagent(type)

/datum/reagent/medicine/C2/helbital/overdose_process(mob/living/carbon/M)
	if(!helbent)
		M.apply_necropolis_curse(CURSE_WASTING | CURSE_BLINDING)
		helbent = TRUE
	..()
	return TRUE

/datum/reagent/medicine/C2/helbital/on_mob_delete(mob/living/carbon/human/user)
	if(helbent)
		user.remove_status_effect(STATUS_EFFECT_NECROPOLIS_CURSE)
	..()

