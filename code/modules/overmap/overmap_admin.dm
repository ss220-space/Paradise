/datum/overmap_admin_panel
	var/obj/overmap/selected
	var/picking = FALSE
	var/pick_for_dump = FALSE
	var/filter_name = ""
	var/filter_sector = ""
	var/filter_x
	var/filter_y
	var/filter_docked = FALSE
	var/list/dump_uids
	var/list/obj/machinery/computer/helm/admin/open_helms
	var/datum/map_template/uploaded_template

/datum/overmap_admin_panel/New()
	dump_uids = list()
	open_helms = list()

/datum/overmap_admin_panel/Destroy()
	selected = null
	open_helms = null
	dump_uids = null
	QDEL_NULL(uploaded_template)
	return ..()

/datum/overmap_admin_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN | R_EVENT)

/datum/overmap_admin_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapAdmin", "Овермап")
		ui.open()

/datum/overmap_admin_panel/ui_data(mob/user)
	var/list/data = list()
	data["picking"] = picking
	data["pick_for_dump"] = pick_for_dump
	data["filter_name"] = filter_name
	data["filter_sector"] = filter_sector
	data["filter_x"] = filter_x
	data["filter_y"] = filter_y
	data["filter_docked"] = filter_docked
	if(picking)
		data["candidates"] = collect_candidates()
	data["selected"] = serialize_token(selected)
	data["dump_list"] = serialize_dump_list()
	data["consoles"] = serialize_sensor_consoles()
	data["uploaded_dmm"] = uploaded_template?.name
	data["uploaded_w"] = uploaded_template?.width
	data["uploaded_h"] = uploaded_template?.height
	data["pool_medium"] = length(SSovermap?.pooled_medium_cells)
	data["pool_large"] = length(SSovermap?.pooled_large_cells)
	var/datum/overmap_sector/hint_sector = SSovermap?.local_sector
	if(hint_sector)
		var/turf/hint = hint_sector.get_nearest_open_turf(round(hint_sector.size / 2), round(hint_sector.size / 2))
		data["suggest_x"] = hint ? hint_sector.coord_x(hint) : round(hint_sector.size / 2)
		data["suggest_y"] = hint ? hint_sector.coord_y(hint) : round(hint_sector.size / 2)
		data["suggest_sector"] = hint_sector.id
	data["iff_centcom"] = SSovermap?.iff_key_centcom
	data["iff_syndicate"] = SSovermap?.iff_key_syndicate
	data["transponders"] = serialize_transponders()
	data["comms"] = serialize_comms()
	return data

/datum/overmap_admin_panel/ui_static_data(mob/user)
	var/list/data = list()
	data["sectors"] = serialize_sectors()
	data["icon_file"] = "[OVERMAP_ICON_FILE]"
	var/list/states = list()
	for(var/state in (icon_states_fast(OVERMAP_ICON_FILE) || list()))
		states += "[state]"
	data["icons"] = states
	data["hazard_types"] = serialize_hazard_types()
	data["spawn_types"] = serialize_spawn_types()
	data["templates"] = serialize_templates()
	return data

/datum/overmap_admin_panel/proc/all_tokens()
	. = list()
	if(!SSovermap)
		return
	for(var/sector_id in SSovermap.sectors)
		var/datum/overmap_sector/sector = SSovermap.sectors[sector_id]
		if(QDELETED(sector))
			continue
		for(var/obj/overmap/token as anything in sector.objects)
			if(!QDELETED(token))
				. |= token
	for(var/obj/overmap/entity/vessel as anything in SSovermap.vessels)
		if(!QDELETED(vessel))
			. |= vessel
	for(var/obj/overmap/feature/hazard/hazard as anything in SSovermap.hazards)
		if(!QDELETED(hazard))
			. |= hazard

/datum/overmap_admin_panel/proc/token_docked(obj/overmap/token)
	if(!token)
		return FALSE
	if(!isturf(token.loc))
		return TRUE
	var/obj/overmap/entity/vessel = token
	return istype(vessel) && vessel.status == OVERMAP_STATUS_DOCKED

