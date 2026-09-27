/obj/item/mounted/frame/firealarm
	name = "fire alarm frame"
	desc = "Used for building Fire Alarms"
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "fire_bitem"
	mount_requirements = MOUNTED_FRAME_SIMFLOOR | MOUNTED_FRAME_NOSPACE

/obj/item/mounted/frame/firealarm/do_build(turf/on_wall, mob/user)
	var/obj/machinery/firealarm/alarm = new(get_turf(src), get_dir(user, on_wall), 1)
	alarm.add_fingerprint(user)
	qdel(src)
