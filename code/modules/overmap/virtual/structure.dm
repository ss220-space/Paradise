GLOBAL_LIST_EMPTY(overmap_virtual_structures)

/datum/overmap_virtual_model
	var/mutable_appearance/visual
	var/solid = FALSE
	var/health = 100
	var/visible = FALSE
	var/thrust = 0
	var/list/identity
	var/list/weapons = list()

/datum/overmap_virtual_model/New(text)
	var/list/objects = list()
	var/index = 1
	var/delimiter
	do
		delimiter = GLOB.maploader.find_next_delimiter_position(text, index, ",", "{", "}")
		var/definition = GLOB.maploader.trim_text(copytext(text, index, delimiter))
		var/variables = findtext(definition, "{")
		var/path = text2path(GLOB.maploader.trim_text(copytext(definition, 1, variables)))
		index = delimiter + 1
		if(!ispath(path, /atom) || ispath(path, /area) || ispath(path, /obj/effect) || ispath(path, /mob))
			continue
		var/atom/prototype = path
		var/list/attributes = variables ? GLOB.maploader.readlist(copytext(definition, variables + 1, length(definition)), ";") : list()
		if(ispath(path, /obj/machinery/porta_turret) || ispath(path, /obj/machinery/bsa/portable) || ispath(path, /obj/machinery/bsa/full))
			weapons += list(list(path, attributes))
		var/dense = isnull(attributes["density"]) ? initial(prototype.density) : attributes["density"]
		solid ||= dense
		if(dense && ispath(path, /turf/simulated/wall))
			var/turf/simulated/wall/wall = path
			health = initial(wall.damage_cap)
		if(ispath(path, /turf/space) || ispath(path, /turf/template_noop))
			continue
		visible = TRUE
		var/mutable_appearance/picture = mutable_appearance(attributes["icon"] || initial(prototype.icon), isnull(attributes["icon_state"]) ? initial(prototype.icon_state) : attributes["icon_state"])
		picture.dir = attributes["dir"] || initial(prototype.dir)
		picture.pixel_x = isnull(attributes["pixel_x"]) ? initial(prototype.pixel_x) : attributes["pixel_x"]
		picture.pixel_y = isnull(attributes["pixel_y"]) ? initial(prototype.pixel_y) : attributes["pixel_y"]
		picture.layer = initial(prototype.layer)
		picture.color = attributes["color"] || initial(prototype.color)
		picture.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		if(ispath(path, /turf))
			visual = picture
		else
			objects += picture
		if(ispath(path, /obj/machinery/ship_engine))
			var/obj/machinery/ship_engine/engine = path
			thrust += isnull(attributes["generated_thrust"]) ? initial(engine.generated_thrust) : attributes["generated_thrust"]
		if(ispath(path, /obj/machinery/transponder))
			var/obj/machinery/transponder/beacon = path
			identity = list("name" = attributes["broadcast_name"] || initial(beacon.broadcast_name), "color" = attributes["broadcast_color"] || initial(beacon.broadcast_color), "broadcasting" = isnull(attributes["broadcasting"]) ? initial(beacon.broadcasting) : attributes["broadcasting"])
	while(delimiter)
	visual = visual || mutable_appearance()
	visual.appearance_flags |= KEEP_TOGETHER
	visual.overlays += objects

/obj/overmap/entity/virtual_structure
	name = "virtual structure"
	movable = FALSE
	halted = TRUE
	var/list/virtual_cells = list()
	var/list/virtual_models = list()
	var/shape_dirty = FALSE
	var/shape_refresh_at = 0
	var/list/virtual_weapons = list()
	var/list/collision_edge
	var/collision_edge_version = -1

/obj/overmap/entity/virtual_structure/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)

/obj/overmap/entity/virtual_structure/Initialize(mapload)
	. = ..()
	GLOB.overmap_virtual_structures += src

/obj/overmap/entity/virtual_structure/Destroy()
	GLOB.overmap_virtual_structures -= src
	QDEL_LIST(virtual_weapons)
	QDEL_LIST_ASSOC_VAL(virtual_models)
	return ..()

