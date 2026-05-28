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
