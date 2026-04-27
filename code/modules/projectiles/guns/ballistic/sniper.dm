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

// MARK: SG-HSR-15
/obj/item/gun/projectile/automatic/sniper_rifle/syndicate
	name = "SG-HSR-15 sniper rifle"
	desc = "Тяжёлая снайперская винтовка калибра .50 производства \"Shellguard Munitions\". Высокая точность, низкая скорострельность \
			и огромная убойная сила. Предназначена для поражения целей на больших дистанциях. Совместима с широким спектром боеприпасов."
	origin_tech = "combat=7;syndicate=6"

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "снайперская винтовка SG-HSR-15 .50",
		GENITIVE = "снайперской винтовки SG-HSR-15 .50",
		DATIVE = "снайперской винтовке SG-HSR-15 .50",
		ACCUSATIVE = "снайперскую винтовку SG-HSR-15 .50",
		INSTRUMENTAL = "снайперской винтовкой SG-HSR-15 .50",
		PREPOSITIONAL = "снайперской винтовке SG-HSR-15 .50",
	)

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Крупнокалиберная снайперская винтовка, разработанная для задач, требующих максимальной поражающей способности на больших дистанциях.<br>\
		<br>\
		Холоднокованный ствол с хромированным каналом гарантирует высокую точность на огромных дистанциях. Экстремальная отдача и значительная пауза \
		между выстрелами обуславливается использованием тяжёлого боеприпаса. Камера, спроектированная с увеличенным допуском, позволяет использовать \
		широкий спектр боеприпасов .50: от классических бронебойных и взрывных до узкоспециализированных усыпляющих и кровопускающих.<br>\
		<br>\
		Винтовка поставляется ограниченными партиями для ряда ЧВК, силовых структур и индивидуальных заказчиков. По ограниченным данным, \"Shellguard Munitions\"\
		имеет специальный контракт с \"Синдикатом\" на поставку данной модели, однако достоверность этих сведений многими подвергается сомнению."\
	)

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator
	icon_state = "sniperpenetrator"
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds/compact

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator/Initialize(mapload)
	. = ..()

	QDEL_NULL(magazine)
	magazine = new /obj/item/ammo_box/magazine/sniper_rounds/compact/penetrator(src)

// MARK: Compact Syndicate SR
/obj/item/gun/projectile/automatic/sniper_rifle/compact
	name = "SG-HSR-15C sniper rifle"
	desc = "Модифицированная версия снайперской винтовки SG-HSR-15. Использует патроны калибра .50L. Автоматика, \
			оптимизированная под патрон уменьшенной мощности и укороченный ствол делают эту винтовку пригодной для боя на коротких дистанциях."
	icon_state = "snipercompact"
	weapon_weight = WEAPON_LIGHT
	fire_delay = 2 SECONDS
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds/compact
	accuracy = GUN_ACCURACY_SNIPER
	recoil = GUN_RECOIL_HIGH
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 21, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 12, ATTACHMENT_OFFSET_Y = -4),
	)

/obj/item/gun/projectile/automatic/sniper_rifle/compact/get_ru_names()
	return list(
		NOMINATIVE = "снайперская винтовка SG-HSR-15C \"Оса\" .50L",
		GENITIVE = "снайперской винтовки SG-HSR-15C \"Оса\" .50L",
		DATIVE = "снайперской винтовке SG-HSR-15C \"Оса\" .50L",
		ACCUSATIVE = "снайперскую винтовку SG-HSR-15C \"Оса\" .50L",
		INSTRUMENTAL = "снайперской винтовкой SG-HSR-15C \"Оса\" .50L",
		PREPOSITIONAL = "снайперской винтовке SG-HSR-15C \"Оса\" .50L",
	)

/obj/item/gun/projectile/automatic/sniper_rifle/compact/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Адаптированная инженерами \"Синдиката\" винтовка модели SG-HSR-15 производства \"Shellguard Munitions\". \
		Причиной разработки данной модификации стала нужда в компактном и смертоносном оружии, пригодном как для близких, так и дальних дистанций.<br>\
		<br>\
		Винтовка использует боеприпасы калибра .50L — вариация патронов .50 уменьшенной мощности. Это позволило значительно снизить отдачу и повысить \
		скорострельность, лишь незначительно потеряв в убойной силе и пробивной способности. Для повышения эргономики и габаритов ствол был укорочен, \
		а приклад заменён на облегчённую версию.<br>\
		<br>\
		Данная модель не была замечена на открытых рынках или в использовании представителями какой-либо организации. \
		По информации из разрозненных источников, \"Синдикат\" производит эту модель сугубо для внутреннего пользования."\
	)

// MARK: AXMC
/obj/item/gun/projectile/automatic/sniper_rifle/axmc
	name = "axmc sniper rifle"
	desc = "Снайперская винтовка калибра .338, разработанная и изготовленная одной из дочерних компаний \"Нанотрейзен\"."
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "AXMC"
	item_state = "AXMC"
	mag_type = /obj/item/ammo_box/magazine/a338
	fire_delay = 5.5 SECONDS
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/projectile/automatic/sniper_rifle/axmc/get_ru_names()
	return list(
		NOMINATIVE = "снайперская винтовка AXMC .338",
		GENITIVE = "снайперской винтовки AXMC .338",
		DATIVE = "снайперской винтовке AXMC .338",
		ACCUSATIVE = "снайперскую винтовку AXMC .338",
		INSTRUMENTAL = "снайперской винтовкой AXMC .338",
		PREPOSITIONAL = "снайперской винтовке AXMC .338",
	)

/obj/item/gun/projectile/automatic/sniper_rifle/axmc/attackby(obj/item/item, mob/user, params)
	//TODO: remove it after normal sprite for AXMC
	if(istype(item, /obj/item/gun_module/muzzle/suppressor))
		add_fingerprint(user)
		var/obj/item/gun_module/muzzle/suppressor/suppressor = item
		if(!can_suppress)
			balloon_alert(user, "несовместимо!")
			return ATTACK_CHAIN_PROCEED
		if(suppressed)
			balloon_alert(user, "уже установлено!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(suppressor, src))
			return ..()
		balloon_alert(user, "установлено")
		playsound(loc, 'sound/items/screwdriver.ogg', 40, TRUE)
		suppressed = suppressor
		suppressor.oldsound = fire_sound
		suppressor.initial_w_class = w_class
		fire_sound = 'sound/weapons/gunshots/1suppres.ogg'
		w_class = WEIGHT_CLASS_NORMAL //so pistols do not fit in pockets when suppressed
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/item/gun/projectile/automatic/sniper_rifle/axmc/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "-mag" : ""][suppressed ? "-suppressed" : ""]"
