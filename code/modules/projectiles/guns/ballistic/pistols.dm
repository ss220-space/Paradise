// MARK: Base Pistol
/obj/item/gun/projectile/automatic/pistol
	gender = MALE
	can_holster = TRUE
	recoil = GUN_RECOIL_LOW
	origin_tech = "combat=3;materials=2"
	magin_sound = 'sound/weapons/gun_interactions/pistol_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/pistol_magout.ogg'
	burst_size = 1
	fire_delay = 0
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_PISTOL_UNDER
	fire_modes = GUN_MODE_SINGLE_ONLY

/obj/item/gun/projectile/automatic/pistol/update_icon_state()
	if(current_skin)
		icon_state = "[current_skin][chambered ? "" : "-e"]"
	else
		icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

// MARK: DCA-P9 Enforcer
/obj/item/gun/projectile/automatic/pistol/enforcer
	name = "DCA-P9 \"Enforcer\" pistol"
	desc = "Сбалансированный пистолет калибра 9x19 мм. Хорошая эргономика, низкая отдача, высокая точность. \
			Произведён \"Donc Co. Arms\", используется службой безопасности \"Нанотрейзен\"."
	icon_state = "enforcer_grey"
	force = 10
	mag_type = /obj/item/ammo_box/magazine/enforcer
	fire_sound = 'sound/weapons/gunshots/1colt.ogg'
	accuracy = GUN_ACCURACY_PISTOL_ENFORCER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 18, ATTACHMENT_OFFSET_Y = 4),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = -2, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -3),
	)
	origin_tech = "combat=4;materials=2"

/obj/item/gun/projectile/automatic/pistol/enforcer/get_ru_names()
	return list(
		NOMINATIVE = "пистолет DCA-P9 \"Блюститель\" 9x19 мм",
		GENITIVE = "пистолета DCA-P9 \"Блюститель\" 9x19 мм",
		DATIVE = "пистолету DCA-P9 \"Блюститель\" 9x19 мм",
		ACCUSATIVE = "пистолет DCA-P9 \"Блюститель\" 9x19 мм",
		INSTRUMENTAL = "пистолетом DCA-P9 \"Блюститель\" 9x19 мм",
		PREPOSITIONAL = "пистолете DCA-P9 \"Блюститель\" 9x19 мм",
	)

/obj/item/gun/projectile/automatic/pistol/enforcer/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Лёгкий пистолет под стандартный калибр 9x19 мм. Разработан компанией \"Donk Co. Arms\" в рамках \
		открытого тендера на оснащение корпоративных служб безопасности. <br>\
		<br>\
		Конструкция сочетает в себе проверенные технологические решения с современными материалами: полимерная рамка \
		со стальными вкладышами, укороченный ход затвора для снижения отдачи, модульные направляющие для использования \
		тактических приспособлений.<br>\
		<br>\
		В 2556 году \"Нанотрейзен\" заключила долгосрочный контракт с \"Donk Co. Arms\" на массовую поставку \
		DCA-P9 в целях замены разрозненных моделей пистолетов, использовавшихся силами корпорации \
		В настоящее время \"Блюстители\" остаются основным штатным оружием сотрудников службы безопасности \"Нанотрейзен\", \
		повсеместно встречаясь даже на самых удалённых объектах корпорации."\
	)

/obj/item/gun/projectile/automatic/pistol/enforcer/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins, item_path = /obj/item/gun/projectile/automatic/pistol/enforcer)

/obj/item/gun/projectile/automatic/pistol/enforcer/lethal
	mag_type = /obj/item/ammo_box/magazine/enforcer/lethal

// MARK: P40-E Acer
/obj/item/gun/projectile/automatic/pistol/sp8
	name = "P40-E \"Acer\" pistol"
	desc = "Штурмовой пистолет под патрон .40 N&R производства \"Mars Special\". Высокая точность, низкая отдача и усиленный ствол \
			для стрельбы боеприпасами повышенной мощности. Используется элитными подразделениями сил защиты активов \"Нанотрейзен\"."
	icon_state = "sp8_black"
	force = 10
	mag_type = /obj/item/ammo_box/magazine/sp8
	fire_sound = 'sound/weapons/gunshots/sp8.ogg'
	origin_tech = "combat=5;materials=2"
	accuracy = GUN_ACCURACY_PISTOL_UPLINK
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = -2, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = -2),
	)

/obj/item/gun/projectile/automatic/pistol/sp8/get_ru_names()
	return list(
		NOMINATIVE = "пистолет P40-E \"Эйсер\" .40 N&R",
		GENITIVE = "пистолета P40-E \"Эйсер\" .40 N&R",
		DATIVE = "пистолету P40-E \"Эйсер\" .40 N&R",
		ACCUSATIVE = "пистолет P40-E \"Эйсер\" .40 N&R",
		INSTRUMENTAL = "пистолетом P40-E \"Эйсер\" .40 N&R",
		PREPOSITIONAL = "пистолете P40-E \"Эйсер\" .40 N&R",
	)

/obj/item/gun/projectile/automatic/pistol/sp8/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "P40-E \"Эйсер\" — штурмовой пистолет под патрон .40 N&R, разработанный \"Mars Special\" по прямому заказу \
		\"Нанотрейзен\" для оснащения элитных подразделений.<br>\
		<br>\
		Калибр .40 N&R обеспечивает баланс между останавливающим действием и управляемостью при низкой отдаче. Три слота \
		под тактические модули позволяют адаптировать оружие под конкретную задачу.<br>\
		<br>\
		В открытую продажу не поступает. Доступ к \"Эйсеру\" имеют только подразделения \"Нанотрейзен\", ряд союзных \
		ЧВК и единичные подразделения спецназа ТСФ."\
	)

