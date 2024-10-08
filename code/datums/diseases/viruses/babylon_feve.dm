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

	// We'll store the languages the mob knew before the fever here
	var/list/datum/language/stored_languages = list()

/datum/disease/virus/babylonian_fever/Contract(mob/living/M, act_type, is_carrier, need_protection_check, zone)
	. = ..()
	if(. != src)
  		return FALSE
	RegisterSignal(M, "living_recieved_language", PROC_REF(store_and_remove_languages))
	// Store languages on first stage activation
	if(M.languages)
		stored_languages += M.languages.Copy()
	// Remove existing languages
	if(M.languages)
		for(var/datum/language/lan in M.languages)
			M.remove_language(lan.name)

/datum/disease/virus/babylonian_fever/stage_act()
	if(!..())
		return FALSE
	switch(stage)
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
					"Уээ... Уэээ... УЭЭЭЭ...",
					"Ээ... ээ... ээ...",
					"Ии... ии... ии...",
					"Двести... двадцать..."\
					)
				)
	return TRUE

/datum/disease/virus/babylonian_fever/has_cure()
	if(..())
		// Restore previously known languages
		if(stored_languages.len)
			for(var/datum/language/lan in stored_languages)
				affected_mob.add_language(lan.name)
			stored_languages.Cut() // Clear the stored languages
		return TRUE

/datum/disease/virus/babylonian_fever/proc/store_and_remove_languages()
	// Remove existing languages
	if(affected_mob.languages)
		stored_languages += affected_mob.languages.Copy()
		for(var/datum/language/lan in affected_mob.languages)
			affected_mob.remove_language(lan.name)
