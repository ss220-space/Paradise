#define STORAGE_CAP_WIDTH 2
#define STORED_CAP_WIDTH 4
#define BASE_STORAGE_WIDTH 200
#define MAX_LINE_WIDTH 292

#define STORAGE_TILE_POSITION_X 4
#define STORAGE_TILE_POSITION_Y 2
#define STORAGE_PIXEL_POSITION_X 16
#define STORAGE_PIXEL_POSITION_Y 16
// 3 in an number choosen by altering diffent values, to make gaps more lovely looking
#define STORAGE_SIZE_MULTIPLIER_Y (ICON_SIZE_Y - 3)

// To clarify:
// For use_to_pickup and allow_quick_gather functionality,
// see item/attackby() (/game/objects/items.dm, params)
// Do not remove this functionality without good reason, cough reagent_containers cough.
// -Sayu

/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	flags = BLOCKS_LIGHT
	interaction_flags_click = ALLOW_RESTING | FORBID_TELEKINESIS_REACH
	abstract_type = /obj/item/storage
	/// No message on putting items in
	var/silent = FALSE
	/// List of objects which this item can store (if set, it can't store anything else)
	var/list/can_hold = list()
	/// List of objects that can be stored, regardless of w_class
	var/list/w_class_override = list()
	/// List of objects which this item can't store (in effect only if can_hold isn't set)
	var/list/cant_hold = list()
	/// Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_w_class = WEIGHT_CLASS_SMALL
	/// Min size of objects that this object can store (in effect only if can_hold isn't set)
	var/min_w_class
	/// The sum of the w_classes of all the items in this storage item.
	var/max_combined_w_class = 14
	var/storage_slots = 7
	var/atom/movable/screen/storage/boxes = null
	var/list/datum/storage_box/storage_boxes
	var/atom/movable/screen/close/closer
	/// Set this to make it possible to use this item in an inverse way, so you can have the item in your hand and click items on the floor to pick them up.
	var/use_to_pickup
	/// Set this to make the storage item group contents of the same type and display them as a number.
	var/display_contents_with_number
	/// Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_empty
	/// Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/allow_quick_gather
	/// FALSE = pick one at a time, TRUE = pick all on tile
	var/pickup_all_on_tile = TRUE
	/// Sound played when used. `null` for no sound.
	var/use_sound = SFX_RUSTLE
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

	if(display_contents_with_number)
		boxes = new /atom/movable/screen/storage()
		boxes.name = "storage"
		boxes.master = src
		boxes.icon_state = "block"
		boxes.screen_loc = "7,7 to 10,8"
		boxes.layer = HUD_LAYER
		boxes.plane = HUD_PLANE

	closer = new /atom/movable/screen/close()
	closer.master = src

	orient2hud()


/obj/item/storage/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/contextual_screentip_bare_hands, rmb_text = "Открыть")

/obj/item/storage/Destroy()
	for(var/obj/O in contents)
		O.mouse_opacity = initial(O.mouse_opacity)

	. = ..()
	QDEL_NULL(boxes)
	QDEL_NULL(closer)
	QDEL_LIST_ASSOC_VAL(storage_boxes)
	LAZYCLEARLIST(mobs_viewing)

/obj/item/storage/forceMove(atom/destination)
	. = ..()
	if(!destination || ismob(destination.loc))
		return .
	for(var/mob/player in mobs_viewing)
		if(player == destination)
			continue
		hide_from(player)

/obj/item/storage/proc/dump_storage(mob/user, obj/item/storage/target)
	if(!length(contents) || (HAS_TRAIT(user, TRAIT_RESTRAINED)) || (HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) || src == target)
		return
	for(var/obj/item/thing in contents)
		if(!target.can_be_inserted(thing))
			continue
		if(!do_after(user, 0.3 SECONDS, target = user))
			break
		playsound(loc, SFX_RUSTLE, 50, TRUE, -5)
		target.handle_item_insertion(thing, user)

