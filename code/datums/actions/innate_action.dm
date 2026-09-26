//Preset for general and toggled actions
/datum/action/innate
	/// Whether we're active or not, if we're a innate - toggle action.
	var/active = FALSE
	/// Whether we're a click action or not, if we're a innate - click action.
	var/click_action = FALSE
	/// If we're a click action, the mouse pointer we use
	var/ranged_mousepointer
	/// If we're a click action, the text shown on enable
	var/enable_text
	/// If we're a click action, the text shown on disable
	var/disable_text

/datum/action/innate/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return FALSE
	// We're a click action, trigger just sets it as active or not
	if(click_action)
		if(owner.click_intercept == src)
			unset_ranged_ability(owner, disable_text)
		else
			set_ranged_ability(owner, enable_text)
		build_all_button_icons(UPDATE_BUTTON_STATUS)
		return TRUE

	// We're not a click action (we're a toggle or otherwise)
	else
		var/active_status = active
		if(active_status)
			Deactivate()
		else
			Activate()

		if(active != active_status)
			build_all_button_icons(UPDATE_BUTTON_STATUS)

	return TRUE

/datum/action/innate/is_action_active(atom/movable/screen/movable/action_button/current_button)
	if(click_action)
		return current_button.our_hud?.mymob?.click_intercept == src
	else
		return active

/datum/action/innate/proc/Activate()
	return

/datum/action/innate/proc/Deactivate()
	return

/**
 * This is gross, but a somewhat-required bit of copy+paste until action code becomes slightly more sane.
 * Anything that uses these functions should eventually be moved to use cooldown actions.
 * (Either that, or the click ability of cooldown actions should be moved down a type.)
 *
 * If you're adding something that uses these, rethink your choice in subtypes.
 */

/// Sets this action as the active ability for the passed mob
/datum/action/innate/proc/set_ranged_ability(mob/living/on_who, text_to_show)
	if(ranged_mousepointer)
		on_who.client?.mouse_override_icon = ranged_mousepointer
		on_who.update_mouse_pointer()
	if(text_to_show)
		to_chat(on_who, text_to_show)
	on_who.click_intercept = src

/// Removes this action as the active ability of the passed mob
/datum/action/innate/proc/unset_ranged_ability(mob/living/on_who, text_to_show)
	if(ranged_mousepointer)
		on_who.client?.mouse_override_icon = initial(owner.client?.mouse_pointer_icon)
		on_who.update_mouse_pointer()
	if(text_to_show)
		to_chat(on_who, text_to_show)
	on_who.click_intercept = null

/// Handles whenever a mob clicks on something
/datum/action/innate/proc/InterceptClickOn(mob/living/clicker, params, atom/clicked_on)
	if(!IsAvailable(feedback = TRUE))
		unset_ranged_ability(clicker)
		return FALSE
	if(!clicked_on)
		return FALSE

	return do_ability(clicker, clicked_on)

/// Actually goes through and does the click ability
/datum/action/innate/proc/do_ability(mob/living/clicker, atom/clicked_on)
	return FALSE

/datum/action/innate/Remove(mob/removed_from)
	if(removed_from.click_intercept == src)
		unset_ranged_ability(removed_from)
	return ..()


//MARK: Actions

/datum/action/innate/overdrive
	name = "Овердрайв"
	button_icon_state = "mech_overload_off"
	check_flags = AB_CHECK_CONSCIOUS
	var/used = FALSE

/datum/action/innate/overdrive/Activate()
	var/mob/living/silicon/robot/robot = owner
	if(used)
		return

	if(!do_after(robot, 10 SECONDS) || robot.stat)
		return

	robot.rejuvenate()
	robot.opened = FALSE
	robot.locked = TRUE
	robot.SetEmagged(TRUE)
	robot.SetLockdown(FALSE)
	robot.UnlinkSelf()
	used = TRUE
	Remove(robot)

// /datum/action/innate/overdrive/ApplyIcon()
	// button.cut_overlays()
	// var/static/mutable_appearance/new_icon = mutable_appearance('icons/mob/actions/actions.dmi', "heal", BUTTON_LAYER_ICON, appearance_flags = RESET_COLOR|RESET_ALPHA)
	// button.add_overlay(new_icon)


/datum/action/innate/research_scanner
	name = "Переключить исследовательский анализатор"
	button_icon_state = "scan_mode"

/datum/action/innate/research_scanner/Activate()
	owner.research_scanner = !owner.research_scanner
	to_chat(owner, span_notice("Вы [owner.research_scanner ? "включили" : "отключили"] исследовательский анализатор."))

	return TRUE

/datum/action/innate/research_scanner/Remove(mob/living/L)
	if(owner)
		owner.research_scanner = 0

	. = ..()

// /datum/action/innate/research_scanner/ApplyIcon()
// 	button.cut_overlays()
// 	var/static/mutable_appearance/new_icon = mutable_appearance('icons/mob/actions/actions.dmi', "scan_mode", BUTTON_LAYER_ICON, appearance_flags = RESET_COLOR|RESET_ALPHA)
// 	button.add_overlay(new_icon)

