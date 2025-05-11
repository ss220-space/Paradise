/// Turfs that will be colored as HOLOMAP_ROCK
#define IS_ROCK(tile) (istype(tile, /turf/simulated/mineral) && tile.density)
/// Turfs that will be colored as HOLOMAP_OBSTACLE
#define IS_OBSTACLE(tile) (istype(tile, /turf/simulated/wall) ||  (locate(/obj/structure/window) in tile))
/// Turfs that will be colored as HOLOMAP_SOFT_OBSTACLE
#define IS_SOFT_OBSTACLE(tile) ((locate(/obj/structure/grille) in tile) || (locate(/obj/structure/lattice) in tile))
/// Turfs that will be colored as HOLOMAP_PATH
#define IS_PATH(tile) istype(tile, /turf/simulated/floor)
/// Turfs that contain a Z transition, like ladders and stairs. They show with special animations on the map.
#define HAS_Z_TRANSITION(tile) ((locate(/obj/structure/ladder) in tile) || (locate(/obj/structure/stairs) in tile))

// Holo-Minimaps Generation Subsystem handles initialization of the holo minimaps.

SUBSYSTEM_DEF(holomaps)
	name = "Holomaps"
	init_order = INIT_ORDER_HOLOMAP
	flags = SS_NO_FIRE

	var/static/list/valid_map_indexes = list()
	var/static/list/holomaps = list()
	var/static/list/extra_holomaps = list()
	var/static/list/station_holomaps = list()
	var/static/list/holomap_z_transitions = list()
	var/static/list/list/holomap_position_to_name = list()

/datum/controller/subsystem/holomaps/Recover()
	flags |= SS_NO_INIT // Make extra sure we don't initialize twice.

/datum/controller/subsystem/holomaps/Initialize(timeofday)
	if (generate_holomaps())
		return SS_INIT_SUCCESS
	return SS_INIT_FAILURE

// Holomap generation.

/// Generates all the holo minimaps, initializing it all nicely, probably.
/datum/controller/subsystem/holomaps/proc/generate_holomaps()
	. = TRUE
	// Starting over if we're running midround (it runs real fast, so that's possible)
	holomaps.Cut()
	extra_holomaps.Cut()
	for(var/z in levels_by_trait(STATION_LEVEL))
		if(!generate_holomap(z))
			. = FALSE

	if(!generate_default_holomap_legend())
		. = FALSE

	return .

/datum/controller/subsystem/holomaps/proc/generate_default_holomap_legend()
	for(var/department_color in GLOB.holomap_color_to_name)
		var/image/marker_icon = image('icons/misc/8x8.dmi', "area_legend")
		var/icon/marker_color_overlay = icon('icons/misc/8x8.dmi', "area_legend")
		marker_color_overlay.DrawBox(department_color, 1, 1, 8, 8) // Get the whole icon
		marker_icon.add_overlay(marker_color_overlay)
		GLOB.holomap_default_legend[GLOB.holomap_color_to_name[department_color]] = list(
			"icon" =  marker_icon,
			"markers" = list(),
		)

	return TRUE

