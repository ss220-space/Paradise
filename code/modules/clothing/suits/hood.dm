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
		var/obj/item/clothing/head/hooded/new_hood = new hoodtype(src)
		new_hood.suit = src
		hood = new_hood


/obj/item/clothing/suit/hooded/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()


/obj/item/clothing/suit/hooded/update_icon_state()
	icon_state = "[item_color][suit_adjusted ? "_hood" : ""]"


/obj/item/clothing/suit/hooded/ui_action_click()
	ToggleHood()


/obj/item/clothing/suit/hooded/item_action_slot_check(slot, mob/user)
	if(slot == slot_wear_suit)
		return TRUE


/obj/item/clothing/suit/hooded/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(suit_adjusted)
		RemoveHood()


/obj/item/clothing/suit/hooded/dropped(mob/user, silent = FALSE)
	. = ..()
	if(suit_adjusted)
		RemoveHood()


/obj/item/clothing/suit/hooded/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(suit_adjusted)
		RemoveHood()
	return ..()


/obj/item/clothing/suit/hooded/proc/ToggleHood()
	var/mob/living/carbon/human/user = loc
	if(!ishuman(user) || !hood)
		return
	if(suit_adjusted)
		RemoveHood()
		return
	if(user.wear_suit != src)
		to_chat(user, span_warning("You must be wearing [src] to put up the hood!"))
		return
	EngageHood()


/obj/item/clothing/suit/hooded/proc/EngageHood()
	if(!hood)
		return FALSE
	var/mob/living/carbon/human/user = loc
	if(!ishuman(user))
		return FALSE
	if(user.head)
		to_chat(user, span_warning("You're already wearing something on your head!"))
		return
	if(!user.equip_to_slot(hood, slot_head))
		return FALSE
	. = TRUE
	suit_adjusted = TRUE
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("You adjust the hood on [src]."))
	user.update_head(hood, TRUE)
	user.update_inv_wear_suit()


/obj/item/clothing/suit/hooded/proc/RemoveHood()
	if(!hood)
		return FALSE
	. = TRUE
	suit_adjusted = FALSE
	update_icon(UPDATE_ICON_STATE)
	var/mob/living/carbon/human/user = loc
	if(ishuman(user))
		user.temporarily_remove_item_from_inventory(hood, force = TRUE)
		user.update_inv_wear_suit()
		to_chat(user, span_notice("The hood fells off from [src]."))
	hood.forceMove(src)
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()


/obj/item/clothing/head/hooded
	var/obj/item/clothing/suit/hooded/suit


/obj/item/clothing/head/hooded/Destroy()
	suit = null
	return ..()


/obj/item/clothing/head/hooded/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot != slot_head)
		if(suit)
			suit.RemoveHood()
		else
			qdel(src)


/obj/item/clothing/head/hooded/dropped(mob/user, silent = FALSE)
	. = ..()
	if(suit && loc != suit)
		forceMove(suit)
	else
		qdel(src)


/obj/item/clothing/head/hooded/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(suit)
		suit.RemoveHood()
	else
		qdel(src)

