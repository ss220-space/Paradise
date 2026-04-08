//Antag modules for MODsuits

// MARK: Insignia
/// Insignia - Gives you a skin specific stripe
/obj/item/mod/module/insignia
	name = "MOD insignia module"
	desc = "Модуль для МЭК, представлящий собой набор микрораспылителей для нанесения и снятия краски на поверхность МЭК по заданным цветовым \
			шаблонам. Несмотря на существование систем опознавания \"свой-чужой\", различных коммуникационных технологий и современных методов \
			дедуктивного анализа, включающих использование собственных глаз, разноцветная покраска по-прежнему остаётся популярным \
			способом для различных фракций в галактике отличать друг друга."
	icon_state = "insignia"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/insignia)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	overlay_state_inactive = "module_insignia"
	mask_worn_overlay = TRUE

/obj/item/mod/module/insignia/get_ru_names()
	return list(
		NOMINATIVE = "модуль покраски",
		GENITIVE = "модуля покраски",
		DATIVE = "модулю покраски",
		ACCUSATIVE = "модуль покраски",
		INSTRUMENTAL = "модулем покраски",
		PREPOSITIONAL = "модуле покраски",
	)

/obj/item/mod/module/insignia/generate_worn_overlay(obj/item/source, mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	. = ..()
	for(var/mutable_appearance/appearance as anything in .)
		appearance.color = color

/obj/item/mod/module/insignia/commander
	color = COLOR_COMMAND_BLUE

/obj/item/mod/module/insignia/security
	color = COLOR_SECURITY_RED

/obj/item/mod/module/insignia/engineer
	color = COLOR_ENGINEERING_ORANGE

/obj/item/mod/module/insignia/medic
	color = COLOR_MEDICAL_BLUE

/obj/item/mod/module/insignia/janitor
	color = COLOR_STRONG_VIOLET

/obj/item/mod/module/insignia/clown
	color = COLOR_LIGHT_PINK

/obj/item/mod/module/insignia/chaplain
	color = COLOR_ALMOST_BLACK

//Bite of 87 Springlock - Equips faster, disguised as DNA lock, can block retracting for 10 seconds.
/obj/item/mod/module/springlock/bite_of_87
	activation_step_time_booster = 10
	nineteen_eighty_seven_edition = TRUE
	dont_let_you_come_back = TRUE

/obj/item/mod/module/springlock/bite_of_87/Initialize(mapload)
	. = ..()
	var/obj/item/mod/module/dna_lock/the_dna_lock_behind_the_slaughter = /obj/item/mod/module/dna_lock
	name = initial(the_dna_lock_behind_the_slaughter.name)
	desc = initial(the_dna_lock_behind_the_slaughter.desc)
	icon_state = initial(the_dna_lock_behind_the_slaughter.icon_state)
	complexity = initial(the_dna_lock_behind_the_slaughter.complexity)
	use_energy_cost = initial(the_dna_lock_behind_the_slaughter.use_energy_cost)

/obj/item/mod/module/springlock/bite_of_87/get_ru_names()
	return list(
		NOMINATIVE = "модуль ДНК-блокировки",
		GENITIVE = "модуля ДНК-блокировки",
		DATIVE = "модулю ДНК-блокировки",
		ACCUSATIVE = "модуль ДНК-блокировки",
		INSTRUMENTAL = "модулем ДНК-блокировки",
		PREPOSITIONAL = "модуле ДНК-блокировки",
	)

/obj/item/mod/module/holster/hidden/Initialize(mapload)
	. = ..()
	var/obj/item/mod/module/grappling_hook/fake = /obj/item/mod/module/grappling_hook
	name = initial(fake.name)
	desc = initial(fake.desc)
	icon_state = initial(fake.icon_state)
	complexity = initial(fake.complexity)
	use_energy_cost = initial(fake.use_energy_cost)

/obj/item/mod/module/holster/hidden/get_ru_names()
	return list(
		NOMINATIVE = "модуль крюк-кошки",
		GENITIVE = "модуля крюк-кошки",
		DATIVE = "модулю крюк-кошки",
		ACCUSATIVE = "модуль крюк-кошки",
		INSTRUMENTAL = "модулем крюк-кошки",
		PREPOSITIONAL = "модуле крюк-кошки",
	)

// MARK: Power kick
/// Power kick - Lets the user launch themselves at someone to kick them.
/obj/item/mod/module/power_kick
	name = "MOD power kick module"
	desc = "Модуль для МЭК, использующий миомеры высокой мощности для генерации импульса, преобразуемого в кинетическую энергию пинка."
	icon_state = "power_kick"
	module_type = MODULE_ACTIVE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/power_kick)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_FEET)
	/// Damage on kick.
	var/damage = 20
	/// How long we knockdown for on the kick.
	var/knockdown_time = 6 SECONDS

/obj/item/mod/module/power_kick/get_ru_names()
	return list(
		NOMINATIVE = "модуль \"Силовой пинок\"",
		GENITIVE = "модуля \"Силовой пинок\"",
		DATIVE = "модулю \"Силовой пинок\"",
		ACCUSATIVE = "модуль \"Силовой пинок\"",
		INSTRUMENTAL = "модулем \"Силовой пинок\"",
		PREPOSITIONAL = "модуле \"Силовой пинок\"",
	)

