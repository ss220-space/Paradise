#define RANDOM_COLOUR (rgb(rand(0, 255), rand(0, 255), rand(0, 255)))

/**
 * Flashes a color on the screen of a mob or client for a specified duration
 *
 * Arguments:
 * * target - The mob or client to flash the color on
 * * flash_color - The color to flash (default: cult red)
 * * flash_duration - The duration of the flash in seconds (default: 2 seconds)
 */
/proc/flash_color(target, flash_color = COLOR_CULT_RED, flash_duration = 2 SECONDS)
	var/client/target_client
	if(ismob(target))
		var/mob/mob_instance = target
		if(mob_instance.client)
			target_client = mob_instance.client
		else
			return
	else if(isclient(target))
		target_client = target

	if(!istype(target_client))
		return

	target_client.color = flash_color
	spawn(0)
		animate(target_client, color = initial(target_client.color), time = flash_duration)

/// Given a color in the format of "#RRGGBB", will return if the color is dark.
/proc/is_color_dark(color, threshold = 25)
	var/hsl = rgb2num(color, COLORSPACE_HSL)
	return hsl[3] < threshold

GLOBAL_LIST_INIT(hex_characters, list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"))

/proc/random_short_color()
	return random_string(3, GLOB.hex_characters)

/proc/random_color()
	return random_string(6, GLOB.hex_characters)

/proc/ready_random_color()
	return "#" + random_string(6, GLOB.hex_characters)

/**
 * Generates an HSL color transition matrix filter which nicely paints an object
 * without making it a deep fried blob of color.
 *
 * saturation_behavior determines how we handle color saturation:
 * * SATURATION_MULTIPLY - Multiply pixel's saturation by color's saturation. Paints accents while keeping dim areas dim.
 * * SATURATION_OVERRIDE- Affects original lightness/saturation to ensure that pale objects still get doused in color
 */
/proc/color_transition_filter(new_color, saturation_behavior = SATURATION_MULTIPLY)
	if(islist(new_color))
		new_color = rgb(new_color[1], new_color[2], new_color[3])
	new_color = rgb2num(new_color, COLORSPACE_HSL)
	var/hue = new_color[1] / 360
	var/saturation = new_color[2] / 100
	var/added_saturation = 0
	var/deducted_light = 0
	if(saturation_behavior == SATURATION_OVERRIDE)
		added_saturation = saturation * 0.75
		deducted_light = saturation * 0.5
		saturation = min(saturation, 1 - added_saturation)

	var/list/new_matrix = list(
		0, 0, 0, // Ignore original hue
		0, saturation, 0, // Multiply the saturation by ours
		0, 0, 1 - deducted_light, // If we're highly saturated then remove a bit of lightness to keep some color in
		hue, added_saturation, 0, // And apply our preferred hue and some saturation if we're oversaturated
	)
	return color_matrix_filter(new_matrix, FILTER_COLOR_HSL)

/// Applies a color filter to a hex/RGB list color
/proc/apply_matrix_to_color(color, list/matrix, colorspace = COLORSPACE_HSL)
	if(islist(color))
		color = rgb(color[1], color[2], color[3], color[4])
	color = rgb2num(color, colorspace)
	// Pad alpha if we're lacking it
	if(length(color) < 4)
		color += 255

	// Do we have a constants row?
	var/has_constants = FALSE
	// Do we have an alpha row/parameters?
	var/has_alpha = FALSE

	switch(length(matrix))
		if(9)
			has_constants = FALSE
			has_alpha = FALSE
		if(12)
			has_constants = TRUE
			has_alpha = FALSE
		if(16)
			has_constants = FALSE
			has_alpha = TRUE
		if(20)
			has_constants = TRUE
			has_alpha = TRUE
		else
			CRASH("Matrix of invalid length [length(matrix)] was passed into apply_matrix_to_color!")

	var/list/new_color = list(0, 0, 0, 0)
	var/row_length = 3
	if(has_alpha)
		row_length = 4
	else
		new_color[4] = 255

	for(var/row_index in 1 to (length(matrix) / row_length))
		for(var/row_elem in 1 to row_length)
			var/elem = matrix[(row_index - 1) * row_length + row_elem]
			if(!has_constants || row_index != (length(matrix) / row_length))
				new_color[row_index] += color[row_elem] * elem
				continue

			// Constant values at the end of the list (if we have such)
			if(colorspace != COLORSPACE_HSV && colorspace != COLORSPACE_HCY && colorspace != COLORSPACE_HSL)
				new_color[row_elem] += elem * 255
				continue

			// HSV/HSL/HCY have non-255 maximums for their values
			var/multiplier = 255
			switch(row_elem)
				// Hue goes from 0 to 360
				if(1)
					multiplier = 360
				// Value, luminance, chroma, etc go from 0 to 100
				if(2 to 3)
					multiplier = 100
				// Alpha still goes from 0 to 255
				if(4)
					multiplier = 255
			new_color[row_elem] += elem * multiplier

	var/rgbcolor = rgb(new_color[1], new_color[2], new_color[3], new_color[4], space = colorspace)
	return rgbcolor
