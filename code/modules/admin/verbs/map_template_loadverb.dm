ADMIN_VERB(map_template_load, R_DEBUG|R_EVENT, "Map Template - Place", "Place a map template at your current location.", ADMIN_CATEGORY_DEBUG)
	var/datum/map_template/template

	var/map = tgui_input_list(user, "Choose a Map Template to place at your CURRENT LOCATION", "Place Map Template", GLOB.map_templates)
	if(!map)
		return
	template = GLOB.map_templates[map]

	var/turf/T = get_turf(user.mob)
	if(!T)
		return

	if(!template.fits_in_map_bounds(T, centered = TRUE))
		to_chat(user, "Map is too large to fit in bounds. Map's dimensions: ([template.width], [template.height])")
		return

	var/list/preview = list()
	for(var/turf/place_on as anything in template.get_affected_turfs(T, centered = TRUE))
		var/image/I = image('icons/turf/overlays.dmi', place_on, "greenOverlay")
		SET_PLANE(I, ABOVE_LIGHTING_PLANE, place_on)
		preview += I
	user.images += preview
	if(tgui_alert(user, "Confirm location.", "Template Confirm", list("Yes", "No")) == "Yes")
		var/timer = start_watch()
		log_and_message_admins(span_adminnotice("has started to place the map template ([template.name]) at [ADMIN_COORDJMP(T)]"))
		if(template.load(T, centered = TRUE))
			log_and_message_admins(span_adminnotice("has placed a map template ([template.name]) at [ADMIN_COORDJMP(T)]. Took [stop_watch(timer)]s."))
		else
			to_chat(user, "Failed to place map", confidential = TRUE)
	user.images -= preview

ADMIN_VERB(map_template_upload, R_DEBUG|R_EVENT, "Map Template - Upload", "Upload a map template to the server.", ADMIN_CATEGORY_DEBUG)
	var/map = input(user, "Choose a Map Template to upload to template storage", "Upload Map Template") as null|file
	if(!map)
		return
	if(copytext("[map]", -4) != ".dmm")
		to_chat(user, "Bad map file: [map]")
		return

	var/timer = start_watch()
	message_admins(span_adminnotice("[key_name_admin(user)] has begun uploading a map template ([map])"))
	var/datum/map_template/M = new(map = map, rename = "[map]")
	if(M.preload_size(map))
		to_chat(user, "Map template '[map]' ready to place ([M.width]x[M.height])")
		GLOB.map_templates[M.name] = M
		message_admins(span_adminnotice("[key_name_admin(user)] has uploaded a map template ([map]). Took [stop_watch(timer)]s."))
	else
		to_chat(user, "Map template '[map]' failed to load properly")