/obj/item/mod/module/power_kick/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(mod.wearer.buckled)
		return
	mod.wearer.visible_message(span_warning("[mod.wearer] готов[PLUR_IT_YAT(mod.wearer)]ся кого-нибудь пнуть!"))
	playsound(src, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	animate(mod.wearer, 0.3 SECONDS, pixel_z = 16, flags = ANIMATION_RELATIVE, easing = SINE_EASING|EASE_OUT)
	addtimer(CALLBACK(mod.wearer, TYPE_PROC_REF(/atom, SpinAnimation), 3, 2), 0.3 SECONDS)
	if(!do_after(mod.wearer, 1 SECONDS, target = mod.wearer))
		animate(mod.wearer, 0.2 SECONDS, pixel_z = -16, flags = ANIMATION_RELATIVE, easing = SINE_EASING|EASE_IN)
		return
	animate(mod.wearer)
	drain_power(use_energy_cost)
	playsound(src, 'sound/items/modsuit/loader_launch.ogg', 75, TRUE)
	var/angle = get_angle(mod.wearer, target) + 180
	mod.wearer.transform = mod.wearer.transform.Turn(angle)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	mod.wearer.apply_status_effect(STATUS_EFFECT_IMPACT_IMMUNE)
	mod.wearer.throw_at(target, range = 7, speed = 2, thrower = mod.wearer, spin = FALSE, callback = CALLBACK(src, PROC_REF(on_throw_end), mod.wearer, -angle))

/obj/item/mod/module/power_kick/proc/on_throw_end(mob/living/user, angle)
	if(!user)
		return
	user.transform = user.transform.Turn(angle)
	animate(user, 0.2 SECONDS, pixel_z = -16, flags = ANIMATION_RELATIVE, easing = SINE_EASING|EASE_IN)
	user.remove_status_effect((STATUS_EFFECT_IMPACT_IMMUNE))

/obj/item/mod/module/power_kick/proc/on_throw_impact(mob/living/source, atom/target, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!mod?.wearer)
		return
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_damage(damage, BRUTE, mod.wearer.zone_selected)
		add_attack_logs(mod.wearer, target, "[target] was charged by [mod.wearer]'s [src]", ATKLOG_ALMOSTALL)
		living_target.Weaken(knockdown_time)
		mod.wearer.visible_message(
			span_danger("[mod.wearer] вреза[PLUR_ET_UT(mod.wearer)]ся в [target.declent_ru(ACCUSATIVE)]!"),
			span_userdanger("Вы врезаетесь в [target.declent_ru(ACCUSATIVE)]!")
		)
	else
		return
	mod.wearer.do_attack_animation(target, ATTACK_EFFECT_SMASH)

// MARK: Plate compression
/// Plate Compression - Compresses the suit to normal size
/obj/item/mod/module/plate_compression
	name = "MOD plate compression module"
	desc = "Модуль для МЭК, позволяющий снизить габариты костюма за счёт сближения компонентов костюма друг к другу. \
			Оказываемое в процессе давление делает совместное использование МЭК со стандартными модулями хранения невозможным."
	icon_state = "plate_compression"
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/plate_compression, /obj/item/mod/module/storage)
	/// The size we set the suit to.
	var/new_size = WEIGHT_CLASS_NORMAL
	/// The suit's size before the module is installed.
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	var/old_size
	origin_tech = "materials=6;bluespace=5;syndicate=1" //Printable at illegals 2, so only one level.

/obj/item/mod/module/plate_compression/get_ru_names()
	return list(
		NOMINATIVE = "уплотняющий модуль",
		GENITIVE = "уплотняющего модуля",
		DATIVE = "уплотняющему модулю",
		ACCUSATIVE = "уплотняющий модуль",
		INSTRUMENTAL = "уплотняющим модулем",
		PREPOSITIONAL = "уплотняющем модуле",
	)

/obj/item/mod/module/plate_compression/on_install()
	. = ..()
	old_size = mod.w_class
	mod.w_class = new_size

/obj/item/mod/module/plate_compression/on_uninstall(deleting = FALSE)
	. = ..()
	mod.w_class = old_size
	old_size = null
	if(!mod.loc)
		return
	mod.forceMove(drop_location())


// Ninja modules for MODsuits
// MARK: Stealth
/// Cloaking - Lowers the user's visibility, can be interrupted by being touched or attacked.
/obj/item/mod/module/stealth
	name = "MOD prototype cloaking module"
	desc = "Модуль для МЭК, радикально модифицирующий внешнее устройство костюма. Представляет собой комбинацию \
			технологий оптической маскировки и адаптивных наноматериалов, позволяющих костюму мимикрировать под окружающую среду."
	icon_state = "cloak"
	module_type = MODULE_TOGGLE
	complexity = 4
	active_power_cost = DEFAULT_CHARGE_DRAIN * 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/stealth)
	cooldown_time = 10 SECONDS
	origin_tech = "combat=6;materials=6;powerstorage=5;bluespace=5;syndicate=2" //Printable at 3
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_CLOTH_OUTER|ITEM_SLOT_CLOTH_INNER, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	/// Whether or not the cloak turns off on bumping.
	var/bumpoff = TRUE
	/// The alpha applied when the cloak is on.
	var/stealth_alpha = 50

/obj/item/mod/module/stealth/get_ru_names()
	return list(
		NOMINATIVE = "маскирующий модуль",
		GENITIVE = "маскирующего модуля",
		DATIVE = "маскирующему модулю",
		ACCUSATIVE = "маскирующий модуль",
		INSTRUMENTAL = "маскирующим модулем",
		PREPOSITIONAL = "маскирующем модуле",
	)

/obj/item/mod/module/stealth/on_activation()
	if(bumpoff)
		RegisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP, PROC_REF(unstealth))
	RegisterSignal(mod.wearer, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	RegisterSignal(mod.wearer, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act)) //TODO QWERTY: A LOT OF THESE SIGNALS AINT TRIGGERING. or at least this one.
	RegisterSignal(mod.wearer, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW), PROC_REF(unstealth))
	animate(mod.wearer, alpha = stealth_alpha, time = 1.5 SECONDS)
	drain_power(use_energy_cost)

