#define TAB_ELECTRICITY "electricity"
#define TAB_ENGINES "engines"
#define TAB_FUEL "fuel"
#define TAB_WEAPONS "weapons"
#define TAB_LIFE_SUPPORT "life_support"
#define TAB_INTEGRITY "integrity"
#define TAB_INSTRUMENTAL "instrumental"
#define TAB_MISC "misc"

#define NOT_SELECTED_RPM_PROVIDER "Не передавать"

/datum/ui_module/spacepod_control_panels
	name = "Панель управления космическим челноком"
	var/obj/spacepod/pod
	var/selected_tab_id = TAB_INSTRUMENTAL

/datum/ui_module/spacepod_control_panels/ui_state(mob/user)
	if(isobserver(user))
		return ..()
	return GLOB.not_incapacitated_state

/datum/ui_module/spacepod_control_panels/ui_host(mob/user)
	return pod // Default src.

/datum/ui_module/spacepod_control_panels/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpacepodControlPanel", name)
		ui.open()

/datum/ui_module/spacepod_control_panels/ui_close(mob/user)
	var/datum/tgui/ui = SStgui.get_open_ui(user, src)
	if(!ui)
		return
	ui.close(TRUE)


// MARK: ui_data
/datum/ui_module/spacepod_control_panels/ui_data(mob/user)
	//create root data
	var/list/data = list()
	data["selected_tab"] = selected_tab_id
	data["tabs"] = create_tabs_data()
	data["electricity"] = create_electricity_panel_data()
	data["engines"] = create_engines_panel_data()
	data["fuel"] = create_fuel_panel_data()
	data["weapons"] = create_weapons_panel_data()
	data["life_support"] = create_life_support_data()
	data["integrity"] = create_integrity_panel_data()
	data["misc"] = create_misc_panel_data()
	return data

/datum/ui_module/spacepod_control_panels/proc/create_tabs_data()
	var/tabs = list()
	tabs += list(list(
		"id" = TAB_INSTRUMENTAL,
		"name" = "Панель инструментов",
		"icon" = "plane",
	))
	tabs += list(list(
		"id" = TAB_ELECTRICITY,
		"name" = "Электропитание",
		"icon" = "bolt",
	))
	tabs += list(list(
		"id" = TAB_ENGINES,
		"name" = "Двигатели",
		"icon" = "gears",
	))
	tabs += list(list(
		"id" = TAB_FUEL,
		"name" = "Топливо",
		"icon" = "tint",
	))
	if(pod.systems.life_support != null)
		tabs += list(list(
			"id" = TAB_LIFE_SUPPORT,
			"name" = "Жизнеобеспечение",
			"icon" = "thermometer-full",
		))
	if(pod.systems.weapon != null)
		tabs += list(list(
			"id" = TAB_WEAPONS,
			"name" = "Вооружение",
			"icon" = "crosshairs",
		))
	tabs += list(list(
		"id" = TAB_INTEGRITY,
		"name" = "Прочность",
		"icon" = "heart",
	))
	tabs += list(list(
		"id" = TAB_MISC,
		"name" = "Прочие",
		"icon" = "plus",
	))
	return tabs

/datum/ui_module/spacepod_control_panels/proc/create_electricity_panel_data()
	var/list/panel = list()
	if(pod.systems.battery)
		panel["exists"] = TRUE
		panel["battery_id"] = pod.systems.battery.id
		panel["link"] = pod.systems.battery.connection_power_net
		panel["power"] = pod.systems.battery.power
		panel["capacity"] = pod.systems.battery.power_capacity
		panel["percent"] = round(pod.systems.battery.power / pod.systems.battery.power_capacity * 100, 1)
	else
		panel["exists"] = FALSE
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
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine in pod.systems.engines)
		var/list/engine_data= list()
		engine_data["id"] = engine.id
		engine_data["caption"] = engine.caption
		engine_data["name"] = engine.module_name
		engine_data["enable"] = engine.enable
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
			for(var/obj/item/spacepod_module/fuel_tank/engine/dest_engine in pod.systems.engines)
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
	if(pod.systems.gyroscope)
		var/gyroscope_data = list()
		gyroscope_data["id"] = pod.systems.gyroscope.id
		gyroscope_data["name"] = pod.systems.gyroscope.module_name
		gyroscope_data["power_link"] = pod.systems.gyroscope.connection_power_net
		gyroscope_data["enable"] = pod.systems.gyroscope.enable
		gyroscope_data["rpm"] = pod.systems.gyroscope.current_rpm
		gyroscope_data["rpm_percent"] = round(pod.systems.gyroscope.current_rpm / pod.systems.gyroscope.max_rpm * 100, 1)
		gyroscope_data["rpm_warn"] = gyroscope_data["rpm_percent"] < 10 || gyroscope_data["rpm_percent"] > 120
		gyroscope_data["temperature"] = 32 + rand(1, 10)
		gyroscope_data["temperature_warn"] = FALSE
		gyroscope_data["error_text"] = pod.systems.gyroscope.error_text
		panel["gyroscope"] = gyroscope_data
	else
		panel["gyroscope"] = null
	return panel