/obj/overmap/entity/virtual_structure/proc/load_template(datum/map_template/template, flying)
	if(!template || template.width > 256 || template.height > 256)
		return FALSE
	var/data = template.mapfile ? WRAP_FILE2TEXT(template.mapfile) : mapmanip_read_dmm(template.mappath)
	if(!istext(data))
		return FALSE
	var/key_length = 0
	var/index = 1
	var/thrust = 0
	radar_shape = null
	var/list/shape = list()
	hull_center_x = (template.width + 1) / 2
	hull_center_y = (template.height + 1) / 2
	while(GLOB.maploader.dmmRegex.Find(data, index))
		index = GLOB.maploader.dmmRegex.next
		var/list/match = GLOB.maploader.dmmRegex.group.Copy()
		if(match[1])
			key_length = length(match[1])
			virtual_models[match[1]] = new /datum/overmap_virtual_model(match[2])
		else if(match[3] && key_length && text2num(match[5]) == 1)
			var/x_start = text2num(match[3])
			var/y_start = text2num(match[4])
			var/list/lines = splittext(trim(match[6]), "\n")
			var/y = y_start + length(lines) - 1
			for(var/line in lines)
				var/x = x_start
				for(var/column in 1 to length(line) step key_length)
					var/datum/overmap_virtual_model/model = virtual_models[copytext(line, column, column + key_length)]
					if(model?.visible)
						virtual_cells["[x],[y]"] = list(x, y, model, model.health)
						shape += list((x - hull_center_x) * 2, (y - hull_center_y) * 2)
						thrust += model.thrust
						for(var/list/spec as anything in model.weapons)
							add_virtual_weapon(spec, x, y)
						if(model.identity)
							identity_name = model.identity["name"] || template.name
							identity_color = model.identity["color"]
							identity_broadcasting = model.identity["broadcasting"]
					x++
				y--
				CHECK_TICK
		CHECK_TICK
	if(!length(virtual_cells))
		return FALSE
	name = template.name
	identity_name = identity_name || name
	rebuild_identity_iff()
	hull_radius = sqrt(template.width ** 2 + template.height ** 2) / 2
	hull_inertia = max(1, (template.width ** 2 + template.height ** 2) / 12)
	radar_shape = list("tiles" = shape, "collars" = list())
	vessel_mass = (OVERMAP_MASS_BASE + length(virtual_cells) * OVERMAP_MASS_PER_TURF) * (flying ? OVERMAP_DYNAMIC_MASS_MULTIPLIER : 1)
	overmap_kind = flying ? OVERMAP_KIND_SHUTTLE : OVERMAP_KIND_RUIN
	movable = flying
	halted = !flying
	if(flying)
		AddComponent(/datum/component/overmap_flight)
		admin_virtual_engine = TRUE
		ensure_virtual_engine()
		if(thrust > 0)
			virtual_engine.generated_thrust = thrust
	free_flight_view = TRUE
	hull_dirty = FALSE
	return TRUE

/obj/overmap/entity/virtual_structure/proc/cell_at(world_x, world_y, solid_only = FALSE, list/pose)
	var/list/point = pose ? world_to_hull(world_x, world_y, pose[1], pose[2], pose[3]) : world_to_hull(world_x, world_y)
	var/list/cell = virtual_cells["[FLOOR(point[1] + 0.5, 1)],[FLOOR(point[2] + 0.5, 1)]"]
	if(!cell || cell[4] <= 0)
		return null
	var/datum/overmap_virtual_model/model = cell[3]
	return !solid_only || model.solid ? cell : null

/obj/overmap/entity/virtual_structure/proc/damage_cell(list/cell, damage)
	cell[4] = max(0, cell[4] - damage)
	if(cell[4] <= 0)
		hull_version++
		shape_dirty = TRUE
		for(var/obj/machinery/gun as anything in virtual_weapons.Copy())
			if(gun.virtual_weapon_x == cell[1] && gun.virtual_weapon_y == cell[2])
				virtual_weapons -= gun
				qdel(gun)

