// To clarify:
// For use_to_pickup and allow_quick_gather functionality,
// see item/attackby() (/game/objects/items.dm, params)
// Do not remove this functionality without good reason, cough reagent_containers cough.
// -Sayu


/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	flags = BLOCKS_LIGHT
	///No message on putting items in
	var/silent = FALSE
	///List of objects which this item can store (if set, it can't store anything else)
	var/list/can_hold = list()
	/// List of objects that can be stored, regardless of w_class
	var/list/w_class_override = list()
	///List of objects which this item can't store (in effect only if can_hold isn't set)
	var/list/cant_hold = list()
	///Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_w_class = WEIGHT_CLASS_SMALL
	///Min size of objects that this object can store (in effect only if can_hold isn't set)
	var/min_w_class
	///The sum of the w_classes of all the items in this storage item.
	var/max_combined_w_class = 14
	var/storage_slots = 7
	///The number of storage slots in this container.
	var/atom/movable/screen/storage/boxes = null
	var/atom/movable/screen/close/closer = null
	///Set this to make it possible to use this item in an inverse way, so you can have the item in your hand and click items on the floor to pick them up.
	var/use_to_pickup
	///Set this to make the storage item group contents of the same type and display them as a number.
	var/display_contents_with_number
	///Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_empty
	///Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/allow_quick_gather
	///FALSE = pick one at a time, TRUE = pick all on tile
	var/pickup_all_on_tile = TRUE
	///Sound played when used. null for no sound.
	var/use_sound = "rustle"

	/// What kind of [/obj/item/stack] can this be folded into. (e.g. Boxes and cardboard)
	var/foldable = null
	/// How much of the stack item do you get.
	var/foldable_amt = 0
	/// Lazy list of mobs which are currently viewing the storage inventory.
	var/list/mobs_viewing

/obj/item/storage/Initialize(mapload)
	. = ..()

	can_hold = typecacheof(can_hold)
	cant_hold = typecacheof(cant_hold)

	if(allow_quick_empty)
		verbs += /obj/item/storage/verb/quick_empty
	else
		verbs -= /obj/item/storage/verb/quick_empty

	if(allow_quick_gather)
		verbs += /obj/item/storage/verb/toggle_gathering_mode
	else
		verbs -= /obj/item/storage/verb/toggle_gathering_mode

	populate_contents()

	boxes = new /atom/movable/screen/storage()
	boxes.name = "storage"
	boxes.master = src
	boxes.icon_state = "block"
	boxes.screen_loc = "7,7 to 10,8"
	boxes.layer = HUD_LAYER
	boxes.plane = HUD_PLANE
	closer = new /atom/movable/screen/close()
	closer.master = src
	closer.icon_state = "backpack_close"
	closer.layer = ABOVE_HUD_LAYER
	closer.plane = ABOVE_HUD_PLANE
	orient2hud()

/obj/item/storage/Destroy()
	for(var/obj/O in contents)
		O.mouse_opacity = initial(O.mouse_opacity)

	. = ..()
	QDEL_NULL(boxes)
	QDEL_NULL(closer)
	LAZYCLEARLIST(mobs_viewing)


/obj/item/storage/forceMove(atom/destination)
	. = ..()
	if(!destination || ismob(destination.loc))
		return .
	for(var/mob/player in mobs_viewing)
		if(player == destination)
			continue
		hide_from(player)


/obj/item/storage/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(!isliving(usr))
		return FALSE

	var/mob/living/user = usr

	// Stops inventory actions in a mech, while ventcrawling and while being incapacitated
	if(ismecha(user.loc) || is_ventcrawling(user) || user.incapacitated())
		return FALSE

	if(over_object == user && user.Adjacent(src)) // this must come before the screen objects only block
		open(user)
		return FALSE

	if((!istype(src, /obj/item/storage/lockbox) && (istype(over_object, /obj/structure/table) || isfloorturf(over_object)) \
		&& length(contents) && loc == user && !user.incapacitated() && user.Adjacent(over_object)))

		if(tgui_alert(user, "Empty [src] onto [over_object]?", "Confirm", list("Yes", "No")) != "Yes")
			return FALSE

		if(!user || !over_object || user.incapacitated() || loc != user || !user.Adjacent(over_object))
			return FALSE

		close(user)
		user.face_atom(over_object)
		user.visible_message(
			span_notice("[user] empties [src] onto [over_object]."),
			span_notice("You empty [src] onto [over_object]."),
		)
		var/turf/object_turf = get_turf(over_object)
		for(var/obj/item/item in src)
			remove_from_storage(item, object_turf)

		update_icon() // For content-sensitive icons
		return FALSE

	return ..()


