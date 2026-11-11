/datum/overmap_projectile/proc/scatter_hit(obj/overmap/feature/hazard/field, index, x, y)
	if(ion_impact(x, y))
		return TRUE
	var/key = "[field.UID()]:[index]"
	if(key in payload.ship_pierced_tiles)
		return FALSE
	if(istype(payload, /obj/projectile/ship_round))
		var/obj/projectile/ship_round/round = payload
		var/list/result = round.abstract_hit(key, field.scatter_points[index + 2])
		field.damage_scatter(index, result[1])
		if(!result[2])
			round.sector_impact(sector, x, y)
			qdel(src)
			return TRUE
		return FALSE
	var/pierce = payload.try_ship_penetration(key)
	field.damage_scatter(index, payload.damage)
	if(istype(payload, /obj/projectile/bullet/ship_artillery) && (!pierce || !payload.ship_penetrations))
		detonate_shell(x, y)
		qdel(src)
		return TRUE
	if(!pierce)
		qdel(src)
		return TRUE
	return FALSE

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
		var/turf/spot = SSovermap.world_to_frame(vessel, x, y)
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

/datum/overmap_projectile/proc/detonate_shell(x, y)
	var/obj/projectile/bullet/ship_artillery/shell = payload
	var/turf/blast = SSovermap.sector_explosion_turf(sector, x, y)
	if(blast)
		shell.detonate(blast)
	else
		SSovermap.affect_projected_explosion(sector, x, y, 0, 1, 2)
		SSovermap.show_sector_explosion(sector, x, y)
