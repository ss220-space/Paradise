/datum/component/wall_regenerate
	var/turf/simulated/wall/current

/datum/component/wall_regenerate/Initialize()
	current = parent
	START_PROCESSING(SSprocessing, src)

/datum/component/wall_regenerate/process()
	if(current.damage-5 < 0)
		current.damage = 0
		current.update_damage()
	else if(current.damage > 0)
		current.damage -= 5
		current.update_damage()

/datum/component/obj_regenerate
	var/obj/current

/datum/component/obj_regenerate/Initialize()
	current = parent
	START_PROCESSING(SSprocessing, src)

/datum/component/obj_regenerate/process()
	if(current.obj_integrity > current.max_integrity-5)
		current.obj_integrity = current.max_integrity
		current.update_icon()
	else if(current.obj_integrity < current.max_integrity)
		current.obj_integrity += 5
		current.update_icon()


