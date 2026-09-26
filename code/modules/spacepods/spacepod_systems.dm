/**
 * Spacepod internal system.
 * Contains modules and encapsulates the logic of interaction between modules.
 */
/datum/spacepod_systems
	var/list/obj/item/spacepod_module/modules = list()
	var/obj/item/spacepod_module/battery/battery = null
	var/list/obj/item/spacepod_module/fuel_tank/fuel_tanks = list()
	var/list/obj/item/spacepod_module/fuel_pump/fuel_pumps = list()
	var/obj/item/spacepod_module/fuel_tank/engine/apu/apu = null
	var/list/obj/item/spacepod_module/fuel_tank/engine/engines = list()
	var/obj/item/spacepod_module/gyroscope/gyroscope = null
	var/obj/item/spacepod_module/life_support/life_support = null
	var/obj/item/spacepod_module/weapon/weapon = null
	var/list/obj/item/spacepod_module/armor/armors = list()
	var/obj/item/spacepod_module/fire_extingusher/fire_extenguisher = null
	var/obj/item/spacepod_module/key_lock/key_lock = null
	var/obj/item/spacepod_module/catapult_module/catapult = null
	var/obj/item/spacepod_module/tracker/tracker = null

/datum/spacepod_systems/Destroy(force)
	. = ..()
	battery = null
	fuel_tanks.Cut()
	fuel_pumps.Cut()
	apu = null
	engines.Cut()
	gyroscope = null
	life_support = null
	weapon = null
	armors.Cut()
	fire_extenguisher = null
	key_lock = null
	catapult = null
	tracker = null
	QDEL_LIST(modules)

/datum/spacepod_systems/proc/check_complete()
	. = list()
	if(battery == null)
		. += span_notice("Отсутствует аккумуляторная батарея.")
	if(fuel_tanks == null || length(fuel_tanks) == 0)
		. += span_notice("Отсутствуют топливные баки.")
	if(fuel_pumps == null || length(fuel_pumps) == 0)
		. += span_notice("Отсутствуют топливные насосы.")
	var/exists_engine = FALSE
	if(engines)
		for(var/obj/item/spacepod_module/fuel_tank/engine/engine in engines)
			if(!engine.is_apu())
				exists_engine = TRUE
				break
	if(!exists_engine)
		. += span_notice("Отсутствуют двигатели.")
	if(apu == null)
		. += span_notice("Отсутствует вспомогательная силовая установка.")
	if(gyroscope == null)
		. += span_notice("Отсутствует гироскопический стабилизатор.")

/datum/spacepod_systems/proc/add_module(obj/spacepod/pod, obj/item/spacepod_module/module)
	module.systems = src
	modules += module
	if(istype(module, /obj/item/spacepod_module/battery))
		battery = module
	if(istype(module, /obj/item/spacepod_module/fuel_pump))
		fuel_pumps += module
	if(istype(module, /obj/item/spacepod_module/fuel_tank/engine/apu))
		apu = module
		engines += module
	else if(istype(module, /obj/item/spacepod_module/fuel_tank/engine))
		engines += module
	else if(istype(module, /obj/item/spacepod_module/fuel_tank))
		fuel_tanks += module
	if(istype(module, /obj/item/spacepod_module/gyroscope))
		gyroscope = module
	if(istype(module, /obj/item/spacepod_module/life_support))
		life_support = module
	if(istype(module, /obj/item/spacepod_module/weapon))
		weapon = module
	if(istype(module, /obj/item/spacepod_module/armor))
		armors += module
	if(istype(module, /obj/item/spacepod_module/fire_extingusher))
		fire_extenguisher = module
	if(istype(module, /obj/item/spacepod_module/key_lock))
		key_lock = module
	if(istype(module, /obj/item/spacepod_module/catapult_module))
		catapult = module
	if(istype(module, /obj/item/spacepod_module/tracker))
		tracker = module
	module.on_install(pod)

