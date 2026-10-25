#define OVERMAP_SCATTER_REACH OVERMAP_RADAR_TERRAIN_RANGE

/obj/overmap/feature/hazard
	var/list/scatter_points
	var/list/scatter_chunks
	var/list/scatter_radar_chunks
	var/list/scatter_hit_chunks

/obj/overmap/feature/hazard/proc/generate_scatter()
	if(scatter_points || !sector || istype(src, /obj/overmap/feature/hazard/emp))
		return
	scatter_points = list()
	scatter_chunks = list()
	var/span = OVERMAP_TILE_SPAN * (sector.tile_travel || 1)
	var/list/peers = list()
	var/flavour = hazard_flavour(src)
	for(var/ix in x - 1 to x + 1)
		for(var/iy in y - 1 to y + 1)
			var/turf/cell = locate(ix, iy, z)
			for(var/obj/overmap/feature/hazard/other in cell)
				if(hazard_flavour(other) == flavour)
					peers += list(list((other.x - x) * span, (other.y - y) * span, other.x < x || (other.x == x && other.y < y)))
	var/list/generated = RUSTLIB_CALL(overmap_scatter, x, y, span, clamp(hazard_density, 1, 8), istype(src, /obj/overmap/feature/hazard/carp), peers, rand(1, 1000000000))
	scatter_points = generated[1]
	scatter_chunks = generated[2]
	scatter_radar_chunks = generated[3]

/obj/overmap/feature/hazard/asteroid/taipan_cover/generate_scatter()
	scatter_points = list()
	scatter_chunks = list()
	scatter_radar_chunks = list()

/obj/overmap/feature/hazard/proc/nearby_scatter(world_x, world_y, reach)
	generate_scatter()
	. = list()
	for(var/chunk_x in FLOOR((world_x - reach) / 16, 1) to FLOOR((world_x + reach) / 16, 1))
		for(var/chunk_y in FLOOR((world_y - reach) / 16, 1) to FLOOR((world_y + reach) / 16, 1))
			var/list/indices = scatter_chunks?["[chunk_x],[chunk_y]"]
			if(indices)
				. += indices

/obj/overmap/feature/hazard/proc/scatter_at(world_x, world_y)
	generate_scatter()
	var/x = FLOOR(world_x + 0.5, 1)
	var/y = FLOOR(world_y + 0.5, 1)
	var/chunk_x = FLOOR(x / 16, 1)
	var/chunk_y = FLOOR(y / 16, 1)
	var/key = "[chunk_x],[chunk_y]"
	var/list/indices = scatter_chunks?[key]
	if(!length(indices))
		return null
	var/list/chunk = scatter_hit_chunks?[key]
	if(!chunk)
		chunk = new /list(256)
		for(var/index in indices)
			var/local_x = scatter_points[index] - chunk_x * 16
			var/local_y = scatter_points[index + 1] - chunk_y * 16
			chunk[local_y * 16 + local_x + 1] = index
		LAZYSET(scatter_hit_chunks, key, chunk)
	var/index = chunk[(y - chunk_y * 16) * 16 + x - chunk_x * 16 + 1]
	return index && scatter_points[index + 2] > 0 ? index : null

/obj/overmap/entity
	var/list/scatter_proxies = list()
	var/datum/fog_scene/scatter/scatter_fog
	var/list/scatter_candidates = list()

/obj/effect/abstract/hull_proxy_tile/scatter
	name = "астероид"
	icon = 'icons/turf/smoothrocks.dmi'
	icon_state = "rock"
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	simulated = FALSE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	obj_flags = NONE
	reanchor_distance = 0
	var/obj/overmap/feature/hazard/field
	var/point_index
	var/blocks_sight = TRUE

/obj/effect/abstract/hull_proxy_tile/scatter/Initialize(mapload, obj/overmap/feature/hazard/new_field, index)
	field = new_field
	point_index = index
	if(istype(field, /obj/overmap/feature/hazard/carp))
		name = "карп"
		icon = 'icons/mob/carp.dmi'
		icon_state = "carp"
		blocks_sight = FALSE
		density = FALSE
	transform = matrix().Scale(1.03)
	return ..()

