/obj/machinery/computer/drone_control
	name = "maintenance drone control console"
	desc = "Используется для наблюдения за популяцией дронов на станции и сборщиком, который их обслуживает."
	icon_screen = "power"
	icon_keyboard = "power_key"
	req_access = list(ACCESS_ENGINE_EQUIP)
	circuit = /obj/item/circuitboard/drone_control

	/// The linked fabricator
	var/obj/machinery/drone_fabricator/dronefab
	/// Used when pinging drones
	var/drone_call_area = "Engineering"
	/// Cooldown for area pings
	COOLDOWN_DECLARE(ping_cooldown)

/obj/machinery/computer/drone_control/get_ru_names()
	return list(
		NOMINATIVE = "консоль управления дронами",
		GENITIVE = "консоли управления дронами",
		DATIVE = "консоли управления дронами",
		ACCUSATIVE = "консоль управления дронами",
		INSTRUMENTAL = "консолью управления дронами",
		PREPOSITIONAL = "консоли управления дронами",
	)

/obj/machinery/computer/drone_control/Initialize(mapload)
	. = ..()
	find_fab()

/obj/machinery/computer/drone_control/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		balloon_alert(user, "доступ запрещён!")
		playsound(src, SFX_BUTTON_DENIED, 20)
		return

	ui_interact(user)

/obj/machinery/computer/drone_control/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/computer/drone_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/drone_control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DroneConsole", DECLENT_RU_CAP(src, NOMINATIVE))
		ui.open()

/obj/machinery/computer/drone_control/ui_data(mob/user)
	var/list/data = list()
	data["drone_fab"] = FALSE
	data["fab_power"] = null
	data["drone_prod"] = null
	data["drone_progress"] = null
	if(dronefab)
		data["drone_fab"] = TRUE
		data["fab_power"] = dronefab.stat & NOPOWER ? FALSE : TRUE
		data["drone_prod"] = dronefab.produce_drones
		data["drone_progress"] = dronefab.drone_progress
	data["selected_area"] = drone_call_area
	data["ping_cd"] = !COOLDOWN_FINISHED(src, ping_cooldown)

	data["drones"] = list()
	for(var/mob/living/silicon/robot/drone/drone in GLOB.silicon_mob_list)
		var/area/area = get_area(drone)
		var/turf/turf = get_turf(drone)
		var/list/drone_data = list(
			name = drone.real_name,
			uid = drone.UID(),
			stat = drone.stat,
			client = drone.client ? TRUE : FALSE,
			health = round(drone.health / drone.maxHealth, 0.1),
			charge = round(drone.cell.charge / drone.cell.maxcharge, 0.1),
			location = "[area] ([turf.x], [turf.y])",
			sync_cd = !COOLDOWN_FINISHED(drone, sync_cooldown),
		)
		data["drones"] += list(drone_data)
	return data

/obj/machinery/computer/drone_control/ui_static_data(mob/user)
	var/list/data = list()
	data["area_list"] = GLOB.TAGGERLOCATIONS
	return data

/obj/machinery/computer/drone_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	switch(action)
		if("find_fab")
			find_fab(usr)

		if("toggle_fab")
			if(QDELETED(dronefab))
				dronefab = null
				return

			dronefab.produce_drones = !dronefab.produce_drones
			to_chat(usr, span_notice("Вы [dronefab.produce_drones ? "включаете" : "отключаете"] производство дронов в ближайшем фабрикаторе."))
			var/toggle = dronefab.produce_drones ? "enabled" : "disabled"
			message_admins("[key_name_admin(usr)] [toggle == "enabled" ? "enabled" : "disabled"] maintenance drone production from the control console.")
			log_game("[key_name(usr)] [toggle == "enabled" ? "enabled" : "disabled"] maintenance drone production from the control console.")

		if("set_area")
			drone_call_area = params["area"]

		if("ping")
			COOLDOWN_START(src, ping_cooldown, 1 MINUTES) // to prevent chat spam
			to_chat(usr, span_notice("Вы отправляете запрос на обслуживание для всех активных дронов, выделяя зону [drone_call_area]."))
			for(var/mob/living/silicon/robot/drone/drone in GLOB.silicon_mob_list)
				if(drone.client && drone.stat == CONSCIOUS)
					to_chat(drone, span_boldnotice("-- Запрошено присутствие дрона в зоне: [drone_call_area]."))

		if("resync")
			var/mob/living/silicon/robot/drone/drone = locateUID(params["uid"])
			if(drone)
				COOLDOWN_START(drone, sync_cooldown, 1 MINUTES) // to prevent chat spam
				to_chat(usr, span_notice("Вы отправляете директиву на синхронизацию законов для дрона."))
				drone.law_resync()

		if("shutdown")
			var/mob/living/silicon/robot/drone/drone = locateUID(params["uid"])
			if(drone)
				to_chat(usr, span_warning("Вы отправляете команду на уничтожение несчастного дрона."))
				if(drone != usr) // Don't need to bug admins about a suicide
					message_admins("[key_name_admin(usr)] issued shutdown order for drone [key_name_admin(drone)] from control console.")
				log_game("[key_name(usr)] issued shutdown order for [key_name(drone)] from control console.")
				drone.shut_down()

/obj/machinery/computer/drone_control/proc/find_fab(mob/user)
	if(dronefab)
		return

	for(var/obj/machinery/drone_fabricator/fabricator in get_area(src))
		if(fabricator.stat & NOPOWER)
			continue

		dronefab = fabricator
		if(!user)
			return

		to_chat(user, span_notice("Фабрикатор дронов обнаружен."))

	if(!user)
		return

	to_chat(user, span_warning("Не удалось обнаружить фабрикатор дронов."))
