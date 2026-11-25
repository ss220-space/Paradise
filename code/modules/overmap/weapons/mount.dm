/datum/controller/subsystem/overmap/proc/ship_weapon_targets(datum/overmap_sector/sector)
	if(world.time >= weapon_targets_until)
		weapon_targets = list()
		weapon_targets_until = world.time + OVERMAP_SLOW_TICK
		for(var/mob/living/target as anything in GLOB.alive_mob_list)
			var/turf/spot = get_turf(target)
			var/datum/owner = frame_owner(spot)
			if(!owner)
				continue
			var/datum/overmap_sector/where = frame_sector(owner)
			if(!where)
				continue
			var/list/entries = weapon_targets[where.id]
			if(!entries)
				entries = list()
				weapon_targets[where.id] = entries
			entries[target] = frame_to_world(owner, spot)
	return weapon_targets[sector.id]

/datum/controller/subsystem/overmap/proc/nearby_turret_targets(datum/overmap_sector/sector, list/point, reach)
	var/list/contacts = ship_weapon_targets(sector)
	if(!length(contacts) || !SSspatial_grid.initialized)
		return contacts
	var/list/nearby = list()
	for(var/datum/overmap_bubble/space as anything in sector.bubbles)
		if(space.bubble_z)
			var/list/origin = space.to_bubble(point[1], point[2])
			if(space.covers(origin, reach + 1))
				collect_turret_targets(nearby, contacts, origin, space.bubble_z, reach)
	for(var/datum/turf_reservation/reservation as anything in flight_reservations)
		var/obj/overmap/entity/vessel = flight_reservations[reservation]
		if(vessel.sector != sector || vessel.atmosphere)
			continue
		var/list/origin = vessel.world_to_hull(point[1], point[2])
		for(var/turf/corner as anything in reservation.bottom_left_turfs)
			collect_turret_targets(nearby, contacts, origin, corner.z, reach)
	if(length(nearby) <= 1)
		return nearby
	return contacts & nearby

/datum/controller/subsystem/overmap/proc/collect_turret_targets(list/nearby, list/contacts, list/origin, level, reach)
	var/radius = reach + 1
	if(origin[1] < 1 - radius || origin[1] > world.maxx + radius || origin[2] < 1 - radius || origin[2] > world.maxy + radius)
		return
	var/turf/center = locate(clamp(round(origin[1], 1), 1, world.maxx), clamp(round(origin[2], 1), 1, world.maxy), level)
	for(var/mob/living/target in SSspatial_grid.orthogonal_range_search(center, SPATIAL_GRID_CONTENTS_TYPE_HEARING, radius))
		var/turf/spot = get_turf(target)
		if(spot && abs(spot.x - origin[1]) <= radius && abs(spot.y - origin[2]) <= radius && contacts[target])
			nearby[target] = contacts[target]

/obj/machinery/porta_turret/shuttleRotate(rotation, params)
	. = ..()
	SEND_SIGNAL(src, COMSIG_OVERMAP_WEAPON_ROTATED, rotation)

/obj/machinery/bsa/portable/shuttleRotate(rotation, params)
	. = ..()
	SEND_SIGNAL(src, COMSIG_OVERMAP_WEAPON_ROTATED, rotation)

/obj/machinery/bsa/portable
	name = "portable bluespace artillery"
	desc = "Корабельное блюспейс-орудие с узким сектором обстрела. Управляется через Helm."
	icon_state = "emitter_center"
	use_power = NO_POWER_USE
	max_integrity = 300

/obj/machinery/bsa/portable/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ship_weapon, arc = 30, automatic = FALSE, mount_dir = get_ship_weapon_mount_dir())

/obj/machinery/bsa/portable/proc/get_ship_weapon_mount_dir()
	return dir

/obj/machinery/bsa/portable/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_unfasten_wrench(user, tool)

/obj/machinery/bsa/portable/screwdriver_act(mob/living/user, obj/item/tool)
	if(anchored)
		to_chat(user, span_warning("Сначала открепите орудие гаечным ключом."))
		return TRUE
	if(tool.use_tool(src, user, volume = tool.tool_volume))
		setDir(turn(dir, 90))
		SEND_SIGNAL(src, COMSIG_OVERMAP_WEAPON_ROTATED, 0, get_ship_weapon_mount_dir())
	return TRUE

/obj/machinery/porta_turret/syndicate/ship
	name = "ship defence turret"
	rapid = 2
	ship_damage_scale = 0.5
	ship_penetration_chance = 50
