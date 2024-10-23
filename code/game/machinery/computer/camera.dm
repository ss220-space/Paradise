#define DEFAULT_MAP_SIZE 15

/obj/machinery/computer/security
	name = "security camera console"
	desc = "Used to access the various cameras networks on the station."

	icon_keyboard = "security_key"
	icon_screen = "cameras"
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/camera

	var/mapping = 0 // For the overview file (overview.dm), not used on this page

	var/list/network = list("SS13","Mining Outpost")
	var/obj/machinery/camera/active_camera
	var/list/watchers = list()

	// Stuff needed to render the map
	var/atom/movable/screen/map_view/cam_screen
	/// All the plane masters that need to be applied.
	var/atom/movable/screen/background/cam_background

	// Parent object this camera is assigned to. Used for camera bugs
	var/atom/movable/parent

/obj/machinery/computer/security/ui_host()
	return parent ? parent : src

/obj/machinery/computer/security/Initialize()
	. = ..()
	// Initialize map objects
	var/map_name = "camera_console_[UID(src)]_map"
	cam_screen = new
	cam_screen.generate_view(map_name)
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

/obj/machinery/computer/security/Destroy()
	QDEL_NULL(cam_screen)
	QDEL_NULL(cam_background)
	active_camera = null
	return ..()

/obj/machinery/computer/security/process()
	. = ..()
	update_camera_view()

/obj/machinery/computer/security/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
	if(!ui)
		var/user_uid = user.UID()
		var/is_living = isliving(user)
		// Ghosts shouldn't count towards concurrent users, which produces
		// an audible terminal_on click.
		if(is_living)
			watchers += user_uid
		// Turn on the console
		if(length(watchers) == 1 && is_living)
			playsound(src, 'sound/machines/terminal_on.ogg', 25, FALSE)
			use_power(active_power_usage)
		// Register map objects
		cam_screen.display_to(user)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, "CameraConsole", name)
		ui.open()

/obj/machinery/computer/security/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps)
	)

/obj/machinery/computer/security/ui_close(mob/user)
	..()
	cam_screen.hide_from(user)
	watchers -= user.UID()

/obj/machinery/computer/security/ui_data()
	var/list/data = list()
	data["network"] = network
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			status = active_camera.status,
		)
	var/list/cameras = get_available_cameras()
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
			x = C.x,
			y = C.y,
			z = C.z,
			status = C.status
		))
	return data

/obj/machinery/computer/security/ui_static_data()
	var/list/static_data = list()
	static_data["mapRef"] = cam_screen.assigned_map
	var/list/station_level_numbers = list()
	var/list/station_level_names = list()
	for(var/z_level in levels_by_trait(STATION_LEVEL))
		station_level_numbers += z_level
		station_level_names += check_level_trait(z_level, STATION_LEVEL)
	static_data["stationLevelNum"] = station_level_numbers
	static_data["stationLevelName"] = station_level_names
	return static_data

/obj/machinery/computer/security/ui_act(action, params)
	if(..())
		return

	. = TRUE

	if(action == "switch_camera")
		var/c_tag = params["name"]
		var/list/cameras = get_available_cameras()
		var/obj/machinery/camera/C = cameras[c_tag]
		if(isnull(C))
			to_chat(usr, span_warning("ERROR. [c_tag] camera was not found."))
			return
		active_camera?.computers_watched_by -= src
		active_camera = C
		active_camera.computers_watched_by += src
		playsound(src, get_sfx("terminal_type"), 25, FALSE)

		update_camera_view()

		return

/obj/machinery/computer/security/proc/update_camera_view()
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
		return
	var/list/visible_turfs = list()
	for(var/turf/T in view(active_camera.view_range, get_turf(active_camera)))
		visible_turfs += T

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

// Returns the list of cameras accessible from this computer
/obj/machinery/computer/security/proc/get_available_cameras()
	var/list/L = list()
	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if((is_away_level(z) || is_away_level(C.z)) && (C.z != z))//if on away mission, can only receive feed from same z_level cameras
			continue
		L.Add(C)
	var/list/D = list()
	for(var/obj/machinery/camera/C in L)
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(C.network)))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = C.network & network
		if(tempnetwork.len)
			D["[C.c_tag]"] = C
	return D

/obj/machinery/computer/security/attack_hand(mob/user)
	if(stat || ..())
		user.unset_machine()
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/security/attack_ai(mob/user)
	if(isAI(user))
		to_chat(user, span_notice("You realise its kind of stupid to access a camera console when you have the entire camera network at your metaphorical fingertips"))
		return

	ui_interact(user)


/obj/machinery/computer/security/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)



