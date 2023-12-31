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
	layer = OBJ_LAYER - 0.1
	anchored = TRUE


/obj/structure/garland/wirecutter_act(mob/living/user, obj/item/wirecutters/I)
	. = ..()
	I.play_tool_sound(src, I.tool_volume)
	to_chat(user, span_notice("You cut garland apart."))
	deconstruct()

/obj/structure/garland/wrench_act(mob/living/user, obj/item/wrench/I)
	. = ..()
	I.play_tool_sound(src, I.tool_volume)
	anchored = !anchored
	to_chat(user, span_notice("You [anchored ? "un" : ""]wrenched [src]"))

/obj/structure/garland/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/wirecutters) || istype(P, /obj/item/wrench))
		return
	return ..()