/datum/overmap_admin_panel/proc/matches_filters(obj/overmap/token)
	if(filter_name)
		var/needle = lowertext(filter_name)
		if(!findtext(lowertext(token.name), needle) && !findtext(lowertext(token.get_overmap_display_name()), needle) && !findtext(lowertext("[token.type]"), needle))
			return FALSE
	if(filter_docked && !token_docked(token))
		return FALSE
	if(!filter_docked && filter_sector)
		if(token.sector?.id != filter_sector && token.sector?.name != filter_sector)
			return FALSE
	var/turf/here = token.get_overmap_turf()
	if(!isnull(filter_x) && here && token.sector && token.sector.coord_x(here) != filter_x)
		return FALSE
	if(!isnull(filter_y) && here && token.sector && token.sector.coord_y(here) != filter_y)
		return FALSE
	return TRUE

/datum/overmap_admin_panel/proc/collect_candidates()
	. = list()
	for(var/obj/overmap/token as anything in all_tokens())
		if(!matches_filters(token))
			continue
		. += list(serialize_token(token, TRUE))

/datum/overmap_admin_panel/proc/serialize_token(obj/overmap/token, compact = FALSE)
	if(QDELETED(token))
		return null
	var/turf/here = token.get_overmap_turf()
	var/obj/overmap/entity/vessel = token
	var/list/data = list(
		"uid" = token.UID(),
		"name" = token.name,
		"type" = "[token.type]",
		"kind" = token.overmap_kind,
		"icon" = "[token.icon]",
		"icon_state" = token.icon_state,
		"sector_id" = token.sector?.id,
		"sector_name" = token.sector?.name,
		"x" = token.sector && here ? token.sector.coord_x(here) : here?.x,
		"y" = token.sector && here ? token.sector.coord_y(here) : here?.y,
		"docked" = token_docked(token),
		"nested_in" = istype(vessel) ? vessel.docked_to?.name : null,
	)
	if(compact)
		return data
	data["pos_x"] = token.position[1]
	data["pos_y"] = token.position[2]
	data["speed_x"] = token.speed[1]
	data["speed_y"] = token.speed[2]
	data["movable"] = token.movable
	data["halted"] = token.halted
	data["immune"] = token.overmap_hazard_immune
	data["visible"] = token.visible_without_scanner
	data["hidden"] = token.hidden_from_contacts
	data["wraparound"] = token.wraparound
	data["is_entity"] = istype(vessel)
	data["status"] = istype(vessel) ? vessel.status : null
	data["sensors_on"] = istype(vessel) && (vessel.long_sensors_on || vessel.short_sensors_on)
	data["has_flight"] = istype(vessel) && !!vessel.flight
	return data

/datum/overmap_admin_panel/proc/serialize_dump_list()
	. = list()
	for(var/uid in dump_uids)
		var/obj/overmap/token = locateUID(uid)
		if(QDELETED(token))
			continue
		. += list(serialize_token(token, TRUE))

/datum/overmap_admin_panel/proc/serialize_sensor_consoles()
	. = list()
	for(var/obj/machinery/computer/sensors/console as anything in GLOB.sensor_computers)
		if(QDELETED(console) || istype(console, /obj/machinery/computer/sensors/short_range/pod))
			continue
		. += list(list(
			"uid" = console.UID(),
			"name" = "[console.name] ([get_area_name(console, TRUE) || "без зоны"])",
		))

/datum/overmap_admin_panel/proc/serialize_sectors()
	. = list()
	if(!SSovermap)
		return
	for(var/sector_id in SSovermap.sectors)
		var/datum/overmap_sector/sector = SSovermap.sectors[sector_id]
		if(QDELETED(sector))
			continue
		. += list(list("id" = sector.id, "name" = sector.name, "size" = sector.size))

/datum/overmap_admin_panel/proc/serialize_hazard_types()
	. = list()
	var/obj/overmap/feature/hazard/base_hazard = /obj/overmap/feature/hazard
	. += list(list("path" = "/obj/overmap/feature/hazard", "name" = initial(base_hazard.name)))
	for(var/path in subtypesof(/obj/overmap/feature/hazard))
		var/obj/overmap/feature/hazard/sample = path
		. += list(list("path" = "[path]", "name" = initial(sample.name)))

/datum/overmap_admin_panel/proc/serialize_spawn_types()
	. = list()
	. += list(list("path" = "/obj/overmap/feature", "name" = "Сигнатура / точка", "group" = "token"))
	. += list(list("path" = "/obj/overmap/feature/hazard", "name" = "Угроза (базовая)", "group" = "hazard"))
	for(var/path in subtypesof(/obj/overmap/feature/hazard))
		var/obj/overmap/feature/hazard/sample = path
		. += list(list("path" = "[path]", "name" = initial(sample.name), "group" = "hazard"))
	. += list(list("path" = "/obj/overmap/portal", "name" = "Варп-портал", "group" = "portal"))
	. += list(list("path" = "/obj/overmap/entity/feature/ruin", "name" = "Руина (физическая)", "group" = "ruin"))