/obj/item/mod/module/stealth/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(bumpoff)
		UnregisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(mod.wearer, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_MOB_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW))
	animate(mod.wearer, alpha = 255, time = 1.5 SECONDS)

/obj/item/mod/module/stealth/proc/unstealth(datum/source)
	SIGNAL_HANDLER

	balloon_alert(mod.wearer, "маскировка снята")
	do_sparks(2, TRUE, src)
	drain_power(use_energy_cost)
	COOLDOWN_START(src, cooldown_timer, cooldown_time) //Put it on cooldown.
	on_deactivation(display_message = TRUE, deleting = FALSE)

/obj/item/mod/module/stealth/proc/on_unarmed_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	unstealth(source)

/obj/item/mod/module/stealth/proc/on_bullet_act(datum/source, obj/item/projectile)
	SIGNAL_HANDLER

	unstealth(source)

// MARK: Advanced stealth
/// Advanced Cloaking - Doesn't turn off on bump, less power drain, more stealthy.
/obj/item/mod/module/stealth/ninja
	name = "MOD advanced cloaking module"
	desc = "Модуль для МЭК, радикально модифицирующий внешнее устройство костюма. Представляет собой комбинацию \
			технологий оптической маскировки и адаптивных наноматериалов, позволяющих костюму мимикрировать под окружающую среду. \
			Продвинутая модель, отличающаяся повышенной скоростью реагирования и возможностью поддерживать маскировку \
			даже в случае столкновения с твёрдыми объектами."
	icon_state = "cloak_ninja"
	bumpoff = FALSE
	cooldown_time = 5 SECONDS
	stealth_alpha = 10
	active_power_cost = DEFAULT_CHARGE_DRAIN
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	origin_tech = "combat=6;materials=6;powerstorage=6;bluespace=6;syndicate=4"

/obj/item/mod/module/stealth/ninja/get_ru_names()
	return list(
		NOMINATIVE = "продвинутый маскирующий модуль",
		GENITIVE = "продвинутого маскирующего модуля",
		DATIVE = "продвинутому маскирующему модулю",
		ACCUSATIVE = "продвинутый маскирующий модуль",
		INSTRUMENTAL = "продвинутым маскирующим модулем",
		PREPOSITIONAL = "продвинутом маскирующем модуле",
	)

// MARK: Status readout
/// Status Readout - Puts a lot of information including health, nutrition, fingerprints, temperature to the suit TGUI.
/obj/item/mod/module/status_readout
	name = "MOD status readout module"
	desc = "Модуль для МЭК, устанавливаемый в спинной отдел костюма. Подключается напрямую к позвоночному столбу носителя, \
			что позволяет модулю считывать и отображать различные биометрические показатели организма: \
			уровень утомления, насыщения, физическая форма, состояние здоровья, эмоциональный фон и так далее."
	icon_state = "status"
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.1
	incompatible_modules = list(/obj/item/mod/module/status_readout)
	tgui_id = "status_readout"
	origin_tech = "combat=6;biotech=6;syndicate=1"
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// Does this show damage types, body temp, satiety
	var/display_detailed_vitals = TRUE
	/// Does this show DNA data
	var/display_dna = FALSE
	/// Does this show the round ID and shift time?
	var/display_time = FALSE

/obj/item/mod/module/status_readout/get_ru_names()
	return list(
		NOMINATIVE = "модуль оценки состояния",
		GENITIVE = "модуля оценки состояния",
		DATIVE = "модулюоценки состояния",
		ACCUSATIVE = "модуль оценки состояния",
		INSTRUMENTAL = "модулем оценки состояния",
		PREPOSITIONAL = "модуле оценки состояния",
	)

/obj/item/mod/module/status_readout/add_ui_data()
	. = ..()
	.["display_time"] = display_time
	.["shift_time"] = station_time_timestamp()
	.["shift_id"] = GLOB.round_id
	.["health"] = mod.wearer?.health || 0
	.["health_max"] = mod.wearer?.getMaxHealth() || 0
	if(display_detailed_vitals)
		.["loss_brute"] = mod.wearer?.getBruteLoss() || 0
		.["loss_fire"] = mod.wearer?.getFireLoss() || 0
		.["loss_tox"] = mod.wearer?.getToxLoss() || 0
		.["loss_oxy"] = mod.wearer?.getOxyLoss() || 0
		.["body_temperature"] = mod.wearer?.bodytemperature || 0
		.["nutrition"] = mod.wearer?.nutrition || 0
	if(display_dna)
		.["dna_unique_identity"] = mod.wearer ? md5(mod.wearer.dna.uni_identity) : null
		.["dna_unique_enzymes"] = mod.wearer?.dna.unique_enzymes
	.["viruses"] = null
	if(!length(mod.wearer?.diseases))
		return .
	var/list/viruses = list()
	for(var/datum/disease/virus as anything in mod.wearer.diseases)
		var/list/virus_data = list()
		virus_data["name"] = virus.name
		virus_data["type"] = virus.agent
		virus_data["stage"] = virus.stage
		virus_data["maxstage"] = virus.max_stages
		virus_data["cure"] = virus.cure_text
		viruses += list(virus_data)
	.["viruses"] = viruses

	return .

/obj/item/mod/module/status_readout/get_configuration()
	. = ..()
	.["display_detailed_vitals"] = add_ui_configuration("Детальные данные", "bool", display_detailed_vitals)
	.["display_dna"] = add_ui_configuration("Отображение ДНК", "bool", display_dna)

