// MARK: Basic module
/obj/item/spacepod_module
	desc = "Модуль космического челнока."
	icon = 'icons/obj/spacepod.dmi'
	icon_state = "cargo_blank"
	origin_tech = "programming=2;materials=2;engineering=2"
	var/id = "unknown"
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
	name = "module \"[module_name]\""

/obj/item/spacepod_module/proc/install_to(mob/living/user, obj/spacepod/pod)
	return FALSE

/obj/item/spacepod_module/proc/on_install(obj/spacepod/pod)
	return TRUE

/obj/item/spacepod_module/proc/on_remove(obj/spacepod/pod)
	return TRUE

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
	if(!connection_power_net)
		return FALSE
	if(!systems || !systems.battery)
		return FALSE
	return systems.battery.consume_power(consume_power * seconds_per_tick)

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
	integrity -= absorbed_damage
	if(integrity > 0 && fire_on_hit_chance > 0 && prob(damage_amount * fire_on_hit_chance / 100))
		fire = TRUE
	if(integrity <= 0 && enable)
		enable = FALSE
	return damage_amount - absorbed_damage


// MARK: Fuel tank
/obj/item/spacepod_module/fuel_tank
	id = "fuel_tank"
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

/obj/item/spacepod_module/fuel_tank/proc/consume_fuel(amount)
	if(amount > fuel_amount)
		amount = fuel_amount

	fuel_amount -= amount
	return amount

/obj/item/spacepod_module/fuel_tank/full/New(id)
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

/obj/item/spacepod_module/fuel_tank/large/full/New(id)
	. = ..()
	fuel_amount = fuel_capacity

/obj/item/spacepod_module/fuel_tank/install_to(mob/living/user, obj/spacepod/pod)
	if(length(pod.systems.fuel_tanks) >= POD_MAX_FUEL_TANKS)
		return FALSE
	var/fueltank_id = "fueltank_[length(pod.systems.fuel_tanks) + 1]"
	var/fueltank_name = tgui_input_text(user, "Название топливного бака", "Назвать топливный бак", default=fueltank_id, max_length = MAX_NAME_LEN, encode = TRUE)
	if(fueltank_name == null)
		return FALSE
	var/caption = "TK [length(pod.systems.fuel_tanks) + 1]"
	caption = tgui_input_text(user, "Сокращенный код бака", "Указать код топливный бак", default=caption, max_length = MAX_NAME_LEN, encode = TRUE)
	if(QDELETED(src) || caption == null)
		return FALSE
	src.id = fueltank_id
	src.caption = caption
	src.module_name = fueltank_name
	return TRUE


// MARK: Battery
/obj/item/spacepod_module/battery
	id = "battery"
	caption = "BATT"
	module_name = "Аккумуляторная батарея"
	desc = "Аккумулирует электроэнергию от генераторов и питает электросеть для бортовых систем челнока."
	icon_state = "battery"
	max_integrity = 100
	fire_on_hit_chance = 10
	mass = 80
	enable = TRUE
	/// Battery capacity in watt
	var/power_capacity = 5000 //watt
	/// Current power level in watt
	var/power = 0

/obj/item/spacepod_module/battery/full/New(id)
	. = ..()
	power = power_capacity

