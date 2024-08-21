
//	var/turf/T | This was made 14th September 2013, and has no use at all. Its being removed

/obj/item/grenade/bananade
	name = "bananade"
	desc = "A yellow grenade."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "banana"
	item_state = "flashbang"
	var/deliveryamt = 8
	var/spawner_type = /obj/item/grown/bananapeel


/obj/item/grenade/bananade/prime()
	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		playsound(T, 'sound/items/bikehorn.ogg', 100, TRUE)
		for(var/mob/living/carbon/C in viewers(T, null))
			C.flash_eyes()
		for(var/i=1, i<=deliveryamt, i++)
			var/atom/movable/x = new spawner_type
			x.loc = T
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(x, pick(NORTH, SOUTH, EAST, WEST))
	qdel(src)


/obj/item/grenade/bananade/casing
	name = "bananium casing"
	desc = "A grenade casing made of bananium."
	icon_state = "banana_casing"
	var/fillamt = 0


/obj/item/grenade/bananade/casing/examine(mob/user)
	. = ..()
	. += span_info("Only banana peels fit in this assembly. Currently: <b>[fillamt]/9<b>.")


/obj/item/grenade/bananade/casing/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!fillamt)
		to_chat(user, span_warning("You need to add banana peels before you can ready the grenade."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	if(loc == user && !user.drop_item_ground(src))
		return .
	to_chat(user, span_notice("You lock the assembly shut, readying it for big HONK."))
	var/obj/item/grenade/bananade/bananade = new(drop_location())
	bananade.deliveryamt = fillamt
	bananade.add_fingerprint(user)
	user.put_in_hands(bananade, ignore_anim = FALSE)
	qdel(src)


/obj/item/grenade/bananade/casing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/grown/bananapeel))
		add_fingerprint(user)
		if(fillamt >= 9)
			to_chat(user, span_notice("The bananade is full, screwdriver it shut to lock it down."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You add another banana peel to the assembly."))
		fillamt++
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

