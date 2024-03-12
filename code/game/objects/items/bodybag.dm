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
	if(I.tool_behaviour == TOOL_WIRECUTTER)
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

/obj/item/bodybag/biohazard
	name = "biohazard bodybag"
	desc = "A folded bag designed for the storage and transportation of infected cadavers."
	icon_state = "bodybag_biohazard_folded"

/obj/structure/closet/body_bag/biohazard
	name = "biohazard body bag"
	desc = "A plastic bag designed for the storage and transportation of infected cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_biohazard_closed"
	icon_closed = "bodybag_biohazard_closed"
	icon_opened = "bodybag_biohazard_open"
	item_path = /obj/item/bodybag/biohazard

/obj/item/bodybag/biohazard/attack_self(mob/user)
	var/obj/structure/closet/body_bag/biohazard/R = new /obj/structure/closet/body_bag/biohazard(user.loc)
	R.add_fingerprint(user)
	qdel(src)
