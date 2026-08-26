#define MANUAL_PICK_MESSAGE(X) "Выберите игроков для спавна. Это будет продолжаться до тех пор, пока не останется призраков для выбора или пока [X] оставшихся слотов не будут заполнены."
#define VETO_PICK_MESSAGE(X) "Выберите игроков. Это будет продолжаться до тех пор, пока не останется согласившихся призраков для выбора или пока [X] оставшихся слотов не будут заполнены."
#define MANUAL_PICK_TITLE "Активные игроки"
#define VETO_PICK_TITLE "Кандидаты"

/**
 * Returns the name of the area the atom is in, with optional formatting
 *
 * Arguments:
 * * target_atom - The atom to get the area name for
 * * apply_formatting - Whether to apply text formatting to the area name
 */
/proc/get_area_name(atom/target_atom, apply_formatting = FALSE)
	var/area/target_area = isarea(target_atom) ? target_atom : get_area(target_atom)
	if(!target_area)
		return null
	return apply_formatting ? format_text(target_area.name) : target_area.name

/**
 * Returns the name of the area the atom is in, with optional formatting
 *
 * Arguments:
 * * target_atom - The atom to get the area name for
 * * apply_formatting - Whether to apply text formatting to the area name
 */
/proc/get_location_name(atom/target_atom, apply_formatting = FALSE)
	var/area/target_area = isarea(target_atom) ? target_atom : get_area(target_atom)
	if(!target_area)
		return null
	return apply_formatting ? format_text(target_area.name) : target_area.name

/**
 * Checks if there is a clear line of sight between two atoms using field of view algorithm
 *
 * Arguments:
 * * source_atom - The starting atom for line of sight check
 * * target_atom - The target atom to check visibility to
 */
/proc/ff_cansee(atom/source_atom, atom/target_atom)
	var/turf/source_turf = get_turf(source_atom)
	var/turf/target_turf = get_turf(target_atom)
	if(source_turf == target_turf)
		return TRUE
	for(var/turf/current_turf as anything in get_line(source_atom, target_atom))
		if(current_turf == source_turf || current_turf == target_turf)
			break
		if(current_turf.density)
			return FALSE
	return TRUE

/// Will recursively loop through an atom's contents and check for mobs, then it will loop through every atom in that atom's contents.
/// It will keep doing this until it checks every content possible. This will fix any problems with mobs, that are inside objects,
/// being unable to hear people due to being in a box within a bag.
/proc/recursive_mob_check(atom/check, list/output = list(), recursion_limit = 3, include_clientless = FALSE, include_radio = TRUE, sight_check = TRUE)
	if(!recursion_limit)
		return output

	for(var/thing in check.contents)
		var/is_mob = ismob(thing)
		if(is_mob)
			var/mob/mob = thing
			if(isnull(mob.client) && !include_clientless)
				output |= recursive_mob_check(mob, output, recursion_limit - 1, include_clientless, include_radio, sight_check)
				continue
			if(sight_check && !is_in_sight(mob, check))
				continue
			output |= mob

		else if(include_radio && isradio(thing))
			if(sight_check && !is_in_sight(thing, check))
				continue
			output |= thing

		if(is_mob || isobj(thing))
			output |= recursive_mob_check(thing, output, recursion_limit - 1, include_clientless, include_radio, sight_check)

	return output

/// The old system would loop through lists for a total of 5000 per function call, in an empty server.
/// This new system will loop at around 1000 in an empty server.
/// Returns a list of mobs in range from source. Used in radio and say code.
/proc/get_mobs_in_view(range, atom/source, include_clientless = FALSE, include_radio = TRUE)
	var/turf/source_turf = get_turf(source)
	. = list()

	if(!source_turf)
		return .

	for(var/thing in get_hear(range, source_turf))
		var/is_mob = ismob(thing)
		if(is_mob)
			var/mob/mob = thing
			if(include_clientless || !isnull(mob.client))
				. += mob
		else if(include_radio && isradio(thing))
			. += thing

		if(is_mob || isobj(thing))
			. |= recursive_mob_check(thing, ., 3, include_clientless, include_radio, FALSE)

