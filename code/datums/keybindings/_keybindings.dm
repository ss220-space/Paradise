/datum/keybinding
	/// The user-facing name.
	var/name
	/// The UI category to belong to.
	var/category = KB_CATEGORY_UNSORTED
	/// The default key(s) assigned to the keybind.
	var/list/keys


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
/datum/keybinding/proc/down(client/user)
	return FALSE


/**
  * Called when the client releases the keybind.
  *
  * Arguments:
  * * user - The client.
  */
/datum/keybinding/proc/up(client/user)
	return FALSE