/obj/item/mod/module/status_readout/configure_edit(key, value)
	switch(key)
		if("display_detailed_vitals")
			display_detailed_vitals = text2num(value)
		if("display_dna")
			display_dna = text2num(value)

// MARK: Camera module
/// Camera Module - Puts a camera in the modsuit that the ERT commander can see
/obj/item/mod/module/ert_camera
	name = "MOD camera module"
	desc = "Модуль для МЭК, представляющий собой комбинацию записывающей камеры и транслирующего устройства. В прямом эфире отправляет всё, \
			что видит носитель, на чёрный ящик объекта и Центрального командования. Используется подразделениями ОБР НТ \
			для тактической координации, анализа операций и архивирования инцидентов — включая особо показательные ошибки бойцов \"Нанотрейзен\"."
	icon_state = "eradicationlock" //looks like a bluespace transmitter or something, probably could use an actual camera look.
	complexity = 1
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	incompatible_modules = list(/obj/item/mod/module/ert_camera)
	var/obj/machinery/camera/portable/camera

/obj/item/mod/module/ert_camera/get_ru_names()
	return list(
		NOMINATIVE = "модуль камеры",
		GENITIVE = "модуля камеры",
		DATIVE = "модулю камеры",
		ACCUSATIVE = "модуль камеры",
		INSTRUMENTAL = "модулем камеры",
		PREPOSITIONAL = "модуле камеры",
	)

/obj/item/mod/module/ert_camera/on_part_activation()
	if(ishuman(mod.wearer))
		register_camera(mod.wearer)

/obj/item/mod/module/ert_camera/proc/register_camera(mob/wearer)
	if(camera)
		return
	camera = new /obj/machinery/camera/portable(src, FALSE)
	camera.network = list("ERT")
	camera.c_tag = wearer.name
	balloon_alert(wearer, "камера активирована")

/obj/item/mod/module/ert_camera/Destroy()
	QDEL_NULL(camera)
	return ..()

/obj/item/mod/module/ert_camera/on_part_deactivation(deleting = FALSE)
	QDEL_NULL(camera)

// MARK: Chameleon
/// Chameleon - lets the suit disguise as any item that would fit on that slot.
/obj/item/mod/module/chameleon
	name = "MOD chameleon module"
	desc = "Модуль для МЭК, предоставляющий технологию \"хамелеон\", позволяющую замаскировать костюм под другой объект."
	icon_state = "chameleon"
	module_type = MODULE_USABLE
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/chameleon)
	cooldown_time = 0.5 SECONDS
	allow_flags = list(MODULE_ALLOW_INACTIVE|MODULE_ALLOW_UNWORN)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	origin_tech = "materials=6;bluespace=5;syndicate=1"

/obj/item/mod/module/chameleon/get_ru_names()
	return list(
		NOMINATIVE = "модуль-хамелеон",
		GENITIVE = "модуля-хамелеона",
		DATIVE = "модулю-хамелеону",
		ACCUSATIVE = "модуль-хамелеон",
		INSTRUMENTAL = "модулем-хамелеоном",
		PREPOSITIONAL = "модуле-хамелеоне",
	)

/obj/item/mod/module/chameleon/on_install()
	. = ..()
	mod.chameleon_action = new(mod)
	mod.chameleon_action.chameleon_type = /obj/item/storage/backpack
	mod.chameleon_action.chameleon_name = "Backpack"
	mod.chameleon_action.initialize_disguises()

/obj/item/mod/module/chameleon/on_uninstall(deleting = FALSE)
	. = ..()
	if(mod.current_disguise)
		return_look()
	QDEL_NULL(mod.chameleon_action)

/obj/item/mod/module/chameleon/on_use()
	if(mod.active || mod.activating)
		balloon_alert(mod.wearer, "сначала выключите костюм!")
		return
	if(mod.current_disguise)
		return_look()
		return
	mod.chameleon_action.select_look(mod.wearer)
	mod.current_disguise = TRUE
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(return_look))

/obj/item/mod/module/chameleon/proc/return_look()
	mod.current_disguise = FALSE
	mod.name = "[mod.theme.name] [initial(mod.name)]"
	mod.desc = "[initial(mod.desc)] [mod.theme.desc]"
	mod.icon_state = "[mod.skin]-control"
	var/list/mod_skin = mod.theme.variants[mod.skin]
	mod.icon = mod_skin[MOD_ICON_OVERRIDE] || 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	mod.onmob_sheets = list(slot_bitfield_to_slot_string(mod.slot_flags) = 'icons/mob/clothing/modsuit/mod_clothing.dmi')
	mod.lefthand_file = initial(mod.lefthand_file)
	mod.righthand_file = initial(mod.righthand_file)
	update_clothing_slots()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)

// MARK: Energy shield
/// Energy Shield - Gives you a rechargeable energy shield that nullifies attacks.
/obj/item/mod/module/energy_shield
	name = "MOD energy shield module"
	desc = "Модуль персонального защитного силового поля для МЭК, являющийся уменьшенной версией отражателей, устанавливаемых на \
			космические корабли, что можно легко заметить по его энергозатратности. Впрочем, благодаря этому модуль способен отразить \
			практически любую атаку. К счастью или нет, но из-за малого количества зарядов носитель всё ещё может внезапно оказаться смертен."
	icon_state = "energy_shield"
	complexity = 3
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/energy_shield)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// Max charges of the shield.
	var/max_charges = 3
	/// The time it takes for the first charge to recover.
	var/recharge_start_delay = 20 SECONDS
	/// How much time it takes for charges to recover after they started recharging.
	var/charge_increment_delay = 1 SECONDS
	/// How much charge is recovered per recovery.
	var/charge_recovery = 1
	/// Whether or not this shield can lose multiple charges.
	var/lose_multiple_charges = FALSE
	/// The item path to recharge this shield.
	var/recharge_path = null
	/// The icon file of the shield.
	var/shield_icon_file = 'icons/effects/effects.dmi'
	/// The icon_state of the shield.
	var/shield_icon = "shield-red"
	/// Charges the shield should start with.
	var/charges

