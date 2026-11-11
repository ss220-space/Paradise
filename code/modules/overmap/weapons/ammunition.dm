/obj/projectile/proc/configure_ship_shot(mob/user, atom/source, damage_scale = 1, penetration_chance = 0, radar_visible = FALSE)
	firer = user
	firer_source_atom = source
	damage *= damage_scale
	overmap_radar_visible |= radar_visible
	if(penetration_chance)
		ship_penetrations = 1
		ship_penetration_chance = penetration_chance
		ship_penetration_decay = 0.5
	LAZYADD(permutated, source)

/obj/projectile/proc/try_ship_penetration(key)
	if(key in ship_pierced_tiles)
		return TRUE
	if(!ship_penetrations || !prob(ship_penetration_chance))
		ship_penetrations = 0
		return FALSE
	ship_penetrations--
	damage *= ship_penetration_decay
	LAZYADD(ship_pierced_tiles, key)
	return TRUE

/obj/projectile/proc/ship_pierce(atom/target)
	if((!ship_penetrations && !(get_turf(target) in ship_pierced_tiles)) || ismob(target) || (!isturf(target) && !isstructure(target) && !ismachinery(target)) || !target.density)
		return FALSE
	if(istype(target, /turf/simulated/wall/indestructible) || (target.resistance_flags & INDESTRUCTIBLE))
		return FALSE
	var/turf/spot = get_turf(target)
	if(!try_ship_penetration(spot))
		return FALSE
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
	overmap_radar_kind = "heavy"
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

/datum/controller/subsystem/overmap/proc/sector_explosion_turf(datum/overmap_sector/sector, x, y)
	for(var/datum/overmap_bubble/space as anything in bubbles)
		if(space.static_level && space.sector == sector)
			var/turf/spot = space.turf_at(x, y)
			if(spot)
				return spot
	for(var/obj/overmap/entity/vessel as anything in flying_vessels)
		if(vessel.sector != sector || !vessel.flight_reservation || abs(vessel.get_world_x() - x) > vessel.hull_radius + 3 || abs(vessel.get_world_y() - y) > vessel.hull_radius + 3)
			continue
		var/turf/spot = world_to_frame(vessel, x, y)
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
	overmap_radar_kind = "ion"
	overmap_radar_visible = TRUE

/obj/projectile/ion/pod/on_hit(atom/target, blocked = 0)
	var/turf/spot = get_turf(target)
	if(!spot)
		return
	pod_emp(spot)

/datum/controller/subsystem/overmap/proc/affect_projected_explosion(datum/overmap_sector/sector, x, y, devastation_range, heavy_impact_range, light_impact_range, protect_epicenter = FALSE, direction = 0, arc = 360)
	var/reach = max(devastation_range, heavy_impact_range, light_impact_range)
	if(reach <= 0)
		return
	for(var/obj/overmap/entity/virtual_structure/structure as anything in GLOB.overmap_virtual_structures)
		if(structure.sector != sector || abs(structure.get_world_x() - x) > structure.hull_radius + reach || abs(structure.get_world_y() - y) > structure.hull_radius + reach)
			continue
		var/list/center = structure.world_to_hull(x, y)
		var/heading = structure.get_facing()
		for(var/ix in FLOOR(center[1] - reach, 1) to CEILING(center[1] + reach, 1))
			for(var/iy in FLOOR(center[2] - reach, 1) to CEILING(center[2] + reach, 1))
				var/list/cell = structure.virtual_cells["[ix],[iy]"]
				if(!cell || cell[4] <= 0)
					continue
				var/severity = overmap_explosion_severity(ix - center[1], iy - center[2], devastation_range, heavy_impact_range, light_impact_range, protect_epicenter, direction - heading, arc)
				if(severity)
					structure.damage_cell(cell, overmap_explosion_damage(severity))
	for(var/obj/overmap/feature/hazard/field as anything in scatter_fields_at(sector, x, y, reach))
		for(var/index in field.nearby_scatter(x, y, reach))
			var/severity = overmap_explosion_severity(field.scatter_points[index] - x, field.scatter_points[index + 1] - y, devastation_range, heavy_impact_range, light_impact_range, protect_epicenter, direction, arc)
			if(severity)
				field.damage_scatter(index, overmap_explosion_damage(severity))
