//Xeno Overlays Indexes//////////
#define X_HEAD_LAYER			1
#define X_SUIT_LAYER			2
#define X_L_HAND_LAYER			3
#define X_R_HAND_LAYER			4
#define X_TARGETED_LAYER		5
#define X_FIRE_LAYER			6
#define X_TOTAL_LAYERS			6
/////////////////////////////////

/mob/living/carbon/alien/humanoid
	var/list/overlays_standing[X_TOTAL_LAYERS]


/mob/living/carbon/alien/humanoid/proc/apply_overlay(cache_index)
	if((. = overlays_standing[cache_index]))
		add_overlay(.)


/mob/living/carbon/alien/humanoid/proc/remove_overlay(cache_index)
	var/I = overlays_standing[cache_index]
	if(I)
		cut_overlay(I)
		overlays_standing[cache_index] = null


/mob/living/carbon/alien/humanoid/update_icons()
	cut_overlays()

	if(stat == DEAD)
		//If we mostly took damage from fire
		if(getFireLoss() > 125)
			icon_state = "alien[caste]_husked"
		else
			icon_state = "alien[caste]_dead"

	else if((stat == UNCONSCIOUS && !IsSleeping()) || IsWeakened() || IsParalyzed())
		icon_state = "alien[caste]_unconscious"
	else if(leap_on_click)
		icon_state = "alien[caste]_pounce"

	else if(body_position == LYING_DOWN)
		icon_state = "alien[caste]_sleep"
	else if(m_intent == MOVE_INTENT_RUN)
		icon_state = "alien[caste]_running"
	else
		icon_state = "alien[caste]_s"

	if(leaping)
		if(alt_icon == initial(alt_icon))
			var/old_icon = icon
			icon = alt_icon
			alt_icon = old_icon
		icon_state = "alien[caste]_leap"
	else
		if(alt_icon != initial(alt_icon))
			var/old_icon = icon
			icon = alt_icon
			alt_icon = old_icon

	pixel_x = base_pixel_x + body_position_pixel_x_offset
	pixel_y = base_pixel_y + body_position_pixel_y_offset

	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_pockets()
	update_fire()

	if(blocks_emissive)
		add_overlay(get_emissive_block())


/mob/living/carbon/alien/humanoid/regenerate_icons()
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return
	update_transform()


/mob/living/carbon/alien/humanoid/update_transform() //The old method of updating lying/standing was update_icons(). Aliens still expect that.
	. = ..()
	update_icons()


/mob/living/carbon/alien/humanoid/update_fire()
	remove_overlay(X_FIRE_LAYER)
	if(on_fire)
		overlays_standing[X_FIRE_LAYER] = image('icons/mob/OnFire.dmi', icon_state = "Generic_mob_burning", layer = -X_FIRE_LAYER)
		apply_overlay(X_FIRE_LAYER)


/mob/living/carbon/alien/humanoid/update_inv_pockets()
	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_POCKET_LEFT) + 1]
		inv?.update_appearance()
		inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_POCKET_RIGHT) + 1]
		inv?.update_appearance()

		if(hud_used.hud_shown)
			if(l_store)
				client.screen += l_store
				l_store.screen_loc = ui_alien_storage_l

			if(r_store)
				client.screen += r_store
				r_store.screen_loc = ui_alien_storage_r


/mob/living/carbon/alien/humanoid/update_inv_r_hand()
	..()
	remove_overlay(X_R_HAND_LAYER)
	if(r_hand)
		var/t_state = r_hand.item_state
		if(!t_state)
			t_state = r_hand.icon_state
		overlays_standing[X_R_HAND_LAYER] = mutable_appearance(r_hand.righthand_file, t_state, -X_R_HAND_LAYER)
		apply_overlay(X_R_HAND_LAYER)


/mob/living/carbon/alien/humanoid/update_inv_l_hand()
	..()
	remove_overlay(X_L_HAND_LAYER)
	if(l_hand)
		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state
		overlays_standing[X_L_HAND_LAYER] = mutable_appearance(l_hand.lefthand_file, t_state, -L_HAND_LAYER)
		apply_overlay(X_L_HAND_LAYER)


//Xeno Overlays Indexes//////////
#undef X_HEAD_LAYER
#undef X_SUIT_LAYER
#undef X_L_HAND_LAYER
#undef X_R_HAND_LAYER
#undef X_TARGETED_LAYER
#undef X_FIRE_LAYER
#undef X_TOTAL_LAYERS
