//General modules for MODsuits

///Storage - Adds a storage component to the suit.
/obj/item/mod/module/storage
	name = "MOD storage module"
	desc = "What amounts to a series of integrated storage compartments and specialized pockets installed across \
		the surface of the suit, useful for storing various bits, and or bobs."
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
		NOMINATIVE = "модуль вместимости для МЭК",
		GENITIVE = "модуля вместимости для МЭК",
		DATIVE = "модулю вместимости для МЭК",
		ACCUSATIVE = "модуль вместимости для МЭК",
		INSTRUMENTAL = "модулем вместимости для МЭК",
		PREPOSITIONAL = "модуле вместимости для МЭК",
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
		for(var/obj/I in bag.contents)
			I.forceMove(get_turf(loc))
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

/obj/item/mod/module/storage/large_capacity
	name = "MOD expanded storage module"
	desc = "Reverse engineered by Cybersun Industries from Donk Corporation designs, this system of hidden compartments \
		is entirely within the suit, distributing items and weight evenly to ensure a comfortable experience for the user; \
		whether smuggling, or simply hauling."
	icon_state = "storage_large"
	max_combined_w_class = 21
	max_items = 14

/obj/item/mod/module/storage/large_capacity/get_ru_names()
	return list(
		NOMINATIVE = "модуль повышенной вместимости для МЭК",
		GENITIVE = "модуля повышенной вместимости для МЭК",
		DATIVE = "модулю повышенной вместимости для МЭК",
		ACCUSATIVE = "модуль повышенной вместимости для МЭК",
		INSTRUMENTAL = "модулем повышенной вместимости для МЭК",
		PREPOSITIONAL = "модуле повышенной вместимости для МЭК",
	)

/obj/item/mod/module/storage/syndicate
	name = "MOD syndicate storage module"
	desc = "A storage system using nanotechnology developed by Donk Corporation, these compartments use \
		esoteric technology to compress the physical matter of items put inside of them, \
		essentially shrinking items for much easier and more portable storage."
	icon_state = "storage_syndi"
	max_combined_w_class = 30
	max_items = 21
	origin_tech = "materials=6;bluespace=5;syndicate=2"

/obj/item/mod/module/storage/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "модуль вместимости синдиката для МЭК",
		GENITIVE = "модуля вместимости синдиката для МЭК",
		DATIVE = "модулю вместимости синдиката для МЭК",
		ACCUSATIVE = "модуль вместимости синдиката для МЭК",
		INSTRUMENTAL = "модулем вместимости синдиката для МЭК",
		PREPOSITIONAL = "модуле вместимости синдиката для МЭК",
	)

/obj/item/mod/module/storage/belt
	name = "MOD case storage module"
	desc = "Some concessions had to be made when creating a compressed modular suit core. \
	As a result, Roseus Galactic equipped their suit with a slimline storage case. \
	If you find this equipped to a standard modular suit, then someone has almost certainly shortchanged you on a proper storage module."
	icon_state = "storage_case"
	complexity = 0
	max_w_class = WEIGHT_CLASS_SMALL
	removable = FALSE
	max_combined_w_class = 21
	max_items = 7

/obj/item/mod/module/storage/belt/get_ru_names()
	return list(
		NOMINATIVE = "модуль пониженной вместимости для МЭК",
		GENITIVE = "модуля пониженной вместимости для МЭК",
		DATIVE = "модулю пониженной вместимости для МЭК",
		ACCUSATIVE = "модуль пониженной вместимости для МЭК",
		INSTRUMENTAL = "модулем пониженной вместимости для МЭК",
		PREPOSITIONAL = "модуле пониженной вместимости для МЭК",
	)

/obj/item/mod/module/storage/bluespace
	name = "MOD bluespace storage module"
	desc = "A storage system developed by Nanotrasen, these compartments employ \
		miniaturized bluespace pockets for the ultimate in storage technology; regardless of the weight of objects put inside."
	icon_state = "storage_bluespace"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_combined_w_class = 60
	max_items = 21

