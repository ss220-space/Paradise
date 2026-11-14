/datum/overmap_ai_controller/proc/allocate_ship_id(obj/overmap/entity/ship)
	for(var/attempt in 1 to 999)
		next_ship_id = next_ship_id % 999 + 1
		var/id = add_zero("[next_ship_id]", 3)
		if(!ship_ids[id] || QDELETED(ship_ids[id]))
			ship_ids[id] = ship
			return id
	return add_zero("[rand(0, 999)]", 3)

/datum/overmap_ai_controller/proc/release_ship_id(obj/overmap/entity/ship)
	if(ship_ids[ship.registration_id] == ship)
		ship_ids -= ship.registration_id

/datum/overmap_ai_controller/proc/name_ship(obj/overmap/entity/ship, faction, datum/overmap_ai_profile/profile)
	if(!ship.registration_id || (ship_ids[ship.registration_id] && ship_ids[ship.registration_id] != ship))
		ship.registration_id = allocate_ship_id(ship)
	else
		ship_ids[ship.registration_id] = ship
	var/list/mapped = ship.mapped_ship_identity()
	var/class_code = ship.registration_class || mapped["class"] || profile?.ship_class || "ISS"
	if(!(class_code in GLOB.overmap_ship_classes))
		class_code = profile?.ship_class || "ISS"
	var/base_name = ship.ship_basename || mapped["name"] || ship.identity_name || profile?.name || ship.name
	ship.registration_class = class_code
	ship.recalculate_mass()
	ship.ship_basename = base_name
	ship.name = overmap_format_ship_name(ship.ship_name_format, faction, class_code, ship.registration_id, base_name)
	ship.registered_name = ship.name