/datum/overmap_admin_panel/proc/serialize_templates()
	. = list()
	for(var/template_name in GLOB.map_templates)
		var/datum/map_template/template = GLOB.map_templates[template_name]
		if(!template)
			continue
		. += list(list("id" = template_name, "name" = template.name, "width" = template.width, "height" = template.height, "kind" = "map"))
	for(var/shuttle_id in GLOB.shuttle_templates)
		var/datum/map_template/shuttle/template = GLOB.shuttle_templates[shuttle_id]
		if(!template)
			continue
		. += list(list("id" = shuttle_id, "name" = template.name || shuttle_id, "width" = template.width, "height" = template.height, "kind" = "shuttle"))

/datum/overmap_admin_panel/proc/serialize_transponders()
	. = list()
	for(var/obj/machinery/transponder/beacon as anything in GLOB.transponders)
		if(QDELETED(beacon))
			continue
		beacon.ensure_iff_channels()
		var/list/channels = list()
		for(var/datum/overmap_iff_channel/channel as anything in beacon.iff_channels)
			channels += list(list(
				"id" = channel.id,
				"label" = channel.label,
				"permanent" = channel.permanent,
				"receive" = channel.receive,
				"transmit" = channel.transmit,
			))
		. += list(list(
			"uid" = beacon.UID(),
			"name" = beacon.name,
			"vessel" = beacon.vessel?.name,
			"broadcast_name" = beacon.broadcast_name,
			"broadcasting" = beacon.broadcasting,
			"distress" = beacon.distress,
			"channels" = channels,
		))

/datum/overmap_admin_panel/proc/serialize_comms()
	. = list()
	if(!SSovermap)
		return
	for(var/sector_id in SSovermap.sectors)
		var/datum/overmap_sector/sector = SSovermap.sectors[sector_id]
		if(QDELETED(sector))
			continue
		var/list/messages = list()
		for(var/datum/overmap_sector_message/message as anything in sector.comms_messages)
			messages += list(list(
				"id" = message.id,
				"sender" = message.sender_name,
				"key" = message.encryption_key,
				"text" = message.plaintext,
				"scrambled" = message.scrambled,
			))
		. += list(list(
			"id" = sector.id,
			"name" = sector.name,
			"messages" = messages,
		))

/datum/overmap_admin_panel/proc/resolve_selected(uid)
	if(!uid)
		return selected
	var/obj/overmap/token = locateUID(uid)
	if(istype(token) && !QDELETED(token))
		return token
	return null

