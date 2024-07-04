/*
/datum/disease/virus/babylonian_fever
	name = "Babylonian Fever"
	agent = "Babylon fever agent"
	desc = "If left untreated, the subject will be in a state of disorientation and will forget all the languages he knew."
	max_stages = 3
	spread_flags = AIRBORNE
	visibility_flags = HIDDEN_HUD
	cure_text = "Mannitol & Mitocholide"
	cures = list("mannitol", "mitocholide")
	cure_prob = 30
	permeability_mod = 0.75
	severity = MEDIUM
	var/list/known_languages

/datum/disease/virus/babylonian_fever/New()
	..()
	if(!affected_mob)
		return
 	known_languages = affected_mob.languages

/datum/disease/virus/babylonian_fever/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			remove_languages()
		if(2, 3)
			if(prob(stage))
				affected_mob.adjustBrainLoss(0.5)
	return

/datum/disease/virus/babylonian_fever/has_cure()
	if(..())
		affected_mob.add_language(known_languages)
		return TRUE


/datum/disease/virus/babylonian_fever/proc/remove_languages()
	for(var/la in affected_mob.languages)
		affected_mob.remove_language(la)
*/

/datum/disease/virus/babylonian_fever
	name = "Babylonian Fever"
	agent = "Babylon fever agent"
	desc = "If left untreated, the subject will be in a state of disorientation and will forget all the languages he knew."
	max_stages = 3
	spread_flags = AIRBORNE
	visibility_flags = HIDDEN_HUD
	cure_text = "Mannitol & Mitocholide"
	cures = list("mannitol", "mitocholide")
	cure_prob = 30
	permeability_mod = 0.75
	severity = MEDIUM
	var/known_languages = list()

/datum/disease/virus/babylonian_fever/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(1)
			if(affected_mob.languages && !LAZYLEN(known_languages))
				for(var/datum/language/lan in affected_mob.languages)
					LAZYADD(known_languages, lan)
					affected_mob.remove_language(lan.name)
		if(2, 3)
			if(prob(stage))
				affected_mob.adjustBrainLoss(0.5)
			if(prob(stage))
				affected_mob.say(pick(
					"Ммм... гхм...",
					"А-а-а... эээ...",
					"Брр... бл... бл...",
					"Гх... гх... гх...",
					"Ааа... ааа... ааа...",
					"Ух... ух... ух...",
					"Хм... хм... хм...",
					"Шш... шш... шш...",
					"Ыы... ыы... ыы...",
					"Оо... оо... оо...",
					"Ээ... ээ... ээ...",
					"Ии... ии... ии...",
					)
				)
	return FALSE

/datum/disease/virus/babylonian_fever/has_cure()
	if(..())
		if(LAZYLEN(known_languages))
			for(var/datum/language/lan in known_languages)
				affected_mob.add_language(lan.name)
		return TRUE
