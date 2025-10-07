//Antag modules for MODsuits

// MARK: Armor booster
// This one currently is not in use, all of its armor bonuses were directly added to suits
/// Armor Booster - Grants your suit more armor and speed in exchange for EVA protection. Also acts as a welding screen.
/obj/item/mod/module/armor_booster
	name = "MOD armor booster module"
	desc = "Модуль выдвижных бронепластин для МЭК, предоставляющий отличную защиту от распространённых видов огнестрельного \
		и колюще-режущего оружия. В активированном состоянии лишает костюм защиты от космоса."
	icon_state = "armor_booster"
	module_type = MODULE_TOGGLE
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/armor_booster, /obj/item/mod/module/welding)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_armorbooster_off"
	overlay_state_active = "module_armorbooster_on"
	use_mod_colors = TRUE
	/// Whether or not this module removes pressure protection.
	var/remove_pressure_protection = TRUE
	/// Speed added to the control unit.
	var/speed_added = 0.5
	/// Speed that we actually added.
	var/actual_speed_added = 0
	/// Armor values added to the suit parts.
	var/obj/item/mod/armor/armor_mod_1 = /obj/item/mod/armor/mod_module_armor_boost
	/// List of parts of the suit that are spaceproofed, for giving them back the pressure protection.
	var/list/spaceproofed = list()

/obj/item/mod/module/armor_booster/get_ru_names()
	return list(
		NOMINATIVE = "модуль бронепластин",
		GENITIVE = "модуля бронепластин",
		DATIVE = "модулю бронепластин",
		ACCUSATIVE = "модуль бронепластин",
		INSTRUMENTAL = "модулем бронепластин",
		PREPOSITIONAL = "модуле бронепластин",
	)

/obj/item/mod/module/armor_booster/Initialize(mapload)
	. = ..()
	armor_mod_1 = new armor_mod_1()

/obj/item/mod/module/armor_booster/Destroy()
	QDEL_NULL(armor_mod_1)
	return ..()

/obj/item/mod/armor/mod_module_armor_boost
	armor = list(MELEE = 25, BULLET = 30, LASER = 15, ENERGY = 15, BOMB = 15, RAD = 50, FIRE = 0, ACID = 0)

/obj/item/mod/module/armor_booster/on_part_activation()
	var/datum/mod_part/head_cover = mod.get_part_datum_from_slot(ITEM_SLOT_HEAD) || mod.get_part_datum_from_slot(ITEM_SLOT_MASK) || mod.get_part_datum_from_slot(ITEM_SLOT_EYES)
	var/obj/item/clothing/head = head_cover.part_item
	if(head)
		head.flash_protect = FLASH_PROTECTION_WELDER

/obj/item/mod/module/armor_booster/on_part_deactivation(deleting = FALSE)
	var/datum/mod_part/head_cover = mod.get_part_datum_from_slot(ITEM_SLOT_HEAD) || mod.get_part_datum_from_slot(ITEM_SLOT_MASK) || mod.get_part_datum_from_slot(ITEM_SLOT_EYES)
	var/obj/item/clothing/head = head_cover.part_item
	if(!head || deleting)
		return
	head.flash_protect = initial(head.flash_protect)

/obj/item/mod/module/armor_booster/on_activation()
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(mod.wearer, "броня усилена, космос опасен")
	actual_speed_added = max(0, min(mod.slowdown_deployed, speed_added / 5))
	for(var/obj/item/part as anything in mod.get_parts(TRUE))
		part.armor = part.armor.attachArmor(armor_mod_1.armor)
		part.slowdown -= actual_speed_added
		part.update_equipped_item()
		if(!remove_pressure_protection || !isclothing(part))
			continue
		var/obj/item/clothing/clothing_part = part
		if(clothing_part.clothing_flags & STOPSPRESSUREDMAGE)
			clothing_part.clothing_flags &= ~STOPSPRESSUREDMAGE
			spaceproofed[clothing_part] = TRUE

/obj/item/mod/module/armor_booster/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(!deleting)
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(mod.wearer, "броня ослаблена, космос безопасен")
	for(var/obj/item/part as anything in mod.get_parts(TRUE))
		part.armor = part.armor.detachArmor(armor_mod_1.armor)
		part.slowdown += actual_speed_added
		part.update_equipped_item()
		if(!remove_pressure_protection || !isclothing(part))
			continue
		var/obj/item/clothing/clothing_part = part
		if(spaceproofed[clothing_part])
			clothing_part.clothing_flags |= STOPSPRESSUREDMAGE
	spaceproofed = list()

/obj/item/mod/module/armor_booster/generate_worn_overlay(obj/item/source, mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	overlay_state_active = "[initial(overlay_state_active)]-[mod.skin]"
	return ..()

// MARK: Insignia
/// Insignia - Gives you a skin specific stripe
/obj/item/mod/module/insignia
	name = "MOD insignia module"
	desc = "Модуль для МЭК, представлящий собой набор микрораспылителей для нанесения и снятия краски на МЭК по заданным цветовым \
		шаблонам. Несмотря на существование системы опознавания \"свой-чужой\", радиокоммуникации и современных методов \
		дедуктивного анализа, включающих использование собственных глаз, разноцветная покраска по-прежнему остаётся популярным \
		способным для различных фракций в галактике отличать друг друга."
	icon_state = "insignia"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/insignia)
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

