/obj/structure/tendril
	name = "tendril"
	desc = "A tendril."
	max_integrity = 300
	climbable = FALSE
	anchored = TRUE

	icon = 'icons/obj/tendril.dmi'
	icon_state = "tendril"

/obj/structure/tendril_bone/Initialize(mapload)
	. = ..()

/obj/structure/tendril_bone/Destroy()
	. = ..()

/obj/structure/tendril_bone/small
	name = "small tendril"
	desc = "A small tendril."
	max_integrity = 200
	icon = 'icons/obj/tendril.dmi'
	icon_state = "tendril_small"
