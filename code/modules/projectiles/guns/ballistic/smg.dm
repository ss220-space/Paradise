/obj/item/gun/projectile/automatic/smg
	gender = MALE
	icon = 'icons/obj/weapons/smg.dmi'
	icon_state = "saber"
	base_pixel_x = -8
	accuracy = GUN_ACCURACY_RIFLE_EXTEND_SPREAD
	recoil = GUN_RECOIL_MEDIUM
	weapon_weight = WEAPON_HEAVY
	fire_modes = GUN_MODE_SINGLE_BURST_AUTO

	/// Exists chambered light indicator in gun
	var/chambered_light_exists = FALSE
	/// Exists ammo counter indicator in gun
	var/mag_ammo_counter_exists = FALSE
	/// Magazine ammo overlay count divider
	var/mag_ammo_counter_size = 6

/obj/item/gun/projectile/automatic/smg/Initialize(mapload)
	. = ..()
	if(!base_icon_state)
		base_icon_state = initial(icon_state)
	update_appearance(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/obj/item/gun/projectile/automatic/smg/update_icon_state()
	icon_state = "[base_icon_state]"

/obj/item/gun/projectile/automatic/smg/update_overlays()
	. = ..()
	var/base_icon_id = base_icon_state
	if(chambered_light_exists)
		. += mutable_appearance(icon, "[base_icon_id]_light-[get_ammo() > 0 ? "f" : "e"]", layer = FLOAT_LAYER - 1)
	if(!magazine)
		return
	if(mag_ammo_counter_exists)
		var/ammo_count_indicator = ceil(get_ammo(FALSE) / mag_ammo_counter_size) * mag_ammo_counter_size
		. += mutable_appearance(icon, "[base_icon_id]_mag-[ammo_count_indicator]", layer = FLOAT_LAYER - 1)
	else
		. += mutable_appearance(icon, "[base_icon_id]_mag", layer = FLOAT_LAYER - 1)

// MARK: Saber SMG
/obj/item/gun/projectile/automatic/smg/saber
	name = "Nanotrasen Saber SMG"
	desc = "Компактный пистолет-пулемёт калибра 9x19 мм, выпускаемый по лицензии \"Aegis Ordinance\". \
			Поддерживает одиночный режим огня и очередь. Встроенный коллиматорный прицел, низкая отдача, средняя точность. \
			Закупается \"Нанотрейзен\" для снаряжения охранных структур корпорации."
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	origin_tech = "combat=4;materials=2"
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'
	recoil = GUN_RECOIL_LOW
	fire_modes = GUN_MODE_SINGLE_BURST
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_SMG_STOCK
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = 4),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 3, ATTACHMENT_OFFSET_Y = 9),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = -4),
		ATTACHMENT_SLOT_STOCK = list(ATTACHMENT_OFFSET_X = -13, ATTACHMENT_OFFSET_Y = 2),
	)
	starting_attachment_types = list(/obj/item/gun_module/rail/scope/collimator, /obj/item/gun_module/stock)
	chambered_light_exists = TRUE

/obj/item/gun/projectile/automatic/smg/saber/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт SABR-9 9x19 мм",
		GENITIVE = "пистолета-пулемёта SABR-9 9x19 мм",
		DATIVE = "пистолету-пулемёту SABR-9 9x19 мм",
		ACCUSATIVE = "пистолет-пулемёт SABR-9 9x19 мм",
		INSTRUMENTAL = "пистолетом-пулемётом SABR-9 9x19 мм",
		PREPOSITIONAL = "пистолете-пулемёте SABR-9 9x19 мм",
	)

/obj/item/gun/projectile/automatic/smg/saber/rubber

/obj/item/gun/projectile/automatic/smg/saber/rubber/Initialize(mapload)
	magazine = new/obj/item/ammo_box/magazine/smgm9mm/rubber
	. = ..()

