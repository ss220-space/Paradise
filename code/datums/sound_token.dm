/**
 * Sound tokens, a datumized handler for spatial sound.
 * Uses the spatial grid to track clients in range and add them as listeners
 * Updated by the SSsound_tokens subsystem every tick when requested by client so that if the source or listener moves, the sound updates accordingly.
 */
/datum/sound_token
	/// The atom playing the sound.
	VAR_PRIVATE/atom/source
	/// k:v list of mob : sound status
	VAR_PRIVATE/list/listeners = list()
	///k:v list of mobs : bool. Used to quickly check whether a mob is allowed to hear this noise. This is null by default which means ANY MOB can hear this.
	VAR_PRIVATE/list/allowed_listeners

	/// Sound maximum range
	VAR_PRIVATE/range
	/// Sound volume
	VAR_PRIVATE/volume
	/// Sound falloff
	VAR_PRIVATE/falloff_exponent
	/// Sound falloff distance
	VAR_PRIVATE/falloff_distance
	/// Frequency (playback speed) applied to the sound. Null keeps the default speed.
	VAR_PRIVATE/frequency

	/// The master copy of the playing sound.
	VAR_PRIVATE/sound/sound
	/// Null sound for cancelling the sound entirely.
	VAR_PRIVATE/sound/null_sound

	/// Status of the playing sound
	VAR_PRIVATE/sound_status = NONE
	/// The channel being used.
	VAR_PRIVATE/sound_channel
	/// world.time when the sound started (or when the sound file was last changed). Used to calculate playback offset for new listeners.
	VAR_PRIVATE/start_time
	/// Duration of the current sound file in deciseconds. Used to wrap offset for looping sounds.
	VAR_PRIVATE/sound_duration
	/// Duration of the current sound file in deciseconds. Used to wrap offset for looping sounds.
	VAR_PRIVATE/sound_duration_override
	/// Cell tracker managing spatial grid cells within range of the source. The wizards say this is the fastest.
	VAR_PRIVATE/datum/cell_tracker/cell_tracker
	///Should we destroy the datum when the sound is done?
	VAR_PRIVATE/delete_on_end = FALSE

/datum/sound_token/New(
	atom/source,
	sound,
	range = 10,
	volume = 50,
	falloff_exponent = SOUND_FALLOFF_EXPONENT,
	falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE,
	allowed_listeners,
	sound_duration_override,
	delete_on_end,
	frequency,
)
	src.source = source
	RegisterSignal(source, COMSIG_QDELETING, PROC_REF(source_deleted))
	RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(source_moved))
	RegisterSignal(source, COMSIG_ENTER_AREA, PROC_REF(on_enter_area))

	src.range = range
	src.volume = volume
	src.falloff_exponent = falloff_exponent
	src.falloff_distance = falloff_distance
	src.frequency = frequency
	src.sound_duration_override = sound_duration_override

	if(delete_on_end)
		src.delete_on_end = delete_on_end

	if(allowed_listeners)
		for(var/allowed_mob in allowed_listeners)
			src.allowed_listeners[allowed_mob] = TRUE

	update_sound(sound)

	null_sound = sound(channel = sound_channel)

	cell_tracker = new /datum/cell_tracker(range, range)
	update_tracked_cells()

	RegisterSignal(SSdcs, COMSIG_GLOB_PLAYER_LOGIN, PROC_REF(player_login))
	RegisterSignal(SSdcs, COMSIG_GLOB_PLAYER_LOGOUT, PROC_REF(player_logout))

/datum/sound_token/Destroy(force)
	for(var/listener in listeners)
		remove_listener(listener)

	listeners = null
	source = null
	cell_tracker = null
	return ..()

/// Lets us update the sound to a new one.
/datum/sound_token/proc/update_sound(sound, start_playing = FALSE)
	src.sound = sound(sound)
	if(frequency)
		src.sound.frequency = frequency
	if(!sound_channel)
		sound_channel = SSsounds.reserve_sound_channel_for_datum(src)
	src.sound.channel = sound_channel
	sound_duration = sound_duration_override || SSsounds.get_sound_length(sound)
	start_time = REALTIMEOFDAY
	if(start_playing)
		force_update_all_listeners(FALSE)
	if(delete_on_end)
		addtimer(CALLBACK(src, PROC_REF(on_sound_ended)), sound_duration, TIMER_UNIQUE | TIMER_OVERRIDE)

/// Updates the data of a listener, or adds them if they are not present.
/datum/sound_token/proc/add_or_update_listener(mob/listener_mob)
	PRIVATE_PROC(TRUE)

	if(isnull(listeners[listener_mob]))
		return add_listener(listener_mob)

	update_listener(listener_mob)

