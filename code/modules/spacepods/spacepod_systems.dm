/**
 * Spacepod internal system.
 * Contains modules and encapsulates the logic of interaction between modules.
 */
/datum/spacepod_systems
	var/obj/spacepod/pod = null
	var/list/obj/item/spacepod_module/modules = list()
	var/list/slots = list()

/datum/spacepod_systems/New()
	. = ..()
	var/list/slot_id_list = GLOB.pod_slots
	for(var/slot in slot_id_list)
		slots[slot] = list()

/datum/spacepod_systems/Destroy(force)
	. = ..()
	pod = null
	QDEL_LIST(modules)
	QDEL_LIST(slots)

/datum/spacepod_systems/proc/check_complete()
	. = list()
	var/static/alist/require_modules = alist(
		SPACEPOD_MODULE_SLOT_BATTERY = "Отсутствует аккумуляторная батарея.",
		SPACEPOD_MODULE_SLOT_FUEL_TANK = "Отсутствуют топливные баки.",
		SPACEPOD_MODULE_SLOT_APU = "Отсутствует вспомогательная силовая установка.",
		SPACEPOD_MODULE_SLOT_ENGINE = "Отсутствуют двигатели.",
		SPACEPOD_MODULE_SLOT_FUEL_PUMP = "Отсутствуют топливные насосы.",
		SPACEPOD_MODULE_SLOT_GYRO = "Отсутствует гироскопический стабилизатор.",
	)
	for(var/module_slot, error_message in require_modules)
		var/slot_modules = slots[module_slot]
		if(!slot_modules || !length(slot_modules))
			. += span_notice(error_message)

/datum/spacepod_systems/proc/add_module(obj/spacepod/pod, obj/item/spacepod_module/module)
	module.systems = src
	modules += module
	slots[module.slot] += module
	module.on_install(pod)

/datum/spacepod_systems/proc/remove_module(obj/spacepod/pod, obj/item/spacepod_module/module)
	module.on_remove(pod)
	module.systems = null
	modules -= module
	slots[module.slot] -= module

/datum/spacepod_systems/proc/get_slot(slot_id)
	return slots[slot_id]

/datum/spacepod_systems/proc/get_misc_module(except_type)
	var/list/misc_modules = get_slot(SPACEPOD_MODULE_SLOT_MISC)
	for(var/obj/item/spacepod_module/module in misc_modules)
		if(module.type == except_type)
			return module
	return null

/datum/spacepod_systems/proc/remove_fuel_tank_from_pumps(obj/item/spacepod_module/fuel_tank/tank)
	var/list/fuel_pumps = get_slot(SPACEPOD_MODULE_SLOT_FUEL_PUMP)
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
	var/list/engines = get_slot(SPACEPOD_MODULE_SLOT_ENGINE)
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
	var/list/gyroscopes = get_slot(SPACEPOD_MODULE_SLOT_GYRO)
	if(!length(gyroscopes))
		return FALSE
	for(var/obj/item/spacepod_module/gyroscope/gyro in gyroscopes)
		if(gyro.is_working())
			return TRUE
	return FALSE

/datum/spacepod_systems/proc/fill_fuel_tanks(fuel_amount)
	var/list/fuel_tanks = get_slot(SPACEPOD_MODULE_SLOT_FUEL_TANK)
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

/datum/spacepod_systems/proc/get_total_thrust(has_gravity)
	var/list/engines = get_slot(SPACEPOD_MODULE_SLOT_ENGINE)
	if(!length(engines))
		return 0
	var/total_thrust = 0
	for(var/obj/item/spacepod_module/fuel_tank/engine/engine as anything in engines)
		if(engine.is_apu())
			continue
		total_thrust += engine.get_thrust(has_gravity) * engine.current_rpm / engine.max_rpm
	return total_thrust
