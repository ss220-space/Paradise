// TODO: Merge it with bolt_action_rifles.dm

// MARK: Generic
/obj/item/gun/projectile/automatic/sniper_rifle
	name = "sniper rifle"
	desc = "Крупнокалиберная снайперская винтовка."
	gender = FEMALE
	icon_state = "sniper"
	item_state = "sniper"
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds
	icon = 'icons/obj/weapons/guns_48x32.dmi'
	suppressed_fire_sound = 'sound/weapons/gunshots/snipersupp.ogg'
	fire_sound = 'sound/weapons/gunshots/1sniper.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	fire_delay = 40
	burst_size = 1
	origin_tech = "combat=7"
	can_suppress = TRUE
	slot_flags = ITEM_SLOT_BACK
	actions_types = null
	accuracy = GUN_ACCURACY_SNIPER
	attachable_allowed = GUN_MODULE_CLASS_SNIPER_MUZZLE | GUN_MODULE_CLASS_SNIPER_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 26, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 12, ATTACHMENT_OFFSET_Y = -4),
	)
	recoil = GUN_RECOIL_MEGA
	fire_modes = GUN_MODE_SINGLE_ONLY

/obj/item/gun/projectile/automatic/sniper_rifle/update_icon_state()
	icon_state = base_icon_state

/obj/item/gun/projectile/automatic/sniper_rifle/update_overlays()
	. = ..()
	if(!magazine)
		return
	. += mutable_appearance(icon, "[base_icon_state]_mag", layer = FLOAT_LAYER - 0.01)


// MARK: SGM-HSR-15
/obj/item/gun/projectile/automatic/sniper_rifle/syndicate
	name = "SGM-HSR-15 sniper rifle"
	desc = "Тяжёлая снайперская винтовка калибра .50 производства \"Shellguard Munitions\". Высокая точность, низкая скорострельность \
			и огромная убойная сила. Предназначена для поражения целей на больших дистанциях. Совместима с широким спектром боеприпасов."
	origin_tech = "combat=7;syndicate=6"

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "снайперская винтовка SGM-HSR-15 .50",
		GENITIVE = "снайперской винтовки SGM-HSR-15 .50",
		DATIVE = "снайперской винтовке SGM-HSR-15 .50",
		ACCUSATIVE = "снайперскую винтовку SGM-HSR-15 .50",
		INSTRUMENTAL = "снайперской винтовкой SGM-HSR-15 .50",
		PREPOSITIONAL = "снайперской винтовке SGM-HSR-15 .50",
	)

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Крупнокалиберная снайперская винтовка, разработанная \"Shellguard Munitions\" для задач, требующих максимальной поражающей способности на больших дистанциях.<br>\
		<br>\
		Экстремальная отдача и значительная пауза между выстрелами обуславливается использованием тяжёлого боеприпаса. \
		Камера, спроектированная с увеличенным допуском, позволяет использовать \
		широкий спектр патронов .50: от классических бронебойных и взрывных до узкоспециализированных усыпляющих и кровопускающих.<br>\
		<br>\
		SGM-HSR-15 поставляется ограниченными партиями для ряда ЧВК, силовых структур и индивидуальных заказчиков. По сообщениям некоторых источников, \
		элитные оперативники \"Синдиката\" располагают большим количеством винтовок данной модели, \
		однако \"Shellguard Munitions\" отвергает любые возможные связи с данной организацией."\
	)

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator
	icon_state = "sniperpenetrator"
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds/compact

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator/Initialize(mapload)
	. = ..()

	QDEL_NULL(magazine)
	magazine = new /obj/item/ammo_box/magazine/sniper_rounds/compact/penetrator(src)

// MARK: SGM-HSR-15-С Hornisse
/obj/item/gun/projectile/automatic/sniper_rifle/compact
	name = "SGM-HSR-15-С \"Hornisse\" sniper rifle"
	desc = "Буллпап-конфигурация снайперской винтовки SGM-HSR-15. Использует патроны калибра .50L. Автоматика, \
			оптимизированная под патрон уменьшенной мощности и перенос магазина за пистолетную рукоять делают \
			эту винтовку пригодной для боя на коротких дистанциях."
	icon_state = "snipercompact"
	weapon_weight = WEAPON_LIGHT
	fire_delay = 2 SECONDS
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds/compact
	accuracy = GUN_ACCURACY_SNIPER
	recoil = GUN_RECOIL_HIGH
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 21, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -4),
	)

/obj/item/gun/projectile/automatic/sniper_rifle/compact/get_ru_names()
	return list(
		NOMINATIVE = "снайперская винтовка SGM-HSR-15-С \"Шершень\" .50L",
		GENITIVE = "снайперской винтовки SGM-HSR-15-С \"Шершень\" .50L",
		DATIVE = "снайперской винтовке SGM-HSR-15-С \"Шершень\" .50L",
		ACCUSATIVE = "снайперскую винтовку SGM-HSR-15-С \"Шершень\" .50L",
		INSTRUMENTAL = "снайперской винтовкой SGM-HSR-15-С \"Шершень\" .50L",
		PREPOSITIONAL = "снайперской винтовке SGM-HSR-15-С \"Шершень\" .50L",
	)

/obj/item/gun/projectile/automatic/sniper_rifle/compact/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "SGM-HSR-15C представляет собой глубокую переработку снайперской платформы SGM-HSR-15 производства \"Shellguard Munitions\", \
		выполненную инженерами \"Синдиката\" для нужд оперативных групп. Цель — сохранить поражающую способность базовой модели при радикальном сокращении габаритов.<br>\
		<br>\
		Решением стала конвертация компоновки в буллпап: магазин и затворная группа перенесены за пистолетную рукоять, \
		что позволило сохранить длину ствола при значительно меньшей общей длине оружия. \
		Питание осуществляется патроном .50L — ослабленной версией .50 с меньшим пороховым зарядом. Такая конструкция позволила значительно снизить отдачу и повысить \
		скорострельность, лишь незначительно потеряв в убойной силе и пробивной способности. Для повышения эргономики и габаритов ствол был укорочен, \
		а приклад заменён на облегчённую версию.<br>\
		<br>\
		Данная модель не была замечена на открытых рынках или в использовании представителями какой-либо организации. \
		По информации из разрозненных источников, \"Синдикат\" производит \"Шершней\" сугубо для внутреннего пользования."\
	)

// MARK: AXMC
/obj/item/gun/projectile/automatic/sniper_rifle/axmc
	name = "axmc sniper rifle"
	desc = "Тяжёлая снайперская винтовка калибра .338."
	icon_state = "axmc"
	item_state = "AXMC"
	mag_type = /obj/item/ammo_box/magazine/a338
	fire_delay = 5.5 SECONDS
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 36, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = 6),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 17, ATTACHMENT_OFFSET_Y = -4),
	)

/obj/item/gun/projectile/automatic/sniper_rifle/axmc/get_ru_names()
	return list(
		NOMINATIVE = "снайперская винтовка AXMC .338",
		GENITIVE = "снайперской винтовки AXMC .338",
		DATIVE = "снайперской винтовке AXMC .338",
		ACCUSATIVE = "снайперскую винтовку AXMC .338",
		INSTRUMENTAL = "снайперской винтовкой AXMC .338",
		PREPOSITIONAL = "снайперской винтовке AXMC .338",
	)
