/**
 * Returns whether or not a player is a guest using their ckey as an input
 *
 * Arguments:
 * * player_key - The player's ckey to check
 */
/proc/is_guest_key(player_key)
	if(findtext(player_key, "Guest-", 1, 7) != 1) //was findtextEx
		return FALSE

	var/current_position
	var/current_character
	var/key_length = length(player_key)

	for(current_position = 7, current_position <= key_length, ++current_position) //we know the first 6 chars are Guest-
		current_character = text2ascii(player_key, current_position)
		if(current_character < 48 || current_character > 57) //0-9
			return FALSE
	return TRUE

/**
 * Finds a mob by their ckey in the active and left player lists
 *
 * Arguments:
 * * player_key - The ckey to search for
 */
/proc/get_mob_by_ckey(player_key)
	if(!player_key)
		return

	for(var/mob/mob_instance as anything in GLOB.player_list)
		if(mob_instance.ckey != player_key)
			continue

		return mob_instance

	for(var/mob/mob_instance as anything in GLOB.left_player_list)
		if(mob_instance.ckey != player_key)
			continue

		return mob_instance

/**
 * Finds a client by their ckey, handling stealth keys
 *
 * Arguments:
 * * player_ckey - The ckey to search for
 */
/proc/get_client_by_ckey(player_ckey)
	if(cmptext(copytext(player_ckey, 1, 2),"@"))
		player_ckey = find_stealth_key(player_ckey)
	return GLOB.directory[player_ckey]

/**
 * Resolves a stealth key to its original ckey
 *
 * Arguments:
 * * stealth_text - The stealth key to resolve
 */
/proc/find_stealth_key(stealth_text)
	if(stealth_text)
		for(var/stealth_key in GLOB.stealthminID)
			if(GLOB.stealthminID[stealth_key] == stealth_text)
				return stealth_key
