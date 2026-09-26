/area/ruin
	name = "Unexplored Location"
	icon_state = "away"
	has_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA
	ambience_index = AMBIENCE_RUINS
	sound_environment = SOUND_ENVIRONMENT_STONEROOM
	holomap_should_draw = FALSE

/area/ruin/space
	area_flags = NONE

/area/ruin/unpowered
	always_unpowered = TRUE

/area/ruin/unpowered/no_grav
	has_gravity = FALSE

/area/ruin/powered
	requires_power = FALSE
