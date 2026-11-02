#define NOT_SELECTED_RPM_PROVIDER "Не передавать"

/datum/ui_module/spacepod_control_panels
	name = "Панель управления космическим челноком"
	var/obj/spacepod/pod

/datum/ui_module/spacepod_control_panels/ui_state(mob/user)
	if(isobserver(user))
		return GLOB.observer_state
	return GLOB.not_incapacitated_state

/datum/ui_module/spacepod_control_panels/ui_host(mob/user)
	return pod // Default src.

/// tgui window bound to the transparent "pod_panel" browser pane inside the
/// main window (same technique as the escape menu), so the game stays visible
/// behind the panel. Standalone popup windows can not be see-through.
/datum/tgui_window/pod_panel

/datum/tgui_window/pod_panel/close(can_be_suspended = TRUE)
	. = ..()
	if(client)
		winset(client, SKIN_POD_PANEL, "is-visible=0")

/datum/ui_module/spacepod_control_panels/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(!user.client)
			return
		// Open the panel as a transparent overlay pane inside the game window.
		// Transparent browsers require BYOND 516.1680+, fall back to a normal
		// pooled window otherwise.
		var/datum/tgui_window/window
		if(user.client.byond_build >= 1680)
			window = user.client.tgui_windows[SKIN_POD_PANEL]
			if(!window)
				window = new /datum/tgui_window/pod_panel(user.client, SKIN_POD_PANEL)
		ui = new(user, src, "SpacepodControlPanel", name)
		ui.open(window)

/datum/ui_module/spacepod_control_panels/ui_close(mob/user)
	var/datum/tgui/ui = SStgui.get_open_ui(user, src)
	if(!ui)
		return
	ui.close(TRUE)
	if(user.client)
		winset(user.client, SKIN_POD_PANEL, "is-visible=0")


// MARK: ui_data
/datum/ui_module/spacepod_control_panels/ui_data(mob/user)
	//create root data
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

/datum/ui_module/spacepod_control_panels/proc/create_electricity_panel_data()
	var/list/panel = list()
	panel["exists"] = FALSE
	var/list/batteries = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_BATTERY)
	for(var/obj/item/spacepod_module/battery/batt as anything in batteries)
		panel["exists"] = TRUE
		panel["battery_id"] = batt.id
		panel["link"] = batt.connection_power_net
		panel["power"] = round(batt.power, 1)
		panel["capacity"] = batt.power_capacity
		if(batt.power_capacity > 0)
			panel["percent"] = round(batt.power / batt.power_capacity * 100, 1)
		else
			panel["percent"] = 0
		break

	var/list/consumers = list()
	for(var/obj/item/spacepod_module/module in pod.systems.modules)
		if(module.consume_power > 0)
			var/list/consumer = list()
			consumer["id"] = module.id
			consumer["caption"] = module.caption
			consumer["name"] = module.module_name
			consumer["link"] = module.connection_power_net
			consumers += list(consumer)
	panel["consumers"] = consumers
	return panel

