/mob/living/silicon/robot/drone/say(message, verb = "говор[PLUR_IT_YAT(src)]", sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE, ignore_languages = FALSE, ignore_emotes = FALSE)
	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2), intentional = TRUE)
	return ..()

/mob/living/silicon/robot/drone/whisper(message)
	say(message) //drones do not get to whisper, only speak normally
	return TRUE

/mob/living/silicon/robot/drone/get_default_language()
	if(default_language)
		return default_language
	return GLOB.all_languages[LANGUAGE_DRONE]

