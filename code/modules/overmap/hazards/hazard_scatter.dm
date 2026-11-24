/obj/overmap/feature/hazard/proc/generate_scatter()
	if(scatter_radar_chunks || !sector || istype(src, /obj/overmap/feature/hazard/emp))
		return
	var/span = OVERMAP_TILE_SPAN * (sector.tile_travel || 1)
	var/list/peers = list()
	var/flavour = hazard_flavour(src)
	for(var/ix in x - 1 to x + 1)
		for(var/iy in y - 1 to y + 1)
			var/turf/cell = locate(ix, iy, z)
			for(var/obj/overmap/feature/hazard/other in cell)
				if(hazard_flavour(other) == flavour)
					peers += list(list((other.x - x) * span, (other.y - y) * span, other.x < x || (other.x == x && other.y < y)))
	scatter_radar_chunks = RUSTLIB_CALL(overmap_scatter_create, src, x, y, span, clamp(hazard_density, 1, 8), istype(src, /obj/overmap/feature/hazard/carp), peers, rand(1, 1000000000))

/obj/overmap/feature/hazard/asteroid/taipan_cover/generate_scatter()
	LAZYINITLIST(scatter_radar_chunks)

/obj/overmap/feature/hazard/proc/nearby_scatter(world_x, world_y, reach, circle = FALSE)
	generate_scatter()
	if(!length(scatter_radar_chunks))
		return list()
	return RUSTLIB_CALL(overmap_scatter_near, src, world_x, world_y, reach, circle)

/obj/overmap/feature/hazard/proc/has_scatter_chunks(world_x, world_y, reach)
	generate_scatter()
	for(var/x in FLOOR((world_x - reach) / 16, 1) to FLOOR((world_x + reach) / 16, 1))
		for(var/y in FLOOR((world_y - reach) / 16, 1) to FLOOR((world_y + reach) / 16, 1))
			if(scatter_radar_chunks?["[x],[y]"])
				return TRUE
	return FALSE

/obj/overmap/feature/hazard/proc/scatter_at(world_x, world_y)
	generate_scatter()
	if(!length(scatter_radar_chunks))
		return null
	return RUSTLIB_CALL(overmap_scatter_at, src, FLOOR(world_x + 0.5, 1), FLOOR(world_y + 0.5, 1))

/obj/overmap/feature/hazard/proc/scatter_health(index)
	return RUSTLIB_CALL(overmap_scatter_health, src, index)

/obj/effect/abstract/hull_proxy_tile/scatter
	name = "астероид"
	icon = 'icons/turf/smoothrocks.dmi'
	icon_state = "rock"
	density = TRUE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	obj_flags = NONE
	reanchor_distance = 0
	var/obj/overmap/feature/hazard/field
	var/point_x
	var/point_y
	var/point_index
	var/blocks_sight = TRUE

/obj/effect/abstract/hull_proxy_tile/scatter/Initialize(mapload, obj/overmap/feature/hazard/new_field, index, world_x, world_y)
	field = new_field
	point_index = index
	point_x = world_x
	point_y = world_y
	if(istype(field, /obj/overmap/feature/hazard/carp))
		name = "карп"
		icon = 'icons/mob/carp.dmi'
		icon_state = "carp"
		blocks_sight = FALSE
		density = FALSE
	transform = matrix().Scale(1.03)
	. = ..()
	if(istype(field, /obj/overmap/feature/hazard/carp))
		var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
		AddElement(/datum/element/connect_loc, connections)

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

/obj/effect/abstract/hull_proxy_tile/scatter/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(isliving(arrived) && istype(field, /obj/overmap/feature/hazard/carp) && !QDELETED(field) && field.scatter_health(point_index) > 0)
		field.damage_scatter(point_index, 40)
		new /mob/living/simple_animal/hostile/carp(get_turf(src))
		qdel(src)

/obj/overmap/feature/hazard/proc/damage_scatter(index, damage)
	if(damage <= 0)
		return
	var/chunk_key = RUSTLIB_CALL(overmap_scatter_damage, src, index, damage)
	if(chunk_key)
		scatter_radar_chunks[chunk_key] = TRUE
		SSovermap.scatter_revision++

/obj/overmap/entity/proc/process_scatter(elapsed)
	if(!sector || !free_flight_view)
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
			var/list/points = field.nearby_scatter(self_x, self_y, reach, TRUE)
			if(length(points))
				candidates[field] = points
	if(length(candidates) && !navigation_collision_disabled())
		collide_scatter(candidates, travel)