/obj/item/storage/AltClick(mob/user)
	if(ishuman(user) && Adjacent(user) && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		open(user)

	else if(isobserver(user))
		show_to(user)

/obj/item/storage/proc/return_inv()
	var/list/L = list()

	L += contents

	for(var/obj/item/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/gift/G in src)
		L += G.gift
		if(isstorage(G.gift))
			L += G.gift:return_inv()
	for(var/obj/item/folder/F in src)
		L += F.contents
	return L

/obj/item/storage/proc/show_to(mob/user)
	if(!user.client)
		return
	if(QDELETED(src))
		return
	if(user.s_active != src && !isobserver(user))
		for(var/obj/item/I in src) // For bombs with mousetraps, facehuggers etc
			if(I.on_found(user))
				return
	orient2hud(user)  // this only needs to happen to make .contents show properly as screen objects.
	if(user.s_active)
		user.s_active.hide_from(user)
	user.client.screen -= boxes
	user.client.screen -= closer
	user.client.screen -= contents
	user.client.screen += boxes
	user.client.screen += closer
	user.client.screen += contents
	user.s_active = src
	LAZYOR(mobs_viewing, user)

/obj/item/storage/proc/hide_from(mob/user)
	LAZYREMOVE(mobs_viewing, user) // Remove clientless mobs too
	if(!user.client)
		return
	user.client.screen -= boxes
	user.client.screen -= closer
	user.client.screen -= contents
	if(user.s_active == src)
		user.s_active = null


/obj/item/storage/proc/hide_from_all_viewers()
	if(!LAZYLEN(mobs_viewing))
		return
	for(var/mob/viewer as anything in mobs_viewing)
		hide_from(viewer)


/obj/item/storage/proc/update_viewers()
	for(var/_M in mobs_viewing)
		var/mob/M = _M
		if(!QDELETED(M) && M.s_active == src && (M in range(1, loc)))
			continue
		hide_from(M)

/obj/item/storage/proc/open(mob/user)
	if(use_sound && isliving(user))
		playsound(loc, use_sound, 50, TRUE, -5)
		add_fingerprint(user)
	if(user.s_active)
		user.s_active.close(user)
	show_to(user)

/obj/item/storage/proc/close(mob/user)
	hide_from(user)
	user.s_active = null

//This proc draws out the inventory and places the items on it. tx and ty are the upper left tile and mx, my are the bottm right.
//The numbers are calculated from the bottom-left The bottom-left slot being 1,1.
/obj/item/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	boxes.screen_loc = "[tx],[ty] to [mx],[my]"
	for(var/obj/O in contents)
		O.screen_loc = "[cx],[cy]"
		O.layer = ABOVE_HUD_LAYER
		SET_PLANE_EXPLICIT(O, ABOVE_HUD_PLANE, loc)
		cx++
		if(cx > mx)
			cx = tx
			cy--
	closer.screen_loc = "[mx + 1],[my]"

//This proc draws out the inventory and places the items on it. It uses the standard position.
/obj/item/storage/proc/standard_orient_objs(rows, cols, list/datum/numbered_display/display_contents)
	if(!boxes)
		return
	var/cx = 4
	var/cy = 2 + rows
	boxes.screen_loc = "4:16,2:16 to [4 + cols]:16,[2 + rows]:16"

	if(display_contents_with_number)
		for(var/datum/numbered_display/ND in display_contents)
			ND.sample_object.mouse_opacity = MOUSE_OPACITY_OPAQUE
			ND.sample_object.screen_loc = "[cx]:16,[cy]:16"
			ND.sample_object.maptext = "<font color='white' face='Small Fonts'>[(ND.number > 1) ? "[ND.number]" : ""]</font>"
			ND.sample_object.layer = ABOVE_HUD_LAYER
			SET_PLANE_EXPLICIT(ND.sample_object, ABOVE_HUD_PLANE, src)
			cx++
			if(cx > (4 + cols))
				cx = 4
				cy--
	else
		for(var/obj/O in contents)
			O.mouse_opacity = MOUSE_OPACITY_OPAQUE //This is here so storage items that spawn with contents correctly have the "click around item to equip"
			O.screen_loc = "[cx]:16,[cy]:16"
			O.maptext = ""
			O.layer = ABOVE_HUD_LAYER
			SET_PLANE_EXPLICIT(O, ABOVE_HUD_PLANE, src)
			cx++
			if(cx > (4 + cols))
				cx = 4
				cy--
	closer.screen_loc = "[4 + cols + 1]:16,2:16"

/datum/numbered_display
	var/obj/item/sample_object
	var/number

/datum/numbered_display/New(obj/item/sample)
	if(!istype(sample))
		qdel(src)
		return
	sample_object = sample
	number = 1

//This proc determins the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/obj/item/storage/proc/orient2hud(mob/user)
	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/display_contents
	if(display_contents_with_number)
		for(var/obj/O in contents)
			O.layer = initial(O.layer)
			O.plane = initial(O.plane)

		display_contents = list()
		adjusted_contents = 0
		for(var/obj/item/I in contents)
			var/found = FALSE
			for(var/datum/numbered_display/ND in display_contents)
				if(ND.sample_object.type == I.type && ND.sample_object.name == I.name)
					ND.number++
					found = TRUE
					break
			if(!found)
				adjusted_contents++
				display_contents.Add(new/datum/numbered_display(I))

	//var/mob/living/carbon/human/H = user
	var/row_num = 0
	var/col_count = min(7, storage_slots) - 1
	if(adjusted_contents > 7)
		row_num = round((adjusted_contents - 1) / 7) // 7 is the maximum allowed width.
	standard_orient_objs(row_num, col_count, display_contents)

//This proc returns TRUE if the item can be picked up and FALSE if it can't.
//Set the stop_messages to stop it from printing messages
/obj/item/storage/proc/can_be_inserted(obj/item/W, stop_messages = FALSE)
	if(!istype(W) || (W.item_flags & ABSTRACT)) //Not an item
		return FALSE

	if(loc == W)
		return FALSE //Means the item is already in the storage item

	if(!W.can_enter_storage(src, usr))
		return FALSE

	if(usr)
		var/turf/item_turf = get_turf(W)
		var/turf/storage_turf = get_turf(src)
		// Its ok to move items to/from nullspace, since its not a player action
		if(item_turf && storage_turf && !in_range(item_turf, storage_turf))
			if(!stop_messages)
				to_chat(usr, "<span class='warning'>[src] is too far from [W]!</span>")
			return FALSE

	if(contents.len >= storage_slots)
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>[W] won't fit in [src], make some space!</span>")
		return FALSE //Storage item is full

	if(can_hold.len)
		if(!is_type_in_typecache(W, can_hold))
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>[src] cannot hold [W].</span>")
			return FALSE

	if(is_type_in_typecache(W, cant_hold)) //Check for specific items which this container can't hold.
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>[src] cannot hold [W].</span>")
		return FALSE

	if(W.w_class > max_w_class)
		if(length(w_class_override) && is_type_in_list(W, w_class_override))
			return TRUE

		if(!stop_messages)
			to_chat(usr, "<span class='notice'>[W] is too big for [src].</span>")
		return FALSE

	if(W.w_class < min_w_class)
		if(length(w_class_override) && is_type_in_list(W, w_class_override))
			return TRUE

		if(!stop_messages)
			to_chat(usr, "<span class='notice'>[W] is too small for [src].</span>")
		return FALSE

	var/sum_w_class = W.w_class
	for(var/obj/item/I in contents)
		sum_w_class += I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > max_combined_w_class)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>[src] is full, make some space.</span>")
		return FALSE

	if(W.w_class >= w_class && (isstorage(W)))
		if(!istype(src, /obj/item/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>[src] cannot hold [W] as it's a storage item of the same size.</span>")
			return FALSE //To prevent the stacking of same sized storage items.

	if(HAS_TRAIT(W, TRAIT_NODROP)) //SHOULD be handled in unEquip, but better safe than sorry.
		to_chat(usr, "<span class='notice'>\the [W] is stuck to your hand, you can't put it in \the [src]</span>")
		return FALSE

	// item unequip delay
	if(usr && W.equip_delay_self > 0 && W.loc == usr && !usr.is_general_slot(usr.get_slot_by_item(W)))
		usr.visible_message(
			span_notice("[usr] начинает снимать [W.name]..."),
			span_notice("Вы начинаете снимать [W.name]..."),
		)
		if(!do_after(usr, W.equip_delay_self, usr, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_warning("Снятие [W.name] было прервано!")))
			return FALSE

		if(!usr.can_unEquip(W))
			return FALSE

	return TRUE

//This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
//The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
//such as when picking up all the items on a tile with one click.
/obj/item/storage/proc/handle_item_insertion(obj/item/W, prevent_warning = FALSE)
	if(!istype(W))
		return FALSE
	if(usr)
		if(W.loc == usr && !usr.drop_item_ground(W))
			return FALSE
		usr.update_icons()	//update our overlays
	if(silent)
		prevent_warning = TRUE

	if(usr)
		W.do_pickup_animation(src)

	W.forceMove(src)
	if(QDELING(W))
		return FALSE
	W.on_enter_storage(src)
	if(QDELING(W))
		return FALSE

	for(var/_M in mobs_viewing)
		var/mob/M = _M
		if((M.s_active == src) && M.client)
			M.client.screen += W

	if(usr)
		if(usr.client && usr.s_active != src)
			usr.client.screen -= W
		add_fingerprint(usr)

		if(!prevent_warning && !istype(W, /obj/item/gun/energy/kinetic_accelerator/crossbow))
			for(var/mob/M in viewers(usr, null))
				if(M == usr)
					to_chat(usr, "<span class='notice'>You put [W] into [src].</span>")
				else if(M in range(1)) //If someone is standing close enough, they can tell what it is...
					M.show_message("<span class='notice'>[usr] puts [W] into [src].</span>")
				else if(W && W.w_class >= WEIGHT_CLASS_NORMAL) //Otherwise they can only see large or normal items from a distance...
					M.show_message("<span class='notice'>[usr] puts [W] into [src].</span>")

		orient2hud(usr)
		if(usr.s_active)
			usr.s_active.show_to(usr)

	W.pixel_y = initial(W.pixel_y)
	W.pixel_x = initial(W.pixel_x)
	W.mouse_opacity = MOUSE_OPACITY_OPAQUE //So you can click on the area around the item to equip it, instead of having to pixel hunt
	update_icon()
	return TRUE

//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/obj/item/storage/proc/remove_from_storage(obj/item/W, atom/new_location)
	if(!istype(W))
		return FALSE

	for(var/_M in mobs_viewing)
		var/mob/M = _M
		if((M.s_active == src) && M.client)
			M.client.screen -= W

	if(new_location)
		if(ismob(new_location) || get(new_location, /mob))
			if(usr && !get(loc, /mob) && CONFIG_GET(flag/item_animations_enabled))
				W.loc = get_turf(src)	// This bullshit is required since /image/ registered in turf contents only
				W.pixel_x = pixel_x
				W.pixel_y = pixel_y
				W.do_pickup_animation(usr)
			W.layer = ABOVE_HUD_LAYER
			SET_PLANE_EXPLICIT(W, ABOVE_HUD_PLANE, src)
			W.pixel_y = initial(W.pixel_y)
			W.pixel_x = initial(W.pixel_x)
		else
			W.layer = initial(W.layer)
			SET_PLANE_IMPLICIT(W, initial(W.plane))
			W.mouse_opacity = initial(W.mouse_opacity)
			W.remove_outline()

		W.forceMove(new_location)

	if(usr)
		W.add_fingerprint(usr)
		orient2hud(usr)
		if(usr.s_active && !QDELETED(src))
			usr.s_active.show_to(usr)
	if(W.maptext)
		W.maptext = ""
	W.on_exit_storage(src)
	update_icon()
	return TRUE

/obj/item/storage/Exited(atom/movable/departed, atom/newLoc)
	remove_from_storage(departed, newLoc) //worry not, comrade; this only gets called once
	. = ..()

/obj/item/storage/deconstruct(disassembled = TRUE)
	var/drop_loc = loc
	if(ismob(loc))
		drop_loc = get_turf(src)
	for(var/obj/item/I in contents)
		remove_from_storage(I, drop_loc)
	qdel(src)


//This proc is called when you want to place an item into the storage item.
/obj/item/storage/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .
	if(istype(I, /obj/item/hand_labeler))
		var/obj/item/hand_labeler/labeler = I
		if(labeler.mode)	// labeling with afterattack
			return .

	if(isrobot(user))
		return .|ATTACK_CHAIN_BLOCKED_ALL //Robots can't interact with storage items.

	if(!can_be_inserted(I))
		if(length(contents) >= storage_slots) //don't use items on the backpack if they don't fit
			return .|ATTACK_CHAIN_BLOCKED_ALL
		return .

	handle_item_insertion(I)
	return .|ATTACK_CHAIN_BLOCKED_ALL


/obj/item/storage/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == src && !H.get_active_hand())	//Prevents opening if it's in a pocket.
			H.put_in_hands(src)
			H.l_store = null
			return
		if(H.r_store == src && !H.get_active_hand())
			H.put_in_hands(src)
			H.r_store = null
			return

	orient2hud(user)
	if(loc == user)
		if(user.s_active)
			user.s_active.close(user)
		open(user)
	else
		..()
	add_fingerprint(user)

/obj/item/storage/equipped(mob/user, slot, initial)
	. = ..()
	update_viewers()

/obj/item/storage/attack_ghost(mob/user)
	if(isobserver(user))
		// Revenants don't get to play with the toys.
		show_to(user)
	return ..()

/obj/item/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	pickup_all_on_tile = !pickup_all_on_tile
	switch(pickup_all_on_tile)
		if(TRUE)
			to_chat(usr, "[src] now picks up all items in a tile at once.")
		if(FALSE)
			to_chat(usr, "[src] now picks up one item at a time.")

/obj/item/storage/verb/quick_empty()
	set name = "Empty Contents"
	set category = "Object"

	if((!ishuman(usr) && (loc != usr)) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	drop_inventory(usr)

/obj/item/storage/proc/drop_inventory(user)
	var/turf/T = get_turf(src)
	hide_from(user)
	for(var/obj/item/I in contents)
		remove_from_storage(I, T)
		CHECK_TICK

/**
  * Populates the container with items
  *
  * Override with whatever you want to put in the container
  */
/obj/item/storage/proc/populate_contents()
	return // Override

/obj/item/storage/emp_act(severity)
	..()
	for(var/i in contents)
		var/atom/A = i
		A.emp_act(severity)

/obj/item/storage/hear_talk(mob/living/M, list/message_pieces)
	..()
	for(var/obj/O in contents)
		O.hear_talk(M, message_pieces)

/obj/item/storage/hear_message(mob/living/M, msg)
	..()
	for(var/obj/O in contents)
		O.hear_message(M, msg)

/obj/item/storage/attack_self(mob/user)
	//Clicking on itself will empty it, if allow_quick_empty is TRUE
	if(allow_quick_empty && user.is_in_active_hand(src))
		drop_inventory(user)

	else if(foldable)
		fold(user)

/obj/item/storage/proc/fold(mob/user)
	if(length(contents))
		to_chat(user, "<span class='warning'>You can't fold this [name] with items still inside!</span>")
		return
	if(!ispath(foldable))
		return

	var/found = FALSE
	for(var/mob/M in range(1))
		if(M.s_active == src) // Close any open UI windows first
			close(M)
		if(M == user)
			found = TRUE
	if(!found)	// User is too far away
		return

	to_chat(user, "<span class='notice'>You fold [src] flat.</span>")
	var/obj/item/stack/I = new foldable(get_turf(src), foldable_amt)
	user.put_in_hands(I)
	qdel(src)

//Returns the storage depth of an atom. This is the number of storage items the atom is contained in before reaching toplevel (the area).
//Returns -1 if the atom was not found on container.
/atom/proc/storage_depth(atom/container)
	var/depth = 0
	var/atom/cur_atom = src

	while(cur_atom && !(cur_atom in container.contents))
		if(isarea(cur_atom))
			return -1
		if(isstorage(cur_atom.loc))
			depth++
		cur_atom = cur_atom.loc

	if(!cur_atom)
		return -1	//inside something with a null loc.

	return depth

//Like storage depth, but returns the depth to the nearest turf
//Returns -1 if no top level turf (a loc was null somewhere, or a non-turf atom's loc was an area somehow).
/atom/proc/storage_depth_turf()
	var/depth = 0
	var/atom/cur_atom = src

	while(cur_atom && !isturf(cur_atom))
		if(isarea(cur_atom))
			return -1
		if(isstorage(cur_atom.loc))
			depth++
		cur_atom = cur_atom.loc

	if(!cur_atom)
		return -1	//inside something with a null loc.

	return depth

/obj/item/storage/serialize()
	var/data = ..()
	var/list/content_list = list()
	data["content"] = content_list
	data["slots"] = storage_slots
	data["max_w_class"] = max_w_class
	data["max_c_w_class"] = max_combined_w_class
	for(var/thing in contents)
		var/atom/movable/AM = thing
		// This code does not watch out for infinite loops
		// But then again a tesseract would destroy the server anyways
		// Also I wish I could just insert a list instead of it reading it the wrong way
		content_list.len++
		content_list[content_list.len] = AM.serialize()
	return data

/obj/item/storage/deserialize(list/data)
	if(isnum(data["slots"]))
		storage_slots = data["slots"]
	if(isnum(data["max_w_class"]))
		max_w_class = data["max_w_class"]
	if(isnum(data["max_c_w_class"]))
		max_combined_w_class = data["max_c_w_class"]
	for(var/thing in contents)
		qdel(thing) // out with the old
	for(var/thing in data["content"])
		if(islist(thing))
			list_to_object(thing, src)
		else if(thing == null)
			log_runtime(EXCEPTION("Null entry found in storage/deserialize."), src)
		else
			log_runtime(EXCEPTION("Non-list thing found in storage/deserialize."), src, list("Thing: [thing]"))
	..()

/obj/item/storage/AllowDrop()
	return TRUE

/obj/item/storage/ex_act(severity)
	for(var/atom/A in contents)
		A.ex_act(severity)
		CHECK_TICK
	..()

/obj/item/storage/proc/can_items_stack(obj/item/item_1, obj/item/item_2)
	if(!item_1 || !item_2)
		return

	return item_1.type == item_2.type && item_1.name == item_2.name

/obj/item/storage/proc/swap_items(obj/item/item_1, obj/item/item_2, mob/user = null)
	if(!(item_1.loc == src && item_2.loc == src))
		return

	var/index_1 = contents.Find(item_1)
	var/index_2 = contents.Find(item_2)

	var/list/new_contents = contents.Copy()
	new_contents.Swap(index_1, index_2)
	contents = new_contents

	if(user && user.s_active == src)
		orient2hud(user)
		show_to(user)
	return TRUE
