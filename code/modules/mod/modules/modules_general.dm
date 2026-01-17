//General modules for MODsuits

// MARK: Storage
/// Storage - Adds a storage component to the suit.
/obj/item/mod/module/storage
	name = "MOD storage module"
	desc = "Модуль для МЭК, являющийся системой устанавливаемых по всему костюму отсеков разного размера для хранения \
			снаряжения и мелких предметов."
	icon_state = "storage"
	complexity = 3
	incompatible_modules = list(/obj/item/mod/module/storage, /obj/item/mod/module/plate_compression)
	required_slots = list(ITEM_SLOT_BACK)
	/// Max weight class of items in the storage.
	var/max_w_class = WEIGHT_CLASS_NORMAL
	/// Max combined weight of all items in the storage.
	var/max_combined_w_class = 15
	/// Max amount of items in the storage.
	var/max_items = 7
	var/obj/item/storage/backpack/modstorage/bag

/obj/item/mod/module/storage/get_ru_names()
	return list(
		NOMINATIVE = "модуль вместимости",
		GENITIVE = "модуля вместимости",
		DATIVE = "модулю вместимости",
		ACCUSATIVE = "модуль вместимости",
		INSTRUMENTAL = "модулем вместимости",
		PREPOSITIONAL = "модуле вместимости",
	)

/obj/item/mod/module/storage/serialize()
	var/list/data = ..()
	data["bag"] = bag.serialize()
	return data

/obj/item/mod/module/storage/deserialize(list/data)
	. = ..()
	qdel(bag)
	bag = list_to_object(data["bag"], src)
	bag.source = src

/obj/item/mod/module/storage/Initialize(mapload)
	. = ..()
	var/obj/item/storage/backpack/modstorage/S = new(src)
	bag = S
	bag.max_w_class = max_w_class
	bag.max_combined_w_class = max_combined_w_class
	bag.storage_slots = max_items
	bag.source = src

/obj/item/mod/module/storage/Destroy()
	QDEL_NULL(bag)
	return ..()

/obj/item/mod/module/storage/on_install()
	. = ..()
	mod.bag = bag
	bag.forceMove(mod)

/obj/item/mod/module/storage/on_uninstall(deleting = FALSE)
	. = ..()
	if(!deleting)
		for(var/obj/our_obj as anything in bag.contents)
			our_obj.forceMove(get_turf(loc))
		bag.forceMove(src)
		mod.bag = null
		return
	qdel(bag)
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_CLOTH_OUTER)
	if(istype(suit))
		UnregisterSignal(suit, COMSIG_ITEM_PRE_UNEQUIP)

/obj/item/mod/module/storage/on_part_deactivation(deleting)
	. = ..()
	bag.forceMove(src) //So the pinpointer doesnt lie.

/obj/item/mod/module/storage/on_unequip()
	. = ..()
	bag.forceMove(src)

// MARK: Large storage
/obj/item/mod/module/storage/large_capacity
	name = "MOD expanded storage module"
	desc = "Модуль для МЭК, являющийся системой устанавливаемых по всему костюму отсеков разного размера для хранения \
			снаряжения и мелких предметов. Улучшенная модель, равномерно распределяющая массу, что позволяет \
			увеличить максимальную вместимость."
	icon_state = "storage_large"
	max_combined_w_class = 21
	max_items = 14

/obj/item/mod/module/storage/large_capacity/get_ru_names()
	return list(
		NOMINATIVE = "модуль повышенной вместимости",
		GENITIVE = "модуля повышенной вместимости",
		DATIVE = "модулю повышенной вместимости",
		ACCUSATIVE = "модуль повышенной вместимости",
		INSTRUMENTAL = "модулем повышенной вместимости",
		PREPOSITIONAL = "модуле повышенной вместимости",
	)

// MARK: Syndie storage
/obj/item/mod/module/storage/syndicate
	name = "MOD syndicate storage module"
	desc = "Модуль для МЭК, являющийся системой устанавливаемых по всему костюму отсеков разного размера для хранения \
			снаряжения и мелких предметов. Запатентованная модель Синдиката, использующая технологии сжатия материи, \
			что позволяет значительно увеличить максимальную вместимость."
	icon_state = "storage_syndi"
	max_combined_w_class = 30
	max_items = 21
	origin_tech = "materials=6;bluespace=5;syndicate=2"

/obj/item/mod/module/storage/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "модуль вместимости Синдиката",
		GENITIVE = "модуля вместимости Синдиката",
		DATIVE = "модулю вместимости Синдиката",
		ACCUSATIVE = "модуль вместимости Синдиката",
		INSTRUMENTAL = "модулем вместимости Синдиката",
		PREPOSITIONAL = "модуле вместимости Синдиката",
	)

// MARK: Belt storage
/obj/item/mod/module/storage/belt
	name = "MOD case storage module"
	desc = "Модуль для МЭК, предоставляющий отсек для хранения снаряжения и мелких предметов. \
			Обладает меньшей по сравнению с аналогами вместимостью."
	icon_state = "storage_case"
	complexity = 0
	max_w_class = WEIGHT_CLASS_SMALL
	removable = FALSE
	max_combined_w_class = 21
	required_slots = list(ITEM_SLOT_BELT)

/obj/item/mod/module/storage/belt/get_ru_names()
	return list(
		NOMINATIVE = "модуль пониженной вместимости",
		GENITIVE = "модуля пониженной вместимости",
		DATIVE = "модулю пониженной вместимости",
		ACCUSATIVE = "модуль пониженной вместимости",
		INSTRUMENTAL = "модулем пониженной вместимости",
		PREPOSITIONAL = "модуле пониженной вместимости",
	)