/obj/effect/abstract/hull_proxy_tile/scatter/Click(location, control, params)
	if(fog_hides_from(usr?.client, src))
		return
	usr?.ClickOn(src, params)

/obj/effect/abstract/hull_proxy_tile/scatter/bullet_act(obj/projectile/projectile, def_zone)
	field?.damage_scatter(point_index, projectile.damage)
	return projectile.on_hit(src, 0, def_zone)

/obj/effect/abstract/hull_proxy_tile/scatter/attackby(obj/item/item, mob/living/user, params)
	if(!Adjacent(user))
		return ATTACK_CHAIN_BLOCKED_ALL
	field?.damage_scatter(point_index, item.force)
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/effect/abstract/hull_proxy_tile/scatter/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	field?.damage_scatter(point_index, damage_amount)
	return max(damage_amount, 0)

/obj/effect/abstract/hull_proxy_tile/scatter/Crossed(atom/movable/arrived)
	. = ..()
	if(isliving(arrived) && istype(field, /obj/overmap/feature/hazard/carp) && field.scatter_points?[point_index + 2] > 0)
		field.damage_scatter(point_index, 40)
		new /mob/living/simple_animal/hostile/carp(get_turf(src))
		qdel(src)

/obj/overmap/feature/hazard/proc/damage_scatter(index, damage)
	if(!scatter_points || index < 1 || index + 2 > length(scatter_points) || scatter_points[index + 2] <= 0 || damage <= 0)
		return
	scatter_points[index + 2] = max(0, scatter_points[index + 2] - max(damage, 0))
	if(scatter_points[index + 2] <= 0)
		if(scatter_radar_chunks)
			scatter_radar_chunks["[FLOOR(scatter_points[index] / 16, 1)],[FLOOR(scatter_points[index + 1] / 16, 1)]"] = null
		SSovermap.scatter_revision++

/obj/overmap/entity/proc/process_scatter(elapsed)
	if(!sector || !free_flight_view)
		scatter_candidates = list()
		QDEL_LIST_ASSOC_VAL(scatter_proxies)
		QDEL_NULL(scatter_fog)
		return
	var/turf/here = get_overmap_turf()
	var/self_x = get_world_x()
	var/self_y = get_world_y()
	var/travel = pose_travel()
	var/reach = hull_radius + travel + 1
	var/list/candidates = list()
	var/scan_cells = max(1, CEILING(reach / (OVERMAP_TILE_SPAN * sector.tile_travel), 1))
	for(var/turf/cell as anything in block(locate(max(here.x - scan_cells, sector.origin_x), max(here.y - scan_cells, sector.origin_y), here.z), locate(min(here.x + scan_cells, sector.origin_x + sector.size - 1), min(here.y + scan_cells, sector.origin_y + sector.size - 1), here.z)))
		for(var/obj/overmap/feature/hazard/field in cell)
			if(istype(field, /obj/overmap/feature/hazard/emp))
				var/cloud_density = clamp(field.cloud_strength(self_x, self_y), 0, 1)
				if(cloud_density > 0 && world.time >= next_overmap_hazard_hit && prob(field.hazard_density ** 2 * cloud_density * elapsed / (1 SECONDS)))
					next_overmap_hazard_hit = world.time + OVERMAP_HAZARD_HIT_COOLDOWN
					field.try_affect(src)
				continue
			candidates[field] = field.nearby_scatter(self_x, self_y, reach)
	if(!navigation_collision_disabled())
		collide_scatter(candidates, travel)
	scatter_candidates = candidates

