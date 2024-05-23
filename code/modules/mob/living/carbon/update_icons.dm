/**
 * Called whenever the mob is to be resized or when lying/standing up for carbons.
 * IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
 */
/mob/living/proc/update_transform(resize = RESIZE_DEFAULT_SIZE)
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = base_pixel_y + body_position_pixel_y_offset
	/**
	 * pixel x/y/w/z all discard values after the decimal separator.
	 * That, coupled with the rendered interpolation, may make the
	 * icons look awfuller than they already are, or not, whatever.
	 * The solution to this nit is translating the missing decimals.
	 * also flooring increases the distance from 0 for negative numbers.
	 */
	var/abs_pixel_y_offset = 0
	var/translate = 0
	if(current_size != RESIZE_DEFAULT_SIZE)
		var/standing_offset = get_pixel_y_offset_standing(current_size)
		abs_pixel_y_offset = abs(standing_offset)
		translate = (abs_pixel_y_offset - round(abs_pixel_y_offset)) * SIGN(standing_offset)
	var/final_dir = dir
	var/changed = FALSE

	if(lying_angle != lying_prev && rotate_on_lying)
		changed = TRUE
		if(lying_angle && lying_prev == 0)
			if(translate)
				ntransform.Translate(0, -translate)
			if(dir & (EAST|WEST)) //Standing to lying and facing east or west
				final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass
		else if(translate && !lying_angle && lying_prev != 0)
			ntransform.Translate(translate * (lying_prev == 270 ? -1 : 1), 0)
		///Done last, as it can mess with the translation.
		ntransform.TurnTo(lying_prev, lying_angle)

	if(resize != RESIZE_DEFAULT_SIZE)
		changed = TRUE
		var/is_vertical = !lying_angle || !rotate_on_lying
		///scaling also affects translation, so we've to undo the old translate beforehand.
		if(translate && is_vertical)
			ntransform.Translate(0, -translate)
		ntransform.Scale(resize)
		current_size *= resize
		//Update the height of the maptext according to the size of the mob so they don't overlap.
		var/old_maptext_offset = body_maptext_height_offset
		body_maptext_height_offset = initial(maptext_height) * (current_size - 1) * 0.5
		maptext_height += body_maptext_height_offset - old_maptext_offset
		//Update final_pixel_y so our mob doesn't go out of the southern bounds of the tile when standing
		if(is_vertical) //But not if the mob has been rotated.
			//Make sure the body position y offset is also updated
			body_position_pixel_y_offset = get_pixel_y_offset_standing(current_size)
			abs_pixel_y_offset = abs(body_position_pixel_y_offset)
			var/new_translate = (abs_pixel_y_offset - round(abs_pixel_y_offset)) * SIGN(body_position_pixel_y_offset)
			if(new_translate)
				ntransform.Translate(0, new_translate)
			final_pixel_y = base_pixel_y + body_position_pixel_y_offset

	if(!changed) //Nothing has been changed, nothing has to be done.
		return

	SEND_SIGNAL(src, COMSIG_PAUSE_FLOATING_ANIM, 0.3 SECONDS)

	//if true, we want to avoid any animation time, it'll tween and not rotate at all otherwise.
	var/is_opposite_angle = SIMPLIFY_DEGREES(lying_angle + 180) == lying_prev
	animate(src, transform = ntransform, time = is_opposite_angle ? 0 : UPDATE_TRANSFORM_ANIMATION_TIME, pixel_y = final_pixel_y, dir = final_dir, easing = (EASE_IN|EASE_OUT))
	handle_transform_change()

	SEND_SIGNAL(src, COMSIG_LIVING_POST_UPDATE_TRANSFORM, resize, lying_angle, is_opposite_angle)


/mob/living/proc/handle_transform_change()
	return


/mob/living/carbon
	var/list/overlays_standing[TOTAL_LAYERS]


