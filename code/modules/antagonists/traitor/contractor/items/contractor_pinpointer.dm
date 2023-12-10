/obj/item/pinpointer/crew/contractor
	name = "contractor pinpointer"
	desc = "A handheld tracking device that points to crew without needing suit sensors at the cost of accuracy."
	icon_state = "pinoff_contractor"
	icon_off = "pinoff_contractor"
	icon_null = "pinonnull_contractor"
	icon_direct = "pinondirect_contractor"
	icon_close = "pinonclose_contractor"
	icon_medium = "pinonmedium_contractor"
	icon_far = "pinonfar_contractor"
	/// The minimum range for the pinpointer to function properly.
	var/min_range = 15
	/// The first person to have used the item. If this is set already, no one else can use it.
	var/mob/owner


/obj/item/pinpointer/crew/contractor/update_icon_state()
	if(mode == 0)	// MODE_OFF
		icon_state = icon_off
		return

	if(!target)
		icon_state = icon_null
		return

	if(ISINRANGE(prev_dist, -1, min_range))
		icon_state = icon_direct
	else if(ISINRANGE(prev_dist, min_range + 1, min_range + 8))
		icon_state = icon_close
	else if(ISINRANGE(prev_dist, min_range + 9, min_range + 16))
		icon_state = icon_medium
	else if(ISINRANGE(prev_dist, min_range + 16, INFINITY))
		icon_state = icon_far


/obj/item/pinpointer/crew/contractor/is_trackable(mob/living/carbon/human/pin_target)
	source_turf = get_turf(src)
	target_turf = get_turf(pin_target)
	return source_turf && target_turf && source_turf.z == target_turf.z


/obj/item/pinpointer/crew/contractor/cycle(mob/user, silent = FALSE)
	if(owner)
		if(owner != user)
			to_chat(user, span_warning("[src] refuses to do anything."))
			return
	else
		owner = user
		to_chat(user, span_notice("[src] now recognizes you as its sole user."))
	return ..()

