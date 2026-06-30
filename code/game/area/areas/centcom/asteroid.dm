// Asteroid area stuff
/area/centcom/asteroid
	name = "Asteroid"
	icon_state = "asteroid"
	requires_power = FALSE
	valid_territory = FALSE
	ambience_index = AMBIENCE_MINING
	requires_power = FALSE
	valid_territory = FALSE
	ambience_index = AMBIENCE_MINING

/area/centcom/asteroid/nearstation
	static_lighting = TRUE
	ambience_index = AMBIENCE_RUINS
	always_unpowered = FALSE
	requires_power = TRUE
	area_flags = BLOBS_ALLOWED