/**
 * Attempts to move a movable atom to an adjacent tile in a random cardinal direction
 *
 * Arguments:
 * * movable_atom - The movable atom to relocate
 */
/proc/try_move_adjacent(atom/movable/movable_atom)
	var/turf/current_turf = get_turf(movable_atom)
	for(var/direction in GLOB.cardinal)
		if(movable_atom.Move(get_step(current_turf, direction)))
			break

/**
 * Finds a mob by their ckey (case-insensitive)
 *
 * Arguments:
 * * player_key - The ckey to search for
 */
/proc/get_mob_by_key(player_key)
	for(var/mob/mob_instance in GLOB.mob_list)
		if(mob_instance.ckey == lowertext(player_key))
			return mob_instance
	return null

/// Return an object with a new maptext (not currently in use)
/proc/screen_text(atom/movable/object_to_change, maptext = "", screen_loc = "CENTER-7,CENTER-7", maptext_height = 480, maptext_width = 480)
	if(!istype(object_to_change))
		object_to_change = new /atom/movable/screen/text()
	object_to_change.maptext = MAPTEXT(maptext)
	object_to_change.maptext_height = maptext_height
	object_to_change.maptext_width = maptext_width
	object_to_change.screen_loc = screen_loc
	return object_to_change

/// Adds an image to a client's `.images`. Useful as a callback.
/proc/add_image_to_client(image/image_to_remove, client/add_to)
	add_to?.images += image_to_remove

/// Like add_image_to_client, but will add the image from a list of clients
/proc/add_image_to_clients(image/image_to_remove, list/show_to)
	for(var/client/add_to in show_to)
		add_to.images += image_to_remove

/// Removes an image from a client's `.images`. Useful as a callback.
/proc/remove_image_from_client(image/image_to_remove, client/remove_from)
	remove_from?.images -= image_to_remove

/// Like remove_image_from_client, but will remove the image from a list of clients
/proc/remove_image_from_clients(image/image_to_remove, list/hide_from)
	for(var/client/remove_from in hide_from)
		remove_from.images -= image_to_remove

/// Add an image to a list of clients and calls a proc to remove it after a duration
/proc/flick_overlay(image/image_to_show, list/show_to, duration)
	if(!show_to || !length(show_to) || !image_to_show)
		return
	for(var/client/add_to in show_to)
		add_to.images += image_to_show
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_image_from_clients), image_to_show, show_to), duration, TIMER_CLIENT_TIME)

/**
 * Helper atom that copies an appearance and exists for a period
*/
/atom/movable/flick_visual

/atom/proc/on_flick_qdeleted(atom/movable/flick_visual/source)
	SIGNAL_HANDLER
	if(!istype(source))
		return
	var/atom/movable/lies_to_children = src
	lies_to_children.vis_contents -= source
	UnregisterSignal(source, COMSIG_QDELETING)

/atom/proc/register_flick_visual(atom/movable/flick_visual/visual)
	if(!istype(visual))
		return
	var/atom/movable/lies_to_children = src
	lies_to_children.vis_contents += visual
	RegisterSignal(visual, COMSIG_QDELETING, PROC_REF(on_flick_qdeleted))

/// Takes the passed in MA/icon_state, mirrors it onto ourselves, and displays that in world for duration seconds
/// Returns the displayed object, you can animate it and all, but you don't own it, we'll delete it after the duration
/atom/proc/flick_overlay_view(mutable_appearance/display, duration)
	if(!display)
		return null

	var/mutable_appearance/passed_appearance = \
		istext(display) \
			? mutable_appearance(icon, display, layer) \
			: display

	// If you don't give it a layer, we assume you want it to layer on top of this atom
	// Because this is vis_contents, we need to set the layer manually (you can just set it as you want on return if this is a problem)
	if(passed_appearance.layer == FLOAT_LAYER)
		passed_appearance.layer = layer + 0.1
	// This is faster then pooling. I promise
	var/atom/movable/flick_visual/visual = new()
	visual.appearance = passed_appearance
	// I hate /area
	register_flick_visual(visual)
	QDEL_IN_CLIENT_TIME(visual, duration)
	return visual

