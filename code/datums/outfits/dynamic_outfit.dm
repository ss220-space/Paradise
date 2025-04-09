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

/datum/dynamic_outfit/proc/equip_item(mob/living/carbon/human/H, obj/item/I, slot)
	if(QDELETED(I))
		return
	if(isstorage(I))
		var/obj/item/storage/prom = I
		prom.hide_from(H)
	H.equip_or_collect(I, slot)
 //																					all flags lmao xD
/datum/dynamic_outfit/proc/equip(mob/living/carbon/human/H, selfdestroy = TRUE, selective_mode = INFINITY)
	debug_switch = TRUE

	//Start with backpack,suit,uniform for additional slots
	if(back && (ITEM_SLOT_BACK & selective_mode))
		equip_item(H, back, ITEM_SLOT_BACK)
	if(uniform && (ITEM_SLOT_CLOTH_INNER & selective_mode))
		equip_item(H, uniform, ITEM_SLOT_CLOTH_INNER)
	if(suit && (ITEM_SLOT_CLOTH_OUTER & selective_mode))
		equip_item(H, suit, ITEM_SLOT_CLOTH_OUTER)
	if(belt && (ITEM_SLOT_BELT & selective_mode))
		equip_item(H, belt, ITEM_SLOT_BELT)
	if(gloves && (ITEM_SLOT_GLOVES & selective_mode))
		equip_item(H, gloves, ITEM_SLOT_GLOVES)
	if(shoes && (ITEM_SLOT_FEET & selective_mode))
		equip_item(H, shoes, ITEM_SLOT_FEET)
	if(head && (ITEM_SLOT_HEAD & selective_mode))
		equip_item(H, head, ITEM_SLOT_HEAD)
	if(mask && (ITEM_SLOT_MASK & selective_mode))
		equip_item(H, mask, ITEM_SLOT_MASK)
	if(neck && (ITEM_SLOT_NECK & selective_mode))
		equip_item(H, neck, ITEM_SLOT_NECK)
	if(l_ear && (ITEM_SLOT_EAR_LEFT & selective_mode))
		equip_item(H, l_ear, ITEM_SLOT_EAR_LEFT)
	if(r_ear && (ITEM_SLOT_EAR_RIGHT & selective_mode))
		equip_item(H, r_ear, ITEM_SLOT_EAR_RIGHT)
	if(glasses && (ITEM_SLOT_EYES & selective_mode))
		equip_item(H, glasses, ITEM_SLOT_EYES)
	if(id && (ITEM_SLOT_ID & selective_mode))
		equip_item(H, id, ITEM_SLOT_ID)
	if(suit_store && (ITEM_SLOT_SUITSTORE & selective_mode))
		equip_item(H, suit_store, ITEM_SLOT_SUITSTORE)
	if(l_hand && (ITEM_SLOT_HAND_LEFT & selective_mode))
		equip_item(H, l_hand, ITEM_SLOT_HAND_LEFT)
	if(r_hand && (ITEM_SLOT_HAND_RIGHT & selective_mode))
		equip_item(H, r_hand, ITEM_SLOT_HAND_RIGHT)
	if(pda && (ITEM_SLOT_PDA & selective_mode))
		equip_item(H, pda, ITEM_SLOT_PDA)
	if(l_pocket && (ITEM_SLOT_POCKET_LEFT & selective_mode))
		equip_item(H, l_pocket, ITEM_SLOT_POCKET_LEFT)
	if(r_pocket && (ITEM_SLOT_POCKET_RIGHT & selective_mode))
		equip_item(H, r_pocket, ITEM_SLOT_POCKET_RIGHT)

	H.regenerate_icons()
	
	if(selfdestroy)
		qdel(src)