/datum/overmap_admin_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("pick_start")
			picking = TRUE
			pick_for_dump = FALSE
			return TRUE
		if("pick_dump_start")
			picking = TRUE
			pick_for_dump = TRUE
			return TRUE
		if("pick_cancel")
			picking = FALSE
			return TRUE
		if("set_filter")
			filter_name = params["name"] || ""
			filter_sector = params["sector"] || ""
			filter_x = params["x"] == "" ? null : text2num(params["x"])
			filter_y = params["y"] == "" ? null : text2num(params["y"])
			filter_docked = truthy(params["docked"])
			return TRUE
		if("pick_token")
			var/obj/overmap/token = resolve_selected(params["uid"])
			if(!token)
				return TRUE
			if(pick_for_dump)
				dump_uids |= token.UID()
			else
				selected = token
				picking = FALSE
			return TRUE
		if("dump_remove")
			dump_uids -= params["uid"]
			return TRUE
		if("dump_clear")
			dump_uids.Cut()
			return TRUE
		if("dump_paper")
			var/obj/item/paper/sheet = new(get_turf(user) || user.loc)
			overmap_write_dump_paper(sheet, dump_uids, "admin")
			if(user.put_in_hands(sheet))
				to_chat(user, span_notice("Дамп ([length(dump_uids)]) выдан."), confidential = TRUE)
			log_admin("[key_name(user)] created an overmap sensor dump paper ([length(dump_uids)] contacts).")
			return TRUE
		if("dump_click")
			if(user.client)
				new /datum/click_intercept/overmap_dump(user.client, dump_uids.Copy())
				to_chat(user, span_notice("Кликните по консоли сенсоров, чтобы загрузить дамп."), confidential = TRUE)
			return TRUE
		if("dump_console")
			var/obj/machinery/computer/sensors/console = locateUID(params["uid"])
			if(!istype(console) || QDELETED(console))
				return TRUE
			apply_dump_to_console(console, user)
			return TRUE
		if("vv")
			var/obj/overmap/token = resolve_selected(params["uid"])
			if(token && user.client)
				user.client.debug_variables(token)
			return TRUE
		if("delete")
			var/obj/overmap/token = resolve_selected(params["uid"])
			if(!token)
				return TRUE
			if(token == SSovermap?.station_entity)
				to_chat(user, span_warning("Станцию удалять нельзя."), confidential = TRUE)
				return TRUE
			log_admin("[key_name(user)] deleted overmap token [token] ([token.type]).")
			if(selected == token)
				selected = null
			qdel(token)
			return TRUE
		if("helm")
			var/obj/overmap/token = resolve_selected(params["uid"])
			if(!token)
				return TRUE
			open_admin_helm(token, user)
			return TRUE
		if("sensors")
			var/obj/overmap/entity/vessel = resolve_selected(params["uid"])
			if(!istype(vessel))
				to_chat(user, span_warning("Сенсоры только у entity-токенов."), confidential = TRUE)
				return TRUE
			if(!vessel.sensor_pack)
				vessel.AddComponent(/datum/component/overmap_sensors)
			vessel.long_sensors_on = TRUE
			vessel.short_sensors_on = TRUE
			if(!vessel.sensor_pack.short_identified)
				vessel.sensor_pack.short_identified = list()
			if(vessel.sector)
				for(var/obj/overmap/other as anything in vessel.sector.objects)
					vessel.sensor_pack.short_identified[other.UID()] = TRUE
			vessel.refresh_sensor_displays()
			log_admin("[key_name(user)] forced sensors on [vessel].")
			return TRUE
		if("set_field")
			var/obj/overmap/token = resolve_selected(params["uid"])
			if(!token)
				return TRUE
			apply_field(token, params["field"], params["value"], user)
			return TRUE
		if("teleport")
			var/obj/overmap/token = resolve_selected(params["uid"])
			if(!token)
				return TRUE
			admin_teleport_token(token, params["sector"], text2num(params["x"]), text2num(params["y"]), user)
			return TRUE
		if("spawn")
			admin_spawn_token(params, user)
			return TRUE
		if("upload_dmm")
			upload_dmm_from_user(user)
			return TRUE
		if("iff_toggle")
			var/obj/machinery/transponder/beacon = locateUID(params["uid"])
			if(!istype(beacon))
				return TRUE
			var/datum/overmap_iff_channel/channel = beacon.find_iff_channel(params["id"])
			if(!channel)
				return TRUE
			if(params["flag"] == "receive")
				channel.receive = !channel.receive
			else
				channel.transmit = !channel.transmit
			beacon.sync_global_broadcast()
			beacon.vessel?.sync_transponder()
			return TRUE
		if("iff_add")
			var/obj/machinery/transponder/beacon = locateUID(params["uid"])
			if(!istype(beacon))
				return TRUE
			var/id = overmap_iff_id_for_key(params["key"]) || trim(params["key"])
			if(!id || beacon.find_iff_channel(id))
				return TRUE
			beacon.iff_channels += new /datum/overmap_iff_channel(id, overmap_iff_label_for_id(id), FALSE, TRUE, FALSE)
			beacon.vessel?.sync_transponder()
			return TRUE
		if("iff_remove")
			var/obj/machinery/transponder/beacon = locateUID(params["uid"])
			if(!istype(beacon))
				return TRUE
			var/datum/overmap_iff_channel/channel = beacon.find_iff_channel(params["id"])
			if(!channel || channel.permanent)
				return TRUE
			beacon.iff_channels -= channel
			qdel(channel)
			beacon.vessel?.sync_transponder()
			return TRUE
		if("iff_broadcast")
			var/obj/machinery/transponder/beacon = locateUID(params["uid"])
			if(!istype(beacon))
				return TRUE
			var/datum/overmap_iff_channel/global_ch = beacon.find_iff_channel(OVERMAP_IFF_GLOBAL)
			if(global_ch)
				global_ch.transmit = !global_ch.transmit
			beacon.sync_global_broadcast()
			beacon.vessel?.sync_transponder()
			return TRUE
		if("comms_send")
			var/datum/overmap_sector/sector = SSovermap?.sectors[params["sector"]]
			if(!sector)
				return TRUE
			var/body = trim(params["text"])
			if(!body)
				return TRUE
			var/key = trim(params["key"])
			sector.add_comms_message(new /datum/overmap_sector_message(body, key, params["sender"] || "Админ", sector.id))
			log_admin("[key_name(user)] sent overmap comms to [sector.id].")
			return TRUE
		if("comms_delete")
			var/datum/overmap_sector/sector = SSovermap?.sectors[params["sector"]]
			if(!sector)
				return TRUE
			for(var/datum/overmap_sector_message/message as anything in sector.comms_messages)
				if(message.id == params["id"])
					sector.comms_messages -= message
					qdel(message)
					break
			return TRUE
		if("comms_clear")
			var/datum/overmap_sector/sector = SSovermap?.sectors[params["sector"]]
			if(!sector)
				return TRUE
			QDEL_LIST(sector.comms_messages)
			return TRUE
	return FALSE

