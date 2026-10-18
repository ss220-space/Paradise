/mob/living/carbon/alien/humanoid/update_icons()
	cut_overlays()

	if(stat == DEAD)
		//If we mostly took damage from fire. Castes with their own icon file have no separate husked state.
		if(getFireLoss() > 125 && !caste_icon_prefix)
			icon_state = "alien[caste]_husked"
		else
			icon_state = get_caste_icon_state("dead")

	else if((stat == UNCONSCIOUS && !IsSleeping()) || IsWeakened() || IsParalyzed())
		icon_state = get_caste_icon_state("knockdown")
	else if(body_position == LYING_DOWN)
		icon_state = get_caste_icon_state("sleep")
	else if(m_intent == MOVE_INTENT_RUN)
		icon_state = get_caste_icon_state("run")
	else
		icon_state = get_caste_icon_state("walk")

	update_held_items()
	update_pockets()
	update_fire()
	update_wounds()

/**
 * Returns the icon_state for the given pose ("walk", "run", "sleep", "knockdown", "dead").
 *
 * Castes with their own icon file (see [var/caste_icon_prefix]) use "[prefix]_[pose]",
 * legacy castes keep the historical "alien[caste]_[suffix]" naming from 'icons/mob/alien.dmi'.
 */
/mob/living/carbon/alien/humanoid/proc/get_caste_icon_state(pose)
	var/static/list/legacy_pose_suffixes = list(
		"walk" = "s",
		"run" = "running",
		"sleep" = "sleep",
		"knockdown" = "unconscious",
		"dead" = "dead",
	)
	if(caste_icon_prefix)
		return "[caste_icon_prefix]_[pose]"
	return "alien[caste]_[legacy_pose_suffixes[pose]]"

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
		var/fire_icon = 'icons/mob/OnFire.dmi'
		var/fire_icon_state = "[is_monkeybasic(src) ? "monkey" : "human"]_generic_burn"
		if(caste_icon_prefix)
			// Castes with their own icon file carry their own fire overlays
			fire_icon = icon
			fire_icon_state = body_position == LYING_DOWN ? "alien_fire_lying" : "alien_fire"
		if(!overlays_standing[FIRE_LAYER])
			overlays_standing[FIRE_LAYER] = mutable_appearance(fire_icon, icon_state = fire_icon_state, layer = -FIRE_LAYER)
	apply_overlay(FIRE_LAYER)

#define WOUND_OVERLAY_NONE 0

/// Returns the wound overlay tier for the current health: 1 (light) to 3 (heavy), or WOUND_OVERLAY_NONE.
/mob/living/carbon/alien/humanoid/proc/get_wound_tier()
	if(health > maxHealth * 0.66)
		return WOUND_OVERLAY_NONE
	if(health > maxHealth * 0.33)
		return 1
	if(health > 0)
		return 2
	return 3

/// Returns the pose suffix of the wound overlay state for the current stance.
/mob/living/carbon/alien/humanoid/proc/get_wound_pose_suffix()
	if((stat == UNCONSCIOUS && !IsSleeping()) || IsWeakened() || IsParalyzed())
		return "stunned"
	if(body_position == LYING_DOWN)
		return IsSleeping() ? "sleeping" : "resting"
	return null

/**
 * Updates the damage overlay based on the current health tier.
 */
/mob/living/carbon/alien/humanoid/proc/update_wounds()
	remove_overlay(H_DAMAGE_LAYER)
	if(caste_icon_prefix)
		var/wound_tier = get_wound_tier()
		if(wound_tier)
			var/wound_pose = get_wound_pose_suffix()
			var/wound_state = wound_pose ? "alien_wounded_[wound_pose]_[wound_tier]" : "alien_wounded_[wound_tier]"
			var/mutable_appearance/wound_overlay = mutable_appearance(icon, icon_state = wound_state, layer = -H_DAMAGE_LAYER)
			overlays_standing[H_DAMAGE_LAYER] = wound_overlay
	apply_overlay(H_DAMAGE_LAYER)

/mob/living/carbon/alien/humanoid/set_health(new_value)
	. = ..()
	if(. != health)
		update_wounds()

#undef WOUND_OVERLAY_NONE

/mob/living/carbon/alien/humanoid/update_pockets()
	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_POCKET_LEFT) + 1]
		inv?.update_icon()
		inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_POCKET_RIGHT) + 1]
		inv?.update_icon()

	if(l_store)
		update_item_on_hud(l_store, ui_alien_storage_l)

	if(r_store)
		update_item_on_hud(r_store, ui_alien_storage_r)