/obj/item/mod/module/energy_shield/get_ru_names()
	return list(
		NOMINATIVE = "модуль энергетического щита",
		GENITIVE = "модуля энергетического щита",
		DATIVE = "модулю энергетического щита",
		ACCUSATIVE = "модуль энергетического щита",
		INSTRUMENTAL = "модулем энергетического щита",
		PREPOSITIONAL = "модуле энергетического щита",
	)

/obj/item/mod/module/energy_shield/Initialize(mapload)
	. = ..()
	charges = max_charges

/obj/item/mod/module/energy_shield/on_part_activation()
	mod.AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_start_delay, charge_increment_delay = charge_increment_delay, \
	charge_recovery = charge_recovery, lose_multiple_charges = lose_multiple_charges, recharge_path = recharge_path, starting_charges = charges, shield_icon_file = shield_icon_file, shield_icon = shield_icon)
	RegisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(shield_reaction))

/obj/item/mod/module/energy_shield/on_part_deactivation(deleting = FALSE)
	var/datum/component/shielded/shield = mod.GetComponent(/datum/component/shielded)
	charges = shield.current_charges
	qdel(shield)
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS)

/obj/item/mod/module/energy_shield/proc/shield_reaction(mob/living/carbon/human/owner,
	atom/movable/hitby,
	attack_text = "the attack",
	final_block_chance = 0,
	damage = 0,
	attack_type = MELEE_ATTACKS,
	damage_type = BRUTE
)
	SIGNAL_HANDLER

	if(SEND_SIGNAL(mod, COMSIG_ITEM_HIT_REACT, owner, hitby, damage, attack_type) & COMPONENT_BLOCK_SUCCESSFUL)
		drain_power(use_energy_cost)
		return SHIELD_BLOCK
	return NONE

/obj/item/mod/module/energy_shield/gamma
	shield_icon = "shield-old"

// MARK: Tesla-wall
/obj/item/mod/module/anomaly_locked/teslawall
	name = "MOD arc-shield module" // temp
	desc = "Экспериментальный модуль для МЭК, требующий для своей работы ядро энергетической аномалии, которое позволяет генерировать \
			наведённое силовое поле высокой интенсивности, функционально схожее с энергетическим щитом."
	icon_state = "tesla"
	complexity = 3
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 75
	accepted_anomalies = list(/obj/item/assembly/signaler/core/energetic)
	incompatible_modules = list(/obj/item/mod/module/energy_shield, /obj/item/mod/module/anomaly_locked)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	///Copy paste of shielded code wheeeey
	/// Max charges of the shield.
	var/max_charges = 80 // Less charges because not gamma / this one is real shocking
	/// The time it takes for the first charge to recover.
	var/recharge_start_delay = 10 SECONDS
	/// How much time it takes for charges to recover after they started recharging.
	var/charge_increment_delay = 10 SECONDS
	/// How much charge is recovered per recovery.
	var/charge_recovery = 20
	/// Whether or not this shield can lose multiple charges.
	var/lose_multiple_charges = TRUE
	/// The item path to recharge this shield.
	var/recharge_path = null
	/// The icon file of the shield.
	var/shield_icon_file = 'icons/effects/effects.dmi'
	/// The icon_state of the shield.
	var/shield_icon = "electricity3"
	/// Charges the shield should start with.
	var/charges
	/// Can our core actually zap in melee?
	var/can_tesla_zap = TRUE
	/// Range of tesla zap when we get shot
	var/zap_range = 5
	/// Maximum tesla zap range of the core
	var/maximum_zap_range = 7
	/// Power of tesla zap when we get shot
	var/power = 12500
	/// Damage of tesla zap when we get shot
	var/shock_damage = 30

/obj/item/mod/module/anomaly_locked/teslawall/get_ru_names()
	return list(
		NOMINATIVE = "модуль аномальной защиты",
		GENITIVE = "модуля аномальной защиты",
		DATIVE = "модулю аномальной защиты",
		ACCUSATIVE = "модуль аномальной защиты",
		INSTRUMENTAL = "модулем аномальной защиты",
		PREPOSITIONAL = "модуле аномальной защиты",
	)

/obj/item/mod/module/anomaly_locked/teslawall/Initialize(mapload)
	. = ..()
	charges = max_charges

/*
tier 1 - 15-20 damage absorb, 5 recharge per 10 seconds, no melee arc flash, tesla zap range 2-3 tiles and 7 damage
tier 2 - 30-40 damage absorb, 11 recharge per 10 seconds, no melee arc flash,  tesla zap range 5-6 tiles and 14 damage
tier 3 - 60-70 damage absorb, 23 recharge per 10 seconds, melee arc flash, tesla zap range 7 tiles, and 28-30 damage
please, keep this up to date
*/
#define PROTECTION_DIVIDING_MODIFICATOR 3
#define CHARGE_DIVIDING_MODIFICATOR 9
#define RANGE_DIVIDING_MODIFICATOR 20
#define DAMAGE_DIVIDING_MODIFICATOR 7
#define TESLA_ZAP_STRENGTH_REQ 200