/obj/item/spacepod_module/battery/install_to(mob/living/user, obj/spacepod/pod)
	if(pod.systems.battery != null)
		to_chat(user, span_notice("Аккумуляторная батарея уже установлена в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/battery/proc/consume_power(amount)
	if(!connection_power_net)
		return FALSE
	if(!enable)
		return FALSE
	if(power < amount)
		return FALSE
	power -= amount
	return TRUE

/obj/item/spacepod_module/battery/proc/accumulate_power(amount)
	power = min(power + amount, power_capacity)


// MARK: Fuel pump
/obj/item/spacepod_module/fuel_pump
	id = "fuel_pump"
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

/obj/item/spacepod_module/fuel_pump/install_to(mob/living/user, obj/spacepod/pod)
	if(length(pod.systems.fuel_tanks) == 0)
		to_chat(user, span_notice("Чтобы установить топливный насос, сначала установите топливный бак!"))
		return FALSE
	var/obj/item/spacepod_module/fuel_tank/source_fueltank = tgui_input_list(user, "Выберите откуда насос будет качать топливо:", "Выбор источника топлива", pod.systems.fuel_tanks)
	var/obj/item/spacepod_module/fuel_tank/destination_fueltank = tgui_input_list(user, "Выберите куда насос будет качать топливо:", "Выбор назначения топлива", pod.systems.fuel_tanks | pod.systems.engines)
	var/pump_id = "fuelpump_[length(pod.systems.fuel_pumps) + 1]"
	var/pump_name = tgui_input_text(user, "Название топливного насоса", "Назвать топливный насос", default=pump_id, max_length = MAX_NAME_LEN, encode = TRUE)
	if(pump_name == null)
		return FALSE
	var/caption = "PUMP [length(pod.systems.fuel_pumps) + 1]"
	caption = tgui_input_text(user, "Сокращенный код топливного насоса", "Указать код топливного насоса", default=caption, max_length = MAX_NAME_LEN, encode = TRUE)
	if(QDELETED(src) || caption == null)
		return FALSE
	src.id = pump_id
	src.caption = caption
	src.module_name = pump_name
	src.source_tank = source_fueltank
	src.destination_tank = destination_fueltank
	return TRUE

/obj/item/spacepod_module/fuel_pump/process_work(seconds_per_tick)
	. = ..()
	if(!.)
		return
	if(source_tank == null || destination_tank == null)
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
	destination_tank.fuel_amount += pumped


// MARK: Engines
/obj/item/spacepod_module/fuel_tank/engine
	id = "engine"
	module_name = "Двигатель челнока"
	desc = "Базовый маршевый двигатель челнока. Обеспечивает тягу для перемещения в космосе. Требуется вспомогательная силовая установка для запуска данного двигателя."
	icon_state = "engine"
	caption = "ENG"
	max_integrity = 120
	fire_damage_mod = 1
	fire_on_hit_chance = 15
	mass = 150
	fuel_capacity = 30
	var/thrust = 3500
	/// How many fuel consume in units per tick on 100% of power
	var/fuel_consume_amount = 1
	/// Maximal rotations per minutes
	var/max_rpm = 15000
	/// Current rotations per minutes
	var/current_rpm = 0
	/// Ignition acceleration (rpm increase per units)
	var/ignition_acceleration = 1000
	/// How many fuel consume in units per seconds
	var/fuel_consume_speed = 2 // unit/sec
	var/generator_enable = FALSE
	/// How many powers generate on 100% rpm per seconds in watt
	var/generate_power = 100
	/// Receiving external rotation
	var/external_rotation = FALSE

/obj/item/spacepod_module/fuel_tank/engine/install_to(mob/living/user, obj/spacepod/pod)
	if(length(pod.systems.engines) >= POD_MAX_ENGINES)
		return FALSE
	var/engine_id = "engine_[length(pod.systems.engines) + 1]"
	var/engine_name = tgui_input_text(user, "Название двигателя", "Назвать двигатель", default=engine_id, max_length = MAX_NAME_LEN, encode = TRUE)
	if(engine_name == null)
		return FALSE
	var/caption = "ENG [length(pod.systems.engines) + 1]"
	caption = tgui_input_text(user, "Сокращенный код двигателя", "Указать код двигателя", default=caption, max_length = MAX_NAME_LEN, encode = TRUE)
	if(QDELETED(src) || caption == null)
		return FALSE
	src.id = engine_id
	src.caption = caption
	src.module_name = engine_name
	return TRUE

/obj/item/spacepod_module/fuel_tank/engine/proc/get_rpm_percent()
	return round(current_rpm / max_rpm * 100, 1)

/obj/item/spacepod_module/fuel_tank/engine/turn_on()
	error_text = null
	ignite()

/obj/item/spacepod_module/fuel_tank/engine/proc/ignite()
	if(enable)
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
		if(systems && systems.battery)
			systems.battery.accumulate_power(rpm_mod * generate_power * seconds_per_tick)

	if(!enable) // slowly stoping
		if(external_rotation || current_rpm == 0)
			return
		current_rpm = max(current_rpm - ignition_acceleration * seconds_per_tick, 0)
		return

	if(!consume_fuel(fuel_consume_speed * seconds_per_tick) > 0)
		error_text = "Топливное голодание"
		enable = FALSE //auto off
		return
	if(current_rpm >= max_rpm)
		return
	current_rpm = min(current_rpm + ignition_acceleration * seconds_per_tick, max_rpm)

/obj/item/spacepod_module/fuel_tank/engine/heavy
	module_name = "Форсажный двигатель челнока"
	desc = "Двигатель челнока повышенной тяги. Значительно мощнее базового, но быстрее расходует топливо. Требуется вспомогательная силовая установка для запуска данного двигателя."
	icon_state = "engine_speedy"
	thrust = 6000
	fuel_consume_amount = 2
	mass = 170


// MARK: APU
/obj/item/spacepod_module/fuel_tank/engine/apu
	id = "apu"
	caption = "APU"
	module_name = "Вспомогательная силовая установка"
	desc = "Вспомогательная силовая установка обеспечивает челнок электроэнергией при выключенном маршевом двигателе и выдает крутящий момент для запуска основных двигателей челнока."
	icon_state = "apu"
	thrust = 0
	mass = 100
	consume_power = 1000
	generate_power = 50
	var/obj/item/spacepod_module/fuel_tank/engine/rpm_destination_engine = null

/obj/item/spacepod_module/fuel_tank/engine/apu/is_apu()
	return TRUE

/obj/item/spacepod_module/fuel_tank/engine/apu/install_to(mob/living/user, obj/spacepod/pod)
	if(pod.systems.apu != null)
		to_chat(user, span_notice("Вспомогательная силовая установка уже установлена в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/fuel_tank/engine/apu/ignite()
	if(enable || current_rpm > 0)
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
	if(rpm_destination_engine != null)
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
	if(rpm_destination_engine)
		rpm_destination_engine.external_rotation = FALSE
	rpm_destination_engine = destination
	if(rpm_destination_engine)
		rpm_destination_engine.external_rotation = TRUE


// MARK: Gyroscope
/obj/item/spacepod_module/gyroscope
	id = "gyroscope"
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
	var/ignition_acceleration = 1000

/obj/item/spacepod_module/gyroscope/process_work(seconds_per_tick)
	if(!enable) // slowly stoping
		if(current_rpm == 0)
			return
		current_rpm = max(current_rpm - ignition_acceleration * seconds_per_tick, 0)
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

/obj/item/spacepod_module/gyroscope/install_to(mob/living/user, obj/spacepod/pod)
	if(pod.systems.gyroscope != null)
		to_chat(user, span_notice("Стабилизирующий гироскоп уже установлен в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/gyroscope/proc/is_working()
	return current_rpm > max_rpm / 2


// MARK: Weapon
/obj/item/spacepod_module/weapon
	id = "weapon"
	module_name = "Модуль вооружения"
	desc = "Оружейная установка с двумя слотами для стрелкового оружия. Позволяет пилоту вести огонь из орудий, установленных на челноке."
	icon_state = "weapon"
	caption = "WPN"
	hit_weight = POD_MODULE_HIT_CHANCE_LARGE
	max_integrity = 100
	consume_power = 5
	mass = 250
	var/only_course_fire = FALSE
	var/datum/spacepod_weapon_slot/primary = new("primary", "Основное")
	var/datum/spacepod_weapon_slot/secondary = new("secondary", "Дополнительное")

/obj/item/spacepod_module/weapon/Destroy(force)
	QDEL_NULL(primary)
	QDEL_NULL(secondary)
	. = ..()

/obj/item/spacepod_module/weapon/install_to(mob/living/user, obj/spacepod/pod)
	if(pod.systems.weapon != null)
		to_chat(user, span_notice("Модуль вооружения уже установлен в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/weapon/proc/install_gun(obj/item/gun/installed_gun)
	if(primary.weapon == null)
		primary.weapon = installed_gun
		return TRUE
	if(secondary.weapon == null)
		secondary.weapon = installed_gun
		return TRUE
	return FALSE

/obj/item/spacepod_module/weapon/proc/remove_gun(obj/item/gun/selected_gun)
	if(primary.weapon == selected_gun)
		primary.weapon = null
		primary.charging = FALSE
		primary.safety = TRUE
		return selected_gun
	if(secondary.weapon == selected_gun)
		secondary.weapon = null
		secondary.charging = FALSE
		secondary.safety = TRUE
		return selected_gun
	return null


/datum/spacepod_weapon_slot
	var/id
	var/name
	var/obj/item/gun/weapon = null
	var/safety = TRUE
	var/charging = FALSE
	var/recharge_rate = 100

/datum/spacepod_weapon_slot/New(id, name)
	. = ..()
	src.id = id
	src.name = name

/datum/spacepod_weapon_slot/proc/reload(obj/spacepod/pod, mob/user)
	if(weapon == null)
		return
	if(isenergygun(weapon))
		charging = !charging
		return

	if(isprojectilegun(weapon))
		var/obj/item/gun/projectile/gun = weapon
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
	if(weapon == null)
		return
	if(!charging)
		return
	if(!isenergygun(weapon))
		return
	var/obj/item/gun/energy/energy_gun = weapon
	if(module.systems.battery.consume_power(recharge_rate))
		energy_gun.cell.give(recharge_rate)

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
	id = "weapon_course"
	module_name = "Модуль курсового вооружения"
	desc = "Оружейная установка курсового огня с двумя слотами для стрелкового оружия. Позволяет пилоту вести огонь из орудий, установленных на челноке."
	only_course_fire = TRUE

/obj/item/spacepod_module/weapon/course/get_ru_names()
	return alist(
		NOMINATIVE = "модуль курсового вооружения",
		GENITIVE = "модуля курсового вооружения",
		DATIVE = "модулю курсового вооружения",
		ACCUSATIVE = "модуль курсового вооружения",
		INSTRUMENTAL = "модулем курсового вооружения",
		PREPOSITIONAL = "модуле курсового вооружения",
	)

/obj/item/spacepod_module/weapon/turret
	id = "weapon_turret"
	module_name = "Модуль турельного вооружения"
	desc = "Турельная установка с двумя слотами для стрелкового оружия. Позволяет пилоту вести огонь из орудий, установленных на челноке."


// MARK: Armor
/obj/item/spacepod_module/armor
	id = "armor"
	caption = "ARM"
	module_name = "модуль брони"
	icon_state = "armor"
	hit_weight = POD_MODULE_HIT_CHANCE_EXTRA_LARGE
	max_integrity = 75
	mass = 60

/obj/item/spacepod_module/armor/install_to(mob/living/user, obj/spacepod/pod)
	if(length(pod.systems.armors) >= POD_ARMOR_PLATE_BY_ENGINE * length(pod.systems.engines))
		to_chat(user, span_notice("Установлено максимальное количество модулей брони в космическом челноке!"))
		return FALSE
	var/armor_id = "armor_[length(pod.systems.armors) + 1]"
	var/name = tgui_input_text(user, "Название бронеэлемента", "Указать название бронеэлемента", default=armor_id, max_length = MAX_NAME_LEN, encode = TRUE)
	if(QDELETED(src) || name == null)
		return FALSE
	src.name = name
	src.id = armor_id
	src.caption = "ARM [length(pod.systems.armors) + 1]"
	return TRUE

/obj/item/spacepod_module/armor/light
	id = "armor_light"
	module_name = "Модуль лёгкой брони"
	desc = "Лёгкая бронепластина для защиты корпуса челнока. Небольшой вес, но ограниченная прочность."

/obj/item/spacepod_module/armor/heavy
	id = "armor_heavy"
	module_name = "Модуль тяжёлой брони"
	desc = "Усиленная бронепластина с высоким сопротивлением урону. Значительно тяжелее лёгкой, но выдерживает прямые попадания."
	icon_state = "armor_heavy"
	max_integrity = 150
	mass = 150


// MARK: Life support
/obj/item/spacepod_module/life_support
	id = "life_support"
	caption = "AIR"
	module_name = "Модуль жизнеобеспечения"
	desc = "Поддерживает пригодную для дыхания атмосферу и температуру в кабине шаттла."
	icon_state = "life_support"
	mass = 40
	consume_power = 50

/obj/item/spacepod_module/life_support/install_to(mob/living/user, obj/spacepod/pod)
	if(pod.systems.life_support != null)
		to_chat(user, span_notice("Модуль жизнеобеспечения уже установлен в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/life_support/process_work(seconds_per_tick)
	if(!enable)
		return
	if(process_power(seconds_per_tick))
		return

	if(!connection_power_net)
		error_text = "Нет подключения к электросети для работы жизнеобеспечения"
	else
		error_text = "Не хватает электричества для работы жизнеобеспечения"
	turn_off()


// MARK: Misc modules
/obj/item/spacepod_module/passenger_seat
	id = "passenger_seat"
	caption = "SEAT"
	module_name = "Пассажирское сиденье"
	desc = "Дополнительное место для пассажира. Позволяет взять на борт ещё одного человека, но не даёт ему управления челноком."
	icon_state = "sec_cargo_chair"
	hit_weight = 0
	mass = 220

/obj/item/spacepod_module/passenger_seat/install_to(mob/living/user, obj/spacepod/pod)
	if(pod.max_passengers >= POD_PASSENGERS_BY_ENGINE * length(pod.systems.engines))
		to_chat(user, span_notice("Установлено максимальное количество пассажирский сидений в космическом челноке!"))
		return FALSE
	src.id = "passenger_seat_[pod.max_passengers]"
	return TRUE

/obj/item/spacepod_module/passenger_seat/on_install(obj/spacepod/pod)
	pod.max_passengers += 1

/obj/item/spacepod_module/passenger_seat/on_remove(obj/spacepod/pod)
	pod.max_passengers -= 1

/obj/item/spacepod_module/fire_extingusher
	id = "fire_extinguisher"
	caption = "FIRE"
	module_name = "модуль пожаротушения"
	desc = "Система тушения пожара. Распыляет огнетушащий состав при обнаружении возгорания."
	icon_state = "fire_extinguisher"
	hit_weight = 0
	var/charges = 3
	mass = 180

/obj/item/spacepod_module/fire_extingusher/five_charges
	charges = 5

/obj/item/spacepod_module/fire_extingusher/install_to(mob/living/user, obj/spacepod/pod)
	if(pod.systems.fire_extenguisher != null)
		to_chat(user, span_notice("Модуль пожаротушения уже установлен в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/key_lock
	id = "key_lock"
	caption = "LOCK"
	module_name = "Модуль замка"
	desc = "Электронный замок, блокирующий доступ к челноку. Для посадки требуется специальный ключ изготовленный из заготовки."
	icon_state = "lock_tumbler"
	hit_weight = POD_MODULE_HIT_CHANCE_SMALL
	mass = 30
	var/key_id

/obj/item/spacepod_module/key_lock/auto_id
	var/static/id_source = 0

/obj/item/spacepod_module/key_lock/auto_id/Initialize(mapload)
	. = ..()
	key_id = ++id_source

/obj/item/spacepod_module/key_lock/install_to(mob/living/user, obj/spacepod/pod)
	if(pod.systems.key_lock != null)
		to_chat(user, span_notice("Модуль замка уже установлен в космическом челноке!"))
		return FALSE
	return TRUE

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
	id = "catapult"
	caption = "CAT"
	module_name = "Модуль аварийного катапультирования"
	desc = "Система экстренной эвакуации пилота. Автоматически выбрасывает пилота в направлении, противоположном курсу челнока в случае критического повреждения корпуса."
	icon_state = "cargo_crate"
	hit_weight = POD_MODULE_HIT_CHANCE_SMALL
	mass = 50

/obj/item/spacepod_module/catapult_module/install_to(mob/living/user, obj/spacepod/pod)
	if(pod.systems.catapult != null)
		to_chat(user, span_notice("Модуль пожаротушения уже установлен в космическом челноке!"))
		return FALSE
	return TRUE

/obj/item/spacepod_module/tracker
	id = "tracker"
	caption = "TR"
	module_name = "Модуль маячка"
	desc = "Модуль маячка, позволяет находить челнок с помощью специальной консоли."
	icon_state = "lock_card"
	hit_weight = POD_MODULE_HIT_CHANCE_SMALL
	mass = 5
	var/obj/spacepod/pod

/obj/item/spacepod_module/tracker/on_install(obj/spacepod/pod)
	src.pod = pod
	GLOB.pod_trackers |= src
	return TRUE

/obj/item/spacepod_module/tracker/on_remove(obj/spacepod/pod)
	src.pod = null
	GLOB.pod_trackers -= src
	return TRUE
