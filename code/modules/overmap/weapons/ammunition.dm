/obj/projectile
	var/ship_penetrations = 0
	var/ship_penetration_chance = 100
	var/ship_penetration_decay = 1
	var/ship_piercing = FALSE
	var/list/ship_pierced_tiles

/obj/projectile/proc/ship_pierce(atom/target)
	if(!ship_penetrations || ismob(target) || (!isturf(target) && !isstructure(target) && !ismachinery(target)) || !target.density)
		return FALSE
	if(istype(target, /turf/simulated/wall/indestructible) || (target.resistance_flags & INDESTRUCTIBLE))
		return FALSE
	var/turf/spot = get_turf(target)
	var/new_tile = !(spot in ship_pierced_tiles)
	if(new_tile && !prob(ship_penetration_chance))
		ship_penetrations = 0
		return FALSE
	if(new_tile)
		ship_penetrations--
		LAZYADD(ship_pierced_tiles, spot)
		damage *= ship_penetration_decay
	ship_piercing = TRUE
	prehit(target)
	target.bullet_act(src, def_zone)
	ship_piercing = FALSE
	if(QDELETED(src))
		return TRUE
	LAZYADD(permutated, target)
	loc = spot
	if(istype(src, /obj/projectile/bullet/ship_artillery) && !ship_penetrations)
		var/obj/projectile/bullet/ship_artillery/shell = src
		shell.detonate(spot)
	return TRUE

/obj/projectile/bullet/ship_artillery
	name = "bluespace artillery shell"
	icon_state = "pulse1"
	damage = 75
	armour_penetration = 30
	overmap_radar_visible = TRUE
	ship_penetrations = 2
	var/detonated = FALSE

/obj/projectile/bullet/ship_artillery/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	if(!ship_piercing)
		detonate(get_turf(target))

/obj/projectile/bullet/ship_artillery/proc/detonate(turf/spot)
	if(detonated || !spot)
		return
	detonated = TRUE
	explosion(spot, devastation_range = 0, heavy_impact_range = 1, light_impact_range = 2, flash_range = 2, adminlog = TRUE, cause = "portable bluespace artillery")
	qdel(src)

/datum/overmap_projectile/proc/scatter_hit(obj/overmap/feature/hazard/field, index, x, y)
	if(ion_impact(x, y))
		return TRUE
	var/key = "[field.UID()]:[index]"
	if(key in payload.ship_pierced_tiles)
		return FALSE
	var/pierce = payload.ship_penetrations > 0 && prob(payload.ship_penetration_chance)
	if(pierce)
		payload.ship_penetrations--
		payload.damage *= payload.ship_penetration_decay
		LAZYADD(payload.ship_pierced_tiles, key)
	field.damage_scatter(index, payload.damage)
	if(istype(payload, /obj/projectile/bullet/ship_artillery) && (!pierce || !payload.ship_penetrations))
		for(var/obj/overmap/feature/hazard/nearby as anything in SSovermap.scatter_fields_at(sector, x, y, 2))
			for(var/point_index in nearby.nearby_scatter(x, y, 2))
				var/distance = sqrt((nearby.scatter_points[point_index] - x) ** 2 + (nearby.scatter_points[point_index + 1] - y) ** 2)
				if(distance <= 2)
					nearby.damage_scatter(point_index, max(0, 150 - 50 * distance))
		var/obj/projectile/bullet/ship_artillery/shell = payload
		var/turf/blast = SSovermap.sector_explosion_turf(sector, x, y)
		if(blast)
			shell.detonate(blast)
		else
			SSovermap.show_sector_explosion(sector, x, y)
		qdel(src)
		return TRUE
	if(!pierce)
		qdel(src)
		return TRUE
	return FALSE

/datum/controller/subsystem/overmap/proc/sector_explosion_turf(datum/overmap_sector/sector, x, y)
	for(var/datum/overmap_bubble/space as anything in bubbles)
		if(space.static_level && space.sector == sector)
			var/turf/spot = space.turf_at(x, y)
			if(spot)
				return spot
	for(var/obj/overmap/entity/vessel as anything in flying_vessels)
		if(vessel.sector != sector || !vessel.flight_reservation || abs(vessel.get_world_x() - x) > vessel.hull_radius + 3 || abs(vessel.get_world_y() - y) > vessel.hull_radius + 3)
			continue
		var/list/point = vessel.world_to_hull(x, y)
		var/turf/spot = locate(FLOOR(point[1] + 0.5, 1), FLOOR(point[2] + 0.5, 1), vessel.hull_z)
		if(spot && SSmapping.used_turfs[spot] == vessel.flight_reservation)
			return spot

/datum/controller/subsystem/overmap/proc/show_sector_explosion(datum/overmap_sector/sector, x, y)
	var/obj/projectile/visual = new(null)
	visual.icon = 'icons/effects/96x96.dmi'
	visual.icon_state = "explosionfast"
	visual.pixel_w = -32
	visual.pixel_z = -32
	visual.overmap_effect_until = world.time + 4
	launch_sector_projectile(visual, sector, x, y, 0)

/obj/projectile/ion/pod
	overmap_radar_visible = TRUE
	emp_range = 1

/obj/projectile/ion/pod/on_hit(atom/target, blocked = 0)
	var/turf/spot = get_turf(target)
	if(!spot)
		return
	pod_emp(spot)

/proc/pod_emp(turf/spot)
	playsound(spot, 'sound/effects/empulse.ogg', 60, TRUE)
	new /obj/effect/temp_visual/emp/pulse(spot)
	for(var/atom/target in range(1, spot))
		target.emp_act(EMP_HEAVY)
	add_game_logs("Pod ion impact at [COORD(spot)]")

/datum/overmap_projectile/proc/ion_impact(x, y)
	if(!istype(payload, /obj/projectile/ion/pod))
		return FALSE
	var/list/affected = list()
	for(var/obj/overmap/entity/vessel as anything in SSovermap.flying_vessels)
		if(vessel.sector != sector)
			continue
		if(istype(vessel, /obj/overmap/entity/virtual_structure))
			var/obj/overmap/entity/virtual_structure/structure = vessel
			for(var/obj/machinery/gun as anything in structure.virtual_weapons)
				var/list/point = structure.hull_to_world(gun.virtual_weapon_x, gun.virtual_weapon_y)
				if(abs(point[1] - x) <= 1.5 && abs(point[2] - y) <= 1.5)
					gun.emp_act(EMP_HEAVY)
			continue
		var/list/point = vessel.world_to_hull(x, y)
		var/turf/spot = locate(FLOOR(point[1] + 0.5, 1), FLOOR(point[2] + 0.5, 1), vessel.hull_z)
		if(spot && vessel.flight_reservation && SSmapping.used_turfs[spot] == vessel.flight_reservation)
			affected |= spot
	for(var/datum/overmap_bubble/space as anything in SSovermap.bubbles)
		if(space.static_level && space.sector == sector)
			var/turf/spot = space.turf_at(x, y)
			if(spot)
				affected |= spot
	for(var/turf/spot as anything in affected)
		pod_emp(spot)
	if(!length(affected))
		var/obj/effect/temp_visual/emp/pulse/prototype = /obj/effect/temp_visual/emp/pulse
		var/obj/projectile/visual = new(null)
		visual.icon = initial(prototype.icon)
		visual.icon_state = initial(prototype.icon_state)
		visual.overmap_effect_until = world.time + initial(prototype.duration)
		SSovermap.launch_sector_projectile(visual, sector, x, y, 0)
	qdel(src)
	return TRUE
