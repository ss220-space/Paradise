// MARK: Basic module
/obj/item/spacepod_module
	desc = "Модуль космического челнока."
	icon = 'icons/obj/spacepod.dmi'
	icon_state = "cargo_blank"
	origin_tech = "programming=2;materials=2;engineering=2"
	var/slot = 0
	var/caption = "???"
	var/module_name = "Модуль челнока"
	var/datum/spacepod_systems/systems = null

	/// Current module integrity
	var/integrity
	/// Maximal module integrity
	max_integrity = 50
	/// Hit chance weight
	var/hit_weight = POD_MODULE_HIT_CHANCE_NORMAL
	/// Mass of module on kg
	var/mass = 0
	/// Enable status flag
	var/enable = FALSE
	/// Fire process
	var/fire = FALSE
	var/fire_on_hit_chance = 0
	/// Module fire damage multiplyer
	var/fire_damage_mod = 1
	/// Connect to electric power net
	var/connection_power_net = FALSE
	/// Amount of consumed power in watt per tick
	var/consume_power = 0
	/// Module is immune to EMP shutdown
	var/emp_immune = FALSE
	/// Error detail data
	var/error_text = null


/obj/item/spacepod_module/get_ru_names()
	return alist(
		NOMINATIVE = "модуль \"[module_name]\"",
		GENITIVE = "модуля \"[module_name]\"",
		DATIVE = "модулю \"[module_name]\"",
		ACCUSATIVE = "модуль \"[module_name]\"",
		INSTRUMENTAL = "модулем \"[module_name]\"",
		PREPOSITIONAL = "модуле \"[module_name]\"",
	)

/obj/item/spacepod_module/Initialize(mapload)
	. = ..()
	integrity = max_integrity
	update_appearance(UPDATE_NAME)

/obj/item/spacepod_module/update_name(updates)
	. = ..()
	name = "Модуль \"[module_name]\""

/obj/item/spacepod_module/examine(mob/user)
	. = ..()
	. += span_notice("Прочность [get_integrity_percent()]%")
	if(mass > 0)
		. += span_notice("Вес [mass] кг.")

/obj/item/spacepod_module/proc/get_integrity_percent()
	return max_integrity > 0 ? clamp(round(integrity * 100 / max_integrity), 0, 100) : 0

/obj/item/spacepod_module/proc/get_examine_details()
	return ""

/obj/item/spacepod_module/proc/get_examine_status()
	var/integrity_percent = get_integrity_percent()
	var/line = "- [module_name] ([caption]) — состояние [integrity_percent]%[get_examine_details()]"
	if(integrity_percent <= 0)
		return span_danger(line)
	if(integrity_percent < 50)
		return span_warning(line)
	return span_notice(line)

/obj/item/spacepod_module/proc/get_ui_data()
	var/list/data = list()
	data["id"] = UID()
	data["caption"] = caption
	data["name"] = module_name
	data["enable"] = enable
	data["link"] = connection_power_net
	data["integrity"] = integrity
	data["max_integrity"] = max_integrity
	data["integrity_warn"] = integrity < max_integrity * 0.5
	data["fire"] = fire
	data["error_text"] = error_text
	return data

/obj/item/spacepod_module/welder_act(mob/living/user, obj/item/tool)
	if(user.a_intent == INTENT_HARM)
		return
	. = TRUE
	if(!tool.tool_use_check(user, 0))
		return
	if(integrity >= max_integrity)
		balloon_alert(user, "модуль целый!")
		return
	WELDER_ATTEMPT_REPAIR_MESSAGE
	while(integrity < max_integrity)
		if(!tool.use_tool(src, user, 15, volume = tool.tool_volume))
			break
		integrity = min(integrity + 20, max_integrity)
		user.visible_message(
			span_notice("[user] частично отремонтировал[GEND_A_O_I(user)] [name]."),
			span_notice("Вы частично отремонтировали [name].")
		)
	if(integrity >= max_integrity)
		balloon_alert(user, "модуль полностью отремонтирован!")

/obj/item/spacepod_module/proc/install_to(mob/living/user, obj/spacepod/pod)
	return TRUE

/obj/item/spacepod_module/proc/on_install(obj/spacepod/pod)
	RegisterSignal(pod, COMSIG_SPACEPOD_EMP, PROC_REF(on_pod_emp))
	return TRUE

/obj/item/spacepod_module/proc/on_remove(obj/spacepod/pod)
	UnregisterSignal(pod, COMSIG_SPACEPOD_EMP)
	enable = FALSE
	fire = FALSE
	connection_power_net = FALSE
	return TRUE

/obj/item/spacepod_module/proc/on_pod_emp(datum/source, severity)
	SIGNAL_HANDLER
	if(emp_immune || !enable)
		return
	if(prob(POD_EMP_MODULE_DISABLE_CHANCE / max(severity, 1)))
		turn_off()
		error_text = "Модуль отключён ЭМИ"

/obj/item/spacepod_module/proc/fire_process()
	if(!fire)
		return FALSE
	if(integrity == 0)
		return FALSE

	integrity -= POD_MODULE_FIRE_DAMAGE * fire_damage_mod
	if(integrity < 0)
		integrity = 0

	return integrity > 0

/obj/item/spacepod_module/proc/process_power(seconds_per_tick)
	if(!connection_power_net || !systems)
		return FALSE
	return systems.consume_power(consume_power * seconds_per_tick)

/obj/item/spacepod_module/proc/process_work(seconds_per_tick)
	return enable

/obj/item/spacepod_module/proc/turn_on()
	if(integrity <= 0)
		error_text = "Модуль уничтожен"
		enable = FALSE
		return
	error_text = null
	enable = TRUE

/obj/item/spacepod_module/proc/turn_off()
	enable = FALSE

