/area/station/cargo/bitrunning
	name = "Bitrunning"

/area/station/cargo/bitrunning/den
	name = "Bitrunning Den"
	icon_state = "quartoffice"

/area/virtual_domain
	name = "Virtual Domain Ruins"
	icon_state = "away"
	has_gravity = STANDARD_GRAVITY
	requires_power = FALSE
	area_flags = VIRTUAL_AREA
	holomap_should_draw = FALSE
	report_alerts = FALSE
	tele_proof = TRUE
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/virtual_domain/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/virtual_domain/safehouse
	name = "Virtual Domain Safehouse"
	area_flags = VIRTUAL_AREA | VIRTUAL_SAFE_AREA

/area/virtual_domain/protected_space
	name = "Virtual Domain Safe Zone"
	area_flags = VIRTUAL_AREA | VIRTUAL_SAFE_AREA

/area/virtual_domain/protected_space/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/lavaland/surface/outdoors/virtual_domain
	name = "Virtual Domain Lava Ruins"
	icon_state = "away"
	area_flags = VIRTUAL_AREA
	report_alerts = FALSE
	tele_proof = TRUE

/area/ruin/space/virtual_domain
	name = "Virtual Domain Unexplored Location"
	requires_power = FALSE
	area_flags = VIRTUAL_AREA
	report_alerts = FALSE
	tele_proof = TRUE

/area/space/virtual_domain
	name = "Virtual Domain Space"
	icon_state = "away"
	area_flags = VIRTUAL_AREA
	holomap_should_draw = FALSE
	report_alerts = FALSE
	tele_proof = TRUE