/obj/overmap/entity/proc/collide_scatter(list/candidates, travel)
	if(navigation_collision_disabled())
		return
	var/self_x = get_world_x()
	var/self_y = get_world_y()
	var/reach_squared = (hull_radius + travel + 1) ** 2
	var/steps = max(1, CEILING(travel / 0.4, 1))
	var/list/poses = list()
	for(var/step in 0 to steps)
		var/list/pose = pose_at(step / steps)
		pose += cos(pose[3])
		pose += sin(pose[3])
		poses += list(pose)
	var/first_step = steps + 1
	var/obj/overmap/feature/hazard/struck
	var/struck_index
	var/turf/struck_hull
	var/list/carp_hits = list()
	for(var/obj/overmap/feature/hazard/field as anything in candidates)
		for(var/index in candidates[field])
			if(field.scatter_points[index + 2] <= 0)
				continue
			var/world_x = field.scatter_points[index]
			var/world_y = field.scatter_points[index + 1]
			if((self_x - world_x) ** 2 + (self_y - world_y) ** 2 > reach_squared)
				continue
			for(var/step in 1 to min(steps, first_step))
				var/list/pose = poses[step + 1]
				var/dx = world_x - pose[1]
				var/dy = world_y - pose[2]
				var/hull_x = hull_center_x + dx * pose[4] - dy * pose[5]
				var/hull_y = hull_center_y + dy * pose[4] + dx * pose[5]
				var/turf/hit = locate(FLOOR(hull_x + 0.5, 1), FLOOR(hull_y + 0.5, 1), hull_z)
				if(!hull_turfs[hit])
					continue
				if(istype(field, /obj/overmap/feature/hazard/carp))
					carp_hits += list(list(field, index, step, hit))
				else if(step < first_step)
					first_step = step
					struck = field
					struck_index = index
					struck_hull = hit
				break
	for(var/list/contact as anything in carp_hits)
		if(contact[3] > first_step)
			continue
		var/obj/overmap/feature/hazard/field = contact[1]
		var/turf/impact = contact[4]
		if(impact.is_blocked_turf(exclude_mobs = TRUE))
			for(var/direction in GLOB.cardinal)
				var/turf/outside = get_step(impact, direction)
				if(outside && !outside.is_blocked_turf(exclude_mobs = TRUE))
					impact = outside
					break
		if(impact && !impact.is_blocked_turf(exclude_mobs = TRUE))
			field.damage_scatter(contact[2], 40)
			new /mob/living/simple_animal/hostile/carp(impact)
	if(!struck)
		return
	var/severity = get_speed() * OVERMAP_TILE_SPAN * (1 SECONDS)
	var/damage = mass_impact_damage(severity)
	var/own_health = overmap_pod ? max(1, overmap_pod.pod().health) : overmap_contact_health(struck_hull)
	var/target_health = struck.scatter_points[struck_index + 2]
	var/target_damage = overmap_contact_damage(damage, target_health, own_health)
	var/own_damage = overmap_contact_damage(damage, own_health, target_health)
	struck.damage_scatter(struck_index, target_damage)
	if(world.time >= next_ram_damage)
		next_ram_damage = world.time + OVERMAP_FLIGHT_TICK
		if(overmap_pod)
			overmap_pod.pod().deal_damage(own_damage)
		else
			overmap_damage_turf(struck_hull, own_damage)
	set_pose(poses[first_step])
	var/retained = struck.scatter_points[struck_index + 2] > 0 ? 0 : 1 - clamp(target_health / max(target_damage, 1), 0.02, 1)
	speed[1] *= retained
	speed[2] *= retained
	feel_impact(severity, severity, get_world_x() - struck.scatter_points[struck_index], get_world_y() - struck.scatter_points[struck_index + 1])

/obj/overmap/entity/proc/draw_scatter(list/candidates, elapsed, draw)
	var/list/wanted = list()
	var/self_x = get_world_x()
	var/self_y = get_world_y()
	var/cos_facing = cos(get_facing())
	var/sin_facing = sin(get_facing())
	var/matrix/turned = matrix().Scale(1.03).Turn(-get_facing())
	if(draw)
		for(var/list/viewport as anything in SSovermap.scatter_viewports(src))
			var/turf/eye = viewport[1]
			var/list/point = hull_to_world(eye.x, eye.y)
			var/reach = viewport[2] * 1.42 + 1
			for(var/obj/overmap/feature/hazard/field as anything in SSovermap.scatter_fields_at(sector, point[1], point[2], reach))
				for(var/index in field.nearby_scatter(point[1], point[2], reach))
					if(field.scatter_points[index + 2] <= 0)
						continue
					var/key = "[field.UID()]_[index]"
					if(wanted[key])
						continue
					var/dx = field.scatter_points[index] - self_x
					var/dy = field.scatter_points[index + 1] - self_y
					var/hull_x = hull_center_x + dx * cos_facing - dy * sin_facing
					var/hull_y = hull_center_y + dy * cos_facing + dx * sin_facing
					if(abs(hull_x - eye.x) > viewport[2] || abs(hull_y - eye.y) > viewport[2])
						continue
					var/turf/spot = overmap_fog_anchor(hull_x, hull_y, hull_z)
					if(!spot || hull_area_turfs[spot] || spot.x < flight_bounds[1] || spot.x > flight_bounds[3] || spot.y < flight_bounds[2] || spot.y > flight_bounds[4])
						continue
					wanted[key] = TRUE
					var/obj/effect/abstract/hull_proxy_tile/scatter/proxy = scatter_proxies[key]
					var/fresh = !proxy
					if(fresh)
						proxy = new(spot, field, index)
						scatter_proxies[key] = proxy
					proxy.glide(hull_x, hull_y, hull_z, turned, flight_bounds, fresh ? 0 : elapsed)
	for(var/key in scatter_proxies.Copy())
		if(!wanted[key])
			qdel(scatter_proxies[key])
			scatter_proxies -= key
	if(draw && length(wanted))
		if(!scatter_fog)
			scatter_fog = new(src)
		scatter_fog.update(scatter_proxies)
	else
		QDEL_NULL(scatter_fog)