// MARK: BS storage
/obj/item/mod/module/storage/bluespace
	name = "MOD bluespace storage module"
	desc = "Модуль для МЭК, являющийся системой устанавливаемых по всему костюму отсеков разного размера для хранения \
			снаряжения и мелких предметов. Эксклюзивная модель, запатентованная \"Нанотрейзен\". \
			Использует блюспейс-технологии для радикального увеличения максимальной вместимости."
	icon_state = "storage_bluespace"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_combined_w_class = 60
	max_items = 21

/obj/item/mod/module/storage/bluespace/get_ru_names()
	return list(
		NOMINATIVE = "модуль блюспейс-хранилища",
		GENITIVE = "модуля блюспейс-хранилища",
		DATIVE = "модулю блюспейс-хранилища",
		ACCUSATIVE = "модуль блюспейс-хранилища",
		INSTRUMENTAL = "модулем блюспейс-хранилища",
		PREPOSITIONAL = "модуле блюспейс-хранилища",
	)

//Internal
/obj/item/storage/backpack/modstorage
	name = "mod's storage"
	desc = "Either you tried to spawn a storage mod, or someone fucked up. Unless you are an admin that just tried to spawn something, issue report."
	var/obj/item/mod/module/storage/source

/obj/item/storage/backpack/modstorage/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/storage/backpack/modstorage/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/storage/backpack/modstorage/process()
	update_viewers()

/obj/item/storage/backpack/modstorage/update_viewers()
	for(var/mobs in mobs_viewing)
		var/mob/our_mob = mobs
		if(!QDELETED(our_mob) && our_mob.s_active == src && (our_mob in range(1, loc)) && (source.mod.loc == mobs || (our_mob in range(1, source.mod)))) //This ensures someone isn't taking it away from the mod unit
			continue
		hide_from(our_mob)

// MARK: Ion Jetpack
/// Ion Jetpack - Lets the user fly freely through space using battery charge.
/obj/item/mod/module/jetpack
	name = "MOD ion jetpack module"
	desc = "Модуль для МЭК, представляющий собой набор распределённых по всему костюму ионных двигателей, которые питаются от заряда костюма."
	icon_state = "jetpack"
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/jetpack)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_jetpack"
	overlay_state_active = "module_jetpack_on"
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// Do we stop the wearer from gliding in space.
	var/stabilizers = FALSE
	/// Callback to see if we can thrust the user.
	var/thrust_callback
	var/skip_trails = FALSE

/obj/item/mod/module/jetpack/get_ru_names()
	return list(
		NOMINATIVE = "модуль ионного джетпака",
		GENITIVE = "модуля ионного джетпака",
		DATIVE = "модулю ионного джетпака",
		ACCUSATIVE = "модуль ионного джетпака",
		INSTRUMENTAL = "модулем ионного джетпака",
		PREPOSITIONAL = "модуле ионного джетпака",
	)

/obj/item/mod/module/jetpack/Initialize(mapload)
	. = ..()
	thrust_callback = CALLBACK(src, PROC_REF(allow_thrust))
	configure_jetpack(stabilizers)

/obj/item/mod/module/jetpack/Destroy()
	thrust_callback = null
	return ..()

/**
 * configures/re-configures the jetpack component
 *
 * Arguments
 * stabilizers - Should this jetpack be stabalized
 * skip_trails - if `TRUE` skips ion trails visualization
 */
/obj/item/mod/module/jetpack/proc/configure_jetpack(stabilizers, skip_trails)
	if(!isnull(stabilizers))
		src.stabilizers = stabilizers
	if(!isnull(skip_trails))
		src.skip_trails = skip_trails

	AddComponent( \
		/datum/component/jetpack, \
		src.stabilizers, \
		COMSIG_MODULE_TRIGGERED, \
		COMSIG_MODULE_DEACTIVATED, \
		MOD_ABORT_USE, \
		thrust_callback, \
		/datum/effect_system/trail_follow/ion/grav_allowed, \
		src.skip_trails \
	)

/obj/item/mod/module/jetpack/get_configuration()
	. = ..()
	.["stabilizers"] = add_ui_configuration("Стабилизация", "bool", stabilizers)

/obj/item/mod/module/jetpack/configure_edit(key, value)
	switch(key)
		if("stabilizers")
			configure_jetpack(value)

/obj/item/mod/module/jetpack/proc/allow_thrust()
	if(!drain_power(use_energy_cost))
		return FALSE
	return TRUE

/obj/item/mod/module/jetpack/on_activation()
	. = ..()
	if(.)
		mod.jetpack_active = TRUE

/obj/item/mod/module/jetpack/on_deactivation(display_message, deleting)
	mod.jetpack_active = FALSE

// MARK: Adv. ion jetpack
/obj/item/mod/module/jetpack/advanced
	name = "MOD advanced ion jetpack module"
	desc = "Модуль для МЭК, представляющий собой набор распределённых по всему костюму \
			ионных двигателей, которые питаются от заряда костюма. Улучшенная модель, \
			использующая двигатели повышенной мощности."
	icon_state = "jetpack_advanced"
	overlay_state_inactive = "module_jetpackadv"
	overlay_state_active = "module_jetpackadv_on"
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.25
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.5
	origin_tech = "materials=4;magnets=4;engineering=5" //To replace the old hardsuit upgrade jetpack levels.

/obj/item/mod/module/jetpack/advanced/get_ru_names()
	return list(
		NOMINATIVE = "модуль продвинутого джетпака",
		GENITIVE = "модуля продвинутого джетпака",
		DATIVE = "модулю продвинутого джетпака",
		ACCUSATIVE = "модуль продвинутого джетпака",
		INSTRUMENTAL = "модулем продвинутого джетпака",
		PREPOSITIONAL = "модуле продвинутого джетпака",
	)

// MARK: EMP shield
/// EMP Shield - Protects the suit from EMPs.
/obj/item/mod/module/emp_shield
	name = "MOD EMP shield module"
	desc = "Модуль для МЭК, являющийся подавителем электромагнитных полей. Будучи установленным в костюм, защищает его модули и \
			электронику от воздействия ЭМИ, постоянно потребляя заряд костюма."
	icon_state = "empshield"
	origin_tech = "materials=6;bluespace=5;syndicate=2"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/emp_shield, /obj/item/mod/module/dna_lock)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)

