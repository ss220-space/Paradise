// Engineering modules for MODsuits

// MARK: Welding shield
/// Welding Protection - Makes the helmet protect from flashes and welding.
/obj/item/mod/module/welding
	name = "MOD welding protection module"
	desc = "Модуль для МЭК, устанавливаемый в визор. Обеспечивает фильтрацию избыточного оптического излучения, позволяя \
			без опасений смотреть на вспышки сварки разных видов, солнечные затмения, а также карманные фонарики."
	icon_state = "welding"
	complexity = 1
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	incompatible_modules = list(/obj/item/mod/module/welding)
	overlay_state_inactive = "module_welding"

/obj/item/mod/module/welding/get_ru_names()
	return list(
		NOMINATIVE = "модуль защиты от сварки",
		GENITIVE = "модуля защиты от сварки",
		DATIVE = "модулю защиты от сварки",
		ACCUSATIVE = "модуль защиты от сварки",
		INSTRUMENTAL = "модулем защиты от сварки",
		PREPOSITIONAL = "модуле защиты от сварки",
	)

/obj/item/mod/module/welding/on_part_activation()
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		// this is a screen that displays an image, so flash sensitives can use this to protect against flashes.
		head_cover.flash_protect = FLASH_PROTECTION_WELDER

/obj/item/mod/module/welding/on_part_deactivation(deleting = FALSE)
	if(deleting)
		return
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		head_cover.flash_protect = initial(head_cover.flash_protect)

/obj/item/mod/module/welding/syndie
	name = "MOD flash protection module"
	desc = "Модуль для МЭК, устанавливаемый в визор. Продвинутая матрица обеспечивает автоматическую фильтрацию любого мощного оптического излучения, \
			полностью защищая пользователя от ярких вспышек любого рода."
	icon_state = "welding_syndie"
	complexity = 0
	removable = FALSE
	overlay_state_inactive = "module_welding_syndie"

/obj/item/mod/module/welding/syndie/get_ru_names()
	return list(
		NOMINATIVE = "модуль защиты от вспышек",
		GENITIVE = "модуля защиты от вспышек",
		DATIVE = "модулю защиты от вспышек",
		ACCUSATIVE = "модуль защиты от вспышек",
		INSTRUMENTAL = "модулем защиты от вспышек",
		PREPOSITIONAL = "модуле защиты от вспышек",
	)

// MARK: T-ray scanner
/// T-Ray Scan - Scans the terrain for undertile objects.
/obj/item/mod/module/t_ray
	name = "MOD t-ray scan module"
	desc = "Модуль для МЭК, устанавливаемый в визор. Использует терагерцевое излучение для \
			эхолокации и последующего отображения технических объектов, скрытых под полом — \
			мусорных и атмосферных труб, кабелей, терминалов ЛКП и других."
	icon_state = "tray"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/t_ray)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// T-ray scan range.
	var/range = 4

/obj/item/mod/module/t_ray/get_ru_names()
	return list(
		NOMINATIVE = "модуль ТГц сканирования",
		GENITIVE = "модуля ТГц сканирования",
		DATIVE = "модулю ТГц сканирования",
		ACCUSATIVE = "модуль ТГц сканирования",
		INSTRUMENTAL = "модулем ТГц сканирования",
		PREPOSITIONAL = "модуле ТГц сканирования",
	)

/obj/item/mod/module/t_ray/on_active_process()
	t_ray_scan(mod.wearer, 0.8 SECONDS, range)

// MARK: Magboots
/// Magnetic Stability - Gives the user a slowdown but makes them negate gravity and be immune to slips.
/obj/item/mod/module/magboot
	name = "MOD magnetic stability module"
	desc = "Модуль для МЭК, являющийся встраиваемым аналогом магнитных ботинок. Обеспечивает активное сцепление \
			и предотвращает скольжение на влажных, обледенелых или загрязнённых поверхностях. \
			Функционирует в условиях нулевой гравитации."
	icon_state = "magnet"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	required_slots = list(ITEM_SLOT_FEET)
	incompatible_modules = list(/obj/item/mod/module/magboot)
	cooldown_time = 0.5 SECONDS
	/// Slowdown added onto the suit.
	var/slowdown_active = 0.5
	/// list of all traits, that added to magboots
	var/list/active_traits = list(
		TRAIT_NO_SLIP_WATER,
		TRAIT_NO_SLIP_ICE,
		TRAIT_NO_SLIP_SLIDE,
		TRAIT_NEGATES_GRAVITY,
	)

