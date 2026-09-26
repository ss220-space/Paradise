// Simple datum to keep track of a running holomap. Each machine capable of displaying the holomap will have one.
/datum/station_holomap
	var/image/base_map
	var/icon/map_icon
	var/image/cursor

	var/list/overlay_data = list()
	var/list/disabled_overlays = list()
	var/total_legend_y

	/// This set to TRUE when the station map is initialized on a zLevel that doesn't have its own icon formatted for use by station holomaps.
	var/bogus = TRUE
	/// Redraw location turf
	var/turf/location_turf
	/// Z level of map
	var/map_z
	/// Flag for add map legend
	var/show_legend
	/// Bottom left corner x for crop (0 for disable crop)
	var/crop_x
	/// Bottom left corner y for crop (0 for disable crop)
	var/crop_y
	/// Crop size by x (world.maxx for disable crop)
	var/crop_w
	/// Crop size by y (world.maxy for disable crop)
	var/crop_h

/datum/station_holomap/New()
	. = ..()
	cursor = image('icons/misc/8x8.dmi', "you")

/datum/station_holomap/proc/initialize_holomap(turf/T, current_z_level, mob/user = null, reinit_base_map = FALSE, extra_overlays = list(), show_legend = TRUE, crop = null)
	bogus = FALSE
	location_turf = T
	map_z = current_z_level
	src.show_legend = show_legend
	crop_x = 0
	crop_y = 0
	crop_w = world.maxx
	crop_h = world.maxy
	if(crop)
		crop_x = crop[CROP_X1]
		crop_y = crop[CROP_Y1]
		crop_w = crop[CROP_X2] - crop_x
		crop_h = crop[CROP_Y2] - crop_y

	if(!("[HOLOMAP_EXTRA_STATIONMAP]_[map_z]" in SSholomaps.extra_holomaps))
		initialize_holomap_bogus()
		return

	if(!base_map || reinit_base_map)
		var/icon/extra_holomap = SSholomaps.extra_holomaps["[HOLOMAP_EXTRA_STATIONMAP]_[map_z]"]
		map_icon = icon(extra_holomap)
		if(crop)
			map_icon.Crop(crop_x, crop_y, crop[CROP_X2], crop[CROP_Y2])
		base_map = image(map_icon)

	if(isAI(user) || isAIEye(user))
		var/turf/eye_turf = get_turf(user?.client?.eye)
		if(eye_turf)
			location_turf = eye_turf

	update_map(extra_overlays)

/datum/station_holomap/proc/generate_legend(list/overlays_to_use = list())
	if(!show_legend)
		return

	var/legend_y = HOLOMAP_LEGEND_Y
	for(var/list/overlay_name as anything in overlays_to_use)
		var/image/overlay_icon = overlays_to_use[overlay_name]["icon"]

		overlay_icon.pixel_w = HOLOMAP_LEGEND_X
		overlay_icon.pixel_z = legend_y
		overlay_icon.maptext = MAPTEXT("<span style='font-size: 6px'>[overlay_name]</span>")
		overlay_icon.maptext_x = 10
		overlay_icon.maptext_width = 64
		base_map.add_overlay(overlay_icon)

		if(length(overlays_to_use[overlay_name]["markers"]))
			overlay_data["[round(legend_y / 10)]"] = overlay_name

		if(overlay_name in disabled_overlays)
			var/image/disabled_marker = image('icons/misc/8x8.dmi', "legend_cross")
			disabled_marker.pixel_w = HOLOMAP_LEGEND_X
			disabled_marker.pixel_z = legend_y
			base_map.add_overlay(disabled_marker)

		legend_y += 10

	total_legend_y = legend_y

/// Updates the map with the provided overlays, with any, removing any overlays it already had that aren't the cursor or legend.
/// If there is no turf, then it doesn't add the cursor or legend back.
/// Make sure to set the pixel x and y of your overlays, or they'll render in the far bottom left.
/datum/station_holomap/proc/update_map(list/overlays_to_use = list())
	base_map.cut_overlays()
	var/list/image/overlays = create_overlays(overlays_to_use)
	for(var/image/overlay in overlays)
		base_map.add_overlay(overlay)

	if(bogus)
		return

	generate_legend(overlays_to_use)


/datum/station_holomap/proc/create_overlays(list/overlays_to_use = list())
	. = list()

	if(bogus)
		var/image/legend = image('icons/misc/64x64.dmi', "notfound")
		legend.pixel_w = crop_w / 2 - ICON_SIZE_ALL
		legend.pixel_z = crop_h / 2 - ICON_SIZE_ALL
		. += legend
		return

	if(location_turf && location_turf.z == map_z && is_station_level(location_turf.z))
		cursor.pixel_w = HOLOMAP_CENTER_X + location_turf.x - crop_x - 3
		cursor.pixel_z = HOLOMAP_CENTER_Y + location_turf.y - crop_y - 3

		. += cursor
		overlays_to_use["Вы здесь"] = list(
			"icon" = image('icons/misc/8x8.dmi', "you"),
			"markers" = list()
		)

	for(var/overlay in overlays_to_use)
		if(overlay in disabled_overlays)
			continue

		for(var/image/map_layer in overlays_to_use[overlay]["markers"])
			if(length(.) >= HOLOMAP_MAX_OVERLAYS)
				return
			. += map_layer


/datum/station_holomap/proc/reset_map()
	disabled_overlays = list()

/datum/station_holomap/proc/initialize_holomap_bogus()
	bogus = TRUE
	map_icon = icon('icons/misc/480x480.dmi', "stationmap_r")
	map_icon.Crop(crop_x, crop_y, crop_x + crop_w, crop_y + crop_h)
	base_map = image(map_icon)
	update_map()