// MARK: DCA-S45
/obj/item/gun/projectile/automatic/smg/c20r
	name = "DCA-S45 submachine gun"
	desc = "Пистолет-пулемёт калибра .45 производства \"Donk Co. Arms\". Может стрелять в режиме одиночного огня, автоматического и очередями по 2. \
			Управляемая отдача и высокая для класса точность делают его предпочтительным выбором для ближнего и среднего боя."
	icon_state = "c20r"
	item_state = "c20r"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'
	burst_size = 2
	accuracy = GUN_ACCURACY_RIFLE_UPLINK
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 20, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = 6),
	)
	recoil = GUN_RECOIL_MEDIUM
	autofire_delay = 0.25 SECONDS
	chambered_light_exists = TRUE
	mag_ammo_counter_exists = TRUE
	mag_ammo_counter_size = 4

/obj/item/gun/projectile/automatic/smg/c20r/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт DCA-S45 .45",
		GENITIVE = "пистолет-пулемёта DCA-S45 .45",
		DATIVE = "пистолет-пулемёту DCA-S45 .45",
		ACCUSATIVE = "пистолет-пулемёт DCA-S45 .45",
		INSTRUMENTAL = "пистолет-пулемётом DCA-S45 .45",
		PREPOSITIONAL = "пистолет-пулемёте DCA-S45 .45",
	)

/obj/item/gun/projectile/automatic/smg/c20r/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Пистолет-пулемёт под мощный патрон .45, разработанный \"Donk Co. Arms\" для корпоративного охранного рынка. \
		Позиционируется как решение для ЧОП и служб сопровождения грузов в нестабильных секторах.<br>\
		<br>\
		Трёхпозиционный переводчик огня обеспечивает выбор между одиночным выстрелом, двухпатронным залпом и непрерывным \
		автоматическим режимом с умеренным темпом для балансировки отдачи. Стандартные крепления для тактических модулей позволяют \
		адаптировать оружие под различные задачи.<br>\
		<br>\
		По неподтверждённым данным, часть производственных партий DCA-S45 утекает на чёрный \
		рынок через посредников с сомнительной репутацией, в последствии оказываясь \
		в руках криминальных элементов и наёмников. Некоторые источники утверждают, что в их числе есть и \
		оперативники небезызвестного \"Синдиката\"."\
	)

/obj/item/gun/projectile/automatic/smg/c20r/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/gun/projectile/automatic/smg/c20r/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/ammo_alarm, 'sound/weapons/smg_empty_alarm.ogg')

/obj/item/gun/projectile/automatic/smg/c20r/update_icon_state()
	icon_state = "c20r[magazine ? "-[ceil(get_ammo(FALSE)/4)*4]" : ""][chambered ? "" : "-e"]"

// MARK: DCA-S45M Reaper
/obj/item/gun/projectile/automatic/smg/c20r/auto
	name = "DCA-S45M \"Reaper\" submachine gun"
	desc = "Модифицированный вариант пистолета-пулемёта DCA-S45 под патрон .45. Перенастроенная автоматика обеспечивает значительно более высокий темп \
			огня за счёт снижения точности. Предназначен для ближнего боя, где плотность огня превалирует над точностью. Официально на рынке не представлен."
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_LOW
	autofire_delay = 0.15 SECONDS
	fire_delay = 0.15 SECONDS

/obj/item/gun/projectile/automatic/smg/c20r/auto/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт DCA-S45M \"Жнец\" .45",
		GENITIVE = "пистолет-пулемёта DCA-S45M \"Жнец\" .45",
		DATIVE = "пистолет-пулемёту DCA-S45M \"Жнец\" .45",
		ACCUSATIVE = "пистолет-пулемёт DCA-S45M \"Жнец\" .45",
		INSTRUMENTAL = "пистолет-пулемётом DCA-S45M \"Жнец\" .45",
		PREPOSITIONAL = "пистолет-пулемёте DCA-S45M \"Жнец\" .45",
	)

/obj/item/gun/projectile/automatic/smg/c20r/rusted
	damage_mod = 0.85

/obj/item/gun/projectile/automatic/smg/c20r/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 10, destroy_max_chance = 3, malf_low_bound = 50, malf_high_bound = 100)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 5, misfire_low_bound = 50, misfire_high_bound = 100)

