//Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/bodybag/attack_self(mob/user)
	var/obj/structure/closet/body_bag/R = new /obj/structure/closet/body_bag(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	open_sound = 'sound/items/zip.ogg'
	close_sound = 'sound/items/zip.ogg'
	open_sound_volume = 15
	close_sound_volume = 15
	density = FALSE
	integrity_failure = FALSE
	var/item_path = /obj/item/bodybag


/obj/structure/closet/body_bag/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		var/t = rename_interactive(user, I)
		if(isnull(t))
			return
		if(t)
			update_icon(UPDATE_OVERLAYS)
		return
	if(istype(I, /obj/item/wirecutters))
		to_chat(user, "<span class='notice'>You cut the tag off the bodybag.</span>")
		name = initial(name)
		update_icon(UPDATE_OVERLAYS)
		return
	return ..()


/obj/structure/closet/body_bag/close()
	if(..())
		density = FALSE
		return TRUE
	return FALSE


/obj/structure/closet/body_bag/update_icon_state()
	icon_state = opened ? icon_opened : icon_closed


/obj/structure/closet/body_bag/update_overlays()
	. = list()
	if(name != initial(name))
		. += "bodybag_label"


/obj/structure/closet/body_bag/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(over_object == usr && ishuman(usr) && !usr.incapacitated() && !opened && !length(contents) && usr.Adjacent(src))
		usr.visible_message(
			span_notice("[usr] folds up [src]."),
			span_notice("You fold up [src]."),
		)
		new item_path(get_turf(src))
		qdel(src)
		return FALSE
	return ..()


/obj/structure/closet/body_bag/relaymove(mob/user as mob)
	if(user.stat)
		return

	// Make it possible to escape from bodybags in morgues and crematoriums
	if(loc && (isturf(loc) || istype(loc, /obj/structure/morgue) || istype(loc, /obj/machinery/crematorium)))
		if(!open())
			to_chat(user, "<span class='notice'>It won't budge!</span>")

/obj/item/bluespace_bag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL
	var/obj/structure/closet/body_bag/bluespace/bag

/obj/item/bluespace_bag/Destroy()
	. = ..()

/obj/item/bluespace_bag/New()
	. = ..()
	bag = new
	bag.bag = src

/obj/item/bluespace_bag/Initialize(mapload)
	RegisterSignal(src, COMSIG_PARENT_PREQDELETED, PROC_REF(pre_gib))
	. = ..()

/obj/item/bluespace_bag/proc/pre_gib()
	visible_message("пиздец")
	unfold()
	bag.bust_open()

/obj/item/bluespace_bag/attack_self(mob/user)
	unfold(user)

/obj/item/bluespace_bag/proc/unfold(mob/user)
	if(user)
		user.drop_item_ground(src)
	bag.forceMove(get_turf(src))
	src.forceMove(null)

/obj/structure/closet/body_bag/bluespace
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	open_sound = 'sound/items/zip.ogg'
	close_sound = 'sound/items/zip.ogg'
	open_sound_volume = 15
	close_sound_volume = 15
	density = FALSE
	integrity_failure = FALSE
	var/obj/item/bluespace_bag/bag

/obj/structure/closet/body_bag/bluespace/AltClick(mob/user)
	fold(user)
	. = ..()

/obj/structure/closet/body_bag/bluespace/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	fold(usr)
	return ..()

/obj/structure/closet/body_bag/bluespace/proc/fold(mob/living/carbon/human/user)
	if(ishuman(usr) && !usr.incapacitated() && !broken && !opened && usr.Adjacent(src))
		usr.visible_message(
			span_notice("[usr] folds up [src]."),
			span_notice("You fold up [src]."),
		)
		bag.forceMove(get_turf(src))
		src.forceMove(bag)
		user.put_in_hands(bag)

