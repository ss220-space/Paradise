//Medical modules for MODsuits

#define HEALTH_SCAN "Состояние здоровья"
#define CHEM_SCAN "Химикаты"

// MARK: Health analyzer
/// Health Analyzer - Gives the user a ranged health analyzer and their health status in the panel.
/obj/item/mod/module/health_analyzer
	name = "MOD health analyzer module"
	desc = "Модуль для МЭК, встраиваемый в перчатку костюма. Позволяет лёгким движением руки получить детальную информацию \
			о состоянии здоровья субъекта даже на расстоянии."
	icon_state = "health"
	module_type = MODULE_ACTIVE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/health_analyzer)
	cooldown_time = 0.5 SECONDS
	tgui_id = "health_analyzer"
	required_slots = list(ITEM_SLOT_GLOVES)
	/// Scanning mode, changes how we scan something.
	var/mode = HEALTH_SCAN

	/// List of all scanning modes.
	var/static/list/modes = list(HEALTH_SCAN, CHEM_SCAN)

/obj/item/mod/module/health_analyzer/get_ru_names()
	return list(
		NOMINATIVE = "модуль анализатора здоровья",
		GENITIVE = "модуля анализатора здоровья",
		DATIVE = "модулю анализатора здоровья",
		ACCUSATIVE = "модуль анализатора здоровья",
		INSTRUMENTAL = "модулем анализатора здоровья",
		PREPOSITIONAL = "модуле анализатора здоровья",
	)

/obj/item/mod/module/health_analyzer/add_ui_data()
	. = ..()
	.["health"] = mod.wearer?.health || 0
	.["health_max"] = mod.wearer?.getMaxHealth() || 0
	.["loss_brute"] = mod.wearer?.getBruteLoss() || 0
	.["loss_fire"] = mod.wearer?.getFireLoss() || 0
	.["loss_tox"] = mod.wearer?.getToxLoss() || 0
	.["loss_oxy"] = mod.wearer?.getOxyLoss() || 0

	return .

/obj/item/mod/module/health_analyzer/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!isliving(target) || is_monkeybasic(mod.wearer))
		return
	switch(mode)
		if(HEALTH_SCAN)
			healthscan(mod.wearer, target)
		if(CHEM_SCAN)
			chemscan(mod.wearer, target)
	drain_power(use_energy_cost)

/obj/item/mod/module/health_analyzer/get_configuration()
	. = ..()
	.["mode"] = add_ui_configuration("Режим сканирования", "list", mode, modes)

/obj/item/mod/module/health_analyzer/configure_edit(key, value)
	switch(key)
		if("mode")
			mode = value

#undef HEALTH_SCAN
#undef CHEM_SCAN

// MARK: Quick carry
/// Quick Carry - Lets the user carry bodies quicker.
/obj/item/mod/module/quick_carry
	name = "MOD quick carry module"
	desc = "Модуль для МЭК, являющийся набором продвинутых сервоприводов, устанавливаемых в руки костюма. \
			Облегчает перенос тел гуманоидов. Используется спасателями и медицинским персоналом."
	icon_state = "carry"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/quick_carry) //TODO MODSUIT: add /obj/item/mod/module/constructor
	required_slots = list(ITEM_SLOT_GLOVES)
	var/quick_carry_trait = TRAIT_QUICK_CARRY

/obj/item/mod/module/quick_carry/get_ru_names()
	return list(
		NOMINATIVE = "модуль сильного хвата",
		GENITIVE = "модуля сильного хвата",
		DATIVE = "модулю сильного хвата",
		ACCUSATIVE = "модуль сильного хвата",
		INSTRUMENTAL = "модулем сильного хвата",
		PREPOSITIONAL = "модуле сильного хвата",
	)

/obj/item/mod/module/quick_carry/on_part_activation()
	. = ..()
	ADD_TRAIT(mod.wearer, quick_carry_trait, UNIQUE_TRAIT_SOURCE(src))

/obj/item/mod/module/quick_carry/on_part_deactivation(deleting = FALSE)
	. = ..()
	REMOVE_TRAIT(mod.wearer, quick_carry_trait, UNIQUE_TRAIT_SOURCE(src))

/obj/item/mod/module/quick_carry/advanced
	name = "MOD advanced quick carry module"
	removable = FALSE
	complexity = 0
	quick_carry_trait = TRAIT_QUICKER_CARRY

/obj/item/mod/module/quick_carry/advanced/get_ru_names()
	return list(
		NOMINATIVE = "модуль улучшенного хвата",
		GENITIVE = "модуля улучшенного хвата",
		DATIVE = "модулю улучшенного хвата",
		ACCUSATIVE = "модуль улучшенного хвата",
		INSTRUMENTAL = "модулем улучшенного хвата",
		PREPOSITIONAL = "модуле улучшенного хвата",
	)