/obj/item/mod/module/emp_shield/get_ru_names()
	return list(
		NOMINATIVE = "модуль защиты от ЭМИ",
		GENITIVE = "модуля защиты от ЭМИ",
		DATIVE = "модулю защиты от ЭМИ",
		ACCUSATIVE = "модуль защиты от ЭМИ",
		INSTRUMENTAL = "модулем защиты от ЭМИ",
		PREPOSITIONAL = "модуле защиты от ЭМИ",
	)

/obj/item/mod/module/emp_shield/on_install()
	. = ..()
	mod.emp_proof = TRUE

/obj/item/mod/module/emp_shield/on_uninstall(deleting = FALSE)
	. = ..()
	mod.emp_proof = FALSE

// MARK: Flashlight
/// Flashlight - Gives the suit a customizable flashlight.
/obj/item/mod/module/flashlight
	name = "MOD flashlight module"
	desc = "Модуль для МЭК, представляющий собой пару фонариков, устанавливаемых по бокам шлема. \
			Обладает возможностью настройки цвета. Полезно для освещения пространства в настраиваемом диапазоне."
	icon_state = "flashlight"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/flashlight, /obj/item/mod/module/flashlight/darkness)
	overlay_state_inactive = "module_light"
	overlay_state_active = "module_light_on"
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_on = FALSE
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	/// Charge drain per range amount.
	var/base_power = DEFAULT_CHARGE_DRAIN * 0.1
	/// Minimum range we can set.
	var/min_range = 2
	/// Maximum range we can set.
	var/max_range = 5

/obj/item/mod/module/flashlight/get_ru_names()
	return list(
		NOMINATIVE = "модуль фонарика",
		GENITIVE = "модуля фонарика",
		DATIVE = "модулю фонарика",
		ACCUSATIVE = "модуль фонарика",
		INSTRUMENTAL = "модулем фонарика",
		PREPOSITIONAL = "модуле фонарика",
	)

/obj/item/mod/module/flashlight/on_activation()
	set_light_flags(light_flags | LIGHT_ATTACHED)
	set_light_on(TRUE)
	active_power_cost = base_power * light_range

/obj/item/mod/module/flashlight/extinguish_light(force)
	on_deactivation()

/obj/item/mod/module/flashlight/on_deactivation(display_message = TRUE, deleting = FALSE)
	set_light_flags(light_flags & ~LIGHT_ATTACHED)
	set_light_on(FALSE)

/obj/item/mod/module/flashlight/on_process(seconds_per_tick)
	active_power_cost = base_power * light_range
	return ..()

/obj/item/mod/module/flashlight/get_configuration()
	. = ..()
	.["light_color"] = add_ui_configuration("Цвет фонаря", "color", light_color)
	.["light_range"] = add_ui_configuration("Дальность освещения", "number", light_range)

/obj/item/mod/module/flashlight/configure_edit(key, value)
	switch(key)
		if("light_color")
			value = tgui_input_color(usr, "Выберите цвет фонаря", "Цвет фонаря")
			if(!value)
				return
			if(is_color_dark(value, 50))
				to_chat(mod.wearer, span_warning("Нельзя выбрать слишком тёмный цвет!"))
				return
			set_light_color(value)
			update_clothing_slots()
		if("light_range")
			set_light_range(clamp(value, min_range, max_range))

// MARK: Dark flashlight
/// Like the flashlight module, except the light color is stuck to black and cannot be changed.
/obj/item/mod/module/flashlight/darkness
	name = "MOD flashdark module"
	desc = "Модуль для МЭК, представляющий собой пару темнариков, устанавливаемых по бокам шлема. \
			Полезно для затемнения пространства в настраиваемом радиусе."
	light_color = COLOR_BLACK
	light_system = MOVABLE_LIGHT
	light_range = 2
	min_range = 1
	max_range = 3

/obj/item/mod/module/flashlight/darkness/get_ru_names()
	return list(
		NOMINATIVE = "модуль темнарика",
		GENITIVE = "модуля темнарика",
		DATIVE = "модулю темнарика",
		ACCUSATIVE = "модуль темнарика",
		INSTRUMENTAL = "модулем темнарика",
		PREPOSITIONAL = "модуле темнарика",
	)

/obj/item/mod/module/flashlight/darkness/get_configuration()
	. = ..()
	. -= "light_color"

// MARK: Dispenser
/// Dispenser - Dispenses an item after a time passes.
/obj/item/mod/module/dispenser
	name = "MOD burger dispenser module"
	desc = "Модуль для МЭК. Чрезвычайно редкая технология, потенциально дающая возможность производить любую съедобную органическую \
			материю, потребляя для этого огромное количество энергии костюма. По какой-то причине исследования возможностей производства \
			остановились на создании чизбургеров."
	icon_state = "dispenser"
	module_type = MODULE_USABLE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/dispenser)
	required_slots = list(ITEM_SLOT_GLOVES)
	cooldown_time = 5 SECONDS
	/// Path we dispense.
	var/dispense_type = /obj/item/reagent_containers/food/snacks/cheeseburger
	/// Time it takes for us to dispense.
	var/dispense_time = 0 SECONDS

/obj/item/mod/module/dispenser/get_ru_names()
	return list(
		NOMINATIVE = "модуль раздатчика бургеров",
		GENITIVE = "модуля раздатчика бургеров",
		DATIVE = "модулю раздатчика бургеров",
		ACCUSATIVE = "модуль раздатчика бургеров",
		INSTRUMENTAL = "модулем раздатчика бургеров",
		PREPOSITIONAL = "модуле раздатчика бургеров",
	)

