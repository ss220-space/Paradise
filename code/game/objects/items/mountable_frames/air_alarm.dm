/// Handheld air alarm frame, for placing on walls.
/obj/item/mounted/frame/alarm_frame
	name = "air alarm frame"
	desc = "Used for building air alarms."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "alarm_bitem"
	materials = list(MAT_METAL = 2000)
	metal_sheets_refunded = 1
	mount_requirements = MOUNTED_FRAME_SIMFLOOR | MOUNTED_FRAME_NOSPACE

/obj/item/mounted/frame/alarm_frame/do_build(turf/on_wall, mob/user)
	var/obj/machinery/alarm/alarm = new(get_turf(src), get_dir(user, on_wall), 1)
	alarm.buildstage = AIR_ALARM_BUILD_NO_CIRCUIT // Set the build stage to the initial state
	alarm.update_icon()
	alarm.add_fingerprint(user)
	qdel(src)