// MARK: Injector
/// Injector - Gives the suit an extendable large-capacity piercing syringe.
/obj/item/mod/module/injector
	name = "MOD injector module"
	desc = "Модуль для МЭК, представляющий собой высокоёмкий выдвижной шприц-инъектор, устанавливаемый в запястье костюма. \
			Умный наконечник позволяет с лёгкостью обнаружить специальные места для инъекций на МЭК любой модели, проникая через любые бронеэлементы."
	icon_state = "injector"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	required_slots = list(ITEM_SLOT_GLOVES)
	device = /obj/item/reagent_containers/syringe/mod
	incompatible_modules = list(/obj/item/mod/module/injector)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/injector/get_ru_names()
	return list(
		NOMINATIVE = "модуль инъектора",
		GENITIVE = "модуля инъектора",
		DATIVE = "модулю инъектора",
		ACCUSATIVE = "модуль инъектора",
		INSTRUMENTAL = "модулем инъектора",
		PREPOSITIONAL = "модуле инъектора",
	)

/obj/item/reagent_containers/syringe/mod
	name = "MOD injector syringe"
	desc = "Высокоёмкий выдвижной шприц-инъектор. Умный наконечник позволяет с лёгкостью обнаружить \
			специальные места для инъекций на МЭК любой модели, проникая через любые бронеэлементы."
	amount_per_transfer_from_this = 30
	possible_transfer_amounts = list(5, 10, 15, 20, 30)
	volume = 30
	penetrates_thick = TRUE
	ignores_pierceimmune = TRUE

/obj/item/reagent_containers/syringe/mod/get_ru_names()
	return list(
		NOMINATIVE = "шприц-инъектор МЭК",
		GENITIVE = "шприца-инъектора МЭК",
		DATIVE = "шприцу-инъектору МЭК",
		ACCUSATIVE = "шприц-инъектор МЭК",
		INSTRUMENTAL = "шприцом-инъектором МЭК",
		PREPOSITIONAL = "шприце-инъекторе МЭК",
	)

/obj/item/reagent_containers/syringe/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, MODSUIT_TRAIT)

// MARK: Defibrillator
/// Defibrillator - Gives the suit an extendable pair of shock paddles.
/obj/item/mod/module/defibrillator
	name = "MOD defibrillator module"
	desc = "Модуль для МЭК, встраиваемый в перчатки костюма. Представляет собой компактный дефибриллятор с умным микрокомпьютером, \
			автоматически высчитывающим нужный вольтаж, усилие давления и точку приложения перчаток к пациенту. Встроенная система безопасности \
			блокирует любые попытки использования модуля в качестве оружия."
	icon_state = "defibrillator"
	item_state = null // It has an overlay as an item in hands when activated
	module_type = MODULE_ACTIVE
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 200 // 1000 charge. Shocking, I know.
	device = /obj/item/mod_defib
	required_slots = list(ITEM_SLOT_GLOVES)
	overlay_state_inactive = "module_defibrillator"
	overlay_state_active = "module_defibrillator_active"
	incompatible_modules = list(/obj/item/mod/module/defibrillator)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/defibrillator/get_ru_names()
	return list(
		NOMINATIVE = "модуль дефибриллятора",
		GENITIVE = "модуля дефибриллятора",
		DATIVE = "модулю дефибриллятора",
		ACCUSATIVE = "модуль дефибриллятора",
		INSTRUMENTAL = "модулем дефибриллятора",
		PREPOSITIONAL = "модуле дефибриллятора",
	)

/obj/item/mod/module/defibrillator/Initialize(mapload)
	. = ..()
	RegisterSignal(device, COMSIG_DEFIB_SHOCK_APPLIED, PROC_REF(on_defib_success))

/obj/item/mod/module/defibrillator/proc/on_defib_success()
	SIGNAL_HANDLER  // COMSIG_DEFIB_SHOCK_APPLIED
	drain_power(use_energy_cost)

/obj/item/mod_defib
	name = "defibrillator gauntlets"
	desc = "Пара лопаток с проводящей металлической поверхностью для передачи мощных электрических разрядов."
	icon = 'icons/obj/defib.dmi'
	icon_state = "defibgauntlets0" //Inhands handled by the module overlays
	item_state = null
	righthand_file = null //because modules are visual on modsuits
	lefthand_file = null
	w_class = WEIGHT_CLASS_BULKY
	var/defib_cooldown = 5 SECONDS
	var/safety = TRUE
	/// Whether or not the paddles are on cooldown. Used for tracking icon states.
	var/on_cooldown = FALSE

