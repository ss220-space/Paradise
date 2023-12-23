/**
 * New year celebration stuff. Yeah :D
 */
/obj/structure/garland
	name = "garland"
	desc = "It's a glowey garland."
	icon = 'icons/obj/new_year/decorations.dmi'
	icon_state = "garland_on"
	max_integrity = 24 //can be removed easily (also, symbolism)
	density = FALSE
	layer = ABOVE_OBJ_LAYER - 0.1
	anchored = TRUE


/obj/structure/garland/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deconstruct()

/obj/structure/garland/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/wirecutters))
		return
	return ..()
