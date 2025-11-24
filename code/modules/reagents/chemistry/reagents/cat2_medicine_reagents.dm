// Category 2 medicines are medicines that have an ill effect regardless of volume/OD to dissuade doping.
// Mostly used as emergency chemicals OR to convert damage (and heal a bit in the process).
// The type is used to prompt borgs that the medicine is harmful.
/datum/reagent/medicine/c2
	harmless = FALSE
	metabolization_rate = 0.2

#define ROCK "камень"
#define PAPER "бумага"
#define SCISSORS "ножницы"

/******BRUTE******/
/*Suffix: -bital*/
/datum/reagent/medicine/c2/helbital //only REALLY a C2 if you heal the other damages but not being able to outright heal the other guys is close enough to damaging
	name = "Хельбитал"
	id = "helbital"
	description = "Названное в честь норвежской богини Хель, это лекарство залечивает раны пациента тем эффективнее, чем ближе он к смерти. \
		Ожоги, токсины и удушье усиливают исцеление, но эти повреждения должны поддерживаться, пока препарат метаболизируется, иначе лекарство вызовет негативную реакцию."
	color = "#9400D3"
	taste_description = "холода и смерти"
	overdose_threshold = 35
	var/helbent = FALSE
	var/beginning_combo = 0
	var/reaping = FALSE
	var/static/list/rock_paper_scissors = list(ROCK = PAPER, PAPER = SCISSORS, SCISSORS = ROCK)
	var/static/list/rock_paper_scissors_keys = list(ROCK, PAPER, SCISSORS)

/datum/reagent/medicine/c2/helbital/on_mob_metabolize(mob/living/affected_mob)
	beginning_combo = affected_mob.getToxLoss() + affected_mob.getOxyLoss() + affected_mob.getFireLoss() //This DOES mean you can cure Tox/Oxy and then do burn to maintain the brute healing that way.
	return ..()

/datum/reagent/medicine/c2/helbital/on_mob_life(mob/living/carbon/affected_mob)
	. = TRUE
	var/combo = affected_mob.getToxLoss() + affected_mob.getOxyLoss() + affected_mob.getFireLoss()
	var/healed_this_iteration = FALSE
	if(combo >= beginning_combo)
		affected_mob.adjustBruteLoss(FLOOR(combo / -15, 0.1)) //every 15 damage adds 1 per tick
		healed_this_iteration = TRUE
	else
		affected_mob.adjustToxLoss((beginning_combo - combo) * 0.1) //If you are just healing instead of converting the damage we'll KINDLY do it for you AND make it the most difficult!

	if(!healed_this_iteration || reaping || !prob(0.05)) //janken with the grim reaper!
		return ..()

	notify_ghosts(
		"[affected_mob.real_name] вступил в игру \"камень-ножницы-бумага\" со смертью!",
		source = affected_mob,
		title = "Кто победит?",
	)
	reaping = TRUE

	if(affected_mob.apply_status_effect(/datum/status_effect/necropolis_curse, CURSE_BLINDING))
		helbent = TRUE

	to_chat(affected_mob, "Зловещие духи возникают перед вами, предлагая сыграть \"дружескую\" игру в камень-ножницы-бумага... на вашу жизнь. Что выбираете?")
	var/rps_choice = tgui_alert(affected_mob, "Время сыграть! У вас 60 секунд для выбора!", "Камень-Ножницы-Бумага", rock_paper_scissors_keys, timeout = 1.1 MINUTES)

	if(QDELETED(affected_mob))
		reaping = FALSE
		return //good job, you ruined it

	if(!rps_choice)
		to_chat(affected_mob, span_hierophant("Вы решаете не испытывать судьбу, но духи остаются... будем надеяться, они скоро уйдут."))
		reaping = FALSE
		return

	var/grim = pick(rock_paper_scissors)
	to_chat(affected_mob, span_hierophant("Духи выбрали — [grim], вы выбрали — [rps_choice]."))
	if(grim == rps_choice) //You Tied!
		to_chat(affected_mob, span_hierophant("Вы сыграли вничью, и злобные духи исчезают... по крайней мере, на время."))
		reaping = FALSE
		return

	if(rock_paper_scissors[rps_choice] == grim) //You lost!
		to_chat(affected_mob, span_hierophant("Вы проигрываете, и злобные духи с жуткими усмешками окружают ваше тело."))
		affected_mob.dust()
		return

	to_chat(affected_mob, span_hierophant("Вы побеждаете, и злобные духи исчезают, а ваши раны затягиваются."))
	affected_mob.client.give_award(/datum/award/achievement/jobs/helbitaljanken, affected_mob)
	affected_mob.revive()
	affected_mob.reagents.del_reagent(type)

#undef ROCK
#undef PAPER
#undef SCISSORS

/datum/reagent/medicine/c2/helbital/overdose_process(mob/living/carbon/affected_mob)
	if(!helbent)
		affected_mob.apply_necropolis_curse(CURSE_WASTING | CURSE_BLINDING)
		helbent = TRUE
	return ..()

/datum/reagent/medicine/c2/helbital/on_mob_delete(mob/living/carbon/human/user)
	if(helbent)
		user.remove_status_effect(STATUS_EFFECT_NECROPOLIS_CURSE)
	..()