/obj/item/mod/module/magboot/get_ru_names()
	return list(
		NOMINATIVE = "модуль магбутсов",
		GENITIVE = "модуля магбутсов",
		DATIVE = "модулю магбутсов",
		ACCUSATIVE = "модуль магбутсов",
		INSTRUMENTAL = "модулем магбутсов",
		PREPOSITIONAL = "модуле магбутсов",
	)

/obj/item/mod/module/magboot/on_install()
	. = ..()
	RegisterSignal(mod, COMSIG_MOD_UPDATE_SPEED, PROC_REF(on_update_speed))

/obj/item/mod/module/magboot/on_uninstall(deleting = FALSE)
	. = ..()
	UnregisterSignal(mod, COMSIG_MOD_UPDATE_SPEED)

/obj/item/mod/module/magboot/on_activation()
	mod.wearer.add_traits(active_traits, UNIQUE_TRAIT_SOURCE(src))
	mod.update_speed()

/obj/item/mod/module/magboot/on_deactivation(display_message = TRUE, deleting = FALSE)
	mod.wearer.remove_traits(active_traits, UNIQUE_TRAIT_SOURCE(src))
	mod.update_speed()

/obj/item/mod/module/magboot/proc/on_update_speed(datum/source, list/module_slowdowns)
	SIGNAL_HANDLER
	if(active)
		module_slowdowns += slowdown_active

// MARK: Atmos magboots
/obj/item/mod/module/magboot/atmos
	name = "MOD atmos magnetic stability module"
	desc = "Модуль для МЭК, являющийся встраиваемым аналогом магнитных ботинок. Обеспечивает активное сцепление \
			и предотвращает скольжение на влажных, обледенелых или загрязнённых поверхностях. \
			Функционирует в условиях нулевой гравитации. Благодаря дополнительному усилению сцепления \
			позволяет безопасно работать с атмосферными трубами с высоким давлением."
	active_traits = list(
		TRAIT_NO_SLIP_WATER,
		TRAIT_NO_SLIP_ICE,
		TRAIT_NO_SLIP_SLIDE,
		TRAIT_GUSTPROTECTION,
		TRAIT_NEGATES_GRAVITY,
	)

/obj/item/mod/module/magboot/atmos/get_ru_names()
	return list(
		NOMINATIVE = "модуль атмосферных магбутсов",
		GENITIVE = "модуля атмосферных магбутсов",
		DATIVE = "модулю атмосферных магбутсов",
		ACCUSATIVE = "модуль атмосферных магбутсов",
		INSTRUMENTAL = "модулем атмосферных магбутсов",
		PREPOSITIONAL = "модуле атмосферных магбутсов",
	)

// MARK: Adv. magboots
/obj/item/mod/module/magboot/advanced
	name = "MOD advanced magnetic stability module"
	desc = "Модуль для МЭК, являющийся встраиваемым аналогом магнитных ботинок. Обеспечивает активное сцепление \
			и предотвращает скольжение на влажных, обледенелых или загрязнённых поверхностях. \
			Функционирует в условиях нулевой гравитации. Оснащён системой активного контроля сцепления, \
			что позволяет не замедлять пользователя при передвижении."
	slowdown_active = 0
	active_traits = list(
		TRAIT_NO_SLIP_WATER,
		TRAIT_NO_SLIP_ICE,
		TRAIT_NO_SLIP_SLIDE,
		TRAIT_NEGATES_GRAVITY,
		TRAIT_GUSTPROTECTION,
	)

/obj/item/mod/module/magboot/advanced/get_ru_names()
	return list(
		NOMINATIVE = "модуль продвинутых магбутсов",
		GENITIVE = "модуля продвинутых магбутсов",
		DATIVE = "модулю продвинутых магбутсов",
		ACCUSATIVE = "модуль продвинутых магбутсов",
		INSTRUMENTAL = "модулем продвинутых магбутсов",
		PREPOSITIONAL = "модуле продвинутых магбутсов",
	)

// MARK: Elite magboots
/obj/item/mod/module/magboot/advanced/elite
	name = "MOD elite magnetic stability module"
	desc = "Модуль для МЭК, являющийся встраиваемым аналогом магнитных ботинок. Обеспечивает активное сцепление \
			и предотвращает скольжение на любых поверхностях. Оснащён системой активного контроля сцепления, \
			что позволяет не замедлять пользователя при передвижении."
	complexity = 0
	removable = FALSE
	active_traits = list(
		TRAIT_NO_SLIP_ALL,
		TRAIT_NO_SLIP_SLIDE,
		TRAIT_NEGATES_GRAVITY,
		TRAIT_GUSTPROTECTION,
	)

