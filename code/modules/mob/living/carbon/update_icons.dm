//LOOK G-MA, I'VE JOINED CARBON PROCS THAT ARE IDENTICAL IN ALL CASES INTO ONE PROC, I'M BETTER THAN LIFE()
//I thought about mob/living but silicons and simple_animals don't want this just yet.
//Right now just handles lying down, but could handle other cases later.
//IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/changed = 0
	if(lying_angle != lying_prev)
		changed++
		ntransform.TurnTo(lying_prev, lying_angle)
		if(lying_angle == 0) //Lying to standing
			final_pixel_y = get_standard_pixel_y_offset()
		else //if(lying != 0)
			if(lying_prev == 0) //Standing to lying
				pixel_y = get_standard_pixel_y_offset()
				final_pixel_y = get_standard_pixel_y_offset(lying_angle)
				if(dir & (EAST|WEST)) //Facing east or west
					final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

		lying_prev = lying_angle	//so we don't try to animate until there's been another change.

	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(!changed)
		return

	SEND_SIGNAL(src, COMSIG_PAUSE_FLOATING_ANIM, 0.3 SECONDS)

	//if true, we want to avoid any animation time, it'll tween and not rotate at all otherwise.
	var/is_opposite_angle = SIMPLIFY_DEGREES(lying_angle + 180) == lying_prev
	animate(src, transform = ntransform, time = is_opposite_angle ? 0 : UPDATE_TRANSFORM_ANIMATION_TIME, pixel_y = final_pixel_y, dir = final_dir, easing = (EASE_IN|EASE_OUT))
	handle_transform_change()


/mob/living/carbon/proc/handle_transform_change()
	return

//update whether handcuffs appears on our hud.
/mob/living/carbon/proc/update_hud_handcuffed()
	if(!hud_used)
		return
	for(var/obj/screen/inventory/hand/hand_box as anything in hud_used.hand_slots)
		hand_box.update_appearance()


/mob/living/carbon/update_inv_r_hand()
	if(handcuffed)
		drop_r_hand()
		return
	if(r_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.screen_loc = ui_rhand
			client.screen += r_hand

/mob/living/carbon/update_inv_l_hand()
	if(handcuffed)
		drop_l_hand()
		return
	if(l_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.screen_loc = ui_lhand
			client.screen += l_hand

/mob/living/carbon/update_inv_wear_mask()
	if(istype(wear_mask, /obj/item/clothing/mask))
		update_hud_wear_mask(wear_mask)


/mob/living/carbon/update_inv_back()
	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1]
		inv?.update_appearance()

	if(back)
		update_hud_back(back)


/mob/living/carbon/update_inv_head()
	if(head)
		update_hud_head(head)

//update whether our head item appears on our hud.
/mob/living/carbon/proc/update_hud_head(obj/item/I)
	return

//update whether our mask item appears on our hud.
/mob/living/carbon/proc/update_hud_wear_mask(obj/item/I)
	return

//update whether our back item appears on our hud.
/mob/living/carbon/proc/update_hud_back(obj/item/I)
	return
