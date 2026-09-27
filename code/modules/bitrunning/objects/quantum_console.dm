/obj/machinery/computer/quantum_console
	name = "quantum console"
	desc = "Терминал управления квантовым сервером. Отсюда выбирают, во что нырять."
	icon_keyboard = "mining_key"
	icon_screen = "mining"
	circuit = /obj/item/circuitboard/quantum_console
	req_access = list(ACCESS_BITRUNNING)
	var/datum/weakref/server_ref

/obj/machinery/computer/quantum_console/get_ru_names()
	return alist(
		NOMINATIVE = "квантовая консоль",
		GENITIVE = "квантовой консоли",
		DATIVE = "квантовой консоли",
		ACCUSATIVE = "квантовую консоль",
		INSTRUMENTAL = "квантовой консолью",
		PREPOSITIONAL = "квантовой консоли",
	)

/obj/machinery/computer/quantum_console/examine(mob/user)
	. = ..()
	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		. += span_warning("Консоль не подключена к серверу. Он должен стоять вплотную.")
		return

	. += span_notice("Накоплено очков: [server.points].")
	. += span_notice("Уровень сканера: [server.scanner_tier].")

	if(server.generated_domain)
		. += span_notice("Запущен домен: [server.generated_domain.name].")
		. += span_notice("Подключено битраннеров: [length(server.avatar_connection_refs)].")
		. += span_notice("Осталось выходов: [length(server.exit_turfs) - server.retries_spent].")
		return

	. += span_notice(server.is_ready ? "Сервер готов к загрузке домена." : "Сервер остывает.")

/obj/machinery/computer/quantum_console/attack_hand(mob/user)
	if(..())
		return TRUE

	if(!allowed(user))
		balloon_alert(user, "доступ запрещён!")
		playsound(src, SFX_BUTTON_DENIED, 20)
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/quantum_console/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "QuantumConsole", name)
		ui.open()

/obj/machinery/computer/quantum_console/ui_data(mob/user)
	var/list/data = list()

	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		data["connected"] = FALSE
		return data

	data["connected"] = TRUE
	data["available_domains"] = get_available_domains(server.scanner_tier, server.points)
	data["broadcasting"] = server.broadcasting
	data["broadcasting_on_cd"] = !COOLDOWN_FINISHED(server, broadcast_toggle_cd)
	data["avatars"] = server.get_avatar_data()
	data["generated_domain"] = server.generated_domain?.key
	data["occupants"] = length(server.avatar_connection_refs)
	data["points"] = server.points
	data["randomized"] = server.domain_randomized
	data["ready"] = server.is_ready && server.is_operational()
	data["retries_left"] = length(server.exit_turfs) - server.retries_spent
	data["scanner_tier"] = server.scanner_tier

	return data

/obj/machinery/computer/quantum_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	if(!allowed(usr))
		to_chat(usr, span_warning("Доступ запрещён."))
		playsound(src, SFX_BUTTON_DENIED, 20)
		return TRUE

	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		return TRUE

	. = TRUE
	switch(action)
		if("random_domain")
			server.cold_boot_map(server.get_random_domain_id(), was_random_selection = TRUE)

		if("set_domain")
			server.cold_boot_map(params["id"])

		if("stop_domain")
			server.begin_shutdown(usr)

		if("broadcast")
			server.toggle_broadcast()

		else
			return FALSE

	add_fingerprint(usr)

/obj/machinery/computer/quantum_console/proc/find_server()
	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	if(server)
		return server

	for(var/direction in GLOB.cardinal)
		server = locate(/obj/machinery/quantum_server) in get_step(src, direction)
		if(isnull(server))
			continue

		server_ref = WEAKREF(server)
		return server
