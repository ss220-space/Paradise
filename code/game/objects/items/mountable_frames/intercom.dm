/obj/item/mounted/frame/intercom
	name = "Intercom Frame"
	desc = "Used for building intercoms"
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "intercom-frame"
	mount_requirements = MOUNTED_FRAME_SIMFLOOR | MOUNTED_FRAME_NOSPACE

/obj/item/mounted/frame/intercom/get_ru_names()
	return alist(
		NOMINATIVE = "корпус интеркома",
		GENITIVE = "корпуса интеркома",
		DATIVE = "корпусу интеркома",
		ACCUSATIVE = "корпус интеркома",
		INSTRUMENTAL = "корпусом интеркома",
		PREPOSITIONAL = "корпусе интеркома",
	)

/obj/item/mounted/frame/intercom/do_build(turf/on_wall, mob/user)
	new /obj/item/radio/intercom(get_turf(src), get_dir(user, on_wall), 0)
	qdel(src)