/datum/ui_module/spacepod_control_panels/proc/create_engines_panel_data()
	var/list/panel = list()
	var/list/engines = list()
	var/list/pod_engines = list()
	var/list/basic_engines = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_ENGINE)
	pod_engines += basic_engines
	pod_engines += pod.systems.get_slot(SPACEPOD_MODULE_SLOT_APU)
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine as anything in pod_engines)
		var/list/engine_data= list()
		engine_data["id"] = engine.id
		engine_data["caption"] = engine.caption
		engine_data["name"] = engine.module_name
		engine_data["enable"] = engine.enable
		engine_data["is_apu"] = engine.is_apu()
		engine_data["rpm"] = engine.current_rpm
		engine_data["rpm_percent"] = round(engine.current_rpm / engine.max_rpm * 100, 1)
		engine_data["rpm_warn"] = engine_data["rpm_percent"] > 0 && (engine_data["rpm_percent"] < 25 || engine_data["rpm_percent"] > 120)
		engine_data["fuel_pressure"] = round(engine.fuel_amount / engine.fuel_capacity * 100, 1)
		engine_data["fuel_pressure_warn"] = engine_data["fuel_pressure"] <= 30
		if(istype(engine, /obj/item/spacepod_module/fuel_tank/engine/apu))
			var/obj/item/spacepod_module/fuel_tank/engine/apu/apu_engine = engine
			engine_data["power_link"] = apu_engine.connection_power_net
			engine_data["selected_rpm_provide_engine"] = apu_engine.rpm_destination_engine ? apu_engine.rpm_destination_engine.module_name : NOT_SELECTED_RPM_PROVIDER
			var/rpm_destinations = list()
			rpm_destinations += NOT_SELECTED_RPM_PROVIDER
			for(var/obj/item/spacepod_module/fuel_tank/engine/dest_engine as anything in basic_engines)
				if(engine == dest_engine)
					continue
				rpm_destinations += dest_engine.module_name
			engine_data["rpm_provide_engines"] = rpm_destinations
		else
			engine_data["power_link"] = null
			engine_data["rpm_provide_engines"] = null
		engine_data["generator_enable"] = engine.generator_enable
		engine_data["generated_power"] = engine.generator_enable ? round(engine.current_rpm / engine.max_rpm * engine.generate_power, 1) : 0
		engine_data["temperature"] = 32 + rand(1, 10)
		engine_data["temperature_warn"] = FALSE
		engine_data["error_text"] = engine.error_text
		engines += list(engine_data)
	panel["engines"] = engines

	// Gyroscope
	panel["gyroscope"] = null
	var/list/gyroscopes = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_GYRO)
	for(var/obj/item/spacepod_module/gyroscope/gyro as anything in gyroscopes)
		var/gyroscope_data = list()
		gyroscope_data["id"] = gyro.id
		gyroscope_data["name"] = gyro.module_name
		gyroscope_data["power_link"] = gyro.connection_power_net
		gyroscope_data["enable"] = gyro.enable
		gyroscope_data["rpm"] = gyro.current_rpm
		gyroscope_data["rpm_percent"] = round(gyro.current_rpm / gyro.max_rpm * 100, 1)
		gyroscope_data["rpm_warn"] = gyroscope_data["rpm_percent"] < 10 || gyroscope_data["rpm_percent"] > 120
		gyroscope_data["temperature"] = 32 + rand(1, 10)
		gyroscope_data["temperature_warn"] = FALSE
		gyroscope_data["error_text"] = gyro.error_text
		panel["gyroscope"] = gyroscope_data

	return panel

/datum/ui_module/spacepod_control_panels/proc/create_fuel_panel_data()
	var/list/panel = list()
	var/fuel_tanks = list()
	var/list/pod_fuel_tanks = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_FUEL_TANK)
	for(var/obj/item/spacepod_module/fuel_tank/fuel_tank as anything in pod_fuel_tanks)
		var/tank_data = list()
		tank_data["id"] = fuel_tank.id
		tank_data["name"] = fuel_tank.module_name
		tank_data["caption"] = fuel_tank.caption
		tank_data["fuel_amount"] = fuel_tank.fuel_amount
		tank_data["fuel_capacity"] = fuel_tank.fuel_capacity
		tank_data["level_percent"] = round(fuel_tank.fuel_amount / fuel_tank.fuel_capacity * 100, 1)
		fuel_tanks += list(tank_data)
	panel["fuel_tanks"] = fuel_tanks

	var/list/pod_fuel_pumps = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_FUEL_PUMP)
	var/fuel_pumps = list()
	for(var/obj/item/spacepod_module/fuel_pump/pump as anything in pod_fuel_pumps)
		var/pump_data = list()
		pump_data["id"] = pump.id
		pump_data["name"] = pump.module_name
		pump_data["caption"] = pump.caption
		pump_data["enable"] = pump.enable
		pump_data["power_link"] = pump.connection_power_net
		pump_data["pump_speed"] = pump.enable ? pump.pump_speed : 0
		pump_data["temperature"] = 32 + rand(1, 10)
		pump_data["temperature_warn"] = FALSE
		pump_data["error_text"] = pump.error_text
		fuel_pumps += list(pump_data)
	panel["fuel_pumps"] = fuel_pumps
	return panel

