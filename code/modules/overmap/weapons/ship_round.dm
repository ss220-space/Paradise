/obj/projectile/ship_round
	desc = "TEMP123TEMP"
	name = "ship shell"
	damage = 60
	pass_flags = PASSPROJECTILE
	overmap_velocity = 140 / 3.6
	overmap_radar_visible = TRUE
	overmap_radar_kind = "medium"
	var/structure_damage = 60
	var/wall_damage = 60
	var/preserve_walls = FALSE
	var/preserve_floors = FALSE
	var/penetration_left = 0
	var/penetration_first = 100
	var/penetration_next = 100
	var/obstacles_hit = 0
	var/erase_obstacles = FALSE
	var/energy_budget = 0
	var/damage_cap = 0
	var/blast_devastation = -1
	var/blast_heavy = -1
	var/blast_light = -1
	var/emp_heavy = 0
	var/emp_light = 0
	var/guided = FALSE
	var/seeker_arc = 30
	var/seeker_range = 300
	var/turn_rate = 10
	var/detonated = FALSE

/obj/projectile/ship_round/Initialize(mapload)
	. = ..()
	switch(overmap_radar_kind)
		if("medium", "heavy", "capital", "capital_rail", "missile", "guided_missile")
			icon = 'icons/obj/ship_weapons/ship_rounds.dmi'
			icon_state = overmap_radar_kind == "capital_rail" ? "rail" : overmap_radar_kind
			appearance_flags |= PIXEL_SCALE

/obj/projectile/ship_round/proc/penetrates()
	var/chance = obstacles_hit++ ? penetration_next : penetration_first
	if(erase_obstacles)
		return TRUE
	if(!penetration_left || !prob(chance))
		penetration_left = 0
		return FALSE
	if(penetration_left > 0)
		penetration_left--
	return TRUE

/obj/projectile/ship_round/proc/spend_energy(health, living = FALSE)
	var/amount = min(energy_budget, living ? damage : damage_cap, max(0, health))
	energy_budget -= amount
	return amount

/obj/projectile/ship_round/ship_pierce(atom/target)
	if(target in permutated)
		return TRUE
	if(target == firer_source_atom)
		return TRUE
	var/turf/spot = get_turf(target)
	if(!spot)
		return FALSE
	if(istype(target, /turf/simulated/wall/indestructible) || (target.resistance_flags & INDESTRUCTIBLE))
		impact(spot)
		qdel(src)
		return TRUE
	var/is_living = isliving(target)
	var/turf/simulated/wall/wall = target
	var/obj/object = target
	var/is_wall = istype(wall)
	var/is_object = istype(object)
	if(!is_living && !is_wall && !is_object)
		impact(spot)
		qdel(src)
		return TRUE
	var/laser = initial(energy_budget) > 0
	var/health = is_wall ? max(0, wall.damage_cap - wall.damage) : is_object ? object.obj_integrity : damage
	var/amount = laser ? spend_energy(health, is_living) : is_wall ? wall_damage : structure_damage
	var/pierce = laser ? energy_budget > 0 : !is_living && penetrates()
	if(erase_obstacles && !is_living)
		amount = health + 1
	if(preserve_walls && is_wall)
		amount = min(amount, max(0, health - 1))
	if(is_living)
		var/previous_damage = damage
		if(laser)
			damage = amount
		target.bullet_act(src, def_zone)
		damage = previous_damage
	else if(is_wall)
		wall.take_damage(amount)
	else if(erase_obstacles)
		qdel(object)
	else
		object.take_damage(amount, damage_type, flag, FALSE)
	if(QDELETED(src))
		return TRUE
	LAZYADD(permutated, target)
	loc = spot
	if(!pierce)
		impact(spot)
		qdel(src)
	return TRUE

/obj/projectile/ship_round/proc/impact(turf/spot)
	if(detonated || !spot)
		return
	var/datum/owner = SSovermap.frame_owner(spot)
	if(owner)
		var/list/point = SSovermap.frame_to_world(owner, spot)
		sector_impact(SSovermap.frame_sector(owner), point[1], point[2])

/obj/projectile/ship_round/proc/sector_impact(datum/overmap_sector/sector, x, y)
	if(detonated || !sector)
		return
	detonated = TRUE
	if(max(blast_light, blast_heavy, blast_devastation) < 0 && !emp_light)
		return
	var/reach = max(blast_light, blast_heavy, blast_devastation, emp_heavy, emp_light)
	if(reach < 0)
		return
	SSovermap.ship_round_effect(src, sector, x, y, reach)

/obj/projectile/ship_round/proc/abstract_hit(key, health)
	if(key in ship_pierced_tiles)
		return list(0, TRUE)
	LAZYADD(ship_pierced_tiles, key)
	var/laser = initial(energy_budget) > 0
	var/amount = laser ? spend_energy(health) : structure_damage
	if(erase_obstacles)
		amount = health + 1
	if(preserve_walls)
		amount = min(wall_damage, amount, max(0, health - 1))
	return list(amount, laser ? energy_budget > 0 : penetrates())