/obj/item/storage/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(!isliving(usr))
		return FALSE

	// Stops inventory actions in a mech, while ventcrawling and while being incapacitated
	if(ismecha(user.loc) || is_ventcrawling(user) || user.incapacitated())
		return FALSE

	if(over_object == user && IsReachableBy(user)) // this must come before the screen objects only block
		open(user)
		return FALSE

	if(isstorage(over_object))
		var/obj/item/storage = over_object
		if(!(storage.item_flags & IN_STORAGE))
			dump_storage(user, over_object)
			return TRUE

	if((!istype(src, /obj/item/storage/lockbox) && (istable(over_object) || isfloorturf(over_object)) \
		&& length(contents) && loc == user && !user.incapacitated() && over_object.IsReachableBy(user)))

		if(tgui_alert(user, "Опустошить содержимое [declent_ru(GENITIVE)] на [over_object.declent_ru(ACCUSATIVE)]?", "Подтверждение", list("Да", "Нет")) != "Да")
			return FALSE

		if(!user || !over_object || user.incapacitated() || loc != user || !over_object.IsReachableBy(user))
			return FALSE

		if(user.s_active == src)
			close(user)

		user.face_atom(over_object)
		user.visible_message(
			span_notice("[user] опустоша[PLUR_ET_YUT(user)] содерижмое [declent_ru(GENITIVE)] на [over_object.declent_ru(ACCUSATIVE)]."),
			span_notice("Вы опустошаете содержимое [declent_ru(ACCUSATIVE)] на [over_object.declent_ru(ACCUSATIVE)]."),
		)
		var/turf/object_turf = get_turf(over_object)
		for(var/obj/item/item in src)
			remove_from_storage(item, object_turf)

		update_icon() // For content-sensitive icons
		return FALSE

	return ..()

/obj/item/storage/click_alt(mob/user)
	if(isobserver(user))
		show_to(user)
		return CLICK_ACTION_SUCCESS
	open(user)
	return CLICK_ACTION_SUCCESS

/obj/item/storage/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	click_alt(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/storage/attack_self_secondary(mob/user, list/modifiers)
	open(user)
	return TRUE

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

/obj/item/storage/proc/show_to(mob/user, from_inv_observers = FALSE)
	if(!user.client)
		return
	if(QDELETED(src))
		return
	if(user.s_active != src && !isobserver(user))
		for(var/obj/item/I in src) // For bombs with mousetraps, facehuggers etc
			if(I.on_found(user))
				return

	if(user.s_active && user.s_active != src)
		user.s_active.hide_from(user)

	if(!display_contents_with_number && !LAZYIN(storage_boxes, user))
		LAZYADDASSOC(storage_boxes, user, new /datum/storage_box(src))

	orient2hud(user) // this only needs to happen to make .contents show properly as screen objects.

	if(!display_contents_with_number)
		user.client.screen |= storage_boxes[user].screens_list()
	else
		user.client.screen |= boxes
		user.client.screen |= closer
	user.client.screen |= contents

	user.s_active = src
	LAZYOR(mobs_viewing, user)

	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_mob_qdeleting), TRUE)

	if(from_inv_observers)
		return

	for(var/mob/dead/observer/observe in user.inventory_observers)
		if(!observe.client)
			LAZYREMOVE(user.inventory_observers, observe)
			continue
		show_to(observe, TRUE)

/obj/item/storage/proc/hide_from(mob/user, from_inv_observers = FALSE)
	LAZYREMOVE(mobs_viewing, user) // Remove clientless mobs too
	if(!user.client)
		return
	user.client.screen -= boxes
	var/datum/storage_box/box = LAZYACCESS(storage_boxes, user)
	if(box)
		user.client.screen -= box.screens_list()
		storage_boxes -= user
	user.client.screen -= closer
	user.client.screen -= contents
	if(user.s_active == src)
		user.s_active = null

	UnregisterSignal(user, COMSIG_QDELETING)

	if(from_inv_observers)
		return

	for(var/mob/dead/observer/observe in user.inventory_observers)
		if(!observe.client)
			LAZYREMOVE(user.inventory_observers, observe)
			continue
		hide_from(observe, TRUE)

/obj/item/storage/proc/on_mob_qdeleting(mob/source, force)
	SIGNAL_HANDLER
	hide_from(source)

/obj/item/storage/proc/hide_from_all_viewers()
	if(!LAZYLEN(mobs_viewing))
		return
	for(var/mob/viewer as anything in mobs_viewing)
		hide_from(viewer)

/obj/item/storage/proc/update_viewers()
	for(var/mob/M as anything in mobs_viewing)
		if(!QDELETED(M) && M.s_active == src && (M in range(1, loc)))
			continue
		hide_from(M)

