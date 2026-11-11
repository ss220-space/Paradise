/datum/overmap_bubble/proc/update_scatter_proxies(list/eyes, elapsed)
	var/list/wanted = list()
	var/span = OVERMAP_TILE_SPAN * (sector?.tile_travel || 1)
	for(var/list/viewport as anything in SSovermap.frame_viewports(src))
		var/turf/eye = viewport[1]
		var/draw_reach = min(OVERMAP_SCATTER_REACH, viewport[2])
		if(eye.z != bubble_z || !covers(list(eye.x, eye.y), 0))
			continue
		var/list/point = to_world(eye.x, eye.y)
		var/cell_x = FLOOR(point[1] / span + 0.5, 1)
		var/cell_y = FLOOR(point[2] / span + 0.5, 1)
		for(var/x in max(sector.origin_x, cell_x - 1) to min(sector.origin_x + sector.size - 1, cell_x + 1))
			for(var/y in max(sector.origin_y, cell_y - 1) to min(sector.origin_y + sector.size - 1, cell_y + 1))
				var/turf/cell = locate(x, y, sector.z_level)
				for(var/obj/overmap/feature/hazard/field in cell)
					if(istype(field, /obj/overmap/feature/hazard/emp))
						continue
					for(var/index in field.nearby_scatter(point[1], point[2], draw_reach))
						if(field.scatter_points[index + 2] <= 0)
							continue
						var/list/spot = to_bubble(field.scatter_points[index], field.scatter_points[index + 1])
						if(!covers(spot, 0) || abs(spot[1] - eye.x) > draw_reach || abs(spot[2] - eye.y) > draw_reach)
							continue
						var/turf/tile = locate(round(spot[1]), round(spot[2]), bubble_z)
						if(!isspaceturf(tile) || hull_under(tile))
							continue
						var/key = "[field.UID()]_[index]"
						wanted[key] = TRUE
						var/obj/effect/abstract/hull_proxy_tile/scatter/proxy = scatter_proxies[key]
						var/fresh = !proxy
						if(fresh)
							proxy = new(tile, field, index)
							scatter_proxies[key] = proxy
						proxy.glide(spot[1], spot[2], bubble_z, null, bounds, fresh ? 0 : elapsed)
	for(var/key in scatter_proxies)
		if(!wanted[key])
			qdel(scatter_proxies[key])
			scatter_proxies -= key

	if(length(wanted))
		if(!scatter_fog)
			scatter_fog = new(src)
		scatter_fog.update(scatter_proxies)
	else
		QDEL_NULL(scatter_fog)

/datum/fog_scene/scatter
	parent_type = /datum/fog_scene/projected
	var/datum/owner

/datum/fog_scene/scatter/New(datum/owner)
	..(OVERMAP_SCATTER_REACH)
	src.owner = owner

/datum/fog_scene/scatter/Destroy(force)
	owner = null
	return ..()

/datum/fog_scene/scatter/proc/update(list/proxies)
	var/list/previous = drawn
	drawn = list()
	source_positions = list()
	opaque_chunks = list()
	var/changed = length(proxies) != length(previous)
	for(var/key, tile_entry in proxies)
		var/obj/effect/abstract/hull_proxy_tile/scatter/tile = tile_entry
		var/list/point = list(tile.field.scatter_points[tile.point_index], tile.field.scatter_points[tile.point_index + 1])
		drawn[tile] = tile
		source_positions[tile] = point
		if(tile.blocks_sight)
			add_opaque_point(point)
		if(!previous[tile])
			changed = TRUE
	if(!length(drawn))
		detach_all()
		return
	var/obj/overmap/entity/vessel = owner
	if(istype(vessel))
		set_frame(overmap_fog_anchor(vessel.hull_center_x, vessel.hull_center_y, vessel.hull_z), vessel.get_world_x(), vessel.get_world_y(), vessel.hull_center_x, vessel.hull_center_y, vessel.get_facing())
	else
		var/datum/overmap_bubble/bubble = owner
		var/list/point = bubble.to_world(bubble.center_x, bubble.center_y)
		set_frame(overmap_fog_anchor(bubble.center_x, bubble.center_y, bubble.bubble_z), point[1], point[2], bubble.center_x, bubble.center_y, 0)
	if(changed)
		mark_dirty()
	refresh()

/datum/fog_scene/scatter/collect_clients(list/out)
	for(var/viewer_entry, eyes_entry in SSovermap.client_eyes)
		var/client/viewer = viewer_entry
		var/list/eyes = eyes_entry
		for(var/turf/eye as anything in eyes)
			if(SSovermap.frame_owner(eye) == owner)
				out[viewer] = TRUE
				break
