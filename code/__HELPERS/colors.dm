
/// Flash a color on the passed mob
/proc/flash_color(mob_or_client, flash_color=COLOR_CULT_RED, flash_time=20)
	var/client/C
	if(istype(mob_or_client, /mob))
		var/mob/M = mob_or_client
		if(M.client)
			C = M.client
		else
			return
	else if(isclient(mob_or_client))
		C = mob_or_client

	if(!istype(C))
		return

	C.color = flash_color
	spawn(0)
		animate(C, color = initial(C.color), time = flash_time)

#define RANDOM_COLOUR (rgb(rand(0,255),rand(0,255),rand(0,255)))