/obj/item/gun/projectile/automatic/pistol/sp8/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

// MARK: Stechkin
/obj/item/gun/projectile/automatic/pistol/stechkin
	name = "Stechkin pistol"
	desc = "Компактный пистолет калибра 10x25 мм, собранный по открытой схеме из библиотеки \"Canon de Frontira\". Имеет два слота под \
			тактические модули, а также совместим с широким спектром специальных боеприпасов. Встречается повсеместно — от гражданского рынка до криминальных структур."
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=3;materials=2;syndicate=1"
	fire_sound = 'sound/weapons/gunshots/1stechkin.ogg'
	accuracy = GUN_ACCURACY_PISTOL_STECHKIN
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_PISTOL_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = 3),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 1, ATTACHMENT_OFFSET_Y = 7),
	)

/obj/item/gun/projectile/automatic/pistol/stechkin/get_ru_names()
	return list(
		NOMINATIVE = "пистолет \"Стечкин\" 10x25 мм",
		GENITIVE = "пистолета \"Стечкин\" 10x25 мм",
		DATIVE = "пистолету \"Стечкин\" 10x25 мм",
		ACCUSATIVE = "пистолет \"Стечкин\" 10x25 мм",
		INSTRUMENTAL = "пистолетом \"Стечкин\" 10x25 мм",
		PREPOSITIONAL = "пистолете \"Стечкин\" 10x25 мм",
	)

/obj/item/gun/projectile/automatic/pistol/stechkin/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Схема пистолета под патрон 10x25 мм давно осела в открытой библиотеке \"Canon de Frontira\" и с тех пор \
		воспроизводится всеми, у кого есть доступ к базовому производственному оборудованию. Народное прозвище \"Стечкин\" \
		прикрепилось к платформе так давно, что оригинальный смысл этого названия канул в лету.<br>\
		<br>\
		Низкая цена сборки, малые габариты, и доступные повсеместно патроны калибра 10x25 мм во множестиве вариаций делают его \
		востребованным как на гражданском рынке, так и вооружённых структур разной степени легальности."\
	)

// MARK: SGM-P Colossus
/obj/item/gun/projectile/automatic/pistol/deagle
	name = "SGM-P \"Colossus\""
	desc = "Тяжёлый пистолет калибра .50 AE производства \"Shellguard Munitions\". Патроны имеют огромную останавливающую силу, \
			ценой которой служит значительная отдача и малый магазин. Один из самых мощных пистолетов в классе."
	icon_state = "deagle"
	force = 14.0
	mag_type = /obj/item/ammo_box/magazine/m50
	fire_sound = 'sound/weapons/gunshots/1deagle.ogg'
	magin_sound = 'sound/weapons/gun_interactions/hpistol_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/hpistol_magout.ogg'
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 20, ATTACHMENT_OFFSET_Y = 4),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = -2),
	)
	accuracy = GUN_ACCURACY_PISTOL_UPLINK
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/projectile/automatic/pistol/deagle/get_ru_names()
	return list(
		NOMINATIVE = "пистолет SGM-P \"Колосс\" .50 AE",
		GENITIVE = "пистолета SGM-P \"Колосс\" .50 AE",
		DATIVE = "пистолету SGM-P \"Колосс\" .50 AE",
		ACCUSATIVE = "пистолет SGM-P \"Колосс\" .50 AE",
		INSTRUMENTAL = "пистолетом SGM-P \"Колосс\" .50 AE",
		PREPOSITIONAL = "пистолете SGM-P \"Колосс\" .50 AE",
	)

/obj/item/gun/projectile/automatic/pistol/deagle/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

// MARK: APS Pistol
/obj/item/gun/projectile/automatic/pistol/APS
	name = "stechkin APS pistol"
	desc = "Старинный пистолет калибра 9x19 мм. Стреляет очередями."
	icon_state = "aps"
	mag_type = /obj/item/ammo_box/magazine/pistolm9mm
	burst_size = 3
	fire_delay = 2
	accuracy = GUN_ACCURACY_PISTOL_UPLINK
	recoil = GUN_RECOIL_MEDIUM
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_PISTOL_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 18, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 3, ATTACHMENT_OFFSET_Y = 8),
	)
	fire_modes = GUN_MODE_SINGLE_BURST_AUTO

/obj/item/gun/projectile/automatic/pistol/APS/get_ru_names()
	return list(
		NOMINATIVE = "пистолет АПС 9x19 мм",
		GENITIVE = "пистолета АПС 9x19 мм",
		DATIVE = "пистолету АПС 9x19 мм",
		ACCUSATIVE = "пистолет АПС 9x19 мм",
		INSTRUMENTAL = "пистолетом АПС 9x19 мм",
		PREPOSITIONAL = "пистолете АПС 9x19 мм",
	)

// MARK: M1911
/obj/item/gun/projectile/automatic/pistol/m1911
	name = "M1911"
	desc = "Классический пистолет калибра .45 с малой ёмкостью магазина. Низкая отдача, высокая останавливающая сила, простота в обслуживании. \
			Конструкция, проверенная временем."
	icon_state = "m1911"
	mag_type = /obj/item/ammo_box/magazine/m45
	fire_sound = 'sound/weapons/gunshots/1colt.ogg'
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 21, ATTACHMENT_OFFSET_Y = 6),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 9),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -1),
	)

/obj/item/gun/projectile/automatic/pistol/m1911/get_ru_names()
	return list(
		NOMINATIVE = "пистолет M1911 .45",
		GENITIVE = "пистолета M1911 .45",
		DATIVE = "пистолету M1911 .45",
		ACCUSATIVE = "пистолет M1911 .45",
		INSTRUMENTAL = "пистолетом M1911 .45",
		PREPOSITIONAL = "пистолете M1911 .45",
	)
