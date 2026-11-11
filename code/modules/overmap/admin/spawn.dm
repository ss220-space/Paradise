/datum/controller/subsystem/overmap/proc/is_loading_admin_shuttle(obj/docking_port/mobile/port)
	return length(admin_shuttle_spawns) && admin_shuttle_spawns[SSmapping.used_turfs[get_turf(port)]]

/obj/docking_port/mobile/overmap_spawn_anchor
	timid = TRUE

/obj/docking_port/mobile/overmap_spawn_anchor/overmap_uses_area_hull()
	return TRUE