/obj/item/spacepod_module/proc/deal_damage(damage_amount)
	var/absorbed_damage = min(integrity, damage_amount)
	if(absorbed_damage <= 0)
		return 0
	integrity -= absorbed_damage
	if(integrity > 0 && fire_on_hit_chance > 0 && prob(damage_amount * fire_on_hit_chance / 100))
		fire = TRUE
	if(integrity <= 0)
		on_destroy_module()
	return damage_amount - absorbed_damage

/obj/item/spacepod_module/proc/on_destroy_module()
	enable = FALSE
	error_text = "Модуль уничтожен"


// MARK: Fuel tank
/obj/item/spacepod_module/fuel_tank
	slot = SPACEPOD_MODULE_SLOT_FUEL_TANK
	caption = "TK"
	module_name = "Топливный бак"
	desc = "Стандартный топливный бак вместимостью 1000 литров. Обеспечивает челнок горючим для перелётов на средние расстояния."
	icon_state = "fueltank"
	max_integrity = 75
	hit_weight = POD_MODULE_HIT_CHANCE_LARGE
	fire_damage_mod = 2
	fire_on_hit_chance = 25
	mass = 120
	/// Fuel capacity in units
	var/fuel_capacity = 1000 //units
	/// Current fuel level in units
	var/fuel_amount = 0

/obj/item/spacepod_module/fuel_tank/examine(mob/user)
	. = ..()
	. += span_notice("Емкость [fuel_capacity] л.")
	. += span_notice("Заправлено на [fuel_amount] л.")

/obj/item/spacepod_module/fuel_tank/get_examine_details()
	var/fuel_percent = fuel_capacity > 0 ? clamp(round(fuel_amount * 100 / fuel_capacity), 0, 100) : 0
	return ", топливо [fuel_percent]%"

/obj/item/spacepod_module/fuel_tank/get_ui_data()
	. = ..()
	.["fuel_amount"] = fuel_amount
	.["fuel_capacity"] = fuel_capacity
	.["level_percent"] = fuel_capacity > 0 ? round(fuel_amount / fuel_capacity * 100, 1) : 0
	return .

/obj/item/spacepod_module/fuel_tank/proc/consume_fuel(amount)
	if(amount > fuel_amount)
		amount = fuel_amount

	fuel_amount -= amount
	return amount

/obj/item/spacepod_module/fuel_tank/on_remove(obj/spacepod/pod)
	. = ..()
	for(var/obj/item/spacepod_module/fuel_pump/pump as anything in pod.systems.get_slot(SPACEPOD_MODULE_SLOT_FUEL_PUMP))
		if(pump.source_tank == src)
			pump.source_tank = null
		if(pump.destination_tank == src)
			pump.destination_tank = null

/obj/item/spacepod_module/fuel_tank/on_destroy_module()
	. = ..()
	fuel_amount = 0

/obj/item/spacepod_module/fuel_tank/install_to(mob/living/user, obj/spacepod/pod)
	var/list/fuel_tanks = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_FUEL_TANK)
	var/fueltank_id = "fueltank_[length(fuel_tanks) + 1]"
	var/fueltank_name = tgui_input_text(user, "Название топливного бака", "Назвать топливный бак", default = fueltank_id, max_length = MAX_NAME_LEN, encode = TRUE)
	if(isnull(fueltank_name))
		return FALSE
	var/caption = "TK [length(fuel_tanks) + 1]"
	caption = tgui_input_text(user, "Сокращенный код бака", "Указать код топливный бак", default = caption, max_length = MAX_NAME_LEN, encode = TRUE)
	if(QDELETED(src) || isnull(caption))
		return FALSE
	src.caption = caption
	src.module_name = fueltank_name
	update_appearance(UPDATE_NAME)
	return TRUE

/obj/item/spacepod_module/fuel_tank/full/New(loc, ...)
	. = ..()
	fuel_amount = fuel_capacity

/obj/item/spacepod_module/fuel_tank/large
	module_name = "Большой топливный бак"
	desc = "Увеличенный топливный бак вместимостью 2000 литров. Для дальних перелётов и тяжёлых челноков с высоким расходом топлива."
	icon_state = "fueltank_large"
	max_integrity = 100
	hit_weight = POD_MODULE_HIT_CHANCE_EXTRA_LARGE
	mass = 250
	fuel_capacity = 2000

/obj/item/spacepod_module/fuel_tank/large/full/New(loc, ...)
	. = ..()
	fuel_amount = fuel_capacity


// MARK: Battery
/obj/item/spacepod_module/battery
	slot = SPACEPOD_MODULE_SLOT_BATTERY
	caption = "BATT"
	module_name = "Аккумуляторная батарея"
	desc = "Аккумулирует электроэнергию от генераторов и питает электросеть для бортовых систем челнока."
	icon_state = "battery"
	max_integrity = 100
	fire_on_hit_chance = 10
	mass = 80
	enable = TRUE
	emp_immune = TRUE
	/// Battery capacity in watt
	var/power_capacity = 10000 WATTS
	/// Current power level in watt
	var/power = 0

/obj/item/spacepod_module/battery/examine(mob/user)
	. = ..()
	. += span_notice("Емкость [display_power(power_capacity, convert = FALSE)].")
	. += span_notice("Заряжено на [display_power(power, convert = FALSE)].")

/obj/item/spacepod_module/battery/get_examine_details()
	var/charge_percent = power_capacity > 0 ? clamp(round(power * 100 / power_capacity), 0, 100) : 0
	return ", заряд [charge_percent]%"

/obj/item/spacepod_module/battery/get_ui_data()
	. = ..()
	.["power"] = round(power, 1)
	.["capacity"] = power_capacity
	.["percent"] = power_capacity > 0 ? round(power / power_capacity * 100, 1) : 0
	return .

/obj/item/spacepod_module/battery/on_pod_emp(datum/source, severity)
	var/drain_percent = rand(POD_EMP_BATTERY_DRAIN_MIN, POD_EMP_BATTERY_DRAIN_MAX)
	power = max(0, power - power_capacity * drain_percent / 100)

