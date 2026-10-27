/datum/controller/subsystem/overmap/proc/is_loading_admin_shuttle(obj/docking_port/mobile/port)
	return length(admin_shuttle_spawns) && admin_shuttle_spawns[SSmapping.used_turfs[get_turf(port)]]

/obj/docking_port/mobile/overmap_spawn_anchor
	timid = TRUE

/obj/docking_port/mobile/overmap_spawn_anchor/overmap_uses_area_hull()
	return TRUE

/datum/overmap_admin_panel/proc/spawn_shuttle_in_hyperspace(datum/map_template/template, datum/overmap_sector/sector, turf/spot, mob/user)
	if(!template || template.width <= 0 || template.height <= 0 || template.width > world.maxx - SHUTTLE_TRANSIT_BORDER * 2 || template.height > world.maxy - SHUTTLE_TRANSIT_BORDER * 2)
		to_chat(user, span_warning("Не выбран шаблон шаттла или его размеры превышают доступную область гиперпространства."), confidential = TRUE)
		return null
	var/obj/docking_port/mobile/overmap_spawn_anchor/anchor = new(null)
	anchor.width = template.width
	anchor.height = template.height
	anchor.dwidth = FLOOR(template.width / 2, 1)
	anchor.dheight = FLOOR(template.height / 2, 1)
	anchor.mapped_width = anchor.width
	anchor.mapped_height = anchor.height
	anchor.mapped_dwidth = anchor.dwidth
	anchor.mapped_dheight = anchor.dheight
	var/obj/docking_port/stationary/transit/pad = SSshuttle.generate_transit_dock(anchor, OVERMAP_SPAWN_MAX_Z_LEVEL)
	if(!pad)
		qdel(anchor, TRUE)
		to_chat(user, span_warning("Не удалось выделить гиперпространство для шаттла в пределах лимита [OVERMAP_SPAWN_MAX_Z_LEVEL] z-уровней."), confidential = TRUE)
		return null
	var/turf/low = pad.reserved_area.bottom_left_turfs[1]
	var/turf/high = pad.reserved_area.top_right_turfs[1]
	var/turf/load_at = locate(FLOOR((low.x + high.x) / 2, 1), FLOOR((low.y + high.y) / 2, 1), low.z)
	SSovermap.admin_shuttle_spawns[pad.reserved_area] = TRUE
	var/loaded = FALSE
	try
		loaded = template.load(load_at, centered = TRUE)
	catch(var/exception/error)
		SSovermap.admin_shuttle_spawns -= pad.reserved_area
		qdel(anchor, TRUE)
		throw error
	SSovermap.admin_shuttle_spawns -= pad.reserved_area
	if(!loaded)
		qdel(anchor, TRUE)
		to_chat(user, span_warning("Не удалось загрузить карту шаттла."), confidential = TRUE)
		return null
	var/obj/docking_port/mobile/port = find_loaded_mobile_port(null, template, load_at)
	if(!port)
		port = make_mobile_port_for_loaded_map(null, template, load_at, user)
	if(!port)
		qdel(anchor, TRUE)
		to_chat(user, span_warning("На карте не найдена область шаттла."), confidential = TRUE)
		return null
	anchor.assigned_transit = null
	pad.owner = port
	port.assigned_transit = pad
	pad.forceMove(get_turf(port))
	pad.setDir(port.dir)
	register_spawned_mobile_port(port)
	qdel(anchor, TRUE)
	var/obj/overmap/entity/vessel = SSovermap.get_or_register_shuttle(port)
	if(!vessel)
		return null
	if(vessel.docked_to)
		vessel.release_to_overmap(spot)
	if(vessel.sector != sector)
		vessel.sector?.remove_object(vessel)
	sector.add_object(vessel, spot)
	vessel.position = list(0, 0)
	vessel.status = OVERMAP_STATUS_OVERMAP
	vessel.halted = FALSE
	vessel.selected_dock_id = null
	vessel.set_free_flight_view(TRUE)
	log_admin("[key_name(user)] spawned shuttle [template.name] directly in hyperspace at [sector.id].")
	return vessel
