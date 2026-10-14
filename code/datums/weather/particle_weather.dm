/**
 * Subtype of /datum/weather that renders its visuals with world-space particles (rain, ash, etc) instead of
 * relying purely on tiled area overlays. Manages a particle emitter per z-level and animates its intensity
 * ("severity") across the weather stages.
 */
/datum/weather/particle
	/// Particle type used for the primary weather visual. At least one of particle_type/emissive_type must be set.
	var/particles/weather/particle_type = null
	/// Optional secondary particle type rendered onto the emissive particle weather plane (for glowing embers etc).
	var/particles/weather/emissive_type = null

	/// Minimum possible severity, (0~100].
	var/min_severity = 1
	/// Maximum possible severity, (0~100].
	var/max_severity = MAXIMUM_WEATHER_SEVERITY
	/// Maximum variation in severity each weather frame.
	var/severity_variation = 5
	/// Optimal severity the weather tries to gravitate towards during the main stage.
	var/optimal_severity = 70
	/// How often (in deciseconds) severity may change. Don't set this too low or it'll look jank.
	var/severity_cooldown = 5 SECONDS

	/// Current weather severity (0 to max_severity).
	var/severity = 0
	/// world.time of the last severity change.
	var/last_severity_tick = 0
	/// Per-player emitter sets we created, keyed by mob. Each entry is a list of /obj/effect/abstract/weather_holder.
	var/list/player_emitters = list()
	/// Current wind direction sign (-1 or 1), picked once per storm.
	var/wind_sign = 0

/datum/weather/particle/New(z_levels)
	. = ..()
	if(isnull(particle_type) && isnull(emissive_type))
		CRASH("[src] ([type]) attempted to initialize without normal or emissive particle types!")

/datum/weather/particle/Destroy()
	remove_all_emitters()
	player_emitters = null
	return ..()

/datum/weather/particle/telegraph()
	. = ..()
	if(!.)
		return
	animate_severity(0)

/datum/weather/particle/end()
	. = ..()
	if(!.)
		animate_severity(0)
		remove_all_emitters()

/**
 * Adjusts severity by a random amount biased by the current stage, then applies it to the emitters,
 * and keeps every player's emitter set following them. Called by SSweather every fire (weather frame).
 */
/datum/weather/particle/proc/process_particles()
	if(last_severity_tick + severity_cooldown <= world.time)
		last_severity_tick = world.time
		var/new_severity = severity
		switch(stage)
			if(STARTUP_STAGE)
				new_severity += rand() * severity_variation * (1 - severity / min_severity)
				new_severity = clamp(new_severity, min_severity, max_severity)
			if(MAIN_STAGE)
				new_severity += LERP(-severity_variation * clamp(INVERSE_LERP(min_severity, optimal_severity, severity), 0, 1), severity_variation * clamp(INVERSE_LERP(max_severity, optimal_severity, severity), 0, 1), rand())
				new_severity = clamp(new_severity, min_severity, max_severity)
			if(WIND_DOWN_STAGE)
				new_severity += rand() * -severity_variation * 4 * max(severity / min_severity, 1)

		new_severity = clamp(new_severity, 0, max_severity)

		animate_severity(new_severity)

	update_emitters()

/// The turf a player is currently looking from (their eye if observing, else the mob itself).
/datum/weather/particle/proc/get_view_turf(mob/player)
	return get_turf(player.canon_client?.eye || player)

/// Whether we should currently have emitters for this player: client attached, viewing an impacted z.
/datum/weather/particle/proc/can_have_emitter(mob/player)
	if(!istype(player) || !player.canon_client)
		return FALSE
	var/turf/view_turf = get_view_turf(player)
	if(!view_turf || !(view_turf.z in impacted_z_levels))
		return FALSE
	return TRUE