/obj/item/spacepod_module/battery/on_remove(obj/spacepod/pod)
	. = ..()
	fire = FALSE
	connection_power_net = FALSE

/obj/item/spacepod_module/battery/proc/consume_power(amount)
	if(!connection_power_net || !enable)
		return FALSE
	if(power < amount)
		return FALSE
	power -= amount
	return TRUE

/obj/item/spacepod_module/battery/proc/accumulate_power(amount)
	power = min(power + amount, power_capacity)

/obj/item/spacepod_module/battery/on_destroy_module()
	power = 0
	error_text = "Модуль уничтожен"

/obj/item/spacepod_module/battery/full/New(loc, ...)
	. = ..()
	power = power_capacity


// MARK: Fuel pump
/obj/item/spacepod_module/fuel_pump
	slot = SPACEPOD_MODULE_SLOT_FUEL_PUMP
	caption = "PUMP"
	module_name = "Топливный насос"
	desc = "Перекачивает топливо из бака к двигателю. Несколько насосов повышают пропускную способность и стабильность подачи."
	icon_state = "fuel_pump"
	max_integrity = 20
	hit_weight = POD_MODULE_HIT_CHANCE_SMALL
	fire_damage_mod = 5
	fire_on_hit_chance = 20
	consume_power = 10
	mass = 45
	/// Fuel pumping speed in units per tick
	var/pump_speed = 10 //units per tick
	var/obj/item/spacepod_module/fuel_tank/source_tank
	var/obj/item/spacepod_module/fuel_tank/destination_tank

/obj/item/spacepod_module/fuel_pump/examine(mob/user)
	. = ..()
	. += span_notice("Перекачивает [pump_speed] л. топлива в секунду.")

/obj/item/spacepod_module/fuel_pump/get_ui_data()
	. = ..()
	.["power_link"] = connection_power_net
	.["pump_speed"] = enable ? pump_speed : 0
	.["temperature"] = 32 + rand(1, 10)
	.["temperature_warn"] = FALSE
	return .

/obj/item/spacepod_module/fuel_pump/install_to(mob/living/user, obj/spacepod/pod)
	var/list/fuel_tanks = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_FUEL_TANK)
	if(!length(fuel_tanks))
		to_chat(user, span_notice("Чтобы установить топливный насос, сначала установите топливный бак!"))
		return FALSE
	var/list/engines = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_ENGINE)
	var/list/apus = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_APU)
	var/obj/item/spacepod_module/fuel_tank/source_fueltank = tgui_input_list(user, "Выберите откуда насос будет качать топливо:", "Выбор источника топлива", fuel_tanks)
	var/obj/item/spacepod_module/fuel_tank/destination_fueltank = tgui_input_list(user, "Выберите куда насос будет качать топливо:", "Выбор назначения топлива", fuel_tanks | engines | apus)
	var/fuel_pumps = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_FUEL_PUMP)
	var/pump_id = "fuelpump_[length(fuel_pumps) + 1]"
	var/pump_name = tgui_input_text(user, "Название топливного насоса", "Назвать топливный насос", default = pump_id, max_length = MAX_NAME_LEN, encode = TRUE)
	if(isnull(pump_name))
		return FALSE
	var/caption = "PUMP [length(fuel_pumps) + 1]"
	caption = tgui_input_text(user, "Сокращенный код топливного насоса", "Указать код топливного насоса", default = caption, max_length = MAX_NAME_LEN, encode = TRUE)
	if(QDELETED(src) || isnull(caption))
		return FALSE
	src.caption = caption
	src.module_name = pump_name
	src.source_tank = source_fueltank
	src.destination_tank = destination_fueltank
	update_appearance(UPDATE_NAME)
	return TRUE

/obj/item/spacepod_module/fuel_pump/process_work(seconds_per_tick)
	. = ..()
	if(!.)
		return
	if(isnull(source_tank) || isnull(destination_tank))
		error_text = "Отсутствует подключение!"
		turn_off()
		return
	if(!process_power(seconds_per_tick))
		if(!connection_power_net)
			error_text = "Нет подключения к электросети для работы топливного насоса"
		else
			error_text = "Не хватает электричества для работы топливного насоса"
		turn_off()
		return
	var/pumped = pump_speed * seconds_per_tick
	if(pumped > source_tank.fuel_amount)
		pumped = source_tank.fuel_amount
	var/free_space = max(destination_tank.fuel_capacity - destination_tank.fuel_amount, 0)
	if(pumped > free_space)
		pumped = free_space
	if(pumped <= 0)
		return
	source_tank.fuel_amount -= pumped
	if(destination_tank.integrity > 0)
		destination_tank.fuel_amount += pumped


// MARK: Engines
/obj/item/spacepod_module/fuel_tank/engine
	slot = SPACEPOD_MODULE_SLOT_ENGINE
	module_name = "Двигатель челнока"
	desc = "Базовый маршевый двигатель челнока. Обеспечивает тягу для перемещения в космосе. Требуется вспомогательная силовая установка для запуска данного двигателя."
	icon_state = "engine"
	caption = "ENG"
	max_integrity = 120
	fire_damage_mod = 1
	fire_on_hit_chance = 15
	mass = 150
	fuel_capacity = 30
	emp_immune = TRUE
	var/thrust = 3500
	/// Maximal rotations per minutes
	var/max_rpm = 15000
	/// Current rotations per minutes
	var/current_rpm = 0
	/// Ignition acceleration (rpm increase per units)
	var/ignition_acceleration = 1000
	/// How many fuel consume in units per seconds
	var/fuel_consume_speed = 1.5 // unit/sec
	var/generator_enable = FALSE
	/// How many powers generate on 100% rpm per seconds in watt
	var/generate_power = 250
	/// Receiving external rotation
	var/external_rotation = FALSE
	/// Last time the pod successfully moved a tile
	var/last_movement_time = 0