// MARK: Anti-slip
// Currently not used anywhere, /obj/item/mod/module/magboot plays its role instead
/// Anti Slip - Prevents you from slipping on water.
/obj/item/mod/module/noslip
	name = "MOD anti slip module"
	desc = "Модифицированный вариант стандартных магнитных ботинок для МЭК. Их притяжение слишком слабо, чтобы можно было ходить \
		по стенам или потолку, но достаточно сильно, чтобы можно было игнорировать таблички \"Мокрый пол!\""
	icon_state = "noslip"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.1
	incompatible_modules = list(/obj/item/mod/module/noslip)
	origin_tech = "syndicate=1"
	required_slots = list(ITEM_SLOT_FEET)

/obj/item/mod/module/noslip/get_ru_names()
	return list(
		NOMINATIVE = "модуль антискольжения",
		GENITIVE = "модуля антискольжения",
		DATIVE = "модулю антискольжения",
		ACCUSATIVE = "модуль антискольжения",
		INSTRUMENTAL = "модулем антискольжения",
		PREPOSITIONAL = "модуле антискольжения",
	)

/obj/item/mod/module/noslip/on_part_activation()
	ADD_CLOTHING_TRAIT(mod.wearer, src, TRAIT_NO_SLIP_WATER)

/obj/item/mod/module/noslip/on_part_deactivation(deleting = FALSE)
	REMOVE_CLOTHING_TRAIT(mod.wearer, src, TRAIT_NO_SLIP_WATER)

/obj/item/mod/module/noslip/advanced/on_part_activation()
	ADD_CLOTHING_TRAIT(mod.wearer, src, TRAIT_NO_SLIP_ALL)
	ADD_CLOTHING_TRAIT(mod.wearer, src, TRAIT_NO_SLIP_SLIDE)

/obj/item/mod/module/noslip/advanced/on_part_deactivation(deleting = FALSE)
	REMOVE_CLOTHING_TRAIT(mod.wearer, src, TRAIT_NO_SLIP_ALL)
	REMOVE_CLOTHING_TRAIT(mod.wearer, src, TRAIT_NO_SLIP_SLIDE)

//Bite of 87 Springlock - Equips faster, disguised as DNA lock, can block retracting for 10 seconds.
/obj/item/mod/module/springlock/bite_of_87
	activation_step_time_booster = 10
	nineteen_eighty_seven_edition = TRUE
	dont_let_you_come_back = TRUE

/obj/item/mod/module/springlock/bite_of_87/Initialize(mapload)
	. = ..()
	var/obj/item/mod/module/dna_lock/the_dna_lock_behind_the_slaughter = /obj/item/mod/module/dna_lock
	name = initial(the_dna_lock_behind_the_slaughter.name) //TODO: внедрить рунеймы и их изменение
	desc = initial(the_dna_lock_behind_the_slaughter.desc)
	icon_state = initial(the_dna_lock_behind_the_slaughter.icon_state)
	complexity = initial(the_dna_lock_behind_the_slaughter.complexity)
	use_energy_cost = initial(the_dna_lock_behind_the_slaughter.use_energy_cost)

/obj/item/mod/module/holster/hidden/Initialize(mapload)
	. = ..()
	var/obj/item/mod/module/tether/fake = /obj/item/mod/module/tether
	name = initial(fake.name) //TODO: внедрить рунеймы и их изменение
	desc = initial(fake.desc)
	icon_state = initial(fake.icon_state)
	complexity = initial(fake.complexity) //This is 1 less complex than a holster, but that is fine tbh, paying tc for it.
	use_energy_cost = initial(fake.use_energy_cost)

// MARK: Power kick
/// Power kick - Lets the user launch themselves at someone to kick them.
/obj/item/mod/module/power_kick
	name = "MOD power kick module"
	desc = "Модуль для МЭК, использующий миомеры высокой мощности для генерации невероятного количества энергии, \
		преобразуемой в кинетическую энергию пинка."
	icon_state = "power_kick"
	module_type = MODULE_ACTIVE
	removable = FALSE
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
	mod.wearer.visible_message(span_warning("[mod.wearer] готов[pluralize_ru(mod.wearer.gender, "ится", "ятся")] кого-нибудь пнуть!"))
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
			span_danger("[mod.wearer] вреза[pluralize_ru(mod.wearer.gender, "ется", "ются")] в [target.declent_ru(ACCUSATIVE)]"),
			span_userdanger("Вы врезаетесь в [target.declent_ru(ACCUSATIVE)]!")
		)
	else
		return
	mod.wearer.do_attack_animation(target, ATTACK_EFFECT_SMASH)

