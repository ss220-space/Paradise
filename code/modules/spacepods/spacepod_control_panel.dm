/datum/ui_module/spacepod_control_panels
	name = "Панель управления космическим челноком"
	var/obj/spacepod/pod
	/// Mob whose HUD we hid while the panel was open, or null.
	var/mob/hud_hidden_user
	/// HUD style the player had before we hid it, restored when the panel closes.
	var/hud_hidden_version = HUD_STYLE_STANDARD

/datum/ui_module/spacepod_control_panels/ui_state(mob/user)
	if(isobserver(user))
		return GLOB.observer_state
	return GLOB.not_incapacitated_state

/datum/ui_module/spacepod_control_panels/ui_host(mob/user)
	return pod // Default src.

/datum/ui_module/spacepod_control_panels/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(QDELETED(user.client))
			return
		var/datum/tgui_window/window = user.client.tgui_windows[SKIN_POD_PANEL]
		if(!window)
			window = new /datum/tgui_window(user.client, SKIN_POD_PANEL)
		ui = new(user, src, "SpacepodControlPanel", name)
		if(ui.open(window))
			winset(user.client, SKIN_POD_PANEL, "is-visible=true")
			hide_player_hud(user)

/datum/ui_module/spacepod_control_panels/ui_close(mob/user)
	restore_player_hud(user)
	var/datum/tgui/ui = SStgui.get_open_ui(user, src)
	if(ui)
		ui.close(TRUE)
	if(!QDELETED(user?.client))
		winset(user.client, SKIN_POD_PANEL, "is-visible=false")

/datum/ui_module/spacepod_control_panels/Destroy()
	restore_player_hud()
	return ..()

// MARK: Player HUD control
/datum/ui_module/spacepod_control_panels/proc/hide_player_hud(mob/user)
	var/datum/hud/user_hud = user?.hud_used
	if(QDELETED(user?.client) || !user_hud)
		return
	var/previous_version = user_hud.hud_version
	if(hud_hidden_user || previous_version == HUD_STYLE_NOHUD)
		return
	hud_hidden_user = user
	hud_hidden_version = previous_version
	user_hud.show_hud(HUD_STYLE_NOHUD)
	user.client.screen |= user_hud.infodisplay

/// Restores the HUD that was hidden when the panel opened.
/datum/ui_module/spacepod_control_panels/proc/restore_player_hud(mob/user)
	if(user && hud_hidden_user && user != hud_hidden_user)
		return
	var/mob/hidden_user = hud_hidden_user
	var/restore_version = hud_hidden_version
	hud_hidden_user = null
	hud_hidden_version = HUD_STYLE_STANDARD
	var/datum/hud/user_hud = hidden_user?.hud_used
	if(!user_hud)
		return
	if(QDELETED(hidden_user.client))
		user_hud.hud_version = restore_version
		return
	user_hud.show_hud(restore_version)
	for(var/atom/movable/screen/ammo/ammo_hud as anything in user_hud.ammo_hud_list)
		hidden_user.client.screen += ammo_hud


// MARK: ui_data
/datum/ui_module/spacepod_control_panels/ui_data(mob/user)
	var/list/data = list()
	data["vessel"] = pod.name
	data["electricity"] = create_electricity_panel_data()
	data["engines"] = create_engines_panel_data()
	data["fuel"] = create_fuel_panel_data()
	data["weapons"] = create_weapons_panel_data()
	data["life_support"] = create_life_support_data()
	data["integrity"] = create_integrity_panel_data()
	data["misc"] = create_misc_panel_data()
	return data

/datum/ui_module/spacepod_control_panels/proc/get_slot_ui_data(slot_id)
	var/list/modules_data = list()
	for(var/obj/item/spacepod_module/module as anything in pod.systems.get_slot(slot_id))
		modules_data += list(module.get_ui_data())
	return modules_data

