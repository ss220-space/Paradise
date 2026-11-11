/datum/overmap_admin_panel/proc/galaxy_data()
	var/list/data = list("preview" = SSovermap?.initialized && galaxy_preview ? SSovermap.galaxy_map(null) : null, "systems" = list(), "links" = list(), "pois" = SSovermap?.galaxy_layout?["pois"] || list())
	if(!SSovermap?.initialized)
		return data
	for(var/id, record in SSovermap.galaxy_systems)
		var/list/entry = record
		var/list/serialized = entry.Copy()
		serialized["x"] = entry["x"] / 1000
		serialized["y"] = entry["y"] / 1000
		serialized["transit"] = entry["kind"] == "transit"
		data["systems"] += list(serialized)
	for(var/list/route as anything in SSovermap.build_galaxy_routes(SSovermap.galaxy_layout))
		var/list/source = SSovermap.galaxy_systems[route["from"]]
		var/list/destination = SSovermap.galaxy_systems[route["to"]]
		var/present = FALSE
		var/enabled = TRUE
		var/datum/overmap_sector/sector = SSovermap.sectors[route["from"]]
		for(var/obj/overmap/entity/hyperrelay/relay in sector?.objects)
			if(relay.pair_id != route["id"] || !relay.paired)
				continue
			present = TRUE
			enabled = relay.enabled && relay.paired.enabled
		var/list/style = list()
		for(var/list/segment as anything in SSovermap.galaxy_layout["links"])
			if(segment["id"] in route["segments"])
				for(var/key in list("line", "width", "opacity", "color"))
					style[key] = segment[key]
				break
		data["links"] += list(list("style" = style, "id" = route["id"], "from" = source["name"], "to" = destination["name"], "enabled" = present && enabled, "present" = present))
	return data

/datum/overmap_admin_panel/proc/galaxy_action(action, list/params, mob/user)
	if(!user?.client || !check_rights_for(user.client, R_ADMIN | R_EVENT) || !SSovermap?.initialized)
		return TRUE
	if(!islist(SSovermap.galaxy_layout["pois"]))
		SSovermap.galaxy_layout["pois"] = list()
	galaxy_feedback = null
	galaxy_failed = FALSE
	try
		switch(action)
			if("galaxy_preview")
				galaxy_preview = !galaxy_preview
			if("galaxy_add_sector")
				add_galaxy_sector(params, user)
			if("galaxy_edit_sector")
				edit_galaxy_sector(params, user)
			if("galaxy_add_link")
				add_galaxy_link(params, user)
			if("galaxy_toggle_link")
				toggle_galaxy_link(params["id"], user)
			if("galaxy_add_poi")
				add_galaxy_poi(params, user)
			if("galaxy_edit_link")
				edit_galaxy_link(params, user)
			if("galaxy_edit_poi")
				edit_galaxy_poi(params, user)
			if("galaxy_remove_poi")
				for(var/list/poi as anything in SSovermap.galaxy_layout["pois"])
					if(poi["id"] != params["id"])
						continue
					SSovermap.galaxy_layout["pois"] -= list(poi)
					SSovermap.bump_galaxy()
					log_admin("[key_name(user)] removed galaxy POI [poi["id"]].")
					galaxy_feedback = "Точка интереса удалена."
					break
			if("galaxy_save")
				var/path = "config/overmap_galaxy.json"
				var/temporary_path = "[path].tmp"
				SSovermap.build_galaxy_routes(SSovermap.galaxy_layout)
				rustlib_file_write(json_encode(SSovermap.galaxy_layout), temporary_path)
				if(!fcopy(temporary_path, path))
					throw EXCEPTION("Не удалось сохранить конфигурацию.")
				fdel(temporary_path)
				log_admin("[key_name(user)] saved the live galaxy to [path].")
				galaxy_feedback = "Галактика сохранена для следующих запусков."
	catch(var/exception/error)
		galaxy_failed = TRUE
		galaxy_feedback = "[error]"
	return TRUE

