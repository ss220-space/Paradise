//MISC items
//These items don't belong anywhere else, so they have this file.

//Current contents:
/*
	Cursor Drag Pointer
	Beach Ball
	Mouse Jetpack
*/

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER


/obj/item/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	density = FALSE
	anchored = FALSE
	w_class = WEIGHT_CLASS_TINY
	force = 0.0
	throwforce = 0.0
	throw_speed = 1
	throw_range = 20
	flags = CONDUCT
	item_flags = NO_PIXEL_RANDOM_DROP


/obj/item/mouse_jet
	name = "improvised mini-jetpack"
	desc = "A roughly made jetpack designed for satisfy extremely small persons."
	icon_state = "jetpack_mouse"
	icon = 'icons/obj/tank.dmi'
	w_class = WEIGHT_CLASS_SMALL