/datum/ui_module/spacepod_control_panels/proc/create_electricity_panel_data()
	var/list/panel = list(
		"exists" = FALSE,
		"battery_id" = null,
		"link" = FALSE,
		"power" = 0,
		"capacity" = 0,
		"percent" = 0,
	)
	var/list/batteries = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_BATTERY)
	if(length(batteries))
		var/obj/item/spacepod_module/battery/battery = batteries[1]
		var/list/battery_data = battery.get_ui_data()
		panel["exists"] = TRUE
		panel["battery_id"] = battery_data["id"]
		panel["link"] = battery_data["link"]
		panel["power"] = battery_data["power"]
		panel["capacity"] = battery_data["capacity"]
		panel["percent"] = battery_data["percent"]

	var/list/consumers = list()
	for(var/obj/item/spacepod_module/module as anything in pod.systems.modules)
		if(module.consume_power > 0)
			consumers += list(module.get_ui_data())
	panel["consumers"] = consumers
	return panel

/datum/ui_module/spacepod_control_panels/proc/create_engines_panel_data()
	var/list/panel = list()
	var/list/engines = list()
	var/list/pod_engines = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_ENGINE) + pod.systems.get_slot(SPACEPOD_MODULE_SLOT_APU)
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine as anything in pod_engines)
		engines += list(engine.get_ui_data())
	panel["engines"] = engines

	panel["gyroscope"] = null
	var/list/gyroscopes = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_GYRO)
	if(length(gyroscopes))
		var/obj/item/spacepod_module/gyroscope/gyro = gyroscopes[1]
		panel["gyroscope"] = gyro.get_ui_data()
	return panel

/datum/ui_module/spacepod_control_panels/proc/create_fuel_panel_data()
	var/list/panel = list(
		"fuel_tanks" = get_slot_ui_data(SPACEPOD_MODULE_SLOT_FUEL_TANK),
		"fuel_pumps" = get_slot_ui_data(SPACEPOD_MODULE_SLOT_FUEL_PUMP),
	)
	return panel

/datum/ui_module/spacepod_control_panels/proc/create_weapons_panel_data()
	var/list/panel = list(
		"module" = null,
		"guns" = list(),
	)
	var/list/weapons = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_WEAPON)
	if(!length(weapons))
		return panel
	var/obj/item/spacepod_module/weapon/weapon = weapons[1]
	var/list/weapon_data = weapon.get_ui_data()
	panel["guns"] = weapon_data["guns"]
	panel["module"] = weapon_data
	return panel

/datum/ui_module/spacepod_control_panels/proc/create_life_support_data()
	var/list/panel = list()
	var/obj/item/spacepod_module/life_support/life_supports = pod.systems.get_misc_module(/obj/item/spacepod_module/life_support)
	panel["exists"] = !isnull(life_supports)
	if(!isnull(pod.internal_tank))
		var/list/airtank = list()
		airtank["name"] = pod.internal_tank.declent_ru(NOMINATIVE)
		airtank["enable"] = !isnull(life_supports) && life_supports.enable
		airtank["volume"] = pod.internal_tank.volume
		airtank["pressure"] = pod.internal_tank.return_pressure()
		airtank["low_pressure"] = pod.internal_tank.return_pressure() < 0.25 * pod.internal_tank.maximum_pressure
		panel["airtank"] = airtank
	else
		panel["airtank"] = null

	var/list/atmos = list()
	if(!isnull(life_supports) && life_supports.enable)
		atmos["pressure"] = pod.cabin_air.return_pressure()
		atmos["low_pressure"] = pod.cabin_air.return_pressure() < 0.8 * ONE_ATMOSPHERE
		var/temperature = pod.cabin_air.temperature()
		atmos["temperature"] = temperature
		atmos["low_temperature"] = temperature < T0C || temperature > T100C
	else
		var/turf/pod_location = get_turf(pod)
		var/datum/gas_mixture/external_air = pod_location.get_readonly_air()
		atmos["pressure"] = external_air.return_pressure()
		atmos["low_pressure"] = external_air.return_pressure() < 0.8 * ONE_ATMOSPHERE
		var/temperature = external_air.temperature()
		atmos["temperature"] = temperature
		atmos["low_temperature"] = temperature < T0C || temperature > T100C
	panel["atmos"] = atmos
	return panel

