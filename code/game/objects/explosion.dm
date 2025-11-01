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
	var/choice = tgui_input_list(usr, "Bomb Size?", , choices)
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
			dev = tgui_input_number(usr, "Devestation range (Tiles):")
			heavy = tgui_input_number(usr, "Heavy impact range (Tiles):")
			light = tgui_input_number(usr, "Light impact range (Tiles):")

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
		var/dist = CHEAP_HYPOTENUSE(T.x, T.y, x0, y0)
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
			T.maptext = MAPTEXT("Dev")
		else if(dist < heavy)
			T.color = "yellow"
			T.maptext = MAPTEXT("Heavy")
		else if(dist < light)
			T.color = "blue"
			T.maptext = MAPTEXT("Light")
		else
			continue

	sleep(100)
	for(var/turf/T in wipe_colours)
		T.color = null
		T.maptext = ""

