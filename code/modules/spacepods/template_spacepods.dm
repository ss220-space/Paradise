
/obj/spacepod/template
	abstract_type = /obj/spacepod/template
	name = "template spacepod"
	desc = "Шаблонный космический челнок."
	assemble_process = FALSE

/obj/spacepod/template/create_internal_system()
	. = ..()
	create_battery()
	create_fuel_and_engines()
	create_gyroscope()
	create_weapon()
	create_armor()
	create_misc_modules()

/obj/spacepod/template/proc/create_battery()
	var/obj/item/spacepod_module/battery/battery = new /obj/item/spacepod_module/battery/full(src)
	systems.add_module(src, battery)

/obj/spacepod/template/proc/create_fuel_and_engines()
	return // implement on specific spacepod

/obj/spacepod/template/proc/create_gyroscope()
	var/obj/item/spacepod_module/gyroscope/gyro = new(src)
	systems.add_module(src, gyro)

/obj/spacepod/template/proc/create_weapon()
	return // implement on specific spacepod

/obj/spacepod/template/proc/create_armor()
	return // implement on specific spacepod

/obj/spacepod/template/proc/create_misc_modules()
	return // implement on specific spacepod


// MARK: One engine pod
/obj/spacepod/template/one_engine
	name = "one engine spacepod"
	desc = "Однодвигательный космический челнок."

/obj/spacepod/template/one_engine/create_fuel_and_engines()
	// Total mass: 1090 кг
	// Total thrust: 3500
	// fueltank
	var/obj/item/spacepod_module/fuel_tank/large/central_fuel_tank = new /obj/item/spacepod_module/fuel_tank/large/full(src)
	central_fuel_tank.id = "central_fueltank"
	central_fuel_tank.caption = "CENT TK"
	central_fuel_tank.module_name = "Центральный топливный бак"
	systems.add_module(src, central_fuel_tank)
	// engines
	var/obj/item/spacepod_module/fuel_tank/engine/apu/apu = new(src)
	var/obj/item/spacepod_module/fuel_tank/engine/central_engine = new("engine_central")
	central_engine.module_name = "Центральный двигатель"
	// Fuel pumps
	// central fueltank - apu
	var/obj/item/spacepod_module/fuel_pump/pump_apu = new(src)
	pump_apu.id = "pump_central_fueltanktank_to_apu"
	pump_apu.caption = "APU PUMP"
	pump_apu.module_name = "Топливный насос из центрального бака в ВСУ"
	pump_apu.source_tank = central_fuel_tank
	pump_apu.destination_tank = apu
	systems.add_module(src, pump_apu)
	// central fueltank - central engine
	var/obj/item/spacepod_module/fuel_pump/pump_central_engine = new(src)
	pump_central_engine.id = "pump_central_fueltank_to_engine_central"
	pump_central_engine.caption = "ENG PUMP"
	pump_central_engine.module_name = "Топливный насос из центрального бака в центральный двигатель"
	pump_central_engine.source_tank = central_fuel_tank
	pump_central_engine.destination_tank = central_engine
	systems.add_module(src, pump_central_engine)
	// Add engines after fuel pumps
	systems.add_module(src, apu)
	systems.add_module(src, central_engine)

/obj/spacepod/template/one_engine/create_armor()
	var/obj/item/spacepod_module/armor/fore_armor = new /obj/item/spacepod_module/armor/light(src)
	fore_armor.id = "fore_armor"
	fore_armor.module_name = "Носовая броня"
	systems.add_module(src, fore_armor)
	var/obj/item/spacepod_module/armor/aft_armor = new /obj/item/spacepod_module/armor/light(src)
	aft_armor.id = "aft_armor"
	aft_armor.module_name = "Кормовая броня"
	systems.add_module(src, aft_armor)


// MARK: Two engine
/obj/spacepod/template/two_engine
	name = "two engine spacepod"
	desc = "Двухдвигательный космический челнок."