/obj/item/spacepod_module/fuel_tank/engine/examine(mob/user)
	. = ..()
	. += span_notice("Тяга [thrust] кгс")
	. += span_notice("Потребляет до [fuel_consume_speed] л. топлива в секунду при максимальных оборотах.")

/obj/item/spacepod_module/fuel_tank/engine/get_ui_data()
	. = ..()
	var/rpm_percent = get_rpm_percent()
	.["is_apu"] = is_apu()
	.["rpm"] = current_rpm
	.["rpm_percent"] = rpm_percent
	.["rpm_warn"] = rpm_percent > 0 && (rpm_percent < 25 || rpm_percent > 120)
	.["fuel_pressure"] = fuel_capacity > 0 ? round(fuel_amount / fuel_capacity * 100, 1) : 0
	.["fuel_pressure_warn"] = .["fuel_pressure"] <= 30
	.["power_link"] = null
	.["rpm_provide_engines"] = null
	.["selected_rpm_provide_engine"] = null
	.["generator_enable"] = generator_enable
	.["generated_power"] = generator_enable ? round(current_rpm / max_rpm * generate_power, 1) : 0
	.["temperature"] = 32 + rand(1, 10)
	.["temperature_warn"] = FALSE
	return .

/obj/item/spacepod_module/fuel_tank/engine/install_to(mob/living/user, obj/spacepod/pod)
	var/list/engines = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_ENGINE)
	var/engine_id = "engine_[length(engines) + 1]"
	var/engine_name = tgui_input_text(user, "Название двигателя", "Назвать двигатель", default = engine_id, max_length = MAX_NAME_LEN, encode = TRUE)
	if(isnull(engine_name))
		return FALSE
	var/caption = "ENG [length(engines) + 1]"
	caption = tgui_input_text(user, "Сокращенный код двигателя", "Указать код двигателя", default = caption, max_length = MAX_NAME_LEN, encode = TRUE)
	if(QDELETED(src) || isnull(caption))
		return FALSE
	src.caption = caption
	src.module_name = engine_name
	update_appearance(UPDATE_NAME)
	return TRUE

/obj/item/spacepod_module/fuel_tank/engine/on_install(obj/spacepod/pod)
	. = ..()
	RegisterSignal(pod, COMSIG_SPACEPOD_MOVED, PROC_REF(on_pod_moved))

/obj/item/spacepod_module/fuel_tank/engine/on_remove(obj/spacepod/pod)
	UnregisterSignal(pod, COMSIG_SPACEPOD_MOVED)
	return ..()

/obj/item/spacepod_module/fuel_tank/engine/proc/get_rpm_percent()
	return max_rpm > 0 ? round(current_rpm / max_rpm * 100, 1) : 0

/obj/item/spacepod_module/fuel_tank/engine/proc/get_thrust(has_gravity)
	if(has_gravity)
		return thrust / POD_GRAVITY_SPEED_MOD
	return thrust

/obj/item/spacepod_module/fuel_tank/engine/proc/on_pod_moved(datum/source)
	SIGNAL_HANDLER
	if(is_apu() || !enable)
		return
	current_rpm = min(current_rpm + max_rpm * POD_ENGINE_MOVEMENT_RPM_GAIN, max_rpm)
	last_movement_time = world.time

/obj/item/spacepod_module/fuel_tank/engine/turn_on()
	error_text = null
	ignite()

/obj/item/spacepod_module/fuel_tank/engine/proc/ignite()
	if(enable)
		return FALSE
	if(integrity <= 0)
		error_text = "Модуль уничтожен"
		return FALSE
	if(current_rpm <= 0) //no rotation - no ignition, provde rotations from apu
		error_text = "Нет оборотов для запуска"
		return FALSE
	enable = TRUE
	external_rotation = FALSE
	return TRUE

/obj/item/spacepod_module/fuel_tank/engine/proc/enable_power_generator()
	if(current_rpm > 0)
		generator_enable = TRUE
	else
		error_text = "Нет оборотов двигателя для запуска генератора"

/obj/item/spacepod_module/fuel_tank/engine/proc/is_apu()
	return FALSE

/obj/item/spacepod_module/fuel_tank/engine/process_work(seconds_per_tick)
	if(generator_enable)
		var/rpm_mod = current_rpm / max_rpm
		systems?.accumulate_power(rpm_mod * generate_power * seconds_per_tick)

	if(!enable) // slowly stoping
		if(external_rotation || current_rpm == 0)
			return
		current_rpm = max(current_rpm - ignition_acceleration * seconds_per_tick, 0)
		return

	var/fuel_needed = fuel_consume_speed * (current_rpm / max_rpm) * seconds_per_tick
	if(fuel_needed > 0 && consume_fuel(fuel_needed) <= 0)
		error_text = "Топливное голодание"
		enable = FALSE //auto off
		return

	if(is_apu())
		if(current_rpm >= max_rpm)
			return
		current_rpm = min(current_rpm + ignition_acceleration * seconds_per_tick, max_rpm)
		return

	var/idle_rpm = max_rpm * POD_ENGINE_IDLE_RPM_RATIO
	if(current_rpm < idle_rpm)
		current_rpm = min(current_rpm + ignition_acceleration * seconds_per_tick, idle_rpm)
		return
	if(current_rpm <= idle_rpm || world.time < last_movement_time + POD_ENGINE_IDLE_DELAY)
		return
	current_rpm = max(current_rpm - ignition_acceleration * seconds_per_tick, idle_rpm)

/obj/item/spacepod_module/fuel_tank/engine/on_destroy_module()
	. = ..()
	current_rpm = 0
	generator_enable = FALSE

/obj/item/spacepod_module/fuel_tank/engine/heavy
	module_name = "Форсажный двигатель челнока"
	desc = "Двигатель челнока повышенной тяги. Значительно мощнее базового, но быстрее расходует топливо. Требуется вспомогательная силовая установка для запуска данного двигателя."
	icon_state = "engine_speedy"
	thrust = 6000
	fuel_consume_speed = 2
	mass = 170

