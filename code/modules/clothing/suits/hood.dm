//Hoods for winter coats and chaplain hoodie etc

/obj/item/clothing/suit/hooded
	actions_types = list(/datum/action/item_action/toggle)
	var/obj/item/clothing/head/hooded/hood
	var/hoodtype = /obj/item/clothing/head/hooded/winterhood //so the chaplain hoodie or other hoodies can override this


/obj/item/clothing/suit/hooded/Initialize(mapload)
	. = ..()
	MakeHood()


/obj/item/clothing/suit/hooded/Destroy()
	unequip_hood()
	hood = null
	return ..()


/obj/item/clothing/suit/hooded/proc/MakeHood()
	item_color = initial(icon_state)
	if(!hoodtype || hood)
		return
	hood = new hoodtype(src, src)
	RegisterSignal(hood, COMSIG_ITEM_DROPPED, PROC_REF(on_hood_dropped))
	RegisterSignal(hood, COMSIG_ITEM_EQUIPPED, PROC_REF(on_hood_equipped))
	RegisterSignal(hood, COMSIG_QDELETING, PROC_REF(on_hood_destroyed))


/obj/item/clothing/suit/hooded/proc/on_hood_dropped()
	SIGNAL_HANDLER

	RemoveHood()


/obj/item/clothing/suit/hooded/proc/on_hood_equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(slot & ITEM_SLOT_HEAD)
		return
	RemoveHood()


/obj/item/clothing/suit/hooded/proc/on_hood_destroyed()
	SIGNAL_HANDLER

	RemoveHood()
	hood = null


/obj/item/clothing/suit/hooded/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()


/obj/item/clothing/suit/hooded/update_icon_state()
	icon_state = "[item_color][suit_adjusted ? "_hood" : ""]"


/obj/item/clothing/suit/hooded/ui_action_click(mob/user, datum/action/action, leftclick)
	ToggleHood()


/obj/item/clothing/suit/hooded/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_CLOTH_OUTER)
		return TRUE


/obj/item/clothing/suit/hooded/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	RemoveHood()


/obj/item/clothing/suit/hooded/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	RemoveHood()


/obj/item/clothing/suit/hooded/proc/ToggleHood()
	if(suit_adjusted)
		return RemoveHood()
	return EngageHood()


/obj/item/clothing/suit/hooded/proc/EngageHood()
	var/mob/living/carbon/human/wearer = loc
	if(suit_adjusted || !ishuman(wearer))
		return FALSE
	if(wearer.wear_suit != src)
		to_chat(wearer, span_warning("You must be wearing [src] to put up the head gear!"))
		return FALSE
	if(!hood)
		to_chat(wearer, span_warning("[src] has no head gear anymore!"))
		return FALSE
	if(wearer.head)
		to_chat(wearer, span_warning("You're already wearing something on your head!"))
		return FALSE
	if(!wearer.equip_to_slot_if_possible(hood, ITEM_SLOT_HEAD))
		return FALSE
	. = TRUE
	suit_adjusted = TRUE
	update_icon(UPDATE_ICON_STATE)
	to_chat(wearer, span_notice("You adjust the hood on [src]."))
	wearer.update_inv_wear_suit()
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()


/obj/item/clothing/suit/hooded/proc/RemoveHood()
	unequip_hood()
	if(!suit_adjusted)
		return FALSE
	. = TRUE
	suit_adjusted = FALSE
	update_icon(UPDATE_ICON_STATE)
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()


/obj/item/clothing/suit/hooded/proc/unequip_hood()
	if(!hood || hood.loc == src)
		return
	var/mob/living/carbon/human/wearer = hood.loc
	if(!ishuman(wearer))
		hood.forceMove(src)
		return
	wearer.transfer_item_to_loc(hood, src, force = TRUE)
	wearer.update_inv_wear_suit()


/obj/item/clothing/head/hooded
	flags_inv = HIDEHAIR


/obj/item/clothing/head/hooded/Initialize(mapload, obj/item/clothing/suit/hooded/parent)
	. = ..()
	if(!istype(parent))
		stack_trace("Investigate suit hood ([type]). Initialized without proper suit.")

