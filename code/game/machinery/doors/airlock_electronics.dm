/obj/item/airlock_electronics
	name = "airlock electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	origin_tech = "engineering=2;programming=1"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

	multitool_menu_type = /datum/multitool_menu/idtag/airlock_electronics
	
	var/id

/obj/item/airlock_electronics/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu_interact(user, I)

/obj/item/airlock_electronics/syndicate
	name = "suspicious airlock electronics"