// MARK: Plate compression
/// Plate Compression - Compresses the suit to normal size
/obj/item/mod/module/plate_compression
	name = "MOD plate compression module"
	desc = "Модуль для МЭК, позволяющий крайне плотно подогнать друг к другу детали костюма, делая его невероятно компактным. \
		Оказываемое в процессе давление делает несовместимыми с костюмом большинство стандартных модулей хранилища."
	icon_state = "plate_compression"
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/plate_compression, /obj/item/mod/module/storage)
	/// The size we set the suit to.
	var/new_size = WEIGHT_CLASS_NORMAL
	/// The suit's size before the module is installed.
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
	desc = "Модуль для МЭК, полностью изменяющий устройство костюма. Представляет собой комбинацию \
		технологий визуального стелса, использующих преломление света у поверхности костюма, и адаптивных наноматериалов, \
		позволяющих костюму мимикрировать под окружающую среду на основе показателей внешних сенсоров."
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

	balloon_alert(mod.wearer, "маскировка снята!")
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
	desc = "Модуль для МЭК, стоящий на голову выше всех предыдущих версий. \
		Преломляющее поле было усовершенствовано, приобретя гораздо более высокую скорость и точность реагирования, \
		поддерживая при этом маскировку даже в случае столкновения носителя с твёрдыми объектами."
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
	desc = "Модуль для МЭК, подключающийся к позвоночному столбу костюма, напрямую считывая и отображая всевозможные \
		биометрические данные носителя: уровень утомления, насыщения, физическая форма, здоровье и даже настроение."
	icon_state = "status"
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.1
	incompatible_modules = list(/obj/item/mod/module/status_readout)
	tgui_id = "status_readout"
	origin_tech = "combat=6;biotech=6;syndicate=1"
	required_slots = list(ITEM_SLOT_BACK)
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
	.["display_detailed_vitals"] = add_ui_configuration("Доп. описание вирусов", "bool", display_detailed_vitals)
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
	что видит носитель, на чёрный ящик станции и центрального командования. Используется подразделениями ОБР для координации \
	действий через командный центр, для последующего разбора полевых операций, и для записи смешнейших провалов лучших бойцов Нанотрейзен."
	icon_state = "eradicationlock" //looks like a bluespace transmitter or something, probably could use an actual camera look.
	complexity = 1
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
		balloon_alert(mod.wearer, "выключите костюм!")
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
	mod.lefthand_file = initial(mod.lefthand_file)
	mod.righthand_file = initial(mod.righthand_file)
	mod.wearer.update_clothing()
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
	required_slots = list(ITEM_SLOT_BACK)
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
		наведённое силовое поле высокой интенсивности. По своей функциональности схож с модулем энергетического щита."
	icon_state = "tesla"
	complexity = 3
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 75
	accepted_anomalies = list(/obj/item/assembly/signaler/core/energetic)
	incompatible_modules = list(/obj/item/mod/module/energy_shield, /obj/item/mod/module/anomaly_locked)
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

	var/zap_range = 5
	var/power = 12500
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
	if(isitem(hitby))
		if(isliving(hitby.loc))
			var/mob/living/M = hitby.loc
			M.electrocute_act(shock_damage, owner)
			M.Knockdown(3 SECONDS)
	else if(isliving(hitby))
		var/mob/living/M = hitby
		M.electrocute_act(shock_damage, owner)
		M.Knockdown(3 SECONDS)

/obj/item/mod/module/anomaly_locked/teslawall/prebuilt
	prebuilt = TRUE
	removable = FALSE // No switching it into another suit / no free anomaly core

// MARK: Flamethrower
/// Flamethrower - Launches fire across the area.
/obj/item/mod/module/flamethrower
	name = "MOD flamethrower module"
	desc = "Модуль ручного огнемёта для МЭК. Поддерживает достаточную температуру, чтобы прожечь вам путь \
		через любые препятствия, будь то деревянные баррикады или опостылевший агент внутренних дел."
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
	flame.preparePixelProjectile(target, get_turf(target), mod.wearer)
	flame.fire()
	playsound(src, 'sound/items/modsuit/flamethrower.ogg', 75, TRUE)
	INVOKE_ASYNC(flame, TYPE_PROC_REF(/obj/projectile, fire))
	drain_power(use_energy_cost)

// MARK: Medbeam
/// Medbeam - Medbeam but built into a modsuit
/obj/item/mod/module/medbeam
	name = "MOD medical beamgun module"
	desc = "Модуль медицинской лучевой пушки для МЭК, встроенный в рукав костюма. Позволяет исцелять союзников без риска \
		выронить столь ценную экипировку. Впрочем, её всё ещё можно потерять вместе с рукой."
	icon_state = "chronogun"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN
	device = /obj/item/gun/medbeam/mod
	incompatible_modules = list(/obj/item/mod/module/medbeam)
	removable = TRUE
	cooldown_time = 0.05 SECONDS
	required_slots = list(ITEM_SLOT_BACK)

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