/obj/item/mod/module/magboot/advanced/elite/get_ru_names()
	return list(
		NOMINATIVE = "модуль элитных магбутсов",
		GENITIVE = "модуля элитных магбутсов",
		DATIVE = "модулю элитных магбутсов",
		ACCUSATIVE = "модуль элитных магбутсов",
		INSTRUMENTAL = "модулем элитных магбутсов",
		PREPOSITIONAL = "модуле элитных магбутсов",
	)

// MARK: Rad. detector
/// Radiation detector (should be Radiation Protection one day...) - Gives the user rad info in the ui, currently (absolutely useless)
/obj/item/mod/module/rad_protection
	name = "MOD radiation detector module"
	desc = "Модуль для МЭК с датчиками обнаружения и измерения радиоактивного загрязнения пользователя. \
			Из-за бюрократических проволочек при проектировке и дефицита свинца на Лазисе модуль не имеет \
			встроенного счётчика Гейгера и не предоставляет никакой защиты от радиации."
	icon_state = "radshield"
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.1 //Lowered from 0.3 due to no protection.
	incompatible_modules = list(/obj/item/mod/module/rad_protection)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	tgui_id = "rad_counter"
	/// Radiation threat level being perceived.
	var/perceived_threat_level

/obj/item/mod/module/rad_protection/get_ru_names()
	return list(
		NOMINATIVE = "модуль радиационного сканирования",
		GENITIVE = "модуля радиационного сканирования",
		DATIVE = "модулю радиационного сканирования",
		ACCUSATIVE = "модуль радиационного сканирования",
		INSTRUMENTAL = "модулем радиационного сканирования",
		PREPOSITIONAL = "модуле радиационного сканирования",
	)

/obj/item/mod/module/rad_protection/on_part_activation()
	AddComponent(/datum/component/geiger_sound)
	ADD_TRAIT(mod.wearer, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK, UID())
	RegisterSignal(mod.wearer, COMSIG_IN_RANGE_OF_IRRADIATION, PROC_REF(on_pre_potential_irradiation))
	for(var/obj/item/part in mod.get_parts(all = TRUE))
		ADD_TRAIT(part, TRAIT_RADIATION_PROTECTED_CLOTHING, MODSUIT_TRAIT)

/obj/item/mod/module/rad_protection/on_part_deactivation(deleting = FALSE)
	qdel(GetComponent(/datum/component/geiger_sound))
	REMOVE_TRAIT(mod.wearer, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK, UID())
	UnregisterSignal(mod.wearer, COMSIG_IN_RANGE_OF_IRRADIATION)
	for(var/obj/item/part in mod.get_parts(all = TRUE))
		REMOVE_TRAIT(part, TRAIT_RADIATION_PROTECTED_CLOTHING, MODSUIT_TRAIT)

/obj/item/mod/module/rad_protection/add_ui_data()
	. = ..()
	.["is_user_irradiated"] = mod.wearer ? HAS_TRAIT(mod.wearer, TRAIT_IRRADIATED) : FALSE
	.["background_radiation_level"] = perceived_threat_level
	.["health_max"] = mod.wearer?.getMaxHealth() || 0
	.["loss_tox"] = mod.wearer?.getToxLoss() || 0

/obj/item/mod/module/rad_protection/proc/on_pre_potential_irradiation(datum/source, datum/radiation_pulse_information/pulse_information, insulation_to_target)
	SIGNAL_HANDLER

	perceived_threat_level = get_perceived_radiation_danger(pulse_information, insulation_to_target)
	addtimer(VARSET_CALLBACK(src, perceived_threat_level, null), TIME_WITHOUT_RADIATION_BEFORE_RESET, TIMER_UNIQUE | TIMER_OVERRIDE)

// MARK: Grappling hook
/// Emergency Tether - Shoots a grappling hook projectile in 0g that throws the user towards it.
/obj/item/mod/module/grappling_hook
	name = "MOD grappling hook module"
	desc = "Модуль для МЭК, встраиваемый в предплечье костюма. Позволяет выстрелить крюк-кошкой на лебёдке с встроенным мотором. \
			Конструкционные ограничения не позволяют использовать его вне среды с нулевой гравитацией."
	icon_state = "tether"
	module_type = MODULE_ACTIVE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/grappling_hook)
	required_slots = list(ITEM_SLOT_GLOVES)
	cooldown_time = 4 SECONDS
	var/upgraded = FALSE

/obj/item/mod/module/grappling_hook/get_ru_names()
	return list(
		NOMINATIVE = "модуль крюк-кошки",
		GENITIVE = "модуля крюк-кошки",
		DATIVE = "модулю крюк-кошки",
		ACCUSATIVE = "модуль крюк-кошки",
		INSTRUMENTAL = "модулем крюк-кошки",
		PREPOSITIONAL = "модуле крюк-кошки",
	)