/obj/item/mod/module/anomaly_locked/teslawall/update_core_powers()
	if(!core)
		max_charges = 0
		zap_range = 0
		shock_damage = 0
		can_tesla_zap = FALSE
		return

	var/calculated_protection = round((core.get_strength() / PROTECTION_DIVIDING_MODIFICATOR))
	var/calculated_charge = round((core.get_strength() / CHARGE_DIVIDING_MODIFICATOR))
	var/calculated_range =  min(round((core.get_strength() / RANGE_DIVIDING_MODIFICATOR)), maximum_zap_range) //limit of 7
	var/calculated_damage = round((core.get_strength() / DAMAGE_DIVIDING_MODIFICATOR))
	max_charges = calculated_protection
	charge_recovery = calculated_charge
	zap_range = calculated_range
	shock_damage = calculated_damage
	if(core.get_strength() > TESLA_ZAP_STRENGTH_REQ)
		can_tesla_zap = TRUE

#undef PROTECTION_DIVIDING_MODIFICATOR
#undef CHARGE_DIVIDING_MODIFICATOR
#undef RANGE_DIVIDING_MODIFICATOR
#undef DAMAGE_DIVIDING_MODIFICATOR
#undef TESLA_ZAP_STRENGTH_REQ

/obj/item/mod/module/anomaly_locked/teslawall/on_part_activation()
	if(!core)
		return FALSE
	mod.AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_start_delay, charge_increment_delay = charge_increment_delay, \
	charge_recovery = charge_recovery, lose_multiple_charges = lose_multiple_charges, show_charge_as_alpha = lose_multiple_charges, recharge_path = recharge_path, starting_charges = charges, shield_icon_file = shield_icon_file, shield_icon = shield_icon)
	RegisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(shield_reaction))
	ADD_TRAIT(mod.wearer, TRAIT_SHOCKIMMUNE, UNIQUE_TRAIT_SOURCE(src))

/obj/item/mod/module/anomaly_locked/teslawall/on_part_deactivation(deleting = FALSE)
	if(!core)
		return FALSE
	var/datum/component/shielded/shield = mod.GetComponent(/datum/component/shielded)
	charges = shield.current_charges
	qdel(shield)
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS)
	REMOVE_TRAIT(mod.wearer, TRAIT_SHOCKIMMUNE, UNIQUE_TRAIT_SOURCE(src))

/obj/item/mod/module/anomaly_locked/teslawall/proc/shield_reaction(mob/living/carbon/human/owner,
	atom/movable/hitby,
	attack_text = "the attack",
	final_block_chance = 0,
	damage = 0,
	attack_type = MELEE_ATTACKS,
	damage_type = BRUTE
)
	SIGNAL_HANDLER

	if(SEND_SIGNAL(mod, COMSIG_ITEM_HIT_REACT, owner, hitby, damage, attack_type) & COMPONENT_BLOCK_SUCCESSFUL)
		drain_power(use_energy_cost)
		arc_flash(owner, hitby, damage, attack_type)
		return SHIELD_BLOCK
	return NONE

/obj/item/mod/module/anomaly_locked/teslawall/proc/arc_flash(mob/owner, atom/movable/hitby, damage, attack_type)
	if((attack_type == PROJECTILE_ATTACK || attack_type == THROWN_PROJECTILE_ATTACK) && prob(33))
		tesla_zap(owner, zap_range, power)
		return
	if(!can_tesla_zap)
		return

	if(isitem(hitby) && isliving(hitby.loc))
		var/mob/living/living_target = hitby.loc
		living_target.electrocute_act(shock_damage, owner)
		living_target.Knockdown(3 SECONDS)
		return
	if(!isliving(hitby))
		return

	var/mob/living/living_target = hitby
	living_target.electrocute_act(shock_damage, owner)
	living_target.Knockdown(3 SECONDS)

/obj/item/mod/module/anomaly_locked/teslawall/prebuilt
	prebuilt = TRUE
	removable = FALSE // No switching it into another suit / no free anomaly core

// MARK: Flamethrower
/// Flamethrower - Launches fire across the area.
/obj/item/mod/module/flamethrower
	name = "MOD flamethrower module"
	desc = "Модуль ручного огнемёта для МЭК. Развивает высокую температуру — достаточную, \
			чтобы прожечь вам путь через любые препятствия, будь то деревянные баррикады или сотрудник вражеской корпорации."
	icon_state = "flamethrower"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/flamethrower)
	cooldown_time = 2.5 SECONDS
	overlay_state_inactive = "module_flamethrower"
	overlay_state_active = "module_flamethrower_on"
	required_slots = list(ITEM_SLOT_CLOTH_OUTER|ITEM_SLOT_CLOTH_INNER)

/obj/item/mod/module/flamethrower/get_ru_names()
	return list(
		NOMINATIVE = "модуль огнемёта",
		GENITIVE = "модуля огнемёта",
		DATIVE = "модулю огнемёта",
		ACCUSATIVE = "модуль огнемёта",
		INSTRUMENTAL = "модулем огнемёта",
		PREPOSITIONAL = "модуле огнемёта",
	)

/obj/item/mod/module/flamethrower/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/projectile/flame = new /obj/projectile/bullet/incendiary/fire(mod.wearer.loc)
	flame.original = target
	flame.firer = mod.wearer
	flame.preparePixelProjectile(target, mod.wearer)
	flame.fire()
	playsound(src, 'sound/weapons/gunshots/1flamethr.ogg', 75, TRUE)
	INVOKE_ASYNC(flame, TYPE_PROC_REF(/obj/projectile, fire))
	drain_power(use_energy_cost)

