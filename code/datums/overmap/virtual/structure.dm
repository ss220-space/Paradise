/datum/overmap_virtual_model
	var/turf_type
	var/ship_name
	var/ship_faction
	var/ship_class
	var/mutable_appearance/visual
	var/solid = FALSE
	var/opaque = FALSE
	var/health = 100
	var/visible = FALSE
	var/list/engines = list()
	var/list/identity
	var/list/weapons = list()
	var/warp_portal = FALSE
	var/mutable_appearance/warp_visual

/datum/overmap_virtual_model/Destroy()
	visual = null
	warp_visual = null
	identity = null
	weapons = null
	engines = null
	return ..()

/datum/overmap_virtual_model/New(text, closed_blastdoors = FALSE)
	var/list/objects = list()
	var/index = 1
	var/delimiter
	do
		delimiter = GLOB.maploader.find_next_delimiter_position(text, index, ",", "{", "}")
		var/definition = GLOB.maploader.trim_text(copytext(text, index, delimiter))
		var/variables = findtext(definition, "{")
		var/path_text = GLOB.maploader.trim_text(copytext(definition, 1, variables))
		var/path = text2path(path_text)
		index = delimiter + 1
		if(ispath(path, /obj/effect/overmap_warp_portal))
			warp_portal = TRUE
			visible = TRUE
			warp_visual = mutable_appearance('icons/obj/stationobjs.dmi', "portal")
			warp_visual.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			warp_visual.layer = HIGH_OBJ_LAYER
			continue
		if(ispath(path, /area/shuttle))
			var/area/shuttle/ship_area = path
			var/list/area_attributes = variables ? GLOB.maploader.readlist(copytext(definition, variables + 1, length(definition)), ";") : list()
			ship_name = area_attributes["overmap_ship_name"] || initial(ship_area.overmap_ship_name) || ship_name
			ship_faction = area_attributes["overmap_ship_faction"] || initial(ship_area.overmap_ship_faction) || ship_faction
			ship_class = area_attributes["overmap_ship_class"] || initial(ship_area.overmap_ship_class) || ship_class
		if(!ispath(path, /atom) || ispath(path, /area) || ispath(path, /obj/effect) || ispath(path, /mob))
			continue
		var/atom/prototype = path
		var/list/attributes = variables ? GLOB.maploader.readlist(copytext(definition, variables + 1, length(definition)), ";") : list()
		if(closed_blastdoors && ispath(path, /obj/machinery/door/poddoor))
			attributes["density"] = TRUE
			attributes["opacity"] = TRUE
			attributes["icon_state"] = "closed"
		if(ispath(path, /obj/machinery/ship_gun) || ispath(path, /obj/machinery/porta_turret) || ispath(path, /obj/machinery/bsa/portable) || ispath(path, /obj/machinery/bsa/full))
			weapons += list(list(path, attributes))
		var/dense = isnull(attributes["density"]) ? initial(prototype.density) : attributes["density"]
		solid ||= dense
		opaque ||= isnull(attributes["opacity"]) ? initial(prototype.opacity) : attributes["opacity"]
		if(dense && ispath(path, /turf/simulated/wall))
			var/turf/simulated/wall/wall = path
			health = initial(wall.damage_cap)
		if(ispath(path, /turf))
			turf_type = path
		if(ispath(path, /obj/machinery/door/poddoor/shuttle))
			var/obj/machinery/door/poddoor/shuttle/door = path
			health = initial(door.max_integrity)
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
			engines += list(list(path, attributes))
		if(ispath(path, /obj/machinery/transponder))
			var/obj/machinery/transponder/beacon = path
			identity = list("name" = attributes["broadcast_name"] || initial(beacon.broadcast_name), "color" = attributes["broadcast_color"] || initial(beacon.broadcast_color), "broadcasting" = isnull(attributes["broadcasting"]) ? initial(beacon.broadcasting) : attributes["broadcasting"])
	while(delimiter)
	visual = visual || mutable_appearance()
	visual.appearance_flags |= KEEP_TOGETHER
	visual.overlays += objects
