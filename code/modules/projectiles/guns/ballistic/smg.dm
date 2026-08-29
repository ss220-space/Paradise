// MARK: Base SMG
/obj/item/gun/projectile/automatic/smg
	gender = MALE
	icon = 'icons/obj/weapons/smg.dmi'
	icon_state = "saber"
	base_pixel_x = -8
	accuracy = GUN_ACCURACY_RIFLE_EXTEND_SPREAD
	recoil = GUN_RECOIL_MEDIUM
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC)

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

// MARK: SABR-9
/obj/item/gun/projectile/automatic/smg/saber
	name = "SABR-9 submachine gun"
	desc = "Компактный пистолет-пулемёт калибра 9x19 мм, выпускаемый по лицензии \"Aegis Ordinance\". \
			Поддерживает одиночный режим огня и очередь. Встроенный коллиматорный прицел, низкая отдача, средняя точность. \
			Закупается \"Нанотрейзен\" для снаряжения охранных структур корпорации."
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	origin_tech = "combat=4;materials=2"
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'
	recoil = GUN_RECOIL_LOW
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE)
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
	return alist(
		NOMINATIVE = "пистолет-пулемёт SABR-9",
		GENITIVE = "пистолета-пулемёта SABR-9",
		DATIVE = "пистолету-пулемёту SABR-9",
		ACCUSATIVE = "пистолет-пулемёт SABR-9",
		INSTRUMENTAL = "пистолетом-пулемётом SABR-9",
		PREPOSITIONAL = "пистолете-пулемёте SABR-9",
	)

/obj/item/gun/projectile/automatic/smg/saber/rubber

/obj/item/gun/projectile/automatic/smg/saber/rubber/Initialize(mapload)
	magazine = new/obj/item/ammo_box/magazine/smgm9mm/rubber
	. = ..()

// MARK: DCA S45
/obj/item/gun/projectile/automatic/smg/c20r
	name = "DCA S45 submachine gun"
	desc = "Пистолет-пулемёт калибра .45 производства \"Donk Co. Arms\". Может стрелять в режиме одиночного огня, автоматического и очередями по 2. \
			Управляемая отдача и высокая для класса точность делают его предпочтительным выбором для ближнего и среднего боя."
	icon_state = "c20r"
	item_state = "c20r"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'
	burst_amount = 2
	accuracy = GUN_ACCURACY_RIFLE_UPLINK
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 20, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = 6),
	)
	recoil = GUN_RECOIL_MEDIUM
	fire_delay = 0.35 SECONDS
	chambered_light_exists = TRUE
	mag_ammo_counter_exists = TRUE
	mag_ammo_counter_size = 4

/obj/item/gun/projectile/automatic/smg/c20r/get_ru_names()
	return alist(
		NOMINATIVE = "пистолет-пулемёт DCA S45",
		GENITIVE = "пистолета-пулемёта DCA S45",
		DATIVE = "пистолету-пулемёту DCA S45",
		ACCUSATIVE = "пистолет-пулемёт DCA S45",
		INSTRUMENTAL = "пистолетом-пулемётом DCA S45",
		PREPOSITIONAL = "пистолете-пулемёте DCA S45",
	)

/obj/item/gun/projectile/automatic/smg/c20r/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Пистолет-пулемёт под мощный патрон .45, разработанный \"Donk Co. Arms\" для корпоративного охранного рынка. \
		Позиционируется как решение для ЧОП и служб сопровождения грузов в нестабильных секторах.<br>\
		<br>\
		Трёхпозиционный переводчик огня обеспечивает выбор между одиночным выстрелом, двухпатронным залпом и непрерывным \
		автоматическим режимом с умеренным темпом для балансировки отдачи.<br>\
		<br>\
		По неподтверждённым данным, часть производственных партий DCA S45 утекает на чёрный \
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

// MARK: "Reaper"
/obj/item/gun/projectile/automatic/smg/c20r/auto
	name = "\"Reaper\" submachine gun"
	desc = "Модифицированный вариант пистолета-пулемёта DCA S45 под патрон .45. Перенастроенная автоматика обеспечивает значительно более высокий темп \
			огня за счёт снижения точности. Предназначен для ближнего боя, где плотность огня превалирует над точностью. Официально на рынке не представлен."
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_LOW
	fire_delay = 0.2 SECONDS

/obj/item/gun/projectile/automatic/smg/c20r/auto/get_ru_names()
	return alist(
		NOMINATIVE = "пистолет-пулемёт \"Жнец\"",
		GENITIVE = "пистолета-пулемёта \"Жнец\"",
		DATIVE = "пистолету-пулемёту \"Жнец\"",
		ACCUSATIVE = "пистолет-пулемёт \"Жнец\"",
		INSTRUMENTAL = "пистолетом-пулемётом \"Жнец\"",
		PREPOSITIONAL = "пистолете-пулемёте \"Жнец\"",
	)

