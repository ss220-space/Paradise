// Asteroid area stuff
/area/centcom/asteroid
	name = "Asteroid"
	icon_state = "asteroid"
	valid_territory = FALSE
	ambience_index = AMBIENCE_MINING
	sound_environment = SOUND_AREA_ASTEROID

/area/centcom/asteroid/nearstation
	static_lighting = TRUE
	ambience_index = AMBIENCE_RUINS
	requires_power = TRUE
	area_flags = BLOBS_ALLOWED
