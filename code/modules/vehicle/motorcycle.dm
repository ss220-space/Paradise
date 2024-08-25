/obj/vehicle/motorcycle
	name = "motorcycle"
	desc = "A fast and highly maneuverable vehicle."
	icon = 'icons/obj/vehicles/motorcycle.dmi'
	icon_state = "motorcycle_4dir"
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