/obj/item/gun/projectile/automatic/smg/c20r/rusted
	damage_mod = 0.85
	fire_delay = 0.3 SECONDS

/obj/item/gun/projectile/automatic/smg/c20r/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 10, destroy_max_chance = 3, malf_low_bound = 50, malf_high_bound = 100)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 5, misfire_low_bound = 50, misfire_high_bound = 100)

// MARK: WT550
/obj/item/gun/projectile/automatic/smg/wt550
	name = "WT-550 submachine gun"
	desc = "Компактный пистолет-пулемёт калибра 4,6x30 мм, выпускаемый по лицензии \"Aegis Ordinance\". Поддерживает три режима огня: \
			одиночный, очередь по 2 патрона и автоматический. Имеет три слота под тактические модули. \
			Состоит на вооружении многих корпоративных охранных структур, в том числе \"Нанотрейзен\"."
	icon_state = "wt550"
	item_state = "arg"
	fire_delay = 0.25 SECONDS
	accuracy = GUN_ACCURACY_RIFLE_EXTEND_SPREAD
	mag_type = /obj/item/ammo_box/magazine/wt550m9
	fire_sound = 'sound/weapons/gunshots/1wt.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_amount = 2
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
	return alist(
		NOMINATIVE = "пистолет-пулемёт WT-550",
		GENITIVE = "пистолета-пулемёта WT-550",
		DATIVE = "пистолету-пулемёту WT-550",
		ACCUSATIVE = "пистолет-пулемёт WT-550",
		INSTRUMENTAL = "пистолетом-пулемётом WT-550",
		PREPOSITIONAL = "пистолете-пулемёте WT-550",
	)

/obj/item/gun/projectile/automatic/smg/wt550/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "WT-550 — относительно дешёвый пистолет-пулемёт под патрон 4,6x30 мм, выпускаемый по производственной лицензии \"Aegis Ordinance\". \
		Патент на платформу был зарегистрирован несколько десятилетий назад и с тех пор практически не обновлялся — конструкция считается отработанной \
		и коммерчески незначимой для пересмотра.<br>\
		<br>\
		Переводчик огня обеспечивает выбор между одиночным выстрелом, двухпатронным залпом и автоматическим режимом. \
		Имеет среднюю отдачу и точность по сравнению с аналогами в классе. \
		Совместим со специализированными боеприпасами, включая бронебойные, зажигательные \
		и токсинные варианты.<br>\
		<br>\
		\"Нанотрейзен\", как и ряд других компаний, закупает WT-550 крупными партиями для снабжения службы безопаности удалённых объектов — прежде всего там, \
		где стоимость логистики делает использование более дорогого вооружения нецелесообразным."\
	)

// MARK: DCA S91 Peacekeeper
/obj/item/gun/projectile/automatic/smg/sp91rc
	name = "DCA S91 \"Peacekeeper\" submachine gun"
	desc = "Пистолет-пулемёт калибра .45 N&R производства \"Donk Co. Arms\". Поддерживает три режима огня: \
			одиночный, очередь по 2 патрона и автоматический. Предназначен для нелетального подавления беспорядков."
	icon_state = "sp91"
	item_state = "SP-91-RC"
	accuracy = GUN_ACCURACY_RIFLE_EXTEND_SPREAD
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
	return alist(
		NOMINATIVE = "пистолет-пулемёт DCA S91 \"Миротворец\"",
		GENITIVE = "пистолета-пулемёта DCA S91 \"Миротворец\"",
		DATIVE = "пистолету-пулемёту DCA S91 \"Миротворец\"",
		ACCUSATIVE = "пистолет-пулемёт DCA S91 \"Миротворец\"",
		INSTRUMENTAL = "пистолетом-пулемётом DCA S91 \"Миротворец\"",
		PREPOSITIONAL = "пистолете-пулемёте DCA S91 \"Миротворец\"",
	)

// MARK: A-12 "Sparkle"
/obj/item/gun/projectile/automatic/smg/sparkle_a12
	name = "A-12 \"Sparkle\" submachine gun"
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
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE)
	damage_mod = 0.7
	chambered_light_exists = TRUE
	mag_ammo_counter_exists = TRUE

