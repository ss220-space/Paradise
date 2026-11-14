/obj/overmap/entity/proc/mapped_ship_identity()
	var/list/result = list()
	var/list/areas = list()
	if(shuttle?.areaInstance)
		areas |= shuttle.areaInstance
	for(var/area/place as anything in shuttle?.shuttle_areas)
		areas |= place
	for(var/area/shuttle/place in areas)
		result["name"] ||= place.overmap_ship_name
		result["class"] ||= place.overmap_ship_class
		result["faction"] ||= place.overmap_ship_faction
	return result

/obj/overmap/entity/virtual_structure/mapped_ship_identity()
	return list("name" = mapped_ship_name, "class" = mapped_ship_class, "faction" = mapped_ship_faction)

/obj/overmap/entity/proc/assign_ship_name(faction, fallback_name)
	if(!SSovermap.ai_controller)
		SSovermap.ai_controller = new
	var/list/mapped = mapped_ship_identity()
	if(!ship_basename)
		ship_basename = mapped["name"] || fallback_name || identity_name || name
	var/affiliation = faction || mapped["faction"] || overmap_ai_faction(src, TRUE)
	var/first_registration = !registration_id
	SSovermap.ai_controller.name_ship(src, affiliation)
	if(first_registration && GLOB.overmap_faction_colors[affiliation])
		identity_color = GLOB.overmap_faction_colors[affiliation]
	identity_name = name
	sync_transponder()

/obj/overmap/entity/proc/hull_class()
	var/list/mapped = mapped_ship_identity()
	return registration_class || mapped["class"] || ship_ai?.profile.ship_class

/obj/overmap/entity/proc/estimated_hull_mass(turfs, flying)
	return (OVERMAP_MASS_BASE + turfs * OVERMAP_MASS_PER_TURF) * (flying ? OVERMAP_DYNAMIC_MASS_MULTIPLIER : 1) * (GLOB.overmap_ship_mass_multipliers[hull_class()] || 1)
