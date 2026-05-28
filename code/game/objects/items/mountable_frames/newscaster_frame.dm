/obj/item/mounted/frame/newscaster_frame
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	item_state = "syringe_kit"
	materials = list(MAT_METAL = 6000, MAT_GLASS = 2000)
	mount_requirements = MOUNTED_FRAME_SIMFLOOR | MOUNTED_FRAME_NOSPACE
	metal_sheets_refunded = 3
	glass_sheets_refunded = 1

/obj/item/mounted/frame/newscaster_frame/do_build(turf/on_wall, mob/user)
	var/obj/machinery/newscaster/newscaster = new /obj/machinery/newscaster(get_turf(src), get_dir(on_wall, user), 1)
	newscaster.pixel_y -= (loc.y - on_wall.y) * 32
	newscaster.pixel_x -= (loc.x - on_wall.x) * 32
	newscaster.add_fingerprint(user)
	qdel(src)