/datum/overmap_admin_panel/proc/galaxy_coordinate(value)
	var/number = isnum(value) ? value : text2num(value)
	if(!isnum(number) || !(abs(number) <= 100))
		throw EXCEPTION("Координаты должны быть от -100 до 100 световых лет.")
	return number * 1000

/datum/overmap_admin_panel/proc/galaxy_label(value)
	if(!istext(value))
		throw EXCEPTION("Укажите название.")
	var/label = trim(strip_html(value, MAX_NAME_LEN))
	if(!length(label))
		throw EXCEPTION("Укажите название.")
	return label

/datum/overmap_admin_panel/proc/galaxy_id(prefix)
	var/index = SSovermap.galaxy_revision + 1
	var/id = "[prefix]_[index]"
	var/list/used = list()
	for(var/key in SSovermap.galaxy_systems)
		used[key] = TRUE
	for(var/list/entry as anything in SSovermap.galaxy_layout["links"])
		used[entry["id"]] = TRUE
	for(var/list/entry as anything in SSovermap.galaxy_layout["pois"])
		used[entry["id"]] = TRUE
	while(used[id])
		id = "[prefix]_[++index]"
	return id

/datum/overmap_admin_panel/proc/add_galaxy_sector(list/params, mob/user)
	if(length(SSovermap.galaxy_systems) >= 256)
		throw EXCEPTION("Достигнут предел: 256 секторов.")
	var/list/entry = list("id" = galaxy_id("sector"), "name" = galaxy_label(params["name"]), "x" = galaxy_coordinate(params["x"]), "y" = galaxy_coordinate(params["y"]), "kind" = "wilderness", "description" = "TEMP123TEMP")
	entry["marker"] = galaxy_marker(params["marker"])
	for(var/id, record in SSovermap.galaxy_systems)
		var/list/other = record
		if(other["x"] == entry["x"] && other["y"] == entry["y"])
			throw EXCEPTION("В этих координатах уже есть сектор.")
	var/datum/overmap_sector/sector = SSovermap.create_galaxy_sector(entry)
	if(!sector?.reservation)
		throw EXCEPTION("Не удалось выделить карту сектора.")
	SSovermap.sectors[sector.id] = sector
	SSovermap.sector_order |= sector
	SSovermap.galaxy_systems[sector.id] = entry
	SSovermap.galaxy_layout["systems"] += list(entry)
	SSovermap.bump_galaxy()
	galaxy_feedback = "Сектор создан: [sector.name]. Размер совпадает со станционным сектором."
	log_admin("[key_name(user)] created galaxy sector [sector.id] at [entry["x"]], [entry["y"]].")

/datum/overmap_admin_panel/proc/edit_galaxy_sector(list/params, mob/user)
	var/list/entry = SSovermap.galaxy_systems[params["id"]]
	if(!entry || entry["kind"] == "transit")
		throw EXCEPTION("Выберите обычный сектор.")
	var/new_name = galaxy_label(params["name"])
	var/list/marker = galaxy_marker(params["marker"])
	var/x = galaxy_coordinate(params["x"])
	var/y = galaxy_coordinate(params["y"])
	for(var/id, record in SSovermap.galaxy_systems)
		var/list/other = record
		if(other != entry && other["x"] == x && other["y"] == y)
			throw EXCEPTION("В этих координатах уже есть сектор.")
	if(entry["x"] != x || entry["y"] != y)
		SSovermap.move_galaxy_system(entry, x, y)
	entry["name"] = new_name
	entry["marker"] = marker
	var/datum/overmap_sector/sector = SSovermap.sectors[entry["id"]]
	sector.name = new_name
	sector.map_area.name = "Overmap - [new_name]"
	for(var/obj/overmap/entity/hyperrelay/relay as anything in SSovermap.vessels)
		if(istype(relay) && relay.paired?.sector == sector)
			relay.update_destination_name()
	SSovermap.bump_galaxy()
	galaxy_feedback = "Сектор обновлён."
	log_admin("[key_name(user)] edited galaxy sector [entry["id"]]: [new_name] at [x], [y].")