/// Adds a listener to the sound. returns TRUE if we already were added, or for some reason couldnt be added.
/datum/sound_token/proc/add_listener(mob/listener_mob)
	PRIVATE_PROC(TRUE)

	if(!isnull(listeners[listener_mob]))
		return TRUE

	if(!listener_mob.client || isnewplayer(listener_mob))
		return FALSE

	if(allowed_listeners && !allowed_listeners[listener_mob])
		return FALSE

	listeners[listener_mob] = NONE
	listener_mob.client.sound_tokens += src
	// The source already holds source_deleted on COMSIG_QDELETING (which qdels the whole token), so don't clobber it when the source hears its own sound.
	if(listener_mob != source)
		RegisterSignal(listener_mob, COMSIG_QDELETING, PROC_REF(listener_deleted))
	RegisterSignals(listener_mob, list(SIGNAL_ADDTRAIT(TRAIT_DEAF), SIGNAL_REMOVETRAIT(TRAIT_DEAF)), PROC_REF(listener_deafness_update))
	update_listener(listener_mob, FALSE)
	return TRUE

/// Remove a listener from the sound.
/datum/sound_token/proc/remove_listener(mob/listener_mob)
	PRIVATE_PROC(TRUE)

	listeners -= listener_mob

	if(listener_mob.client)
		listener_mob.client.sound_tokens -= src

	// Don't strip COMSIG_QDELETING from the source, or we'd wipe its source_deleted handler.
	var/list/signals_to_remove = list(SIGNAL_ADDTRAIT(TRAIT_DEAF), SIGNAL_REMOVETRAIT(TRAIT_DEAF))
	if(listener_mob != source)
		signals_to_remove += COMSIG_QDELETING
	UnregisterSignal(listener_mob, signals_to_remove)
	SEND_SOUND(listener_mob, null_sound)

/// Recompute a single listener's mute state from distance/z-level/deafness and push the sound.
/datum/sound_token/proc/update_listener(mob/listener_mob, update_sound = TRUE)
	if(QDELETED(src))
		return

	if(isnull(listeners[listener_mob]))
		return

	var/turf/source_turf = get_turf(source)
	var/turf/listener_turf = get_turf(listener_mob)

	if(!source_turf || !listener_turf)
		return

	var/is_muted = listeners[listener_mob] & SOUND_MUTE
	var/should_be_muted = source_turf.z != listener_turf.z
	should_be_muted ||= get_dist_euclidean(source_turf, listener_turf) > range
	should_be_muted ||= HAS_TRAIT(listener_mob, TRAIT_DEAF)

	// Nothing to do if it is already muted and should stay that way.
	if(should_be_muted && is_muted)
		return

	set_listener_status(listener_mob, should_be_muted ? SOUND_MUTE : NONE)
	send_listener_sound(listener_mob, update_sound)

/datum/sound_token/proc/send_listener_sound(mob/listener_mob, update_sound)
	PRIVATE_PROC(TRUE)

	sound.status = SOUND_STREAM|sound_status|listeners[listener_mob]
	if(update_sound)
		sound.status |= SOUND_UPDATE
	else
		sound.offset = calculate_offset()

	if(sound.status & SOUND_MUTE)
		SEND_SOUND(listener_mob, sound)
		return

	if(!listener_mob.playsound_local(
		get_turf(source),
		vol = volume,
		falloff_exponent = falloff_exponent,
		channel = sound_channel,
		sound_to_use = sound,
		max_distance = range,
		falloff_distance = falloff_distance,
		use_reverb = TRUE,
	))
		sound.status = SOUND_UPDATE|SOUND_MUTE
		SEND_SOUND(listener_mob, sound)
	sound.offset = null

/// Queue every listener for a deferred refresh by the subsystem.
/datum/sound_token/proc/update_all_listeners()
	PRIVATE_PROC(TRUE)

	for(var/mob/listener_mob in listeners)
		if(!listener_mob.client)
			continue
		SSsound_tokens.clients_needing_update[listener_mob.client] = TRUE

/// Refresh every listener immediately, bypassing the subsystem queue.
/datum/sound_token/proc/force_update_all_listeners(update_sound = TRUE)
	PRIVATE_PROC(TRUE)

	for(var/mob/listener_mob in listeners)
		if(!listener_mob.client)
			continue
		update_listener(listener_mob, update_sound)

/// Setter for volume
/datum/sound_token/proc/set_volume(new_volume, update_listeners = TRUE)
	volume = new_volume
	if(update_listeners)
		update_all_listeners()

