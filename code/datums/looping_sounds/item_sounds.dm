/datum/looping_sound/tape_recorder_hiss
	mid_sounds = list('sound/items/taperecorder/taperecorder_hiss_mid.ogg')
	start_sound = list('sound/items/taperecorder/taperecorder_hiss_start.ogg')
	volume = 10

/datum/looping_sound/ambulance_alarm/justice
	mid_length = 1.5 SECONDS
	falloff_distance = 4
	falloff_exponent = 4
	volume = 40

/datum/looping_sound/chainsaw
	start_sound = list('sound/weapons/chainsaw_start.ogg')
	start_length = 1 SECONDS
	mid_sounds = list('sound/weapons/chainsaw_loop.ogg')
	mid_length = 1 SECONDS
	end_sound = list('sound/weapons/chainsaw_stop.ogg')
	volume = 20

/datum/looping_sound/tesla_cannon
	start_sound = list('sound/weapons/gun/tesla/tesla_start.ogg' = 1)
	start_volume = 100
	start_length = 200 MILLISECONDS
	mid_sounds = list('sound/weapons/gun/tesla/tesla_loop.ogg' = 1)
	mid_length = 3.8 SECONDS
	end_sound = list('sound/weapons/gun/tesla/power_breaker_fan.ogg' = 1)
	end_volume = 15
	ignore_walls = FALSE
	reserve_random_channel = TRUE