/datum/overmap_admin_panel/proc/add_galaxy_link(list/params, mob/user)
	if(length(SSovermap.galaxy_layout["links"]) >= 256)
		throw EXCEPTION("Достигнут предел: 256 связей.")
	var/from_id = params["from"]
	var/to_id = params["to"]
	if(from_id == to_id || !SSovermap.sectors[from_id] || !SSovermap.sectors[to_id])
		throw EXCEPTION("Выберите два разных обычных сектора.")
	for(var/list/route as anything in SSovermap.build_galaxy_routes(SSovermap.galaxy_layout))
		if((route["from"] == from_id && route["to"] == to_id) || (route["from"] == to_id && route["to"] == from_id))
			throw EXCEPTION("Между этими секторами уже есть маршрут.")
	var/list/link = list("id" = galaxy_id("link"), "from" = from_id, "to" = to_id, "state" = "active", "access" = params["restricted"] ? "restricted" : "public", "color" = "#b98cfa")
	SSovermap.galaxy_layout["links"] += list(link)
	var/list/pair
	try
		for(var/list/route as anything in SSovermap.build_galaxy_routes(SSovermap.galaxy_layout))
			if(route["id"] == link["id"])
				pair = SSovermap.spawn_galaxy_link(route)
	catch(var/exception/error)
		SSovermap.galaxy_layout["links"] -= list(link)
		throw error
	if(!length(pair))
		SSovermap.galaxy_layout["links"] -= list(link)
		throw EXCEPTION("Нет свободного места для гипертрансляторов на краях секторов.")
	SSovermap.bump_galaxy()
	galaxy_feedback = "Связь создана; гипертрансляторы размещены по направлению маршрута."
	log_admin("[key_name(user)] connected galaxy sectors [from_id] and [to_id].")

/datum/overmap_admin_panel/proc/toggle_galaxy_link(id, mob/user)
	var/list/chosen
	for(var/list/route as anything in SSovermap.build_galaxy_routes(SSovermap.galaxy_layout))
		if(route["id"] == id)
			chosen = route
	if(!chosen)
		throw EXCEPTION("Маршрут не найден.")
	var/list/relays = list()
	var/enabled = TRUE
	var/datum/overmap_sector/sector = SSovermap.sectors[chosen["from"]]
	for(var/obj/overmap/entity/hyperrelay/relay in sector.objects)
		if(relay.pair_id == id && relay.paired)
			relays |= relay
			relays |= relay.paired
			enabled = relay.enabled && relay.paired.enabled
	if(length(relays) != 2)
		throw EXCEPTION("Для маршрута не найдена пара гипертрансляторов.")
	for(var/obj/overmap/entity/hyperrelay/relay as anything in relays)
		relay.set_enabled(!enabled)
	for(var/list/link as anything in SSovermap.galaxy_layout["links"])
		if(link["id"] in chosen["segments"])
			link["state"] = enabled ? "closed" : "active"
	SSovermap.bump_galaxy()
	galaxy_feedback = enabled ? "Маршрут отключён с обеих сторон." : "Маршрут включён с обеих сторон."
	log_admin("[key_name(user)] set galaxy route [id] to [enabled ? "closed" : "active"].")

/datum/overmap_admin_panel/proc/add_galaxy_poi(list/params, mob/user)
	if(length(SSovermap.galaxy_layout["pois"]) >= 256)
		throw EXCEPTION("Достигнут предел: 256 точек интереса.")
	var/list/poi = list("id" = galaxy_id("poi"), "name" = galaxy_label(params["name"]), "x" = galaxy_coordinate(params["x"]), "y" = galaxy_coordinate(params["y"]), "kind" = "landmark", "color" = "#f2d681", "description" = "TEMP123TEMP")
	poi["marker"] = galaxy_marker(params["marker"])
	SSovermap.galaxy_layout["pois"] += list(poi)
	SSovermap.bump_galaxy()
	galaxy_feedback = "Точка интереса добавлена."
	log_admin("[key_name(user)] added galaxy POI [poi["id"]].")