/obj/item/storage/proc/open(mob/user)
	if(use_sound && isliving(user))
		playsound(loc, use_sound, 50, TRUE, -5)
		add_fingerprint(user)

	if(user.s_active)
		user.s_active.close(user)

	if(user?.hud_used?.is_shown_robot_modules())
		user?.hud_used?.toggle_show_robot_modules()

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

/obj/item/storage/proc/space_orient_objs(list/obj/item/display_contents)
	var/total_width = 1
	var/line_width
	var/lines_num = 1
	for(var/obj/item/stored in contents)
		total_width += stored.storage_display_width
		if(total_width <= MAX_LINE_WIDTH)
			continue
		lines_num++
		line_width = total_width - stored.storage_display_width
		total_width = 1 + stored.storage_display_width

	if(!line_width)
		if((total_width + 32) > MAX_LINE_WIDTH)
			lines_num++
			line_width = total_width
		else
			line_width = min(1 + storage_slots * ICON_SIZE_X, max(total_width + 32, BASE_STORAGE_WIDTH))

	var/first_time = TRUE
	for(var/mob/user as anything in storage_boxes)
		var/ui_style
		var/ui_color
		if(user.client && user.client.prefs)
			var/datum/preferences/prefs = user.client.prefs
			ui_style = !(prefs.toggles3 & PREFTOGGLE_3_STORAGE_NEUTRAL) && prefs.UI_style
			ui_color = (prefs.toggles3 & PREFTOGGLE_3_STORAGE_COLORFY) && prefs.UI_style_color
		storage_boxes[user].modify(line_width, lines_num, ui_style, ui_color, first_time)
		first_time = FALSE

/datum/storage_box
	/// Parent storage item ref
	var/obj/item/storage/storage
	// Borders and filling of storage
	var/atom/movable/screen/storage/space_box/start
	var/atom/movable/screen/storage/space_box/continued
	var/atom/movable/screen/storage/space_box/end
	var/atom/movable/screen/storage/space_box/top
	var/atom/movable/screen/storage/space_box/bottom
	/// Part of storage used for item boxes overlays
	var/atom/movable/screen/storage/space_box/place_items
	/// Storage closer ref
	var/atom/movable/screen/close/closer

/datum/storage_box/New(master)
	// Making ref to parent storage
	storage = master

	// Initialize screen objects
	start = new
	start.icon_state = "storage_start"
	start.master = master

	end = new
	end.icon_state = "storage_end"
	end.master = master

	continued = new
	continued.icon_state = "storage_continue"
	continued.master = master

	top = new
	top.icon_state = "storage_top"
	top.master = master

	bottom = new
	bottom.icon_state = "storage_bottom"
	bottom.master = master

	closer = new
	closer.master = master

	place_items = new

/datum/storage_box/proc/modify(line_width, lines_num, ui_style, ui_color, first_time)
	place_items.overlays.Cut()
	var/ui_icon
	// Change icon
	if(ui_style)
		ui_icon = ui_style2icon(ui_style)
		start.icon = ui_icon
		continued.icon = ui_icon
		end.icon = ui_icon
		top.icon = ui_icon
		bottom.icon = ui_icon
		closer.icon = ui_icon
	// Change color
	if(ui_color)
		start.color = ui_color
		continued.color = ui_color
		end.color = ui_color
		top.color = ui_color
		bottom.color = ui_color
		closer.color = ui_color
	var/y_enlarge = (ICON_SIZE_Y + (lines_num - 1) * (STORAGE_SIZE_MULTIPLIER_Y)) / ICON_SIZE_Y
	// Both axes modify
	var/matrix/modify_matrix = matrix()
	modify_matrix.Scale((line_width - STORAGE_CAP_WIDTH + 1) / ICON_SIZE_X, y_enlarge)
	continued.transform = modify_matrix
	// Y axis modify
	modify_matrix = matrix()
	modify_matrix.Scale(1, y_enlarge)
	start.transform = modify_matrix
	end.transform = modify_matrix
	// X axis modify
	modify_matrix = matrix()
	modify_matrix.Scale((line_width + 2) / ICON_SIZE_X, 1)
	top.transform = modify_matrix
	bottom.transform = modify_matrix
	// Move out box to correct place after resize
	move_storage_box(y_enlarge, line_width, lines_num)

	var/startpoint
	var/endpoint = 1
	var/current_level = 0
	for(var/obj/item/stored in storage.contents)
		startpoint = endpoint + 1
		endpoint += stored.storage_display_width
		if(endpoint > line_width)
			current_level++
			startpoint = 2
			endpoint = 1 + stored.storage_display_width

		var/datum/item_storage_box/item_box = new()
		item_box.modify(startpoint, endpoint, lines_num, current_level, ui_icon, ui_color)
		add_item(item_box)

		if(!first_time)
			continue

		stored.screen_loc = "[STORAGE_TILE_POSITION_X]:[floor((startpoint + endpoint) / 2)],[STORAGE_TILE_POSITION_Y]:[STORAGE_PIXEL_POSITION_Y + STORAGE_SIZE_MULTIPLIER_Y * (lines_num - current_level - 1)]"
		stored.layer = ABOVE_HUD_LAYER
		stored.mouse_opacity = MOUSE_OPACITY_OPAQUE
		stored.maptext = ""
		SET_PLANE_EXPLICIT(stored, ABOVE_HUD_PLANE, storage)

