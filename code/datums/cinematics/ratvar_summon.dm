/datum/cinematic/cult_arm_ratvar
/datum/cinematic/cult_arm_ratvar/play_cinematic()
	screen.icon_state = null
	flick("intro_clockwork", screen)
	stoplag(2.5 SECONDS)
	play_cinematic_sound(sound('sound/magic/clockwork/reconstruct.ogg'))
	stoplag(6 SECONDS)
	play_cinematic_sound(sound('sound/machines/terminal_off.ogg'))
	stoplag(2 SECONDS)
	flick("station_corrupted_Ratvar", screen)
	stoplag(7 SECONDS)
	special_callback?.Invoke()


/datum/cinematic/cult_fail_ratvar
/datum/cinematic/cult_fail_ratvar/play_cinematic()
	screen.icon_state = "station_intact"
	stoplag(2 SECONDS)
	play_cinematic_sound(sound('sound/effects/narsie_summon.ogg'))
	stoplag(6 SECONDS)
	play_cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	stoplag(1 SECONDS)
	play_cinematic_sound(sound('sound/misc/demon_dies.ogg'))
	stoplag(3 SECONDS)
	special_callback?.Invoke()
