/obj/overmap/entity/virtual_structure/ai
	abstract_type = /obj/overmap/entity/virtual_structure/ai
	name = "AI ship"
	desc = "TEMP123TEMP"
	wraparound = FALSE
	vessel_flags = OVERMAP_VESSEL_SHUTTLE
	var/list/ai_drive_cells = list()
	var/list/ai_sensor_cell
	var/ai_structure_version = -1
	var/ai_drive_force = 0
	var/ai_hull_cells = 0
	var/ai_destroyed_cells = 0
	var/ai_destroyed = FALSE

/obj/overmap/entity/virtual_structure/ai/Destroy()
	QDEL_NULL(ship_ai)
	ai_drive_cells = null
	ai_sensor_cell = null
	return ..()

/obj/overmap/entity/virtual_structure/ai/process_sensors()
	return

/obj/overmap/entity/virtual_structure/ai/can_enter_relay(obj/overmap/entity/hyperrelay/relay)
	return FALSE

/obj/overmap/entity/virtual_structure/ai/on_virtual_cell_loaded(datum/overmap_virtual_model/model, cell_x, cell_y)
	var/list/cell = virtual_cells["[cell_x],[cell_y]"]
	if(model.thrust > 0)
		ai_drive_cells += list(cell)
	if(!ai_sensor_cell || (cell_x - hull_center_x) ** 2 + (cell_y - hull_center_y) ** 2 < (ai_sensor_cell[1] - hull_center_x) ** 2 + (ai_sensor_cell[2] - hull_center_y) ** 2)
		ai_sensor_cell = cell

/obj/overmap/entity/virtual_structure/ai/proc/build_hull(datum/overmap_ai_profile/profile, armed = TRUE)
	hull_center_x = (profile.width + 1) / 2
	hull_center_y = (profile.height + 1) / 2
	var/datum/overmap_virtual_model/floor_model = new("/turf/simulated/floor/plasteel,/area/space")
	var/datum/overmap_virtual_model/wall_model = new("/turf/simulated/wall,/area/space")
	var/datum/overmap_virtual_model/drive_model = new("/turf/simulated/floor/plasteel,/obj/machinery/ship_engine{dir = 2},/area/space")
	floor_model.health = 60
	wall_model.health = 150
	drive_model.health = 120
	virtual_models = list("floor" = floor_model, "wall" = wall_model, "drive" = drive_model)
	var/list/gun_x = !armed ? list() : profile.gun_count == 1 ? list(hull_center_x) : list(hull_center_x - 2, hull_center_x + 2)
	var/list/shape = list()
	for(var/ix in 1 to profile.width)
		for(var/iy in 1 to profile.height)
			if((iy == 1 || iy == profile.height) && abs(ix - hull_center_x) > (profile.width - 1) / 2 - 2)
				continue
			var/datum/overmap_virtual_model/model = floor_model
			if(ix == 1 || ix == profile.width || iy == 1 || iy == profile.height)
				model = wall_model
			if(iy == 2 && ix == hull_center_x)
				model = drive_model
			if(iy == profile.height && ix in gun_x)
				var/datum/overmap_virtual_model/gun_model = new("/turf/simulated/floor/plasteel,[profile.gun_type]{dir = 1},/area/space")
				gun_model.health = 120
				virtual_models["gun[ix]"] = gun_model
				model = gun_model
			virtual_cells["[ix],[iy]"] = list(ix, iy, model, model.health)
			on_virtual_cell_loaded(model, ix, iy)
			shape += list((ix - hull_center_x) * 2, (iy - hull_center_y) * 2)
			for(var/list/spec as anything in model.weapons)
				add_virtual_weapon(spec, ix, iy)
	hull_radius = sqrt(profile.width ** 2 + profile.height ** 2) / 2
	hull_inertia = max(1, (profile.width ** 2 + profile.height ** 2) / 12)
	vessel_mass = (OVERMAP_MASS_BASE + length(virtual_cells) * OVERMAP_MASS_PER_TURF) * OVERMAP_DYNAMIC_MASS_MULTIPLIER
	radar_shape = list("tiles" = shape, "collars" = list())
	overmap_kind = OVERMAP_KIND_SHUTTLE
	movable = TRUE
	halted = FALSE
	free_flight_view = TRUE
	AddComponent(/datum/component/overmap_flight)
	admin_virtual_engine = TRUE
	ensure_virtual_engine()
	return TRUE

/obj/overmap/entity/virtual_structure/ai/proc/prepare_ai(datum/overmap_ai_profile/profile)
	ai_hull_cells = length(virtual_cells)
	if(!flight || !ai_hull_cells)
		return FALSE
	if(!length(ai_drive_cells) && ai_sensor_cell)
		ai_drive_cells += list(ai_sensor_cell)
	if(!length(ai_drive_cells))
		return FALSE
	ai_drive_force = vessel_mass * profile.acceleration / 200
	virtual_engine.generated_thrust = ai_drive_force
	virtual_engine.end_processing()
	for(var/obj/machinery/gun as anything in virtual_weapons)
		gun.end_processing()
		var/datum/component/ship_weapon/mount = gun.GetComponent(/datum/component/ship_weapon)
		if(mount)
			mount.automatic = FALSE
	if(!sensor_pack)
		AddComponent(/datum/component/overmap_sensors/ai)
	short_sensors_on = TRUE
	long_sensors_on = profile.long_scan
	flight.angular_dampeners = TRUE
	return TRUE

/obj/overmap/entity/virtual_structure/ai/proc/drive_intact()
	if(ai_destroyed)
		return FALSE
	if(ai_structure_version != hull_version)
		ai_structure_version = hull_version
		var/intact = 0
		for(var/list/cell as anything in ai_drive_cells)
			if(cell[4] > 0)
				intact++
		virtual_engine.generated_thrust = ai_drive_force * intact / max(1, length(ai_drive_cells))
		virtual_engine.on = intact > 0
	return virtual_engine?.can_burn() && virtual_engine.generated_thrust > 0

/obj/overmap/entity/virtual_structure/ai/damage_cell(list/cell, damage)
	if(cell[4] <= 0)
		return
	. = ..()
	if(cell[4] <= 0)
		ai_destroyed_cells++
		if(!ai_destroyed && ai_hull_cells > 0 && ai_destroyed_cells / ai_hull_cells >= 0.35)
			ai_destroyed = TRUE
			ship_ai?.set_enabled(FALSE)
			if(ship_ai)
				ship_ai.state = "destroyed"
				ship_ai.controller.index_until = 0
			virtual_engine.on = FALSE
			flight.engines_state = FALSE
			map_color = "#888888"
			identity_color = map_color
			for(var/obj/machinery/gun as anything in virtual_weapons)
				gun.stat |= BROKEN
			update_overmap_visibility()
			radar_epoch++

/obj/overmap/entity/virtual_structure/ai/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors/ai)

/obj/overmap/entity/virtual_structure/ai/object_visibility(obj/overmap/contact, turf/here, reach)
	var/obj/overmap/entity/ship = contact
	if(istype(ship) && ship_ai?.controller.contact_for(ship_ai, ship))
		return 1
	return ..()

/obj/overmap/entity/virtual_structure/ai/radar_drifters()
	. = ..()
	if(!ship_ai?.sensors_online())
		return
	for(var/id, record in ship_ai.controller.fleet_life[ship_ai.controller.group_key(ship_ai)])
		var/list/point = record
		var/list/local_point = world_to_hull(point[1], point[2])
		. += list(list(local_point[1] - hull_center_x, local_point[2] - hull_center_y, TRUE))