/datum/storage_box/proc/move_storage_box(y_enlarge, line_width, lines_num)
	//Calculate offset
	var/y_offset = floor(16 * y_enlarge)
	// Move modified object
	start.screen_loc = "[STORAGE_TILE_POSITION_X]:[STORAGE_PIXEL_POSITION_X],[STORAGE_TILE_POSITION_Y]:[y_offset]"
	place_items.screen_loc = "[STORAGE_TILE_POSITION_X]:[STORAGE_PIXEL_POSITION_X],[STORAGE_TILE_POSITION_Y]:[STORAGE_PIXEL_POSITION_Y]"
	continued.screen_loc = "[STORAGE_TILE_POSITION_X]:[floor(line_width / 2 + STORAGE_CAP_WIDTH)],[STORAGE_TILE_POSITION_Y]:[y_offset]"
	end.screen_loc = "[STORAGE_TILE_POSITION_X]:[STORAGE_PIXEL_POSITION_X + line_width + 1],[STORAGE_TILE_POSITION_Y]:[y_offset]"
	top.screen_loc = "[STORAGE_TILE_POSITION_X]:[floor(line_width / 2 + STORAGE_CAP_WIDTH)],[STORAGE_TILE_POSITION_Y]:[y_offset + round((STORAGE_SIZE_MULTIPLIER_Y + 1) / 2) * (lines_num - 1)]"
	bottom.screen_loc = "[STORAGE_TILE_POSITION_X]:[floor(line_width / 2 + STORAGE_CAP_WIDTH)],[STORAGE_TILE_POSITION_Y]:[STORAGE_PIXEL_POSITION_Y]"
	closer.screen_loc = "[STORAGE_TILE_POSITION_X]:[line_width + STORAGE_PIXEL_POSITION_X + STORAGE_CAP_WIDTH + 1],[STORAGE_TILE_POSITION_Y]:[STORAGE_PIXEL_POSITION_Y]"

/datum/storage_box/proc/screens_list()
	return list(start, continued, end, top, bottom, place_items, closer)

/datum/storage_box/proc/add_item(datum/item_storage_box/item_box)
	place_items.add_overlay(item_box.screens_list())

/datum/storage_box/Destroy(force, ...)
	QDEL_NULL(start)
	QDEL_NULL(continued)
	QDEL_NULL(end)
	QDEL_NULL(bottom)
	QDEL_NULL(top)
	QDEL_NULL(place_items)
	QDEL_NULL(closer)
	storage = null
	return ..()

/datum/item_storage_box
	// Borders and filling of item storage box
	var/atom/movable/screen/storage/start
	var/atom/movable/screen/storage/continued
	var/atom/movable/screen/storage/end

/datum/item_storage_box/New()
	. = ..()
	start = new()
	start.icon_state = "stored_start"
	continued = new()
	continued.icon_state = "stored_continue"
	end = new()
	end.icon_state = "stored_end"

/datum/item_storage_box/proc/screens_list()
	return list(start, continued, end)