/area/flick_overlay_view(mutable_appearance/display, duration)
	return

/datum/projectile_data
	var/src_x
	var/src_y
	var/time
	var/distance
	var/power_x
	var/power_y
	var/dest_x
	var/dest_y

/datum/projectile_data/New(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)
	src.src_x = src_x
	src.src_y = src_y
	src.time = time
	src.distance = distance
	src.power_x = power_x
	src.power_y = power_y
	src.dest_x = dest_x
	src.dest_y = dest_y

// telesci
/proc/projectile_trajectory(src_x, src_y, rotation, angle, power)

	// returns the destination (Vx,y) that a projectile shot at [src_x], [src_y], with an angle of [angle],
	// rotated at [rotation] and with the power of [power]
	// Thanks to VistaPOWA for this function

	var/power_x = power * cos(angle)
	var/power_y = power * sin(angle)
	var/time = 2* power_y / 10 //10 = g

	var/distance = time * power_x

	var/dest_x = src_x + distance*sin(rotation);
	var/dest_y = src_y + distance*cos(rotation);

	return new /datum/projectile_data(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)

/**
 * Returns a list of mobs in the specified area, optionally filtering by client presence
 *
 * Arguments:
 * * target_area - The area to search for mobs in
 * * require_client - If TRUE, only include mobs with clients
 * * source_mob_list - The list of mobs to search through (default: GLOB.mob_list)
 */
/proc/mobs_in_area(area/target_area, require_client = FALSE, source_mob_list = GLOB.mob_list)
	var/list/found_mobs = list()
	var/area/target_area_instance = get_area(target_area)
	for(var/mob/current_mob in source_mob_list)
		if(require_client && !current_mob.client)
			continue
		if(target_area_instance != get_area(current_mob))
			continue
		found_mobs += current_mob
	return found_mobs

/**
 * Checks if the pressure at a given turf is low enough for lavaland equipment effects
 *
 * Arguments:
 * * target_turf - The turf to check pressure on
 */
/proc/lavaland_equipment_pressure_check(turf/target_turf)
	. = FALSE
	if(!istype(target_turf))
		return
	var/datum/gas_mixture/environment = target_turf.get_readonly_air()
	if(!istype(environment))
		return
	var/pressure = environment.return_pressure()
	if(pressure <= LAVALAND_EQUIPMENT_EFFECT_PRESSURE)
		. = TRUE

/**
 * Polls candidates with admin veto selection from a list of willing ghosts
 *
 * Arguments:
 * * admin_client - The client of the admin making the selection
 * * max_slots - Maximum number of candidates to select
 * * question - The poll question presented to ghosts
 * * be_special_type - The special role type to check for
 * * antag_age_check - Whether to check antag age restrictions
 * * poll_time - Duration of the poll in seconds
 * * ignore_respawnability - Whether to ignore respawnability checks
 * * min_hours - Minimum hours required to participate
 * * flashwindow - Whether to flash the window for candidates
 * * check_antaghud - Whether to check antag HUD visibility
 * * source - The source of the poll
 * * role_cleanname - Clean name of the role for display
 * * reason - Reason for the poll
 */
/proc/poll_candidates_with_veto(client/admin_client, max_slots, question, be_special_type, antag_age_check = FALSE, poll_time = 300, ignore_respawnability = FALSE, min_hours = FALSE, flashwindow = TRUE, check_antaghud = TRUE, source, role_cleanname, reason)
	var/list/willing_ghosts = SSghost_spawns.poll_candidates(question, be_special_type, antag_age_check, poll_time, ignore_respawnability, min_hours, flashwindow, check_antaghud, source, role_cleanname, reason)
	var/list/selected_candidates = list()
	if(!length(willing_ghosts))
		return selected_candidates

	var/list/available_candidates = willing_ghosts.Copy()

	to_chat(admin_client, "Candidate Ghosts:")
	for(var/mob/dead/observer/ghost in available_candidates)
		if(ghost.key && ghost.client)
			to_chat(admin_client, "- [ghost] ([ghost.key])")
		else
			available_candidates -= ghost
	for(var/slot_count = max_slots, (slot_count > 0 && length(available_candidates)), slot_count--)
		var/selected_ghost = tgui_input_list(admin_client, VETO_PICK_MESSAGE(slot_count), VETO_PICK_TITLE, available_candidates)
		if(!selected_ghost)
			continue
		available_candidates -= selected_ghost
		selected_candidates += selected_ghost
	return selected_candidates