/obj/item/mod/module/dispenser/on_use()
	if(dispense_time && !do_after(mod.wearer, dispense_time, target = mod.wearer))
		return FALSE
	var/obj/item/dispensed = new dispense_type(mod.wearer.loc)
	mod.wearer.put_in_hands(dispensed)
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)
	drain_power(use_energy_cost)
	return dispensed

// MARK: Thermal Regulator
/// Thermal Regulator - Regulates the wearer's core temperature.
/obj/item/mod/module/thermal_regulator
	name = "MOD thermal regulator module"
	desc = "Модуль для МЭК, обеспечивающий продвинутый климат-контроль костюма с помощью сети из тысяч нанотрубок, \
			по которым циркулирует охлаждающая жидкость. Поддерживает настройку целевой температуры."
	icon_state = "regulator"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/thermal_regulator)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	cooldown_time = 0.5 SECONDS
	/// The temperature we are regulating to.
	var/temperature_setting = BODYTEMP_NORMAL
	/// Minimum temperature we can set.
	var/min_temp = 293.15
	/// Maximum temperature we can set.
	var/max_temp = 318.15

/obj/item/mod/module/thermal_regulator/get_ru_names()
	return list(
		NOMINATIVE = "модуль регуляции температуры",
		GENITIVE = "модуля регуляции температуры",
		DATIVE = "модулю регуляции температуры",
		ACCUSATIVE = "модуль регуляции температуры",
		INSTRUMENTAL = "модулем регуляции температуры",
		PREPOSITIONAL = "модуле регуляции температуры",
	)

/obj/item/mod/module/thermal_regulator/get_configuration()
	. = ..()
	.["temperature_setting"] = add_ui_configuration("Температура", "number", temperature_setting - T0C)

/obj/item/mod/module/thermal_regulator/configure_edit(key, value)
	switch(key)
		if("temperature_setting")
			temperature_setting = clamp(text2num(value) + T0C, min_temp, max_temp)

/obj/item/mod/module/thermal_regulator/on_active_process()
	if(mod.wearer.bodytemperature > temperature_setting)
		mod.wearer.bodytemperature = max(temperature_setting, mod.wearer.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(mod.wearer.bodytemperature < temperature_setting)
		mod.wearer.bodytemperature = min(temperature_setting, mod.wearer.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))

// MARK: DNA lock
/obj/item/mod/module/dna_lock
	name = "MOD DNA lock module"
	desc = "Модуль для МЭК, интегрированный в систему герметизации и электронику костюма. \
			Ограничивает использование МЭК только авторизованным пользователем по ДНК-профилю."
	icon_state = "dnalock"
	origin_tech = "materials=6;bluespace=5;syndicate=1"
	module_type = MODULE_USABLE
	complexity = 2
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/dna_lock, /obj/item/mod/module/emp_shield)
	cooldown_time = 0.5 SECONDS
	/// The DNA we lock with.
	var/dna = null

/obj/item/mod/module/dna_lock/get_ru_names()
	return list(
		NOMINATIVE = "модуль ДНК-блокировки",
		GENITIVE = "модуля ДНК-блокировки",
		DATIVE = "модулю ДНК-блокировки",
		ACCUSATIVE = "модуль ДНК-блокировки",
		INSTRUMENTAL = "модулем ДНК-блокировки",
		PREPOSITIONAL = "модуле ДНК-блокировки",
	)

/obj/item/mod/module/dna_lock/on_install()
	. = ..()
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(on_mod_activation))
	RegisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL, PROC_REF(on_mod_removal))
	RegisterSignal(mod, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))
	RegisterSignal(mod, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag))

/obj/item/mod/module/dna_lock/on_uninstall(deleting = FALSE)
	. = ..()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	UnregisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL)
	UnregisterSignal(mod, COMSIG_ATOM_EMP_ACT)
	UnregisterSignal(mod, COMSIG_ATOM_EMAG_ACT)

/obj/item/mod/module/dna_lock/on_use()
	dna = mod.wearer.dna.unique_enzymes
	balloon_alert(mod.wearer, "данные считаны")
	drain_power(use_energy_cost)

/obj/item/mod/module/dna_lock/emp_act(severity)
	. = ..()
	if(mod.emp_proof)
		return
	on_emp(src, severity)

/obj/item/mod/module/dna_lock/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	on_emag(src, user, emag_card)

/obj/item/mod/module/dna_lock/proc/dna_check(mob/user)
	if(!iscarbon(user))
		return FALSE
	if(!dna)
		return TRUE
	if(dna == mod.wearer.dna.unique_enzymes)
		return TRUE
	return FALSE

/obj/item/mod/module/dna_lock/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER

	dna = null

/obj/item/mod/module/dna_lock/proc/on_emag(datum/source, mob/user, obj/item/card/emag/emag_card)
	SIGNAL_HANDLER

	dna = null

/obj/item/mod/module/dna_lock/proc/on_mod_activation(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!dna_check(user))
		atom_say("ОШИБКА: ДНК пользователя не совпадает с ДНК владельца.")
		return MOD_CANCEL_ACTIVATE

/obj/item/mod/module/dna_lock/proc/on_mod_removal(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!dna_check(user))
		atom_say("ОШИБКА: ДНК пользователя не совпадает с ДНК владельца.")
		return MOD_CANCEL_REMOVAL

// MARK: EMP-proof DNA
/obj/item/mod/module/dna_lock/emp_shield
	name = "MOD DN-MP shield lock"
	desc = "Модуль для МЭК, интегрированный в систему герметизации и электронику костюма. \
			Ограничивает использование МЭК только авторизованным пользователем по ДНК-профилю. \
			Улучшенная модель, оборудованная ЭМИ-экранированием."
	origin_tech = "materials=6;bluespace=5;syndicate=3"
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5