/obj/overmap/entity
	var/list/radar_scatter = list()
	var/list/pushed_scatter
	var/scatter_radar_key

/datum/controller/subsystem/overmap/proc/scatter_fields_at(datum/overmap_sector/sector, world_x, world_y, reach)
	. = list()
	if(!sector)
		return
	var/span = OVERMAP_TILE_SPAN * sector.tile_travel
	for(var/x in max(sector.origin_x, FLOOR((world_x - reach) / span, 1) - 1) to min(sector.origin_x + sector.size - 1, CEILING((world_x + reach) / span, 1) + 1))
		for(var/y in max(sector.origin_y, FLOOR((world_y - reach) / span, 1) - 1) to min(sector.origin_y + sector.size - 1, CEILING((world_y + reach) / span, 1) + 1))
			var/turf/cell = locate(x, y, sector.z_level)
			for(var/obj/overmap/feature/hazard/field in cell)
				if(!istype(field, /obj/overmap/feature/hazard/emp))
					. += field

/obj/overmap/entity/proc/radar_scatter_data(reach = 128)
	if(!sector)
		return list()
	reach = clamp(reach, 32, 128)
	var/chunk_x = FLOOR(get_world_x() / 16, 1)
	var/chunk_y = FLOOR(get_world_y() / 16, 1)
	var/key = "[sector.UID()]_[chunk_x]_[chunk_y]_[reach]_[SSovermap.scatter_revision]"
	if(key == scatter_radar_key)
		return radar_scatter
	var/list/geometry = list()
	var/center_x = chunk_x * 16 + 8
	var/center_y = chunk_y * 16 + 8
	for(var/obj/overmap/feature/hazard/field as anything in SSovermap.scatter_fields_at(sector, center_x, center_y, reach + 16))
		field.generate_scatter()
		for(var/x in chunk_x - CEILING(reach / 16, 1) - 1 to chunk_x + CEILING(reach / 16, 1) + 1)
			for(var/y in chunk_y - CEILING(reach / 16, 1) - 1 to chunk_y + CEILING(reach / 16, 1) + 1)
				var/chunk_key = "[x],[y]"
				if(!field.scatter_chunks?[chunk_key])
					continue
				var/list/chunk = field.scatter_radar_chunks?[chunk_key]
				if(!chunk)
					chunk = field.rebuild_scatter_radar_chunk(x, y)
				geometry += list(chunk)
	scatter_radar_key = key
	radar_scatter = geometry
	return geometry

/datum/controller/subsystem/overmap/proc/clear_scatter_for_host(obj/overmap/entity/host)
	var/z_level = host?.dock_host?.pick_landing_z()
	if(!z_level)
		return
	var/list/region = host.region_from_rect(host.host_content_bounds(z_level))
	if(!region)
		return
	var/center_x = (region[1] + region[3]) / 2
	var/center_y = (region[2] + region[4]) / 2
	var/reach = max(region[3] - region[1], region[4] - region[2]) / 2 + 4
	for(var/obj/overmap/feature/hazard/field as anything in scatter_fields_at(host.sector, center_x, center_y, reach))
		field.generate_scatter()
		for(var/index in field.nearby_scatter(center_x, center_y, reach))
			var/x = field.scatter_points[index]
			var/y = field.scatter_points[index + 1]
			if(x >= region[1] - 4 && x <= region[3] + 4 && y >= region[2] - 4 && y <= region[4] + 4)
				field.damage_scatter(index, field.scatter_points[index + 2])