/datum/ui_module/spacepod_control_panels/proc/create_weapons_panel_data()
	var/list/panel = list()
	var/list/weapons = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_WEAPON)
	if(!length(weapons))
		panel["module"] = null
		panel["guns"] = list()
		return panel

	var/obj/item/spacepod_module/weapon/weapon = weapons[1]
	var/module = list()
	module["id"] = weapon.id
	module["name"] = weapon.module_name
	module["enable"] = weapon.enable
	module["power_link"] = weapon.connection_power_net
	module["error_text"] = weapon.error_text
	panel["module"] = module
	var/guns = list()
	if(weapon.primary.weapon)
		guns += list(create_weapon_data(weapon.primary, TRUE))
	if(weapon.secondary.weapon)
		guns += list(create_weapon_data(weapon.secondary, FALSE))
	panel["guns"] = guns
	return panel

/datum/ui_module/spacepod_control_panels/proc/create_weapon_data(datum/spacepod_weapon_slot/gun_slot, is_primary)
	var/data = list()
	data["id"] = gun_slot.id
	data["name"] = gun_slot.weapon.declent_ru(NOMINATIVE)
	data["primary"] = is_primary
	data["safety"] = gun_slot.safety
	data["charging"] = gun_slot.charging
	if(isprojectilegun(gun_slot.weapon))
		data["type"] = 1
		var/obj/item/gun/projectile/projectile_gun = gun_slot.weapon
		data["ammo"] = projectile_gun.get_ammo()
		if(projectile_gun.magazine)
			data["capacity"] = projectile_gun.magazine.max_ammo
		else
			data["capacity"] = 0
	else if(isenergygun(gun_slot.weapon))
		data["type"] = 2
		var/obj/item/gun/energy/energy_gun = gun_slot.weapon
		data["ammo"] = energy_gun.get_ammo_count()
		data["capacity"] = energy_gun.get_max_ammo_count()
	else
		data["type"] = 3
		data["ammo"] = 0
		data["capacity"] = 0
	return data

/datum/ui_module/spacepod_control_panels/proc/create_life_support_data()
	var/list/panel = list()
	var/obj/item/spacepod_module/life_support/life_supports = pod.systems.get_misc_module(/obj/item/spacepod_module/life_support)
	panel["exists"] = life_supports != null
	if(pod.internal_tank != null)
		var/list/airtank = list()
		airtank["name"] = pod.internal_tank.declent_ru(NOMINATIVE)
		airtank["enable"] = life_supports != null && life_supports.enable
		airtank["volume"] = pod.internal_tank.volume
		airtank["pressure"] = pod.internal_tank.return_pressure()
		airtank["low_pressure"] = pod.internal_tank.return_pressure() < 0.25 * pod.internal_tank.maximum_pressure
		panel["airtank"] = airtank
	else
		panel["airtank"] = null
	var/list/atmos = list()
	if(life_supports != null && life_supports.enable)
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
	var/hull = list()
	hull["name"] = "Корпус челнока"
	hull["integrity"] = pod.obj_integrity
	hull["max_integrity"] = pod.max_integrity
	hull["integrity_warn"] = pod.obj_integrity < 0.25 * pod.max_integrity
	hull["extenguish_charges"] = 0
	var/obj/item/spacepod_module/fire_extingusher/fire_extenguisher = pod.systems.get_misc_module(/obj/item/spacepod_module/fire_extingusher)
	if(fire_extenguisher != null)
		hull["extenguish_charges"] = fire_extenguisher.charges
	panel["hull"] = hull

	var/modules = list()
	for(var/obj/item/spacepod_module/module in pod.systems.modules)
		var/module_data = list()
		module_data["id"] = module.id
		module_data["caption"] = module.caption
		module_data["name"] = module.module_name
		module_data["enable"] = module.enable
		module_data["integrity"] = module.integrity
		module_data["max_integrity"] = module.max_integrity
		module_data["integrity_warn"] = module.integrity < 0.5 * module.max_integrity
		module_data["fire"] = module.fire
		modules += list(module_data)
	panel["modules"] = modules
	return panel

