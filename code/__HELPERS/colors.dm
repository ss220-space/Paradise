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
 * Gets a color for a name, will return the same color for a given string consistently within a round.atom
 *
 * Note that this proc aims to produce pastel-ish colors using the HSL colorspace. These seem to be favorable for displaying on the map.
 *
 * Arguments:
 * * name - The name to generate a color for
 * * sat_shift - A value between 0 and 1 that will be multiplied against the saturation
 * * lum_shift - A value between 0 and 1 that will be multiplied against the luminescence
 */
/proc/colorize_string(name, sat_shift = 1, lum_shift = 1)
	// seed to help randomness
	var/static/rseed = rand(1,26)

	// get hsl using the selected 6 characters of the md5 hash
	var/hash = copytext(md5(name + GLOB.round_id), rseed, rseed + 6)
	var/h = hex2num(copytext(hash, 1, 3)) * (360 / 255)
	var/s = (hex2num(copytext(hash, 3, 5)) >> 2) * ((CM_COLOR_SAT_MAX - CM_COLOR_SAT_MIN) / 63) + CM_COLOR_SAT_MIN
	var/l = (hex2num(copytext(hash, 5, 7)) >> 2) * ((CM_COLOR_LUM_MAX - CM_COLOR_LUM_MIN) / 63) + CM_COLOR_LUM_MIN

	// adjust for shifts
	s = clamp(s * sat_shift, 0, 1)
	l = clamp(l * lum_shift, 0, 1)

	// convert to rgb
	var/h_int = round(h/60) // mapping each section of H to 60 degree sections
	var/c = (1 - abs(2 * l - 1)) * s
	var/x = c * (1 - abs((h / 60) % 2 - 1))
	var/m = l - c * 0.5
	x = (x + m) * 255
	c = (c + m) * 255
	m *= 255
	switch(h_int)
		if(0)
			return "#[num2hex(c, 2)][num2hex(x, 2)][num2hex(m, 2)]"
		if(1)
			return "#[num2hex(x, 2)][num2hex(c, 2)][num2hex(m, 2)]"
		if(2)
			return "#[num2hex(m, 2)][num2hex(c, 2)][num2hex(x, 2)]"
		if(3)
			return "#[num2hex(m, 2)][num2hex(x, 2)][num2hex(c, 2)]"
		if(4)
			return "#[num2hex(x, 2)][num2hex(m, 2)][num2hex(c, 2)]"
		if(5)
			return "#[num2hex(c, 2)][num2hex(m, 2)][num2hex(x, 2)]"
