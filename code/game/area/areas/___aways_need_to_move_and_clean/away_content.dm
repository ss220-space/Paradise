/area/awaycontent
	name = "space"
	report_alerts = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE
	holomap_should_draw = FALSE

// Away Missions
/area/awaymission
	name = "Strange Location"
	icon_state = "away"
	report_alerts = FALSE
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_AWAY
	sound_environment = SOUND_ENVIRONMENT_ROOM
	area_flags = NONE

/area/awaymission/example
	name = "Strange Station"

/area/awaymission/desert
	name = "Sudden Drop"

/area/awaymission/beach
	name = "Beach"
	icon_state = "beach"
	static_lighting = FALSE
	base_lighting_alpha = 255
	requires_power = FALSE
	ambientsounds = list(
		'sound/ambience/beach/shore.ogg',
		'sound/ambience/beach/seag1.ogg',
		'sound/ambience/beach/seag2.ogg',
		'sound/ambience/beach/seag3.ogg',
		'sound/ambience/misc/ambiodd.ogg',
		'sound/ambience/medical/ambinice.ogg',
	)

/area/awaymission/undersea
	name = "Undersea"
	icon_state = "undersea"
