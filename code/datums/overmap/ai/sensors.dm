/datum/overmap_ship_ai/proc/navigation_speed()
	return owner.max_speed * OVERMAP_TILE_SPAN * (1 SECONDS)

/datum/overmap_ship_ai/proc/sensors_online()
	return !QDELETED(owner) && !owner.is_ai_destroyed() && owner.ai_sensor_intact() && !owner.is_overmap_jammed() && (owner.short_sensors_on || (profile.long_scan && owner.long_sensors_on))

/datum/overmap_ship_ai/proc/detection_range()
	return owner.sensor_reach_cells() * OVERMAP_TILE_SPAN * (owner.sector?.tile_travel || 1)

/datum/overmap_ship_ai/proc/perceived_faction(obj/overmap/entity/ship)
	var/list/contact = controller.contact_for(src, ship)
	if(!contact)
		return remember_affiliation(ship, "unknown")
	for(var/datum/overmap_ship_ai/observer as anything in contact["identified_by"])
		if(!QDELETED(observer) && observer.owner.long_sensors_on && observer.sees_directly(contact))
			return remember_affiliation(ship, overmap_ai_faction(ship, TRUE))
	return remember_affiliation(ship, overmap_ai_faction(ship))

/datum/overmap_ai_controller/proc/contact_for(datum/overmap_ship_ai/brain, obj/overmap/entity/ship)
	if(QDELETED(ship) || !brain.sensors_online())
		return null
	var/list/entry = fleet_contacts[group_key(brain)]?[ship]
	for(var/datum/overmap_ship_ai/observer as anything in entry?["observers"])
		if(!QDELETED(observer) && group_key(observer) == group_key(brain) && observer.sees_directly(entry))
			return entry
	return null

/datum/overmap_ai_controller/proc/rebuild_fleet_sensors()
	fleet_contacts = list()
	fleet_life = list()
	for(var/datum/overmap_ship_ai/brain as anything in ships)
		if(QDELETED(brain) || !brain.sensors_online() || !brain.owner.sector)
			continue
		var/key = group_key(brain)
		var/list/shared = fleet_contacts[key]
		if(!shared)
			shared = list()
			fleet_contacts[key] = shared
		var/x = brain.owner.get_world_x()
		var/y = brain.owner.get_world_y()
		var/deep_scan = brain.profile.long_scan && brain.owner.long_sensors_on
		for(var/list/contact as anything in sector_contacts[brain.owner.sector])
			if(!brain.sees_directly(contact))
				continue
			var/obj/overmap/entity/ship = contact["ship"]
			var/list/entry = shared[ship]
			if(!entry)
				entry = list("ship" = ship, "x" = contact["x"], "y" = contact["y"], "radius" = contact["radius"], "targetable" = contact["targetable"])
				entry["observers"] = list()
				entry["identified_by"] = list()
				shared[ship] = entry
			entry["observers"] += brain
			if(deep_scan)
				entry["identified_by"] += brain
		if(!brain.owner.short_sensors_on)
			continue
		var/list/life = fleet_life[key]
		if(!life)
			life = list()
			fleet_life[key] = life
		var/reach = OVERMAP_SENSOR_SHORT_VIEW * OVERMAP_TILE_SPAN * (brain.owner.sector.tile_travel || 1)
		for(var/list/contact as anything in SSovermap.ship_weapon_targets(brain.owner.sector))
			var/mob/living/carbon/human/person = contact[1]
			if(!istype(person) || QDELETED(person) || person.stat == DEAD || person.invisibility > SEE_INVISIBLE_LIVING)
				continue
			if((contact[2] - x) ** 2 + (contact[3] - y) ** 2 > reach ** 2)
				continue
			life[person.UID()] = list(contact[2], contact[3])