/datum/overmap_admin_panel/proc/truthy(value)
	return value == TRUE || value == "true" || value == "1" || value == 1

/datum/overmap_admin_panel/proc/apply_field(obj/overmap/token, field, value, mob/user)
	var/obj/overmap/entity/vessel = token
	switch(field)
		if("name")
			token.name = value
		if("icon_state")
			token.icon_state = value
			token.update_icon(UPDATE_ICON_STATE)
		if("pos_x")
			token.position[1] = clamp(text2num(value) || 0, -OVERMAP_TILE_EDGE + 0.001, OVERMAP_TILE_EDGE - 0.001)
			token.update_overmap_pixel()
		if("pos_y")
			token.position[2] = clamp(text2num(value) || 0, -OVERMAP_TILE_EDGE + 0.001, OVERMAP_TILE_EDGE - 0.001)
			token.update_overmap_pixel()
		if("movable")
			token.movable = truthy(value)
		if("halted")
			token.halted = truthy(value)
		if("immune")
			token.overmap_hazard_immune = truthy(value)
		if("visible")
			token.visible_without_scanner = truthy(value)
			token.apply_overmap_camera_visibility()
		if("hidden")
			token.hidden_from_contacts = truthy(value)
		if("wraparound")
			token.wraparound = truthy(value)
		if("speed_x")
			token.speed[1] = text2num(value) || 0
			token.refresh_heading_overlay()
		if("speed_y")
			token.speed[2] = text2num(value) || 0
			token.refresh_heading_overlay()
		if("flight")
			if(!istype(vessel))
				to_chat(user, span_warning("Полёт только у entity-токенов. Откройте helm — оболочка будет создана."), confidential = TRUE)
				return
			if(!vessel.flight)
				vessel.AddComponent(/datum/component/overmap_flight)
			vessel.ensure_virtual_engine()
			vessel.movable = TRUE
			vessel.halted = FALSE
			if(vessel.status == OVERMAP_STATUS_DOCKED && isturf(vessel.loc))
				vessel.status = OVERMAP_STATUS_OVERMAP
	SEND_SIGNAL(token, COMSIG_OVERMAP_DISPLAY_CHANGED)
	log_admin("[key_name(user)] set overmap [token] field [field] = [value]")

/datum/overmap_admin_panel/proc/admin_teleport_token(obj/overmap/token, sector_id, coord_x, coord_y, mob/user)
	var/datum/overmap_sector/sector = SSovermap?.sectors[sector_id]
	if(!sector)
		to_chat(user, span_warning("Сектор не найден."), confidential = TRUE)
		return
	var/turf/spot = sector.get_turf_at(coord_x, coord_y)
	if(!spot)
		to_chat(user, span_warning("Клетка недоступна."), confidential = TRUE)
		return
	var/obj/overmap/entity/vessel = token
	if(istype(vessel) && vessel.docked_to)
		vessel.release_to_overmap(spot)
	token.sector?.remove_object(token)
	sector.add_object(token, spot)
	token.position = list(0, 0)
	token.update_overmap_pixel()
	SEND_SIGNAL(token, COMSIG_OVERMAP_MOVED)
	log_admin("[key_name(user)] moved overmap [token] to [sector.id] [coord_x]:[coord_y].")

