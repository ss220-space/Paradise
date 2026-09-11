/datum/component/logistics_interface
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/obj/item/logistics_interface/board
	var/datum/logistics_adapter/adapter
	var/datum/logistics_net/net
	var/obj/structure/logistics_pipe/linked_pipe
	var/mode = LOGISTICS_MODE_SEND
	var/allow_export = TRUE
	var/notify_status = FALSE
	var/sound_notify = FALSE
	var/interface_name

/datum/component/logistics_interface/Initialize(obj/item/logistics_interface/installed_board)
	if(!ismachinery(parent))
		return COMPONENT_INCOMPATIBLE
	if(!HAS_TRAIT(parent, TRAIT_LOGISTICS_COMPATIBLE))
		return COMPONENT_INCOMPATIBLE
	var/obj/machinery/machine = parent
	board = installed_board
	mode = board?.mode || LOGISTICS_MODE_SEND
	adapter = make_adapter(machine)
	if(!adapter)
		return COMPONENT_INCOMPATIBLE
	interface_name = machine.name

/datum/component/logistics_interface/proc/make_adapter(obj/machinery/machine)
	if(istype(machine, /obj/machinery/smartfridge))
		return new /datum/logistics_adapter/smartfridge(machine)
	if(machine.GetComponent(/datum/component/material_container))
		return new /datum/logistics_adapter/material_container(machine)
	return null

/datum/component/logistics_interface/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_parent_qdel))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_CROWBAR), PROC_REF(on_crowbar_act))
	try_connect_pipe()

/datum/component/logistics_interface/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_QDELETING, COMSIG_ATOM_TOOL_ACT(TOOL_CROWBAR)))
	disconnect_pipe()

/datum/component/logistics_interface/Destroy()
	disconnect_pipe()
	QDEL_NULL(adapter)
	board = null
	return ..()

/datum/component/logistics_interface/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/mode_text = (mode == LOGISTICS_MODE_SEND) ? "отправка" : "приём"
	examine_list += span_notice("Установлен логистический интерфейс «[interface_name]» ([mode_text]).")

/datum/component/logistics_interface/proc/on_parent_qdel(datum/source)
	SIGNAL_HANDLER
	if(board && !QDELETED(board) && board.loc == parent)
		board.forceMove(get_turf(parent))