/obj/overmap/feature/hazard/proc/rebuild_scatter_radar_chunk(chunk_x, chunk_y)
	LAZYINITLIST(scatter_radar_chunks)
	var/key = "[chunk_x],[chunk_y]"
	var/list/cells = new/list(256)
	for(var/index in scatter_chunks[key])
		if(scatter_points[index + 2] > 0)
			var/x = scatter_points[index] - chunk_x * 16
			var/y = scatter_points[index + 1] - chunk_y * 16
			cells[y * 16 + x + 1] = TRUE
	var/list/runs = list()
	for(var/y in 0 to 15)
		var/x = 0
		while(x < 16)
			if(!cells[y * 16 + x + 1])
				x++
				continue
			var/start = x
			while(x < 16 && cells[y * 16 + x + 1])
				x++
			runs += start
			runs += y
			runs += x - start
	var/list/chunk = list("x" = chunk_x * 16, "y" = chunk_y * 16, "carp" = istype(src, /obj/overmap/feature/hazard/carp), "runs" = runs)
	scatter_radar_chunks[key] = chunk
	return chunk

/datum/overmap_bubble
	var/list/scatter_proxies = list()
	var/datum/fog_scene/scatter/scatter_fog

/datum/overmap_bubble/proc/update_scatter_proxies(list/eyes, elapsed)
	var/list/wanted = list()
	var/span = OVERMAP_TILE_SPAN * (sector?.tile_travel || 1)
	for(var/list/viewport as anything in SSovermap.scatter_viewports(src))
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
	for(var/key in scatter_proxies.Copy())
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
	var/datum/owner
	var/list/visuals = list()
	var/world_origin_x
	var/world_origin_y
	var/turf/grid_origin

/datum/controller/subsystem/overmap/proc/scatter_viewports(datum/owner)
	. = list()
	for(var/client/viewer as anything in client_eyes)
		var/turf/eye = get_turf(viewer.eye || viewer.mob)
		if(frame_owner(eye) == owner)
			. += list(list(eye, (viewer.maxview() || world.view) + 4))

/datum/fog_scene/scatter/New(datum/owner)
	..(OVERMAP_SCATTER_REACH)
	src.owner = owner

/datum/fog_scene/scatter/Destroy(force)
	owner = null
	visuals = null
	return ..()

/datum/fog_scene/scatter/proc/update(list/proxies)
	visuals = proxies
	var/list/next_drawn = list()
	for(var/key in proxies)
		var/obj/effect/abstract/hull_proxy_tile/scatter/tile = proxies[key]
		var/turf/spot = get_turf(tile)
		if(spot)
			next_drawn[spot] = tile
	var/changed = length(next_drawn) != length(drawn)
	for(var/turf/spot as anything in next_drawn)
		if(drawn[spot] != next_drawn[spot])
			changed = TRUE
			break
	drawn = next_drawn
	if(!length(drawn))
		detach_all()
		return
	var/obj/overmap/entity/vessel = owner
	var/turf/anchor
	if(istype(vessel))
		anchor = overmap_fog_anchor(vessel.hull_center_x, vessel.hull_center_y, vessel.hull_z)
	else
		var/datum/overmap_bubble/bubble = owner
		anchor = overmap_fog_anchor(bubble.center_x, bubble.center_y, bubble.bubble_z)
	var/new_origin_x
	var/new_origin_y
	var/list/target
	var/angle = 0
	if(istype(vessel))
		new_origin_x = world_origin_x
		new_origin_y = world_origin_y
		if(isnull(new_origin_x) || abs(vessel.get_world_x() - new_origin_x) > world.maxx / 2 - 40 || abs(vessel.get_world_y() - new_origin_y) > world.maxy / 2 - 40)
			new_origin_x = FLOOR(vessel.get_world_x(), 1)
			new_origin_y = FLOOR(vessel.get_world_y(), 1)
		target = vessel.world_to_hull(new_origin_x, new_origin_y)
		angle = vessel.get_facing()
	else
		var/datum/overmap_bubble/bubble = owner
		var/list/point = bubble.to_world(bubble.center_x, bubble.center_y)
		new_origin_x = FLOOR(point[1], 1)
		new_origin_y = FLOOR(point[2], 1)
		target = bubble.to_bubble(new_origin_x, new_origin_y)
	if(world_origin_x != new_origin_x || world_origin_y != new_origin_y || frame?.angle != angle)
		changed = TRUE
	world_origin_x = new_origin_x
	world_origin_y = new_origin_y
	grid_origin = locate(round(world.maxx / 2), round(world.maxy / 2), anchor.z)
	set_frame(anchor, grid_origin.x, grid_origin.y, target[1], target[2], angle)
	if(changed)
		mark_dirty()
	refresh()
	for(var/client/viewer as anything in mine)
		var/datum/fog_view/view = fog_attached_to(viewer, frame)
		if(view)
			view.frame_time = OVERMAP_FLIGHT_TICK
			view.replace_frame_tiles()