/obj/item/mod/module/storage/bluespace/get_ru_names()
	return list(
		NOMINATIVE = "модуль блюспейс-хранилища для МЭК",
		GENITIVE = "модуля блюспейс-хранилища для МЭК",
		DATIVE = "модулю блюспейс-хранилища для МЭК",
		ACCUSATIVE = "модуль блюспейс-хранилища для МЭК",
		INSTRUMENTAL = "модулем блюспейс-хранилища для МЭК",
		PREPOSITIONAL = "модуле блюспейс-хранилища для МЭК",
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
	for(var/_M in mobs_viewing)
		var/mob/M = _M
		if(!QDELETED(M) && M.s_active == src && (M in range(1, loc)) && (source.mod.loc == _M || (M in range(1, source.mod)))) //This ensures someone isn't taking it away from the mod unit
			continue
		hide_from(M)


///Ion Jetpack - Lets the user fly freely through space using battery charge.
/obj/item/mod/module/jetpack
	name = "MOD ion jetpack module"
	desc = "A series of electric thrusters installed across the suit, this is a module highly anticipated by trainee Engineers. \
		Rather than using gasses for combustion thrust, these jets are capable of accelerating ions using \
		charge from the suit's charge. Some say this isn't Cybersun Industries's first foray into jet-enabled suits."
	icon_state = "jetpack"
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/jetpack)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_jetpack"
	overlay_state_active = "module_jetpack_on"
	required_slots = list(ITEM_SLOT_BACK)
	/// Do we stop the wearer from gliding in space.
	var/stabilizers = FALSE
	/// Callback to see if we can thrust the user.
	var/thrust_callback
	var/skip_trails = FALSE

/obj/item/mod/module/jetpack/get_ru_names()
	return list(
		NOMINATIVE = "модуль ионного джетпака для МЭК",
		GENITIVE = "модуля ионного джетпака для МЭК",
		DATIVE = "модулю ионного джетпака для МЭК",
		ACCUSATIVE = "модуль ионного джетпака для МЭК",
		INSTRUMENTAL = "модулем ионного джетпака для МЭК",
		PREPOSITIONAL = "модуле ионного джетпака для МЭК",
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
			configure_jetpack(text2bool(value))

/obj/item/mod/module/jetpack/proc/allow_thrust()
	if(!drain_power(use_energy_cost))
		return FALSE
	return TRUE

/obj/item/mod/module/jetpack/on_activation()
	. = ..()
	if(.)
		mod.jetpack_active = TRUE

/obj/item/mod/module/jetpack/on_deactivation(display_message, deleting)
	. = ..()
	if(.)
		mod.jetpack_active = FALSE

/obj/item/mod/module/jetpack/advanced
	name = "MOD advanced ion jetpack module"
	desc = "An improvement on the previous model of electric thrusters. This one achieves better efficency through \
		mounting of more jets and a red paint applied on it."
	icon_state = "jetpack_advanced"
	overlay_state_inactive = "module_jetpackadv"
	overlay_state_active = "module_jetpackadv_on"
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.25
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.5
	origin_tech = "materials=4;magnets=4;engineering=5" //To replace the old hardsuit upgrade jetpack levels.

/obj/item/mod/module/jetpack/advanced/get_ru_names()
	return list(
		NOMINATIVE = "модуль продвинутого ионного джетпака для МЭК",
		GENITIVE = "модуля продвинутого ионного джетпака для МЭК",
		DATIVE = "модулю продвинутого ионного джетпака для МЭК",
		ACCUSATIVE = "модуль продвинутого ионного джетпака для МЭК",
		INSTRUMENTAL = "модулем продвинутого ионного джетпака для МЭК",
		PREPOSITIONAL = "модуле продвинутого ионного джетпака для МЭК",
	)

///EMP Shield - Protects the suit from EMPs.
/obj/item/mod/module/emp_shield
	name = "MOD EMP shield module"
	desc = "A field inhibitor installed into the suit, protecting it against feedback such as \
		electromagnetic pulses that would otherwise damage the electronic systems of the suit or it's modules. \
		However, it will take from the suit's power to do so."
	icon_state = "empshield"
	origin_tech = "materials=6;bluespace=5;syndicate=2"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/emp_shield, /obj/item/mod/module/dna_lock)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)

