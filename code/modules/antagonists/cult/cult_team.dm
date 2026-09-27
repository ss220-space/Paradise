/datum/team/blood_cult
	antag_datum_type = /datum/antagonist/cult
	var/datum/cult_objectives/cult_objs = new
	var/cult_risen = FALSE
	var/cult_ascendant = FALSE
	var/rise_number
	var/ascend_number
	var/ascend_percent
	var/ghost_summons

/datum/team/blood_cult/New(list/starting_members)
	. = ..()
	name = "Культисты [SSticker.cultdat ? SSticker.cultdat.entity_name : "Нар’Си"]"

/datum/team/blood_cult/Destroy(force = FALSE)
	QDEL_NULL(cult_objs)
	return ..()

/proc/get_blood_cult_team()
	RETURN_TYPE(/datum/team/blood_cult)
	return GLOB.antagonist_teams[/datum/team/blood_cult]

/datum/team/blood_cult/proc/cult_threshold_check()
	var/players = length(GLOB.player_list)
	var/cultists = get_cultists()
	if(players >= CULT_POPULATION_THRESHOLD)
		ascend_percent = CULT_ASCENDANT_HIGH
		rise_number = round(CULT_RISEN_HIGH * (players - cultists))
		ascend_number = round(CULT_ASCENDANT_HIGH * (players - cultists))
	else
		ascend_percent = CULT_ASCENDANT_LOW
		rise_number = round(CULT_RISEN_LOW * (players - cultists))
		ascend_number = round(CULT_ASCENDANT_LOW * (players - cultists))
	add_game_logs("Blood Cult rise/ascend numbers: [rise_number]/[ascend_number].")

/datum/team/blood_cult/proc/get_cultists(separate = FALSE)
	var/cultists = 0
	var/constructs = 0
	for(var/datum/mind/member as anything in members)
		if(ishuman(member.current) && !member.current.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST) && !member.madeby_sentience_potion)
			cultists++
		else if(isconstruct(member.current))
			constructs++
	if(separate)
		return list(cultists, constructs)
	return cultists + constructs

/datum/team/blood_cult/proc/check_cult_size()
	if(cult_ascendant)
		return
	var/cult_players = get_cultists()

	if((cult_players >= rise_number) && !cult_risen)
		cult_risen = TRUE
		log_admin("The Blood Cult has risen. The eyes started to glow.")
		for(var/datum/mind/member as anything in members)
			if(!ishuman(member.current))
				continue
			SEND_SOUND(member.current, sound('sound/ambience/antag/bloodcult_eyes.ogg'))
			to_chat(member.current, span_cultlarge("The veil weakens as your cult grows, your eyes begin to glow..."))
			addtimer(CALLBACK(src, PROC_REF(rise), member.current), 20 SECONDS)

	if(cult_players >= ascend_number)
		cult_ascendant = TRUE
		log_admin("The Blood Cult has Ascended. The blood halo started to appear.")
		for(var/datum/mind/member as anything in members)
			if(!ishuman(member.current))
				continue
			SEND_SOUND(member.current, sound('sound/ambience/antag/bloodcult_halos.ogg'))
			to_chat(member.current, span_cultlarge("Your cult is ascendant and the red harvest approaches - you cannot hide your true nature for much longer!"))
			addtimer(CALLBACK(src, PROC_REF(ascend), member.current), 20 SECONDS)
		GLOB.major_announcement.announce(
			message = "На вашей станции обнаружена внепространственная активность, связанная с культом [SSticker.cultdat ? SSticker.cultdat.entity_name : "Нар’Си"]. Данные свидетельствуют о том, что в ряды культа обращено около [ascend_percent * 100]% экипажа станции. Служба безопасности получает право свободно применять летальную силу против культистов. Прочий персонал должен быть готов защищать себя и свои рабочие места от нападений культистов (в том числе используя летальную силу в качестве крайней меры самообороны). Погибшие члены экипажа должны быть оживлены и деконвертированы, как только ситуация будет взята под контроль.",
			new_title = ANNOUNCE_CCPARANORMAL_RU,
			new_sound = SSstation.announcer.get_rand_report_sound()
		)
		log_game("Blood cult reveal. Powergame allowed.")

/datum/team/blood_cult/proc/rise(mob/living/carbon/human/cultist)
	if(!ishuman(cultist) || !iscultist(cultist))
		return
	if(!cultist.original_eye_color)
		cultist.original_eye_color = cultist.get_eye_color()
	cultist.change_eye_color(BLOODCULT_EYE, FALSE)
	cultist.update_eyes()
	ADD_TRAIT(cultist, TRAIT_RED_EYES, CULT_TRAIT)
	cultist.update_body()

/datum/team/blood_cult/proc/ascend(mob/living/carbon/human/cultist)
	if(!ishuman(cultist) || !iscultist(cultist))
		return
	new /obj/effect/temp_visual/cult/sparks(get_turf(cultist), cultist.dir)
	SEND_SIGNAL(cultist, COMSIG_MOB_HALO_GAINED)

/datum/team/blood_cult/declare_completion()
	if(!length(members))
		return

	var/list/text = list()
	var/result
	if(cult_objs.cult_status == NARSIE_HAS_RISEN)
		result = "cult win - cult win"
		text += span_danger(span_fontsize3("The cult wins! It has succeeded in summoning [SSticker.cultdat.entity_name]!"))
	else if(cult_objs.cult_status == NARSIE_HAS_FALLEN)
		result = "cult draw - narsie died, nobody wins"
		text += span_danger(span_fontsize3("Nobody wins! [SSticker.cultdat.entity_name] was summoned, but banished!"))
	else
		result = "cult loss - staff stopped the cult"
		text += span_warning(span_fontsize3("The staff managed to stop the cult!"))

	if(sets_round_result)
		SSticker.mode_result = result

	text += "<b>The cultists' objectives were:</b>"
	for(var/datum/objective/objective as anything in cult_objs.presummon_objs)
		text += "[objective.explanation_text] - [objective.check_completion() ? "<font color='green'><b>Success!</b></font>" : "<font color='red'>Fail.</font>"]"

	if(cult_objs.cult_status >= NARSIE_NEEDS_SUMMONING)
		text += "[cult_objs.obj_summon.explanation_text] - [cult_objs.obj_summon.check_completion() ? "<font color='green'><b>Success!</b></font>" : "<font color='red'>Fail.</font>"]"

	return text.Join("<br>")
