/area/solar //i hate this macaroni areas
	requires_power = FALSE
	valid_territory = FALSE
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_SPACE
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/solar/auxport
	name = "North-West Solar Array"
	icon_state = "panelsA"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/solar/auxstarboard
	name = "North-East Solar Array"
	icon_state = "panelsA"

/area/solar/starboardaux
	name = "East Solar Array"
	icon_state = "panelsS"

/area/solar/starboard
	name = "South-East Solar Array"
	icon_state = "panelsS"

/area/solar/port
	name = "South-West Solar Array"
	icon_state = "panelsP"

/area/maintenance/auxsolarport
	name = "North-West Solar Maintenance"
	icon_state = "SolarcontrolA"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/starboardaux
	name = "East Solar Maintenance"
	icon_state = "SolarcontrolS"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/starboardsolar
	name = "South-East Solar Maintenance"
	icon_state = "SolarcontrolS"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/portsolar
	name = "South-West Solar Maintenance"
	icon_state = "SolarcontrolP"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/auxsolarstarboard
	name = "North-East Solar Maintenance"
	icon_state = "SolarcontrolA"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING
