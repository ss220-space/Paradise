//PIMP-CART
/obj/vehicle/janicart
	name = "janicart (pimpin' ride)"
	desc = "A brave janitor cyborg gave its life to produce such an amazing combination of speed and utility."
	icon_state = "pussywagon"
	key_type = /obj/item/key/janitor
	var/obj/item/storage/bag/trash/trash_bag
	var/floorbuffer = FALSE

/obj/vehicle/janicart/Destroy()
	QDEL_NULL(trash_bag)
	return ..()


/obj/vehicle/janicart/handle_vehicle_offsets()
	if(!has_buckled_mobs())
		return
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		buckled_mob.setDir(dir)
		switch(dir)
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -12
				buckled_mob.pixel_y = 7
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 12
				buckled_mob.pixel_y = 7


/obj/vehicle/janicart/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(. && floorbuffer && isturf(loc))
		loc.clean_blood()
		for(var/obj/effect/check in loc)
			if(check.is_cleanable())
				qdel(check)


/obj/vehicle/janicart/examine(mob/user)
	. = ..()
	if(floorbuffer)
		. += span_notice("It has been upgraded with a floor buffer.")


/obj/vehicle/janicart/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/storage/bag/trash))
		add_fingerprint(user)
		if(trash_bag)
			balloon_alert(user, "уже прицеплено!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		balloon_alert(user, "прицеплено к машине")
		trash_bag = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/janiupgrade))
		add_fingerprint(user)
		if(floorbuffer)
			balloon_alert(user, "уже установлено!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		floorbuffer = TRUE
		balloon_alert(user, "установлено")
		update_icon(UPDATE_OVERLAYS)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(trash_bag && (initial(key_type.type) != I.type)) // don't put a key in the trash when we need it
		trash_bag.attackby(I, user, params)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/vehicle/janicart/update_overlays()
	. = ..()
	if(trash_bag)
		. += "cart_garbage"
	if(floorbuffer)
		. += "cart_buffer"


/obj/vehicle/janicart/attack_hand(mob/user)
	if(..())
		return TRUE
	else if(trash_bag)
		trash_bag.forceMove_turf()
		user.put_in_hands(trash_bag, ignore_anim = FALSE)
		trash_bag = null
		update_icon(UPDATE_OVERLAYS)

/obj/item/key/janitor
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "keyjanitor"

/obj/item/janiupgrade
	name = "floor buffer upgrade"
	desc = "An upgrade for mobile janicarts."
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "upgrade"
	origin_tech = "materials=3;engineering=4"