/obj/item/mod/module/emp_shield/get_ru_names()
	return list(
		NOMINATIVE = "модуль защиты от ЭМИ для МЭК",
		GENITIVE = "модуля защиты от ЭМИ для МЭК",
		DATIVE = "модулю защиты от ЭМИ для МЭК",
		ACCUSATIVE = "модуль защиты от ЭМИ для МЭК",
		INSTRUMENTAL = "модулем защиты от ЭМИ для МЭК",
		PREPOSITIONAL = "модуле защиты от ЭМИ для МЭК",
	)

/obj/item/mod/module/emp_shield/on_install()
	. = ..()
	mod.emp_proof = TRUE

/obj/item/mod/module/emp_shield/on_uninstall(deleting = FALSE)
	. = ..()
	mod.emp_proof = FALSE

///Flashlight - Gives the suit a customizable flashlight.
/obj/item/mod/module/flashlight
	name = "MOD flashlight module"
	desc = "A simple pair of configurable flashlights installed on the left and right sides of the helmet, \
		useful for providing light in a variety of ranges and colors. \
		Some survivalists prefer the color green for their illumination, for reasons unknown."
	icon_state = "flashlight"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/flashlight, /obj/item/mod/module/flashlight/darkness)
	overlay_state_inactive = "module_light"
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_color = COLOR_WHITE
	light_range = 4
	light_power = 1
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
		NOMINATIVE = "модуль фонарика для МЭК",
		GENITIVE = "модуля фонарика для МЭК",
		DATIVE = "модулю фонарика для МЭК",
		ACCUSATIVE = "модуль фонарика для МЭК",
		INSTRUMENTAL = "модулем фонарика для МЭК",
		PREPOSITIONAL = "модуле фонарика для МЭК",
	)

/obj/item/mod/module/flashlight/on_activation()
	. = ..()
	if(!.)
		return

	set_light_flags(light_flags | LIGHT_ATTACHED)
	set_light_on(TRUE)
	active_power_cost = base_power * light_range

/obj/item/mod/module/flashlight/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	set_light_flags(light_flags & ~LIGHT_ATTACHED)
	set_light_on(FALSE)

/obj/item/mod/module/flashlight/on_process(seconds_per_tick)
	active_power_cost = base_power * light_range
	return ..()

/obj/item/mod/module/flashlight/get_configuration()
	. = ..()
	.["light_color"] = add_ui_configuration("Light Color", "color", light_color)
	.["light_range"] = add_ui_configuration("Light Range", "number", light_range)

/obj/item/mod/module/flashlight/configure_edit(key, value)
	switch(key)
		if("light_color")
			value = input(usr, "Pick new light color", "Flashlight Color") as color|null
			if(!value)
				return
			if(is_color_dark(value, 50))
				balloon_alert(mod.wearer, "too dark!")
				return
			set_light_color(value)
			update_clothing_slots()
		if("light_range")
			set_light_range(clamp(value, min_range, max_range))

///Like the flashlight module, except the light color is stuck to black and cannot be changed.
/obj/item/mod/module/flashlight/darkness
	name = "MOD flashdark module"
	desc = "A quirky pair of configurable flashdarks installed on the sides of the helmet, \
		useful for providing darkness at a configurable range."
	light_color = COLOR_BLACK
	light_system = MOVABLE_LIGHT
	light_range = 2
	min_range = 1
	max_range = 3

/obj/item/mod/module/flashlight/darkness/get_configuration()
	. = ..()
	. -= "light_color"

