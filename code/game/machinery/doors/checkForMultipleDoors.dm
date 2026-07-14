/obj/machinery/door/proc/checkForMultipleDoors()
	if(!loc)
		return 0
	for(var/obj/machinery/door/door in loc)
		if(!istype(door, /obj/machinery/door/window) && door.density)
			return 0
	return 1

/turf/simulated/wall/proc/checkForMultipleDoors()
	if(!loc)
		return 0
	for(var/obj/machinery/door/door in locate(x,y,z))
		if(!istype(door, /obj/machinery/door/window) && door.density)
			return 0
	//There are no false wall checks because that would be foolish
	return 1
