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
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

// MARK: Stechkin
/obj/item/gun/projectile/automatic/pistol/stechkin
	name = "Stechkin pistol"
	desc = "Компактный пистолет калибра 10x25 мм. Отличается малыми габаритами и высокой огневой мощью для своего класса. \
			Благодаря простоте конструкции и массовости производства \"Стечкины\" в различных модификациях \
			встречаются по всей Галактике. Производитель данного экземпляра неизвестен."
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
		lore = "Один из самых массовых пистолетов Галактики. По слухам, оригинальная конструкция была разработана в начале века, \
		но после утечки чертежей в открытый доступ производство было запущено сотнями предприятий — от лицензированных заводов до \
		подпольных мастерских.<br>\
		<br>\
		Массовость данного пистолета объясняется рядом причин:<br>\
		1. Простота и надёжность конструкции.<br>\
		2. Предельная дешевизна производства.<br>\
		3. Высокая модульность и совместимость с широким спектром боеприпасов.<br>\
		<br>\
		Именно поэтому \"Стечкин\" пользуется высоким спросом как у гражданских лиц, которым нужно дешёвое оружие для самозащиты, \
		так и у корпоративных наёмников, ценящих модульное и легко маскируемое оружие."\
	)

// MARK: M1911
/obj/item/gun/projectile/automatic/pistol/m1911
	name = "M1911"
	desc = "Классический пистолет калибра .45 с малой ёмкостью магазина. \
			Низкая отдача, высокая останавливающая сила, простота в обслуживании. \
			Проверенная временем конструкция, которую легко модифицировать под свои нужды."
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

// MARK: Enforcer
/obj/item/gun/projectile/automatic/pistol/enforcer
	name = "P-9 \"Enforcer\""
	desc = "Сбалансированный пистолет калибра 9x19 мм. Хорошая эргономика, низкая отдача, высокая точность. \
			Произведён \"Нанотрейзен\" для использования корпоративной службой безопасности."
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
		NOMINATIVE = "пистолет П-9 \"Блюститель\" 9x19 мм",
		GENITIVE = "пистолета П-9 \"Блюститель\" 9x19 мм",
		DATIVE = "пистолету П-9 \"Блюститель\" 9x19 мм",
		ACCUSATIVE = "пистолет П-9 \"Блюститель\" 9x19 мм",
		INSTRUMENTAL = "пистолетом П-9 \"Блюститель\" 9x19 мм",
		PREPOSITIONAL = "пистолете П-9 \"Блюститель\" 9x19 мм",
	)

/obj/item/gun/projectile/automatic/pistol/enforcer/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Стандартное личное оружие сотрудников службы безопасности \"Нанотрейзен\". \
		Разработан и принят на вооружение в 2556 году для замены разрозненных моделей пистолетов, использовавшихся силами корпорации.<br>\
		<br>\
		Конструкция сочетает в себе проверенные технологические решения с современными материалами: полимерная рамка \
		со стальными вкладышами, укороченный ход затвора для снижения отдачи, модульные направляющие для использования \
		тактических приспособлений.<br>\
		<br>\
		\"Блюститель\" производится на внутренних мощностях \"Нанотрейзен\" уже второе десятилетие. \
		Стандартизированность и относительно невысокая стоимость производства обеспечивают стабильность поставок даже \
		на самые удалённые объекты."\
	)

/obj/item/gun/projectile/automatic/pistol/enforcer/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins, item_path = /obj/item/gun/projectile/automatic/pistol/enforcer)

/obj/item/gun/projectile/automatic/pistol/enforcer/update_icon_state()
	if(current_skin)
		icon_state = "[current_skin][chambered ? "" : "-e"]"
	else
		icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/pistol/enforcer/lethal
	mag_type = /obj/item/ammo_box/magazine/enforcer/lethal

// MARK: MS-P40-E
/obj/item/gun/projectile/automatic/pistol/sp8
	name = "MS-P40-E pistol"
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
		NOMINATIVE = "пистолет MS-P40-E .40 N&R",
		GENITIVE = "пистолета MS-P40-E .40 N&R",
		DATIVE = "пистолету MS-P40-E .40 N&R",
		ACCUSATIVE = "пистолет MS-P40-E .40 N&R",
		INSTRUMENTAL = "пистолетом MS-P40-E .40 N&R",
		PREPOSITIONAL = "пистолете MS-P40-E .40 N&R",
	)

/obj/item/gun/projectile/automatic/pistol/sp8/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Флагманский пистолет новейшей серии. Разработан в 2567 году по прямому заказу \"Нанотреййзен\" \
		для модернизации личного вооружения элитных подразделений.<br>\
		<br>\
		Использование калибра .40 N&R предоставляет иделальный баланс между останавливающей способностью и управляемостью. \
		Использование композитных сплавов нового поколения позволило значительно снизить вес пистолета и повысить эргономику \
		без потери удобства.<br>\
		<br>\
		MS-P40-E не поставляется в открытую продажу. Доступ к нему имеют только позразделения \"Нанотрейзен\", ряд союзных ЧВК и \
		единичные подразделения спецназа ТСФ."\
	)

/obj/item/gun/projectile/automatic/pistol/sp8/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

/obj/item/gun/projectile/automatic/pistol/sp8/update_icon_state()
	if(current_skin)
		icon_state = "[current_skin][chambered ? "" : "-e"]"
	else
		icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/pistol/sp8/sp8t
	name = "MS-P40-ET pistol"
	icon_state = "sp8t_dust"
	fire_sound = 'sound/weapons/gunshots/sp8t.ogg'
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_PISTOL_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = -2, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = -2),
	)

/obj/item/gun/projectile/automatic/pistol/sp8/sp8t/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

/obj/item/gun/projectile/automatic/pistol/sp8/sp8ar
	name = "MS-P40-EAR pistol"
	icon_state = "sp8ar"
	fire_sound = 'sound/weapons/gunshots/sp8ar.ogg'
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_PISTOL_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = -2, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = -2),
	)

// MARK: SGM-P "Colossus"
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

/obj/item/gun/projectile/automatic/pistol/deagle/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Ответ \"Shellguard Munitions\" на запрос рынка о необходимости компактного оружия против тяжёлых целей.<br>\
		<br>\
		В основе лежит схема газоотвода, заимствованная из винтовочных систем, \
		что позволяет снизить вес конструкции по сравнению с чисто ударными механизмами аналогичного калибра. \
		Ствол хромирован для увеличения ресурса работы. Рамка выполнена из титанового сплава с полимерными вставками для гашения вибраций. \
		Благодаря использования патронов .50 AE, \"Колосс\" обладает огромной останавливающей силой. Однако цена этой мощи — высокая отдача, \
		низкая скорострельность и малый магазин на 7 патронов.<br>\
		<br>\
		\"Колосс\" не предназначен для массовой закупки. Это специализированный оружие, используемое для задач, где нужна предельная \
		огневая мощь вкупе с компактностью. Благодаря этому он не сыскал популярности у стандартизированных силовых подразделений Галактики, \
		но стал популярным инструментом среди элитных наёмников."\
	)

/obj/item/gun/projectile/automatic/pistol/deagle/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"

/obj/item/gun/projectile/automatic/pistol/deagle/gold
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/gun/projectile/automatic/pistol/deagle/camo
	icon_state = "deaglecamo"
	item_state = "deagleg"

// MARK: APS Pistol
/obj/item/gun/projectile/automatic/pistol/APS
	name = "stechkin APS pistol"
	desc = "Советский пистолет калибра 9x19 мм. Стреляет очередями. Произведён в СССП для использования вооружёнными силами."
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
