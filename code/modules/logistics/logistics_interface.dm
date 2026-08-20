/obj/item/logistics_interface
	name = "logistics interface board"
	desc = "Плата логистического интерфейса. Вставляется в совместимую машинерию с открытой панелью."
	icon = 'icons/obj/module.dmi'
	icon_state = "circuit_map"
	item_state = "electronic"
	origin_tech = "programming=2;engineering=2"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	var/mode = LOGISTICS_MODE_SEND

/obj/item/logistics_interface/get_ru_names()
	return alist(
		NOMINATIVE = "плата логистического интерфейса",
		GENITIVE = "платы логистического интерфейса",
		DATIVE = "плате логистического интерфейса",
		ACCUSATIVE = "плату логистического интерфейса",
		INSTRUMENTAL = "платой логистического интерфейса",
		PREPOSITIONAL = "плате логистического интерфейса",
	)

/obj/item/logistics_interface/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_NAME | UPDATE_DESC)

/obj/item/logistics_interface/update_name(updates = ALL)
	. = ..()
	name = (mode == LOGISTICS_MODE_SEND) ? "logistics interface board (export)" : "logistics interface board (import)"

/obj/item/logistics_interface/update_desc(updates = ALL)
	. = ..()
	desc = initial(desc)
	desc += (mode == LOGISTICS_MODE_SEND) ? " Сейчас настроена на отправку ресурсов." : " Сейчас настроена на приём ресурсов."

/obj/item/logistics_interface/examine(mob/user)
	. = ..()
	. += span_notice("Режим: [mode == LOGISTICS_MODE_SEND ? "отправка" : "приём"].")

/obj/item/logistics_interface/attack_self(mob/user)
	if(loc != user)
		return
	mode = (mode == LOGISTICS_MODE_SEND) ? LOGISTICS_MODE_RECEIVE : LOGISTICS_MODE_SEND
	update_appearance(UPDATE_NAME | UPDATE_DESC)
	to_chat(user, span_notice("Режим платы переключён на [mode == LOGISTICS_MODE_SEND ? "отправку" : "приём"]."))
	playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE)

/obj/item/logistics_interface/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ismachinery(interacting_with))
		return NONE
	var/obj/machinery/machine = interacting_with
	if(!HAS_TRAIT(machine, TRAIT_LOGISTICS_COMPATIBLE))
		return NONE
	if(!machine.panel_open)
		balloon_alert(user, "откройте панель!")
		return ITEM_INTERACT_BLOCKING
	if(machine.GetComponent(/datum/component/logistics_interface))
		balloon_alert(user, "интерфейс уже установлен!")
		return ITEM_INTERACT_BLOCKING
	if(!user.drop_transfer_item_to_loc(src, machine))
		return ITEM_INTERACT_BLOCKING
	if(!machine.component_parts)
		machine.component_parts = list()
	machine.component_parts += src
	machine.AddComponent(/datum/component/logistics_interface, src)
	balloon_alert(user, "интерфейс установлен")
	playsound(machine, 'sound/items/deconstruct.ogg', 50, TRUE)
	return ITEM_INTERACT_SUCCESS

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
	var/list/net_types = list()
	var/list/node_entries = list()
	var/list/datum/component/logistics_interface/ordered_interfaces = list()

	for(var/datum/component/logistics_interface/interface as anything in net.interfaces)
		var/obj/machinery/other = interface.parent
		var/list/node_stock = list()
		if(interface.adapter)
			for(var/list/entry as anything in interface.adapter.list_stock())
				var/stock_name = entry["name"]
				var/amount = entry["amount"]
				node_stock += list(list(
					"name" = stock_name,
					"amount" = amount,
					"icon" = entry["icon"],
					"icon_state" = entry["icon_state"],
				))
				net_amounts[stock_name] += amount
				if(!net_icons[stock_name])
					net_icons[stock_name] = list("icon" = entry["icon"], "icon_state" = entry["icon_state"])
				if(!net_types[stock_name])
					net_types[stock_name] = interface.adapter.get_stock_type(stock_name)
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

	for(var/stock_name in net_amounts)
		data["net_stock"] += list(list(
			"name" = stock_name,
			"amount" = net_amounts[stock_name],
			"icon" = net_icons[stock_name]["icon"],
			"icon_state" = net_icons[stock_name]["icon_state"],
		))

	for(var/i in 1 to length(node_entries))
		var/list/node_entry = node_entries[i]
		var/datum/component/logistics_interface/interface = ordered_interfaces[i]
		var/list/accepted = list()
		if(interface?.adapter)
			for(var/stock_name in net_amounts)
				if(interface.adapter.can_accept_name(stock_name, net_types[stock_name]))
					accepted += stock_name
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
			for(var/stock_name in wanted)
				var/amount = text2num(wanted[stock_name])
				if(!amount || amount < 1)
					continue
				cleaned[stock_name] = round(amount)
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

/obj/machinery/proc/try_open_logistics(mob/user)
	var/datum/component/logistics_interface/interface = GetComponent(/datum/component/logistics_interface)
	if(!interface)
		return FALSE
	interface.ui_interact(user)
	return TRUE

/obj/machinery/proc/logistics_board_installed()
	return !!GetComponent(/datum/component/logistics_interface)

/obj/machinery/proc/install_logistics_interface(mode = LOGISTICS_MODE_SEND)
	if(!HAS_TRAIT(src, TRAIT_LOGISTICS_COMPATIBLE))
		return null
	if(GetComponent(/datum/component/logistics_interface))
		return null
	if(!component_parts)
		component_parts = list()
	var/obj/item/logistics_interface/board = new(src)
	board.mode = mode
	board.update_appearance(UPDATE_NAME | UPDATE_DESC)
	component_parts += board
	return AddComponent(/datum/component/logistics_interface, board)

/obj/machinery/proc/try_logistics_ui_act(action, mob/user)
	if(action != "open_logistics")
		return FALSE
	try_open_logistics(user)
	return TRUE