///Dispenser - Dispenses an item after a time passes.
/obj/item/mod/module/dispenser
	name = "MOD burger dispenser module"
	desc = "A rare piece of technology reverse-engineered from a prototype found in a Donk Corporation vessel. \
		This can draw incredible amounts of power from the suit's charge to create edible organic matter in the \
		palm of the wearer's glove; however, research seemed to have entirely stopped at cheeseburgers. \
		Notably, all attempts to get it to dispense Earl Grey tea have failed."
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
		NOMINATIVE = "модуль раздатчика бургеров для МЭК",
		GENITIVE = "модуля раздатчика бургеров для МЭК",
		DATIVE = "модулю раздатчика бургеров для МЭК",
		ACCUSATIVE = "модуль раздатчика бургеров для МЭК",
		INSTRUMENTAL = "модулем раздатчика бургеров для МЭК",
		PREPOSITIONAL = "модуле раздатчика бургеров для МЭК",
	)

/obj/item/mod/module/dispenser/on_use()
	. = ..()
	if(!.)
		return
	if(dispense_time && !do_after(mod.wearer, dispense_time, target = mod.wearer))
		return FALSE
	var/obj/item/dispensed = new dispense_type(mod.wearer.loc)
	mod.wearer.put_in_hands(dispensed)
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)
	drain_power(use_energy_cost)
	return dispensed

///Thermal Regulator - Regulates the wearer's core temperature.
/obj/item/mod/module/thermal_regulator
	name = "MOD thermal regulator module"
	desc = "Advanced climate control, using an inner body glove interwoven with thousands of tiny, \
		flexible cooling lines. This circulates coolant at various user-controlled temperatures, \
		ensuring they're comfortable; even if they're some that like it hot."
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
		NOMINATIVE = "модуль температурного регулятора для МЭК",
		GENITIVE = "модуля температурного регулятора для МЭК",
		DATIVE = "модулю температурного регулятора для МЭК",
		ACCUSATIVE = "модуль температурного регулятора для МЭК",
		INSTRUMENTAL = "модулем температурного регулятора для МЭК",
		PREPOSITIONAL = "модуле ртемпературного регулятора для МЭК",
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

/obj/item/mod/module/dna_lock
	name = "MOD DNA lock module"
	desc = "A module which engages with the various locks and seals tied to the suit's systems, \
		enabling it to only be worn by someone corresponding with the user's exact DNA profile; \
		however, this incredibly sensitive module is shorted out by EMPs. Luckily, stable mutagen has been outlawed."
	icon_state = "dnalock"
	origin_tech = "materials=6;bluespace=5;syndicate=1"
	module_type = MODULE_USABLE
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/dna_lock, /obj/item/mod/module/emp_shield)
	cooldown_time = 0.5 SECONDS
	/// The DNA we lock with.
	var/dna = null

