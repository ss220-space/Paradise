/*
 * Camera Film Cartridge
 */
/obj/item/camera_film
	name = "film cartridge"
	icon = 'icons/obj/items.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/*
 * Spooky Camera
 */
/obj/item/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = 1

/obj/item/camera/spooky/CheckParts(list/parts_list)
	..()
	var/obj/item/camera/C = locate(/obj/item/camera) in contents
	if(C)
		pictures_max = C.pictures_max
		pictures_left = C.pictures_left
		visible_message("[C] has been imbued with godlike power!")
		qdel(C)

/obj/item/camera/proc/get_spooky_ghost()
	var/static/list/ghosts = list("ghost","shade","shade2","ghost-narsie","horror","shadow","ghostian2")
	return pick(ghosts)

/*
 * Photo Album
 */
/obj/item/storage/photo_album
	name = "Photo album"
	icon = 'icons/obj/items.dmi'
	icon_state = "album"
	item_state = "briefcase"
	can_hold = list(/obj/item/photo)
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound =  'sound/items/handling/book_pickup.ogg'