/datum/component/logistics_interface/proc/on_crowbar_act(datum/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER
	var/obj/machinery/machine = parent
	if(!machine.panel_open || !board)
		return NONE
	remove_board(user)
	return ITEM_INTERACT_SUCCESS

/datum/component/logistics_interface/proc/remove_board(mob/user)
	var/obj/machinery/machine = parent
	var/obj/item/logistics_interface/removed = board
	board = null
	if(removed)
		removed.mode = mode
		machine.component_parts -= removed
		removed.forceMove(get_turf(machine))
		if(user && !user.put_in_hands(removed))
			removed.forceMove(get_turf(machine))
		removed.update_appearance(UPDATE_NAME | UPDATE_DESC)
	machine.balloon_alert(user, "интерфейс снят")
	playsound(machine, 'sound/items/deconstruct.ogg', 50, TRUE)
	qdel(src)

/datum/component/logistics_interface/proc/try_connect_pipe()
	var/turf/our_turf = get_turf(parent)
	if(!our_turf)
		return
	var/obj/structure/logistics_pipe/found = locate(/obj/structure/logistics_pipe/trunk) in our_turf
	if(!found)
		found = locate(/obj/structure/logistics_pipe) in our_turf
	if(found)
		connect_pipe(found)

/datum/component/logistics_interface/proc/connect_pipe(obj/structure/logistics_pipe/new_pipe)
	if(!new_pipe)
		return
	if(new_pipe.linked_interface && new_pipe.linked_interface != src)
		return
	if(linked_pipe && linked_pipe != new_pipe)
		disconnect_pipe()
	linked_pipe = new_pipe
	linked_pipe.linked_interface = src
	if(linked_pipe.logistics_net)
		linked_pipe.logistics_net.add_interface(src)

/datum/component/logistics_interface/proc/disconnect_pipe()
	net?.remove_interface(src)
	if(linked_pipe?.linked_interface == src)
		linked_pipe.linked_interface = null
	linked_pipe = null
	net = null

/datum/component/logistics_interface/proc/can_export(stock_name)
	if(!allow_export)
		return FALSE
	var/obj/machinery/machine = parent
	if(!machine.powered() || (machine.stat & (BROKEN | NOPOWER)))
		return FALSE
	if(!adapter)
		return FALSE
	return adapter.get_amount(stock_name) > 0

/datum/component/logistics_interface/proc/get_available_amount(stock_name)
	if(!can_export(stock_name))
		return 0
	return adapter.get_amount(stock_name)

/datum/component/logistics_interface/proc/extract_into(stock_name, amount, atom/target)
	if(!can_export(stock_name))
		return 0
	return adapter.extract(stock_name, amount, target)

/datum/component/logistics_interface/proc/try_insert_item(obj/item/item)
	if(!adapter)
		return FALSE
	if(!adapter.can_insert_item(item))
		return FALSE
	adapter.insert_item(item)
	return QDELETED(item) || item.loc == parent

/datum/component/logistics_interface/proc/announce_status(message)
	if(!notify_status || !message)
		return
	var/obj/machinery/machine = parent
	if(QDELETED(machine))
		return
	machine.atom_say(message)

/datum/component/logistics_interface/proc/play_send_sound()
	var/obj/machinery/machine = parent
	if(QDELETED(machine))
		return
	playsound(machine, 'sound/machines/hiss.ogg', 50, FALSE)

/datum/component/logistics_interface/proc/play_receive_sound()
	if(!sound_notify)
		return
	var/obj/machinery/machine = parent
	if(QDELETED(machine))
		return
	playsound(machine, 'sound/machines/twobeep.ogg', 25, TRUE)

/datum/component/logistics_interface/ui_status(mob/user, datum/ui_state/state)
	var/atom/host = parent
	return host.ui_status(user, state)

/datum/component/logistics_interface/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Logistics", "Логистика")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/component/logistics_interface/ui_data(mob/user)
	var/list/data = list()
	data["name"] = interface_name
	data["mode"] = (mode == LOGISTICS_MODE_SEND) ? "send" : "receive"
	data["connected"] = !!linked_pipe
	data["allow_export"] = allow_export
	data["notify_status"] = notify_status
	data["sound_notify"] = sound_notify
	data["uid"] = UID()
	data["fill_percent"] = adapter ? adapter.get_fill_percent() : null
	data["network_id"] = net ? net.net_id : null
	data["local_stock"] = adapter ? adapter.list_stock() : list()
	data["nodes"] = list()
	data["net_stock"] = list()
	if(!net)
		return data

	var/list/net_amounts = list()
	var/list/net_icons = list()
	var/list/net_names = list()
	var/list/node_entries = list()
	var/list/datum/component/logistics_interface/ordered_interfaces = list()

	for(var/datum/component/logistics_interface/interface as anything in net.interfaces)
		var/obj/machinery/other = interface.parent
		var/list/node_stock = list()
		if(interface.adapter)
			for(var/list/entry as anything in interface.adapter.list_stock())
				var/stock_id = entry["id"]
				var/amount = entry["amount"]
				node_stock += list(list(
					"id" = stock_id,
					"name" = entry["name"],
					"amount" = amount,
					"icon" = entry["icon"],
					"icon_state" = entry["icon_state"],
				))
				net_amounts[stock_id] += amount
				if(!net_names[stock_id])
					net_names[stock_id] = entry["name"]
				if(!net_icons[stock_id])
					net_icons[stock_id] = list("icon" = entry["icon"], "icon_state" = entry["icon_state"])
		ordered_interfaces += interface
		node_entries += list(list(
			"uid" = interface.UID(),
			"name" = interface.interface_name,
			"mode" = (interface.mode == LOGISTICS_MODE_SEND) ? "send" : "receive",
			"self" = (interface == src),
			"icon" = other.icon,
			"icon_state" = other.icon_state,
			"fill_percent" = interface.adapter ? interface.adapter.get_fill_percent() : null,
			"stock" = node_stock,
		))

	for(var/stock_id in net_amounts)
		data["net_stock"] += list(list(
			"id" = stock_id,
			"name" = net_names[stock_id] || logistics_stock_display_name(stock_id),
			"amount" = net_amounts[stock_id],
			"icon" = net_icons[stock_id]["icon"],
			"icon_state" = net_icons[stock_id]["icon_state"],
		))

	for(var/i in 1 to length(node_entries))
		var/list/node_entry = node_entries[i]
		var/datum/component/logistics_interface/interface = ordered_interfaces[i]
		var/list/accepted = list()
		if(interface?.adapter)
			for(var/stock_id in net_amounts)
				if(interface.adapter.can_accept_stock(stock_id))
					accepted += stock_id
		node_entry["accepted"] = accepted
		data["nodes"] += list(node_entry)

	return data

/datum/component/logistics_interface/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_name")
			var/new_name = tgui_input_text(usr, "Название устройства в логистической сети", "Логистика", interface_name, MAX_NAME_LEN)
			if(!new_name)
				return TRUE
			interface_name = trim(new_name)
			return TRUE
		if("toggle_export")
			allow_export = !allow_export
			return TRUE
		if("toggle_notify_status")
			notify_status = !notify_status
			return TRUE
		if("toggle_sound_notify")
			sound_notify = !sound_notify
			return TRUE
		if("create_request")
			if(!net)
				to_chat(usr, span_warning("Нет подключения к логистической сети."))
				return TRUE
			var/list/wanted = params["wanted"]
			if(istext(wanted))
				wanted = json_decode(wanted)
			if(!islist(wanted) || !length(wanted))
				return TRUE
			var/list/cleaned = list()
			for(var/stock_id in wanted)
				var/amount = text2num(wanted[stock_id])
				if(!amount || amount < 1)
					continue
				if(!istext(stock_id) || !length(stock_id))
					continue
				cleaned[stock_id] = round(amount)
			if(!length(cleaned))
				return TRUE
			var/datum/component/logistics_interface/dest
			if(params["dest"])
				dest = locateUID(params["dest"])
			if(!istype(dest) || dest.net != net)
				to_chat(usr, span_warning("Укажите пункт назначения."))
				return TRUE
			var/datum/component/logistics_interface/source
			if(params["source"] && params["source"] != "any")
				source = locateUID(params["source"])
				if(!istype(source) || source.net != net)
					return TRUE
			if(source && source == dest)
				to_chat(usr, span_warning("Источник и назначение не могут совпадать."))
				return TRUE
			net.create_request(source, dest, cleaned, usr, src)
			return TRUE