// MARK: WT550
/obj/item/gun/projectile/automatic/smg/wt550
	name = "WT-550 PDW"
	desc = "Компактный пистолет-пулемёт калибра 4,6x30 мм, выпускаемый по лицензии \"Aegis Ordinance\". Поддерживает три режима огня: \
			одиночный, очередь по 2 патрона и автоматический. Имеет три слота под тактические модули. \
			Состоит на вооружении многих корпоративных охранных структур, в том числе \"Нанотрейзен\"."
	icon_state = "wt550"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/wt550m9
	fire_sound = 'sound/weapons/gunshots/1wt.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_size = 2
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_SMG_STOCK
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 28, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = 7),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = -5),
		ATTACHMENT_SLOT_STOCK = list(ATTACHMENT_OFFSET_X = -5, ATTACHMENT_OFFSET_Y = -1),
	)
	starting_attachment_types = list(/obj/item/gun_module/stock)
	chambered_light_exists = TRUE
	mag_ammo_counter_exists = TRUE

/obj/item/gun/projectile/automatic/smg/wt550/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт WT-550 4,6x30 мм",
		GENITIVE = "пистолет-пулемёта WT-550 4,6x30 мм",
		DATIVE = "пистолет-пулемёту WT-550 4,6x30 мм",
		ACCUSATIVE = "пистолет-пулемёт WT-550 4,6x30 мм",
		INSTRUMENTAL = "пистолет-пулемётом WT-550 4,6x30 мм",
		PREPOSITIONAL = "пистолет-пулемёте WT-550 4,6x30 мм",
	)

/obj/item/gun/projectile/automatic/smg/wt550/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "WT-550 — пистолет-пулемёт под патрон 4,6x30 мм, выпускаемый по производственной лицензии \"Aegis Ordinance\". \
		Патент на платформу был зарегистрирован несколько десятилетий назад и с тех пор практически не обновлялся — конструкция считается отработанной \
		и коммерчески незначимой для пересмотра.<br>\
		<br>\
		Переводчик огня обеспечивает выбор между одиночным выстрелом, двухпатронным залпом и автоматическим режимом. \
		Имеет среднюю отдачу и точность по сравнению с аналогами в классе. \
		Три стандартных крепления — на дульном срезе, верхней планке и под стволом — позволяют оснастить оружие \
		базовым тактическим обвесом. Поддерживает специализированные боеприпасы калибра 4,6x30 мм, включая бронебойные, зажигательные \
		и токсинные варианты.<br>\
		<br>\
		\"Нанотрейзен\", как и ряд других компаний, закупает WT-550 крупными партиями для снабжения службы безопаности удалённых объектов — прежде всего там, \
		где стоимость логистики делает использование более дорогого вооружения нецелесообразным."\
	)

// MARK: DCA-S91 Peacekeeper
/obj/item/gun/projectile/automatic/smg/sp91rc
	name = "DCA-S91 \"Peacekeeper\" submachine gun"
	desc = "Пистолет-пулемёт калибра .45 N&R производства \"Donk Co. Arms\". Поддерживает три режима огня: \
			одиночный, очередь по 2 патрона и автоматический. Предназначен для нелетального подавления беспорядков."
	icon_state = "sp91"
	item_state = "SP-91-RC"
	mag_type = /obj/item/ammo_box/magazine/sp91rc
	fire_sound = 'sound/weapons/gunshots/1sp_91.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_SMG_STOCK
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 27, ATTACHMENT_OFFSET_Y = 3),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = 7),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = -5),
		ATTACHMENT_SLOT_STOCK = list(ATTACHMENT_OFFSET_X = -6, ATTACHMENT_OFFSET_Y = 0),
	)
	starting_attachment_types = list(/obj/item/gun_module/stock)
	chambered_light_exists = TRUE
	mag_ammo_counter_exists = TRUE