// Other computer monitors.
/obj/machinery/computer/security/telescreen
	name = "telescreen"
	desc = "Used for watching camera networks."
	icon_state = "telescreen_console"
	icon_screen = "telescreen"
	icon_keyboard = null
	density = FALSE
	circuit = /obj/item/circuitboard/camera/telescreen


/obj/machinery/computer/security/telescreen/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/direction = tgui_input_list(user, "Which direction?", "Select direction!", list("North", "East", "South", "West", "Centre"))
	if(!direction || !Adjacent(user))
		return
	pixel_x = 0
	pixel_y = 0
	switch(direction)
		if("North")
			pixel_y = 32
		if("East")
			pixel_x = 32
		if("South")
			pixel_y = -32
		if("West")
			pixel_x = -32


/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have Paradise TV on these things."
	icon_state = "entertainment_console"
	icon_screen = "entertainment_off"
	light_color = "#FFEEDB"
	light_power_on = LIGHTING_MINIMUM_POWER
	network = list("news")
	layer = 4 //becouse of plasma glass with layer = 3
	circuit = /obj/item/circuitboard/camera/telescreen/entertainment
	/// Icon utilised when `GLOB.active_video_cameras` list have anything inside.
	var/icon_screen_on = "entertainment"


/obj/machinery/computer/security/telescreen/entertainment/update_overlays()
	icon_screen = length(GLOB.active_video_cameras) ? icon_screen_on : initial(icon_screen)
	return ..()

/obj/machinery/computer/security/telescreen/entertainment/ui_state(mob/user)
	if(issilicon(user))
		if(isAI(user))
			var/mob/living/silicon/ai/AI = user
			if(!AI.lacks_power() || AI.apc_override)
				return GLOB.always_state
		if(isrobot(user))
			return GLOB.always_state

	else if(ishuman(user))
		for(var/obj/machinery/computer/security/telescreen/entertainment/TV in range(6, user))
			if(!TV.stat)
				return GLOB.range_state

	return GLOB.default_state

/obj/machinery/computer/security/telescreen/entertainment/view_act(mob/user)
	if(stat)
		user.unset_machine()
		return
	ui_interact(user)


/obj/machinery/computer/security/telescreen/singularity
	name = "Singularity Engine Telescreen"
	desc = "Used for watching the singularity chamber."
	network = list("Singularity")
	circuit = /obj/item/circuitboard/camera/telescreen/singularity

/obj/machinery/computer/security/telescreen/toxin_chamber
	name = "Toxins Telescreen"
	desc = "Used for watching the test chamber."
	network = list("Toxins")

/obj/machinery/computer/security/telescreen/test_chamber
	name = "Test Chamber Telescreen"
	desc = "Used for watching the test chamber."
	network = list("TestChamber")

/obj/machinery/computer/security/telescreen/research
	name = "Research Monitor"
	desc = "Used for watching the RD's goons from the safety of his office."
	network = list("Research","Research Outpost","RD")

/obj/machinery/computer/security/telescreen/prison
	name = "Prison Monitor"
	desc = "Used for watching Prison Wing holding areas."
	network = list("Prison")

/obj/machinery/computer/security/wooden_tv
	name = "security camera monitor"
	desc = "An old TV hooked into the station's camera network."
	icon_state = "television"
	icon_keyboard = null
	icon_screen = "detective_tv"
	light_color = "#3848B3"
	light_power_on = 0.5
	network = list("SS13")
	circuit = /obj/item/circuitboard/camera/wooden_tv

/obj/machinery/computer/security/mining
	name = "outpost camera monitor"
	desc = "Used to access the various cameras on the outpost."
	icon_keyboard = "mining_key"
	icon_screen = "mining"
	light_color = "#F9BBFC"
	network = list("Mining Outpost")
	circuit = /obj/item/circuitboard/camera/mining

/obj/machinery/computer/security/engineering
	name = "engineering camera monitor"
	desc = "Used to monitor fires and breaches."
	icon_keyboard = "power_key"
	icon_screen = "engie_cams"
	light_color = "#FAC54B"
	network = list("Power Alarms","Atmosphere Alarms","Fire Alarms")
	circuit = /obj/item/circuitboard/camera/engineering

/obj/machinery/computer/security/old_frame
	icon = 'icons/obj/machines/computer3.dmi'
	icon_screen = "sec_oldframe"
	icon_state = "frame-sec"
	icon_keyboard = "kb15"

/obj/machinery/computer/security/old_frame/macintosh
	icon = 'icons/obj/machines/computer3.dmi'
	icon_screen = "sec_oldcomp"
	icon_state = "oldcomp"
	icon_keyboard = null

#undef DEFAULT_MAP_SIZE
