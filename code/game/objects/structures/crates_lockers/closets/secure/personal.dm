/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"
	req_access = list(ACCESS_ALL_PERSONAL_LOCKERS)
	var/registered_name = null

/obj/structure/closet/secure_closet/personal/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/duffel(src)
	if(prob(50))
		new /obj/item/storage/backpack(src)
	else
		new /obj/item/storage/backpack/satchel_norm(src)
	new /obj/item/radio/headset(src)

/obj/structure/closet/secure_closet/personal/patient
	name = "patient's closet"

/obj/structure/closet/secure_closet/personal/patient/populate_contents()
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/shoes/white(src)

/obj/structure/closet/secure_closet/personal/mining
	name = "personal miner's locker"
	icon_state = "mine_pers"

/obj/structure/closet/secure_closet/personal/mining/populate_contents()
	new /obj/item/stack/sheet/cardboard(src)

/obj/structure/closet/secure_closet/personal/cabinet
	name = "personal cabinet"
	desc = "It's a secure cabinet for personnel. The first card swiped gains control."
	icon_state = "cabinet"
	overlay_sparking = "c_sparking"
	overlay_locked = "c_locked"
	overlay_locker = "c_locker"
	overlay_unlocked = "c_unlocked"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50


/obj/structure/closet/secure_closet/personal/cabinet/populate_contents()
	new /obj/item/storage/backpack/satchel/withwallet(src)
	new /obj/item/radio/headset(src)


/obj/structure/closet/secure_closet/personal/update_desc(updates = ALL)
	. = ..()
	desc = registered_name ? "Owned by [registered_name]." : initial(desc)


/obj/structure/closet/secure_closet/personal/attackby(obj/item/I, mob/user, params)
	if(opened)
		return ..()

	var/obj/item/card/id/id = I.GetID()
	if(id)
		add_fingerprint(user)
		if(broken)
			to_chat(user, span_warning("It appears to be broken."))
			return ATTACK_CHAIN_PROCEED
		if(!id.registered_name)
			to_chat(user, span_warning("This ID is blank."))
			return ATTACK_CHAIN_PROCEED
		if(src == user.loc)
			to_chat(user, span_notice("You can't reach the lock from inside."))
			return ATTACK_CHAIN_PROCEED
		//they can open all lockers, or nobody owns this, or they own this locker
		if(!allowed(user) && registered_name && registered_name != id.registered_name)
			to_chat(user, span_warning("Access Denied."))
			return ATTACK_CHAIN_PROCEED
		locked = !locked
		if(locked)
			if(!registered_name)
				registered_name = id.registered_name
		else
			registered_name = null
		update_appearance(UPDATE_ICON|UPDATE_DESC)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

