/**
 * New year celebration stuff. Yeah :D
 */
/obj/structure/garland
	name = "garland"
	desc = "It's a glowey garland."
	icon = 'icons/obj/new_year/decorations.dmi'
	icon_state = "garland_on"
	max_integrity = 10 //can be removed easily
	density = FALSE
	layer = ABOVE_OBJ_LAYER + 0.1


/obj/structure/garland/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	qdel(src)
