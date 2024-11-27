/**
 * This code contains abstract stacked item. Main goal of this is to make items dropping from storages, smartfridges, etc. not lag the clients out.
 * It is, as simple is possible, tries to implement stacked items behavior like in storages.
 * Main features:
 * - Items appear stacked when dropped from smartfridge on destruction or when amount taken at one time is too high
 * - Same rule applies to bags or storages with display_contents_with_number and allow_quick_empty properties enabled
 * - Can't be taken by hand. Instead, player takes one sample from entire stack.
 * - Same rule applies to pulling. Player pulls only one sample from entire stack.
 * - Player can walk over stack.
 * - Integrity of stack is determenied by summary of stacked items.
 * - One by one items are deleted from stack if stack is damaged by integrity of one stack item.
 * - Player can take items from a stack using bags.
 * - Icon and icon state is determined by item it is holding.
 * - Player can't add items to a stockpile.
 */

/// Abstract stacked item. Do not spawn directly
/obj/stacked_item
	name = "Stockpiled item"
	desc = "Stockpile of some items."
	anchored = TRUE
	density = FALSE
	var/holding_type
	var/list/internal_storage = list()

/obj/stacked_item/Initialize(mapload, list/contents_to_add)
	. = ..()
	enrich_contents(contents_to_add)

/obj/stacked_item/Destroy()
	. = ..()
	QDEL_LIST(internal_storage)

/// Enriches the contents of stockpile
/obj/stacked_item/proc/enrich_contents(list/contents_to_add)
	if(length(contents_to_add) < 1)
		stack_trace("Attempted to make a stockpile from no contents")

	for(var/obj/item/item in contents_to_add)
		RegisterSignal(item, COMSIG_QDELETING, PROC_REF(handle_item_deletion))
		item.forceMove(src)

	internal_storage = contents_to_add
	var/obj/item/item = internal_storage[1]
	holding_type = item.type
	obj_integrity = item.max_integrity * length(internal_storage)
	max_integrity = item.max_integrity * length(internal_storage)
	name = "Stockpile of [item.name]"
	desc = "This is a stockpile of [item.name]"

	update_icon(UPDATE_ICON_STATE)

/obj/stacked_item/update_icon_state()
	if(length(internal_storage) < 1)
		return

	var/obj/item/item = internal_storage[1]
	icon = item.icon
	icon_state = item.icon_state
	appearance = item.appearance
	pixel_x = base_pixel_x
	pixel_y = base_pixel_y
	maptext = "<font color='white' face='Small Fonts'>[(length(internal_storage) > 1) ? "[length(internal_storage)]" : ""]</font>"

/obj/stacked_item/proc/handle_item_deletion(obj/item/item_to_remove)
	SIGNAL_HANDLER
	remove_item(item_to_remove)

/// Retrieves and removes item from internal storage. Returns reference to removed item.
/obj/stacked_item/proc/remove_item(obj/item/item_to_remove)
	internal_storage -= item_to_remove
	contents -= item_to_remove
	if(!length(internal_storage))
		qdel(src)

	update_icon(UPDATE_ICON_STATE)
	return item_to_remove

/// Returns item from a stack
/obj/stacked_item/proc/get_item()
	if(length(internal_storage) < 1)
		return

	return internal_storage[length(internal_storage)]

/obj/stacked_item/attack_hand(mob/living/user, list/modifiers)
	var/obj/item/item = get_item()
	if(user.put_in_active_hand(item, ignore_anim = FALSE))
		remove_item(item)
		return


/obj/stacked_item/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	var/cached_integrity = obj_integrity
	var/destroy_step = max_integrity / length(internal_storage)
	. = ..()
	var/resulting_integrity = obj_integrity
	var/items_to_destroy = round((cached_integrity - resulting_integrity) / destroy_step)
	if(items_to_destroy < 1)
		return

	for(var/item in items_to_destroy)
		remove_item(item)
		qdel(item)


/obj/stacked_item_test

/obj/stacked_item_test/Initialize(mapload)
	. = ..()
	var/list/objects_to_add = list()
	for(var/i in 1 to 100)
		var/item = new /obj/item/reagent_containers/food/snacks/grown/ambrosia/gaia(src)
		objects_to_add += item

	new /obj/stacked_item(get_turf(src), objects_to_add)
	return INITIALIZE_HINT_QDEL
