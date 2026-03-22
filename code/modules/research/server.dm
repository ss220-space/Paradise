#define RD_SERVER_SCREEN_MAIN 0
#define RD_SERVER_SCREEN_ACCESS 1
#define RD_SERVER_SCREEN_DATA 2
#define RD_SERVER_SCREEN_LOGS 3
/obj/machinery/r_n_d/server
	name = "R&D Server"
	desc = "Центральный сервер отдела НИО. Предназначен для хранения и управления базой данных шаблонов печати. \
			Обеспечивает синхронизацию данных между подключёнными консолями и научным оборудованием."
	icon_state = "server"
	base_icon_state = "server"
	var/datum/research/files
	var/health = 100
	var/list/id_with_upload = list()		//List of R&D consoles with upload to server access.
	var/list/id_with_download = list()	//List of R&D consoles with download from server access.
	var/id_with_upload_string = ""		//String versions for easy editing in map editor.
	var/id_with_download_string = ""
	var/server_id = 0
	var/heat_gen = 100
	var/heating_power = 40000
	var/delay = 10
	req_access = list(ACCESS_RD) //Only the R&D can change server settings.
	var/plays_sound = 0
	var/syndicate = 0 //добавленный для синдибазы флаг
	var/list/usage_logs
	var/list/logs_for_logs_clearing
	var/static/logs_decryption_key = null
	var/list/design_blacklist = list()

/obj/machinery/r_n_d/server/get_ru_names()
	return list(
		NOMINATIVE = "сервер НИО",
		GENITIVE = "сервера НИО",
		DATIVE = "серверу НИО",
		ACCUSATIVE = "сервер НИО",
		INSTRUMENTAL = "сервером НИО",
		PREPOSITIONAL = "сервере НИО",
	)

