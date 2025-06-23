/datum/game_mode
	var/list/datum/mind/sintouched = list()
	var/list/datum/mind/devils = list()


/datum/game_mode/proc/auto_declare_completion_devil()
	if(!length(devils))
		return

	var/text = span_fontsize2("<b>Дьявол[declension_ru(devils.len, "ом", "ами", "ами")]:</b>")
	for(var/datum/mind/devil in devils)
		var/datum/antagonist/devil_datum = devil.has_antag_datum(/datum/antagonist/devil)
		if(!devil_datum)
			continue
		text += "[devil_datum.roundend_report()]<br>"
	to_chat(world, text)

/datum/game_mode/proc/auto_declare_completion_sintouched()
	if(!length(devils))
		return

	var/text = span_fontsize2("<b>Грешник[declension_ru(devils.len, "ом", "ами", "ами")]:</b>")
	for(var/datum/mind/devil in devils)
		var/datum/antagonist/sintouched_datum = devil.has_antag_datum(/datum/antagonist/sintouched)
		if(!sintouched_datum)
			continue
		text += "[sintouched_datum.roundend_report()]<br>"
	to_chat(world, text)