/obj/item/spacepod_module/fuel_tank/engine/grav_engine
	module_name = "Гравитационный двигатель челнока"
	desc = "Двигатель челнока, который работает только в присутствии гравитации. В безгравитационном пространстве не выдает тяги. Требуется вспомогательная силовая установка для запуска данного двигателя."

/obj/item/spacepod_module/fuel_tank/engine/grav_engine/get_thrust(has_gravity)
	if(!has_gravity)
		return 0
	return thrust


// MARK: APU
/obj/item/spacepod_module/fuel_tank/engine/apu
	slot = SPACEPOD_MODULE_SLOT_APU
	caption = "APU"
	module_name = "Вспомогательная силовая установка"
	desc = "Вспомогательная силовая установка обеспечивает челнок электроэнергией при выключенном маршевом двигателе и выдает крутящий момент для запуска основных двигателей челнока."
	icon_state = "apu"
	thrust = 0
	mass = 100
	consume_power = 500
	generate_power = 200
	fuel_consume_speed = 1
	var/obj/item/spacepod_module/fuel_tank/engine/rpm_destination_engine = null

/obj/item/spacepod_module/fuel_tank/engine/apu/is_apu()
	return TRUE

/obj/item/spacepod_module/fuel_tank/engine/apu/get_ui_data()
	. = ..()
	.["power_link"] = connection_power_net
	var/list/providers = list(list("displayText" = POD_RPM_PROVIDER_NONE, "value" = ""))
	.["selected_rpm_provide_engine"] = ""
	if(systems)
		for(var/obj/item/spacepod_module/fuel_tank/engine/engine as anything in systems.get_slot(SPACEPOD_MODULE_SLOT_ENGINE))
			providers += list(list("displayText" = engine.module_name, "value" = engine.UID()))
			if(engine == rpm_destination_engine)
				.["selected_rpm_provide_engine"] = engine.UID()
	.["rpm_provide_engines"] = providers
	return .

/obj/item/spacepod_module/fuel_tank/engine/apu/ignite()
	if(enable || current_rpm > 0)
		return FALSE
	if(integrity <= 0)
		error_text = "Модуль уничтожен"
		return FALSE
	if(!process_power(1)) // can not ignite, because low power
		if(!connection_power_net)
			error_text = "Нет подключения к электросети для запуска стартера"
		else
			error_text = "Не хватает электричества для запуска стартера"
		return FALSE
	enable = TRUE
	return TRUE

/obj/item/spacepod_module/fuel_tank/engine/apu/turn_off()
	. = ..()
	if(!isnull(rpm_destination_engine))
		select_rpm_destination_engine(null)

/obj/item/spacepod_module/fuel_tank/engine/apu/process_work(seconds_per_tick)
	. = ..()
	if(current_rpm <= 0 || !rpm_destination_engine)
		return
	if(!enable)
		select_rpm_destination_engine(null)
		return
	rpm_destination_engine.current_rpm = max(rpm_destination_engine.current_rpm, current_rpm / 10) // 10% of rpm provde to engine for ignition
	current_rpm = max(current_rpm - current_rpm / 20, 0) // slowly stop by 5% becase rpm provide to engine
	if(current_rpm == 0)
		error_text = "Низкие обороты"
		turn_off()

/obj/item/spacepod_module/fuel_tank/engine/apu/proc/select_rpm_destination_engine(obj/item/spacepod_module/fuel_tank/engine/destination)
	if(!enable && destination)
		return
	rpm_destination_engine?.external_rotation = FALSE
	rpm_destination_engine = destination
	rpm_destination_engine?.external_rotation = TRUE


// MARK: Gyroscope
/obj/item/spacepod_module/gyroscope
	slot = SPACEPOD_MODULE_SLOT_GYRO
	module_name = "Гироскопический стабилизатор"
	desc = "Генерирует крутящий момент для маневрирования челнока в открытом космосе, компенсирует вращение и раскачку челнока."
	icon_state = "gyro"
	caption = "GYRO"
	hit_weight = POD_MODULE_HIT_CHANCE_LARGE
	max_integrity = 70
	consume_power = 50
	mass = 100
	/// Maximal rotations per minutes
	var/max_rpm = 50000
	/// Current rotations per minutes
	var/current_rpm = 0
	/// Ignition acceleration (rpm increase per units)
	var/ignition_acceleration = 10000

/obj/item/spacepod_module/gyroscope/get_ui_data()
	. = ..()
	var/rpm_percent = max_rpm > 0 ? round(current_rpm / max_rpm * 100, 1) : 0
	.["power_link"] = connection_power_net
	.["rpm"] = current_rpm
	.["rpm_percent"] = rpm_percent
	.["rpm_warn"] = rpm_percent < 10 || rpm_percent > 120
	.["temperature"] = 32 + rand(1, 10)
	.["temperature_warn"] = FALSE
	return .

/obj/item/spacepod_module/gyroscope/process_work(seconds_per_tick)
	if(!enable) // slowly stoping
		if(current_rpm == 0)
			return
		current_rpm = max(current_rpm - ignition_acceleration / 2 * seconds_per_tick, 0)
		return
	if(!process_power(seconds_per_tick))
		if(!connection_power_net)
			error_text = "Нет подключения к электросети для работы гироскопического стабилизатора"
		else
			error_text = "Не хватает электричества для работы гироскопического стабилизатора"
		turn_off()
		return
	if(current_rpm >= max_rpm)
		return
	current_rpm = min(current_rpm + ignition_acceleration * seconds_per_tick, max_rpm)

/obj/item/spacepod_module/gyroscope/proc/is_working()
	return current_rpm > max_rpm * 0.25


