/obj/vehicle/ridden/motorcycle
	name = "motorcycle"
	desc = "A fast and highly maneuverable vehicle."
	icon = 'icons/obj/vehicles/motorcycle.dmi'
	icon_state = "motorcycle_4dir"
	var/mutable_appearance/bikecover


/obj/vehicle/ridden/motorcycle/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/motorcycle)
	if(!bikecover)
		bikecover = mutable_appearance(icon, "motorcycle_4dir_overlay", ABOVE_MOB_LAYER)


/obj/vehicle/ridden/motorcycle/Destroy()
	bikecover = null
	return ..()


/obj/vehicle/ridden/motorcycle/update_overlays()
	. = ..()
	if(!has_buckled_mobs())
		return .
	. += bikecover

