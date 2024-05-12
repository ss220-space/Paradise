/mob/living/silicon/pai/say(message, verb = "says", sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE, ignore_languages = FALSE)
	if(silence_time)
		to_chat(src, "<font color=green>Communication circuits remain uninitialized.</font>")
		return
	return ..(message)


/mob/living/silicon/pai/get_whisper_loc()
	if(loc == card)			// currently in its card?
		var/atom/movable/whisper_loc = card
		if(is_pda(card.loc)) // Step up 1 level if in a PDA
			whisper_loc = card.loc
		if(isliving(whisper_loc.loc))
			return whisper_loc.loc	// allow a pai being held or in pocket to whisper
		else
			return whisper_loc		// allow a pai in its card to whisper
	return ..()