/datum/controller/subsystem/overmap/proc/ship_effect_turfs(datum/overmap_sector/sector, x, y, reach)
	. = list()
	var/list/frames = list()
	for(var/datum/overmap_bubble/space as anything in bubbles)
		if(space.static_level && space.sector == sector)
			frames += space
	for(var/obj/overmap/entity/vessel as anything in flying_vessels)
		if(vessel.sector == sector && vessel.flight_reservation && abs(vessel.get_world_x() - x) <= vessel.hull_radius + reach && abs(vessel.get_world_y() - y) <= vessel.hull_radius + reach)
			frames += vessel
	for(var/datum/owner as anything in frames)
		var/obj/overmap/entity/vessel = owner
		var/datum/overmap_bubble/space = owner
		var/is_ship = istype(vessel)
		var/list/point = is_ship ? vessel.world_to_hull(x, y) : space.to_bubble(x, y)
		if(point[1] + reach + 1 < 1 || point[1] - reach - 1 > world.maxx || point[2] + reach + 1 < 1 || point[2] - reach - 1 > world.maxy)
			continue
		var/turf/anchor = is_ship ? vessel.flight_reservation.bottom_left_turfs[1] : null
		var/z = is_ship ? anchor.z : space.bubble_z
		for(var/ix in max(1, FLOOR(point[1] - reach - 1, 1)) to min(world.maxx, CEILING(point[1] + reach + 1, 1)))
			for(var/iy in max(1, FLOOR(point[2] - reach - 1, 1)) to min(world.maxy, CEILING(point[2] + reach + 1, 1)))
				var/turf/spot = locate(ix, iy, z)
				if(frame_owner(spot) != owner)
					continue
				var/list/world_point = frame_to_world(owner, spot)
				var/distance = sqrt((world_point[1] - x) ** 2 + (world_point[2] - y) ** 2)
				if(distance <= reach + 0.5)
					.[spot] = distance

/datum/controller/subsystem/overmap/proc/ship_round_effect(obj/projectile/ship_round/round, datum/overmap_sector/sector, x, y, reach)
	if(round.emp_light)
		var/obj/projectile/visual = new(null)
		visual.icon = 'icons/effects/effects.dmi'
		visual.icon_state = "emppulse"
		visual.overmap_effect_until = world.time + 4
		launch_sector_projectile(visual, sector, x, y, 0)
	else
		show_sector_explosion(sector, x, y)
	var/list/affected = ship_effect_turfs(sector, x, y, reach)
	for(var/turf/spot as anything in affected)
		var/distance = affected[spot]
		var/severity = EXPLOSION_SEVERITY(distance, round.blast_devastation, round.blast_heavy, round.blast_light)
		for(var/atom/movable/target in spot)
			if(round.emp_light && distance <= round.emp_light)
				target.emp_act(distance <= round.emp_heavy ? EMP_HEAVY : EMP_LIGHT)
			if(severity)
				target.ex_act(severity)
		if(!severity)
			continue
		round.record_overmap_hit(resolve_vessel(spot))
		if(!round.preserve_floors)
			spot.ex_act(severity)
		else if(iswallturf(spot) && !(spot.resistance_flags & INDESTRUCTIBLE))
			var/turf/simulated/wall/wall = spot
			var/amount = overmap_explosion_damage(severity)
			if(round.preserve_walls)
				amount = min(10, amount, max(0, wall.damage_cap - wall.damage - 1))
			wall.take_damage(amount)
	for(var/obj/overmap/entity/virtual_structure/structure as anything in GLOB.overmap_virtual_structures)
		if(structure.sector != sector || abs(structure.get_world_x() - x) > structure.hull_radius + reach || abs(structure.get_world_y() - y) > structure.hull_radius + reach)
			continue
		for(var/key, cell_entry in structure.virtual_cells)
			var/list/cell = cell_entry
			if(cell[4] <= 0)
				continue
			var/datum/overmap_virtual_model/model = cell[3]
			if(round.preserve_floors && !model.solid)
				continue
			var/list/point = structure.hull_to_world(cell[1], cell[2])
			var/severity = overmap_explosion_severity(point[1] - x, point[2] - y, round.blast_devastation, round.blast_heavy, round.blast_light, FALSE, 0, 360)
			if(severity)
				var/amount = overmap_explosion_damage(severity)
				if(round.preserve_walls)
					amount = min(10, amount, max(0, cell[4] - 1))
				round.record_overmap_hit(structure)
				structure.damage_cell(cell, amount)
		for(var/obj/machinery/gun as anything in structure.virtual_weapons)
			var/list/point = structure.hull_to_world(gun.virtual_weapon_x, gun.virtual_weapon_y)
			var/distance = sqrt((point[1] - x) ** 2 + (point[2] - y) ** 2)
			if(round.emp_light && distance <= round.emp_light)
				gun.emp_act(distance <= round.emp_heavy ? EMP_HEAVY : EMP_LIGHT)
	for(var/obj/overmap/feature/hazard/field as anything in scatter_fields_at(sector, x, y, reach))
		for(var/index in field.nearby_scatter(x, y, reach))
			var/severity = overmap_explosion_severity(field.scatter_points[index] - x, field.scatter_points[index + 1] - y, round.blast_devastation, round.blast_heavy, round.blast_light, FALSE, 0, 360)
			if(severity)
				field.damage_scatter(index, overmap_explosion_damage(severity))
	add_game_logs("Ship weapon impact in [sector.id] at ([x], [y]), blast [round.blast_devastation]/[round.blast_heavy]/[round.blast_light], EMP [round.emp_heavy]/[round.emp_light].")