/**
 * Manually picks candidates from all available ghosts without a poll
 *
 * Arguments:
 * * admin_client - The client of the admin making the selection
 * * team_size - Number of team members to select
 */
/proc/pick_candidates_manually(client/admin_client, team_size)
	var/list/available_ghosts = list()
	var/list/selected_players = list()
	for(var/mob/dead/observer/ghost in GLOB.player_list)
		if(!ghost.client.is_afk())
			if(!(ghost.mind && ghost.mind.current && ghost.mind.current.stat != DEAD))
				available_ghosts += ghost
	for(var/selection_count = team_size, (selection_count > 0 && length(available_ghosts)), selection_count--)
		var/selected_candidate = tgui_input_list(admin_client, MANUAL_PICK_MESSAGE(selection_count), MANUAL_PICK_TITLE, available_ghosts)
		if(selected_candidate == null)
			break
		available_ghosts -= selected_candidate
		selected_players += selected_candidate
	return selected_players

/**
 * Presents admin with choice of candidate selection methods
 *
 * Arguments:
 * * admin_client - The client of the admin making the selection
 * * max_slots - Maximum number of candidates to select
 * * question - The poll question presented to ghosts
 * * be_special_type - The special role type to check for
 * * antag_age_check - Whether to check antag age restrictions
 * * poll_time - Duration of the poll in seconds
 * * ignore_respawnability - Whether to ignore respawnability checks
 * * min_hours - Minimum hours required to participate
 * * flashwindow - Whether to flash the window for candidates
 * * check_antaghud - Whether to check antag HUD visibility
 * * source - The source of the poll
 * * role_cleanname - Clean name of the role for display
 * * reason - Reason for the poll
 */
/proc/pick_candidates_all_types(client/admin_client, max_slots, question, be_special_type, antag_age_check = FALSE, poll_time = 300, ignore_respawnability = FALSE, min_hours = FALSE, flashwindow = TRUE, check_antaghud = TRUE, source, role_cleanname, reason)
	var/selection_method = tgui_alert(admin_client, "Как вы хотите выбрать членов команды? \n \
		Случайно — призраки получат предложение занять роль. \
		После его окончания, среди них будет рандомно выбрано [max_slots] кандидатов \n \
		С вето — призраки получат предложение занять роль.\
		После его окончания, вам необходимо среди них выбрать [max_slots] кандидатов \n \
		Вручную — Вам необходимо выбрать [max_slots] кандидатов среди всех призраков. \
		(не рекомендуется, вы можете выбрать игрока на роль против его воли).",
		"Выберите способ.", list("Случайно", "С вето", "Вручную")
	)
	switch(selection_method)
		if("Случайно")
			return SSghost_spawns.poll_candidates(question, be_special_type, antag_age_check, poll_time, ignore_respawnability, min_hours, flashwindow, check_antaghud, source, role_cleanname, reason)
		if("С вето")
			return poll_candidates_with_veto(admin_client, max_slots, question, be_special_type, antag_age_check, poll_time, ignore_respawnability, min_hours, flashwindow, check_antaghud, source, role_cleanname, reason)
		if("Вручную")
			return pick_candidates_manually(admin_client, max_slots)
	return list()

/// Sends a whatever to all playing players; use instead of to_chat(world, where needed)
/proc/send_to_playing_players(thing)
	for(var/player_mob in GLOB.player_list)
		if(player_mob && !isnewplayer(player_mob))
			to_chat(player_mob, thing)

