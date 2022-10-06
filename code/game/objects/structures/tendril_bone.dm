/obj/structure/tendril_bone
	name = "bone tendril"
	desc = "A bone tendril."
	max_integrity = 300
	climbable = FALSE
	anchored = TRUE
	color = "#fffff0"

	icon = 'icons/obj/tendril_bone.dmi'
	icon_state = "tendril_bone"
	//tile_key = "tendril_bone"

/obj/structure/tendril_bone/Initialize(mapload)
	. = ..()

/obj/structure/tendril_bone/Destroy()
	. = ..()

/obj/structure/tendril_bone/small
	max_integrity = 200
	icon = 'icons/obj/tendril_bone.dmi'
	icon_state = "tendril_bone_small"
	//tile_key = "tendril_bone_small"