/obj/item/mod_defib/get_ru_names()
	return list(
		NOMINATIVE = "рукавицы-дефибрилляторы",
		GENITIVE = "рукавиц-дефибрилляторов",
		DATIVE = "рукавицам-дефибрилляторам",
		ACCUSATIVE = "рукавицы-дефибрилляторы",
		INSTRUMENTAL = "рукавицами-дефибрилляторами",
		PREPOSITIONAL = "рукавицах-дефибрилляторах",
	)

/obj/item/mod_defib/Initialize(mapload)
	. = ..()
	//actual unit is set to src because if not, than mod wearer is used as target for atom say and that is cursed as fuck
	AddComponent(/datum/component/defib, actual_unit = src, cooldown = defib_cooldown, speed_multiplier = toolspeed, ignore_hardsuits = !safety, safe_by_default = safety, robotic = TRUE, safe_by_default = safety, emp_proof = TRUE)
	ADD_TRAIT(src, TRAIT_NODROP, MODSUIT_TRAIT)
	RegisterSignal(src, COMSIG_DEFIB_READY, PROC_REF(on_cooldown_expire))
	RegisterSignal(src, COMSIG_DEFIB_SHOCK_APPLIED, PROC_REF(after_shock))

/obj/item/mod_defib/proc/after_shock(obj/item/defib, mob/user)
	SIGNAL_HANDLER  // COMSIG_DEFIB_SHOCK_APPLIED
	on_cooldown = TRUE
	update_icon(UPDATE_ICON_STATE)

/obj/item/mod_defib/proc/on_cooldown_expire(obj/item/defib)
	SIGNAL_HANDLER // COMSIG_DEFIB_READY
	on_cooldown = FALSE
	atom_say("Дефибриллятор готов.")
	playsound(get_turf(src), 'sound/machines/defib_ready.ogg', 50, FALSE)
	update_icon(UPDATE_ICON_STATE)

/obj/item/mod_defib/update_icon_state()
	icon_state = "[initial(icon_state)]"
	if(on_cooldown)
		icon_state = "[initial(icon_state)]_cooldown"

// MARK: Combat defib
/obj/item/mod/module/defibrillator/combat
	name = "MOD combat defibrillator module"
	desc = "Модуль для МЭК, встраиваемый в перчатки костюма. Представляет собой компактный дефибриллятор с умным микрокомпьютером, \
			автоматически высчитывающим нужный вольтаж, усилие давления и точку приложения перчаток к пациенту. \
			Протоколы безопасности были модифицированы, что позволяет использовать модуль в качестве оружия."
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 400 // 2000 charge. Since you like causing heart attacks, don't you?
	overlay_state_inactive = "module_defibrillator_combat"
	overlay_state_active = "module_defibrillator_combat_active"
	device = /obj/item/mod_defib/syndicate

/obj/item/mod/module/defibrillator/combat/get_ru_names()
	return list(
		NOMINATIVE = "модуль боевого дефибриллятора",
		GENITIVE = "модуля боевого дефибриллятора",
		DATIVE = "модулю боевого дефибриллятора",
		ACCUSATIVE = "модуль боевого дефибриллятора",
		INSTRUMENTAL = "модулем боевого дефибриллятора",
		PREPOSITIONAL = "модуле боевого дефибриллятора",
	)

/obj/item/mod_defib/syndicate
	name = "combat defibrillator gauntlets"
	icon_state = "syndiegauntlets0"
	safety = FALSE
	toolspeed = 2
	defib_cooldown = 2.5 SECONDS

/obj/item/mod_defib/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "боевые рукавицы-дефибрилляторы",
		GENITIVE = "боевых рукавиц-дефибрилляторов",
		DATIVE = "боевым рукавицам-дефибрилляторам",
		ACCUSATIVE = "боевые рукавицы-дефибрилляторы",
		INSTRUMENTAL = "боевыми рукавицами-дефибрилляторами",
		PREPOSITIONAL = "боевых рукавицах-дефибрилляторах",
	)