/datum/item_storage_box/proc/modify(startpoint, endpoint, lines_num, current_level, ui_icon, ui_color)
	// Change icon
	if(ui_icon)
		start.icon = ui_icon
		continued.icon = ui_icon
		end.icon = ui_icon
	if(ui_color)
		start.color = ui_color
		continued.color = ui_color
		end.color = ui_color

	// Calcylate Y offset for current level
	var/box_offset = STORAGE_SIZE_MULTIPLIER_Y * (lines_num - current_level - 1)

	// Modify start
	var/matrix/modify_matrix = matrix(start.transform)
	modify_matrix.Translate(startpoint, box_offset)
	start.transform = modify_matrix

	// Modify continue
	modify_matrix = matrix(continued.transform)
	modify_matrix.Scale((endpoint - startpoint - STORED_CAP_WIDTH * 2) / ICON_SIZE_X, 1)
	modify_matrix.Translate(startpoint + (endpoint - startpoint) / 2 - (ICON_SIZE_X - STORAGE_PIXEL_POSITION_X), box_offset)
	continued.transform = modify_matrix

	// Modify end
	modify_matrix = matrix(end.transform)
	modify_matrix.Translate(endpoint - STORED_CAP_WIDTH, box_offset)
	end.transform = modify_matrix

/datum/item_storage_box/Destroy(force, ...)
	QDEL_NULL(start)
	QDEL_NULL(continued)
	QDEL_NULL(end)
	return ..()

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

	if(display_contents_with_number)
		standard_orient_objs(row_num, col_count, display_contents)
	else
		space_orient_objs(display_contents)

