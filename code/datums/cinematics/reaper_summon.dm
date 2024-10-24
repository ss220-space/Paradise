/datum/cinematic/cult_arm_reaper
/datum/cinematic/cult_arm_reaper/play_cinematic()
	screen.icon_state = null
	flick("intro_cult", screen)
	stoplag(2.5 SECONDS)
	play_cinematic_sound(sound('sound/misc/enter_blood.ogg'))
	stoplag(2.8 SECONDS)
	play_cinematic_sound(sound('sound/machines/terminal_off.ogg'))
	stoplag(2 SECONDS)
	flick("station_corrupted_Reaper", screen)
	play_cinematic_sound(sound('sound/effects/ghost.ogg'))
	stoplag(7 SECONDS)
	special_callback?.Invoke()


/datum/cinematic/cult_fail_reaper
/datum/cinematic/cult_fail_reaper/play_cinematic()
	screen.icon_state = "station_intact"
	stoplag(2 SECONDS)
	play_cinematic_sound(sound('sound/effects/narsie_summon.ogg'))
	stoplag(6 SECONDS)
	play_cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	stoplag(1 SECONDS)
	play_cinematic_sound(sound('sound/misc/demon_dies.ogg'))
	stoplag(3 SECONDS)
	special_callback?.Invoke()
