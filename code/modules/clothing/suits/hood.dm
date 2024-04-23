//Hoods for winter coats and chaplain hoodie etc

/obj/item/clothing/suit/hooded
	actions_types = list(/datum/action/item_action/toggle)
	var/obj/item/clothing/head/hooded/hood
	var/hoodtype = /obj/item/clothing/head/hooded/winterhood //so the chaplain hoodie or other hoodies can override this


/obj/item/clothing/suit/hooded/Initialize(mapload)
	. = ..()
	MakeHood()


/obj/item/clothing/suit/hooded/Destroy()
	QDEL_NULL(hood)
	. = ..()


/obj/item/clothing/suit/hooded/proc/MakeHood()
	item_color = initial(icon_state)
	if(!hood)
		var/obj/item/clothing/head/hooded/new_hood = new hoodtype(src, src)
		hood = new_hood


/obj/item/clothing/suit/hooded/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()


/obj/item/clothing/suit/hooded/update_icon_state()
	icon_state = "[item_color][suit_adjusted ? "_hood" : ""]"


/obj/item/clothing/suit/hooded/ui_action_click(mob/user)
	ToggleHood(user)


/obj/item/clothing/suit/hooded/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_CLOTH_OUTER)
		return TRUE


/obj/item/clothing/suit/hooded/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	RemoveHood(user)


/obj/item/clothing/suit/hooded/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	RemoveHood(user)


/obj/item/clothing/suit/hooded/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	RemoveHood(usr)
	. = ..()


/obj/item/clothing/suit/hooded/proc/ToggleHood(mob/living/carbon/human/user)
	if(!ishuman(user))
		return
	if(!hood)
		to_chat(user, span_warning("[src] has no head gear anymore!"))
		return
	if(suit_adjusted)
		RemoveHood(user)
		return
	if(user.wear_suit != src)
		to_chat(user, span_warning("You must be wearing [src] to put up the hood!"))
		return
	EngageHood(user)


/obj/item/clothing/suit/hooded/proc/EngageHood(mob/living/carbon/human/user)
	if(!hood || suit_adjusted)
		return FALSE
	if(user.head)
		to_chat(user, span_warning("You're already wearing something on your head!"))
		return
	if(!user.equip_to_slot(hood, ITEM_SLOT_HEAD))
		return FALSE
	. = TRUE
	suit_adjusted = TRUE
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("You adjust the hood on [src]."))
	user.update_head(hood, TRUE)
	user.update_inv_wear_suit()


/obj/item/clothing/suit/hooded/proc/RemoveHood(mob/living/carbon/human/user)
	if(!hood)
		return FALSE
	if(!suit_adjusted)
		return FALSE
	. = TRUE
	suit_adjusted = FALSE
	update_icon(UPDATE_ICON_STATE)
	if(ishuman(user))
		user.temporarily_remove_item_from_inventory(hood, force = TRUE)
		user.update_inv_wear_suit()
		to_chat(user, span_notice("The hood fells off from [src]."))
	hood.forceMove(src)
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()


/obj/item/clothing/head/hooded
	var/obj/item/clothing/suit/hooded/suit


/obj/item/clothing/head/hooded/Initialize(mapload, obj/item/clothing/suit/hooded/parent)
	. = ..()
	if(istype(parent))
		suit = parent
	else
		stack_trace("Investigate suit hood ([type]). Initialized without proper suit.")


/obj/item/clothing/head/hooded/Destroy()
	if(suit)
		suit.RemoveHood(loc)
		suit.hood = null
		suit = null
	return ..()


/obj/item/clothing/head/hooded/attack_hand(mob/user, pickupfireoverride = FALSE)
	if(suit)
		suit.RemoveHood(user)
	else
		qdel(src)
		stack_trace("Investigate suit hood attackhand of type: [type]")


/obj/item/clothing/head/hooded/equipped(mob/living/carbon/user, slot, initial = FALSE)
	. = ..()
	if(!suit || slot != ITEM_SLOT_HEAD || user.wear_suit != suit)
		if(!QDELING(src))
			qdel(src)
		stack_trace("Investigate suit hood equip of type: [type]")
		return FALSE


/obj/item/clothing/head/hooded/dropped(mob/living/carbon/user, slot, silent = FALSE)
	. = ..()
	if(!suit || slot != ITEM_SLOT_HEAD || user.wear_suit != suit)
		if(!QDELING(src))
			qdel(src)
		stack_trace("Investigate suit hood drop of type: [type]")
		return FALSE
	suit.RemoveHood(user)


/obj/item/clothing/head/hooded/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(suit)
		suit.RemoveHood(usr)
	else
		qdel(src)
		stack_trace("Investigate suit hood mousedrop of type: [type]")