/// This proc returns TRUE if the item can be picked up and FALSE if it can't.
/// Set the stop_messages to stop it from printing messages
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
		var/turf/user_turf = get_turf(usr)
		// Its ok to move items to/from nullspace, since its not a player action
		if(item_turf && storage_turf && (!in_range(storage_turf, user_turf) || !in_range(item_turf, user_turf)))
			if(!stop_messages)
				usr.balloon_alert(usr, "слишком далеко!")
			return FALSE

	if(length(contents) >= storage_slots)
		if(!stop_messages)
			usr.balloon_alert(usr, "нет места!")
		return FALSE //Storage item is full

	if(length(can_hold))
		if(!is_type_in_typecache(W, can_hold))
			if(!stop_messages)
				to_chat(usr, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] не подход[PLUR_IT_YAT(src)] для [W.declent_ru(GENITIVE)]!"))
			return FALSE

	if(is_type_in_typecache(W, cant_hold)) //Check for specific items which this container can't hold.
		if(!stop_messages)
			to_chat(usr, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] не подход[PLUR_IT_YAT(src)] для [W.declent_ru(GENITIVE)]!"))
		return FALSE

	if(W.w_class > max_w_class)
		if(length(w_class_override) && is_type_in_list(W, w_class_override))
			return TRUE

		if(!stop_messages)
			usr.balloon_alert(usr, "слишком большой объект!")
		return FALSE

	if(W.w_class < min_w_class)
		if(length(w_class_override) && is_type_in_list(W, w_class_override))
			return TRUE

		if(!stop_messages)
			usr.balloon_alert(usr, "слишком маленький объект!")
		return FALSE

	var/sum_w_class = W.w_class
	for(var/obj/item/I in contents)
		sum_w_class += I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > max_combined_w_class)
		if(!stop_messages)
			usr.balloon_alert(usr, "нет места!")
		return FALSE

	if(W.w_class >= w_class && (isstorage(W)))
		if(!istype(src, /obj/item/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
			if(!stop_messages)
				usr.balloon_alert(usr, "слишком большой объект!")
			return FALSE //To prevent the stacking of same sized storage items.

	if(HAS_TRAIT(W, TRAIT_NODROP)) //SHOULD be handled in unEquip, but better safe than sorry.
		usr.balloon_alert(usr, "не получается выпустить!")
		return FALSE

	// item unequip delay
	if(usr && W.equip_delay_self > 0 && W.loc == usr && !usr.is_general_slot(usr.get_slot_by_item(W)))
		usr.visible_message(
			span_notice("[usr] начина[PLUR_ET_YUT(usr)] снимать [W.declent_ru(ACCUSATIVE)]."),
			span_notice("Вы начинаете снимать [W.declent_ru(ACCUSATIVE)]."),
		)
		if(!do_after(usr, W.equip_delay_self, usr, timed_action_flags = (DA_IGNORE_LYING|DA_IGNORE_USER_LOC_CHANGE), max_interact_count = 1, cancel_on_max = TRUE))
			usr.balloon_alert(usr, "снятие прервано!")
			return FALSE

		if(!usr.can_unEquip(W))
			return FALSE

	return TRUE

/// This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
/// The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
/// such as when picking up all the items on a tile with one click.
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

		for(var/mob/dead/observer/observe in usr.inventory_observers)
			if(!observe.client)
				LAZYREMOVE(usr.inventory_observers, observe)
				continue
			observe.client.screen -= W

		add_fingerprint(usr)

		if(!prevent_warning && !istype(W, /obj/item/gun/energy/kinetic_accelerator/crossbow))
			for(var/mob/M in viewers(usr, null))
				if(M == usr)
					to_chat(usr, span_notice("Вы помещаете [W.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
				else if(M in range(1)) //If someone is standing close enough, they can tell what it is...
					M.show_message(span_notice("[usr] помеща[PLUR_ET_YUT(usr)] [W.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
				else if(W && W.w_class >= WEIGHT_CLASS_NORMAL) //Otherwise they can only see large or normal items from a distance...
					M.show_message(span_notice("[usr] помеща[PLUR_ET_YUT(usr)] [W.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))

		orient2hud(usr)
		if(usr.s_active)
			usr.s_active.show_to(usr)

	W.pixel_y = initial(W.pixel_y)
	W.pixel_x = initial(W.pixel_x)
	W.mouse_opacity = MOUSE_OPACITY_OPAQUE //So you can click on the area around the item to equip it, instead of having to pixel hunt
	update_icon()
	return TRUE

/// Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/obj/item/storage/proc/remove_from_storage(obj/item/W, atom/new_location)
	if(!istype(W))
		return FALSE

	W.item_flags &= ~IN_STORAGE

	for(var/mob/M as anything in mobs_viewing)
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

	if(!attempt_insert(I))
		return .

	return .|ATTACK_CHAIN_BLOCKED_ALL

/obj/item/storage/proc/attempt_insert(obj/item/item)
	if(!can_be_inserted(item))
		if(length(contents) >= storage_slots) //don't use items on the backpack if they don't fit
			return TRUE
		return FALSE

	handle_item_insertion(item)
	return TRUE

/obj/item/storage/attackby_secondary(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	open(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

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
	set name = "Режим сбора"
	set category = VERB_CATEGORY_OBJECT

	pickup_all_on_tile = !pickup_all_on_tile
	switch(pickup_all_on_tile)
		if(TRUE)
			to_chat(usr, "[DECLENT_RU_CAP(src, NOMINATIVE)] теперь будет собирать все предметы с тайла за раз.")
		if(FALSE)
			to_chat(usr, "[DECLENT_RU_CAP(src, NOMINATIVE)] теперь будет собирать один предмет с тайла за раз")

/obj/item/storage/verb/quick_empty()
	set name = "Выбросить содержимое"
	set category = VERB_CATEGORY_OBJECT

	if((!ishuman(usr) && (loc != usr)) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	drop_inventory(usr)

/obj/item/storage/proc/drop_inventory(user)
	var/turf/current_turf = get_turf(src)
	hide_from(user)
	for(var/obj/item/item in contents)
		remove_from_storage(item, current_turf)
		CHECK_TICK

/obj/item/storage/proc/force_drop_inventory()
	var/turf/T = get_turf(src)
	for(var/obj/item/I in contents)
		remove_from_storage(I, T)

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
		user.balloon_alert(user, "внутри что-то есть!")
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
	user.balloon_alert(user, "сложено")
	var/obj/item/stack/I = new foldable(get_turf(src), foldable_amt)
	user.put_in_hands(I)
	qdel(src)

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
		content_list[length(content_list)] = AM.serialize()
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
			stack_trace("Null entry found in storage/deserialize.")
		else
			stack_trace("Non-list thing found in storage/deserialize (Thing: [thing])")
	..()

/obj/item/storage/AllowDrop()
	return TRUE

/obj/item/storage/ex_act(severity, target)
	for(var/atom/A in contents)
		A.ex_act(severity, target)
		CHECK_TICK
	return ..()

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

#undef STORAGE_CAP_WIDTH
#undef STORED_CAP_WIDTH
#undef BASE_STORAGE_WIDTH
#undef MAX_LINE_WIDTH

#undef STORAGE_TILE_POSITION_X
#undef STORAGE_TILE_POSITION_Y
#undef STORAGE_PIXEL_POSITION_X
#undef STORAGE_PIXEL_POSITION_Y
#undef STORAGE_SIZE_MULTIPLIER_Y