/obj/item/gun/projectile/automatic/smg/sp91rc/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт DCA-S91 \"Миротворец\" 4,6x30 мм",
		GENITIVE = "пистолет-пулемёта DCA-S91 \"Миротворец\" 4,6x30 мм",
		DATIVE = "пистолет-пулемёту DCA-S91 \"Миротворец\" 4,6x30 мм",
		ACCUSATIVE = "пистолет-пулемёт DCA-S91 \"Миротворец\" 4,6x30 мм",
		INSTRUMENTAL = "пистолет-пулемётом DCA-S91 \"Миротворец\" 4,6x30 мм",
		PREPOSITIONAL = "пистолет-пулемёте DCA-S91 \"Миротворец\" 4,6x30 мм",
	)

/obj/item/gun/projectile/automatic/smg/sp91rc/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "DCA-S91 \"Миротворец\" — пистолет-пулемёт под патрон .45 N&R, разработанный \"Donk Co. Arms\" как инструмент силового контроля в условиях, \
		где летальное воздействие нежелательно. Платформа создавалась с расчётом на охрану объектов с высокой плотностью \
		гражданского персонала — прежде всего корпоративных станций и закрытых производственных комплексов.<br>\
		<br>\
		Конструктивно оружие близко к другим ПП линейки \"Donk Co. Arms\": трёхпозиционный переводчик огня, стандартные тактические крепления, \
		средние показатели отдачи и точности. Ключевое отличие — патрон .45 N&R, обеспечивающий выраженное останавливающее действие при значительно \
		сниженном риске летального исхода.<br>\
		<br>\
		\"Нанотрейзен\" закупает \"Миротворцев\" в рамках стандартных контрактов на снабжение объектовых арсеналов. Оружие часто соседствует с боевыми ПП — \
		как более мягкая альтернатива для ситуаций, где применение летальной силы нецелесообразно."\
	)

// MARK: Sparkle-A12
/obj/item/gun/projectile/automatic/smg/sparkle_a12
	name = "A12 \"Sparkle\""
	desc = "Пистолет-пулемёт под калибр 9x19 мм, произведённый \"Aegis Ordinance\". \
			Штатно используется силовыми структурами \"Нанотрейзен\". Отличается надёжностью, высокой точностью и малыми габаритами. \
			Предназначен для ближнего боя в условиях ограниченного пространства."
	icon_state = "sparkle-a12"
	item_state = "sparkle-a12"
	mag_type = /obj/item/ammo_box/magazine/sparkle_a12
	fire_sound = 'sound/weapons/gunshots/1wt.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_SMG_STOCK
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 25, ATTACHMENT_OFFSET_Y = 3), //x+4
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 14, ATTACHMENT_OFFSET_Y = -5),
		ATTACHMENT_SLOT_STOCK = list(ATTACHMENT_OFFSET_X = -4, ATTACHMENT_OFFSET_Y = 1),
	)
	starting_attachment_types = list(/obj/item/gun_module/stock, /obj/item/gun_module/muzzle/suppressor/integrated)
	fire_modes = GUN_MODE_SINGLE_BURST
	fire_delay = 1
	damage_mod = 0.7
	chambered_light_exists = TRUE
	mag_ammo_counter_exists = TRUE

/obj/item/gun/projectile/automatic/smg/sparkle_a12/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт A-12 \"Искра\" 9x19 мм",
		GENITIVE = "пистолет-пулемёта A-12 \"Искра\" 9x19 мм",
		DATIVE = "пистолет-пулемёту A-12 \"Искра\" 9x19 мм",
		ACCUSATIVE = "пистолет-пулемёт A-12 \"Искра\" 9x19 мм",
		INSTRUMENTAL = "пистолет-пулемётом A-12 \"Искра\" 9x19 мм",
		PREPOSITIONAL = "пистолет-пулемёте A-12 \"Искра\" 9x19 мм",
	)