/obj/overmap/entity/proc/collide_scatter(list/candidates, travel)
	var/steps = max(1, CEILING(travel / 0.4, 1))
	var/list/poses = list()
	for(var/step in 0 to steps)
		var/list/pose = pose_at(step / steps)
		pose += cos(pose[3])
		pose += sin(pose[3])
		poses += list(pose)
	var/first_step = steps + 1
	var/obj/overmap/feature/hazard/struck
	var/struck_x
	var/struck_y
	var/struck_index
	var/struck_hull
	var/list/carp_hits = list()
	for(var/obj/overmap/feature/hazard/field as anything in candidates)
		var/list/points = candidates[field]
		for(var/i in 1 to length(points) step 3)
			var/index = points[i]
			var/world_x = points[i + 1]
			var/world_y = points[i + 2]
			for(var/step in 1 to min(steps, first_step))
				var/list/pose = poses[step + 1]
				var/dx = world_x - pose[1]
				var/dy = world_y - pose[2]
				var/hull_x = hull_center_x + dx * pose[4] - dy * pose[5]
				var/hull_y = hull_center_y + dy * pose[4] + dx * pose[5]
				var/hit = scatter_contact_at(hull_x, hull_y)
				if(!hit)
					continue
				if(istype(field, /obj/overmap/feature/hazard/carp))
					carp_hits += list(list(field, index, step, hit, world_x, world_y))
				else if(step < first_step)
					first_step = step
					struck = field
					struck_index = index
					struck_x = world_x
					struck_y = world_y
					struck_hull = hit
				break
	for(var/list/contact as anything in carp_hits)
		if(contact[3] > first_step)
			continue
		var/obj/overmap/feature/hazard/field = contact[1]
		var/turf/impact = scatter_carp_turf(contact[4], contact[5], contact[6])
		if(impact?.is_blocked_turf(exclude_mobs = TRUE))
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
	var/own_health = overmap_contact_health(struck_hull, src)
	var/target_health = struck.scatter_health(struck_index)
	var/target_damage = damage
	var/own_damage = overmap_contact_damage(damage, own_health, target_health)
	struck.damage_scatter(struck_index, target_damage)
	if(world.time >= next_ram_damage)
		next_ram_damage = world.time + OVERMAP_FLIGHT_TICK
		overmap_damage_contact(struck_hull, own_damage, src)
	set_pose(poses[first_step])
	var/retained = struck.scatter_health(struck_index) > 0 ? 0 : 1 - overmap_impact_loss(target_health, target_damage)
	speed[1] *= retained
	speed[2] *= retained
	feel_impact(severity, severity, get_world_x() - struck_x, get_world_y() - struck_y)

/obj/overmap/entity/proc/scatter_contact_at(hull_x, hull_y)
	var/turf/spot = locate(FLOOR(hull_x + 0.5, 1), FLOOR(hull_y + 0.5, 1), hull_z)
	return hull_turfs[spot] ? spot : null

/obj/overmap/entity/proc/scatter_carp_turf(contact, world_x, world_y)
	return contact

/obj/overmap/entity/proc/draw_scatter(elapsed, draw)
	var/list/wanted = list()
	var/self_x = get_world_x()
	var/self_y = get_world_y()
	var/cos_facing = cos(get_facing())
	var/sin_facing = sin(get_facing())
	var/matrix/turned = matrix()
	turned.Scale(1.03)
	turned.Turn(-get_facing())
	if(draw)
		for(var/list/viewport as anything in SSovermap.frame_viewports(src))
			var/turf/eye = viewport[1]
			var/list/point = hull_to_world(eye.x, eye.y)
			var/reach = viewport[2] * 1.42 + 1
			for(var/obj/overmap/feature/hazard/field as anything in SSovermap.scatter_fields_at(sector, point[1], point[2], reach))
				var/list/points = field.nearby_scatter(point[1], point[2], reach)
				for(var/i in 1 to length(points) step 3)
					var/index = points[i]
					var/key = "[field.UID()]_[index]"
					if(wanted[key])
						continue
					var/dx = points[i + 1] - self_x
					var/dy = points[i + 2] - self_y
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
						proxy = new(spot, field, index, points[i + 1], points[i + 2])
						scatter_proxies[key] = proxy
					proxy.glide(hull_x, hull_y, hull_z, turned, flight_bounds, fresh ? 0 : elapsed)
	for(var/key in scatter_proxies)
		if(!wanted[key])
			qdel(scatter_proxies[key])
			scatter_proxies -= key
	if(draw && length(wanted))
		if(!scatter_fog)
			scatter_fog = new(src)
		scatter_fog.update(scatter_proxies)
	else
		QDEL_NULL(scatter_fog)

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
	if(atmosphere || !sector)
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
				var/chunk = field.scatter_radar_chunks?[chunk_key]
				if(!chunk)
					continue
				if(chunk == TRUE)
					chunk = list("x" = x * 16, "y" = y * 16, "carp" = istype(field, /obj/overmap/feature/hazard/carp), "runs" = RUSTLIB_CALL(overmap_scatter_runs, field, x, y))
					field.scatter_radar_chunks[chunk_key] = chunk
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
		var/list/points = field.nearby_scatter(center_x, center_y, reach)
		for(var/i in 1 to length(points) step 3)
			var/index = points[i]
			var/x = points[i + 1]
			var/y = points[i + 2]
			if(x >= region[1] - 4 && x <= region[3] + 4 && y >= region[2] - 4 && y <= region[4] + 4)
				field.damage_scatter(index, INFINITY)
