/datum/component/wall_regenerate
	var/turf/simulated/wall/current

/datum/component/wall_regenerate/Initialize()
	RegisterSignal(parent, list(COMSIG_TURF_CHANGE), PROC_REF(stop_regen))
	current = parent
	START_PROCESSING(SSprocessing, src)

/datum/component/wall_regenerate/process()
	if(current.damage > 0)
		current.damage -= 5
		current.update_damage()

/datum/component/wall_regenerate/proc/stop_regen()
	STOP_PROCESSING(SSprocessing, src)

/datum/component/obj_regenerate
	var/obj/current

/datum/component/obj_regenerate/Initialize()
	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), PROC_REF(stop_regen))
	current = parent
	START_PROCESSING(SSprocessing, src)

/datum/component/obj_regenerate/process()
	if(current.obj_integrity < current.max_integrity)
		current.obj_integrity += 5
		current.update_icon()

/datum/component/obj_regenerate/proc/stop_regen()
	STOP_PROCESSING(SSprocessing, src)

