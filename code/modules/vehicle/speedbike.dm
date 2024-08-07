/obj/vehicle/space/speedbike
	name = "Speedbike"
	icon = 'icons/obj/vehicles/bike.dmi'
	icon_state = "speedbike_blue"
	vehicle_move_delay = 0.15 SECONDS
	var/overlay_state = "cover_blue"
	var/mutable_appearance/cover_overlay


/obj/vehicle/space/speedbike/Initialize(mapload)
	. = ..()
	cover_overlay = mutable_appearance(icon, overlay_state, ABOVE_MOB_LAYER)


/obj/vehicle/space/speedbike/Destroy()
	cover_overlay = null
	return ..()


/obj/vehicle/space/speedbike/update_overlays()
	. = ..()
	if(!has_buckled_mobs())
		return .
	. += cover_overlay


/obj/vehicle/space/speedbike/handle_vehicle_icons()
	update_icon(UPDATE_OVERLAYS)


/obj/vehicle/space/speedbike/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(has_buckled_mobs())
		new /obj/effect/temp_visual/dir_setting/speedbike_trail(loc, direct)
	return ..()


/obj/vehicle/space/speedbike/handle_vehicle_layer()
	return


/obj/vehicle/space/speedbike/handle_vehicle_offsets()
	switch(dir)
		if(NORTH, SOUTH)
			pixel_x = -16
			pixel_y = -16
		if(EAST, WEST)
			pixel_x = -18
			pixel_y = 0
	if(!has_buckled_mobs())
		return
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		buckled_mob.setDir(dir)
		switch(dir)
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = -8
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -10
				buckled_mob.pixel_y = 5
			if(WEST)
				buckled_mob.pixel_x = 10
				buckled_mob.pixel_y = 5


/obj/vehicle/space/speedbike/red
	icon_state = "speedbike_red"
	overlay_state = "cover_red"
