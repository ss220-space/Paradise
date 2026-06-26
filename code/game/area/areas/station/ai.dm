// MARK: Satellite
/area/aisat
	name = "AI Satellite Hallway"
	icon_state = "yellow"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/aisat/aihallway
	name = "AI Satellite Exterior Hallway"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/aisat/maintenance
	name = "AI Satellite Service"
	icon_state = "storage"

/area/aisat/atmospherics
	name = "AI Satellite Atmospherics"
	icon_state = "storage"

/area/turret_protected
	ambientsounds = list(
		'sound/ambience/engineering/ambitech.ogg',
		'sound/ambience/engineering/ambitech2.ogg',
		'sound/ambience/engineering/ambiatmos.ogg',
		'sound/ambience/engineering/ambiatmos2.ogg',
	)
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

// MARK: Turret
/area/turret_protected/ai_upload
	name = "AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/turret_protected/ai
	name = "AI Chamber"
	icon_state = "ai_chamber"

/area/turret_protected/aisat
	name = "AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/turret_protected/aisat_interior
	name = "AI Satellite Antechamber"
	icon_state = "ai"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/turret_protected/aisat_interior/secondary
	name = "AI Satellite Secondary Antechamber"
