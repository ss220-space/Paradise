/obj/machinery/door/poddoor/shutters
	gender = PLURAL
	name = "shutters"
	desc = "Heavy duty metal shutters that open mechanically."
	icon = 'icons/obj/doors/shutters.dmi'
	icon_state = "closed"
	layer = SHUTTER_LAYER
	closingLayer = SHUTTER_LAYER
	damage_deflection = 20
	dir = EAST

/obj/machinery/door/poddoor/shutters/invincible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	hackable = FALSE

/obj/machinery/door/poddoor/shutters/preopen
	icon_state = "open"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/poddoor/shutters/preopen/invincible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	hackable = FALSE

/obj/machinery/door/poddoor/shutters/invincible/fake_r_wall
	name = "reinforced wall"
	desc = "Effectively impervious to conventional methods of destruction."
	icon = 'icons/obj/doors/fake_wall_shutters.dmi'
	icon_state = "closed"
