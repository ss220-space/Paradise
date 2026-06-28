/area/space
	icon_state = "space"
	always_unpowered = TRUE
	static_lighting = FALSE
	base_lighting_alpha = 255
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	valid_territory = FALSE
	outdoors = TRUE
	ambience_index = AMBIENCE_SPACE
	sound_environment = SOUND_AREA_SPACE
	area_flags = UNIQUE_AREA
	ambient_buzz = null // Space is deafeningly quiet

/area/space/nearstation
	icon_state = "space_near"
	static_lighting = TRUE
	base_lighting_alpha = 0
	base_lighting_color = null

/area/space/atmosalert()
	return

/area/space/firealert(obj/source)
	return

/area/space/firereset(obj/source)
	return