/datum/spacepod_systems/proc/remove_module(obj/spacepod/pod, obj/item/spacepod_module/module)
	module.on_remove(pod)
	module.enable = FALSE
	module.fire = FALSE
	module.connection_power_net = FALSE
	module.systems = null
	modules -= module
	if(istype(module, /obj/item/spacepod_module/battery))
		battery = null
	if(istype(module, /obj/item/spacepod_module/fuel_pump))
		fuel_pumps -= module
	if(istype(module, /obj/item/spacepod_module/fuel_tank/engine/apu))
		remove_fuel_tank_from_pumps(module)
		apu.select_rpm_destination_engine(null)
		apu = null
		engines -= module
	else if(istype(module, /obj/item/spacepod_module/fuel_tank/engine))
		remove_fuel_tank_from_pumps(module)
		engines -= module
	else if(istype(module, /obj/item/spacepod_module/fuel_tank))
		remove_fuel_tank_from_pumps(module)
		fuel_tanks -= module
	if(istype(module, /obj/item/spacepod_module/gyroscope))
		gyroscope = null
	if(istype(module, /obj/item/spacepod_module/life_support))
		life_support = null
	if(istype(module, /obj/item/spacepod_module/weapon))
		weapon = null
	if(istype(module, /obj/item/spacepod_module/armor))
		armors -= module
	if(istype(module, /obj/item/spacepod_module/fire_extingusher))
		fire_extenguisher = null
	if(istype(module, /obj/item/spacepod_module/key_lock))
		key_lock = null
	if(istype(module, /obj/item/spacepod_module/catapult_module))
		catapult = null
	if(istype(module, /obj/item/spacepod_module/tracker))
		tracker = null

/datum/spacepod_systems/proc/remove_fuel_tank_from_pumps(obj/item/spacepod_module/fuel_tank/tank)
	for(var/obj/item/spacepod_module/fuel_pump/pump in fuel_pumps)
		if(pump.source_tank == tank)
			pump.source_tank = null
		if(pump.destination_tank == tank)
			pump.destination_tank = null

/datum/spacepod_systems/proc/process_work(seconds_per_tick, obj/spacepod/pod)
	for(var/obj/item/spacepod_module/module as anything in modules)
		if(module.fire)
			module.fire_process()
		module.process_work(seconds_per_tick)

/datum/spacepod_systems/proc/get_total_speed_mod()
	if(!length(engines))
		return 0
	var/total_thrust = 0
	var/max_thrust = 0
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine as anything in engines)
		if(engine.is_apu())
			continue
		total_thrust += engine.current_rpm / engine.max_rpm
		max_thrust += 1
	if(max_thrust == 0) //zero div check
		max_thrust = 1
	return clamp(total_thrust / max_thrust, 0, 1)

/datum/spacepod_systems/proc/can_maneuver()
	if(!gyroscope)
		return FALSE
	return gyroscope.is_working()

/datum/spacepod_systems/proc/fill_fuel_tanks(fuel_amount)
	for(var/obj/item/spacepod_module/fuel_tank/tank in fuel_tanks)
		var/fill_fuel_amount = tank.fuel_capacity - tank.fuel_amount
		if(fill_fuel_amount <= 0)
			continue
		fill_fuel_amount = min(fill_fuel_amount, fuel_amount)
		tank.fuel_amount += fill_fuel_amount
		fuel_amount -= fill_fuel_amount
		if(fuel_amount <= 0)
			return 0
	return fuel_amount

/datum/spacepod_systems/proc/damage_modules(damage_amount)
	var/hit_chance_summ = 0
	for(var/obj/item/spacepod_module/module in modules)
		hit_chance_summ += module.hit_weight
	hit_chance_summ += POD_HULL_HIT_CHANCE
	// randomize target module or hull
	var/random_value = rand(0, hit_chance_summ - 1)
	for(var/obj/item/spacepod_module/module in modules)
		if(random_value < module.hit_weight)
			return module.deal_damage(damage_amount)
		random_value -= module.hit_weight
	// otherwise - full damage to hull
	return damage_amount

/datum/spacepod_systems/proc/get_total_mass()
	var/total_mass = POD_FRAME_MASS
	for(var/obj/item/spacepod_module/module in modules)
		total_mass += module.mass
	return total_mass

/datum/spacepod_systems/proc/get_total_thrust()
	if(!length(engines))
		return 0
	var/total_thrust = 0
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine as anything in engines)
		if(engine.is_apu())
			continue
		total_thrust += engine.thrust * engine.current_rpm / engine.max_rpm
	return total_thrust