/// Set the status of a listener. Does not update the sound.
/datum/sound_token/proc/set_listener_status(mob/listener_mob, new_status)
	PRIVATE_PROC(TRUE)

	if(isnull(listeners[listener_mob]))
		return

	listeners[listener_mob] = new_status

/// Respond to TRAIT_DEAF addition/removal
/datum/sound_token/proc/listener_deafness_update(atom/movable/source)
	SIGNAL_HANDLER
	update_listener(source)

/datum/sound_token/proc/listener_deleted(datum/source)
	SIGNAL_HANDLER
	remove_listener(source)

/// Respond to any mob in the world being logged into. Only adds if the mob is within range.
/datum/sound_token/proc/player_login(datum/source, mob/player)
	SIGNAL_HANDLER
	var/turf/player_turf = get_turf(player)
	var/turf/source_turf = get_turf(src.source)
	if(!player_turf || !source_turf)
		return
	if(player_turf.z != source_turf.z)
		return
	if(get_dist_euclidean(source_turf, player_turf) > range)
		return
	add_or_update_listener(player)

/// Respond to any cliented mob becoming uncliented
/datum/sound_token/proc/player_logout(datum/source, mob/player)
	SIGNAL_HANDLER
	remove_listener(player)

/// If the sound source moves, update tracked cells then refresh all listener positions.
/datum/sound_token/proc/source_moved()
	SIGNAL_HANDLER
	update_tracked_cells()
	update_all_listeners()

/datum/sound_token/proc/source_deleted()
	SIGNAL_HANDLER

	qdel(src)

/// Update env when source is entering new area.
/datum/sound_token/proc/on_enter_area(datum/source, area/area_to_register)
	SIGNAL_HANDLER
	set_new_environment(area_to_register.sound_environment || SOUND_ENVIRONMENT_NONE)

/// Apply a new reverb environment and refresh listeners if it changed.
/datum/sound_token/proc/set_new_environment(new_env)
	PRIVATE_PROC(TRUE)

	if(sound.environment == new_env)
		return
	sound.environment = new_env
	update_all_listeners()

/// Calculates the offset to give the sound for people who start hearing it mid-play.
/datum/sound_token/proc/calculate_offset()
	PRIVATE_PROC(TRUE)
	SHOULD_BE_PURE(TRUE)

	var/elapsed = REALTIMEOFDAY - start_time
	var/freq_factor = (sound.frequency || 100) / 100
	var/pitch_factor = (sound.pitch || 100) / 100
	return elapsed * freq_factor * pitch_factor

/// Update tracked cells; happens on movement. We need to check if anyone is now out of cell range and kick them out.
/datum/sound_token/proc/update_tracked_cells()
	PRIVATE_PROC(TRUE)

	if(!get_turf(source))
		return

	var/list/new_and_old = cell_tracker.recalculate_cells(get_turf(source))
	var/list/datum/spatial_grid_cell/added_cells = new_and_old[1]
	var/list/datum/spatial_grid_cell/removed_cells = new_and_old[2]

	for(var/datum/spatial_grid_cell/cell as anything in removed_cells)
		UnregisterSignal(cell, list(SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)))

	// Remove listeners whose mob is no longer in any remaining member cell
	if(length(removed_cells))
		for(var/mob/listener_mob as anything in listeners)
			if(SSspatial_grid.get_cell_of(listener_mob) in cell_tracker.member_cells)
				continue
			remove_listener(listener_mob)

	for(var/datum/spatial_grid_cell/cell as anything in added_cells)
		RegisterSignal(cell, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(on_cell_client_entered))
		RegisterSignal(cell, SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(on_cell_client_exited))
		for(var/mob/listener_mob as anything in cell.client_contents)
			add_or_update_listener(listener_mob)

/// Signal handler for SPATIAL_GRID_CELL_ENTERED on tracked cells. Adds newly arriving mobs as listeners.
/datum/sound_token/proc/on_cell_client_entered(datum/source, list/entering_mobs)
	SIGNAL_HANDLER

	for(var/mob/listener_mob as anything in entering_mobs)
		if(!isnull(listeners[listener_mob])) // already added
			continue
		add_or_update_listener(listener_mob)

/// Signal handler for SPATIAL_GRID_CELL_EXITED on tracked cells. Removes mobs who have left all member cells.
/datum/sound_token/proc/on_cell_client_exited(datum/source, list/exiting_mobs)
	SIGNAL_HANDLER

	for(var/mob/listener_mob as anything in exiting_mobs)
		if(SSspatial_grid.get_cell_of(listener_mob) in cell_tracker.member_cells)
			continue
		remove_listener(listener_mob)

/// The sound should have ended on all clients. Time to destroy the sound token.
/datum/sound_token/proc/on_sound_ended()
	qdel(src)