/datum/ui_module/spacepod_control_panels/proc/create_misc_panel_data()
	var/list/panel = list()
	var/obj/item/spacepod_module/key_lock/key_lock = pod.systems.get_misc_module(/obj/item/spacepod_module/key_lock)
	if(key_lock != null)
		var/lock_data = list()
		lock_data["locked"] = !pod.unlocked
		panel["key_lock"] = lock_data
	else
		panel["key_lock"] = null

	var/obj/item/spacepod_module/catapult_module/pod_catapult = pod.systems.get_misc_module(/obj/item/spacepod_module/catapult_module)
	if(pod_catapult != null)
		var/catapult = list()
		catapult["id"] = pod_catapult.id
		catapult["enable"] = pod_catapult.enable
		panel["catapult"] = catapult
	else
		panel["catapult"] = null

	var/obj/item/spacepod_module/tracker/pod_tracker = pod.systems.get_misc_module(/obj/item/spacepod_module/tracker)
	if(pod_tracker != null)
		var/tracker_data = list()
		tracker_data["id"] = pod_tracker.id
		tracker_data["enable"] = pod_tracker.enable
		panel["tracker"] = tracker_data
	else
		panel["tracker"] = null
	return panel


//MARK: assets
/datum/asset/simple/spacepod_panel
	assets = list(
		"eng-idle.png" = 'icons/ui_icons/spacepod_panel/engine-idle.png',
		"eng-on.png" = 'icons/ui_icons/spacepod_panel/engine-on.png',
		"eng-off.png" = 'icons/ui_icons/spacepod_panel/engine-off.png',
		"eng-off-top.png" = 'icons/ui_icons/spacepod_panel/engine-off-top.png',
		"eng-fail.png" = 'icons/ui_icons/spacepod_panel/engine-fail.png',
	)

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
			var/id = params["id"]
			switch_powernet_link(id)
		if("switch_enable")
			var/id = params["id"]
			switch_enable(id)
		if("ignite_engine")
			var/id = params["id"]
			ignite_engine(id)
		if("switch_generator_enable")
			var/id = params["id"]
			switch_generator_enable(id)
		if("select_rpm_provider")
			var/id = params["id"]
			var/dest_name = params["destination"]
			select_engine_rpm_provider(id, dest_name)
		if("toggle_weapon_safety")
			var/id = params["id"]
			toggle_weapon_safety(id)
		if("reload_weapon")
			var/id = params["id"]
			reload_weapon(id)
		if("switch_airtank")
			switch_airtank()
		if("extinguish")
			var/id = params["id"]
			extinguish_module(id)
		if("toggle_lock")
			pod.toggle_lock(usr)
		if("catapult_pilot")
			pod.catapult_pilot(TRUE)
		if("map_click")
			handle_map_click(usr, params)
		else
			return FALSE