/datum/overmap_admin_panel/proc/galaxy_number(value, minimum, maximum)
	if(!isnum(value) || !(value >= minimum && value <= maximum))
		throw EXCEPTION("Параметр должен быть от [minimum] до [maximum].")
	return value

/datum/overmap_admin_panel/proc/galaxy_color(value)
	var/static/regex/color_pattern = regex("^#\[0-9a-fA-F\]{6}$")
	if(!istext(value) || !color_pattern.Find(value))
		throw EXCEPTION("Укажите цвет в формате #RRGGBB.")
	return value

/datum/overmap_admin_panel/proc/galaxy_marker(list/supplied)
	var/list/marker = list("shape" = "circle")
	if(isnull(supplied))
		return null
	if(!islist(supplied))
		throw EXCEPTION("Некорректные параметры обозначения.")
	if("shape" in supplied)
		if(!(supplied["shape"] in list("circle", "ring", "square", "diamond", "triangle", "cross", "star")))
			throw EXCEPTION("Неизвестная форма обозначения.")
		marker["shape"] = supplied["shape"]
	for(var/key in list("color", "fill", "labelColor"))
		if(key in supplied)
			marker[key] = galaxy_color(supplied[key])
	var/list/ranges = list("size" = list(1, 40), "width" = list(0.5, 8), "opacity" = list(0, 1), "rotation" = list(-360, 360), "labelSize" = list(6, 32), "labelX" = list(-200, 200), "labelY" = list(-200, 200), "imageSize" = list(8, 160))
	for(var/key in ranges)
		if(key in supplied)
			var/list/bounds = ranges[key]
			marker[key] = galaxy_number(supplied[key], bounds[1], bounds[2])
	if("showLabel" in supplied)
		marker["showLabel"] = !!supplied["showLabel"]
	if(supplied["image"])
		var/picture = supplied["image"]
		var/static/regex/image_pattern = regex("^data:image/(png|jpeg|webp);base64,\[A-Za-z0-9+/=\]+$")
		if(!istext(picture) || length(picture) > 700000 || !image_pattern.Find(picture))
			throw EXCEPTION("Изображение: PNG, JPEG или WebP до 512 КиБ.")
		marker["image"] = picture
	return marker

/datum/overmap_admin_panel/proc/edit_galaxy_link(list/params, mob/user)
	var/line = params["line"]
	if(!(line in list("solid", "dashed", "dotted", "dash-dot")))
		throw EXCEPTION("Неизвестный тип линии.")
	var/tint = galaxy_color(params["color"])
	var/width = galaxy_number(params["width"], 0.5, 8)
	var/opacity = galaxy_number(params["opacity"], 0, 1)
	var/list/chosen
	for(var/list/route as anything in SSovermap.build_galaxy_routes(SSovermap.galaxy_layout))
		if(route["id"] == params["id"])
			chosen = route
	if(!chosen)
		throw EXCEPTION("Связь не найдена.")
	for(var/list/link as anything in SSovermap.galaxy_layout["links"])
		if(link["id"] in chosen["segments"])
			link["line"] = line
			link["color"] = tint
			link["width"] = width
			link["opacity"] = opacity
	SSovermap.bump_galaxy()
	galaxy_feedback = "Оформление связи обновлено."
	log_admin("[key_name(user)] restyled galaxy route [params["id"]].")

/datum/overmap_admin_panel/proc/edit_galaxy_poi(list/params, mob/user)
	var/new_name = galaxy_label(params["name"])
	var/x = galaxy_coordinate(params["x"])
	var/y = galaxy_coordinate(params["y"])
	var/list/marker = galaxy_marker(params["marker"])
	for(var/list/poi as anything in SSovermap.galaxy_layout["pois"])
		if(poi["id"] != params["id"])
			continue
		poi["name"] = new_name
		poi["x"] = x
		poi["y"] = y
		poi["marker"] = marker
		SSovermap.bump_galaxy()
		galaxy_feedback = "Точка интереса обновлена."
		log_admin("[key_name(user)] edited galaxy POI [poi["id"]].")
		return
	throw EXCEPTION("Точка интереса не найдена.")
