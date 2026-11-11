/datum/component/overmap_sensors/ai

/datum/component/overmap_sensors/ai/has_working_sensor(kind)
	var/obj/overmap/entity/virtual_structure/ai/vessel = parent
	if(vessel.ai_destroyed || !vessel.ai_sensor_cell || vessel.ai_sensor_cell[4] <= 0 || vessel.is_overmap_jammed())
		return FALSE
	return kind == OVERMAP_SENSOR_KIND_SHORT || (kind == OVERMAP_SENSOR_KIND_LONG && vessel.ship_ai?.profile.long_scan)

/datum/component/overmap_sensors/ai/display_identified(obj/overmap/other, short_console = FALSE)
	var/obj/overmap/entity/virtual_structure/ai/vessel = parent
	var/obj/overmap/entity/contact = other
	if(istype(contact) && vessel.ship_ai?.controller.contact_for(vessel.ship_ai, contact))
		return TRUE
	return ..()