/obj/overmap/entity/virtual_structure/proc/add_virtual_weapon(list/spec, x, y)
	var/path = spec[1]
	if(ispath(path, /obj/machinery/bsa/full))
		path = /obj/machinery/bsa/full/ship
	var/list/attributes = spec[2]
	var/obj/machinery/gun = new path(null)
	gun.virtual_weapon_owner = src
	gun.virtual_weapon_x = x
	gun.virtual_weapon_y = y
	gun.use_power = NO_POWER_USE
	gun.stat &= ~NOPOWER
	for(var/key in list("dir", "enabled", "lethal", "projectile", "eprojectile", "shot_delay"))
		if((key in attributes) && (key in gun.vars)
			gun.vars[key] = attributes[key]
	var/datum/component/ship_weapon/weapon = gun.GetComponent(/datum/component/ship_weapon)
	if(weapon)
		weapon.mount_dir = gun.dir
	virtual_weapons += gun

/obj/overmap/entity/virtual_structure/keep_inside_local_space()
	QDEL_NULL(dock_host)
	if(physical_space?.host == src)
		QDEL_NULL(physical_space)
	return ..()

/obj/overmap/entity/virtual_structure/create_hull_proxy(turf/viewer_turf, glowing = FALSE)
	return new /datum/hull_proxy/virtual(src, viewer_turf)

/obj/overmap/entity/virtual_structure/in_free_flight()
	return TRUE

/obj/overmap/entity/virtual_structure/remap_hull()
	return

/obj/overmap/entity/virtual_structure/process_scatter(elapsed)
	if(movable)
		..()
	if(!shape_dirty || world.time < shape_refresh_at)
		return
	shape_dirty = FALSE
	shape_refresh_at = world.time + OVERMAP_SLOW_TICK
	radar_shape = list("tiles" = list(), "collars" = list())
	for(var/key in virtual_cells)
		var/list/cell = virtual_cells[key]
		if(cell[4] > 0)
			radar_shape["tiles"] += list((cell[1] - hull_center_x) * 2, (cell[2] - hull_center_y) * 2)

/obj/overmap/entity/virtual_structure/radar_extent()
	return list(hull_radius * 2, hull_radius * 2)

/datum/hull_proxy/virtual/New(obj/overmap/entity/virtual_structure/vessel, turf/viewer_turf)
	src.vessel = vessel
	src.viewer_turf = viewer_turf
	rebuild_tiles()
	RegisterSignal(vessel, COMSIG_QDELETING, PROC_REF(on_vessel_deleted))

/datum/hull_proxy/virtual/Destroy(force)
	QDEL_LIST_ASSOC_VAL(tiles_by_turf)
	return ..()

/datum/hull_proxy/virtual/rebuild_tiles()
	return

/datum/hull_proxy/virtual/place(new_center_x, new_center_y, new_z, new_heading, list/bounds, time)
	var/obj/overmap/entity/virtual_structure/structure = vessel
	var/cosine = cos(new_heading)
	var/sine = sin(new_heading)
	var/list/wanted = list()
	for(var/client/viewer as anything in SSovermap.client_eyes)
		var/turf/eye = get_turf(viewer.eye || viewer.mob)
		if(eye?.z != new_z)
			continue
		var/dx = eye.x - new_center_x
		var/dy = eye.y - new_center_y
		var/local_x = vessel.hull_center_x + dx * cosine - dy * sine
		var/local_y = vessel.hull_center_y + dx * sine + dy * cosine
		var/reach = CEILING(((viewer.maxview() || world.view) + 3) * 1.42, 1)
		for(var/ix in FLOOR(local_x - reach, 1) to CEILING(local_x + reach, 1))
			for(var/iy in FLOOR(local_y - reach, 1) to CEILING(local_y + reach, 1))
				var/key = "[ix],[iy]"
				var/list/cell = structure.virtual_cells[key]
				if(cell && cell[4] > 0)
					wanted[key] = cell
	var/matrix/turned = matrix()
	turned.Scale(OVERMAP_TERRAIN_SEAM_SCALE)
	turned.Turn(new_heading)
	for(var/key in wanted)
		var/list/cell = wanted[key]
		var/obj/effect/abstract/hull_proxy_tile/tile = tiles_by_turf[key]
		var/fresh = !tile
		if(fresh)
			var/datum/overmap_virtual_model/model = cell[3]
			tile = new(null)
			tile.appearance = model.visual
			tile.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			SET_PLANE_EXPLICIT(tile, GAME_PLANE, viewer_turf)
			tiles_by_turf[key] = tile
		var/dx = cell[1] - vessel.hull_center_x
		var/dy = cell[2] - vessel.hull_center_y
		tile.glide(new_center_x + dx * cosine + dy * sine, new_center_y + dy * cosine - dx * sine, new_z, turned, bounds, fresh ? 0 : time)
	for(var/key in tiles_by_turf.Copy())
		if(!wanted[key])
			qdel(tiles_by_turf[key])
			tiles_by_turf -= key
