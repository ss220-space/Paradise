/// Datum tracker for storage UI
/datum/storage_interface
	/// UI elements for this theme
	var/atom/movable/screen/storage/start
	var/atom/movable/screen/storage/end
	var/atom/movable/screen/storage/continued
	var/atom/movable/screen/storage/top
	var/atom/movable/screen/storage/bottom

	/// Background covering the whole grid of cells (gives the "cell division" look)
	var/atom/movable/screen/storage/place_items

	/// Storage closer ref
	var/atom/movable/screen/close/closer

	/// Storage that owns us
	var/datum/storage/parent_storage

	/// How many columns/rows are currently shown
	var/columns = 1
	var/rows = 1

	/// Screen location of the content area (top-left cell), used by add_items
	var/screen_start_x = 4
	var/screen_pixel_x = 16
	var/screen_start_y = 2
	var/screen_pixel_y = 16

	/// Width of the content area in pixels (for the closer position)
	var/frame_line_width = 0

/datum/storage_interface/New(ui_style, datum/storage/parent_storage, mob/user)
	..()
	src.parent_storage = parent_storage
	var/datum/hud/owner_hud = user.hud_used

	closer = new(null, owner_hud, parent_storage)

	start = new(null, owner_hud, parent_storage)
	start.icon_state = "storage_start"
	end = new(null, owner_hud, parent_storage)
	end.icon_state = "storage_end"
	continued = new(null, owner_hud, parent_storage)
	continued.icon_state = "storage_continue"
	top = new(null, owner_hud, parent_storage)
	top.icon_state = "storage_top"
	bottom = new(null, owner_hud, parent_storage)
	bottom.icon_state = "storage_bottom"

	place_items = new(null, owner_hud, parent_storage)

	for (var/atom/movable/screen/ui_elem as anything in list_ui_elements(initializing = TRUE))
		ui_elem.icon = ui_style

/// Returns all UI elements under this theme
/datum/storage_interface/proc/list_ui_elements(initializing = FALSE)
	return list(start, end, continued, top, bottom, place_items, closer)

/datum/storage_interface/Destroy(force)
	QDEL_NULL(closer)
	QDEL_NULL(start)
	QDEL_NULL(end)
	QDEL_NULL(continued)
	QDEL_NULL(top)
	QDEL_NULL(bottom)
	QDEL_NULL(place_items)
	parent_storage = null
	return ..()

/// Updates position of all UI elements
/datum/storage_interface/proc/update_position(screen_start_x, screen_pixel_x, screen_start_y, screen_pixel_y, columns, rows, mob/user_looking, atom/real_location, list/datum/numbered_display/numbered_contents)
	src.columns = columns
	src.rows = rows
	src.screen_start_x = screen_start_x
	src.screen_pixel_x = screen_pixel_x
	src.screen_start_y = screen_start_y
	src.screen_pixel_y = screen_pixel_y

	var/y_enlarge = (ICON_SIZE_Y + (rows - 1) * (ICON_SIZE_Y - 3)) / ICON_SIZE_Y
	var/y_offset = floor(16 * y_enlarge)

	var/line_width = columns * ICON_SIZE_X
	src.frame_line_width = line_width

	var/matrix/modify_matrix = matrix()
	modify_matrix.Scale((line_width - 1) / ICON_SIZE_X, y_enlarge)
	continued.transform = modify_matrix

	modify_matrix = matrix()
	modify_matrix.Scale(1, y_enlarge)
	start.transform = modify_matrix
	end.transform = modify_matrix

	modify_matrix = matrix()
	modify_matrix.Scale((line_width + 2) / ICON_SIZE_X, 1)
	top.transform = modify_matrix
	bottom.transform = modify_matrix

	start.screen_loc = "[4]:[16],[2]:[y_offset]"
	continued.screen_loc = "[4]:[floor(line_width / 2 + 2)],[2]:[y_offset]"
	end.screen_loc = "[4]:[16 + line_width + 1],[2]:[y_offset]"

	top.screen_loc = "[4]:[floor(line_width / 2 + 2)],[2]:[y_offset + round(((ICON_SIZE_Y - 3) + 1) / 2) * (rows - 1)]"
	bottom.screen_loc = "[4]:[floor(line_width / 2 + 2)],[2]:[16]"

	closer.screen_loc = "[4]:[line_width + 16 + 2 + 1],[2]:[16]"

	var/end_cell_x = screen_start_x + columns
	var/end_cell_y = screen_start_y + rows
	place_items.screen_loc = "[screen_start_x]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y] to [end_cell_x]:[screen_pixel_x],[end_cell_y]:[screen_pixel_y]"

	add_items(screen_start_x, screen_pixel_x, screen_start_y, screen_pixel_y, columns, rows, user_looking, real_location, numbered_contents)

/datum/storage_interface/proc/add_items(screen_start_x, screen_pixel_x, screen_start_y, screen_pixel_y, columns, rows, mob/user_looking, atom/real_location, list/datum/numbered_display/numbered_contents)
	var/current_x = screen_start_x
	var/current_y = screen_start_y + rows - 1

	var/list/obj/storage_contents = list()
	if (islist(numbered_contents))
		for(var/content_type in numbered_contents)
			var/datum/numbered_display/numberdisplay = numbered_contents[content_type]
			storage_contents[numberdisplay.sample_object] = MAPTEXT("<font color='white'>[(numberdisplay.number > 1)? "[numberdisplay.number]" : ""]</font>")
	else
		for(var/obj/item as anything in real_location)
			storage_contents[item] = ""

	for(var/obj/item as anything in storage_contents)
		item.mouse_opacity = MOUSE_OPACITY_OPAQUE
		item.screen_loc = "[current_x]:[screen_pixel_x],[current_y]:[screen_pixel_y]"
		if(parent_storage.numerical_stacking)
			item.maptext = storage_contents[item]
		SET_PLANE_EXPLICIT(item, ABOVE_HUD_PLANE, real_location)
		current_x++
		if(current_x - screen_start_x >= columns)
			current_x = screen_start_x
			current_y--
			if(current_y < screen_start_y)
				break
