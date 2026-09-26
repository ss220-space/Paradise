/obj/overmap/portal
	name = "warp portal"
	desc = "Нестабильный проход в другой сектор. Он явно не должен тут находиться."
	icon_state = "event"
	color = "#c48bff"
	overmap_kind = OVERMAP_KIND_PORTAL
	map_color = "#c48bff"
	var/datum/overmap_sector/destination_sector
	var/destination_x
	var/destination_y
	var/required_vessel_flags = OVERMAP_VESSEL_WARP
	var/ttl

/obj/overmap/portal/Initialize(mapload)
	. = ..()
	if(ttl)
		QDEL_IN(src, ttl)

/obj/overmap/portal/proc/transit_vessel(obj/overmap/entity/vessel)
	if(!vessel.can_use_portal(src))
		return "Этот корабль не может использовать этот портал."
	if(vessel.status != OVERMAP_STATUS_OVERMAP && vessel.status != OVERMAP_STATUS_TRANSIT)
		return "Сначала нужно выйти в открытый космос."
	if(vessel.is_moving())
		return "Снизьте скорость перед входом в портал."
	var/datum/overmap_sector/target_sector = destination_sector
	if(!target_sector)
		return "Портал никуда не ведёт."
	var/turf/dest = target_sector.get_turf_at(destination_x || round(target_sector.size / 2), destination_y || round(target_sector.size / 2))
	if(!dest)
		return "Точка выхода портала недоступна."
	vessel.sector?.remove_object(vessel)
	target_sector.add_object(vessel, dest)
	vessel.announce_sensor_event("Прыжок через портал: [vessel.get_overmap_display_name()]", "portal")
	return TRUE