/obj/spacepod/template/two_engine/create_fuel_and_engines()
	// Total mass: 2825 кг
	// Total thrust: 12000
	// fuel tanks
	var/obj/item/spacepod_module/fuel_tank/large/fuel_tank_central = new /obj/item/spacepod_module/fuel_tank/large/full(src)
	fuel_tank_central.id = "fueltank_center"
	fuel_tank_central.caption = "CENT TK"
	fuel_tank_central.module_name = "Центральный топливный бак"
	systems.add_module(src, fuel_tank_central)
	var/obj/item/spacepod_module/fuel_tank/fuel_tank_right = new /obj/item/spacepod_module/fuel_tank/full(src)
	fuel_tank_right.id = "fueltank_right"
	fuel_tank_right.caption = "R TK"
	fuel_tank_right.module_name = "Правый топливный бак"
	systems.add_module(src, fuel_tank_right)
	var/obj/item/spacepod_module/fuel_tank/fuel_tank_left = new /obj/item/spacepod_module/fuel_tank/full(src)
	fuel_tank_left.id = "fueltank_left"
	fuel_tank_left.caption = "L TK"
	fuel_tank_left.module_name = "Левый топливный бак"
	systems.add_module(src, fuel_tank_left)
	// Engines
	var/obj/item/spacepod_module/fuel_tank/engine/apu/apu = new(src)
	var/obj/item/spacepod_module/fuel_tank/engine/engine_right = new /obj/item/spacepod_module/fuel_tank/engine/heavy(src)
	engine_right.id = "engine_right"
	engine_right.caption = "R ENG"
	engine_right.module_name = "Правый двигатель"
	var/obj/item/spacepod_module/fuel_tank/engine/engine_left = new /obj/item/spacepod_module/fuel_tank/engine/heavy(src)
	engine_left.id = "engine_left"
	engine_left.caption = "L ENG"
	engine_left.module_name = "Левый двигатель"
	// Fuel pumps
	// central fueltank - apu
	var/obj/item/spacepod_module/fuel_pump/pump_central_to_apu = new(src)
	pump_central_to_apu.id = "pump_central_fueltanktank_to_apu"
	pump_central_to_apu.caption = "APU PUMP"
	pump_central_to_apu.module_name = "Топливный насос из центрального бака в ВСУ"
	pump_central_to_apu.source_tank = fuel_tank_central
	pump_central_to_apu.destination_tank = apu
	systems.add_module(src, pump_central_to_apu)
	// central fueltank - right engine
	var/obj/item/spacepod_module/fuel_pump/pump_central_to_right_engine = new(src)
	pump_central_to_right_engine.id = "pump_central_fueltank_to_engine_right"
	pump_central_to_right_engine.caption = "CR ENG PUMP"
	pump_central_to_right_engine.module_name = "Топливный насос из центрального бака в правый двигатель"
	pump_central_to_right_engine.source_tank = fuel_tank_central
	pump_central_to_right_engine.destination_tank = engine_right
	systems.add_module(src, pump_central_to_right_engine)
	// central fueltank - left engine
	var/obj/item/spacepod_module/fuel_pump/pump_central_to_left_engine = new(src)
	pump_central_to_left_engine.id = "pump_central_fueltank_to_engine_left"
	pump_central_to_left_engine.caption = "CL ENG PUMP"
	pump_central_to_left_engine.module_name = "Топливный насос из центрального бака в левый двигатель"
	pump_central_to_left_engine.source_tank = fuel_tank_central
	pump_central_to_left_engine.destination_tank = engine_left
	systems.add_module(src, pump_central_to_left_engine)
	// right fueltank - central fueltank
	var/obj/item/spacepod_module/fuel_pump/pump_right_to_central = new(src)
	pump_right_to_central.id = "pump_right_fueltank_to_central_fueltank"
	pump_right_to_central.caption = "RC TK PUMP"
	pump_right_to_central.module_name = "Топливный насос из правого бака в центральный бак"
	pump_right_to_central.source_tank = fuel_tank_right
	pump_right_to_central.destination_tank = fuel_tank_central
	systems.add_module(src, pump_right_to_central)
	// left fueltank - central fueltank
	var/obj/item/spacepod_module/fuel_pump/pump_left_to_central = new(src)
	pump_left_to_central.id = "pump_left_fueltank_to_central_fueltank"
	pump_left_to_central.caption = "LC TK PUMP"
	pump_left_to_central.module_name = "Топливный насос из левого бака в центральный бак"
	pump_left_to_central.source_tank = fuel_tank_left
	pump_left_to_central.destination_tank = fuel_tank_central
	systems.add_module(src, pump_left_to_central)
	// right fueltank - right engine
	var/obj/item/spacepod_module/fuel_pump/pump_right_to_right_engine = new(src)
	pump_right_to_right_engine.id = "pump_right_fueltank_to_right_engine"
	pump_right_to_right_engine.caption = "R ENG PUMP"
	pump_right_to_right_engine.module_name = "Топливный насос из правого бака в правый двигатель"
	pump_right_to_right_engine.source_tank = fuel_tank_right
	pump_right_to_right_engine.destination_tank = engine_right
	systems.add_module(src, pump_right_to_right_engine)
	// left fueltank - left engine
	var/obj/item/spacepod_module/fuel_pump/pump_left_to_left_engine = new(src)
	pump_left_to_left_engine.id = "pump_left_fueltank_to_left_engine"
	pump_left_to_left_engine.caption = "L ENG PUMP"
	pump_left_to_left_engine.module_name = "Топливный насос из левого бака в левый двигатель"
	pump_left_to_left_engine.source_tank = fuel_tank_left
	pump_left_to_left_engine.destination_tank = engine_left
	systems.add_module(src, pump_left_to_left_engine)
	// Add engine after pumps
	systems.add_module(src, apu)
	systems.add_module(src, engine_right)
	systems.add_module(src, engine_left)