/datum/overmap_admin_panel/proc/open_admin_helm(obj/overmap/token, mob/user)
	var/obj/overmap/entity/vessel = token
	if(!istype(vessel))
		vessel = new /obj/overmap/entity/admin_shell(token.get_overmap_turf() || token.loc)
		var/obj/overmap/entity/admin_shell/shell = vessel
		shell.bind_slave(token)
	if(!vessel.flight)
		vessel.AddComponent(/datum/component/overmap_flight)
	vessel.ensure_virtual_engine()
	if(!vessel.sensor_pack)
		vessel.AddComponent(/datum/component/overmap_sensors)
	vessel.long_sensors_on = TRUE
	vessel.short_sensors_on = TRUE
	vessel.movable = TRUE
	if(istype(vessel, /obj/overmap/entity/admin_shell) || isturf(vessel.loc))
		vessel.halted = FALSE
		if(vessel.status == OVERMAP_STATUS_DOCKED && isturf(vessel.loc))
			vessel.status = OVERMAP_STATUS_OVERMAP
	var/obj/machinery/computer/helm/admin/helm = new(null)
	helm.bind_target(vessel)
	open_helms |= helm
	helm.ui_interact(user)
	log_admin("[key_name(user)] opened admin helm on [token].")

/datum/overmap_admin_panel/proc/apply_dump_to_console(obj/machinery/computer/sensors/console, mob/user)
	console.link_vessel()
	if(!console.vessel)
		to_chat(user, span_warning("Консоль не привязана к судну."), confidential = TRUE)
		return
	if(!console.vessel.sensor_pack)
		console.vessel.AddComponent(/datum/component/overmap_sensors)
	var/added = console.vessel.import_short_dump(dump_uids.Copy(), "admin")
	to_chat(user, span_notice("Загружено контактов: [added]."), confidential = TRUE)
	log_admin("[key_name(user)] loaded overmap dump ([added]) into [console] / [console.vessel].")

/datum/overmap_admin_panel/proc/upload_dmm_from_user(mob/user)
	var/uploaded = input(user, "Выберите .dmm файл", "Загрузка DMM") as null|file
	if(!uploaded)
		return
	var/datum/map_template/template = new /datum/map_template(map = uploaded, rename = "[uploaded]")
	var/bounds = GLOB.maploader.load_map(uploaded, 1, 1, 1, shouldCropMap = FALSE, measureOnly = TRUE)
	if(bounds)
		template.width = bounds[MAP_MAXX]
		template.height = bounds[MAP_MAXY]
	QDEL_NULL(uploaded_template)
	uploaded_template = template
	to_chat(user, span_notice("DMM загружен: [template.name] ([template.width]x[template.height])."), confidential = TRUE)

/datum/overmap_admin_panel/proc/apply_spawn_look(obj/overmap/token, list/params)
	if(!token)
		return
	if(params["name"])
		token.name = params["name"]
	if(params["icon_state"])
		token.icon_state = params["icon_state"]
		token.update_icon(UPDATE_ICON_STATE)
	if(!isnull(params["movable"]))
		token.movable = truthy(params["movable"])
	if(!isnull(params["halted"]))
		token.halted = truthy(params["halted"])
	if(!isnull(params["immune"]))
		token.overmap_hazard_immune = truthy(params["immune"])
	if(!isnull(params["visible"]))
		token.visible_without_scanner = truthy(params["visible"])
		token.apply_overmap_camera_visibility()
	if(!isnull(params["hidden"]))
		token.hidden_from_contacts = truthy(params["hidden"])
	SEND_SIGNAL(token, COMSIG_OVERMAP_DISPLAY_CHANGED)

