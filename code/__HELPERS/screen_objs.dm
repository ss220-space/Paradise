/**
 * Converts a screen location string to pixel offsets
 *
 * Takes a screen loc string in the format "+-left-offset:+-pixel,+-bottom-offset:+-pixel"
 * Where the :pixel is optional, and returns a list in the format (x_offset, y_offset)
 * Requires context to get info out of screen locs that contain relative info (NORTH, SOUTH, etc)
 *
 * Arguments:
 * * screen_loc - The screen location string to parse
 * * view - The view context to use for relative positioning
 */
/proc/screen_loc_to_offset(screen_loc, view)
	if(!screen_loc)
		return list(64, 64)

	var/list/view_dimensions = view_to_pixels(view)
	var/x_offset = 0
	var/y_offset = 0

	// Parse for directional relative offsets
	if(findtext(screen_loc, "EAST")) // Starting from the east edge
		x_offset += view_dimensions[1]
	if(findtext(screen_loc, "WEST")) // WEST is a 1 tile offset from the start
		x_offset += ICON_SIZE_X
	if(findtext(screen_loc, "NORTH"))
		y_offset += view_dimensions[2]
	if(findtext(screen_loc, "SOUTH"))
		y_offset += ICON_SIZE_Y

	var/list/coordinates = splittext(screen_loc, ",")
	var/list/x_components = splittext(coordinates[1], ":")
	var/list/y_components = splittext(coordinates[2], ":")

	var/x_coordinate = x_components[1]
	var/y_coordinate = y_components[1]

	if(findtext(x_coordinate, "CENTER"))
		x_offset += view_dimensions[1] / 2

	if(findtext(y_coordinate, "CENTER"))
		y_offset += view_dimensions[2] / 2

	x_coordinate = text2num(cut_relative_direction(x_coordinate))
	y_coordinate = text2num(cut_relative_direction(y_coordinate))

	x_offset += x_coordinate * ICON_SIZE_X
	y_offset += y_coordinate * ICON_SIZE_Y

	if(length(x_components) > 1)
		x_offset += text2num(x_components[2])
	if(length(y_components) > 1)
		y_offset += text2num(y_components[2])

	return list(x_offset, y_offset)

/**
 * Converts pixel offsets to a screen location string
 *
 * Takes a list in the form (x_offset, y_offset) and converts it to a screen loc string.
 * Accepts an optional view string/size to force the screen_loc within bounds.
 *
 * Arguments:
 * * x_offset - The horizontal pixel offset
 * * y_offset - The vertical pixel offset
 * * view - Optional view context to clamp the coordinates within bounds
 */
/proc/offset_to_screen_loc(x_offset, y_offset, view = null)
	if(view)
		var/list/view_bounds = view_to_pixels(view)
		x_offset = clamp(x_offset, ICON_SIZE_X, view_bounds[1])
		y_offset = clamp(y_offset, ICON_SIZE_Y, view_bounds[2])

	// Round with no argument is floor, so we get the non-pixel offset here
	var/tile_x = round(x_offset / ICON_SIZE_X)
	var/pixel_x = x_offset % ICON_SIZE_X
	var/tile_y = round(y_offset / ICON_SIZE_Y)
	var/pixel_y = y_offset % ICON_SIZE_Y

	var/list/screen_loc_parts = list()
	screen_loc_parts += "[tile_x]"
	if(pixel_x)
		screen_loc_parts += ":[pixel_x]"
	screen_loc_parts += ",[tile_y]"
	if(pixel_y)
		screen_loc_parts += ":[pixel_y]"
	return jointext(screen_loc_parts, "")

/**
 * Returns a valid location to place a screen object without overflowing the viewport
 *
 * Arguments:
 * * target_loc - The target location as a purely number based screen_loc string "+-left-offset:+-pixel,+-bottom-offset:+-pixel"
 * * offset_distance - The amount we want to offset the target location by. We explicitly don't care about direction here, we will try all 4
 * * view - The view variable of the client we're doing this for. We use this to get the size of the screen
 *
 * Returns a screen loc representing the valid location
 */
/proc/get_valid_screen_location(target_loc, offset_distance, view)
	var/list/base_offsets = screen_loc_to_offset(target_loc)
	var/base_x_offset = base_offsets[1]
	var/base_y_offset = base_offsets[2]

	var/list/view_dimensions = view_to_pixels(view)

	// Bias to the right, down, left, and then finally up
	if(base_x_offset + offset_distance < view_dimensions[1])
		return offset_to_screen_loc(base_x_offset + offset_distance, base_y_offset, view)
	if(base_y_offset - offset_distance > ICON_SIZE_Y)
		return offset_to_screen_loc(base_x_offset, base_y_offset - offset_distance, view)
	if(base_x_offset - offset_distance > ICON_SIZE_X)
		return offset_to_screen_loc(base_x_offset - offset_distance, base_y_offset, view)
	if(base_y_offset + offset_distance < view_dimensions[2])
		return offset_to_screen_loc(base_x_offset, base_y_offset + offset_distance, view)
	stack_trace("You passed in a screen location {[target_loc]} and offset {[offset_distance]} that can't be fit in the viewport Width {[view_dimensions[1]]}, Height {[view_dimensions[2]]}. what did you do lad")
	return null // The fuck did you do lad

/**
 * Takes a screen_loc string and removes any directions like NORTH or SOUTH
 *
 * Arguments:
 * * input_fragment - The screen location fragment to process
 */
/proc/cut_relative_direction(input_fragment)
	var/static/regex/direction_regex = regex(@"([A-Z])\w+", "g")
	return direction_regex.Replace(input_fragment, "")

/**
 * Returns a screen_loc format for a tiling screen objects from start and end positions
 * Start should be bottom left corner, and end top right corner
 *
 * Arguments:
 * * start_x_pixel - Starting X position in pixels
 * * start_y_pixel - Starting Y position in pixels
 * * end_x_pixel - Ending X position in pixels
 * * end_y_pixel - Ending Y position in pixels
 */
/proc/spanning_screen_loc(start_x_pixel, start_y_pixel, end_x_pixel, end_y_pixel)
	var/start_tile_x = round(start_x_pixel / ICON_SIZE_X)
	start_x_pixel -= start_tile_x * ICON_SIZE_X
	var/start_tile_y = round(start_y_pixel / ICON_SIZE_Y)
	start_y_pixel -= start_tile_y * ICON_SIZE_Y
	var/end_tile_x = round(end_x_pixel / ICON_SIZE_X)
	end_x_pixel -= end_tile_x * ICON_SIZE_X
	var/end_tile_y = round(end_y_pixel / ICON_SIZE_Y)
	end_y_pixel -= end_tile_y * ICON_SIZE_Y
	return "[start_tile_x]:[start_x_pixel],[start_tile_y]:[start_y_pixel] to [end_tile_x]:[end_x_pixel],[end_tile_y]:[end_y_pixel]"