/// Proxies a click made on a transparent area of the control panel HUD to
/// the game map underneath. Clicks are translated from pane pixel
/// coordinates into world turf coordinates, honoring the current map zoom.
/datum/ui_module/spacepod_control_panels/proc/handle_map_click(mob/user, list/click_params)
	var/client/user_client = user.client
	if(!user_client)
		return FALSE
	var/turf/eye_turf = get_turf(user_client.eye)
	if(!eye_turf)
		return FALSE

	var/list/map_info = params2list(winget(user_client, "mapwindow.map", "size;view-size"))
	var/list/map_size = splittext(map_info["size"], "x")
	var/list/view_px = splittext(map_info["view-size"], "x")
	if(length(map_size) < 2 || length(view_px) < 2)
		return FALSE

	var/map_width = text2num(map_size[1])
	var/map_height = text2num(map_size[2])
	var/view_width = text2num(view_px[1])
	var/view_height = text2num(view_px[2])
	if(!map_width || !map_height || !view_width || !view_height)
		return FALSE

	var/list/view_tiles = getviewsize(user_client.view)
	var/tiles_x = view_tiles[1]
	var/tiles_y = view_tiles[2]
	var/tile_width = view_width / tiles_x
	var/tile_height = view_height / tiles_y
	if(!tile_width || !tile_height)
		return FALSE

	// Position inside the rendered map (letterboxing is centered).
	var/map_px = click_params["x"] - (map_width - view_width) / 2
	var/map_py = click_params["y"] - (map_height - view_height) / 2

	var/list/modifiers = list()
	modifiers[BUTTON] = click_params["button"] || LEFT_CLICK
	// Mark the button key itself (right -> RIGHT_CLICK and so on), the way
	// native map clicks do.
	modifiers[modifiers[BUTTON]] = "1"
	if(click_params["ctrl"])
		modifiers[CTRL_CLICK] = "1"
	if(click_params["alt"])
		modifiers[ALT_CLICK] = "1"
	if(click_params["shift"])
		modifiers[SHIFT_CLICK] = "1"

	// HUD screen objects (action buttons and the like) are drawn above the
	// map: forward the click to the one under the pointer, if any.
	var/list/native_view = view_to_pixels(user_client.view)
	var/map_scale = view_width / native_view[1]
	if(map_scale > 0)
		var/atom/movable/screen/screen_hit = get_screen_object_at(user, round(map_px / map_scale), round(map_py / map_scale))
		if(screen_hit)
			user_client.Click(screen_hit, screen_hit, "mapwindow.map", list2params(modifiers))
			return TRUE

	var/world_x = eye_turf.x + 0.5 - tiles_x / 2 + map_px / tile_width
	var/world_y = eye_turf.y + 0.5 - tiles_y / 2 + (view_height - map_py) / tile_height
	var/turf/target = locate(round(world_x), round(world_y), eye_turf.z)
	if(!target)
		return FALSE

	// Pick the topmost visible atom on the tile, like a normal map click
	// would (mobs and objects sit above the turf).
	var/atom/click_target = target
	for(var/atom/atom_on_tile as anything in target.contents)
		if(atom_on_tile.mouse_opacity == MOUSE_OPACITY_TRANSPARENT)
			continue
		if(atom_on_tile.invisibility || atom_on_tile.alpha <= 0)
			continue
		if(atom_on_tile.layer > click_target.layer)
			click_target = atom_on_tile

	// Screen-loc relative to the visible map area, as if the click was made
	// on the map control itself. X offsets are counted from the left edge of
	// the tile, Y offsets from its bottom edge (same as icon-x / icon-y).
	var/sx_tile = clamp(floor(map_px / tile_width) + 1, 1, tiles_x)
	var/sx_offset = clamp(round(map_px - (sx_tile - 1) * tile_width), 0, tile_width - 1)
	var/px_from_bottom = view_height - map_py
	var/sy_tile = clamp(floor(px_from_bottom / tile_height) + 1, 1, tiles_y)
	var/sy_offset = clamp(round(px_from_bottom - (sy_tile - 1) * tile_height), 0, tile_height - 1)
	modifiers[SCREEN_LOC] = "[sx_tile]:[sx_offset],[sy_tile]:[sy_offset]"
	modifiers[ICON_X] = "[sx_offset]"
	modifiers[ICON_Y] = "[sy_offset]"
	modifiers[VIS_X] = "[sx_tile]"
	modifiers[VIS_Y] = "[sy_tile]"

	// params must be a plain params string: the client-side click pipeline
	// runs params2list(params), which does not round-trip assoc lists.
	user_client.Click(click_target, target, "mapwindow.map", list2params(modifiers))
	return TRUE


