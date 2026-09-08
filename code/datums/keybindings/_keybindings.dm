/datum/keybinding
	/// The user-facing name.
	var/name
	var/full_name
	var/description = ""
	/// The UI category to belong to.
	var/category = KB_CATEGORY_UNSORTED
	/// The default key(s) assigned to the keybind.
	var/list/classic_keys
	var/list/hotkey_keys
	var/weight = WEIGHT_LOWEST
	var/keybind_signal
	///Boolean on whether players are able to edit this keybinding. Used for BYOND built-in binds we wish to
	///tell the player of its existence, but don't want it being edited because BYOND doesn't let us.
	var/can_edit = TRUE

/datum/keybinding/New()
	if(!keybind_signal)
		CRASH("Keybind [src] called unredefined down() without a keybind_signal.")

	// Default keys to the master "hotkey_keys"
	if(LAZYLEN(hotkey_keys) && !LAZYLEN(classic_keys))
		classic_keys = hotkey_keys.Copy()

/**
 * Returns whether the keybinding can be pressed by the client's current mob.
 *
 * Arguments:
 * * user - The client.
 */
/datum/keybinding/proc/can_use(client/user)
	return TRUE

/**
 * Called when the client presses the keybind.
 *
 * Arguments:
 * * user - The client.
 */
/datum/keybinding/proc/down(client/user, turf/target, mousepos_x, mousepos_y)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(user.mob, keybind_signal, target) & COMSIG_KB_ACTIVATED
/**
 * Called when the client releases the keybind.
 *
 * Arguments:
 * * user - The client.
 */
/datum/keybinding/proc/up(client/user, turf/target)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(user.mob, DEACTIVATE_KEYBIND(keybind_signal), target)
	return FALSE

