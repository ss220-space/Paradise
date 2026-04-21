//Temporary equipment storage
/datum/dynamic_outfit
	var/obj/item/uniform = null
	var/obj/item/suit = null
	var/obj/item/back = null
	var/obj/item/belt = null
	var/obj/item/gloves = null
	var/obj/item/shoes = null
	var/obj/item/head = null
	var/obj/item/mask = null
	var/obj/item/neck = null
	var/obj/item/l_ear = null
	var/obj/item/r_ear = null
	var/obj/item/glasses = null
	var/obj/item/id = null
	var/obj/item/l_pocket = null
	var/obj/item/r_pocket = null
	var/obj/item/suit_store = null
	var/obj/item/l_hand = null
	var/obj/item/r_hand = null
	var/obj/item/pda = null

/datum/dynamic_outfit/Destroy(force)
	remove_all_objects()
	. = ..()

/datum/dynamic_outfit/proc/unequip_item(mob/living/carbon/human/H, obj/item/I)
	if(isstorage(I))
		var/obj/item/storage/temp = I
		temp.close(H)

	H.temporarily_remove_item_from_inventory(I, TRUE, FALSE, TRUE)

//Хы... хыхы
/datum/dynamic_outfit/proc/remove_all_objects()
	QDEL_NULL(uniform)
	QDEL_NULL(suit)
	QDEL_NULL(back)
	QDEL_NULL(belt)
	QDEL_NULL(gloves)
	QDEL_NULL(shoes)
	QDEL_NULL(head)
	QDEL_NULL(mask)
	QDEL_NULL(neck)
	QDEL_NULL(l_ear)
	QDEL_NULL(r_ear)
	QDEL_NULL(glasses)
	QDEL_NULL(id)
	QDEL_NULL(l_pocket)
	QDEL_NULL(r_pocket)
	QDEL_NULL(suit_store)
	QDEL_NULL(l_hand)
	QDEL_NULL(r_hand)
	QDEL_NULL(pda)

/datum/dynamic_outfit/proc/equip(mob/living/carbon/human/H, selective_mode = INFINITY)
	//Start with backpack,suit,uniform for additional slots
	if(back && (ITEM_SLOT_BACK & selective_mode))
		H.equip_or_collect(back, ITEM_SLOT_BACK)
		back = null
	if(uniform && (ITEM_SLOT_CLOTH_INNER & selective_mode))
		H.equip_or_collect(uniform, ITEM_SLOT_CLOTH_INNER)
		uniform = null
	if(suit && (ITEM_SLOT_CLOTH_OUTER & selective_mode))
		H.equip_or_collect(suit, ITEM_SLOT_CLOTH_OUTER)
		suit = null
	if(belt && (ITEM_SLOT_BELT & selective_mode))
		H.equip_or_collect(belt, ITEM_SLOT_BELT)
		belt = null
	if(gloves && (ITEM_SLOT_GLOVES & selective_mode))
		H.equip_or_collect(gloves, ITEM_SLOT_GLOVES)
		gloves = null
	if(shoes && (ITEM_SLOT_FEET & selective_mode))
		H.equip_or_collect(shoes, ITEM_SLOT_FEET)
		shoes = null
	if(head && (ITEM_SLOT_HEAD & selective_mode))
		H.equip_or_collect(head, ITEM_SLOT_HEAD)
		head = null
	if(mask && (ITEM_SLOT_MASK & selective_mode))
		H.equip_or_collect(mask, ITEM_SLOT_MASK)
		mask = null
	if(neck && (ITEM_SLOT_NECK & selective_mode))
		H.equip_or_collect(neck, ITEM_SLOT_NECK)
		neck = null
	if(l_ear && (ITEM_SLOT_EAR_LEFT & selective_mode))
		H.equip_or_collect(l_ear, ITEM_SLOT_EAR_LEFT)
		l_ear = null
	if(r_ear && (ITEM_SLOT_EAR_RIGHT & selective_mode))
		H.equip_or_collect(r_ear, ITEM_SLOT_EAR_RIGHT)
		r_ear = null
	if(glasses && (ITEM_SLOT_EYES & selective_mode))
		H.equip_or_collect(glasses, ITEM_SLOT_EYES)
		glasses = null
	if(id && (ITEM_SLOT_ID & selective_mode))
		H.equip_or_collect(id, ITEM_SLOT_ID)
		id = null
	if(suit_store && (ITEM_SLOT_SUITSTORE & selective_mode))
		H.equip_or_collect(suit_store, ITEM_SLOT_SUITSTORE)
		suit_store = null
	if(l_hand && (ITEM_SLOT_HAND_LEFT & selective_mode))
		H.equip_or_collect(l_hand, ITEM_SLOT_HAND_LEFT)
		l_hand = null
	if(r_hand && (ITEM_SLOT_HAND_RIGHT & selective_mode))
		H.equip_or_collect(r_hand, ITEM_SLOT_HAND_RIGHT)
		r_hand = null
	if(pda && (ITEM_SLOT_PDA & selective_mode))
		H.equip_or_collect(pda, ITEM_SLOT_PDA)
		pda = null
	if(l_pocket && (ITEM_SLOT_POCKET_LEFT & selective_mode))
		H.equip_or_collect(l_pocket, ITEM_SLOT_POCKET_LEFT)
		l_pocket = null
	if(r_pocket && (ITEM_SLOT_POCKET_RIGHT & selective_mode))
		H.equip_or_collect(r_pocket, ITEM_SLOT_POCKET_RIGHT)
		r_pocket = null

	H.regenerate_icons()

