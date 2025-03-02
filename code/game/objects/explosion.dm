//TODO: Flash range does nothing currently

#define CREAK_DELAY 5 SECONDS //Time taken for the creak to play after explosion, if applicable.
#define DEVASTATION_PROB 30 //The probability modifier for devistation, maths!
#define HEAVY_IMPACT_PROB 5 //ditto
#define FAR_UPPER 60 //Upper limit for the far_volume, distance, clamped.
#define FAR_LOWER 40 //lower limit for the far_volume, distance, clamped.
#define PROB_SOUND 75 //The probability modifier for a sound to be an echo, or a far sound. (0-100)
#define SHAKE_CLAMP 2.5 //The limit for how much the camera can shake for out of view booms.
#define FREQ_UPPER 40 //The upper limit for the randomly selected frequency.
#define FREQ_LOWER 25 //The lower of the above.

/client/proc/check_bomb_impacts()
	set name = "Check Bomb Impact"
	set category = "Debug"

	var/newmode = alert("Use reactionary explosions?","Check Bomb Impact", "Yes", "No")
	var/zmode = alert("Use Multi-Z explosions?","Check Bomb Impact,", "Yes", "No")
	var/turf/epicenter = get_turf(mob)
	if(!epicenter)
		return

	to_chat(usr, span_notice("Check Bomb Impact epicenter is: [COORD(epicenter)]"))
	var/dev = 0
	var/heavy = 0
	var/light = 0
	var/list/choices = list("Small Bomb","Medium Bomb","Big Bomb","Custom Bomb")
	var/choice = input("Bomb Size?") in choices
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			dev = 1
			heavy = 2
			light = 3
		if("Medium Bomb")
			dev = 2
			heavy = 3
			light = 4
		if("Big Bomb")
			dev = 3
			heavy = 5
			light = 7
		if("Custom Bomb")
			dev = input("Devestation range (Tiles):") as num
			heavy = input("Heavy impact range (Tiles):") as num
			light = input("Light impact range (Tiles):") as num

	var/max_range = max(dev, heavy, light)
	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/z0 = epicenter.z
	var/list/wipe_colours = list()
	var/list/affected_turfs = spiral_range_turfs(max_range, epicenter)
	var/list/epicenter_list = list(epicenter)
	var/list/floor_block = list() // [z] = num_block
	if(zmode == "Yes")
		var/turf/above = GET_TURF_ABOVE(epicenter)
		var/turf/below = GET_TURF_BELOW(epicenter)
		floor_block["[z0]"] = epicenter.explosion_vertical_block
		if(above)
			affected_turfs += spiral_range_turfs(max_range, above)
			epicenter_list += above
			floor_block["[above.z]"] = above.explosion_vertical_block
		if(below)
			affected_turfs += spiral_range_turfs(max_range, below)
			epicenter_list += below
			floor_block["[below.z]"] = below.explosion_vertical_block
	for(var/turf/T in affected_turfs)
		wipe_colours += T
		var/dist = HYPOTENUSE(T.x, T.y, x0, y0)
		if((zmode == "Yes") && (T.z != z0))
			if(T.z < z0)
				dist += floor_block["[T.z + 1]"] + 1
			else
				dist += floor_block["[T.z]"] + 1

		if(newmode == "Yes")
			var/turf/TT = T
			while(!(TT in epicenter_list))
				TT = get_step_towards(TT,epicenter)
				if(TT.density)
					dist += TT.explosion_block

				for(var/obj/O in T)
					var/the_block = O.explosion_block
					dist += the_block == EXPLOSION_BLOCK_PROC ? O.get_explosion_block() : the_block

		if(dist < dev)
			T.color = "red"
			T.maptext = "Dev"
		else if(dist < heavy)
			T.color = "yellow"
			T.maptext = "Heavy"
		else if(dist < light)
			T.color = "blue"
			T.maptext = "Light"
		else
			continue

	sleep(100)
	for(var/turf/T in wipe_colours)
		T.color = null
		T.maptext = ""

#undef CREAK_DELAY
#undef DEVASTATION_PROB
#undef HEAVY_IMPACT_PROB
#undef FAR_UPPER
#undef FAR_LOWER
#undef PROB_SOUND
#undef SHAKE_CLAMP
#undef FREQ_UPPER
#undef FREQ_LOWER
