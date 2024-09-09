/obj/item/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	item_state = "briefcase"
	flags = CONDUCT
	hitsound = "swing_hit"
	force = 8
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	resistance_flags = FLAMMABLE
	max_integrity = 150

/obj/item/storage/briefcase/sniperbundle
	desc = "Its label reads \"genuine hardened Captain leather\", but suspiciously has no other tags or branding. Smells like L'Air du Temps."
	force = 10

/obj/item/storage/briefcase/sniperbundle/populate_contents()
	new /obj/item/gun/projectile/automatic/sniper_rifle/syndicate(src)
	new /obj/item/clothing/accessory/red(src)
	new /obj/item/clothing/under/syndicate/sniper(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/suppressor/specialoffer(src)

/obj/item/storage/briefcase/false_bottomed
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 10

	var/busy_hunting = FALSE
	var/bottom_open = FALSE //is the false bottom open?
	var/obj/item/stored_item = null //what's in the false bottom. If it's a gun, we can fire it

/obj/item/storage/briefcase/false_bottomed/Destroy()
	if(stored_item)//since the stored_item isn't in the briefcase' contents we gotta remind the game to delete it here.
		QDEL_NULL(stored_item)
	return ..()

/obj/item/storage/briefcase/false_bottomed/afterattack(atom/A, mob/user, flag, params)
	..()
	if(stored_item && isgun(stored_item) && !Adjacent(A))
		var/obj/item/gun/stored_gun = stored_item
		stored_gun.afterattack(A, user, flag, params)


/obj/item/storage/briefcase/false_bottomed/attackby(obj/item/I, mob/user, params)
	if(bottom_open)
		add_fingerprint(user)
		if(stored_item)
			to_chat(user, span_warning("There's already something in the false bottom!"))
			return ATTACK_CHAIN_PROCEED
		if(I.w_class > WEIGHT_CLASS_NORMAL)
			to_chat(user, span_warning("The [I.name] is too big to fit in the false bottom!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		stored_item = I
		max_w_class = WEIGHT_CLASS_NORMAL - stored_item.w_class
		I.move_to_null_space() //null space here we go - to stop it showing up in the briefcase
		to_chat(user, span_notice("You place the [I] into the false bottom of the briefcase."))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/storage/briefcase/false_bottomed/screwdriver_act(mob/user, obj/item/I)
	if(!bottom_open && busy_hunting)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!bottom_open)
		to_chat(user, "You begin to hunt around the rim of the [src]...")
		busy_hunting = TRUE
		if(do_after(user, 2 SECONDS, src))
			if(user)
				to_chat(user, "You pry open the false bottom!")
			bottom_open = TRUE
		busy_hunting = FALSE
	else
		to_chat(user, "You push the false bottom down and close it with a click[stored_item ? ", with the [stored_item] snugly inside." : "."]")
		bottom_open = FALSE

/obj/item/storage/briefcase/false_bottomed/attack_hand(mob/user)
	if(bottom_open && stored_item)
		user.put_in_hands(stored_item)
		to_chat(user, "You pull out the [stored_item] from the [src]'s false bottom.")
		stored_item = null
		max_w_class = initial(max_w_class)
	else
		return ..()

/obj/item/case_with_bipki
	name = "Кейс с бипками"
	desc = "Легендарнейший кейс с бипками! Интересно что это такое?"
	icon = 'icons/obj/beebki.dmi'
	icon_state = "briefcase_bipki"
	item_state = "briefcase"
	force = 8
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_BULKY
	var/opened = FALSE

/obj/item/case_with_bipki/attack_self(mob/user)
	. = ..()
	opened = TRUE
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_warning("Вы видите бипки."))
	sleep(3 SECONDS)
	user.drop_item_ground(src, force = TRUE)
	user.dust()
	sleep(4 SECONDS)
	opened = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/item/case_with_bipki/update_icon_state()
	icon_state = "briefcase_bipki[opened ? "_o" : ""]"

/obj/item/case_with_bipki/examine(mob/user)
	. = ..()
	if(opened)
		. += span_warning("Яркий свет не позволяет вам увидеть содержимое кейса.")
