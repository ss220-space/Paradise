/obj/machinery/computer/logistics_core
	name = "logistics core console"
	desc = "Центральная консоль логистики. Позволяет управлять всеми логистическими сетями в секторе."
	icon_keyboard = "logistics_key"
	icon_screen = "logistics_core"
	light_color = LIGHT_COLOR_BLUE
	circuit = /obj/item/circuitboard/logistics_core

/obj/machinery/computer/logistics_core/get_ru_names()
	return alist(
		NOMINATIVE = "консоль ядра логистики",
		GENITIVE = "консоли ядра логистики",
		DATIVE = "консоли ядра логистики",
		ACCUSATIVE = "консоль ядра логистики",
		INSTRUMENTAL = "консолью ядра логистики",
		PREPOSITIONAL = "консоли ядра логистики",
	)

/obj/machinery/computer/logistics_core/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/logistics_core/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/logistics_core/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/nanomaps))

/obj/machinery/computer/logistics_core/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LogisticsCore", DECLENT_RU_CAP(src, NOMINATIVE))
		ui.open()

/obj/machinery/computer/logistics_core/ui_static_data(mob/user)
	var/list/data = list()
	var/list/station_level_numbers = list()
	var/list/station_level_names = list()
	for(var/z_level in levels_by_trait(STATION_LEVEL))
		station_level_numbers += z_level
		var/datum/space_level/level = GLOB.space_manager.get_zlev(z_level)
		station_level_names += level.name
	data["stationLevelNum"] = station_level_numbers
	data["stationLevelName"] = station_level_names
	return data

/obj/machinery/computer/logistics_core/ui_data(mob/user)
	var/list/data = list()
	data["networks"] = list()
	data["requests"] = list()
	data["logs"] = list()
	data["archived"] = list()
	data["map_nodes"] = list()
	data["map_pipes"] = list()

	for(var/datum/logistics_net/net as anything in GLOB.logistics_nets)
		var/list/net_interfaces = list()
		for(var/datum/component/logistics_interface/interface as anything in net.interfaces)
			var/obj/machinery/machine = interface.parent
			var/turf/T = get_turf(machine)
			net_interfaces += list(list(
				"uid" = interface.UID(),
				"name" = interface.interface_name,
				"mode" = (interface.mode == LOGISTICS_MODE_SEND) ? "send" : "receive",
				"allow_export" = interface.allow_export,
				"fill_percent" = interface.adapter ? interface.adapter.get_fill_percent() : null,
			))
			if(T)
				data["map_nodes"] += list(list(
					"uid" = interface.UID(),
					"name" = interface.interface_name,
					"mode" = (interface.mode == LOGISTICS_MODE_SEND) ? "send" : "receive",
					"allow_export" = interface.allow_export,
					"net_id" = net.net_id,
					"net_color" = net.net_color,
					"x" = T.x,
					"y" = T.y,
					"z" = T.z,
				))

		var/list/seen_links = list()
		for(var/obj/structure/logistics_pipe/pipe as anything in net.pipes)
			var/turf/pipe_turf = get_turf(pipe)
			if(!pipe_turf)
				continue
			for(var/obj/structure/logistics_pipe/neighbor as anything in pipe.get_neighbors())
				if(neighbor.logistics_net != net)
					continue
				var/link_key = pipe.UID() > neighbor.UID() ? "[neighbor.UID()]|[pipe.UID()]" : "[pipe.UID()]|[neighbor.UID()]"
				if(seen_links[link_key])
					continue
				seen_links[link_key] = TRUE
				var/turf/neighbor_turf = get_turf(neighbor)
				if(!neighbor_turf || neighbor_turf.z != pipe_turf.z)
					continue
				data["map_pipes"] += list(list(
					"x1" = pipe_turf.x,
					"y1" = pipe_turf.y,
					"x2" = neighbor_turf.x,
					"y2" = neighbor_turf.y,
					"z" = pipe_turf.z,
					"net_color" = net.net_color,
				))

		data["networks"] += list(list(
			"uid" = net.UID(),
			"id" = net.net_id,
			"name" = net.net_name,
			"color" = net.net_color,
			"auto_execute" = net.auto_execute,
			"pipes" = length(net.pipes),
			"interfaces" = length(net.interfaces),
			"requests" = length(net.requests),
			"nodes" = net_interfaces,
		))

		for(var/datum/logistics_request/request as anything in net.requests)
			data["requests"] += list(request.ui_serialize())

		for(var/entry in net.archived_orders)
			data["archived"] += list(entry)

		for(var/log_line in net.logs)
			data["logs"] += list(list(
				"net_id" = net.net_id,
				"net_name" = net.net_name,
				"text" = log_line,
			))

	return data

/obj/machinery/computer/logistics_core/ui_act(action, list/params)
	if(..())
		return
	add_fingerprint(usr)
	. = TRUE

	switch(action)
		if("execute_request")
			var/datum/logistics_request/request = locateUID(params["uid"])
			if(istype(request))
				request.net?.execute_request(request)
		if("pause_request")
			var/datum/logistics_request/request = locateUID(params["uid"])
			if(istype(request))
				request.net?.pause_request(request)
		if("cancel_request")
			var/datum/logistics_request/request = locateUID(params["uid"])
			if(istype(request))
				request.net?.cancel_request(request)
		if("move_request")
			var/datum/logistics_request/request = locateUID(params["uid"])
			var/direction = text2num(params["dir"])
			if(istype(request) && direction)
				request.net?.move_request(request, direction)
		if("set_net_name")
			var/datum/logistics_net/net = locateUID(params["uid"])
			if(!istype(net))
				return
			var/new_name = tgui_input_text(usr, "Название логистической сети", "Сети", net.net_name, MAX_NAME_LEN)
			if(!new_name || QDELETED(net))
				return
			net.net_name = trim(new_name)
			net.add_log("Сеть переименована в «[net.net_name]».")
		if("set_net_color")
			var/datum/logistics_net/net = locateUID(params["uid"])
			if(!istype(net))
				return
			var/new_color = params["color"]
			if(!istext(new_color) || length(new_color) < 4)
				return
			net.net_color = new_color
		if("toggle_auto_execute")
			var/datum/logistics_net/net = locateUID(params["uid"])
			if(!istype(net))
				return
			net.auto_execute = !net.auto_execute
			net.add_log("Автовыполнение заказов [net.auto_execute ? "включено" : "выключено"].")
			if(net.auto_execute)
				for(var/datum/logistics_request/request as anything in net.requests)
					if(request.status == LOGISTICS_REQUEST_PENDING)
						net.execute_request(request)
		if("rename_interface")
			var/datum/component/logistics_interface/interface = locateUID(params["uid"])
			if(!istype(interface))
				return
			var/new_name = tgui_input_text(usr, "Название устройства в сети", "Логистика", interface.interface_name, MAX_NAME_LEN)
			if(!new_name || QDELETED(interface))
				return
			interface.interface_name = trim(new_name)

/obj/item/circuitboard/logistics_core
	board_name = "Logistics Core Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/logistics_core
	origin_tech = "programming=6;engineering=6"
