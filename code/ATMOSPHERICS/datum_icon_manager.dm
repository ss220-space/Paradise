//--------------------------------------------
// Pipe colors
//
// Add them here and to the pipe_colors list
//  to automatically add them to all relevant
//  atmospherics devices.
//--------------------------------------------

/proc/pipe_color_lookup(color)
	for(var/check_color in GLOB.pipe_colors)
		if(color == GLOB.pipe_colors[check_color])
			return "[check_color]"

/proc/pipe_color_check(color)
	if(!color)
		return TRUE
	for(var/check_color in GLOB.pipe_colors)
		if(color == GLOB.pipe_colors[check_color])
			return TRUE
	return FALSE

//--------------------------------------------
// Icon cache generation
//--------------------------------------------

/datum/pipe_icon_manager
	var/list/pipe_icons
	var/list/manifold_icons
	var/list/device_icons
	var/list/underlays


/datum/pipe_icon_manager/New()
	check_icons()


/datum/pipe_icon_manager/proc/get_atmos_icon(device, dir, color, state)
	check_icons()

	device = "[device]"
	state = "[state]"
	color = "[color]"
	dir = "[dir]"

	switch(device)
		if("pipe")
			return pipe_icons[state + color]
		if("manifold")
			return manifold_icons[state + color]
		if("device")
			return device_icons[state]
		if("underlay")
			return underlays[state + dir + color]


/datum/pipe_icon_manager/proc/check_icons()
	if(!pipe_icons)
		gen_pipe_icons()
	if(!manifold_icons)
		gen_manifold_icons()
	if(!device_icons)
		gen_device_icons()
	if(!underlays)
		gen_underlay_icons()


/datum/pipe_icon_manager/proc/gen_pipe_icons()
	if(!pipe_icons)
		pipe_icons = list()

	var/icon/pipe = icon('icons/obj/pipes_and_stuff/atmospherics/atmos/pipes.dmi')

	for(var/state in pipe.IconStates())
		if(!state || findtext(state, "map"))
			continue

		var/cache_name = state
		var/image/img = image('icons/obj/pipes_and_stuff/atmospherics/atmos/pipes.dmi', icon_state = state)
		pipe_icons[cache_name] = img

		for(var/pipe_color in GLOB.pipe_colors)
			img = image('icons/obj/pipes_and_stuff/atmospherics/atmos/pipes.dmi', icon_state = state)
			img.color = GLOB.pipe_colors[pipe_color]
			pipe_icons[state + "[GLOB.pipe_colors[pipe_color]]"] = img

	pipe = icon('icons/obj/pipes_and_stuff/atmospherics/atmos/heat.dmi')
	for(var/state in pipe.IconStates())
		if(!state || findtext(state, "map"))
			continue
		pipe_icons["hepipe" + state] = image('icons/obj/pipes_and_stuff/atmospherics/atmos/heat.dmi', icon_state = state)

	pipe = icon('icons/obj/pipes_and_stuff/atmospherics/atmos/junction.dmi')
	for(var/state in pipe.IconStates())
		if(!state || findtext(state, "map"))
			continue
		pipe_icons["hejunction" + state] = image('icons/obj/pipes_and_stuff/atmospherics/atmos/junction.dmi', icon_state = state)


/datum/pipe_icon_manager/proc/gen_manifold_icons()
	if(!manifold_icons)
		manifold_icons = list()

	var/icon/pipe = icon('icons/obj/pipes_and_stuff/atmospherics/atmos/manifold.dmi')

	for(var/state in pipe.IconStates())
		if(findtext(state, "clamps"))
			var/image/img = image('icons/obj/pipes_and_stuff/atmospherics/atmos/manifold.dmi', icon_state = state)
			manifold_icons[state] = img
			continue

		if(findtext(state, "core") || findtext(state, "4way"))
			var/image/img = image('icons/obj/pipes_and_stuff/atmospherics/atmos/manifold.dmi', icon_state = state)
			manifold_icons[state] = img
			for(var/pipe_color in GLOB.pipe_colors)
				img = image('icons/obj/pipes_and_stuff/atmospherics/atmos/manifold.dmi', icon_state = state)
				img.color = GLOB.pipe_colors[pipe_color]
				manifold_icons[state + GLOB.pipe_colors[pipe_color]] = img


/datum/pipe_icon_manager/proc/gen_device_icons()
	if(!device_icons)
		device_icons = list()

	var/icon/device = icon('icons/obj/pipes_and_stuff/atmospherics/atmos/vent_pump.dmi')
	for(var/state in device.IconStates())
		if(!state || findtext(state, "map"))
			continue
		device_icons["vent" + state] = image('icons/obj/pipes_and_stuff/atmospherics/atmos/vent_pump.dmi', icon_state = state)

	device = icon('icons/obj/pipes_and_stuff/atmospherics/atmos/vent_scrubber.dmi')
	for(var/state in device.IconStates())
		if(!state || findtext(state, "map"))
			continue
		device_icons["scrubber" + state] = image('icons/obj/pipes_and_stuff/atmospherics/atmos/vent_scrubber.dmi', icon_state = state)


/datum/pipe_icon_manager/proc/gen_underlay_icons()
	if(!underlays)
		underlays = list()

	var/icon/pipe = icon('icons/obj/pipes_and_stuff/atmospherics/atmos/pipe_underlays.dmi')

	for(var/state in pipe.IconStates())
		if(state == "")
			continue

		var/cache_name = state

		for(var/change_dir in GLOB.cardinal)
			var/image/img = image(icon('icons/obj/pipes_and_stuff/atmospherics/atmos/pipe_underlays.dmi', icon_state = state, dir = change_dir), layer = GAS_PIPE_HIDDEN_LAYER)
			underlays[cache_name + "[change_dir]"] = img
			for(var/pipe_color in GLOB.pipe_colors)
				img = image(icon('icons/obj/pipes_and_stuff/atmospherics/atmos/pipe_underlays.dmi', icon_state = state, dir = change_dir), layer = GAS_PIPE_HIDDEN_LAYER)
				img.color = GLOB.pipe_colors[pipe_color]
				underlays[state + "[change_dir]" + "[GLOB.pipe_colors[pipe_color]]"] = img