/obj/item/mod/module/dna_lock/emp_shield/get_ru_names()
	return list(
		NOMINATIVE = "модуль ДНК-блокировки и защиты от ЭМИ",
		GENITIVE = "модуля ДНК-блокировки и защиты от ЭМИ",
		DATIVE = "модулю ДНК-блокировки и защиты от ЭМИ",
		ACCUSATIVE = "модуль ДНК-блокировки и защиты от ЭМИ",
		INSTRUMENTAL = "модулем ДНК-блокировки и защиты от ЭМИ",
		PREPOSITIONAL = "модуле ДНК-блокировки и защиты от ЭМИ",
	)

/obj/item/mod/module/dna_lock/emp_shield/on_install()
	. = ..()
	mod.emp_proof = TRUE

/obj/item/mod/module/dna_lock/emp_shield/on_uninstall(deleting = FALSE)
	. = ..()
	mod.emp_proof = FALSE

// MARK: Plasma stabilizer
/// Plasma Stabilizer - Prevents plasmamen from igniting in the suit
/obj/item/mod/module/plasma_stabilizer
	name = "MOD plasma stabilizer module"
	desc = "Модуль для МЭК, предназначенный для плазмолюдов. Формирует внутри костюма собственную атмосферу, предотвращающую \
			спонтанное самовозгорание пользователя при воздействии кислорода."
	icon_state = "plasma_stabilizer"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/plasma_stabilizer)
	overlay_state_inactive = "module_plasma"
	required_slots = list(ITEM_SLOT_HEAD)

/obj/item/mod/module/plasma_stabilizer/get_ru_names()
	return list(
		NOMINATIVE = "модуль стабилизации плазмы",
		GENITIVE = "модуля стабилизации плазмы",
		DATIVE = "модулю стабилизации плазмы",
		ACCUSATIVE = "модуль стабилизации плазмы",
		INSTRUMENTAL = "модулем стабилизации плазмы",
		PREPOSITIONAL = "модуле стабилизации плазмы",
	)

/obj/item/mod/module/plasma_stabilizer/on_equip()
	ADD_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION_HEAD_ONLY, MODSUIT_TRAIT)

/obj/item/mod/module/plasma_stabilizer/on_unequip()
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION_HEAD_ONLY, MODSUIT_TRAIT)

/// Cooldown to use if we didn't actually launch a jump jet
#define FAILED_ACTIVATION_COOLDOWN 3 SECONDS

// MARK: Jump jet
/// Jump Jet - Briefly removes the effect of gravity and pushes you up one z-level if possible.
/obj/item/mod/module/jump_jet
	name = "MOD ionic jump jet module"
	desc = "Модуль для МЭК, представляющий собой миниатюрные ионные двигатели, способные кратковременно поднять пользователя в воздух. \
			Оборудование для последующей посадки не предусмотрено в стандартной комплектации."
	icon_state = "jump_jet"
	module_type = MODULE_USABLE
	complexity = 1
	cooldown_time = 30 SECONDS
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/jump_jet)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)

/obj/item/mod/module/jump_jet/examine(mob/user)
	. = ..()
	. += span_notice("Данный модуль будет бесполезен там, где есть только один этаж.")

/obj/item/mod/module/jump_jet/get_ru_names()
	return list(
		NOMINATIVE = "модуль ионных двигателей",
		GENITIVE = "модуля ионных двигателей",
		DATIVE = "модулю ионных двигателей",
		ACCUSATIVE = "модуль ионных двигателей",
		INSTRUMENTAL = "модулем ионных двигателей",
		PREPOSITIONAL = "модуле ионных двигателей",
	)

/obj/item/mod/module/jump_jet/on_use()
	if(DOING_INTERACTION(mod.wearer, mod.wearer))
		balloon_alert(mod.wearer, "невозможно!")
		return
	balloon_alert(mod.wearer, "запуск...")
	mod.wearer.Shake(duration = 1 SECONDS)
	if(!do_after(mod.wearer, 1 SECONDS, target = mod.wearer))
		start_cooldown(FAILED_ACTIVATION_COOLDOWN) // Don't go on full cooldown if we failed to launch
		return FALSE
	playsound(mod.wearer, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
	mod.wearer.apply_status_effect(/datum/status_effect/jump_jet)
	var/turf/launch_from = get_turf(mod.wearer)
	if(mod.wearer.zMove(UP, z_move_flags = ZMOVE_CHECK_PULLS))
		launch_from.visible_message(span_warning("[mod.wearer] поднима[PLUR_ET_UT(mod.wearer)]ся вверх!"))
	new /obj/effect/temp_visual/jet_plume(launch_from)

	var/obj/item/mod/module/jetpack/linked_jetpack = locate() in mod.modules
	if(!isnull(linked_jetpack) && !linked_jetpack.active)
		linked_jetpack.on_activation()
	return TRUE

#undef FAILED_ACTIVATION_COOLDOWN

// MARK: Apparatus
/// Eating Apparatus - Lets the user eat/drink with the suit on.
/obj/item/mod/module/mouthhole
	name = "MOD eating apparatus module"
	desc = "Модуль для МЭК, формирующий селективный барьер на основе твёрдого света перед ртом пользователя. Позволяет принимать пищу и жидкость \
			без разгерметизации костюма. Не заменяет оборудование для дыхания и не блокирует аэрозольные частицы."
	icon_state = "apparatus"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/mouthhole)
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	/// Former flags of the helmet.
	var/former_helmet_flags = NONE
	/// Former visor flags of the helmet.
	var/former_visor_helmet_flags = NONE
	/// Former flags of the mask.
	var/former_mask_flags = NONE
	/// Former visor flags of the mask.
	var/former_visor_mask_flags = NONE

/obj/item/mod/module/mouthhole/get_ru_names()
	return list(
		NOMINATIVE = "модуль пищеприёмника",
		GENITIVE = "модуля пищеприёмника",
		DATIVE = "модулю пищеприёмника",
		ACCUSATIVE = "модуль пищеприёмника",
		INSTRUMENTAL = "модулем пищеприёмника",
		PREPOSITIONAL = "модуле пищеприёмника",
	)

