/datum/overmap_radar_cache
	var/snapshot_tick = -1
	var/snapshot_epoch = -1
	var/list/snapshots = list()
	var/list/motion_frame
	var/motion_epoch
	var/datum/overmap_sector/motion_sector
	var/list/object_sources = list()
	var/datum/overmap_sector/objects_sector
	var/list/pushed_scatter
	var/list/terrain_cache
	var/terrain_key
	var/terrain_until = 0
	var/list/terrain_chunks
	var/terrain_docks
	var/terrain_revision = 0

/datum/overmap_radar_cache/Destroy()
	snapshots = null
	motion_frame = null
	motion_sector = null
	object_sources = null
	objects_sector = null
	pushed_scatter = null
	terrain_cache = null
	terrain_chunks = null
	return ..()