/obj/item/mod/module/dna_lock/get_ru_names()
	return list(
		NOMINATIVE = "модуль ДНК-блокировки для МЭК",
		GENITIVE = "модуля ДНК-блокировки для МЭК",
		DATIVE = "модулю ДНК-блокировки для МЭК",
		ACCUSATIVE = "модуль ДНК-блокировки для МЭК",
		INSTRUMENTAL = "модулем ДНК-блокировки для МЭК",
		PREPOSITIONAL = "модуле ДНК-блокировки для МЭК",
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
	. = ..()
	if(!.)
		return
	dna = mod.wearer.dna.unique_enzymes
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

/obj/item/mod/module/dna_lock/emp_shield
	name = "MOD DN-MP shield lock"
	desc = "This syndicate module is a combination EMP shield and DNA lock. Provides the best of both worlds, with the weakness of niether."
	icon_state = "dnalock"
	origin_tech = "materials=6;bluespace=5;syndicate=3"
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5

/obj/item/mod/module/dna_lock/emp_shield/get_ru_names()
	return list(
		NOMINATIVE = "модуль ДНК-блокировки и защиты от ЭМИ для МЭК",
		GENITIVE = "модуля ДНК-блокировки и защиты от ЭМИ для МЭК",
		DATIVE = "модулю ДНК-блокировки и защиты от ЭМИ для МЭК",
		ACCUSATIVE = "модуль ДНК-блокировки и защиты от ЭМИ для МЭК",
		INSTRUMENTAL = "модулем ДНК-блокировки и защиты от ЭМИ для МЭК",
		PREPOSITIONAL = "модуле ДНК-блокировки и защиты от ЭМИ для МЭК",
	)

/obj/item/mod/module/dna_lock/emp_shield/on_install()
	. = ..()
	mod.emp_proof = TRUE

/obj/item/mod/module/dna_lock/emp_shield/on_uninstall(deleting = FALSE)
	. = ..()
	mod.emp_proof = FALSE

///Plasma Stabilizer - Prevents plasmamen from igniting in the suit
/obj/item/mod/module/plasma_stabilizer
	name = "MOD plasma stabilizer module"
	desc = "This system essentially forms an atmosphere of its own, within the suit, \
		efficiently and quickly preventing oxygen from causing the user's head to burst into flame. \
		This allows plasmamen to safely remove their helmet, allowing for easier \
		equipping of any MODsuit-related equipment, or otherwise. \
		The purple glass of the visor seems to be constructed for nostalgic purposes."
	icon_state = "plasma_stabilizer"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/plasma_stabilizer)
	overlay_state_inactive = "module_plasma"
	required_slots = list(ITEM_SLOT_HEAD)

/obj/item/mod/module/plasma_stabilizer/get_ru_names()
	return list(
		NOMINATIVE = "модуль стабилизации плазмы для МЭК",
		GENITIVE = "модуля стабилизации плазмы для МЭК",
		DATIVE = "модулю стабилизации плазмы для МЭК",
		ACCUSATIVE = "модуль стабилизации плазмы для МЭК",
		INSTRUMENTAL = "модулем стабилизации плазмы для МЭК",
		PREPOSITIONAL = "модуле стабилизации плазмы для МЭК",
	)

/obj/item/mod/module/plasma_stabilizer/on_equip()
	ADD_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION_HEAD_ONLY, MODSUIT_TRAIT)

/obj/item/mod/module/plasma_stabilizer/on_unequip()
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION_HEAD_ONLY, MODSUIT_TRAIT)

/// Cooldown to use if we didn't actually launch a jump jet
#define FAILED_ACTIVATION_COOLDOWN 3 SECONDS

///Jump Jet - Briefly removes the effect of gravity and pushes you up one z-level if possible.
/obj/item/mod/module/jump_jet
	name = "MOD ionic jump jet module"
	desc = "A specialised ionic thruster which provides a short but powerful boost capable of pushing against gravity, \
		after which time it needs to recharge."
	icon_state = "jump_jet"
	module_type = MODULE_USABLE
	complexity = 3
	cooldown_time = 30 SECONDS
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/jump_jet)
	required_slots = list(ITEM_SLOT_BACK)

/obj/item/mod/module/jump_jet/on_use()
	if (DOING_INTERACTION(mod.wearer, mod.wearer))
		balloon_alert(mod.wearer, "busy!")
		return
	balloon_alert(mod.wearer, "launching...")
	mod.wearer.Shake(duration = 1 SECONDS)
	if (!do_after(mod.wearer, 1 SECONDS, target = mod.wearer))
		start_cooldown(FAILED_ACTIVATION_COOLDOWN) // Don't go on full cooldown if we failed to launch
		return FALSE
	playsound(mod.wearer, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
	mod.wearer.apply_status_effect(/datum/status_effect/jump_jet)
	var/turf/launch_from = get_turf(mod.wearer)
	if (mod.wearer.zMove(UP, z_move_flags = ZMOVE_CHECK_PULLS))
		launch_from.visible_message(span_warning("[mod.wearer] rockets into the air!"))
	new /obj/effect/temp_visual/jet_plume(launch_from)

	var/obj/item/mod/module/jetpack/linked_jetpack = locate() in mod.modules
	if (!isnull(linked_jetpack) && !linked_jetpack.active)
		linked_jetpack.on_activation()
	return TRUE

#undef FAILED_ACTIVATION_COOLDOWN

///Eating Apparatus - Lets the user eat/drink with the suit on.
/obj/item/mod/module/mouthhole
	name = "MOD eating apparatus module"
	desc = "A favorite by Miners, this modification to the helmet utilizes a nanotechnology barrier infront of the mouth \
		to allow eating and drinking while retaining protection and atmosphere. However, it won't free you from masks, \
		lets pepper spray pass through and it will do nothing to improve the taste of a goliath steak."
	icon_state = "apparatus"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/mouthhole)
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	/// Former flags of the helmet.
	var/former_helmet_flags = NONE
	/// Former flags of the mask.
	var/former_mask_flags = NONE