/obj/item/mod/module/mouthhole/on_install()
	. = ..()
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(helmet))
		former_helmet_flags = helmet.flags_cover
		former_visor_helmet_flags = helmet.visor_flags_cover
		helmet.flags_cover &= ~(HEADCOVERSMOUTH)
		helmet.visor_flags_cover &= ~(HEADCOVERSMOUTH)
	var/obj/item/clothing/mask = mod.get_part_from_slot(ITEM_SLOT_MASK)
	if(!istype(mask))
		return
	former_mask_flags = mask.flags_cover
	former_visor_mask_flags = mask.visor_flags_cover
	mask.flags_cover &= ~(MASKCOVERSMOUTH)
	mask.visor_flags_cover &= ~(MASKCOVERSMOUTH)

/obj/item/mod/module/mouthhole/can_install(obj/item/mod/control/mod)
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	var/obj/item/clothing/mask = mod.get_part_from_slot(ITEM_SLOT_MASK)
	if(istype(helmet) && ((helmet.flags_cover|helmet.visor_flags_cover) & (HEADCOVERSMOUTH)))
		return ..()
	if(istype(mask) && ((mask.flags_cover|mask.visor_flags_cover) & (MASKCOVERSMOUTH)))
		return ..()
	return FALSE

/obj/item/mod/module/mouthhole/on_uninstall(deleting = FALSE)
	. = ..()
	if(deleting)
		return
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(helmet))
		helmet.flags_cover |= former_helmet_flags
		helmet.visor_flags_cover |= former_visor_helmet_flags
	var/obj/item/clothing/mask = mod.get_part_from_slot(ITEM_SLOT_MASK)
	if(!istype(mask))
		return
	mask.flags_cover |= former_mask_flags
	mask.visor_flags_cover |= former_visor_mask_flags

// MARK: Longfall
/// Longfall - Nullifies fall damage, removing charge instead.
/obj/item/mod/module/longfall
	name = "MOD longfall module"
	desc = "Модуль для МЭК, использующий сочетание амортизаторов и гироскопов с микрокомпьютером для обеспечения безопасного \
			для пользователя и костюма приземления."
	icon_state = "longfall"
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/longfall)
	required_slots = list(ITEM_SLOT_FEET)

/obj/item/mod/module/longfall/examine(mob/user)
	. = ..()
	. += span_notice("Данный модуль будет бесполезен там, где есть только один этаж.")

/obj/item/mod/module/longfall/get_ru_names()
	return list(
		NOMINATIVE = "модуль амортизации",
		GENITIVE = "модуля амортизации",
		DATIVE = "модулю амортизации",
		ACCUSATIVE = "модуль амортизации",
		INSTRUMENTAL = "модулем амортизации",
		PREPOSITIONAL = "модуле амортизации",
	)

/obj/item/mod/module/longfall/on_part_activation()
	..()
	RegisterSignal(mod.wearer, COMSIG_LIVING_Z_IMPACT, PROC_REF(z_impact_react))

/obj/item/mod/module/longfall/on_part_deactivation(deleting = FALSE)
	..()
	UnregisterSignal(mod.wearer, COMSIG_LIVING_Z_IMPACT)

/obj/item/mod/module/longfall/proc/z_impact_react(datum/source, levels, turf/fell_on)
	SIGNAL_HANDLER

	if(!drain_power(use_energy_cost * levels))
		return NONE
	new /obj/effect/temp_visual/mook_dust(fell_on)

	/// Boolean that tracks whether we fell more than one z-level. If TRUE, we stagger our wearer.
	var/extreme_fall = FALSE

	if(levels >= 2)
		extreme_fall = TRUE
		mod.wearer.Stun(clamp(3 SECONDS * levels, 0, 10 SECONDS))

	mod.wearer.visible_message(
		span_notice("[mod.wearer] без ущерба приземля[PLUR_ET_UT(mod.wearer)]ся на [fell_on.declent_ru(ACCUSATIVE)] [extreme_fall ? ", едва устояв на ногах" : ", даже не шелохнувшись"]."),
		span_notice("[capitalize(declent_ru(NOMINATIVE))] защища[PLUR_ET_UT(src)] вас от ущерба при падении!"),
	)
	return ZIMPACT_CANCEL_DAMAGE|ZIMPACT_NO_MESSAGE|ZIMPACT_NO_SPIN

// MARK: Joint torsion
/// A module that recharges the suit by an itsy tiny bit whenever the user takes a step. Originally called "magneto module" but the videogame reference sounds cooler.
/obj/item/mod/module/joint_torsion
	name = "MOD joint torsion ratchet module"
	desc = "Модуль для МЭК, генерирующий при ходьбе слабый переменный ток, заряжающий батарею костюма. По очевидным причинам не работает в невесомости."
	icon_state = "joint_torsion"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/joint_torsion)
	required_slots = list(ITEM_SLOT_FEET)
	var/power_per_step = DEFAULT_CHARGE_DRAIN * 0.3

/obj/item/mod/module/joint_torsion/get_ru_names()
	return list(
		NOMINATIVE = "модуль кинетической зарядки",
		GENITIVE = "модуля кинетической зарядки",
		DATIVE = "модулю кинетической зарядки",
		ACCUSATIVE = "модуль кинетической зарядки",
		INSTRUMENTAL = "модулем кинетической зарядки",
		PREPOSITIONAL = "модуле кинетической зарядки",
	)

/obj/item/mod/module/joint_torsion/on_part_activation()
	..()
	if(!(mod.wearer.movement_type & (FLOATING|FLYING)))
		RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	/// This way we don't even bother to call on_moved() while flying/floating
	RegisterSignal(mod.wearer, COMSIG_MOVETYPE_FLAG_ENABLED, PROC_REF(on_movetype_flag_enabled))
	RegisterSignal(mod.wearer, COMSIG_MOVETYPE_FLAG_DISABLED, PROC_REF(on_movetype_flag_disabled))