/// Flash the window of a player
/proc/window_flash(client/flashed_client)
	if(ismob(flashed_client))
		var/mob/player_mob = flashed_client
		if(player_mob.client)
			flashed_client = player_mob.client
	if(!flashed_client || !(flashed_client.prefs.toggles2 & PREFTOGGLE_2_WINDOWFLASHING))
		return
	winset(flashed_client, "mainwindow", "flash=5")

/**
 * Returns a list of vents that can be used as a potential spawn if they meet the criteria set by the arguments
 *
 * Will not include parent-less vents to the returned list.
 * Arguments:
 * * unwelded_only - Whether the list should only include vents that are unwelded
 * * exclude_mobs_nearby - Whether to exclude vents that are near living mobs regardless of visibility
 * * nearby_mobs_range - The range at which to look for living mobs around the vent for the above argument
 * * exclude_visible_by_mobs - Whether to exclude vents that are visible to any living mob
 * * min_network_size - The minimum length (non-inclusive) of the vent's parent network. A smaller number means vents in small networks (Security, Virology) will appear in the list
 * * station_levels_only - Whether to only consider vents that are in a Z-level with a STATION_LEVEL trait
 * * z_level - The Z-level number to look for vents in. Defaults to all
 */
/proc/get_valid_vent_spawns(unwelded_only = TRUE, exclude_mobs_nearby = FALSE, nearby_mobs_range = world.view, exclude_visible_by_mobs = FALSE, min_network_size = 50, station_levels_only = TRUE, z_level = 0)
	ASSERT(min_network_size >= 0)
	ASSERT(z_level >= 0)

	var/num_z_levels = length(GLOB.space_manager.z_list)
	var/list/non_station_levels[num_z_levels] // Cache so we don't do is_station_level for every vent!

	. = list()
	for(var/object in GLOB.all_vent_pumps) // This only contains vent_pumps so don't bother with type checking
		var/obj/machinery/atmospherics/unary/vent_pump/vent = object
		var/vent_z = vent.z
		if(z_level && vent_z != z_level)
			continue
		if(station_levels_only && (non_station_levels[vent_z] || !is_station_level(vent_z)))
			non_station_levels[vent_z] = TRUE
			continue
		if(unwelded_only && vent.welded)
			continue
		if(exclude_mobs_nearby)
			var/turf/T = get_turf(vent)
			var/mobs_nearby = FALSE
			for(var/mob/living/M in orange(nearby_mobs_range, T))
				if(!M.is_dead())
					mobs_nearby = TRUE
					break
			if(mobs_nearby)
				continue
		if(exclude_visible_by_mobs)
			var/turf/T = get_turf(vent)
			var/visible_by_mobs = FALSE
			for(var/mob/living/M in viewers(world.view, T))
				if(!M.is_dead())
					visible_by_mobs = TRUE
					break
			if(visible_by_mobs)
				continue
		if(!vent.parent) // This seems to have been an issue in the past, so this is here until it's definitely fixed
			// Can cause heavy message spam in some situations (e.g. pipenets breaking)
			// log_debug("get_valid_vent_spawns(), vent has no parent: [vent], qdeled: [QDELETED(vent)], loc: [vent.loc]")
			continue
		if(length(vent.parent.other_atmosmch) <= min_network_size)
			continue
		. += vent

/**
 * Recursively checks if an item is inside a given type/atom, even through layers of storage.
 * Returns the atom if it finds it.
 *
 * Arguments
 * * atom/movable/target - the atom whos loc we are checking for
 * * type - the location(typepath or solid atom) the target maybe stored in
 */
/proc/recursive_loc_check(atom/movable/target, type)
	var/atom/atom_to_find = null

	if(ispath(type))
		atom_to_find = target
		if(istype(atom_to_find, type))
			return atom_to_find

		while(!istype(atom_to_find, type))
			if(!atom_to_find.loc)
				return
			atom_to_find = atom_to_find.loc
	else if(isatom(type))
		atom_to_find = target
		if(atom_to_find == type)
			return atom_to_find

		while(atom_to_find != type)
			if(!atom_to_find.loc)
				return
			atom_to_find = atom_to_find.loc

	return atom_to_find
