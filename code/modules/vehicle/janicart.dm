/**
 * # Janicart
 */
/obj/vehicle/ridden/janicart
	name = "janicart (pimpin' ride)"
	desc = "A brave janitor cyborg gave its life to produce such an amazing combination of speed and utility."
	icon_state = "pussywagon"
	key_type = /obj/item/key/janitor
	movedelay = 1
	/// The attached garbage bag, if present
	var/obj/item/storage/bag/trash/trash_bag
	/// The installed upgrade, if present
	var/obj/item/janiupgrade/installed_upgrade

/obj/vehicle/ridden/janicart/Initialize(mapload)
	. = ..()
	update_appearance()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/janicart)


/obj/vehicle/ridden/janicart/Destroy()
	if(trash_bag)
		QDEL_NULL(trash_bag)
	if(installed_upgrade)
		QDEL_NULL(installed_upgrade)
	return ..()

/obj/vehicle/ridden/janicart/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(. && installed_upgrade && isturf(loc))
		loc.clean_blood()
		for(var/obj/effect/check in loc)
			if(check.is_cleanable())
				qdel(check)


/obj/vehicle/ridden/janicart/examine(mob/user)
	. = ..()
	if(installed_upgrade)
		. += "It has been upgraded with [installed_upgrade], which can be removed with a screwdriver."

/obj/vehicle/ridden/janicart/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(istype(I, /obj/item/storage/bag/trash))
		add_fingerprint(user)
		if(trash_bag)
			balloon_alert(user, "уже прицеплено!")
			return ATTACK_CHAIN_PROCEED
		if(!user.transfer_item_to_loc(I, src))
			return ..()
		balloon_alert(user, "прицеплено к машине")
		trash_bag = I
		update_appearance()
		return ATTACK_CHAIN_BLOCKED_ALL

	else if(istype(I, /obj/item/janiupgrade))
		if(installed_upgrade)
			balloon_alert(user, "уже установлено!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		var/obj/item/janiupgrade/new_upgrade = I
		new_upgrade.forceMove(src)
		installed_upgrade = new_upgrade
		balloon_alert(user, "установлено")
		update_appearance()
		return ATTACK_CHAIN_BLOCKED_ALL

	else if(istype(I, /obj/item/screwdriver) && installed_upgrade)
		installed_upgrade.forceMove(get_turf(user))
		user.put_in_hands(installed_upgrade)
		balloon_alert(user, "удалено")
		installed_upgrade = null
		update_appearance()
		return ATTACK_CHAIN_BLOCKED_ALL

	else if(trash_bag && (!is_key(I) || is_key(inserted_key))) // don't put a key in the trash when we need it
		trash_bag.attackby(I, user, params)
		return ATTACK_CHAIN_BLOCKED_ALL
	else
		return ..()


/obj/vehicle/ridden/janicart/update_overlays()
	. = ..()
	if(trash_bag)
		if(istype(trash_bag, /obj/item/storage/bag/trash/bluespace))
			. += "cart_bluespace_garbage"
		else
			. += "cart_garbage"
	if(installed_upgrade)
		. += "cart_buffer"

/obj/vehicle/ridden/janicart/attack_hand(mob/user)
	if(..())
		return TRUE
	else if(trash_bag)
		trash_bag.forceMove_turf()
		user.put_in_hands(trash_bag, ignore_anim = FALSE)
		trash_bag = null
		update_icon(UPDATE_OVERLAYS)

/obj/item/janiupgrade
	name = "floor buffer upgrade"
	desc = "An upgrade for mobile janicarts."
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "upgrade"
	origin_tech = "materials=3;engineering=4"