/datum/ui_module/spacepod_control_panels/proc/create_integrity_panel_data()
	var/list/panel = list()
	var/list/hull = list()
	hull["name"] = "Корпус челнока"
	hull["integrity"] = pod.obj_integrity
	hull["max_integrity"] = pod.max_integrity
	hull["integrity_warn"] = pod.obj_integrity < 0.25 * pod.max_integrity
	hull["extenguish_charges"] = 0
	var/obj/item/spacepod_module/fire_extingusher/fire_extenguisher = pod.systems.get_misc_module(/obj/item/spacepod_module/fire_extingusher)
	if(!isnull(fire_extenguisher))
		hull["extenguish_charges"] = fire_extenguisher.charges
	panel["hull"] = hull

	var/list/modules_data = list()
	for(var/obj/item/spacepod_module/module as anything in pod.systems.modules)
		modules_data += list(module.get_ui_data())
	panel["modules"] = modules_data
	return panel

/datum/ui_module/spacepod_control_panels/proc/create_misc_panel_data()
	var/list/panel = list()
	var/obj/item/spacepod_module/key_lock/key_lock = pod.systems.get_misc_module(/obj/item/spacepod_module/key_lock)
	panel["key_lock"] = !isnull(key_lock) ? list("locked" = !pod.unlocked) : null

	var/obj/item/spacepod_module/catapult_module/catapult = pod.systems.get_misc_module(/obj/item/spacepod_module/catapult_module)
	panel["catapult"] = !isnull(catapult) ? catapult.get_ui_data() : null

	var/obj/item/spacepod_module/tracker/tracker = pod.systems.get_misc_module(/obj/item/spacepod_module/tracker)
	panel["tracker"] = !isnull(tracker) ? tracker.get_ui_data() : null
	return panel

/datum/ui_module/spacepod_control_panels/proc/find_module(module_uid)
	var/obj/item/spacepod_module/module = locateUID(module_uid)
	if(!istype(module) || module.systems != pod.systems)
		return null
	return module

/datum/ui_module/spacepod_control_panels/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/spacepod_panel),
	)


// MARK: ui_act
/datum/ui_module/spacepod_control_panels/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(usr != pod.pilot)
		return FALSE

	. = TRUE

	playsound(pod.loc, SFX_TERMINAL_TYPE, 25, TRUE)
	switch(action)
		if("switch_powernet_link")
			switch_powernet_link(params["id"])
		if("switch_enable")
			switch_enable(params["id"])
		if("ignite_engine")
			ignite_engine(params["id"])
		if("switch_generator_enable")
			switch_generator_enable(params["id"])
		if("select_rpm_provider")
			select_engine_rpm_provider(params["id"], params["destination"])
		if("toggle_weapon_safety")
			toggle_weapon_safety(params["id"])
		if("reload_weapon")
			reload_weapon(params["id"])
		if("switch_airtank")
			switch_airtank()
		if("extinguish")
			extinguish_module(params["id"])
		if("toggle_lock")
			pod.toggle_lock(usr)
		if("catapult_pilot")
			pod.catapult_pilot(TRUE)
		if("exit_pod")
			pod.exit_pod(usr)
		if("map_click")
			handle_map_click(usr, params)
		else
			return FALSE

/// Proxies a click made on a transparent area of the control panel HUD to the game map underneath.
/datum/ui_module/spacepod_control_panels/proc/handle_map_click(mob/user, list/click_params)
	var/client/user_client = user.client
	if(!user_client)
		return FALSE
	var/list/map_size = splittext(winget(user_client, "mapwindow.map", "size"), "x")
	if(length(map_size) < 2)
		return FALSE
	var/map_width = text2num(map_size[1])
	var/map_height = text2num(map_size[2])
	if(!map_width || !map_height)
		return FALSE

	var/list/loc_data = get_loc_from_mousepos(click_params["x"], click_params["y"], map_width, map_height, user_client)
	var/turf/target = loc_data[1]
	if(isnull(target))
		return FALSE

	var/list/modifiers = list()
	modifiers[BUTTON] = click_params["button"] || LEFT_CLICK
	modifiers[modifiers[BUTTON]] = "1"
	if(click_params["ctrl"])
		modifiers[CTRL_CLICK] = "1"
	if(click_params["alt"])
		modifiers[ALT_CLICK] = "1"
	if(click_params["shift"])
		modifiers[SHIFT_CLICK] = "1"
	modifiers[ICON_X] = "[loc_data[2]]"
	modifiers[ICON_Y] = "[loc_data[3]]"

	user_client.Click(target, target, "mapwindow.map", list2params(modifiers))
	return TRUE


