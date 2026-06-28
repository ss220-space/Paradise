// MARK: Satellite
/area/station/ai/satellite/hallway
	name = "AI Satellite Hallway"
	icon_state = "yellow"

/area/station/ai/satellite/exterior
	name = "AI Satellite Exterior Hallway"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/ai/satellite/maintenance
	name = "AI Satellite Service"
	icon_state = "storage"

/area/station/ai/satellite/atmos
	name = "AI Satellite Atmospherics"
	icon_state = "storage"

/area/station/ai
	ambientsounds = list(
		'sound/ambience/engineering/ambitech.ogg',
		'sound/ambience/engineering/ambitech2.ogg',
		'sound/ambience/engineering/ambiatmos.ogg',
		'sound/ambience/engineering/ambiatmos2.ogg',
	)
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

// MARK: Turret
/area/station/ai/upload/chamber
	name = "AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/ai/satellite/chamber
	name = "AI Chamber"
	icon_state = "ai_chamber"

/area/station/ai/satellite
	name = "AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/station/ai/satellite/interior
	name = "AI Satellite Antechamber"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/ai/satellite/interior/secondary
	name = "AI Satellite Secondary Antechamber"