// MARK: Weapon
/obj/item/spacepod_module/weapon
	slot = SPACEPOD_MODULE_SLOT_WEAPON
	module_name = "Вооружение"
	desc = "Оружейная установка с двумя слотами для стрелкового оружия. Позволяет пилоту вести огонь из орудий, установленных на челноке."
	icon_state = "weapon"
	caption = "WPN"
	hit_weight = POD_MODULE_HIT_CHANCE_LARGE
	max_integrity = 100
	consume_power = 5
	mass = 250
	var/only_course_fire = FALSE
	/// Wing for next shot: 1 - right, -1 - left.
	var/next_fire_side = -1
	var/datum/spacepod_weapon_slot/primary = new("primary", "Основное")
	var/datum/spacepod_weapon_slot/secondary = new("secondary", "Дополнительное")

/obj/item/spacepod_module/weapon/Destroy(force)
	QDEL_NULL(primary)
	QDEL_NULL(secondary)
	return ..()

/obj/item/spacepod_module/weapon/get_ui_data()
	. = ..()
	.["power_link"] = connection_power_net
	.["guns"] = get_guns_data()
	return .

/obj/item/spacepod_module/weapon/proc/get_guns_data()
	var/list/guns = list()
	if(primary.weapon)
		guns += list(get_gun_data(primary, TRUE))
	if(secondary.weapon)
		guns += list(get_gun_data(secondary, FALSE))
	return guns

/obj/item/spacepod_module/weapon/proc/get_gun_data(datum/spacepod_weapon_slot/gun_slot, is_primary)
	var/list/data = list()
	data["id"] = gun_slot.id
	data["name"] = gun_slot.weapon.declent_ru(NOMINATIVE)
	data["primary"] = is_primary
	data["safety"] = gun_slot.safety
	data["charging"] = gun_slot.charging
	if(isprojectilegun(gun_slot.weapon))
		data["type"] = 1
		var/obj/item/gun/projectile/projectile_gun = gun_slot.weapon
		data["ammo"] = projectile_gun.get_ammo()
		data["capacity"] = projectile_gun.magazine ? projectile_gun.magazine.max_ammo : 0
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

/obj/item/spacepod_module/weapon/on_remove(obj/spacepod/pod)
	. = ..()
	primary.restore_weapon_offset()
	secondary.restore_weapon_offset()

/obj/item/spacepod_module/weapon/on_pod_emp(datum/source, severity)
	for(var/datum/spacepod_weapon_slot/weapon_slot as anything in list(primary, secondary))
		var/obj/item/gun/energy/energy_gun = weapon_slot.weapon
		if(!isenergygun(energy_gun))
			continue
		if(energy_gun.chambered?.BB)
			QDEL_NULL(energy_gun.chambered.BB)
		energy_gun.chambered = null
		if(energy_gun.cell)
			energy_gun.cell.charge = 0
			energy_gun.cell.update_icon(UPDATE_OVERLAYS)
		energy_gun.newshot()
		energy_gun.update_appearance()
	return ..()

/obj/item/spacepod_module/weapon/proc/install_gun(obj/item/gun/installed_gun)
	if(isnull(primary.weapon))
		primary.install_weapon(installed_gun)
		return TRUE
	if(isnull(secondary.weapon))
		secondary.install_weapon(installed_gun)
		return TRUE
	return FALSE

/obj/item/spacepod_module/weapon/proc/remove_gun(obj/item/gun/selected_gun)
	if(primary.weapon == selected_gun)
		primary.clear_weapon()
		primary.charging = FALSE
		primary.safety = TRUE
		return selected_gun
	if(secondary.weapon == selected_gun)
		secondary.clear_weapon()
		secondary.charging = FALSE
		secondary.safety = TRUE
		return selected_gun
	return null


/obj/item/spacepod_module/weapon/process_work(seconds_per_tick)
	if(!enable)
		return
	if(!process_power(seconds_per_tick))
		if(!connection_power_net)
			error_text = "Нет подключения к электросети"
		else
			error_text = "Не хватает электричества для работы"
		turn_off()
		return
	primary.process_charge(src)
	secondary.process_charge(src)

/obj/item/spacepod_module/weapon/course
	module_name = "Курсовое вооружение"
	desc = "Оружейная установка курсового огня с двумя слотами для стрелкового оружия. Позволяет пилоту вести огонь из орудий, установленных на челноке."
	only_course_fire = TRUE

/obj/item/spacepod_module/weapon/turret
	module_name = "Турельное вооружение"
	desc = "Турельная установка с двумя слотами для стрелкового оружия. Позволяет пилоту вести огонь из орудий, установленных на челноке."


/datum/spacepod_weapon_slot
	var/id
	var/name
	var/obj/item/gun/weapon = null
	var/safety = TRUE
	var/charging = FALSE
	var/recharge_rate = 100
	var/original_pixel_x = 0
	var/original_pixel_y = 0

/datum/spacepod_weapon_slot/New(id, name)
	. = ..()
	src.id = id
	src.name = name

/datum/spacepod_weapon_slot/proc/install_weapon(obj/item/gun/new_weapon)
	weapon = new_weapon
	original_pixel_x = new_weapon.pixel_x
	original_pixel_y = new_weapon.pixel_y

/datum/spacepod_weapon_slot/proc/set_fire_origin(obj/spacepod/pod, side)
	if(!weapon || !pod)
		return
	var/list/pixel_offsets = pod.get_weapon_fire_pixel_offsets(side)
	weapon.pixel_x = original_pixel_x + pixel_offsets[1]
	weapon.pixel_y = original_pixel_y + pixel_offsets[2]

/datum/spacepod_weapon_slot/proc/restore_weapon_offset()
	if(!weapon)
		return
	weapon.pixel_x = original_pixel_x
	weapon.pixel_y = original_pixel_y

/datum/spacepod_weapon_slot/proc/clear_weapon()
	restore_weapon_offset()
	weapon = null
	original_pixel_x = 0
	original_pixel_y = 0