/datum/ui_module/spacepod_control_panels/proc/create_fuel_panel_data()
	var/list/panel = list()
	var/fuel_tanks = list()
	for(var/obj/item/spacepod_module/fuel_tank/fuel_tank in pod.systems.fuel_tanks)
		var/tank_data = list()
		tank_data["id"] = fuel_tank.id
		tank_data["name"] = fuel_tank.module_name
		tank_data["caption"] = fuel_tank.caption
		tank_data["fuel_amount"] = fuel_tank.fuel_amount
		tank_data["fuel_capacity"] = fuel_tank.fuel_capacity
		tank_data["level_percent"] = round(fuel_tank.fuel_amount / fuel_tank.fuel_capacity * 100, 1)
		fuel_tanks += list(tank_data)
	panel["fuel_tanks"] = fuel_tanks
	var/fuel_pumps = list()
	for(var/obj/item/spacepod_module/fuel_pump/pump in pod.systems.fuel_pumps)
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
	if(pod.systems.weapon == null)
		panel["module"] = null
		panel["guns"] = list()
		return panel
	var/module = list()
	module["id"] = pod.systems.weapon.id
	module["name"] = pod.systems.weapon.module_name
	module["enable"] = pod.systems.weapon.enable
	module["power_link"] = pod.systems.weapon.connection_power_net
	module["error_text"] = pod.systems.weapon.error_text
	panel["module"] = module
	var/guns = list()
	if(pod.systems.weapon.primary.weapon)
		guns += list(create_weapon_data(pod.systems.weapon.primary, TRUE))
	if(pod.systems.weapon.secondary.weapon)
		guns += list(create_weapon_data(pod.systems.weapon.secondary, FALSE))
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
	panel["exists"] = pod.systems.life_support != null
	if(pod.internal_tank != null)
		var/list/airtank = list()
		airtank["name"] = pod.internal_tank.declent_ru(NOMINATIVE)
		airtank["enable"] = pod.systems.life_support != null && pod.systems.life_support.enable
		airtank["volume"] = pod.internal_tank.volume
		airtank["pressure"] = pod.internal_tank.return_pressure()
		airtank["low_pressure"] = pod.internal_tank.return_pressure() < 0.25 * pod.internal_tank.maximum_pressure
		panel["airtank"] = airtank
	else
		panel["airtank"] = null
	var/list/atmos = list()
	if(pod.systems.life_support != null && pod.systems.life_support.enable)
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
	if(pod.systems.fire_extenguisher != null)
		hull["extenguish_charges"] = pod.systems.fire_extenguisher.charges
	panel["hull"] = hull
	var/modules = list()
	for(var/obj/item/spacepod_module/module in pod.systems.modules)
		var/module_data = list()
		module_data["id"] = module.id
		module_data["caption"] = module.caption
		module_data["name"] = module.module_name
		module_data["integrity"] = module.integrity
		module_data["max_integrity"] = module.max_integrity
		module_data["integrity_warn"] = module.integrity < 0.5 * module.max_integrity
		module_data["fire"] = module.fire
		modules += list(module_data)
	panel["modules"] = modules
	return panel

/datum/ui_module/spacepod_control_panels/proc/create_misc_panel_data()
	var/list/panel = list()
	if(pod.systems.key_lock != null)
		var/lock_data = list()
		lock_data["locked"] = !pod.unlocked
		panel["key_lock"] = lock_data
	else
		panel["key_lock"] = null
	if(pod.systems.catapult != null)
		var/catapult = list()
		catapult["id"] = pod.systems.catapult.id
		catapult["enable"] = pod.systems.catapult.enable
		panel["catapult"] = catapult
	else
		panel["catapult"] = null
	return panel