// MARK: Crew monitor
/// Crew Monitor - Deploys or retracts a built-in handheld crew monitor
/obj/item/mod/module/monitor
	name = "MOD crew monitor module"
	desc = "Модуль для МЭК, устанавливаемый в запястье костюма. Предоставляет пользователю \
			информацию о состоянии здоровья экипажа, считывая данные с их датчиков жизнеобеспечения."
	icon_state = "scanner"
	module_type = MODULE_ACTIVE
	complexity = 1
	required_slots = list(ITEM_SLOT_GLOVES)
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/sensor_device/mod
	incompatible_modules = list(/obj/item/mod/module/monitor)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/monitor/get_ru_names()
	return list(
		NOMINATIVE = "модуль монитора экипажа",
		GENITIVE = "модуля монитора экипажа",
		DATIVE = "модулю монитора экипажа",
		ACCUSATIVE = "модуль монитора экипажа",
		INSTRUMENTAL = "модулем монитора экипажа",
		PREPOSITIONAL = "модуле монитора экипажа",
	)

/obj/item/sensor_device/mod
	name = "MOD crew monitor"
	desc = "Миниатюрное устройство, установленное в МЭК. Предоставляет пользователю \
			информацию о состоянии здоровья экипажа, считывая данные с их датчиков жизнеобеспечения."

/obj/item/sensor_device/mod/get_ru_names()
	return list(
		NOMINATIVE = "ручной монитор экипажа",
		GENITIVE = "ручного монитора экипажа",
		DATIVE = "ручному монитору экипажа",
		ACCUSATIVE = "ручной монитор экипажа",
		INSTRUMENTAL = "ручным монитором экипажа",
		PREPOSITIONAL = "ручном мониторе экипажа"
	)

/obj/item/sensor_device/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, MODSUIT_TRAIT)

// MARK: Organizer
/// Organizer - Lets you shoot organs, immediately replacing them if the target has the organ manipulation surgery.
/obj/item/mod/module/organizer
	name = "MOD organizer module"
	desc = "Модуль для МЭК, встраиваемый в предплечье костюма. Позволяет мгновенно заменить до пяти внутренних органов цели \
			без предварительного извлечения повреждённых. Использует блюспейс-технологии, схожие с принципом работы блюспейс заменителя двигателей."
	icon_state = "organizer"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/organizer) //TODO modsuit: add /obj/item/mod/module/microwave_beam
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	/// How many organs the module can hold.
	var/max_organs = 5
	/// A list of all our organs.
	var/organ_list = list()

/obj/item/mod/module/organizer/get_ru_names()
	return list(
		NOMINATIVE = "модуль замены органов",
		GENITIVE = "модуля замены органов",
		DATIVE = "модулю замены органов",
		ACCUSATIVE = "модуль замены органов",
		INSTRUMENTAL = "модулем замены органов",
		PREPOSITIONAL = "модуле замены органов"
	)

/obj/item/mod/module/organizer/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/wearer_human = mod.wearer
	if(is_organ(target))
		if(!wearer_human.Adjacent(target))
			return
		var/atom/movable/organ = target
		if(length(organ_list) >= max_organs)
			balloon_alert(mod.wearer, "лимит органов!")
			return
		organ_list += organ
		organ.forceMove(src)
		balloon_alert(mod.wearer, "орган взят")
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		drain_power(use_energy_cost)
		return
	if(!length(organ_list))
		return
	var/atom/movable/fired_organ = pop(organ_list)
	var/obj/projectile/organ/projectile = new /obj/projectile/organ(mod.wearer.loc, fired_organ)
	projectile.original = target
	projectile.firer = mod.wearer
	projectile.preparePixelProjectile(target, mod.wearer)
	playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
	INVOKE_ASYNC(projectile, TYPE_PROC_REF(/obj/projectile, fire))
	drain_power(use_energy_cost)

// MARK: Patient transport
/// Patient Transport - Generates hardlight bags you can put people in.
/obj/item/mod/module/criminalcapture/patienttransport
	name = "MOD patient transport module"
	desc = "Модуль для МЭК, встраиваемый в предплечье костюма. Громоздкие, неудобные и хрупкие пластиковые мешки для тел теперь уже \
			прошлый век, ведь этот модуль предоставляет возможность создавать мешки из твёрдого света! Комфортная транспортировка живых \
			и не очень пациентов в любой ситуации, в любое время! Не является рекламой."
	icon_state = "patient_transport"
	bodybag_type = /obj/structure/closet/body_bag/environmental/hardlight
	capture_time = 1.5 SECONDS
	packup_time = 0.5 SECONDS

/obj/item/mod/module/criminalcapture/patienttransport/get_ru_names()
	return list(
		NOMINATIVE = "модуль мешков для тел",
		GENITIVE = "модуля мешков для тел",
		DATIVE = "модулю мешков для тел",
		ACCUSATIVE = "модуль мешков для тел",
		INSTRUMENTAL = "модулем мешков для тел",
		PREPOSITIONAL = "модуле мешков для тел"
	)