/obj/spacepod/template/two_engine/create_armor()
	var/obj/item/spacepod_module/armor/fore_armor = new /obj/item/spacepod_module/armor/light(src)
	fore_armor.id = "fore_armor"
	fore_armor.module_name = "Носовая броня"
	systems.add_module(src, fore_armor)
	var/obj/item/spacepod_module/armor/aft_armor = new /obj/item/spacepod_module/armor/light(src)
	aft_armor.id = "aft_armor"
	aft_armor.module_name = "Кормовая броня"
	systems.add_module(src, aft_armor)


// MARK: Civilian spacepod
/obj/spacepod/template/one_engine/civilian
	name = "wanderer spacepod"
	desc = "Стильный однодвигательный гражданский космический челнок \"Странник\"."

/obj/spacepod/template/one_engine/civilian/get_ru_names()
	return alist(
		NOMINATIVE = "космический челнок \"Странник\"",
		GENITIVE = "космического челнока \"Странник\"",
		DATIVE = "космическому челноку \"Странник\"",
		ACCUSATIVE = "космический челнок \"Странник\"",
		INSTRUMENTAL = "космическим челноком \"Странник\"",
		PREPOSITIONAL = "космическом челноке \"Странник\"",
	)

/obj/spacepod/template/one_engine/civilian/damaged
	desc = "Сильно поврежденный космический челнок \"Странник\""

/obj/spacepod/template/one_engine/civilian/damaged/Initialize(mapload)
	. = ..()
	take_damage(250, BRUTE)
	update_icon()


// MARK: Security spacepod
/obj/spacepod/template/two_engine/raptor
	name = "raptor spacepod"
	desc = "Стандартный патрульный челнок службы безопасности \"Раптор\". Оснащен двумя двигателями и оружейным модулем для патрулирования космического пространства около станции."
	icon_state = "pod_dece"
	max_integrity = 450

/obj/spacepod/template/two_engine/raptor/get_ru_names()
	return alist(
		NOMINATIVE = "космический челнок \"Раптор\"",
		GENITIVE = "космического челнока \"Раптор\"",
		DATIVE = "космическому челноку \"Раптор\"",
		ACCUSATIVE = "космический челнок \"Раптор\"",
		INSTRUMENTAL = "космическим челноком \"Раптор\"",
		PREPOSITIONAL = "космическом челноке \"Раптор\"",
	)

/obj/spacepod/template/two_engine/raptor/create_weapon()
	var/obj/item/spacepod_module/weapon/turret/gun_turret = new(src)
	systems.add_module(src, gun_turret)
	// Primary weapon - disabler
	var/obj/item/gun/energy/disabler/disabler_gun = new(src)
	gun_turret.install_gun(disabler_gun)
	// Secondary weapon - laser gun
	var/obj/item/gun/energy/laser/laser_gun = new(src)
	gun_turret.install_gun(laser_gun)

/obj/spacepod/template/two_engine/raptor/create_misc_modules()
	// Life support module
	systems.add_module(src, new /obj/item/spacepod_module/life_support(src))
	// Passenger seat for arrests
	systems.add_module(src, new /obj/item/spacepod_module/passenger_seat(src))
	// Fire extinguish module
	systems.add_module(src, new /obj/item/spacepod_module/fire_extingusher(src))
	// Key lock module
	var/obj/item/spacepod_module/key_lock/lock = new /obj/item/spacepod_module/key_lock(src)
	lock.key_id = 100000 //default key id for security spacepod
	systems.add_module(src, lock)
	// Emergency catapult module
	systems.add_module(src, new /obj/item/spacepod_module/catapult_module(src))

