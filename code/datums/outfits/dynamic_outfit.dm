//Temporary equipment storage
/datum/dynamic_outfit
	var/name = "Outfit name"

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

	var/debug_switch = FALSE

/datum/dynamic_outfit/proc/unequip_item(mob/living/carbon/human/H, obj/item/I)
	//For some unknown reason, players have access to a backpack located in null space.
	if(isstorage(I))
		var/obj/item/storage/prom = I
		prom.close(H)
	H.temporarily_remove_item_from_inventory(I, TRUE, FALSE, TRUE)

//all flags lmao xD
/datum/dynamic_outfit/proc/equip(mob/living/carbon/human/H, selfdestroy = TRUE, selective_mode = INFINITY)
	debug_switch = TRUE

	//Start with backpack,suit,uniform for additional slots
	if(back && (ITEM_SLOT_BACK & selective_mode))
		H.equip_or_collect(back, ITEM_SLOT_BACK)
	if(uniform && (ITEM_SLOT_CLOTH_INNER & selective_mode))
		H.equip_or_collect(uniform, ITEM_SLOT_CLOTH_INNER)
	if(suit && (ITEM_SLOT_CLOTH_OUTER & selective_mode))
		H.equip_or_collect(suit, ITEM_SLOT_CLOTH_OUTER)
	if(belt && (ITEM_SLOT_BELT & selective_mode))
		H.equip_or_collect(belt, ITEM_SLOT_BELT)
	if(gloves && (ITEM_SLOT_GLOVES & selective_mode))
		H.equip_or_collect(gloves, ITEM_SLOT_GLOVES)
	if(shoes && (ITEM_SLOT_FEET & selective_mode))
		H.equip_or_collect(shoes, ITEM_SLOT_FEET)
	if(head && (ITEM_SLOT_HEAD & selective_mode))
		H.equip_or_collect(head, ITEM_SLOT_HEAD)
	if(mask && (ITEM_SLOT_MASK & selective_mode))
		H.equip_or_collect(mask, ITEM_SLOT_MASK)
	if(neck && (ITEM_SLOT_NECK & selective_mode))
		H.equip_or_collect(neck, ITEM_SLOT_NECK)
	if(l_ear && (ITEM_SLOT_EAR_LEFT & selective_mode))
		H.equip_or_collect(l_ear, ITEM_SLOT_EAR_LEFT)
	if(r_ear && (ITEM_SLOT_EAR_RIGHT & selective_mode))
		H.equip_or_collect(r_ear, ITEM_SLOT_EAR_RIGHT)
	if(glasses && (ITEM_SLOT_EYES & selective_mode))
		H.equip_or_collect(glasses, ITEM_SLOT_EYES)
	if(id && (ITEM_SLOT_ID & selective_mode))
		H.equip_or_collect(id, ITEM_SLOT_ID)
	if(suit_store && (ITEM_SLOT_SUITSTORE & selective_mode))
		H.equip_or_collect(suit_store, ITEM_SLOT_SUITSTORE)
	if(l_hand && (ITEM_SLOT_HAND_LEFT & selective_mode))
		H.equip_or_collect(l_hand, ITEM_SLOT_HAND_LEFT)
	if(r_hand && (ITEM_SLOT_HAND_RIGHT & selective_mode))
		H.equip_or_collect(r_hand, ITEM_SLOT_HAND_RIGHT)
	if(pda && (ITEM_SLOT_PDA & selective_mode))
		H.equip_or_collect(pda, ITEM_SLOT_PDA)
	if(l_pocket && (ITEM_SLOT_POCKET_LEFT & selective_mode))
		H.equip_or_collect(l_pocket, ITEM_SLOT_POCKET_LEFT)
	if(r_pocket && (ITEM_SLOT_POCKET_RIGHT & selective_mode))
		H.equip_or_collect(r_pocket, ITEM_SLOT_POCKET_RIGHT)

	H.regenerate_icons()

	if(selfdestroy)
		qdel(src)

/datum/dynamic_outfit/proc/temp_unequip(mob/living/carbon/human/H, ignore_active_hand = FALSE, selective_mode = INFINITY)
	debug_switch = FALSE
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