//MARK: assets
/datum/asset/simple/spacepod_panel
	assets = list(
		"eng-idle.png" = 'icons/ui_icons/spacepod_panel/engine-idle.png',
		"eng-on.png" = 'icons/ui_icons/spacepod_panel/engine-on.png',
		"eng-off.png" = 'icons/ui_icons/spacepod_panel/engine-off.png',
		"eng-off-top.png" = 'icons/ui_icons/spacepod_panel/engine-off-top.png',
		"eng-fail.png" = 'icons/ui_icons/spacepod_panel/engine-fail.png',
		"tumbler-on.png" = 'icons/ui_icons/spacepod_panel/tumbler-on.png',
		"tumbler-off.png" = 'icons/ui_icons/spacepod_panel/tumbler-off.png',
	)

/datum/ui_module/spacepod_control_panels/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/spacepod_panel),
	)


// MARK: ui_act
/datum/ui_module/spacepod_control_panels/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = TRUE

	playsound(pod.loc, SFX_TERMINAL_TYPE, 25, TRUE)
	switch(action)
		if("select_tab")
			selected_tab_id = params["tab"]
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
		else
			return FALSE

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
	if(!target_module)
		return
	if(target_module.enable)
		target_module.turn_off()
	else
		target_module.turn_on()

/datum/ui_module/spacepod_control_panels/proc/ignite_engine(id)
	var/apu_id = null
	var/obj/item/spacepod_module/fuel_tank/engine/target_engine = null
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine in pod.systems.engines)
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
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine in pod.systems.engines)
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
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine in pod.systems.engines)
		if(id == engine.id && istype(engine, /obj/item/spacepod_module/fuel_tank/engine/apu))
			target_engine = engine
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
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine in pod.systems.engines)
		if(id == engine.id && istype(engine, /obj/item/spacepod_module/fuel_tank/engine/apu))
			target_engine = engine
		if(destination_engine_id == engine.id)
			destination_engine = engine
	if(!target_engine)
		return
	if(destination_engine_id == null || destination_engine == null)
		destination_engine = null
	target_engine.select_rpm_destination_engine(destination_engine)

/datum/ui_module/spacepod_control_panels/proc/toggle_weapon_safety(id)
	var/obj/item/spacepod_module/weapon/weapon_module = pod.systems.weapon
	var/datum/spacepod_weapon_slot/weapon_slot = null
	if(weapon_module.primary.id == id)
		weapon_slot = weapon_module.primary
	if(weapon_module.secondary.id == id)
		weapon_slot = weapon_module.secondary
	if(weapon_slot == null)
		return
	weapon_slot.safety = !weapon_slot.safety

/datum/ui_module/spacepod_control_panels/proc/reload_weapon(id)
	var/obj/item/spacepod_module/weapon/weapon_module = pod.systems.weapon
	var/datum/spacepod_weapon_slot/weapon_slot = null
	if(weapon_module.primary.id == id)
		weapon_slot = weapon_module.primary
	if(weapon_module.secondary.id == id)
		weapon_slot = weapon_module.secondary
	if(weapon_slot == null)
		return
	weapon_slot.reload(pod, usr)

/datum/ui_module/spacepod_control_panels/proc/switch_airtank()
	if(pod.systems.life_support == null)
		return
	pod.systems.life_support.enable = !pod.systems.life_support.enable
	to_chat(usr, span_notice("Подача воздуха: [pod.systems.life_support.enable ? "из баллона" : "снаружи"]."))

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
	if(pod.systems.fire_extenguisher == null || pod.systems.fire_extenguisher.charges <= 0)
		return
	pod.systems.fire_extenguisher.charges -= 1
	target_module.fire = FALSE

#undef TAB_ELECTRICITY
#undef TAB_ENGINES
#undef TAB_FUEL
#undef TAB_WEAPONS
#undef TAB_LIFE_SUPPORT
#undef TAB_INTEGRITY
#undef TAB_INSTRUMENTAL
#undef TAB_MISC
#undef NOT_SELECTED_RPM_PROVIDER
