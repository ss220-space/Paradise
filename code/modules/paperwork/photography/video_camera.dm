GLOBAL_LIST_EMPTY(active_video_cameras)

/*
 * Video Camera
 */
/obj/item/videocam
	name = "video camera"
	icon = 'icons/obj/items.dmi'
	desc = "video camera that can send live feed to the entertainment network."
	icon_state = "videocam"
	item_state = "videocam"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=2000)
	var/on = FALSE
	var/video_cooldown = 0
	var/obj/machinery/camera/portable/camera
	var/canhear_range = 7

/obj/item/videocam/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += span_notice("This video camera can send live feeds to the entertainment network. It's [on ? "" : "in"]active.")

/obj/item/videocam/Destroy()
	if(on)
		camera_state()
	return ..()

/obj/item/videocam/update_icon_state()
	icon_state = "videocam[on ? "_on" : ""]"

/obj/item/videocam/proc/update_feeds()
	if(on)
		GLOB.active_video_cameras |= src
	else
		GLOB.active_video_cameras -= src

	for(var/obj/machinery/computer/security/telescreen/entertainment/TV in GLOB.machines)
		TV.update_icon(UPDATE_OVERLAYS)

/obj/item/videocam/proc/camera_state(mob/living/carbon/user)
	if(on)
		camera.c_tag = null
		QDEL_NULL(camera)
	else
		camera = new(src, list("news"), user.name)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	visible_message(span_notice("The video camera has been turned [on ? "on" : "off"]."))
	update_feeds()

/obj/item/videocam/attack_self(mob/user)
	if(world.time < video_cooldown)
		to_chat(user, span_warning("[src] is overheating, give it some time."))
		return
	camera_state(user)

/obj/item/videocam/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(on)
		camera_state()

/obj/item/videocam/hear_talk(mob/M, list/message_pieces)
	var/msg = multilingual_to_message(message_pieces)
	if(camera && on)
		if(get_dist(src, M) <= canhear_range)
			talk_into(M, msg)
		for(var/obj/machinery/computer/security/telescreen/T in GLOB.machines)
			if(T.watchers[M] == camera)
				T.atom_say(msg)

/obj/item/videocam/hear_message(mob/M, msg)
	if(camera && on)
		for(var/obj/machinery/computer/security/telescreen/T in GLOB.machines)
			if(T.watchers[M] == camera)
				T.atom_say(msg)

/obj/item/videocam/advanced
	name = "advanced video camera"
	desc = "This video camera allows you to send live feeds even when attached to a belt."
	slot_flags = ITEM_SLOT_BELT
