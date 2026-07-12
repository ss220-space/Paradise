///Deathmatch modifiers are little options the host can choose to spice the match a bit.
/datum/deathmatch_modifier
	/// The name of the modifier
	var/name = "Unnamed Modifier"
	/// A small description/tooltip shown in the UI
	var/description = "What the heck does this do?"
	/// The color of the button shown in the UI
	var/color = "blue"
	/// A lazylist of modifier typepaths this is incompatible with.
	var/list/datum/deathmatch_modifier/blacklisted_modifiers
	/// A lazylist of map typepaths this is incomptable with.
	var/list/datum/lazy_template/deathmatch/blacklisted_maps
	/// Is this trait exempted from the "Random Modifiers" modifier.
	var/random_exempted = FALSE

///Whether or not this modifier can be selected, for both host and player-selected modifiers.
/datum/deathmatch_modifier/proc/selectable(datum/deathmatch_lobby/lobby)
	SHOULD_CALL_PARENT(TRUE)
	if(!random_exempted && (/datum/deathmatch_modifier/random in lobby.modifiers))
		return FALSE
	if(length(lobby.modifiers & blacklisted_modifiers))
		return FALSE
	if (map_incompatible(lobby.map))
		return FALSE
	for(var/modpath in lobby.modifiers)
		if(src in GLOB.deathmatch_game.modifiers[modpath].blacklisted_modifiers)
			return FALSE
	return TRUE

/// Returns TRUE if map.type is in our blacklisted maps, FALSE otherwise.
/datum/deathmatch_modifier/proc/map_incompatible(datum/lazy_template/deathmatch/map)
	if (map?.type in blacklisted_maps)
		return TRUE

	return FALSE

///Called when selecting the deathmatch modifier.
/datum/deathmatch_modifier/proc/on_select(datum/deathmatch_lobby/lobby)
	return

///When the host changes his mind and unselects it.
/datum/deathmatch_modifier/proc/unselect(datum/deathmatch_lobby/lobby)
	return

///Called when the host chooses to change map. Returns FALSE if the new map is incompatible, TRUE otherwise.
/datum/deathmatch_modifier/proc/on_map_changed(datum/deathmatch_lobby/lobby)
	if (map_incompatible(lobby.map))
		lobby.unselect_modifier(src)
		return FALSE
	return TRUE

///Called as the game is about to start.
/datum/deathmatch_modifier/proc/on_start_game(datum/deathmatch_lobby/lobby)
	return

///Called as the game has ended, right before the reservation is deleted.
/datum/deathmatch_modifier/proc/on_end_game(datum/deathmatch_lobby/lobby)
	return

///Apply the modifier to the newly spawned player as the game is about to start
/datum/deathmatch_modifier/proc/apply(mob/living/carbon/player, datum/deathmatch_lobby/lobby)
	return

/datum/deathmatch_modifier/health
	name = "Double-Health"
	description = "Doubles your starting health"
	blacklisted_modifiers = list(/datum/deathmatch_modifier/health/half, /datum/deathmatch_modifier/health/triple)
	var/multiplier = 2

/datum/deathmatch_modifier/health/apply(mob/living/carbon/player, datum/deathmatch_lobby/lobby)
	player.maxHealth *= multiplier
	player.health *= multiplier