/obj/machinery/r_n_d/server/Initialize(mapload)
	. = ..()
	if(!logs_decryption_key)
		logs_decryption_key = GenerateKey()
	if(is_taipan(z))
		syndicate = 1
		req_access = list(ACCESS_SYNDICATE_RESEARCH_DIRECTOR)
		icon_state = "syndie_server"
		base_icon_state = "syndie_server"
	component_parts = list()
	component_parts += new /obj/item/circuitboard/rdserver(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	RefreshParts()
	initialize_serv() //Agouri // fuck you agouri

/obj/machinery/r_n_d/server/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/rdserver(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	RefreshParts()

/obj/machinery/r_n_d/server/Destroy()
	griefProtection()
	return ..()

/obj/machinery/r_n_d/server/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/SP in src)
		tot_rating += SP.rating
	heat_gen /= max(1, tot_rating)

/obj/machinery/r_n_d/server/proc/initialize_serv()
	if(!files)
		files = new /datum/research(src)
	var/list/temp_list
	if(!length(id_with_upload))
		temp_list = list()
		temp_list = splittext(id_with_upload_string, ";")
		for(var/N in temp_list)
			id_with_upload += text2num(N)
	if(!length(id_with_download))
		temp_list = list()
		temp_list = splittext(id_with_download_string, ";")
		for(var/N in temp_list)
			id_with_download += text2num(N)

/obj/machinery/r_n_d/server/process()
	if(prob(3) && plays_sound)
		playsound(loc, SFX_COMPUTER_AMBIENCE, 50, TRUE)

	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.get_readonly_air()
	switch(environment.temperature())
		if(0 to T0C)
			health = min(100, health + 1)
		if(T0C to (T20C + 20))
			health = clamp(health, 0, 100)
		if((T20C + 20) to INFINITY)
			health = max(0, health - 1)
	if(health <= 0)
		/*griefProtection() This seems to get called twice before running any code that deletes/damages the server or it's files anwyay.
							refreshParts and the hasReq procs that get called by this are laggy and do not need to be called by every server on the map every tick */
		var/updateRD = 0
		files.known_designs = list()
		for(var/v in files.known_tech)
			var/datum/tech/tech = files.known_tech[v]
			// Slowly decrease research if health drops below 0
			if(prob(1))
				updateRD++
				tech.level--
		if(updateRD)
			files.RefreshResearch()
	if(delay)
		delay--
	else
		produce_heat(heat_gen)
		delay = initial(delay)

/obj/machinery/r_n_d/server/emp_act(severity)
	griefProtection()
	return ..()

/obj/machinery/r_n_d/server/ex_act(severity, target)
	griefProtection()
	return ..()

/obj/machinery/r_n_d/server/blob_act(obj/structure/blob/B)
	griefProtection()
	return ..()

// Backup files to CentComm to help admins recover data after griefer attacks
/obj/machinery/r_n_d/server/proc/griefProtection()
	for(var/obj/machinery/r_n_d/server/centcom/C in SSmachines.get_by_type(/obj/machinery/r_n_d/server/centcom))
		files.push_data(C.files)

/obj/machinery/r_n_d/server/proc/produce_heat(heat_amt)
	var/datum/milla_safe/rnd_server_heat/milla = new()
	milla.invoke_async(src, heat_amt)

/datum/milla_safe/rnd_server_heat

/datum/milla_safe/rnd_server_heat/on_run(obj/machinery/r_n_d/server/server, heat)
	var/turf/location = get_turf(server)
	var/datum/gas_mixture/env = get_turf_air(location)

	if(server.stat & (NOPOWER|BROKEN))
		return
	if(env.temperature() >= (heat + T0C))
		return

	var/transfer_moles = 0.25 * env.total_moles()

	var/datum/gas_mixture/removed = env.remove(transfer_moles)
	if(!removed)
		return

	var/heat_capacity = removed.heat_capacity()
	if(heat_capacity == 0 || heat_capacity == null)
		heat_capacity = 1
	removed.set_temperature(min((removed.temperature() * heat_capacity + server.heating_power) / heat_capacity, 1000))
	env.merge(removed)

/obj/machinery/r_n_d/server/attackby(obj/item/I, mob/user, params)
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/machinery/r_n_d/server/screwdriver_act(mob/living/user, obj/item/I)
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return TRUE
	. = default_deconstruction_screwdriver(user, "[base_icon_state]_unscrewed", base_icon_state, I)

/obj/machinery/r_n_d/server/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return .
	if(!panel_open)
		add_fingerprint(user)
		to_chat(user, span_warning("Сначала откройте техническую панель."))
		return .
	griefProtection()
	default_deconstruction_crowbar(user, I)

/obj/machinery/r_n_d/server/attack_hand(mob/user)
	if(..())
		return TRUE

	if(disabled)
		return

	if(shocked)
		add_fingerprint(user)
		shock(user,50)
	return

/obj/machinery/r_n_d/server/proc/add_usage_log(mob/user, datum/design/built_design, obj/machinery/r_n_d/machine)
	var/time_created = station_time_timestamp()
	var/user_name = user.name
	var/user_job = NOJOB_STATUS_RUS
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		user_name = human_user.get_authentification_name()
		user_job = human_user.get_assignment()
	var/blueprint_name = built_design.build_object_name || built_design.name || "Неизвестный шаблон"
	var/used_machine = machine.declent_ru(ACCUSATIVE)

	LAZYINITLIST(usage_logs)
	usage_logs.len++
	usage_logs[length(usage_logs)] = list(time_created, user_name, user_job, blueprint_name, used_machine)

/obj/machinery/r_n_d/server/proc/clear_logs(mob/user)
	if(!LAZYLEN(usage_logs))
		return
	var/time_cleared = station_time_timestamp()
	var/user_name = user.name
	var/user_job = NOJOB_STATUS_RUS
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		user_name = human_user.get_authentification_name()
		user_job = human_user.get_assignment()

	LAZYINITLIST(logs_for_logs_clearing)
	logs_for_logs_clearing.len++
	logs_for_logs_clearing[length(logs_for_logs_clearing)] = list(time_cleared, user_name, user_job)

	LAZYCLEARLIST(usage_logs)

/obj/machinery/r_n_d/server/proc/is_design_blacklisted(design_id)
	return (design_id in design_blacklist)

/**
 * MARK: R&D Server variations
 */

/obj/machinery/r_n_d/server/core
	name = "Core R&D Server"
	id_with_upload_string = "1;3"
	id_with_download_string = "1;3"
	server_id = 1
	plays_sound = 1

/obj/machinery/r_n_d/server/core/get_ru_names()
	return list(
		NOMINATIVE = "центральный сервер НИО",
		GENITIVE = "центрального сервера НИО",
		DATIVE = "центральному серверу НИО",
		ACCUSATIVE = "центральный сервер НИО",
		INSTRUMENTAL = "центральным сервером НИО",
		PREPOSITIONAL = "центральном сервере НИО",
	)

/obj/machinery/r_n_d/server/robotics
	name = "Robotics and Mechanic R&D Server"
	id_with_upload_string = "1;2;4;6"
	id_with_download_string = "1;2;4;6"
	server_id = 2

/obj/machinery/r_n_d/server/robotics/get_ru_names()
	return list(
		NOMINATIVE = "сервер робототехники и механики НИО",
		GENITIVE = "сервера робототехники и механики НИО",
		DATIVE = "серверу робототехники и механики НИО",
		ACCUSATIVE = "сервер робототехники и механики НИО",
		INSTRUMENTAL = "сервером робототехники и механики НИО",
		PREPOSITIONAL = "сервере робототехники и механики НИО",
	)

/obj/machinery/r_n_d/server/centcom
	name = "CentComm. Central R&D Database"
	server_id = -1

/obj/machinery/r_n_d/server/centcom/get_ru_names()
	return list(
		NOMINATIVE = "сервер НИО ЦК",
		GENITIVE = "сервера НИО ЦК",
		DATIVE = "серверу НИО ЦК",
		ACCUSATIVE = "сервер НИО ЦК",
		INSTRUMENTAL = "сервером НИО ЦК",
		PREPOSITIONAL = "сервере НИО ЦК",
	)

/obj/machinery/r_n_d/server/centcom/Initialize(mapload)
	. = ..()
	var/list/no_id_servers = list()
	var/list/server_ids = list()
	for(var/obj/machinery/r_n_d/server/server as anything in SSmachines.get_by_type(/obj/machinery/r_n_d/server))
		switch(server.server_id)
			if(-1)
				continue
			if(0)
				no_id_servers += server
			else
				server_ids += server.server_id

	for(var/obj/machinery/r_n_d/server/server as anything in no_id_servers)
		var/num = 1
		while(!server.server_id)
			if(num in server_ids)
				num++
			else
				server.server_id = num
				server_ids += num
		no_id_servers -= server

/obj/machinery/r_n_d/server/centcom/process()
	return PROCESS_KILL	//don't need process()

/**
 * MARK: R&D Server Controller
 */

/obj/machinery/computer/rdservercontrol
	name = "R&D server controller"
	desc = "Комьютер, предназначенный для администрирования системы серверов НИО."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_LAVENDER
	circuit = /obj/item/circuitboard/rdservercontrol
	req_access = list(ACCESS_RD)
	var/screen = 0
	var/obj/machinery/r_n_d/server/temp_server
	var/list/servers = list()
	var/list/consoles = list()
	var/badmin = 0
	var/syndicate = 0 //добавленный для синдибазы флаг

/obj/machinery/computer/rdservercontrol/get_ru_names()
	return list(
		NOMINATIVE = "консоль управления серверами НИО",
		GENITIVE = "консоли управления серверами НИО",
		DATIVE = "консоли управления серверами НИО",
		ACCUSATIVE = "консоль управления серверами НИО",
		INSTRUMENTAL = "консолью управления серверами НИО",
		PREPOSITIONAL = "консоли управления серверами НИО",
	)

/obj/machinery/computer/rdservercontrol/Initialize(mapload)
	. = ..()
	if(is_taipan(z))
		syndicate = 1
		req_access = list(ACCESS_SYNDICATE_RESEARCH_DIRECTOR)

/obj/machinery/computer/rdservercontrol/emag_act(mob/user)
	if(emagged)
		return FALSE

	add_attack_logs(user, src, "emagged")
	playsound(src, 'sound/effects/sparks4.ogg', 75, TRUE)
	emagged = TRUE
	req_access = list()

	if(user)
		balloon_alert(user, "протоколы безопасности взломаны")

	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/rdservercontrol/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return

	if(!allowed(user) && !isobserver(user))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		balloon_alert(user, "отказано в доступе!")
		return

	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/computer/rdservercontrol/ui_interact(mob/user, datum/tgui/ui)
	if(!length(servers) || !length(consoles))
		refresh_cache()

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RdServerControl", DECLENT_RU_CAP(src, NOMINATIVE))
		ui.open()

/obj/machinery/computer/rdservercontrol/ui_data(mob/user)
	var/list/data = list()
	data["screen"] = screen
	var/list/server_list = list()
	for(var/obj/machinery/r_n_d/server/server as anything in servers)
		if(!server || QDELETED(server))
			continue

		server_list += list(list(
			"name" = DECLENT_RU_CAP(server, NOMINATIVE),
			"id" = server.server_id
		))

	data["servers"] = server_list

	if(temp_server)
		data["temp_server_name"] = DECLENT_RU_CAP(temp_server, NOMINATIVE)
		var/list/tech_list = list()
		for(var/tech_id, tech in temp_server.files.known_tech)
			var/datum/tech/T = tech // Вот здесь мы объясняем компилятору тип
			if(!T || T.level < 1)
				continue
			tech_list += list(list(
				"name" = T.name,
				"id" = T.id,
				"level" = T.level
			))
		data["technologies"] = tech_list

		var/list/design_list = list()
		for(var/id, design in temp_server.files.known_designs)
			var/datum/design/D = design // Объясняем тип
			if(!D)
				continue
			var/display_name = D.build_object_name || D.name || "Неизвестный шаблон"
			design_list += list(list(
				"name" = display_name,
				"id" = D.id,
				"blacklisted" = (D.id in temp_server.design_blacklist)
			))
		data["designs"] = design_list

		var/list/console_data = list()
		for(var/obj/machinery/computer/rdconsole/console as anything in consoles)
			if(!console || QDELETED(console))
				continue
			var/turf/console_turf = get_turf(console)
			console_data += list(list(
				"id" = console.id,
				"loc" = (console_turf && console_turf.loc) ? console_turf.loc.name : "Неизвестно",
				"upload" = (console.id in temp_server.id_with_upload) ? 1 : 0,
				"download" = (console.id in temp_server.id_with_download) ? 1 : 0
			))
		data["consoles"] = console_data

		if(screen == RD_SERVER_SCREEN_LOGS)
			data["usage_logs"] = temp_server.usage_logs || list()
			data["clear_logs"] = temp_server.logs_for_logs_clearing || list()
		else
			data["usage_logs"] = list()
			data["clear_logs"] = list()

	return data

/obj/machinery/computer/rdservercontrol/ui_act(action, list/params)
	if(..())
		return

	if(!allowed(usr) && !isobserver(usr))
		to_chat(usr, span_warning("Отказано в доступе!"))
		return

	var/is_syndicate = syndicate

	switch(action)
		if("select_server")
			var/target_id = text2num(params["id"])
			for(var/obj/machinery/r_n_d/server/server as anything in servers)
				if(!server || QDELETED(server))
					continue
				if(server.server_id == target_id)
					if(server.syndicate != is_syndicate)
						continue

					temp_server = server
					screen = RD_SERVER_SCREEN_DATA
					return TRUE

		if("set_screen")
			var/new_screen = text2num(params["target"])
			if(new_screen == RD_SERVER_SCREEN_LOGS)
				if(!temp_server || QDELETED(temp_server))
					return FALSE
				var/key = tgui_input_text(usr, "Введите ключ дешифровки", "Проверка безопасности")
				if(key != temp_server.logs_decryption_key)
					to_chat(usr, span_danger("Неверный ключ!"))
					return FALSE

			if(new_screen == RD_SERVER_SCREEN_MAIN)
				temp_server = null

			screen = new_screen
			return TRUE

		if("reset_tech")
			if(!temp_server || QDELETED(temp_server))
				return
			var/tech_id = params["tech_id"]
			var/choice = tgui_alert(usr, "Сбросить уровень технологии?", "Внимание", list("Да", "Нет"))
			if(choice == "Да")
				var/datum/tech/tech = temp_server.files.known_tech[tech_id]
				if(tech)
					tech.level = 1
				temp_server.files.RefreshResearch()
			return TRUE

		if("toggle_access")
			if(!temp_server ||  QDELETED(temp_server))
				return
			var/c_id = text2num(params["console_id"])
			var/type = params["type"]
			var/list/target_list = (type == "upload") ? temp_server.id_with_upload : temp_server.id_with_download
			if(c_id in target_list)
				target_list -= c_id
			else
				target_list += c_id
			return TRUE

		if("clear_logs")
			if(temp_server && !QDELETED(temp_server) && screen == RD_SERVER_SCREEN_LOGS)
				temp_server.clear_logs(usr)
				return TRUE

		if("toggle_blacklist")
			if(!temp_server || QDELETED(temp_server))
				return
			var/d_id = params["design_id"]
			if(d_id in temp_server.design_blacklist)
				temp_server.design_blacklist -= d_id
			else
				temp_server.design_blacklist += d_id
			return TRUE

	return ..()

/obj/machinery/computer/rdservercontrol/proc/refresh_cache()
	servers = list()
	consoles = list()
	var/is_syndicate = syndicate

	for(var/obj/machinery/r_n_d/server/server as anything in SSmachines.get_by_type(/obj/machinery/r_n_d/server))
		if(server.syndicate == is_syndicate)
			servers += server

	for(var/obj/machinery/computer/rdconsole/console as anything in SSmachines.get_by_type(/obj/machinery/computer/rdconsole))
		if(console.syndicate == is_syndicate)
			consoles += console

#undef RD_SERVER_SCREEN_MAIN
#undef RD_SERVER_SCREEN_ACCESS
#undef RD_SERVER_SCREEN_DATA
#undef RD_SERVER_SCREEN_LOGS