/obj/item/mod/module/grappling_hook/used()
	if(get_gravity(get_turf(src)) && !upgraded)
		balloon_alert(mod.wearer, "нельзя использовать!")
		playsound(src, 'sound/weapons/gun_interactions/dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mod/module/grappling_hook/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/projectile/tether = new /obj/projectile/tether(get_turf(mod.wearer))
	tether.original = target
	tether.firer = mod.wearer
	tether.preparePixelProjectile(target, mod.wearer)
	tether.fire()
	playsound(src, 'sound/weapons/batonextend.ogg', 25, TRUE)
	INVOKE_ASYNC(tether, TYPE_PROC_REF(/obj/projectile/tether, make_chain))
	drain_power(use_energy_cost)

/obj/projectile/tether
	name = "tether"
	icon_state = "tether_projectile"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	speed = 2
	damage = 15
	range = 20
	hitsound = 'sound/weapons/batonextend.ogg'
	hitsound_wall = 'sound/weapons/batonextend.ogg'
	ricochet_chance = 0

/obj/projectile/tether/proc/make_chain()
	if(!firer)
		return
	chain = Beam(firer, icon_state = "line", icon = 'icons/obj/clothing/modsuit/mod_modules.dmi', time = 10 SECONDS, maxdistance = 15)

/obj/projectile/tether/on_hit(atom/target)
	. = ..()
	if(!firer || !isliving(firer))
		return
	var/mob/living/living_firer = firer
	living_firer.apply_status_effect(STATUS_EFFECT_IMPACT_IMMUNE)
	living_firer.throw_at(target, 15, 1, living_firer, FALSE, FALSE, callback = CALLBACK(living_firer, TYPE_PROC_REF(/mob/living, remove_status_effect), STATUS_EFFECT_IMPACT_IMMUNE))

/obj/projectile/tether/Destroy()
	QDEL_NULL(chain)
	return ..()

/obj/item/mod/module/grappling_hook/upgraded
	name = "MOD upgraded grappling hook module"
	desc = "Модуль для МЭК, встраиваемый в предплечье костюма. Позволяет выстрелить крюк-кошкой на лебёдке с встроенным мотором. \
	Улучшенные тросы позволяют использовать модуль на в среде с гравитацией."
	complexity = 2
	upgraded = TRUE

/obj/item/mod/module/grappling_hook/upgraded/get_ru_names()
	return list(
		NOMINATIVE = "модуль улучшенной крюк-кошки",
		GENITIVE = "модуля улучшенной крюк-кошки",
		DATIVE = "модулю улучшенной крюк-кошки",
		ACCUSATIVE = "модуль улучшенной крюк-кошки",
		INSTRUMENTAL = "модулем улучшенной крюк-кошки",
		PREPOSITIONAL = "модуле улучшенной крюк-кошки",
	)

// MARK: Atmos watertank
/// Atmos water tank module
/obj/item/mod/module/firefighting_tank
	name = "MOD firefighting tank"
	desc = "Модуль для МЭК, предоставляющий в пользование носителю огнетушитель с баком охлаждённой сжатой воды. Предназначен \
			для тушения пожаров. Переключается между стандартным огнетушителем, распылителем металлической пены и режимом \"Нанофрост\", \
			в котором огнетушитель стреляет снарядами, превращающими горящую в атмосфере плазму в азот."
	icon_state = "firefighting_tank"
	module_type = MODULE_ACTIVE
	complexity = 2
	required_slots = list(ITEM_SLOT_GLOVES)
	active_power_cost = DEFAULT_CHARGE_DRAIN * 3
	device = /obj/item/extinguisher/mini/mod

/obj/item/mod/module/firefighting_tank/get_ru_names()
	return list(
		NOMINATIVE = "модуль пожаротушения",
		GENITIVE = "модуля пожаротушения",
		DATIVE = "модулю пожаротушения",
		ACCUSATIVE = "модуль пожаротушения",
		INSTRUMENTAL = "модулем пожаротушения",
		PREPOSITIONAL = "модуле пожаротушения",
	)

#define EXTINGUISHER 0
#define NANOFROST 1
#define METAL_FOAM 2

/obj/item/extinguisher/mini/mod
	name = "modsuit extinguisher nozzle"
	desc = "Сверхмощная распыляющая насадка, подсоединяемая к внутреннему хранилищу МЭК."
	icon = 'icons/obj/watertank.dmi'
	icon_state = "atmos_nozzle_1"
	item_state = "nozzleatmos"
	safety = 0
	max_water = 500
	precision = 1
	cooling_power = 5
	w_class = WEIGHT_CLASS_HUGE
	var/nozzle_mode = EXTINGUISHER
	var/metal_synthesis_charge = 5
	COOLDOWN_DECLARE(nanofrost_cooldown)

/obj/item/extinguisher/mini/mod/get_ru_names()
	return list(
		NOMINATIVE = "огнетушитель МЭК",
		GENITIVE = "огнетушителя МЭК",
		DATIVE = "огнетушителю МЭК",
		ACCUSATIVE = "огнетушитель МЭК",
		INSTRUMENTAL = "огнетушителем МЭК",
		PREPOSITIONAL = "огнетушителе МЭК",
	)

/obj/item/extinguisher/mini/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, MODSUIT_TRAIT) // Necessary to ensure that the nozzle and tank never seperate

