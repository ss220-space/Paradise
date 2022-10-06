/obj/structure/tendril
	name = "bone tendril"
	desc = "A bone tendril."
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
	max_integrity = 200
	icon = 'icons/obj/tendril.dmi'
	icon_state = "tendril_small"