/datum/dynamic_outfit/proc/temp_unequip(mob/living/carbon/human/H, ignore_active_hand = FALSE, selective_mode = INFINITY)
	if(H.back && (ITEM_SLOT_BACK & selective_mode))
		back = H.back
		unequip_item(H, H.back)
	if(H.w_uniform && (ITEM_SLOT_CLOTH_INNER & selective_mode))
		uniform = H.w_uniform
		unequip_item(H, H.w_uniform)
	if(H.wear_suit && (ITEM_SLOT_CLOTH_OUTER & selective_mode))
		suit = H.wear_suit
		unequip_item(H, H.wear_suit)
	if(H.belt && (ITEM_SLOT_BELT & selective_mode))
		belt = H.belt
		unequip_item(H, H.belt)
	if(H.gloves && (ITEM_SLOT_GLOVES & selective_mode))
		gloves = H.gloves
		unequip_item(H, H.gloves)
	if(H.shoes && (ITEM_SLOT_FEET & selective_mode))
		shoes = H.shoes
		unequip_item(H, H.shoes)
	if(H.head && (ITEM_SLOT_HEAD & selective_mode))
		head = H.head
		unequip_item(H, H.head)
	if(H.wear_mask && (ITEM_SLOT_MASK & selective_mode))
		mask = H.wear_mask
		unequip_item(H, H.wear_mask)
	if(H.neck && (ITEM_SLOT_NECK & selective_mode))
		neck = H.neck
		unequip_item(H, H.neck)
	if(H.l_ear && (ITEM_SLOT_EAR_LEFT & selective_mode))
		l_ear = H.l_ear
		unequip_item(H, H.l_ear)
	if(H.r_ear && (ITEM_SLOT_EAR_RIGHT & selective_mode))
		r_ear = H.r_ear
		unequip_item(H, H.r_ear)
	if(H.glasses && (ITEM_SLOT_EYES & selective_mode))
		glasses = H.glasses
		unequip_item(H, H.glasses)
	if(H.wear_id && (ITEM_SLOT_ID & selective_mode))
		id = H.wear_id
		unequip_item(H, H.wear_id)
	if(H.s_store)
		suit_store = H.s_store
		unequip_item(H, H.s_store)
	if(H.l_hand && !(H.is_in_active_hand(H.l_hand) && ignore_active_hand) && (ITEM_SLOT_HAND_LEFT & selective_mode))
		l_hand = H.l_hand
		unequip_item(H, H.l_hand)
	if(H.r_hand && !(H.is_in_active_hand(H.r_hand) && ignore_active_hand) && (ITEM_SLOT_HAND_RIGHT & selective_mode))
		r_hand = H.r_hand
		unequip_item(H, H.r_hand)
	if(H.wear_pda && (ITEM_SLOT_PDA & selective_mode))
		pda = H.wear_pda
		unequip_item(H, H.wear_pda)
	if(H.l_store && (ITEM_SLOT_POCKET_LEFT & selective_mode))
		l_pocket = H.l_store
		unequip_item(H, H.l_store)
	if(H.r_store && (ITEM_SLOT_POCKET_RIGHT & selective_mode))
		r_pocket = H.r_store
		unequip_item(H, H.r_store)

	H.regenerate_icons()
