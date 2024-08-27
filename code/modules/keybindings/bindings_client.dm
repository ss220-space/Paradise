// Clients aren't datums so we have to define these procs indpendently.
// These verbs are called for all key press and release events
/client/verb/KeyDown(_key as text)
	set instant = TRUE
	set hidden = TRUE

	client_keysend_amount += 1

	var/cache = client_keysend_amount

	if(keysend_tripped && next_keysend_trip_reset <= world.time)
		keysend_tripped = FALSE

	if(next_keysend_reset <= world.time)
		client_keysend_amount = 0
		next_keysend_reset = world.time + (1 SECONDS)

	//The "tripped" system is to confirm that flooding is still happening after one spike
	//not entirely sure how byond commands interact in relation to lag
	//don't want to kick people if a lag spike results in a huge flood of commands being sent
	if(cache >= MAX_KEYPRESS_AUTOKICK)
		if(!keysend_tripped)
			keysend_tripped = TRUE
			next_keysend_trip_reset = world.time + (2 SECONDS)
		else
			to_chat(src, span_userdanger("Flooding keysends! This could have been caused by lag, or due to a plugged-in game controller. You have been disconnected from the server automatically."))
			log_and_message_admins("was just autokicked for flooding keysends; likely abuse but potentially lagspike, or a controller plugged into their PC.")
			qdel(src)
			return

	///Check if the key is short enough to even be a real key
	if(LAZYLEN(_key) > MAX_KEYPRESS_COMMANDLENGTH)
		to_chat(src, span_userdanger("Invalid KeyDown detected! You have been disconnected from the server automatically."))
		log_and_message_admins("just attempted to send an invalid keypress. Keymessage was over [MAX_KEYPRESS_COMMANDLENGTH] characters, autokicking due to likely abuse.")
		qdel(src)
		return

	if(length(keys_held) >= HELD_KEY_BUFFER_LENGTH && !keys_held[_key])
		KeyUp(keys_held[1]) //We are going over the number of possible held keys, so let's remove the first one.

	//the time a key was pressed isn't actually used anywhere (as of 2019-9-10) but this allows easier access usage/checking
	keys_held[_key] = world.time
	var/movement = movement_keys[_key]
	if(movement)
		calculate_move_dir()
		if(!movement_locked && !(next_move_dir_sub & movement))
			next_move_dir_add |= movement

	// Client-level keybindings are ones anyone should be able to do at any time
	// Things like taking screenshots, hitting tab, and adminhelps.
	var/AltMod = keys_held["Alt"] ? "Alt" : ""
	var/CtrlMod = keys_held["Ctrl"] ? "Ctrl" : ""
	var/ShiftMod = keys_held["Shift"] ? "Shift" : ""
	var/full_key
	switch(_key)
		if("Alt", "Ctrl", "Shift")
			full_key = "[AltMod][CtrlMod][ShiftMod]"
		else
			if(AltMod || CtrlMod || ShiftMod)
				full_key = "[AltMod][CtrlMod][ShiftMod][_key]"
				key_combos_held[_key] = full_key
			else
				full_key = _key

	var/keycount = 0
	for(var/datum/keybinding/keybinding as anything in active_keybindings[full_key])
		keycount++
		if(keybinding.can_use(src) && keybinding.down(src) && keycount >= MAX_COMMANDS_PER_KEY)
			break

	mob.focus?.key_down(_key, src, full_key)


/client/verb/KeyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	var/key_combo = key_combos_held[_key]
	if(key_combo)
		key_combos_held -= _key
		KeyUp(key_combo)

	if(!keys_held[_key])
		return

	keys_held -= _key

	var/movement = movement_keys[_key]
	if(movement)
		calculate_move_dir()
		if(!movement_locked && !(next_move_dir_add & movement))
			next_move_dir_sub |= movement

	// We don't do full key for release, because for mod keys you
	// can hold different keys and releasing any should be handled by the key binding specifically
	for(var/datum/keybinding/keybinding as anything in active_keybindings[_key])
		if(keybinding.can_use(src) && keybinding.up(src))
			break

	mob.focus?.key_up(_key, src)