/datum/ui_module/spacepod_control_panels/proc/switch_powernet_link(module_uid)
	var/obj/item/spacepod_module/module = find_module(module_uid)
	if(isnull(module))
		return
	module.connection_power_net = !module.connection_power_net

/datum/ui_module/spacepod_control_panels/proc/switch_enable(module_uid)
	var/obj/item/spacepod_module/module = find_module(module_uid)
	if(isnull(module) || module.integrity <= 0)
		return
	if(module.enable)
		module.turn_off()
	else
		module.turn_on()

/datum/ui_module/spacepod_control_panels/proc/ignite_engine(module_uid)
	var/obj/item/spacepod_module/fuel_tank/engine/target_engine = find_module(module_uid)
	if(!istype(target_engine))
		return
	if(target_engine.enable)
		target_engine.turn_off()
		return
	if(target_engine.is_apu())
		target_engine.turn_on()
		return

	var/list/apus = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_APU)
	if(!length(apus))
		return
	var/obj/item/spacepod_module/fuel_tank/engine/apu/apu = apus[1]
	apu.select_rpm_destination_engine(target_engine)
	addtimer(CALLBACK(src, PROC_REF(post_ignite_engine), target_engine), 3 SECONDS)

/datum/ui_module/spacepod_control_panels/proc/post_ignite_engine(obj/item/spacepod_module/fuel_tank/engine/target_engine)
	if(QDELETED(target_engine))
		return
	target_engine.turn_on()

/datum/ui_module/spacepod_control_panels/proc/switch_generator_enable(module_uid)
	var/obj/item/spacepod_module/fuel_tank/engine/target_engine = find_module(module_uid)
	if(!istype(target_engine))
		return
	if(!target_engine.generator_enable)
		target_engine.enable_power_generator()
	else
		target_engine.generator_enable = FALSE

/datum/ui_module/spacepod_control_panels/proc/select_engine_rpm_provider(module_uid, destination_uid)
	var/obj/item/spacepod_module/fuel_tank/engine/apu/target_engine = find_module(module_uid)
	if(!istype(target_engine))
		return
	var/obj/item/spacepod_module/fuel_tank/engine/destination_engine = find_module(destination_uid)
	target_engine.select_rpm_destination_engine(destination_engine)

/datum/ui_module/spacepod_control_panels/proc/get_weapon_slot(weapon_slot_id)
	var/list/weapons = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_WEAPON)
	if(!length(weapons))
		return null
	var/obj/item/spacepod_module/weapon/weapon = weapons[1]
	if(weapon.primary.id == weapon_slot_id)
		return weapon.primary
	if(weapon.secondary.id == weapon_slot_id)
		return weapon.secondary
	return null

/datum/ui_module/spacepod_control_panels/proc/toggle_weapon_safety(weapon_slot_id)
	var/datum/spacepod_weapon_slot/weapon_slot = get_weapon_slot(weapon_slot_id)
	if(isnull(weapon_slot))
		return
	weapon_slot.safety = !weapon_slot.safety

/datum/ui_module/spacepod_control_panels/proc/reload_weapon(weapon_slot_id)
	var/datum/spacepod_weapon_slot/weapon_slot = get_weapon_slot(weapon_slot_id)
	if(isnull(weapon_slot))
		return
	weapon_slot.reload(pod, usr)

/datum/ui_module/spacepod_control_panels/proc/switch_airtank()
	var/obj/item/spacepod_module/life_support/life_supports = pod.systems.get_misc_module(/obj/item/spacepod_module/life_support)
	if(isnull(life_supports))
		return
	life_supports.enable = !life_supports.enable
	to_chat(usr, span_notice("Подача воздуха: [life_supports.enable ? "из баллона" : "снаружи"]."))

/datum/ui_module/spacepod_control_panels/proc/extinguish_module(module_uid)
	var/obj/item/spacepod_module/target_module = find_module(module_uid)
	if(isnull(target_module) || !target_module.fire)
		return
	var/obj/item/spacepod_module/fire_extingusher/fire_extenguisher = pod.systems.get_misc_module(/obj/item/spacepod_module/fire_extingusher)
	if(isnull(fire_extenguisher) || fire_extenguisher.charges <= 0)
		return
	fire_extenguisher.charges--
	target_module.fire = FALSE