/mob/living/carbon/proc/apply_overlay(cache_index)
	. = overlays_standing[cache_index]
	if(.)
		add_overlay(.)
	SEND_SIGNAL(src, COMSIG_CARBON_APPLY_OVERLAY, cache_index, .)


/mob/living/carbon/proc/remove_overlay(cache_index)
	. = overlays_standing[cache_index]
	if(.)
		cut_overlay(.)
		overlays_standing[cache_index] = null
	SEND_SIGNAL(src, COMSIG_CARBON_REMOVE_OVERLAY, cache_index, .)


/mob/living/carbon/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		overlays_standing[HANDCUFF_LAYER] = mutable_appearance(handcuffed.onmob_sheets[ITEM_SLOT_HANDCUFFED_STRING], "[handcuffed.item_state]_hands", layer = -HANDCUFF_LAYER)
		update_hud_hands()
	apply_overlay(HANDCUFF_LAYER)


/mob/living/carbon/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)
	if(legcuffed)
		overlays_standing[LEGCUFF_LAYER] = mutable_appearance(legcuffed.onmob_sheets[ITEM_SLOT_LEGCUFFED_STRING], "[legcuffed.item_state]_legs", layer = -LEGCUFF_LAYER)
	apply_overlay(LEGCUFF_LAYER)