/datum/overmap_admin_panel/proc/admin_spawn_token(list/params, mob/user)
	if(!SSovermap?.initialized)
		to_chat(user, span_warning("Overmap не готов."), confidential = TRUE)
		return
	var/kind = params["kind"]
	var/datum/overmap_sector/sector = SSovermap.sectors[params["sector"]]
	if(!sector)
		to_chat(user, span_warning("Сектор не найден."), confidential = TRUE)
		return
	var/coord_x = text2num(params["x"])
	var/coord_y = text2num(params["y"])
	if(isnull(coord_x))
		coord_x = round(sector.size / 2)
	if(isnull(coord_y))
		coord_y = round(sector.size / 2)
	var/turf/spot = sector.get_nearest_open_turf(coord_x, coord_y)
	if(!spot)
		to_chat(user, span_warning("Нет доступной клетки в секторе."), confidential = TRUE)
		return
	coord_x = sector.coord_x(spot)
	coord_y = sector.coord_y(spot)
	switch(kind)
		if("token", "hazard", "signature", "portal")
			var/spawn_path = text2path(params["spawn_type"] || params["hazard_type"])
			if(!spawn_path)
				if(kind == "hazard")
					spawn_path = /obj/overmap/feature/hazard
				else if(kind == "portal")
					spawn_path = /obj/overmap/portal
				else
					spawn_path = /obj/overmap/feature
			if(!ispath(spawn_path, /obj/overmap) || spawn_path == /obj/overmap/entity/admin_shell)
				to_chat(user, span_warning("Неизвестный тип объекта."), confidential = TRUE)
				return
			overmap_clear_tile_for_feature(sector, spot)
			var/obj/overmap/token = new spawn_path(spot)
			sector.add_object(token, spot)
			apply_spawn_look(token, params)
			var/obj/overmap/portal/gate = token
			if(istype(gate))
				var/datum/overmap_sector/dest = SSovermap.sectors[params["dest_sector"]]
				gate.destination_sector = dest
				gate.destination_x = text2num(params["dest_x"])
				gate.destination_y = text2num(params["dest_y"])
			selected = token
			log_admin("[key_name(user)] spawned overmap [spawn_path] at [sector.id] [coord_x]:[coord_y].")
		if("ruin", "shuttle")
			var/large = truthy(params["large"])
			var/region_size = large ? SSovermap.large_region_size() : OVERMAP_RUIN_REGION_SIZE
			var/datum/map_template/template = resolve_template(params["template_id"], params["template_kind"])
			if(template && (template.width > region_size || template.height > region_size))
				to_chat(user, span_warning("Карта [template.width]x[template.height] не влезает в ячейку [region_size]x[region_size]."), confidential = TRUE)
				return
			var/datum/overmap_feature/ruin/site = new
			site.name = params["name"] || (kind == "shuttle" ? "Шаттл" : "Точка интереса")
			site.enterable_quadrants = list(1)
			site.region_size = region_size
			if(!site.spawn_on(sector, coord_x, coord_y))
				qdel(site)
				to_chat(user, span_warning("Не удалось разместить объект."), confidential = TRUE)
				return
			var/datum/overmap_space_region/cell = site.cells[1]
			if(template)
				var/turf/load_at = cell.center_turf()
				if(!template.fits_in_map_bounds(load_at, centered = TRUE) || !cell.contains_space_turf(load_at))
					qdel(site)
					to_chat(user, span_warning("Карта не влезает в зарезервированный космос."), confidential = TRUE)
					return
				if(!template.load(load_at, centered = TRUE))
					qdel(site)
					to_chat(user, span_warning("Не удалось загрузить dmm."), confidential = TRUE)
					return
			var/obj/overmap/entity/feature/ruin/ruin_token = site.tokens[1]
			selected = ruin_token
			apply_spawn_look(ruin_token, params)
			if(kind == "shuttle")
				bind_spawned_shuttle(site, ruin_token, sector, spot, user)
				if(selected)
					apply_spawn_look(selected, params)
			log_admin("[key_name(user)] spawned overmap [kind] ([template?.name || "empty"]) at [sector.id] [coord_x]:[coord_y].")
		else
			to_chat(user, span_warning("Неизвестный тип спавна."), confidential = TRUE)

/datum/overmap_admin_panel/proc/resolve_template(template_id, template_kind)
	if(template_kind == "upload")
		return uploaded_template
	if(!template_id)
		return null
	if(template_kind == "shuttle")
		return GLOB.shuttle_templates[template_id]
	return GLOB.map_templates[template_id] || GLOB.shuttle_templates[template_id]

/datum/overmap_admin_panel/proc/bind_spawned_shuttle(datum/overmap_feature/ruin/site, obj/overmap/entity/feature/ruin/host, datum/overmap_sector/sector, turf/spot, mob/user)
	var/obj/docking_port/mobile/port
	var/datum/overmap_space_region/cell = host.landing_region
	if(cell)
		for(var/obj/docking_port/mobile/candidate as anything in SSshuttle.mobile)
			if(QDELETED(candidate))
				continue
			if(cell.contains_space_turf(get_turf(candidate)))
				port = candidate
				break
	if(!port)
		to_chat(user, span_warning("В карте нет docking port /mobile — оставлен как руина."), confidential = TRUE)
		return
	var/obj/overmap/entity/vessel = SSovermap.get_or_register_shuttle(port)
	if(!vessel)
		return
	if(vessel.docked_to)
		vessel.release_to_overmap(spot)
	else
		sector.add_object(vessel, spot)
	vessel.status = OVERMAP_STATUS_OVERMAP
	vessel.halted = FALSE
	selected = vessel
	qdel(site)