/// Returns the interactive screen object (action buttons and other HUD
/// items) whose 32x32 cell contains the given native map pixel coordinates,
/// or null if the point misses every screen object.
/datum/ui_module/spacepod_control_panels/proc/get_screen_object_at(mob/user, native_px, native_py)
	var/client/user_client = user.client
	if(!user_client)
		return null

	var/list/candidates = list()
	for(var/atom/movable/screen/screen_atom as anything in user_client.screen)
		if(QDELETED(screen_atom) || !screen_atom.screen_loc)
			continue
		if(screen_atom.mouse_opacity == MOUSE_OPACITY_TRANSPARENT)
			continue
		if(screen_atom.alpha <= 0)
			continue
		// screen_loc_to_offset() expects paired "x,y" coordinates; single
		// token locs ("CENTER" on plane masters) and rectangular ranges
		// ("x1,y1 to x2,y2") are not parseable by it and belong to
		// non-clickable or non-standard objects anyway.
		if(!findtext(screen_atom.screen_loc, ",") || findtext(screen_atom.screen_loc, " to "))
			continue
		var/list/offset = list(0, 0)
		try
			offset = screen_loc_to_offset(screen_atom.screen_loc, user_client.view)
		catch(var/exception/error)
			log_runtime(error, screen_atom)
			continue
		if(native_px < offset[1] || native_px >= offset[1] + ICON_SIZE_X)
			continue
		if(native_py < offset[2] || native_py >= offset[2] + ICON_SIZE_Y)
			continue
		candidates += screen_atom

	if(!length(candidates))
		return null
	return candidates[length(candidates)]


/datum/ui_module/spacepod_control_panels/proc/switch_powernet_link(id)
	var/obj/item/spacepod_module/target_module = null
	for(var/obj/item/spacepod_module/module in pod.systems.modules)
		if(id == module.id)
			target_module = module
			break
	if(!target_module)
		return
	target_module.connection_power_net = !target_module.connection_power_net

/datum/ui_module/spacepod_control_panels/proc/switch_enable(id)
	var/obj/item/spacepod_module/target_module = null
	for(var/obj/item/spacepod_module/module in pod.systems.modules)
		if(id == module.id)
			target_module = module
			break
	if(!target_module || target_module.integrity <= 0)
		return
	if(target_module.enable)
		target_module.turn_off()
	else
		target_module.turn_on()

/datum/ui_module/spacepod_control_panels/proc/ignite_engine(id)
	var/apu_id = null
	var/obj/item/spacepod_module/fuel_tank/engine/target_engine = null
	var/list/total_engines = list()
	total_engines += pod.systems.get_slot(SPACEPOD_MODULE_SLOT_ENGINE)
	total_engines += pod.systems.get_slot(SPACEPOD_MODULE_SLOT_APU)
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine as anything in total_engines)
		if(id == engine.id)
			target_engine = engine
		if(engine.is_apu())
			apu_id = engine.id
	if(!target_engine || apu_id == null)
		return
	if(target_engine.enable)
		target_engine.turn_off()
		return
	if(target_engine.is_apu())
		target_engine.turn_on()
		return
	select_engine_rpm_provider_by_id(apu_id, id)
	addtimer(CALLBACK(src, PROC_REF(post_ignite_engine), target_engine), 3 SECONDS)

/datum/ui_module/spacepod_control_panels/proc/post_ignite_engine(obj/item/spacepod_module/fuel_tank/engine/target_engine)
	target_engine.turn_on()

/datum/ui_module/spacepod_control_panels/proc/switch_generator_enable(id)
	var/obj/item/spacepod_module/fuel_tank/engine/target_engine = null
	var/list/total_engines = list()
	total_engines += pod.systems.get_slot(SPACEPOD_MODULE_SLOT_ENGINE)
	total_engines += pod.systems.get_slot(SPACEPOD_MODULE_SLOT_APU)
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine as anything in total_engines)
		if(id == engine.id)
			target_engine = engine
			break
	if(!target_engine)
		return
	if(!target_engine.generator_enable)
		target_engine.enable_power_generator()
	else
		target_engine.generator_enable = FALSE

