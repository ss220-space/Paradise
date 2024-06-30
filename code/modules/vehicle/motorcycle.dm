/obj/vehicle/motorcycle
	name = "motorcycle"
	desc = "A fast and highly maneuverable vehicle."
	icon = 'icons/obj/vehicles/motorcycle.dmi'
	icon_state = "motorcycle_4dir"
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 0.25 SECONDS
	var/mutable_appearance/bikecover


/obj/vehicle/motorcycle/Initialize(mapload)
	. = ..()
	bikecover = mutable_appearance(icon, "motorcycle_4dir_overlay", ABOVE_MOB_LAYER)


/obj/vehicle/motorcycle/Destroy()
	bikecover = null
	return ..()


/obj/vehicle/motorcycle/update_overlays()
	. = ..()
	if(!has_buckled_mobs())
		return .
	. += bikecover


/obj/vehicle/motorcycle/handle_vehicle_icons()
	update_icon(UPDATE_OVERLAYS)


/obj/vehicle/motorcycle/handle_vehicle_layer()
	return

