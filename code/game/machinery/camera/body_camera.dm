/obj/item/body_camera
	name = "BodyCam"
	desc = ""
	icon = 'icons/obj/monitors.dmi'
	icon_state = "gopro_camera"
	item_state = "gopro_camera"
	slot_flags = SLOT_EARS

	var/obj/machinery/camera/camera = null


/obj/item/body_camera/examine(mob/user)
	. = ..()
	. += "<span class='info>Камера [camera.status ? "в" : "вы"]ключена.</span>"

/obj/item/body_camera/Initialize(mapload)
	. = ..()
	camera = new(src)
	camera.c_tag = "Body Camera"
	camera.network = list("SS13")
	toggle()
	RegisterSignal(src, COMSIG_ITEM_PICKUP, .proc/was_pickedup)
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, .proc/was_pickedup)
	RegisterSignal(src, COMSIG_ITEM_DROPPED, .proc/was_dropped)

/obj/item/body_camera/Destroy()
	. = ..()
	QDEL_NULL(camera)

/obj/item/body_camera/emp_act(severity)
	. = ..()
	camera.emp_act(severity)

/obj/item/body_camera/attack_self(mob/user)
	. = ..()
	toggle(user)

/obj/item/body_camera/proc/toggle(mob/user)
	camera.status = !camera.status
	if(camera.status)
		GLOB.cameranet.cameras += camera
		GLOB.cameranet.addCamera(camera)
		if(user)
			to_chat(user, "<span class='notice'>Ты включаешь камеру.</span>")
	else
		GLOB.cameranet.cameras -= camera
		GLOB.cameranet.removeCamera(camera)
		if(user)
			to_chat(user, "<span class='notice'>Ты выключаешь камеру.</span>")

/obj/item/body_camera/verb/change_name()
	set category = "Objects"
	set name = "Change network name"
	set src in view(1, usr)

	var/new_name = input(usr, "Введи новое название камеры") as text|null
	if(!new_name)
		return
	new_name = sanitize(new_name)
	if(length(new_name) > 24)
		to_chat(usr, "<span class='warning'>Название слишком длинное!</span>")
		return
	if(findtext(new_name, "BodyCam ") != 1)
		new_name = addtext("BodyCam ", new_name)
	camera.c_tag = new_name

/obj/item/body_camera/on_enter_storage(obj/item/storage/S)
	. = ..()
	if(camera.status)
		toggle()

/obj/item/body_camera/on_exit_storage(obj/item/storage/S)
	. = ..()
	if(!ismob(S.loc))
		return
	var/mob/user = S.loc
	was_pickedup(src, user)

/obj/item/body_camera/proc/was_pickedup(datum/source, mob/user)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/update_position, override = TRUE)
	RegisterSignal(user, COMSIG_MOVABLE_HOLDER_MOVED, .proc/update_position, override = TRUE)

/obj/item/body_camera/proc/was_dropped(datum/source, mob/user)
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_HOLDER_MOVED))

/obj/item/body_camera/proc/update_position(datum/source, turf/oldLoc)
	if(!camera || !camera.status)
		return
	if(oldLoc == get_turf(loc))
		return
	GLOB.cameranet.updatePortableCamera(camera)

