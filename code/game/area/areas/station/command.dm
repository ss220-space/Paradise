/area/gateway
	name = "Gateway"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/teleporter
	name = "Teleporter"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/teleporter/abandoned
	name = "Abandoned Teleporter"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/magistrateoffice
	name = "Magistrate's Office"
	icon_state = "magistrate"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/ntrep
	name = "Nanotrasen Representative's Office"
	icon_state = "ntrep"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/blueshield
	name = "Blueshield's Office"
	icon_state = "blueshield"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/server
	name = "Messaging Server Room"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/bridge
	name = "Bridge"
	icon_state = "bridge"
	ambientsounds = list(
		'sound/ambience/misc/signal.ogg',
	)
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/bridge/meeting_room
	name = "Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/bridge/vip
	name = "VIP Area"
	icon_state = "meeting"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/crew_quarters/captain
	name = "Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/crew_quarters/captain/bedroom
	name = "Captain's Bedroom"

/area/crew_quarters/heads/hop
	name = "Head of Personnel's Quarters"

/area/crew_quarters/courtroom
	name = "Courtroom"
	icon_state = "courtroom"
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/crew_quarters/heads
	name = "Head of Personnel's Office"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/crew_quarters/hor
	name = "Research Director's Office"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/crew_quarters/hos
	name = "Head of Security's Office"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/crew_quarters/chief
	name = "Chief Engineer's Office"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	ambience_index = AMBIENCE_DANGER
	holomap_color = HOLOMAP_AREACOLOR_COMMAND
