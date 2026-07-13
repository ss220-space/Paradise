///Deathmatch modifiers are little options the host can choose to spice the match a bit.
/datum/deathmatch_modifier
	/// The name of the modifier
	var/name = "модификатор"
	/// A small description/tooltip shown in the UI
	var/description = "интересно, что он делает??"
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
	if(blacklisted_modifiers && length(lobby.modifiers & blacklisted_modifiers))
		return FALSE
	if(map_incompatible(lobby.map))
		return FALSE
	for(var/modpath in lobby.modifiers)
		if(src in GLOB.deathmatch_game.modifiers[modpath].blacklisted_modifiers)
			return FALSE
	return TRUE

/// Returns TRUE if map.type is in our blacklisted maps, FALSE otherwise.
/datum/deathmatch_modifier/proc/map_incompatible(datum/lazy_template/deathmatch/map)
	if(map?.type in blacklisted_maps)
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
	if(map_incompatible(lobby.map))
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

/datum/deathmatch_modifier/random
	name = "Random Modifiers"
	description = "Picks 3 to 5 random modifiers as the game is about to start"
	random_exempted = TRUE

/datum/deathmatch_modifier/random/on_select(datum/deathmatch_lobby/lobby)
	///remove any other global modifier if chosen. It'll pick random ones when the time comes.
	for(var/modpath in lobby.modifiers)
		var/datum/deathmatch_modifier/modifier = GLOB.deathmatch_game.modifiers[modpath]
		if(modifier.random_exempted)
			continue
		modifier.unselect(lobby)
		lobby.modifiers -= modpath

/datum/deathmatch_modifier/random/on_start_game(datum/deathmatch_lobby/lobby)
	lobby.modifiers -= type //remove it before attempting to select other modifiers, or they'll fail.

	var/static/list/static_pool
	if(isnull(static_pool))
		static_pool = subtypesof(/datum/deathmatch_modifier)
		for(var/datum/deathmatch_modifier/modpath as anything in static_pool)
			if(initial(modpath.random_exempted))
				static_pool -= modpath
	var/list/modifiers_pool = static_pool.Copy()
	for(var/modpath in modifiers_pool)
		var/datum/deathmatch_modifier/modifier = GLOB.deathmatch_game.modifiers[modpath]
		if(!modifier.selectable(lobby))
			modifiers_pool -= modpath

	///Pick global modifiers at random.
	for(var/iteration in 1 to rand(3, 5))
		var/datum/deathmatch_modifier/modifier = GLOB.deathmatch_game.modifiers[pick_n_take(modifiers_pool)]
		modifier.on_select(lobby)
		modifier.on_start_game(lobby)
		lobby.modifiers += modifier.type
		modifiers_pool -= modifier.blacklisted_modifiers
		if(!length(modifiers_pool))
			return

/datum/deathmatch_modifier/health
	name = "Double-Health"
	description = "Doubles your starting health"
	//blacklisted_modifiers = list(/datum/deathmatch_modifier/health/half, /datum/deathmatch_modifier/health/triple)
	var/multiplier = 2

/datum/deathmatch_modifier/health/apply(mob/living/carbon/player, datum/deathmatch_lobby/lobby)
	player.maxHealth *= multiplier
	player.health *= multiplier
