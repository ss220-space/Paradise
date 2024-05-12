/datum/component/ducttape
	var/mutable_appearance/tape_overlay
	var/hide_tape = FALSE


/datum/component/ducttape/Initialize(x_offset = 0, y_offset = 0, hide_tape = FALSE)
	if(!isitem(parent)) //Something went wrong
		return COMPONENT_INCOMPATIBLE
	src.hide_tape = hide_tape
	if(!hide_tape) //if TRUE this hides the tape overlay and added examine text
		tape_overlay = mutable_appearance('icons/obj/bureaucracy.dmi', "tape")
		tape_overlay.pixel_x = x_offset - 2
		tape_overlay.pixel_y = y_offset - 2
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_tape_overlay))
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(add_tape_text))
	var/obj/item/I = parent
	I.set_anchored(TRUE)
	I.update_icon() //Do this first so the action button properly shows the icon
	if(!hide_tape) //the tape can no longer be removed if TRUE
		var/datum/action/item_action/remove_tape/remove_action = new(I)
		if(ismob(I.loc))
			remove_action.Grant(I.loc)
	I.add_tape()


/datum/component/ducttape/Destroy()
	tape_overlay = null
	return ..()


/datum/component/ducttape/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(afterattack))
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(pick_up))


/datum/component/ducttape/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK, COMSIG_ITEM_PICKUP))


/datum/component/ducttape/proc/add_tape_text(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("There's some sticky tape attached to [source].")


/datum/component/ducttape/proc/add_tape_overlay(datum/source, list/overlays)
	SIGNAL_HANDLER

	overlays += tape_overlay


/datum/component/ducttape/proc/remove_tape(obj/item/I, mob/user)
	to_chat(user, span_notice("You tear the tape off [I]!"))
	playsound(I, 'sound/items/poster_ripped.ogg', 50, 1)
	new /obj/item/trash/tapetrash(user.loc)
	I.set_anchored(initial(I.anchored))
	if(!hide_tape)
		UnregisterSignal(parent, list(COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_PARENT_EXAMINE))
	I.update_icon()
	for(var/datum/action/item_action/remove_tape/RT in I.actions)
		RT.Remove(user)
		qdel(RT)
	user.transfer_fingerprints_to(I)
	I.remove_tape()
	qdel(src)


/datum/component/ducttape/proc/afterattack(obj/item/I, atom/target, mob/user, proximity, params)
	SIGNAL_HANDLER

	if(!proximity || !isturf(target) || !user.drop_item_ground(I))
		return

	var/turf/source_turf = get_turf(I)
	var/turf/target_turf = target
	var/x_offset
	var/y_offset
	if(target_turf != get_turf(I)) //Trying to stick it on a wall, don't move it to the actual wall or you can move the item through it. Instead set the pixels as appropriate
		var/target_direction = get_dir(source_turf, target_turf)//The direction we clicked
		// Snowflake diagonal handling
		if(target_direction in GLOB.diagonals)
			to_chat(user, span_warning("You can't reach [target_turf]."))
			return
		if(target_direction & EAST)
			x_offset = 16
			y_offset = rand(-12, 12)
		else if(target_direction & WEST)
			x_offset = -16
			y_offset = rand(-12, 12)
		else if(target_direction & NORTH)
			x_offset = rand(-12, 12)
			y_offset = 16
		else if(target_direction & SOUTH)
			x_offset = rand(-12, 12)
			y_offset = -16
	to_chat(user, span_notice("You stick [I] to [target_turf]."))
	I.pixel_x = x_offset
	I.pixel_y = y_offset


/datum/component/ducttape/proc/pick_up(obj/item/I, mob/user)
	SIGNAL_HANDLER

	I.pixel_x = initial(I.pixel_x)
	I.pixel_y = initial(I.pixel_y)

