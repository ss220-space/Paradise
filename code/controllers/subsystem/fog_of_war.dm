#define FOG_OF_WAR_DIRTY_BATCH 500

SUBSYSTEM_DEF(fog_of_war)
	name = "Fog Of War"

	ss_flags = NONE
	priority = FIRE_PRIORITY_VIS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	wait = 2

	var/max_age = 5

	var/list/synced_z = list()

	var/list/syncing_z = list()

	var/list/turf/dirty_tiles = list()

/datum/controller/subsystem/fog_of_war/Initialize()

#ifdef FOG_OF_WAR_USE_RUSTLIB

	var/result = RUSTLIB_CALL(fog_init, world.maxx, world.maxy, world.maxz)
	if(result != "OK")
		GLOB.fog_rust_enabled = FALSE
		GLOB.fog_rust_error = "fog_init answered [result]"
		log_world("FOG OF WAR native: fog_init answered [result]; falling back to the DM cast")
		return SS_INIT_SUCCESS
	GLOB.fog_rust_verified = TRUE
#else
	GLOB.fog_rust_error = "compiled without FOG_OF_WAR_USE_RUSTLIB"
#endif
	return SS_INIT_SUCCESS

/datum/controller/subsystem/fog_of_war/proc/native_ready(z)
	if(!fog_rust_usable())
		return FALSE
	if(synced_z["[z]"])
		return TRUE
	request_sync(z)
	return FALSE

/datum/controller/subsystem/fog_of_war/proc/request_sync(z)
	var/key = "[z]"
	if(synced_z[key] || syncing_z[key])
		return
	syncing_z[key] = TRUE
	INVOKE_ASYNC(src, PROC_REF(sync_z), z)

/datum/controller/subsystem/fog_of_war/proc/sync_z(z, skip_tick = FALSE)
	var/key = "[z]"
	var/list/blocked = list()
	for(var/turf/tile as anything in Z_TURFS(z))
		if(IS_OPAQUE_TURF(tile))
			blocked += "[tile.x],[tile.y]"
		if(!skip_tick)
			CHECK_TICK
	var/result = RUSTLIB_CALL(fog_load_z, z, jointext(blocked, ";"))
	syncing_z -= key
	if(isnull(result))
		report_native_failure("fog_load_z(z[z]) answered nothing")
		return null
	synced_z[key] = TRUE
	return result

/datum/controller/subsystem/fog_of_war/proc/mark_dirty(turf/tile)
	if(!fog_rust_usable() || (!synced_z["[tile.z]"] && !syncing_z["[tile.z]"]))
		return
	dirty_tiles[tile] = TRUE

/datum/controller/subsystem/fog_of_war/proc/flush_dirty()
	if(!fog_rust_usable() || !length(dirty_tiles))
		return
	var/list/entries = list()
	var/flushed = 0
	for(var/turf/tile as anything in dirty_tiles)
		if(!synced_z["[tile.z]"] || syncing_z["[tile.z]"])
			continue
		entries += "[tile.x],[tile.y],[tile.z],[IS_OPAQUE_TURF(tile) ? 1 : 0]"
		dirty_tiles -= tile
		if(++flushed >= FOG_OF_WAR_DIRTY_BATCH)
			break
	if(!length(entries))
		return
	var/applied = RUSTLIB_CALL(fog_apply_batch, jointext(entries, ";"))
	if(isnull(applied))
		report_native_failure("fog_apply_batch answered nothing")

/datum/controller/subsystem/fog_of_war/proc/native_reset()
	synced_z.Cut()
	syncing_z.Cut()
	dirty_tiles.Cut()
	if(fog_rust_usable())
		RUSTLIB_CALL(fog_reset)

/datum/controller/subsystem/fog_of_war/proc/report_native_failure(reason)
	if(!GLOB.fog_rust_enabled)
		return
	GLOB.fog_rust_enabled = FALSE
	GLOB.fog_rust_error = reason
	message_admins("FOG OF WAR: the native pass failed ([reason]); falling back to the DM cast for the rest of the round.")
	log_world("FOG OF WAR native failure: [reason]")

/datum/controller/subsystem/fog_of_war/Shutdown()
	disable()
	return ..()

/datum/controller/subsystem/fog_of_war/proc/disable()
	for(var/client/viewer as anything in GLOB.fog_attached_views)
		var/list/datum/fog_view/views = GLOB.fog_attached_views[viewer]
		for(var/key in views)
			var/datum/fog_view/view = views[key]
			if(QDELETED(view))
				continue
			view.clear()
			qdel(view)
		fog_update_backdrop(viewer)
	GLOB.fog_attached_views.Cut()
	for(var/client/viewer as anything in GLOB.fog_proxy_backdrops)
		var/atom/movable/screen/overmap_proxy_void/backdrop = GLOB.fog_proxy_backdrops[viewer]
		qdel(backdrop)
	GLOB.fog_proxy_backdrops.Cut()
	native_reset()

/datum/controller/subsystem/fog_of_war/fire(resumed)

	flush_dirty()
	drop_dead_views()

	for(var/client/attached as anything in GLOB.fog_attached_views)
		var/list/datum/fog_view/views = GLOB.fog_attached_views[attached]
		if(QDELETED(attached) || !length(views))
			GLOB.fog_attached_views -= attached
			continue
		for(var/key in views)
			var/datum/fog_view/attached_view = views[key]
			if(QDELETED(attached_view))
				views -= key
				continue
			if(attached_view.needs_update())
				attached_view.update()
		if(!length(views))
			GLOB.fog_attached_views -= attached

/datum/controller/subsystem/fog_of_war/proc/drop_dead_views()
	for(var/client/key as anything in GLOB.fog_attached_views)
		var/list/datum/fog_view/views = GLOB.fog_attached_views[key]
		if(QDELETED(key))
			for(var/frame_key in views)
				var/datum/fog_view/view = views[frame_key]
				view?.clear()
				qdel(view)
			GLOB.fog_attached_views -= key

			var/atom/movable/screen/overmap_proxy_void/orphan = GLOB.fog_proxy_backdrops[key]
			if(orphan)
				qdel(orphan)
				GLOB.fog_proxy_backdrops -= key
			continue
		for(var/frame_key in views)
			var/datum/fog_view/view = views[frame_key]
			if(!QDELETED(view) && view.owner)
				continue
			view?.clear()
			qdel(view)
			views -= frame_key
		if(!length(views))
			GLOB.fog_attached_views -= key

			fog_update_backdrop(key)

#undef FOG_OF_WAR_DIRTY_BATCH