/// Creates a player's emitter set at their feet, tuned to the current severity.
/datum/weather/particle/proc/create_emitters(mob/player)
	var/turf/view_turf = get_view_turf(player)
	if(!view_turf)
		return
	var/list/new_emitters = list()
	if(particle_type)
		new_emitters += spawn_emitter(view_turf, particle_type, RENDER_PLANE_PARTICLE_WEATHER)
	if(emissive_type)
		new_emitters += spawn_emitter(view_turf, emissive_type, RENDER_PLANE_EMISSIVE_PARTICLE_WEATHER)
	if(!length(new_emitters))
		return
	player_emitters[player] = new_emitters
	apply_severity_to(new_emitters)

/// Spawns one in-world emitter carrying `particle_path` on `base_plane`, positioned and offset for `location`.
/datum/weather/particle/proc/spawn_emitter(turf/location, particle_path, base_plane)
	var/obj/effect/abstract/weather_holder/emitter = new(location)
	emitter.base_plane = base_plane
	SET_PLANE_W_SCALAR(emitter, base_plane, GET_Z_PLANE_OFFSET(location.z))
	emitter.particles = new particle_path()
	return emitter

/// Moves a player's existing emitters to their current turf, refreshing plane offsets for the new z.
/datum/weather/particle/proc/reposition_emitters(mob/player)
	var/turf/view_turf = get_view_turf(player)
	if(!view_turf)
		remove_emitters(player)
		return
	var/new_offset = GET_Z_PLANE_OFFSET(view_turf.z)
	for(var/obj/effect/abstract/weather_holder/emitter as anything in player_emitters[player])
		emitter.forceMove(view_turf)
		SET_PLANE_W_SCALAR(emitter, emitter.base_plane, new_offset)

/// Spawns/moves/removes emitter sets so every eligible player has exactly one set that follows them.
/datum/weather/particle/proc/update_emitters()
	for(var/mob/owner in player_emitters.Copy())
		if(!can_have_emitter(owner))
			remove_emitters(owner)
	for(var/mob/player in GLOB.player_list)
		if(player_emitters[player])
			reposition_emitters(player)
		else if(can_have_emitter(player))
			create_emitters(player)

/// Drives a list of just-created emitters to the current severity so they start at the right intensity.
/datum/weather/particle/proc/apply_severity_to(list/emitters)
	var/ratio = severity / MAXIMUM_WEATHER_SEVERITY
	for(var/obj/effect/abstract/weather_holder/emitter as anything in emitters)
		var/particles/weather/particle_effect = emitter.particles
		particle_effect.animate_severity(ratio, wind_sign || 1)

/// Deletes and forgets a player's emitters.
/datum/weather/particle/proc/remove_emitters(mob/player)
	var/list/existing = player_emitters[player]
	if(!existing)
		return
	QDEL_LIST(existing)
	player_emitters -= player

/// Deletes every emitter we own (weather ending / datum cleanup).
/datum/weather/particle/proc/remove_all_emitters()
	for(var/mob/player in player_emitters.Copy())
		remove_emitters(player)

/// Pushes the given severity onto every particle emitter we own, driving spawning rate and wind.
/datum/weather/particle/proc/animate_severity(new_severity)
	if(!wind_sign)
		wind_sign = pick(-1, 1)

	severity = new_severity
	var/ratio = severity / MAXIMUM_WEATHER_SEVERITY
	for(var/mob/owner in player_emitters)
		for(var/obj/effect/abstract/weather_holder/emitter as anything in player_emitters[owner])
			var/particles/weather/particle_effect = emitter.particles
			particle_effect.animate_severity(ratio, wind_sign)

/**
 * Adds a full-tile mask overlay on WEATHER_MASK_PLANE over impacted areas only. The particle weather render plate
 * masks its particles against this, so drops don't render over protected/indoor areas.
 */
/datum/weather/particle/generate_overlay_cache()
	. = ..()
	if(stage == END_STAGE)
		return
	for(var/offset in 0 to SSmapping.max_plane_offset)
		. += mutable_appearance('icons/effects/weather_overlay.dmi', "weather_overlay", overlay_layer, plane = WEATHER_MASK_PLANE, offset_const = offset)
