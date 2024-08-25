/obj/item/clothing/suit/storage
	var/obj/item/storage/internal/pockets
	w_class = WEIGHT_CLASS_NORMAL //we don't want these to be able to fit in their own pockets.

/obj/item/clothing/suit/storage/Initialize(mapload)
	. = ..()
	pockets = new/obj/item/storage/internal(src)
	pockets.storage_slots = 2	//two slots
	pockets.max_w_class = WEIGHT_CLASS_SMALL		//fit only pocket sized items
	pockets.max_combined_w_class = 4

/obj/item/clothing/suit/storage/Destroy()
	QDEL_NULL(pockets)
	return ..()


/obj/item/clothing/suit/storage/attack_hand(mob/user)
	if(!pockets || !pockets.handle_attack_hand(user))
		return ..()


/obj/item/clothing/suit/storage/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(!pockets || !pockets.handle_mousedrop(usr, over_object))
		return ..()


/obj/item/clothing/suit/storage/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !pockets || istype(I, /obj/item/radio/spy_spider))
		return .
	return pockets.attackby(I, user, params)


/obj/item/clothing/suit/storage/emp_act(severity)
	..()
	pockets.emp_act(severity)

/obj/item/clothing/suit/storage/hear_talk(mob/M, list/message_pieces)
	pockets.hear_talk(M, message_pieces)
	..()

/obj/item/clothing/suit/storage/hear_message(mob/M, msg)
	pockets.hear_message(M, msg)
	..()

/obj/item/clothing/suit/storage/proc/return_inv()

	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/gift/G in src)
		L += G.gift
		if(isstorage(G.gift))
			L += G.gift:return_inv()
	return L

/obj/item/clothing/suit/storage/serialize()
	var/list/data = ..()
	data["pockets"] = pockets.serialize()
	return data

/obj/item/clothing/suit/storage/deserialize(list/data)
	qdel(pockets)
	pockets = list_to_object(data["pockets"], src)
