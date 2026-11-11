/datum/overmap_virtual_model
	var/mutable_appearance/visual
	var/solid = FALSE
	var/opaque = FALSE
	var/health = 100
	var/visible = FALSE
	var/thrust = 0
	var/list/identity
	var/list/weapons = list()
	var/warp_portal = FALSE
	var/mutable_appearance/warp_visual

/datum/overmap_virtual_model/Destroy()
	visual = null
	warp_visual = null
	identity = null
	weapons = null
	return ..()

/datum/overmap_virtual_model/New(text)
	var/list/objects = list()
	var/index = 1
	var/delimiter
	do
		delimiter = GLOB.maploader.find_next_delimiter_position(text, index, ",", "{", "}")
		var/definition = GLOB.maploader.trim_text(copytext(text, index, delimiter))
		var/variables = findtext(definition, "{")
		var/path_text = GLOB.maploader.trim_text(copytext(definition, 1, variables))
		path_text = replacetext(path_text, "/obj/machinery/ship_gun/monofrontier/", "/obj/machinery/ship_gun/")
		path_text = replacetext(path_text, "/obj/machinery/porta_turret/syndicate/ship/monofrontier/", "/obj/machinery/porta_turret/syndicate/ship/")
		var/path = text2path(path_text)
		index = delimiter + 1
		if(ispath(path, /obj/effect/overmap_warp_portal))
			warp_portal = TRUE
			visible = TRUE
			warp_visual = mutable_appearance('icons/obj/stationobjs.dmi', "portal")
			warp_visual.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			warp_visual.layer = HIGH_OBJ_LAYER
			continue
		if(!ispath(path, /atom) || ispath(path, /area) || ispath(path, /obj/effect) || ispath(path, /mob))
			continue
		var/atom/prototype = path
		var/list/attributes = variables ? GLOB.maploader.readlist(copytext(definition, variables + 1, length(definition)), ";") : list()
		if(ispath(path, /obj/machinery/ship_gun) || ispath(path, /obj/machinery/porta_turret) || ispath(path, /obj/machinery/bsa/portable) || ispath(path, /obj/machinery/bsa/full))
			weapons += list(list(path, attributes))
		var/dense = isnull(attributes["density"]) ? initial(prototype.density) : attributes["density"]
		solid ||= dense
		opaque ||= isnull(attributes["opacity"]) ? initial(prototype.opacity) : attributes["opacity"]
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

/datum/hull_proxy/virtual
	copy_lighting = FALSE

/datum/hull_proxy/virtual/create_fog()
	return new /datum/fog_scene/projected(round(vessel.hull_radius) + OVERMAP_FOG_HULL_REACH)

/datum/hull_proxy/virtual/Destroy(force)
	QDEL_LIST_ASSOC_VAL(tiles_by_turf)
	return ..()

/datum/hull_proxy/virtual/rebuild_tiles()
	var/obj/overmap/entity/virtual_structure/structure = vessel
	var/datum/fog_scene/projected/projected = fog
	projected.opaque_chunks = list()
	for(var/key, cell_entry in structure.virtual_cells)
		var/list/cell = cell_entry
		var/datum/overmap_virtual_model/model = cell[3]
		if(cell[4] > 0 && model.opaque)
			projected.add_opaque_point(cell)
	mapped_hull_version = vessel.hull_version
	fog.mark_dirty()

/datum/hull_proxy/virtual/place(new_center_x, new_center_y, new_z, new_heading, list/bounds, time)
	update_fog(new_center_x, new_center_y, new_z, new_heading)
	center_x = new_center_x
	center_y = new_center_y
	proxy_z = new_z
	heading = new_heading
	var/obj/overmap/entity/virtual_structure/structure = vessel
	var/datum/fog_scene/projected/projected = fog
	projected.drawn = list()
	projected.source_positions = list()
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
			fog.mark_dirty()
		else
			var/datum/overmap_virtual_model/model = cell[3]
			if(model.warp_portal)
				tile.appearance = model.visual
				tile.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
				SET_PLANE_EXPLICIT(tile, GAME_PLANE, viewer_turf)
		projected.drawn[tile] = tile
		projected.source_positions[tile] = cell
		var/dx = cell[1] - vessel.hull_center_x
		var/dy = cell[2] - vessel.hull_center_y
		tile.glide(new_center_x + dx * cosine + dy * sine, new_center_y + dy * cosine - dx * sine, new_z, turned, bounds, fresh ? 0 : time)
	for(var/key in tiles_by_turf)
		if(!wanted[key])
			qdel(tiles_by_turf[key])
			tiles_by_turf -= key
			fog.mark_dirty()