/// Generates the base holomap and the area holomap, before passing the latter to setup_station_map to tidy it up for viewing.
/datum/controller/subsystem/holomaps/proc/generate_holomap(z_level = 1)
	// Sanity checks - Better to generate a helpful error message now than have DrawBox() runtime
	var/icon/canvas = icon(HOLOMAP_ICON, "blank")
	var/icon/area_canvas = icon(HOLOMAP_ICON, "blank")
	LAZYINITLIST(SSholomaps.holomap_z_transitions["[z_level]"])
	var/list/z_transition_positions = SSholomaps.holomap_z_transitions["[z_level]"]

	var/list/position_to_name = list()
	if(world.maxx > canvas.Width())
		stack_trace("Minimap for z=[z_level] : world.maxx ([world.maxx]) must be <= [canvas.Width()]")
	if(world.maxy > canvas.Height())
		stack_trace("Minimap for z=[z_level] : world.maxy ([world.maxy]) must be <= [canvas.Height()]")

	for(var/x = 1 to world.maxx)
		for(var/y = 1 to world.maxy)
			var/turf/T = locate(x, y, z_level)
			var/offset_x = HOLOMAP_CENTER_X + x
			var/offset_y = HOLOMAP_CENTER_Y + y
			var/area/turf_area = get_area(T)

			if(!T || !turf_area.holomap_should_draw)
				continue

			if(turf_area.holomap_color)
				area_canvas.DrawBox(turf_area.holomap_color, offset_x, offset_y)
				position_to_name["[offset_x]:[offset_y]"] = turf_area.holomap_color == HOLOMAP_AREACOLOR_MAINTENANCE ? "Maintenance" : turf_area.name

			if(IS_ROCK(T))
				canvas.DrawBox(HOLOMAP_ROCK, offset_x, offset_y)

			else if(IS_OBSTACLE(T))
				canvas.DrawBox(HOLOMAP_OBSTACLE, offset_x, offset_y)

			else if(IS_SOFT_OBSTACLE(T))
				canvas.DrawBox(HOLOMAP_SOFT_OBSTACLE, offset_x, offset_y)

			else if(IS_PATH(T))
				canvas.DrawBox(HOLOMAP_PATH, offset_x, offset_y)

			var/z_transition_obj = HAS_Z_TRANSITION(T)
			if(!z_transition_obj)
				continue

			var/image/image_to_use

			if(istype(z_transition_obj, /obj/structure/stairs))
				if(!z_transition_positions["Ступени вверх"])
					z_transition_positions["Ступени вверх"] = list("icon" = image('icons/misc/8x8.dmi', "stairs"), "markers" = list())

				image_to_use = image('icons/misc/8x8.dmi', "stairs")
				image_to_use.pixel_x = offset_x - 1 // -1 to offset icon properly
				image_to_use.pixel_y = offset_y - 1

				z_transition_positions["Ступени вверх"]["markers"] += image_to_use

				var/turf/checking = get_step_multiz(get_turf(z_transition_obj), UP)
				if(!istype(checking))
					continue

				var/list/transitions = SSholomaps.holomap_z_transitions["[checking.z]"]
				if(!transitions)
					transitions = list()
					SSholomaps.holomap_z_transitions["[checking.z]"] = transitions

				image_to_use = image('icons/misc/8x8.dmi', "stairs_down")
				image_to_use.pixel_x = checking.x + HOLOMAP_CENTER_X - 1
				image_to_use.pixel_y = checking.y + HOLOMAP_CENTER_Y - 1

				if(!transitions["Ступени вниз"])
					transitions["Ступени вниз"] = list("icon" = image('icons/misc/8x8.dmi', "stairs_down"), "markers" = list())

				transitions["Ступени вниз"]["markers"] += image_to_use
				continue

			if(!z_transition_positions["Лестница"])
				z_transition_positions["Лестница"] = list("icon" = image('icons/misc/8x8.dmi', "ladder"), "markers" = list())

			image_to_use = image('icons/misc/8x8.dmi', "ladder")
			image_to_use.pixel_x = offset_x - 1
			image_to_use.pixel_y = offset_y - 1

			z_transition_positions["Лестница"]["markers"] += image_to_use

		// Check sleeping after each row to avoid *completely* destroying the server
		CHECK_TICK

	valid_map_indexes += z_level
	holomaps["[z_level]"] = canvas
	holomap_position_to_name["[z_level]"] = position_to_name
	return setup_station_map(area_canvas, z_level)


/// Draws the station area overlay. Required to be run if you want the map to be viewable on a station map viewer.
/// Takes the area canvas, and the Z-level value.
/datum/controller/subsystem/holomaps/proc/setup_station_map(icon/canvas, z_level)
	// Save this nice area-colored canvas in case we want to layer it or something I guess
	extra_holomaps["[HOLOMAP_EXTRA_STATIONMAPAREAS]_[z_level]"] = canvas

	var/icon/map_base = icon(holomaps["[z_level]"])
	map_base.Blend(HOLOMAP_HOLOFIER, ICON_MULTIPLY)

	// Generate the full sized map by blending the base and areas onto the backdrop
	var/icon/big_map = icon(HOLOMAP_ICON, "stationmap")
	big_map.Blend(map_base, ICON_OVERLAY)
	big_map.Blend(canvas, ICON_OVERLAY)
	extra_holomaps["[HOLOMAP_EXTRA_STATIONMAP]_[z_level]"] = big_map

	// Generate the "small" map (I presume for putting on wall map things?)
	var/icon/small_map = icon(HOLOMAP_ICON, "blank")
	small_map.Blend(map_base, ICON_OVERLAY)
	small_map.Blend(canvas, ICON_OVERLAY)
	small_map.Scale(40, 40)
	small_map.Crop(5, 5, 36, 36)

	// And rotate it in every direction of course!
	var/icon/actual_small_map = icon(small_map)
	actual_small_map.Insert(new_icon = small_map, dir = NORTH)
	actual_small_map.Insert(new_icon = turn(small_map, 90), dir = EAST)
	actual_small_map.Insert(new_icon = turn(small_map, 180), dir = SOUTH)
	actual_small_map.Insert(new_icon = turn(small_map, 270), dir = WEST)
	extra_holomaps["[HOLOMAP_EXTRA_STATIONMAPSMALL]_[z_level]"] = actual_small_map
	return TRUE

#undef IS_ROCK
#undef IS_OBSTACLE
#undef IS_SOFT_OBSTACLE
#undef IS_PATH
#undef HAS_Z_TRANSITION