/obj/item/mod/module/mouthhole/on_install()
	. = ..()
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(helmet))
		former_helmet_flags = helmet.flags_cover
		helmet.flags_cover &= ~HEADCOVERSMOUTH
	var/obj/item/clothing/mask = mod.get_part_from_slot(ITEM_SLOT_MASK)
	if(istype(mask))
		former_mask_flags = mask.flags_cover
		mask.flags_cover &= ~MASKCOVERSMOUTH

/obj/item/mod/module/mouthhole/can_install(obj/item/mod/control/mod)
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	var/obj/item/clothing/mask = mod.get_part_from_slot(ITEM_SLOT_MASK)
	if(istype(helmet) && (helmet.flags_cover & HEADCOVERSMOUTH))
		return ..()
	if(istype(mask) && (mask.flags_cover & MASKCOVERSMOUTH))
		return ..()
	return FALSE

/obj/item/mod/module/mouthhole/on_uninstall(deleting = FALSE)
	. = ..()
	if(deleting)
		return
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(helmet))
		helmet.flags_cover |= former_helmet_flags
	var/obj/item/clothing/mask = mod.get_part_from_slot(ITEM_SLOT_MASK)
	if(istype(mask))
		mask.flags_cover |= former_mask_flags

///Longfall - Nullifies fall damage, removing charge instead.
/obj/item/mod/module/longfall
	name = "MOD longfall module"
	desc = "Useful for protecting both the suit and the wearer, \
		utilizing commonplace systems to convert the possible damage from a fall into kinetic charge, \
		as well as internal gyroscopes to ensure the user's safe falling. \
		Useful for mining, monorail tracks, or even skydiving!"
	icon_state = "longfall"
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/longfall)
	required_slots = list(ITEM_SLOT_FEET)

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
		span_notice("[mod.wearer] lands on [fell_on] safely[extreme_fall ? ", but barely manages to stay on [p_their()] feet." : ", and quite stylishly on [p_their()] feet" ]."),
		span_notice("[src] protects you from the damage!"),
	)
	return ZIMPACT_CANCEL_DAMAGE|ZIMPACT_NO_MESSAGE|ZIMPACT_NO_SPIN

///A module that recharges the suit by an itsy tiny bit whenever the user takes a step. Originally called "magneto module" but the videogame reference sounds cooler.
/obj/item/mod/module/joint_torsion
	name = "MOD joint torsion ratchet module"
	desc = "A compact, weak AC generator that charges the suit's internal cell through the power of deambulation. It doesn't work in zero G."
	icon_state = "joint_torsion"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/joint_torsion)
	required_slots = list(ITEM_SLOT_FEET)
	var/power_per_step = DEFAULT_CHARGE_DRAIN * 0.3

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

/obj/item/mod/module/shock_absorber
	name = "MOD shock absorption module"
	desc = "A module that makes the user resistant to the knockdown inflicted by Stun Batons."
	icon_state = "no_baton"
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/shock_absorber)

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

/obj/item/mod/module/hearing_protection
	name = "MOD hearing protection module"
	desc = "A module that protects the users ears from loud sounds"
	complexity = 0
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/hearing_protection)
	required_slots = list(ITEM_SLOT_HEAD)

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