/datum/spacepod_weapon_slot/proc/reload(obj/spacepod/pod, mob/user)
	if(isnull(weapon))
		return
	if(isenergygun(weapon))
		charging = !charging
		return
	if(!isprojectilegun(weapon))
		return
	var/obj/item/gun/projectile/gun = weapon
	if(gun.chambered && isnull(gun.chambered.BB))
		gun.process_chamber(TRUE, TRUE)
		pod.balloon_alert(user, "затвор передёрнут")
		playsound(pod.loc, 'sound/weapons/gun_interactions/remove_bullet.ogg', 50, TRUE)
		return
	if(isnull(pod.cargo_hold))
		return
	for(var/obj/item/ammo_box/magazine/magazine in pod.cargo_hold.contents)
		if(!istype(magazine, gun.mag_type))
			continue
		var/obj/item/ammo_box/magazine/gun_magazine = gun.magazine
		gun.attackby(magazine, user)
		var/mag_changed = (gun_magazine && gun_magazine.loc != gun)
		if(!mag_changed || !pod.cargo_hold.can_be_inserted(gun_magazine))
			return
		pod.cargo_hold.handle_item_insertion(gun_magazine)
		gun_magazine.update_appearance()
		return

/datum/spacepod_weapon_slot/proc/process_charge(obj/item/spacepod_module/weapon/module)
	if(isnull(weapon) || !charging || !isenergygun(weapon))
		return
	var/obj/item/gun/energy/energy_gun = weapon
	if(!module.systems)
		return
	if(module.systems.consume_power(recharge_rate))
		energy_gun.cell.give(recharge_rate)


// MARK: Armor
/obj/item/spacepod_module/armor
	slot = SPACEPOD_MODULE_SLOT_ARMOR
	caption = "ARM"
	module_name = "Броня челнока"
	icon_state = "armor"
	hit_weight = POD_MODULE_HIT_CHANCE_EXTRA_LARGE
	max_integrity = 75
	mass = 60

/obj/item/spacepod_module/armor/install_to(mob/living/user, obj/spacepod/pod)
	var/list/armors = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_ARMOR)
	var/list/engines = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_ENGINE)
	if(length(armors) >= POD_ARMOR_PLATE_BY_ENGINE * length(engines))
		to_chat(user, span_notice("Установлено максимальное количество модулей брони в космическом челноке!"))
		return FALSE
	var/armor_id = "armor_[length(armors) + 1]"
	var/name = tgui_input_text(user, "Название бронеэлемента", "Указать название бронеэлемента", default = armor_id, max_length = MAX_NAME_LEN, encode = TRUE)
	if(QDELETED(src) || isnull(name))
		return FALSE
	src.name = name
	src.caption = "ARM [length(armors) + 1]"
	return TRUE

/obj/item/spacepod_module/armor/light
	module_name = "Лёгкая броня"
	desc = "Лёгкая бронепластина для защиты корпуса челнока. Небольшой вес, но ограниченная прочность."

/obj/item/spacepod_module/armor/heavy
	module_name = "Тяжёлая броня"
	desc = "Усиленная бронепластина с высоким сопротивлением урону. Значительно тяжелее лёгкой, но выдерживает прямые попадания."
	icon_state = "armor_heavy"
	max_integrity = 150
	mass = 150


// MARK: Cargo
/obj/item/spacepod_module/cargo
	slot = SPACEPOD_MODULE_SLOT_MISC
	caption = "CARGO"
	module_name = "Грузовой отсек"
	desc = "Грузовой отсек для перевозки небольших предметов и ящиков. Позволяет загружать и выгружать груз через люк техобслуживания."
	hit_weight = POD_MODULE_HIT_CHANCE_LARGE
	mass = 100