/obj/item/mod/module/joint_torsion/on_part_deactivation(deleting = FALSE)
	..()
	UnregisterSignal(mod.wearer, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVETYPE_FLAG_ENABLED, COMSIG_MOVETYPE_FLAG_DISABLED))

/obj/item/mod/module/joint_torsion/proc/on_movetype_flag_enabled(datum/source, flag, old_state)
	SIGNAL_HANDLER

	if(!(old_state & (FLOATING|FLYING)) && flag & (FLOATING|FLYING))
		UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)

/obj/item/mod/module/joint_torsion/proc/on_movetype_flag_disabled(datum/source, flag, old_state)
	SIGNAL_HANDLER

	if(old_state & (FLOATING|FLYING) && !(mod.wearer.movement_type & (FLOATING|FLYING)))
		RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/obj/item/mod/module/joint_torsion/proc/on_moved(mob/living/carbon/human/wearer, atom/old_loc, movement_dir, forced)
	SIGNAL_HANDLER

	//Shouldn't work if the wearer isn't really walking/running around.
	if(forced || wearer.throwing || wearer.body_position == LYING_DOWN || wearer.buckled || CHECK_MOVE_LOOP_FLAGS(wearer, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	mod.core.add_charge(power_per_step)

// MARK: Shock absorber
/obj/item/mod/module/shock_absorber
	name = "MOD shock absorption module"
	desc = "Модуль для МЭК, делающий пользователя невосприимчивым к воздействию оглушающих дубинок \
			за счёт поглощения шокового импульса."
	icon_state = "no_baton"
	complexity = 1
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/shock_absorber)

/obj/item/mod/module/shock_absorber/get_ru_names()
	return list(
		NOMINATIVE = "модуль шокопоглощения",
		GENITIVE = "модуля шокопоглощения",
		DATIVE = "модулю шокопоглощения",
		ACCUSATIVE = "модуль шокопоглощения",
		INSTRUMENTAL = "модулем шокопоглощения",
		PREPOSITIONAL = "модуле шокопоглощения",
	)

/obj/item/mod/module/shock_absorber/on_part_activation()
	. = ..()
	ADD_TRAIT(mod.wearer, TRAIT_BATON_RESISTANCE, UNIQUE_TRAIT_SOURCE(src))
	RegisterSignal(mod.wearer, COMSIG_MOB_BATONED, PROC_REF(mob_batoned))

/obj/item/mod/module/shock_absorber/on_part_deactivation(deleting)
	. = ..()
	REMOVE_TRAIT(mod.wearer, TRAIT_BATON_RESISTANCE, UNIQUE_TRAIT_SOURCE(src))
	UnregisterSignal(mod.wearer, COMSIG_MOB_BATONED)

/obj/item/mod/module/shock_absorber/proc/mob_batoned(datum/source)
	SIGNAL_HANDLER

	drain_power(use_energy_cost)
	do_sparks(5, TRUE, mod.wearer.loc)

// MARK: Hearing protection
/obj/item/mod/module/hearing_protection
	name = "MOD hearing protection module"
	desc = "Модуль для МЭК, защищающий органы слуха пользователя от воздействия громких звуков."
	incompatible_modules = list(/obj/item/mod/module/hearing_protection)
	required_slots = list(ITEM_SLOT_HEAD)

/obj/item/mod/module/hearing_protection/get_ru_names()
	return list(
		NOMINATIVE = "модуль акустической защиты",
		GENITIVE = "модуля акустической защиты",
		DATIVE = "модулю акустической защиты",
		ACCUSATIVE = "модуль акустической защиты",
		INSTRUMENTAL = "модулем акустической защиты",
		PREPOSITIONAL = "модуле акустической защиты",
	)

/obj/item/mod/module/hearing_protection/on_part_activation()
	..()
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		head_cover.item_flags |= BANGPROTECT_TOTAL

/obj/item/mod/module/hearing_protection/on_part_deactivation(deleting = FALSE)
	..()
	if(deleting)
		return
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		head_cover.item_flags &= ~BANGPROTECT_TOTAL

// MARK: Hat stabilizer

///Allows displaying a hat over the MOD-helmet, à la plasmamen helmets.
/obj/item/mod/module/hat_stabilizer
	name = "MOD hat stabilizer module"
	desc = "Модуль для МЭК, представляющий собой небольшой набор креплений на шлеме костюма, \
			позволяющий дополнительную установку головного убора поверх шлема. \
			Вам всё еще необходимо снять шляпу перед тем, как активировать костюм. \
			Данный модуль обязателен к установке на все МЭК класса \"Магнат\"."
	icon_state = "hat_holder"
	incompatible_modules = list(/obj/item/mod/module/hat_stabilizer)
	required_slots = list(ITEM_SLOT_HEAD)
	complexity = 1
	/// Original cover flags for the MOD helmet, before a hat is placed
	var/former_flags
	var/former_visor_flags

/obj/item/mod/module/hat_stabilizer/get_ru_names()
	return list(
		NOMINATIVE = "модуль стабилизатора шляп",
		GENITIVE = "модуля стабилизатора шляп",
		DATIVE = "модулю стабилизатора шляп",
		ACCUSATIVE = "модуль стабилизатора шляп",
		INSTRUMENTAL = "модулем стабилизатора шляп",
		PREPOSITIONAL = "модуле стабилизатора шляп",
	)

/obj/item/mod/module/hat_stabilizer/on_part_activation()
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(!istype(helmet))
		return
	// Override pre-existing component
	helmet.AddComponent(/datum/component/hat_stabilizer, loose_hat = FALSE)

/obj/item/mod/module/hat_stabilizer/on_part_deactivation(deleting = FALSE)
	if(deleting)
		return
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(!istype(helmet))
		return
	// Override again!
	helmet.AddComponent(/datum/component/hat_stabilizer, loose_hat = TRUE)

/obj/item/mod/module/hat_stabilizer/syndicate
	name = "MOD elite hat stabilizer module"
	desc = "Модуль для МЭК, представляющий собой небольшой набор креплений на шлеме костюма, \
			позволяющий дополнительную установку головного убора поверх шлема. \
			Вам всё еще необходимо снять шляпу перед тем, как активировать костюм. \
			По умолчанию устанавливается на все МЭК, используемые Синдикатом."
	complexity = 0
	removable = FALSE

/obj/item/mod/module/hat_stabilizer/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "модуль стабилизатора шляп Синдиката",
		GENITIVE = "модуля стабилизатора шляп Синдиката",
		DATIVE = "модулю стабилизатора шляп Синдиката",
		ACCUSATIVE = "модуль стабилизатора шляп Синдиката",
		INSTRUMENTAL = "модулем стабилизатора шляп Синдиката",
		PREPOSITIONAL = "модуле стабилизатора шляп Синдиката",
	)