/obj/item/gun/projectile/automatic/smg/sparkle_a12/get_ru_names()
	return alist(
		NOMINATIVE = "пистолет-пулемёт A-12 \"Искра\"",
		GENITIVE = "пистолета-пулемёта A-12 \"Искра\"",
		DATIVE = "пистолету-пулемёту A-12 \"Искра\"",
		ACCUSATIVE = "пистолет-пулемёт A-12 \"Искра\"",
		INSTRUMENTAL = "пистолетом-пулемётом A-12 \"Искра\"",
		PREPOSITIONAL = "пистолете-пулемёте A-12 \"Искра\"",
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
	fire_delay = 0.2 SECONDS
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_LOW
	weapon_weight = WEAPON_LIGHT

/obj/item/gun/projectile/automatic/smg/mini_uzi/get_ru_names()
	return alist(
		NOMINATIVE = "пистолет-пулемёт Type 3 UZI",
		GENITIVE = "пистолета-пулемёта Type 3 UZI",
		DATIVE = "пистолету-пулемёту Type 3 UZI",
		ACCUSATIVE = "пистолет-пулемёт Type 3 UZI",
		INSTRUMENTAL = "пистолетом-пулемётом Type 3 UZI",
		PREPOSITIONAL = "пистолете-пулемёте Type 3 UZI",
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
	burst_amount = 4
	fire_delay = 0.2 SECONDS
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/tommygun/get_ru_names()
	return alist(
		NOMINATIVE = "пистолет-пулемёт Томсона",
		GENITIVE = "пистолета-пулемёта Томсона",
		DATIVE = "пистолету-пулемёту Томсона",
		ACCUSATIVE = "пистолет-пулемёт Томсона",
		INSTRUMENTAL = "пистолетом-пулемётом Томсона",
		PREPOSITIONAL = "пистолете-пулемёте Томсона",
	)

// MARK: SFG-5
/obj/item/gun/projectile/automatic/smg/sfg
	name = "SFG-5"
	desc = "Современный пистолет-пулемёт калибра 9x19 мм."
	icon_state = "sfg-5"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/sfg9mm
	fire_delay = 0.25 SECONDS
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 17, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 2, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -5),
	)
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/smg/sfg/get_ru_names()
	return alist(
		NOMINATIVE = "пистолет-пулемёт SFG-5",
		GENITIVE = "пистолета-пулемёта SFG-5",
		DATIVE = "пистолету-пулемёту SFG-5",
		ACCUSATIVE = "пистолет-пулемёт SFG-5",
		INSTRUMENTAL = "пистолетом-пулемётом SFG-5",
		PREPOSITIONAL = "пистолете-пулемёте SFG-5",
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
	burst_amount = 5
	fire_delay = 0.2 SECONDS
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 20, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 5, ATTACHMENT_OFFSET_Y = 5),
	)
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/projectile/automatic/smg/ppsh/get_ru_names()
	return alist(
		NOMINATIVE = "пистолет-пулемёт ППШ",
		GENITIVE = "пистолета-пулемёта ППШ",
		DATIVE = "пистолету-пулемёту ППШ",
		ACCUSATIVE = "пистолет-пулемёт ППШ",
		INSTRUMENTAL = "пистолетом-пулемётом ППШ",
		PREPOSITIONAL = "пистолете-пулемёте ППШ",
	)

/obj/item/gun/projectile/automatic/smg/ppsh/rusted
	damage_mod = 0.75

/obj/item/gun/projectile/automatic/smg/ppsh/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 20, destroy_max_chance = 4, malf_low_bound = 15, malf_high_bound = 71)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 15, misfire_low_bound = 30, misfire_high_bound = 71)


// MARK: SMG K-45 Kedr
/obj/item/gun/projectile/automatic/smg/kedr
	name = "SMG K-45"
	desc = "Компактный пистолет-пулемет под калибр 9x19 мм. Оснащён интегрированным глушителем. Пользуется спросом среди наёмников."
	icon_state = "kedr"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/kedr
	fire_sound = 'sound/weapons/gunshots/1wt.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	weapon_weight = WEAPON_LIGHT
	fire_delay = 0.25 SECONDS
	accuracy = GUN_ACCURACY_RIFLE
	recoil = GUN_RECOIL_MEDIUM
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SMG_STOCK
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 33, ATTACHMENT_OFFSET_Y = 3),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 13, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_STOCK = list(ATTACHMENT_OFFSET_X = -5, ATTACHMENT_OFFSET_Y = -1),
	)
	starting_attachment_types = list(/obj/item/gun_module/stock/integrated_kedr)
	chambered_light_exists = TRUE
	mag_ammo_counter_exists = TRUE
	mag_ammo_counter_size = 5

/obj/item/gun/projectile/automatic/smg/kedr/get_ru_names()
	return alist(
		NOMINATIVE = "пистолет-пулемет K-45",
		GENITIVE = "пистолета-пулемёта K-45",
		DATIVE = "пистолету-пулемету K-45",
		ACCUSATIVE = "пистолет-пулемет K-45",
		INSTRUMENTAL = "пистолетом-пулеметом K-45",
		PREPOSITIONAL = "пистолете-пулемете K-45",
	)