// MARK: Medbeam
/// Medbeam - Medbeam but built into a modsuit
/obj/item/mod/module/medbeam
	name = "MOD medical beamgun module"
	desc = "Модуль медицинской лучевой пушки для МЭК, встраиваемый в рукав костюма. Позволяет дистанционно исцелять союзников \
			без необходимости использования съёмного медоборудования. Однако от механической потери конечности пользователем это не защищает."
	icon_state = "chronogun"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN
	device = /obj/item/gun/medbeam/mod
	incompatible_modules = list(/obj/item/mod/module/medbeam)
	cooldown_time = 0.05 SECONDS
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)

/obj/item/mod/module/medbeam/get_ru_names()
	return list(
		NOMINATIVE = "модуль мед-пушки",
		GENITIVE = "модуля мед-пушки",
		DATIVE = "модулю мед-пушки",
		ACCUSATIVE = "модуль мед-пушки",
		INSTRUMENTAL = "модулем мед-пушки",
		PREPOSITIONAL = "модуле мед-пушки",
	)

/obj/item/gun/medbeam/mod
	name = "MOD medbeam"

/obj/item/gun/medbeam/mod/get_ru_names()
	return list(
		NOMINATIVE = "медицинская лучевая пушка МЭК",
		GENITIVE = "медицинской лучевой пушки МЭК",
		DATIVE = "медицинской лучевой пушке МЭК",
		ACCUSATIVE = "медицинскую лучевую пушку МЭК",
		INSTRUMENTAL = "медицинской лучевой пушкой МЭК",
		PREPOSITIONAL = "медицинской лучевой пушке МЭК"
	)

//contractor modules
// MARK: Baton Holster
///  Baton Holster - secondary holster for baton
/obj/item/mod/module/baton_holster
	name = "MOD baton holster module"
	desc = "Модуль для МЭК, основанный на системе, схожей со стандартным модулем хранилища. Позволяет прятать в костюм \
			дубинку контрактника и доставать её по желанию пользователя. Совместимо со стандартными модулями кобуры."
	icon_state = "holster_contractor"
	module_type = MODULE_USABLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/baton_holster)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	/// Our holstered baton
	var/obj/item/melee/baton/telescopic/contractor/holstered

/obj/item/mod/module/baton_holster/get_ru_names()
	return list(
		NOMINATIVE = "модуль хранения дубинки",
		GENITIVE = "модуля хранения дубинки",
		DATIVE = "модулю хранения дубинки",
		ACCUSATIVE = "модуль хранения дубинки",
		INSTRUMENTAL = "модулем хранения дубинки",
		PREPOSITIONAL = "модуле хранения дубинки",
	)

/obj/item/mod/module/baton_holster/on_use()
	if(!holstered)
		var/obj/item/melee/baton/telescopic/contractor/holding = mod.wearer.get_active_hand()
		if(!holding)
			return
		if(!mod.wearer.can_unEquip(holding))
			balloon_alert(mod.wearer, "нельзя выпустить из рук!")
			return
		holstered = holding
		mod.wearer.balloon_alert_to_viewers("убира[PLUR_ET_UT(mod.wearer)] оружие", "оружие убрано")
		mod.wearer.temporarily_remove_item_from_inventory(holding)
		holding.forceMove(src)
	else if(mod.wearer.put_in_active_hand(holstered))
		mod.wearer.balloon_alert_to_viewers("извлека[PLUR_ET_UT(mod.wearer)] оружие", "оружие извлечено")
	else
		balloon_alert(mod.wearer, "рука занята!")

/obj/item/mod/module/baton_holster/on_uninstall(deleting = FALSE)
	. = ..()
	if(holstered)
		holstered.forceMove(drop_location())

/obj/item/mod/module/baton_holster/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == holstered)
		holstered = null

/obj/item/mod/module/baton_holster/Destroy()
	QDEL_NULL(holstered)
	return ..()

// MARK: Scorpion hook
///  Scorpion hook - slight reskin of meat hook
/obj/item/mod/module/scorpion_hook
	name = "MOD SCORPION hook module"
	desc = "Модуль для МЭК, устаналвиваемый в предплечье костюма. Представляет из себя незаконную модификацию технологии крюк-кошки \
			с использованием технологий твёрдого света. В отличие от оригинальной технологии, данный крюк применяется исключительно \
			против биологических целей. Мощные катушки притягивают жертву к пользователю на огромной скорости, выбивая жертву из равновесия."
	icon_state = "hook_contractor"
	incompatible_modules = list(/obj/item/mod/module/scorpion_hook)
	module_type = MODULE_ACTIVE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/gun/magic/contractor_hook
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/scorpion_hook/get_ru_names()
	return list(
		NOMINATIVE = "модуль крюк-кошки \"Скорпион\"",
		GENITIVE = "модуля крюк-кошки \"Скорпион\"",
		DATIVE = "модулю крюк-кошки \"Скорпион\"",
		ACCUSATIVE = "модуль крюк-кошки \"Скорпион\"",
		INSTRUMENTAL = "модулем крюк-кошки \"Скорпион\"",
		PREPOSITIONAL = "модуле крюк-кошки \"Скорпион\"",
	)

/obj/item/gun/magic/contractor_hook
	name = "SCORPION hook"
	desc = "A hardlight hook used to non-lethally pull targets much closer to the user."
	ammo_type = /obj/item/ammo_casing/magic/contractor_hook
	icon = 'icons/obj/weapons/energy.dmi'
	icon_state = "hook_weapon"
	item_state = "gun"
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
	charge_tick = 4

/obj/item/gun/magic/contractor_hook/get_ru_names()
	return list(
		NOMINATIVE = "крюк-кошка \"Скорпион\"",
		GENITIVE = "крюк-кошки \"Скорпион\"",
		DATIVE = "крюк-кошке \"Скорпион\"",
		ACCUSATIVE = "крюк-кошку \"Скорпион\"",
		INSTRUMENTAL = "крюк-кошкой \"Скорпион\"",
		PREPOSITIONAL = "крюк-кошке \"Скорпион\"",
	)