/mob/living/carbon/update_inv_r_hand()
	remove_overlay(R_HAND_LAYER)
	if(r_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.screen_loc = ui_rhand
			client.screen += r_hand

		var/t_state = r_hand.item_state ? r_hand.item_state : r_hand.icon_state

		var/mutable_appearance/standing
		if(dna && r_hand.sprite_sheets_inhand?[dna.species.name])
			standing = mutable_appearance(r_hand.sprite_sheets_inhand[dna.species.name], "[t_state]_r", layer = -R_HAND_LAYER)
		else
			standing = mutable_appearance(r_hand.righthand_file, "[t_state]", layer = -R_HAND_LAYER)
			standing = center_image(standing, r_hand.inhand_x_dimension, r_hand.inhand_y_dimension)
		standing.color = r_hand.color
		standing.alpha = r_hand.alpha
		overlays_standing[R_HAND_LAYER] = standing
	apply_overlay(R_HAND_LAYER)


/mob/living/carbon/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)
	if(l_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.screen_loc = ui_lhand
			client.screen += l_hand

		var/t_state = l_hand.item_state ? l_hand.item_state : l_hand.icon_state

		var/mutable_appearance/standing
		if(dna && l_hand.sprite_sheets_inhand?[dna.species.name])
			standing = mutable_appearance(l_hand.sprite_sheets_inhand[dna.species.name], "[t_state]_l", layer = -L_HAND_LAYER)
		else
			standing = mutable_appearance(l_hand.lefthand_file, "[t_state]", layer = -L_HAND_LAYER)
			standing = center_image(standing, l_hand.inhand_x_dimension, l_hand.inhand_y_dimension)
		standing.color = l_hand.color
		standing.alpha = l_hand.alpha
		overlays_standing[L_HAND_LAYER] = standing
	apply_overlay(L_HAND_LAYER)


/// Updates hands HUD element icons.
/mob/living/carbon/proc/update_hud_hands()
	if(!client || !hud_used)
		return
	for(var/atom/movable/screen/inventory/hand/hand_box as anything in hud_used.hand_slots)
		hand_box.update_icon()


/// Changes item's screen_loc position and adds it on client screen.
/// If togleable_inventory is set to `TRUE`, additionally `/datum/hud/var/inventory_shown` will be checked.
/mob/living/carbon/proc/update_item_on_hud(obj/item/worn_item, ui_screen_loc, togleable_inventory = FALSE)
	if(!client || !hud_used || !hud_used.hud_shown)
		return

	client.screen += worn_item
	if(togleable_inventory && !hud_used.inventory_shown)
		return
	worn_item.screen_loc = ui_screen_loc


/mob/living/carbon/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return .
	update_z_overlays(GET_TURF_PLANE_OFFSET(new_turf), TRUE)


/mob/living/carbon/proc/refresh_loop(iter_cnt, rebuild = FALSE)
	for(var/i in 1 to iter_cnt)
		update_z_overlays(1, rebuild)
		sleep(3)
		update_z_overlays(0, rebuild)
		sleep(3)


// Rebuilding is a hack. We should really store a list of indexes into our existing overlay list or SOMETHING
// IDK. will work for now though, which is a lot better then not working at all
/mob/living/carbon/proc/update_z_overlays(new_offset, rebuild = FALSE)
	// Null entries will be filtered here
	for(var/i in 1 to length(overlays_standing))
		var/list/cache_grouping = overlays_standing[i]
		if(cache_grouping && !islist(cache_grouping))
			cache_grouping = list(cache_grouping)
		// Need this so we can have an index, could build index into the list if we need to tho, check
		if(!length(cache_grouping))
			continue
		overlays_standing[i] = update_appearance_planes(cache_grouping, new_offset)


#define NEXT_PARENT_COMMAND "next_parent"
/// Takes a list of mutable appearances
/// Returns a list in the form:
/// 1 - a list of all mutable appearances that would need to be updated to change planes in the event of a z layer change, alnongside the commands required
/// 	to properly track parents to update
/// 2 - a list of all parents that will require updating
/proc/build_planeed_apperance_queue(list/mutable_appearance/appearances)
	var/list/queue
	if(islist(appearances))
		queue = appearances.Copy()
	else
		queue = list(appearances)
	var/queue_index = 0
	var/list/parent_queue = list()

	// We are essentially going to unroll apperance overlays into a flattened list here, so we can filter out floating planes laster
	// It will look like "overlay overlay overlay (change overlay parent), overlay overlay etc"
	// We can use this list to dynamically update these non floating planes, later
	while(queue_index < length(queue))
		queue_index++
		// If it's not a command, we assert that it's an appearance
		var/mutable_appearance/appearance = queue[queue_index]
		if(!appearance || appearance == NEXT_PARENT_COMMAND) // Who fucking adds nulls to their sublists god you people are the worst
			continue

		var/mutable_appearance/new_appearance = new /mutable_appearance()
		new_appearance.appearance = appearance
		// Now check its children
		if(length(appearance.overlays))
			queue += NEXT_PARENT_COMMAND
			parent_queue += appearance
			for(var/mutable_appearance/child_appearance as anything in appearance.overlays)
				queue += child_appearance

	// Now we have a flattened list of parents and their children
	// Setup such that walking the list backwards will allow us to properly update overlays
	// (keeping in mind that overlays only update if an apperance is removed and added, and this pattern applies in a nested fashion)

	// If we found no results, return null
	if(!length(queue))
		return null

	// ALRIGHT MOTHERFUCKER
	// SO
	// DID YOU KNOW THAT OVERLAY RENDERING BEHAVIOR DEPENDS PARTIALLY ON THE ORDER IN WHICH OVERLAYS ARE ADDED?
	// WHAT WE'RE DOING HERE ENDS UP REVERSING THE OVERLAYS ADDITION ORDER (when it's walked back to front)
	// SO GUESS WHAT I'VE GOTTA DO, I'VE GOTTA SWAP ALLLL THE MEMBERS OF THE SUBLISTS
	// I HATE IT HERE
	var/lower_parent = 0
	var/upper_parent = 0
	var/queue_size = length(queue)
	while(lower_parent <= queue_size)
		// Let's reorder our "lists" (spaces between parent changes)
		// We've got a delta index, and we're gonna essentially use it to get "swap" positions from the top and bottom
		// We only need to loop over half the deltas to swap all the entries, any more and it'd be redundant
		// We floor so as to avoid over flipping, and ending up flipping "back" a delta
		// etc etc
		var/target = FLOOR((upper_parent - lower_parent) / 2, 1)
		for(var/delta_index in 1 to target)
			var/old_lower = queue[lower_parent + delta_index]
			queue[lower_parent + delta_index] = queue[upper_parent - delta_index]
			queue[upper_parent - delta_index] = old_lower

		// lower bound moves to the old upper, upper bound finds a new home
		// Note that the end of the list is a valid upper bound
		lower_parent = upper_parent // our old upper bound is now our lower bound
		while(upper_parent <= queue_size)
			upper_parent += 1
			if(length(queue) < upper_parent) // Parent found
				break
			if(queue[upper_parent] == NEXT_PARENT_COMMAND) // We found em lads
				break

	// One more thing to do
	// It's much more convinient for the parent queue to be a list of indexes pointing at queue locations
	// Rather then a list of copied appearances
	// Let's turn what we have now into that yeah?
	// This'll require a loop over both queues
	// We're using an assoc list here rather then several find()s because I feel like that's more sane
	var/list/apperance_to_position = list()
	for(var/i in 1 to length(queue))
		apperance_to_position[queue[i]] = i

	var/list/parent_indexes = list()
	for(var/mutable_appearance/parent as anything in parent_queue)
		parent_indexes += apperance_to_position[parent]

	// Alright. We should now have two queues, a command/appearances one, and a parents queue, which contain no fluff
	// And when walked backwards allow for proper plane updating
	var/list/return_pack = list(queue, parent_indexes)
	return return_pack


/atom/proc/update_appearance_planes(list/mutable_appearance/appearances, new_offset)
	var/list/build_list = build_planeed_apperance_queue(appearances)

	if(!length(build_list))
		return appearances

	// hand_back contains a new copy of the passed in list, with updated values
	var/list/hand_back = list()

	var/list/processing_queue = build_list[1]
	var/list/parents_queue = build_list[2]
	// Now that we have our queues, we're going to walk them forwards to remove, and backwards to add
	// Note, we need to do this separately because you can only remove a mutable appearance when it
	// Exactly matches the appearance it had when it was first "made static" (by being added to the overlays list)
	var/parents_index = 0
	for(var/item in processing_queue)
		if(item == NEXT_PARENT_COMMAND)
			parents_index++
			continue
		var/mutable_appearance/iter_apper = item
		if(parents_index)
			var/parent_src_index = parents_queue[parents_index]
			var/mutable_appearance/parent = processing_queue[parent_src_index]
			parent.overlays -= iter_apper.appearance
		else // Otherwise, we're at the end of the list, and our parent is the mob
			cut_overlay(iter_apper)

	// Now the back to front stuff, to readd the updated appearances
	var/queue_index = length(processing_queue)
	parents_index = length(parents_queue)
	while(queue_index >= 1)
		var/item = processing_queue[queue_index]
		if(item == NEXT_PARENT_COMMAND)
			parents_index--
			queue_index--
			continue
		var/mutable_appearance/new_iter = new /mutable_appearance()
		new_iter.appearance = item
		if(new_iter.plane != FLOAT_PLANE)
			// Here, finally, is where we actually update the plane offsets
			SET_PLANE_W_SCALAR(new_iter, PLANE_TO_TRUE(new_iter.plane), new_offset)
		if(parents_index)
			var/parent_src_index = parents_queue[parents_index]
			var/mutable_appearance/parent = processing_queue[parent_src_index]
			parent.overlays += new_iter.appearance
		else
			add_overlay(new_iter)
			// chant a protective overlays.Copy to prevent appearance theft and overlay sticking
			// I'm not joking without this overlays can corrupt and be replaced by other appearances
			// the compiler might call it useless but I swear it works
			// we conjure the spirits of the computer with our spells, we conjur- (Hey lemon make a damn issue report already)
			var/list/does_nothing = new_iter.overlays.Copy()
			pass(does_nothing)
			hand_back += new_iter

		queue_index--
	return hand_back

#undef NEXT_PARENT_COMMAND