/datum/ui_module/spacepod_control_panels/proc/select_engine_rpm_provider(id, destination_engine_name)
	var/obj/item/spacepod_module/fuel_tank/engine/apu/target_engine = null
	var/obj/item/spacepod_module/fuel_tank/engine/destination_engine = null
	var/list/apu_list = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_APU)
	for(var/obj/item/spacepod_module/fuel_tank/engine/apu/apu as anything in apu_list)
		if(id == apu.id)
			target_engine = apu
	var/list/engines = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_ENGINE)
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine as anything in engines)
		if(destination_engine_name == engine.module_name)
			destination_engine = engine
	if(!target_engine)
		return
	if(destination_engine_name == NOT_SELECTED_RPM_PROVIDER || destination_engine == null)
		destination_engine = null
	target_engine.select_rpm_destination_engine(destination_engine)

/datum/ui_module/spacepod_control_panels/proc/select_engine_rpm_provider_by_id(id, destination_engine_id)
	var/obj/item/spacepod_module/fuel_tank/engine/apu/target_engine = null
	var/obj/item/spacepod_module/fuel_tank/engine/destination_engine = null
	var/list/apu_list = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_APU)
	for(var/obj/item/spacepod_module/fuel_tank/engine/apu/apu as anything in apu_list)
		if(id == apu.id)
			target_engine = apu
	var/list/engines = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_ENGINE)
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine as anything in engines)
		if(destination_engine_id == engine.id)
			destination_engine = engine
	if(!target_engine)
		return
	if(destination_engine_id == null || destination_engine == null)
		destination_engine = null
	target_engine.select_rpm_destination_engine(destination_engine)

/datum/ui_module/spacepod_control_panels/proc/toggle_weapon_safety(id)
	var/list/weapons = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_WEAPON)
	if(!length(weapons))
		return
	var/obj/item/spacepod_module/weapon/weapon_module = weapons[1]
	var/datum/spacepod_weapon_slot/weapon_slot = null
	if(weapon_module.primary.id == id)
		weapon_slot = weapon_module.primary
	if(weapon_module.secondary.id == id)
		weapon_slot = weapon_module.secondary
	if(weapon_slot == null)
		return
	weapon_slot.safety = !weapon_slot.safety

/datum/ui_module/spacepod_control_panels/proc/reload_weapon(id)
	var/list/weapons = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_WEAPON)
	if(!length(weapons))
		return
	var/obj/item/spacepod_module/weapon/weapon_module = weapons[1]
	var/datum/spacepod_weapon_slot/weapon_slot = null
	if(weapon_module.primary.id == id)
		weapon_slot = weapon_module.primary
	if(weapon_module.secondary.id == id)
		weapon_slot = weapon_module.secondary
	if(weapon_slot == null)
		return
	weapon_slot.reload(pod, usr)

/datum/ui_module/spacepod_control_panels/proc/switch_airtank()
	var/obj/item/spacepod_module/life_support/life_supports = pod.systems.get_misc_module(/obj/item/spacepod_module/life_support)
	if(life_supports == null)
		return
	life_supports.enable = !life_supports.enable
	to_chat(usr, span_notice("Подача воздуха: [life_supports.enable ? "из баллона" : "снаружи"]."))

/datum/ui_module/spacepod_control_panels/proc/extinguish_module(module_id)
	var/obj/item/spacepod_module/target_module = null
	for(var/obj/item/spacepod_module/module in pod.systems.modules)
		if(module_id == module.id)
			target_module = module
			break
	if(!target_module)
		return
	if(!target_module.fire)
		return
	var/obj/item/spacepod_module/fire_extingusher/fire_extenguisher = pod.systems.get_misc_module(/obj/item/spacepod_module/fire_extingusher)
	if(fire_extenguisher == null || fire_extenguisher.charges <= 0)
		return
	fire_extenguisher.charges -= 1
	target_module.fire = FALSE

#undef NOT_SELECTED_RPM_PROVIDER