// MARK: Type-U3 Uzi
/obj/item/gun/projectile/automatic/smg/mini_uzi
	name = "Type U3 Uzi"
	desc = "Полностью автоматический лёгкий пистолет-пулемёт калибра 9x19 мм."
	icon_state = "mini-uzi"
	origin_tech = "combat=4;materials=2;syndicate=4"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	fire_sound = 'sound/weapons/gunshots/1uzi.ogg'
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_PISTOL_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 18, ATTACHMENT_OFFSET_Y = 7),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 12),
	)
	weapon_weight = WEAPON_LIGHT
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_LOW

/obj/item/gun/projectile/automatic/smg/mini_uzi/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт Type 3 UZI 9x19 мм",
		GENITIVE = "пистолет-пулемёта Type 3 UZI 9x19 мм",
		DATIVE = "пистолет-пулемёту Type 3 UZI 9x19 мм",
		ACCUSATIVE = "пистолет-пулемёт Type 3 UZI 9x19 мм",
		INSTRUMENTAL = "пистолет-пулемётом Type 3 UZI 9x19 мм",
		PREPOSITIONAL = "пистолет-пулемёте Type 3 UZI 9x19 мм",
	)

// MARK: Tommy Gun
/obj/item/gun/projectile/automatic/tommygun
	name = "Thompson SMG"
	desc = "Старинный пистолет-пулемёт калибра 9x19 мм."
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/gunshots/1saber.ogg'
	burst_size = 4
	fire_delay = 1
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/tommygun/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт Томсона 9x19 мм",
		GENITIVE = "пистолет-пулемёта Томсона 9x19 мм",
		DATIVE = "пистолет-пулемёту Томсона 9x19 мм",
		ACCUSATIVE = "пистолет-пулемёт Томсона 9x19 мм",
		INSTRUMENTAL = "пистолет-пулемётом Томсона 9x19 мм",
		PREPOSITIONAL = "пистолет-пулемёте Томсона 9x19 мм",
	)

// MARK: SFG-5
/obj/item/gun/projectile/automatic/smg/sfg
	name = "SFG-5"
	desc = "Современный пистолет-пулемёт калибра 9x19 мм."
	icon_state = "sfg-5"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/sfg9mm
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 17, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 2, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -5),
	)
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/smg/sfg/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт SFG-5 9x19 мм",
		GENITIVE = "пистолет-пулемёта SFG-5 9x19 мм",
		DATIVE = "пистолет-пулемёту SFG-5 9x19 мм",
		ACCUSATIVE = "пистолет-пулемёт SFG-5 9x19 мм",
		INSTRUMENTAL = "пистолет-пулемётом SFG-5 9x19 мм",
		PREPOSITIONAL = "пистолет-пулемёте SFG-5 9x19 мм",
	)

// MARK: PPSh
/obj/item/gun/projectile/automatic/smg/ppsh
	name = "PPSh submachine gun"
	desc = "Стариннный пистолет-пулемёт калибра 7,62x25 мм."
	icon_state = "ppsh"
	item_state = "ppsh"
	mag_type = /obj/item/ammo_box/magazine/ppsh
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_size = 5
	autofire_delay = 0.15 SECONDS
	fire_delay = 0.15 SECONDS
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 20, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 5, ATTACHMENT_OFFSET_Y = 5),
	)
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/projectile/automatic/smg/ppsh/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт ППШ 7,62x25 мм",
		GENITIVE = "пистолет-пулемёта ППШ 7,62x25 мм",
		DATIVE = "пистолет-пулемёту ППШ 7,62x25 мм",
		ACCUSATIVE = "пистолет-пулемёт ППШ 7,62x25 мм",
		INSTRUMENTAL = "пистолет-пулемётом ППШ 7,62x25 мм",
		PREPOSITIONAL = "пистолет-пулемёте ППШ 7,62x25 мм",
	)

/obj/item/gun/projectile/automatic/smg/ppsh/rusted
	damage_mod = 0.75

/obj/item/gun/projectile/automatic/smg/ppsh/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 20, destroy_max_chance = 4, malf_low_bound = 15, malf_high_bound = 71)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 15, misfire_low_bound = 30, misfire_high_bound = 71)