/datum/dynamic_outfit/proc/temp_unequip(mob/living/carbon/human/H, ignore_active_hand = FALSE, selective_mode = INFINITY)
	debug_switch = FALSE
	if(H.back && (ITEM_SLOT_BACK & selective_mode))
		back = H.back
		H.temporarily_remove_item_from_inventory(H.back, TRUE, FALSE, TRUE)
	if(H.w_uniform && (ITEM_SLOT_CLOTH_INNER & selective_mode))
		uniform = H.w_uniform
		H.temporarily_remove_item_from_inventory(H.w_uniform, TRUE, FALSE, TRUE)
	if(H.wear_suit && (ITEM_SLOT_CLOTH_OUTER & selective_mode))
		suit = H.wear_suit
		H.temporarily_remove_item_from_inventory(H.wear_suit, TRUE, FALSE, TRUE)
	if(H.belt && (ITEM_SLOT_BELT & selective_mode))
		belt = H.belt
		H.temporarily_remove_item_from_inventory(H.belt, TRUE, FALSE, TRUE)
	if(H.gloves && (ITEM_SLOT_GLOVES & selective_mode))
		gloves = H.gloves
		H.temporarily_remove_item_from_inventory(H.gloves, TRUE, FALSE, TRUE)
	if(H.shoes && (ITEM_SLOT_FEET & selective_mode))
		shoes = H.shoes
		H.temporarily_remove_item_from_inventory(H.shoes, TRUE, FALSE, TRUE)
	if(H.head && (ITEM_SLOT_HEAD & selective_mode))
		head = H.head
		H.temporarily_remove_item_from_inventory(H.head, TRUE, FALSE, TRUE)
	if(H.wear_mask && (ITEM_SLOT_MASK & selective_mode))
		mask = H.wear_mask
		H.temporarily_remove_item_from_inventory(H.wear_mask, TRUE, FALSE, TRUE)
	if(H.neck && (ITEM_SLOT_NECK & selective_mode))
		neck = H.neck
		H.temporarily_remove_item_from_inventory(H.neck, TRUE, FALSE, TRUE)
	if(H.l_ear && (ITEM_SLOT_EAR_LEFT & selective_mode))
		l_ear = H.l_ear
		H.temporarily_remove_item_from_inventory(H.l_ear, TRUE, FALSE, TRUE)
	if(H.r_ear && (ITEM_SLOT_EAR_RIGHT & selective_mode))
		r_ear = H.r_ear
		H.temporarily_remove_item_from_inventory(H.r_ear, TRUE, FALSE, TRUE)
	if(H.glasses && (ITEM_SLOT_EYES & selective_mode))
		glasses = H.glasses
		H.temporarily_remove_item_from_inventory(H.glasses, TRUE, FALSE, TRUE)
	if(H.wear_id && (ITEM_SLOT_ID & selective_mode))
		id = H.wear_id
		H.temporarily_remove_item_from_inventory(H.wear_id, TRUE, FALSE, TRUE)
	if(H.s_store)
		suit_store = H.s_store
		H.temporarily_remove_item_from_inventory(H.s_store, TRUE, FALSE, TRUE)
	if(H.l_hand && !(H.is_in_active_hand(H.l_hand) && ignore_active_hand) && (ITEM_SLOT_HAND_LEFT & selective_mode))
		l_hand = H.l_hand
		H.temporarily_remove_item_from_inventory(H.l_hand, TRUE, FALSE, TRUE)
	if(H.r_hand && !(H.is_in_active_hand(H.r_hand) && ignore_active_hand) && (ITEM_SLOT_HAND_RIGHT & selective_mode))
		r_hand = H.r_hand
		H.temporarily_remove_item_from_inventory(H.r_hand, TRUE, FALSE, TRUE)
	if(H.wear_pda && (ITEM_SLOT_PDA & selective_mode))
		pda = H.wear_pda
		H.temporarily_remove_item_from_inventory(H.wear_pda, TRUE, FALSE, TRUE)
	if(H.l_store && (ITEM_SLOT_POCKET_LEFT & selective_mode))
		l_pocket = H.l_store
		H.temporarily_remove_item_from_inventory(H.l_store, TRUE, FALSE, TRUE)
	if(H.r_store && (ITEM_SLOT_POCKET_RIGHT & selective_mode))
		r_pocket = H.r_store
		H.temporarily_remove_item_from_inventory(H.r_store, TRUE, FALSE, TRUE)

	H.regenerate_icons()

//DEBUG ITEM
/obj/item/spatial_storage
	name = "Межпространственное хранилище экиперовки"
	desc = "Хранит в себе снаряжение человечка"
	icon_state = "bodybags"
	icon = 'icons/obj/storage.dmi'
	var/datum/dynamic_outfit/storage = null

/obj/item/spatial_storage/Initialize(mapload)
	storage = new()
	..()

/obj/item/spatial_storage/Destroy()
	qdel(storage)
	..()

/obj/item/spatial_storage/attack_self(mob/user)
	if(!ishuman(user))
		return ..()
	
	var/mob/living/carbon/human/H = user
	if(storage.debug_switch)
		storage.temp_unequip(H, TRUE)
	else
		storage.equip(H, FALSE)
	return ..()
