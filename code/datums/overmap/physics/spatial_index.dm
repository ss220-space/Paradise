/datum/overmap_spatial_index
	var/list/buckets = list()
	var/list/members = list()
	var/list/by_sector = list()
	var/cell_size = 128

/datum/overmap_spatial_index/Destroy()
	buckets = null
	members = null
	by_sector = null
	return ..()

/datum/overmap_spatial_index/proc/rebuild(list/vessels)
	buckets = list()
	members = list()
	by_sector = list()
	for(var/obj/overmap/entity/vessel as anything in vessels)
		if(QDELETED(vessel) || !vessel.sector)
			continue
		var/list/sector_vessels = by_sector[vessel.sector]
		if(!sector_vessels)
			sector_vessels = list()
			by_sector[vessel.sector] = sector_vessels
		sector_vessels[vessel] = TRUE
		update(vessel)

/datum/overmap_spatial_index/proc/remove(obj/overmap/entity/vessel)
	for(var/key in members[vessel])
		var/list/bucket = buckets[key]
		bucket -= vessel
		if(!length(bucket))
			buckets -= key
	members -= vessel

/datum/overmap_spatial_index/proc/update(obj/overmap/entity/vessel)
	remove(vessel)
	if(QDELETED(vessel) || !vessel.sector)
		return
	var/x = vessel.get_world_x()
	var/y = vessel.get_world_y()
	var/reach = vessel.hull_radius + vessel.pose_travel() + 1
	var/list/previous = SSovermap.projectile_poses[vessel]
	if(previous && previous[4] == vessel.sector)
		reach = max(reach, vessel.hull_radius + sqrt((x - previous[1]) ** 2 + (y - previous[2]) ** 2) + TORADIANS(abs(closer_angle_difference(previous[3], vessel.get_facing()))) * vessel.hull_radius + 1)
	var/list/keys = list()
	for(var/ix in FLOOR((x - reach) / cell_size, 1) to FLOOR((x + reach) / cell_size, 1))
		for(var/iy in FLOOR((y - reach) / cell_size, 1) to FLOOR((y + reach) / cell_size, 1))
			var/key = "[vessel.sector.id]/[ix],[iy]"
			var/list/bucket = buckets[key]
			if(!bucket)
				bucket = list()
				buckets[key] = bucket
			bucket += vessel
			keys += key
	members[vessel] = keys

/datum/overmap_spatial_index/proc/nearby(datum/overmap_sector/sector, x, y, reach)
	. = list()
	if(!sector)
		return
	var/min_x = FLOOR((x - reach) / cell_size, 1)
	var/max_x = FLOOR((x + reach) / cell_size, 1)
	var/min_y = FLOOR((y - reach) / cell_size, 1)
	var/max_y = FLOOR((y + reach) / cell_size, 1)
	if((max_x - min_x + 1) * (max_y - min_y + 1) > length(members))
		return by_sector[sector]
	for(var/ix in min_x to max_x)
		for(var/iy in min_y to max_y)
			var/list/bucket = buckets["[sector.id]/[ix],[iy]"]
			for(var/obj/overmap/entity/vessel as anything in bucket)
				.[vessel] = TRUE