/datum/fog_scene/scatter/visual_for(turf/source)
	return null

/datum/fog_scene/scatter/render(datum/fog_view/view)
	view.frame_time = OVERMAP_FLIGHT_TICK
	view.replace_frame_tiles()
	return FALSE

/datum/fog_scene/scatter/collect_clients(list/out)
	for(var/client/viewer as anything in SSovermap.client_eyes)
		var/list/eyes = SSovermap.client_eyes[viewer]
		for(var/turf/eye as anything in eyes)
			if(SSovermap.frame_owner(eye) == owner)
				out[viewer] = TRUE
				break

/datum/fog_scene/scatter/cast_center(datum/fog_view/view)
	var/turf/eye = get_turf(view.owner?.eye || view.owner?.mob)
	if(!eye || !grid_origin)
		return null
	var/obj/overmap/entity/vessel = owner
	var/list/point
	if(istype(vessel))
		point = vessel.hull_to_world(eye.x, eye.y)
	else
		var/datum/overmap_bubble/bubble = owner
		point = bubble.to_world(eye.x, eye.y)
	return locate(grid_origin.x + FLOOR(point[1], 1) - world_origin_x, grid_origin.y + FLOOR(point[2], 1) - world_origin_y, grid_origin.z)

/datum/fog_scene/scatter/cast_radius(datum/fog_view/view)
	return min(32, CEILING((view.owner?.maxview() || world.view) * 1.42 + 2, 1))

/datum/fog_scene/scatter/hidden_for(datum/fog_view/view)
	var/turf/probe = view.center
	if(!probe || !fog_rust_usable())
		return list()
	var/list/blockers = list()
	for(var/key in visuals)
		var/obj/effect/abstract/hull_proxy_tile/scatter/proxy = visuals[key]
		if(proxy.blocks_sight)
			var/visual_x = grid_origin.x + proxy.field.scatter_points[proxy.point_index] - world_origin_x
			var/visual_y = grid_origin.y + proxy.field.scatter_points[proxy.point_index + 1] - world_origin_y
			if(abs(probe.x - visual_x) <= view.radius + 1 && abs(probe.y - visual_y) <= view.radius + 1)
				blockers += "[FLOOR(visual_x + 0.5, 1)],[FLOOR(visual_y + 0.5, 1)]"
	var/list/hidden = fog_hidden_native(probe, view.radius, extra_blockers = "virtual;[jointext(blockers, ";")]") || list()
	var/obj/overmap/entity/vessel = owner
	if(!istype(vessel))
		return hidden
	. = list()
	for(var/turf/spot as anything in hidden)
		var/world_x = world_origin_x + spot.x - grid_origin.x
		var/world_y = world_origin_y + spot.y - grid_origin.y
		var/list/point = vessel.world_to_hull(world_x, world_y)
		var/turf/actual = overmap_fog_anchor(point[1], point[2], vessel.hull_z)
		if(!vessel.hull_area_turfs?[actual])
			. += spot

#undef OVERMAP_SCATTER_REACH