/obj/item/extinguisher/mini/mod/attack_self(mob/user)
	switch(nozzle_mode)
		if(EXTINGUISHER)
			nozzle_mode = NANOFROST
			balloon_alert(user, "режим \"нанофрост\"")
		if(NANOFROST)
			nozzle_mode = METAL_FOAM
			balloon_alert(user, "режим \"металлическая пена\"")
		if(METAL_FOAM)
			nozzle_mode = EXTINGUISHER
			balloon_alert(user, "режим \"огнетушитель\"")
	update_icon(UPDATE_ICON_STATE)

/obj/item/extinguisher/mini/mod/update_icon_state()
	switch(nozzle_mode)
		if(EXTINGUISHER)
			icon_state = "atmos_nozzle_1"
		if(NANOFROST)
			icon_state = "atmos_nozzle_2"
		if(METAL_FOAM)
			icon_state = "atmos_nozzle_3"

/obj/item/extinguisher/mini/mod/examine(mob/user)
	. = ..()
	switch(nozzle_mode)
		if(EXTINGUISHER)
			. += span_notice("Выбранный режим — <b>огнетушитель</b>.")
		if(NANOFROST)
			. += span_notice("Выбранный режим — <b>\"Нанофрост\"</b>.")
		if(METAL_FOAM)
			. += span_notice("Выбранный режим — <b>распылитель металлической пены</b>.")

/obj/item/extinguisher/mini/mod/afterattack(atom/target, mob/user)
	var/is_adjacent = user.Adjacent(target)
	if(is_adjacent && AttemptRefill(target, user))
		return
	switch(nozzle_mode)
		if(EXTINGUISHER)
			..()

		if(NANOFROST)
			if(reagents.total_volume < 100)
				balloon_alert(user, "мало воды!")
				return
			if(!COOLDOWN_FINISHED(src, nanofrost_cooldown))
				balloon_alert(user, "на перезарядке!")
				return
			COOLDOWN_START(src, nanofrost_cooldown, 10 SECONDS)
			reagents.remove_any(100)
			var/obj/effect/nanofrost_container/nanofrost = new /obj/effect/nanofrost_container(get_turf(src))
			log_game("[key_name(user)] used Nanofrost at [get_area(user)] ([user.x], [user.y], [user.z]).")
			playsound(src, 'sound/items/syringeproj.ogg', 40, 1)
			move_nanofrost(nanofrost, target)

		if(METAL_FOAM)
			if(!is_adjacent|| !isturf(target))
				return
			if(metal_synthesis_charge <= 0)
				balloon_alert(user, "в процессе синтеза!")
				return
			if(reagents.total_volume < 10)
				balloon_alert(user, "мало воды!")
				return
			var/datum/effect_system/fluid_spread/foam/metal/metal_foam = new()
			metal_foam.set_up(amount = 0, location = get_turf(target))
			metal_foam.start()
			reagents.remove_any(10)
			metal_synthesis_charge--
			addtimer(CALLBACK(src, PROC_REF(regenerate_metal_charge)), 5 SECONDS)

/obj/item/extinguisher/mini/mod/proc/regenerate_metal_charge()
	metal_synthesis_charge++

/obj/item/extinguisher/mini/mod/proc/move_nanofrost(obj/effect/nanofrost_container/our_nanofrost, atom/target, steps_left = 5)
	if(!our_nanofrost || !target)
		return
	if(steps_left <= 0) //no more steps
		our_nanofrost.Smoke()
		return

	step_towards(our_nanofrost, target)
	addtimer(CALLBACK(src, PROC_REF(move_nanofrost), our_nanofrost, target, steps_left - 1), 2)

#undef EXTINGUISHER
#undef NANOFROST
#undef METAL_FOAM

