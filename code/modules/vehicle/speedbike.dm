/obj/vehicle/ridden/speedbike
	name = "Speedbike"
	icon = 'icons/obj/vehicles/bike.dmi'
	icon_state = "speedbike_blue"
	var/overlay_state = "cover_blue"
	var/mutable_appearance/cover_overlay


/obj/vehicle/ridden/speedbike/Initialize(mapload)
	. = ..()
	cover_overlay = mutable_appearance(icon, overlay_state, ABOVE_MOB_LAYER)
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/speedbike)


/obj/vehicle/ridden/speedbike/Destroy()
	cover_overlay = null
	return ..()


/obj/vehicle/ridden/speedbike/update_overlays()
	. = ..()
	if(!has_buckled_mobs())
		return .
	. += cover_overlay



/obj/vehicle/ridden/speedbike/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(has_buckled_mobs())
		new /obj/effect/temp_visual/dir_setting/speedbike_trail(loc, direct)
	return ..()

/obj/vehicle/ridden/speedbike/red
	icon_state = "speedbike_red"
	overlay_state = "cover_red"
