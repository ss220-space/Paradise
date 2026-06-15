/obj/item/mounted/frame/intercom
	name = "intercom frame"
	desc = "Used for building intercoms"
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "intercom-frame"
	mount_requirements = MOUNTED_FRAME_SIMFLOOR | MOUNTED_FRAME_NOSPACE
	metal_sheets_refunded = 2

/obj/item/mounted/frame/intercom/try_build(turf/on_wall, mob/user)
	if(!..())
		return FALSE

	var/turf/build_turf = get_turf(user)
	for(var/obj/item/radio/intercom/I in build_turf)
		to_chat(user, span_warning("There is already an intercom here!"))
		return FALSE

	return TRUE

/obj/item/mounted/frame/intercom/do_build(turf/on_wall, mob/user)
	new /obj/item/radio/intercom(get_turf(src), get_dir(user, on_wall), 0)
	qdel(src)