/obj/item/spacepod_module/cargo/install_to(mob/living/user, obj/spacepod/pod)
	if(!isnull(pod.cargo_hold))
		to_chat(user, span_notice("Грузовой отсек уже установлен в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/cargo/on_install(obj/spacepod/pod)
	. = ..()
	pod.create_cargo_hold()

/obj/item/spacepod_module/cargo/on_remove(obj/spacepod/pod)
	. = ..()
	pod.remove_cargo_hold()


// MARK: Life support
/obj/item/spacepod_module/life_support
	slot = SPACEPOD_MODULE_SLOT_MISC
	caption = "AIR"
	module_name = "Жизнеобеспечение"
	desc = "Поддерживает пригодную для дыхания атмосферу и температуру в кабине шаттла."
	icon_state = "life_support"
	mass = 40
	consume_power = 50

/obj/item/spacepod_module/life_support/install_to(mob/living/user, obj/spacepod/pod)
	if(!isnull(pod.systems.get_misc_module(/obj/item/spacepod_module/life_support)))
		to_chat(user, span_notice("Модуль жизнеобеспечения уже установлен в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/life_support/process_work(seconds_per_tick)
	if(!enable)
		return
	if(process_power(seconds_per_tick))
		systems?.pod.give_air()
		systems?.pod.regulate_temp()
		return

	if(!connection_power_net)
		error_text = "Нет подключения к электросети для работы жизнеобеспечения"
	else
		error_text = "Не хватает электричества для работы жизнеобеспечения"
	turn_off()


// MARK: Misc modules
/obj/item/spacepod_module/passenger_seat
	slot = SPACEPOD_MODULE_SLOT_MISC
	caption = "SEAT"
	module_name = "Пассажирское сиденье"
	desc = "Дополнительное место для пассажира. Позволяет взять на борт ещё одного человека, но не даёт ему управления челноком."
	icon_state = "sec_cargo_chair"
	hit_weight = 0
	mass = 220

/obj/item/spacepod_module/passenger_seat/install_to(mob/living/user, obj/spacepod/pod)
	var/list/engines = pod.systems.get_slot(SPACEPOD_MODULE_SLOT_ENGINE)
	if(pod.max_passengers >= POD_PASSENGERS_BY_ENGINE * length(engines))
		to_chat(user, span_notice("Установлено максимальное количество пассажирский сидений в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/passenger_seat/on_install(obj/spacepod/pod)
	. = ..()
	pod.max_passengers++

/obj/item/spacepod_module/passenger_seat/on_remove(obj/spacepod/pod)
	. = ..()
	pod.max_passengers--

/obj/item/spacepod_module/fire_extingusher
	slot = SPACEPOD_MODULE_SLOT_MISC
	caption = "FIRE"
	module_name = "Пожаротушение"
	desc = "Система тушения пожара. Распыляет огнетушащий состав при обнаружении возгорания."
	icon_state = "fire_extinguisher"
	hit_weight = 0
	mass = 180
	var/charges = 3

/obj/item/spacepod_module/fire_extingusher/five_charges
	charges = 5

/obj/item/spacepod_module/fire_extingusher/install_to(mob/living/user, obj/spacepod/pod)
	if(!isnull(pod.systems.get_misc_module(/obj/item/spacepod_module/fire_extingusher)))
		to_chat(user, span_notice("Модуль пожаротушения уже установлен в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/key_lock
	slot = SPACEPOD_MODULE_SLOT_MISC
	caption = "LOCK"
	module_name = "Замок челнока"
	desc = "Электронный замок, блокирующий доступ к челноку. Для посадки требуется специальный ключ изготовленный из заготовки."
	icon_state = "lock_tumbler"
	hit_weight = POD_MODULE_HIT_CHANCE_SMALL
	mass = 30
	var/key_id

/obj/item/spacepod_module/key_lock/install_to(mob/living/user, obj/spacepod/pod)
	if(!isnull(pod.systems.get_misc_module(/obj/item/spacepod_module/key_lock)))
		to_chat(user, span_notice("Модуль замка уже установлен в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/key_lock/on_install(obj/spacepod/pod)
	. = ..()
	RegisterSignal(pod, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_key_used))

/obj/item/spacepod_module/key_lock/on_remove(obj/spacepod/pod)
	UnregisterSignal(pod, COMSIG_ATOM_ITEM_INTERACTION)
	return ..()

/obj/item/spacepod_module/key_lock/proc/on_key_used(datum/source, mob/living/user, obj/item/item, list/modifiers)
	SIGNAL_HANDLER
	if(!istype(item, /obj/item/spacepod_key))
		return NONE
	var/obj/item/spacepod_key/key = item
	if(key.id != key_id)
		balloon_alert(user, "неправильный ключ!")
		return ITEM_INTERACT_BLOCKING
	systems?.pod.add_fingerprint(user)
	systems?.pod.toggle_lock(user)
	return ITEM_INTERACT_SUCCESS

/obj/item/spacepod_module/key_lock/auto_id
	var/static/id_source = 0

/obj/item/spacepod_module/key_lock/auto_id/Initialize(mapload)
	. = ..()
	key_id = ++id_source

/obj/item/spacepod_module/key_lock/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/spacepod_key))
		add_fingerprint(user)
		var/obj/item/spacepod_key/key = item
		if(key.id)
			to_chat(user, span_warning("Этот ключ уже используется."))
			return ATTACK_CHAIN_PROCEED
		key.id = key_id
		to_chat(user, span_notice("Вы заточили заготовку ключа под замок."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/spacepod_key
	name = "spacepod key"
	desc = "Маленький ключ для доступа к космическому челноку. Предназначен для открытия модуля замка у космического челнока."
	icon = 'icons/obj/spacepod.dmi'
	icon_state = "podkey"
	w_class = WEIGHT_CLASS_TINY
	var/id = 0

/obj/item/spacepod_key/get_ru_names()
	return alist(
		NOMINATIVE = "ключ к космическому челноку",
		GENITIVE = "ключа к космическому челноку",
		DATIVE = "ключу к космическому челноку",
		ACCUSATIVE = "ключ к космическому челноку",
		INSTRUMENTAL = "ключом к космическому челноку",
		PREPOSITIONAL = "ключе к космическому челноку",
	)

/obj/item/spacepod_module/catapult_module
	slot = SPACEPOD_MODULE_SLOT_MISC
	caption = "CAT"
	module_name = "Аварийное катапультирование"
	desc = "Система экстренной эвакуации пилота. Автоматически выбрасывает пилота в направлении, противоположном курсу челнока в случае критического повреждения корпуса."
	icon_state = "cargo_crate"
	hit_weight = POD_MODULE_HIT_CHANCE_SMALL
	mass = 50

/obj/item/spacepod_module/catapult_module/install_to(mob/living/user, obj/spacepod/pod)
	if(!isnull(pod.systems.get_misc_module(/obj/item/spacepod_module/catapult_module)))
		to_chat(user, span_notice("Модуль катапульты уже установлен в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/tracker
	slot = SPACEPOD_MODULE_SLOT_MISC
	caption = "TR"
	module_name = "GPS маячок"
	desc = "Модуль маячка, позволяет находить челнок с помощью специальной консоли."
	icon_state = "lock_card"
	hit_weight = POD_MODULE_HIT_CHANCE_SMALL
	mass = 5
	var/obj/spacepod/pod

/obj/item/spacepod_module/tracker/install_to(mob/living/user, obj/spacepod/pod)
	if(!isnull(pod.systems.get_misc_module(/obj/item/spacepod_module/tracker)))
		to_chat(user, span_notice("Модуль маячка уже установлен в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/tracker/on_install(obj/spacepod/pod)
	. = ..()
	src.pod = pod
	GLOB.pod_trackers |= src
	return TRUE

/obj/item/spacepod_module/tracker/on_remove(obj/spacepod/pod)
	. = ..()
	src.pod = null
	GLOB.pod_trackers -= src
	return TRUE
