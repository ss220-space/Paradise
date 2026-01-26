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
	if(istype(target, /mob))
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