// MARK: Active Chameleon
// active chameleon module - change modsuit skin, while it's active
/obj/item/mod/module/active_chameleon
	name = "MOD active chameleon module"
	desc = "Модуль для МЭК, представляющий из себя комплект модифицированных микрораспылителей, совмещенный с экспериментальным полем \
			\"Хамелеон\". При использовании позволяет практически мгновенно модифицировать внешний вид МЭК для стороннего наблюдателя, \
			исходя из заранее заданных шаблонов."
	icon_state = "chameleon_contractor"
	module_type = MODULE_TOGGLE
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_CLOTH_OUTER|ITEM_SLOT_CLOTH_INNER, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	incompatible_modules = list(/obj/item/mod/module/active_chameleon, /obj/item/mod/module/chameleon)
	active_power_cost = DEFAULT_CHARGE_DRAIN * 6
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 15
	complexity = 3
	///List of datums we take our skins of
	var/cached_default_skin
	/// timer for chameleon activation
	var/chameleon_timer = 2.5 SECONDS

/obj/item/mod/module/active_chameleon/get_ru_names()
	return list(
		NOMINATIVE = "модуль активного хамелеона",
		GENITIVE = "модуля активного хамелеона",
		DATIVE = "модулю активного хамелеона",
		ACCUSATIVE = "модуль активного хамелеона",
		INSTRUMENTAL = "модулем активного хамелеона",
		PREPOSITIONAL = "модуле активного хамелеона",
	)

/obj/item/mod/module/active_chameleon/on_activation()
	cached_default_skin = mod.theme.default_skin
	var/list/choices = list(
		"civilian" = image(icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi', icon_state = "ref_civillian_sealed"),
		"mining" = image(icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi', icon_state = "ref_mining_sealed"),
		"medical" = image(icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi', icon_state = "ref_medical_sealed"),
		"security" = image(icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi', icon_state = "ref_security_sealed"),
		"engineering" = image(icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi', icon_state = "ref_engineering_sealed")
	)
	var/choosed_skin
	var/choosed_name
	var/selected_chameleon = show_radial_menu(usr, loc, choices, require_near = TRUE)

	if(!selected_chameleon)
		return

	switch(selected_chameleon)
		if("civilian")
			choosed_name = "модели \"Путник\""
			choosed_skin = MOD_VARIANT_CIVILIAN
		if("mining")
			choosed_name = "модели \"Первопроходец\""
			choosed_skin = MOD_VARIANT_MINING
		if("medical")
			choosed_name = "модели \"Пульс\""
			choosed_skin = MOD_VARIANT_MEDICAL
		if("security")
			choosed_name = "модели \"Страж\""
			choosed_skin = MOD_VARIANT_SECURITY
		if("engineering")
			choosed_name = "модели \"Искра\""
			choosed_skin = MOD_VARIANT_ENGINEERING

	addtimer(CALLBACK(src, PROC_REF(activate_chameleon), choosed_name, choosed_skin), chameleon_timer)

/obj/item/mod/module/active_chameleon/proc/activate_chameleon(choosed_name, choosed_skin)
	playsound(loc, 'sound/items/screwdriver2.ogg', 50, TRUE)
	balloon_alert_to_viewers("костюм преображается!", "маскировка активна")
	var/list/parts = mod.get_parts()
	for(var/obj/item/part as anything in parts + mod)
		part.ru_names = part.get_ru_names_cached()
		part.ru_names = list(
			NOMINATIVE = part.ru_names[NOMINATIVE] + " [choosed_name]",
			GENITIVE = part.ru_names[GENITIVE] + " [choosed_name]",
			DATIVE = part.ru_names[DATIVE] + " [choosed_name]",
			ACCUSATIVE = part.ru_names[ACCUSATIVE] + " [choosed_name]",
			INSTRUMENTAL = part.ru_names[INSTRUMENTAL] + " [choosed_name]",
			PREPOSITIONAL = part.ru_names[PREPOSITIONAL] + " [choosed_name]"
			)

	mod.theme.default_skin = choosed_skin
	mod.theme.set_only_visual_skin(mod, choosed_skin)
	// our little trick
	mod.theme.default_skin = cached_default_skin
	cached_default_skin = null

/obj/item/mod/module/active_chameleon/on_deactivation(display_message = TRUE, deleting = FALSE)
	playsound(loc, 'sound/items/screwdriver2.ogg', 50, TRUE)
	balloon_alert_to_viewers("костюм преображается!", "маскировка снята")

	mod.theme.set_skin(mod, mod.theme.default_skin)
	var/list/parts = mod.get_parts()
	for(var/obj/item/part as anything in parts + mod)
		part.ru_names = part.get_ru_names_cached()
		part.ru_names = list(
			NOMINATIVE = part.ru_names[NOMINATIVE] + " [mod.theme.name]",
			GENITIVE = part.ru_names[GENITIVE] + " [mod.theme.name]",
			DATIVE = part.ru_names[DATIVE] + " [mod.theme.name]",
			ACCUSATIVE = part.ru_names[ACCUSATIVE] + " [mod.theme.name]",
			INSTRUMENTAL = part.ru_names[INSTRUMENTAL] + " [mod.theme.name]",
			PREPOSITIONAL = part.ru_names[PREPOSITIONAL] + " [mod.theme.name]"
			)

/obj/item/mod/module/active_chameleon/elite
	complexity = 0
	active_power_cost = DEFAULT_CHARGE_DRAIN * 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 10
	removable = FALSE