/obj/spacepod/template/two_engine/raptor/create_armor()
	var/obj/item/spacepod_module/armor/fore_armor = new /obj/item/spacepod_module/armor/heavy(src)
	fore_armor.id = "fore_armor"
	fore_armor.module_name = "Носовая броня"
	systems.add_module(src, fore_armor)
	var/obj/item/spacepod_module/armor/aft_armor = new /obj/item/spacepod_module/armor/heavy(src)
	aft_armor.id = "aft_armor"
	aft_armor.module_name = "Кормовая броня"
	systems.add_module(src, aft_armor)
	var/obj/item/spacepod_module/armor/port_side_armor = new /obj/item/spacepod_module/armor/heavy(src)
	port_side_armor.id = "port_side_armor"
	port_side_armor.module_name = "Броня левого борта"
	systems.add_module(src, port_side_armor)
	var/obj/item/spacepod_module/armor/starboard_side_armor = new /obj/item/spacepod_module/armor/heavy(src)
	starboard_side_armor.id = "starboard_side_armor"
	starboard_side_armor.module_name = "Броня правого борта"
	systems.add_module(src, starboard_side_armor)


// MARK: Syndicate spacepod
/obj/spacepod/template/two_engine/cobra
	name = "cobra spacepod"
	desc = "Челнок, окрашенный в цвета \"Синдиката\"."
	icon_state = "pod_synd"
	max_integrity = 400

/obj/spacepod/template/two_engine/cobra/get_ru_names()
	return alist(
		NOMINATIVE = "космический челнок \"Кобра\"",
		GENITIVE = "космического челнока \"Кобра\"",
		DATIVE = "космическому челноку \"Кобра\"",
		ACCUSATIVE = "космический челнок \"Кобра\"",
		INSTRUMENTAL = "космическим челноком \"Кобра\"",
		PREPOSITIONAL = "космическом челноке \"Кобра\"",
	)

/obj/spacepod/template/two_engine/cobra/create_weapon()
	var/obj/item/spacepod_module/weapon/turret/gun_turret = new(src)
	systems.add_module(src, gun_turret)
	// Primary weapon - C-20rm SMG
	var/obj/item/gun/projectile/automatic/smg/c20r/auto/primary = new(src)
	gun_turret.install_gun(primary)
	// Secondary weapon - Buldog shotgun
	var/obj/item/gun/projectile/automatic/shotgun/bulldog/secondary = new(src)
	gun_turret.install_gun(secondary)

/obj/spacepod/template/two_engine/raptor/create_armor()
	var/obj/item/spacepod_module/armor/fore_armor = new /obj/item/spacepod_module/armor/heavy(src)
	fore_armor.id = "fore_armor"
	fore_armor.module_name = "Носовая броня"
	systems.add_module(src, fore_armor)
	var/obj/item/spacepod_module/armor/aft_armor = new /obj/item/spacepod_module/armor/heavy(src)
	aft_armor.id = "aft_armor"
	aft_armor.module_name = "Кормовая броня"
	systems.add_module(src, aft_armor)
	var/obj/item/spacepod_module/armor/port_side_armor = new /obj/item/spacepod_module/armor/heavy(src)
	port_side_armor.id = "port_side_armor"
	port_side_armor.module_name = "Броня левого борта"
	systems.add_module(src, port_side_armor)
	var/obj/item/spacepod_module/armor/starboard_side_armor = new /obj/item/spacepod_module/armor/heavy(src)
	starboard_side_armor.id = "starboard_side_armor"
	starboard_side_armor.module_name = "Броня правого борта"
	systems.add_module(src, starboard_side_armor)
	var/obj/item/spacepod_module/armor/top_side_armor = new /obj/item/spacepod_module/armor/heavy(src)
	top_side_armor.id = "top_side_armor"
	top_side_armor.module_name = "Броня крыши"
	systems.add_module(src, top_side_armor)
	var/obj/item/spacepod_module/armor/bottom_side_armor = new /obj/item/spacepod_module/armor/heavy(src)
	bottom_side_armor.id = "bottom_side_armor"
	bottom_side_armor.module_name = "Броня днища"
	systems.add_module(src, bottom_side_armor)

/obj/spacepod/template/two_engine/cobra/create_misc_modules()
	systems.add_module(src, new /obj/item/spacepod_module/life_support(src))
	systems.add_module(src, new /obj/item/spacepod_module/fire_extingusher/five_charges(src))

/obj/spacepod/template/two_engine/cobra/no_weapon/create_weapon()
	var/obj/item/spacepod_module/weapon/turret/gun_turret = new(src)
	systems.add_module(src, gun_turret)
