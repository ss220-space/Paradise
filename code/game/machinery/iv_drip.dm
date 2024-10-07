#define IV_TAKING 0
#define IV_INJECTING 1

/obj/machinery/iv_drip
	name = "\improper IV drip"
	icon = 'icons/goonstation/objects/iv.dmi'
	icon_state = "stand"
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/item/reagent_containers/iv_bag/bag = null

/obj/machinery/iv_drip/process()
	if(istype(bag) && bag.injection_target)
		update_icon(UPDATE_OVERLAYS)
		return
	return PROCESS_KILL


/obj/machinery/iv_drip/update_overlays()
	. = ..()
	if(bag)
		. += "hangingbag"
		if(bag.reagents.total_volume)
			var/image/filling = image('icons/goonstation/objects/iv.dmi', src, "hangingbag-fluid")
			filling.icon += mix_color_from_reagents(bag.reagents.reagent_list)
			. += filling


/obj/machinery/iv_drip/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || !ishuman(usr) || !ishuman(over_object) || !Adjacent(over_object) || !usr.Adjacent(over_object))
		return FALSE

	add_fingerprint(usr)
	if(!bag)
		to_chat(usr, span_warning("There's no IV bag connected to [src]!"))
		return FALSE
	bag.attack(over_object, usr)
	START_PROCESSING(SSmachines, src)


/obj/machinery/iv_drip/attack_hand(mob/user)
	if(bag)
		add_fingerprint(user)
		bag.forceMove_turf()
		user.put_in_hands(bag, ignore_anim = FALSE)
		bag.update_icon(UPDATE_OVERLAYS)
		bag = null
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/iv_drip/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/reagent_containers/iv_bag))
		add_fingerprint(user)
		if(bag)
			to_chat(user, span_warning("[src] already has an IV bag!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		bag = I
		to_chat(user, span_notice("You attach [I] to [src]."))
		update_icon(UPDATE_OVERLAYS)
		START_PROCESSING(SSmachines, src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(bag && istype(I, /obj/item/reagent_containers))
		add_fingerprint(user)
		I.melee_attack_chain(user, bag, params)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/iv_drip/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc)
	qdel(src)

/obj/machinery/iv_drip/examine(mob/user)
	. = ..()
	if(bag)
		. += bag.examine(user)

/obj/machinery/iv_drip/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	if(!.) // ..() will return 0 if we didn't actually move anywhere.
		return .
	playsound(loc, pick('sound/items/cartwheel1.ogg', 'sound/items/cartwheel2.ogg'), 100, 1, ignore_walls = FALSE)

#undef IV_TAKING
#undef IV_INJECTING
