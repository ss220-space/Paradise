#define PAPERWORK 1
#define PHOTO 2

// /obj/item/clipboard
// 	name = "clipboard"
// 	desc = "It looks like you're writing a letter. Want some help?"
// 	icon = 'icons/obj/service/bureaucracy.dmi'
// 	icon_state = "clipboard"
// 	item_state = "clipboard"
// 	w_class = WEIGHT_CLASS_SMALL
// 	throw_speed = 3
// 	var/obj/item/pen/containedpen
// 	var/obj/item/toppaper
// 	slot_flags = ITEM_SLOT_BELT
// 	resistance_flags = FLAMMABLE

/**
 * Clipboard
 */
/obj/item/clipboard
	name = "clipboard"
	desc = "It looks like you're writing a letter. Want some help?"
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE

	//custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT, /datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)

	/// The stored pen
	var/obj/item/pen/containedpen
	/// Is the pen integrated?
	var/integrated_pen = FALSE
	/**
	 * Topmost piece of paper
	 * This is used for the paper displayed on the clipboard's icon
	 * and it is the one attacked, when attacking the clipboard.
	 */
	var/obj/item/paper/top_paper

/obj/item/clipboard/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins, item_path = /obj/item/clipboard)

/obj/item/clipboard/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins putting [user.p_their()] head into the clip of \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS //The clipboard's clip is very strong. Industrial duty. Can kill a man easily.

/obj/item/clipboard/Initialize(mapload)
	update_appearance()
	. = ..()

/obj/item/clipboard/Destroy()
	QDEL_NULL(containedpen)
	QDEL_NULL(top_paper)
	return ..()

/obj/item/clipboard/examine()
	. = ..()
	if(!integrated_pen && containedpen)
		. += span_notice("Right-click to remove [containedpen].")
	else if(top_paper)
		. += span_notice("Right-click to remove [top_paper].")

/// Take out the topmost paper
/obj/item/clipboard/proc/remove_paper(obj/item/paper/paper, mob/user)
	if(!istype(paper))
		return
	paper.forceMove(user.loc)
	user.put_in_hands(paper)
	to_chat(user, span_notice("You remove [paper] from [src]."))

/obj/item/clipboard/proc/remove_pen(mob/user)
	var/obj/item/pen/pen = containedpen
	pen.forceMove(user.loc)
	user.put_in_hands(pen)
	to_chat(user, span_notice("You remove [pen] from [src]."))

/obj/item/clipboard/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == containedpen)
		containedpen = null
		update_icon()
		return

	if(gone != top_paper)
		return

	UnregisterSignal(top_paper, COMSIG_ATOM_UPDATED_ICON)
	top_paper = locate(/obj/item/paper) in src
	update_icon()

/obj/item/clipboard/update_overlays()
	. = ..()
	var/paper_to_add = get_paper_overlay()
	if(paper_to_add)
		. += paper_to_add
	if(containedpen)
		. += "clipboard_pen"
	. += "clipboard_over"

/obj/item/clipboard/proc/get_paper_overlay()
	if(isnull(top_paper))
		return

	var/mutable_appearance/paper_overlay = mutable_appearance(icon, top_paper.icon_state, offset_spokesman = src, appearance_flags = KEEP_APART)
	paper_overlay = top_paper.color_atom_overlay(paper_overlay)
	paper_overlay.overlays += top_paper.overlays
	return paper_overlay

/obj/item/clipboard/attack_hand(mob/user, list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(!integrated_pen && containedpen)
			remove_pen(user)
		else
			remove_paper(top_paper, user)
		return TRUE
	. = ..()

/obj/item/clipboard/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/paper))
		//Add paper into the clipboard
		if(!user.drop_transfer_item_to_loc(tool, src))
			return ITEM_INTERACT_BLOCKING
		if(top_paper)
			UnregisterSignal(top_paper, COMSIG_ATOM_UPDATED_ICON)
		RegisterSignal(tool, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_top_paper_change))
		top_paper = tool
		to_chat(user, span_notice("You clip [tool] onto [src]."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/pen) && !containedpen)
		//Add a pen into the clipboard, attack (write) if there is already one
		if(!user.drop_transfer_item_to_loc(tool, src))
			return ITEM_INTERACT_BLOCKING
		containedpen = tool
		to_chat(user, span_notice("You slot [tool] into [src]."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	// Always label the clipboard so all of the papers don't have to be taken out.
	if(istype(tool, /obj/item/hand_labeler))
		return tool.interact_with_atom(src, user)

	if(top_paper)
		top_paper.item_interaction(user, user.get_active_hand())
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/item/clipboard/attack_self(mob/user)
	add_fingerprint(user)
	ui_interact(user)
	return

/obj/item/clipboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Clipboard")
		ui.open()

/obj/item/clipboard/ui_data(mob/user)
	// prepare data for TGUI
	var/list/data = list()
	data["pen"] = "[containedpen]"
	data["integrated_pen"] = integrated_pen

	data["top_paper"] = "[top_paper]"
	data["top_paper_ref"] = "[top_paper?.UID()]"

	data["paper"] = list()
	data["paper_ref"] = list()
	for(var/obj/item/paper/paper in src)
		if(paper == top_paper)
			continue
		data["paper"] += "[paper]"
		data["paper_ref"] += "[paper?.UID()]"

	return data

/obj/item/clipboard/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user

	if(user.incapacitated || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	switch(action)
		// Take the pen out
		if("remove_pen")
			if(containedpen)
				if(!integrated_pen)
					remove_pen(user)
				else
					to_chat(user, span_warning("You can't seem to find a way to remove [src]'s [containedpen]."))
				. = TRUE
		// Take paper out
		if("remove_paper")
			var/obj/item/paper/paper = locateUID(params["ref"])
			if(istype(paper) && paper.loc == src)
				remove_paper(paper, user)
				. = TRUE
		// Look at (or edit) the paper
		if("edit_paper")
			var/obj/item/paper/paper = locateUID(params["ref"])
			if(istype(paper) && paper.loc == src)
				paper.ui_interact(user)
				update_icon()
				. = TRUE
		// Move paper to the top
		if("move_top_paper")
			var/obj/item/paper/paper = locateUID(params["ref"])
			if(istype(paper) && paper.loc == src)
				top_paper = paper
				to_chat(user, span_notice("You move [paper] to the top."))
				update_icon()
				. = TRUE
		// Rename the paper (it's a verb)
		if("rename_paper")
			var/obj/item/paper/paper = locateUID(params["ref"])
			if(istype(paper) && paper.loc == src)
				paper.rename()
				update_icon()
				. = TRUE

/**
 * This is a simple proc to handle calling update_icon() upon receiving the top paper's `COMSIG_ATOM_UPDATE_APPEARANCE`.
 */
/obj/item/clipboard/proc/on_top_paper_change()
	SIGNAL_HANDLER
	update_appearance()

/obj/item/clipboard/IsContainedAtomAccessible(atom/contained, atom/movable/user)
	return ..() || (contained == top_paper)
