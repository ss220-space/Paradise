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

	update_inv_hands()
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
	remove_overlay(FIRE_LAYER)
	if(on_fire)
		if(!overlays_standing[FIRE_LAYER])
			overlays_standing[FIRE_LAYER] = mutable_appearance('icons/mob/OnFire.dmi', icon_state = "Generic_mob_burning", layer = -FIRE_LAYER)
	apply_overlay(FIRE_LAYER)


/mob/living/carbon/alien/humanoid/update_inv_pockets()
	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_POCKET_LEFT) + 1]
		inv?.update_icon()
		inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_POCKET_RIGHT) + 1]
		inv?.update_icon()

	if(l_store)
		update_item_on_hud(l_store, ui_alien_storage_l)

	if(r_store)
		update_item_on_hud(r_store, ui_alien_storage_r)