// MARK: MOD upgrades
//
/obj/item/mod/module/activation_upgrade
	name = "MOD upgraded actuator module"
	desc = "Модуль для МЭК, представляющий из себя набор продвинутых актуаторов из пластали, предназначенных для увеличения \
			скорости развёртывания МЭК. Продвинутая версия пружинного модуля, лишенная недостатков оригинальной версии."
	icon_state = "magnet"
	complexity = 3
	incompatible_modules = list(/obj/item/mod/module/springlock, /obj/item/mod/module/activation_upgrade)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// How much faster will your suit deploy?
	var/activation_step_time_booster = 2

/obj/item/mod/module/activation_upgrade/get_ru_names()
	return list(
		NOMINATIVE = "модуль улучшенных актуаторов",
		GENITIVE = "модуля улучшенных актуаторов",
		DATIVE = "модулю улучшенных актуаторов",
		ACCUSATIVE = "модуль улучшенных актуаторов",
		INSTRUMENTAL = "модулем улучшенных актуаторов",
		PREPOSITIONAL = "модуле улучшенных актуаторов",
	)

/obj/item/mod/module/activation_upgrade/on_install()
	. = ..()
	mod.activation_step_time *= (1 / activation_step_time_booster) //1 second for standart; 0,5 for pilot; 0,4 for elite

/obj/item/mod/module/activation_upgrade/on_uninstall(deleting = FALSE)
	. = ..()
	mod.activation_step_time *= activation_step_time_booster

/obj/item/mod/module/activation_upgrade/advanced
	name = "MOD advanced actuator module"
	desc = "Модуль для МЭК, представляющий из себя набор продвинутых актуаторов из пластали, предназначенных для увеличения \
			скорости развёртывания МЭК. Улучшенный вариант, который тяжело достать на гражданском рынке."
	activation_step_time_booster = 3
	complexity = 0
	removable = FALSE

/obj/item/mod/module/activation_upgrade/advanced/get_ru_names()
	return list(
		NOMINATIVE = "модуль продвинутых актуаторов",
		GENITIVE = "модуля продвинутых актуаторов",
		DATIVE = "модулю продвинутых актуаторов",
		ACCUSATIVE = "модуль продвинутых актуаторов",
		INSTRUMENTAL = "модулем продвинутых актуаторов",
		PREPOSITIONAL = "модуле продвинутых актуаторов",
	)

/obj/item/mod/module/activation_upgrade/elite
	name = "MOD elite actuator module"
	desc = "Модуль для МЭК, представляющий из себя набор продвинутых актуаторов из пластитана, предназначенных для увеличения \
			скорости развёртывания МЭК. Данная модель еще официально не вышла на рынок."
	icon_state = "magnet_contractor"
	activation_step_time_booster = 4

/obj/item/mod/module/activation_upgrade/elite/get_ru_names()
	return list(
		NOMINATIVE = "модуль элитных актуаторов",
		GENITIVE = "модуля элитных актуаторов",
		DATIVE = "модулю элитных актуаторов",
		ACCUSATIVE = "модуль элитных актуаторов",
		INSTRUMENTAL = "модулем элитных актуаторов",
		PREPOSITIONAL = "модуле элитных актуаторов",
	)

/obj/item/mod/module/deployed_upgrade
	name = "MOD upgraded servos module"
	desc = "Модуль для МЭК, представляющий из себя набор улучшенных сервоприводов, предназначенных для увеличения скорости МЭКа \
			в активном состоянии. Для некоторых устаревших моделей костюмов замена сервоприводов это базовая необходимость."
	icon_state = "microwave_beam"
	complexity = 3
	incompatible_modules = list(/obj/item/mod/module/deployed_upgrade)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 5 //free speed, after all
	/// How much do we upgrade our speed?
	var/speed_booster = 2
	var/original_speed_cached

/obj/item/mod/module/deployed_upgrade/get_ru_names()
	return list(
		NOMINATIVE = "модуль улучшенных сервоприводов",
		GENITIVE = "модуля  улучшенных сервоприводов",
		DATIVE = "модулю  улучшенных сервоприводов",
		ACCUSATIVE = "модуль  улучшенных сервоприводов",
		INSTRUMENTAL = "модулем  улучшенных сервоприводов",
		PREPOSITIONAL = "модуле  улучшенных сервоприводов",
	)

/obj/item/mod/module/deployed_upgrade/on_install()
	. = ..()
	original_speed_cached = mod.slowdown_deployed
	mod.slowdown_deployed /= speed_booster

/obj/item/mod/module/deployed_upgrade/on_uninstall(deleting = FALSE)
	. = ..()
	mod.slowdown_deployed = original_speed_cached