/datum/click_intercept/overmap_dump
	var/list/uids

/datum/click_intercept/overmap_dump/New(client/C, list/dump)
	uids = dump || list()
	return ..()

/datum/click_intercept/overmap_dump/InterceptClickOn(mob/user, params, atom/object)
	var/obj/machinery/computer/sensors/console = object
	if(!istype(console))
		to_chat(user, span_warning("Нужна консоль сенсоров."), confidential = TRUE)
		return TRUE
	console.link_vessel()
	if(!console.vessel)
		to_chat(user, span_warning("Консоль не привязана к судну."), confidential = TRUE)
		return TRUE
	if(!console.vessel.sensor_pack)
		console.vessel.AddComponent(/datum/component/overmap_sensors)
	var/added = console.vessel.import_short_dump(uids.Copy(), "admin")
	to_chat(user, span_notice("Дамп загружен ([added])."), confidential = TRUE)
	log_admin("[key_name(user)] click-loaded overmap dump ([added]) into [console].")
	quit()
	return TRUE

/obj/overmap/entity/admin_shell
	name = "admin helm"
	hidden_from_contacts = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	overmap_kind = OVERMAP_KIND_OTHER
	var/obj/overmap/slave

/obj/overmap/entity/admin_shell/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_flight)

/obj/overmap/entity/admin_shell/proc/bind_slave(obj/overmap/token)
	slave = token
	name = token.get_overmap_display_name()
	icon = token.icon
	icon_state = token.icon_state
	sector = token.sector
	if(token.sector)
		token.sector.objects |= src
	speed = token.speed.Copy()
	position = token.position.Copy()
	if(token.loc)
		forceMove(token.loc)
	RegisterSignal(src, COMSIG_OVERMAP_MOVED, PROC_REF(sync_slave))
	RegisterSignal(token, COMSIG_QDELETING, PROC_REF(on_slave_qdel))

/obj/overmap/entity/admin_shell/proc/sync_slave()
	SIGNAL_HANDLER
	if(QDELETED(slave))
		return
	var/turf/here = loc
	if(isturf(here) && slave.loc != here)
		slave.forceMove(here)
	slave.sector = sector
	if(sector)
		sector.objects |= slave
	slave.speed = speed.Copy()
	slave.position = position.Copy()
	slave.update_overmap_pixel()
	slave.movable = TRUE
	slave.halted = halted

/obj/overmap/entity/admin_shell/proc/on_slave_qdel()
	SIGNAL_HANDLER
	slave = null
	qdel(src)

/obj/overmap/entity/admin_shell/Destroy()
	if(slave)
		UnregisterSignal(slave, COMSIG_QDELETING)
	slave = null
	return ..()

/obj/machinery/computer/helm/admin
	name = "admin helm"
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/helm/admin/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER
	if(vessel)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_NOTICE, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.helms -= src
		vessel = null

/obj/machinery/computer/helm/admin/link_vessel()
	return

/obj/machinery/computer/helm/admin/powered(chan)
	return TRUE

/obj/machinery/computer/helm/admin/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN | R_EVENT)

/obj/machinery/computer/helm/admin/ui_status(mob/user, datum/ui_state/state)
	if(user?.client && check_rights_for(user.client, R_ADMIN | R_EVENT))
		return UI_INTERACTIVE
	return UI_CLOSE

/obj/machinery/computer/helm/admin/proc/bind_target(obj/overmap/entity/target)
	if(!target)
		return
	if(vessel && vessel != target)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_NOTICE, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.helms -= src
	vessel = target
	target.helms |= src
	RegisterSignal(target, COMSIG_OVERMAP_MOVED, PROC_REF(on_overmap_moved), override = TRUE)
	RegisterSignal(target, COMSIG_OVERMAP_NOTICE, PROC_REF(on_overmap_notice), override = TRUE)
	RegisterSignal(target, COMSIG_OVERMAP_DISPLAY_CHANGED, PROC_REF(on_overmap_display_changed), override = TRUE)
	update_map_view()

/datum/overmap_admin_panel/ui_close(mob/user)
	if(!QDELING(src))
		qdel(src)

ADMIN_VERB(overmap_panel, R_ADMIN|R_EVENT, "Овермап", "Панель управления объектами овермапы.", ADMIN_CATEGORY_EVENTS)
	var/datum/overmap_admin_panel/panel = new
	panel.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Overmap Panel")
