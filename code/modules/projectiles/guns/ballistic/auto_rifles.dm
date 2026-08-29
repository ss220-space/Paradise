// MARK: AR-30 "Regula"
/obj/item/gun/projectile/automatic/arg
	name = "AR-30 \"Regula\" assault rifle"
	desc = "Штурмовая винтовка калибра 5,56x45 мм производства \"Mars Special\" — штатное вооружение вооружённых сил Транс-солнечной Федерации. \
			Высокая точность и управляемая отдача."
	gender = FEMALE
	icon_state = "arg"
	item_state = "arg"
	slot_flags = 0
	origin_tech = "combat=6;engineering=4"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	fire_delay = 0.2 SECONDS
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 21, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 3, ATTACHMENT_OFFSET_Y = 6),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -5),
	)
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/arg/get_ru_names()
	return alist(
		NOMINATIVE = "штурмовая винтовка AR-30 \"Регула\"",
		GENITIVE = "штурмовой винтовки AR-30 \"Регула\"",
		DATIVE = "штурмовой винтовке AR-30 \"Регула\"",
		ACCUSATIVE = "штурмовую винтовку AR-30 \"Регула\"",
		INSTRUMENTAL = "штурмовой винтовкой AR-30 \"Регула\"",
		PREPOSITIONAL = "штурмовой винтовке AR-30 \"Регула\"",
	)

// MARK: M-90GL Carbine
/obj/item/gun/projectile/automatic/m90
	name = "M-90GL Carbine"
	desc = "Карабин калибра 5,56x45 мм, выпускаемый по лицензии \"Aegis Ordinance\". \
			Оснащён встроенным подствольным гранатомётом."
	icon_state = "m90"
	item_state = "m90-4"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = TRUE
	fire_delay = 0.2 SECONDS
	accuracy = GUN_ACCURACY_RIFLE_UPLINK
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 18, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 12, ATTACHMENT_OFFSET_Y = 7),
	)
	recoil = GUN_RECOIL_MEDIUM
	starting_attachment_types = list(/obj/item/gun_module/under/gun/grenade_launcher/integrated)

/obj/item/gun/projectile/automatic/m90/get_ru_names()
	return alist(
		NOMINATIVE = "карабин M-90GL",
		GENITIVE = "карабина M-90GL",
		DATIVE = "карабину M-90GL",
		ACCUSATIVE = "карабин M-90GL",
		INSTRUMENTAL = "карабином M-90GL",
		PREPOSITIONAL = "карабине M-90GL",
	)

/obj/item/gun/projectile/automatic/m90/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"
	if(magazine)
		item_state = "m90-[ceil(get_ammo(FALSE)/7.5)]"
	else
		item_state = "m90-0"

/obj/item/gun/projectile/automatic/m90/update_overlays()
	. = ..()
	if(magazine)
		. += image(icon = icon, icon_state = "m90-[ceil(get_ammo(FALSE)/6)*6]")
	switch(gun_firemode)
		if(GUN_FIREMODE_SEMIAUTO)
			. += "[initial(icon_state)]gren"
		if(GUN_FIREMODE_BURSTFIRE)
			.  += "[initial(icon_state)]burst"

/obj/item/gun/projectile/automatic/m90/rusted
	damage_mod = 0.85
	fire_delay = 0.3 SECONDS
	starting_attachment_types = list(/obj/item/gun_module/under/gun/grenade_launcher/integrated/unloaded)

/obj/item/gun/projectile/automatic/m90/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 10, destroy_max_chance = 3, malf_low_bound = 50, malf_high_bound = 100)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 5, misfire_low_bound = 50, misfire_high_bound = 100)

// MARK: AG-814
/obj/item/gun/projectile/automatic/ak814
	name = "AG-814 assault rifle"
	desc = "\"Автомат Грызова 814\" — штурмовая винтовка 5,45x39 мм производства \"Волкодав\", штатное вооружение армии СССП. \
			Высокая надёжность и убойность в сочетании с низкой стоимостью производства делают его основой пехотного арсенала \
			Советских сил. Эталон советской оружейной доктрины."
	gender = MALE
	icon_state = "ak814"
	item_state = "ak814"
	origin_tech = "combat=5;materials=3"
	mag_type = /obj/item/ammo_box/magazine/ak814
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_amount = 2
	fire_delay = 0.2 SECONDS
	accuracy = GUN_ACCURACY_RIFLE
	fire_delay = 0.2 SECONDS
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 21, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 5, ATTACHMENT_OFFSET_Y = 6),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = -5),
	)
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/ak814/get_ru_names()
	return alist(
		NOMINATIVE = "автомат АГ-814",
		GENITIVE = "автомата АГ-814",
		DATIVE = "автомату АГ-814",
		ACCUSATIVE = "автомат АГ-814",
		INSTRUMENTAL = "автоматом АГ-814",
		PREPOSITIONAL = "автомате АГ-814",
	)

/obj/item/gun/projectile/automatic/ak814/weakened
	desc = "Импортная версия штурмовой винтовки AГ-814, использующая уменьшенные магазины."
	mag_type = /obj/item/ammo_box/magazine/ak814/fusty
	fire_delay = 0.25 SECONDS

// MARK: AGS74-U
/obj/item/gun/projectile/automatic/aks74u
	name = "AGS74-U assault rifle"
	desc = "Укороченная версия автомата Грызова под калибр 5,45x39 мм."
	gender = MALE
	icon_state = "aksu"
	item_state = "aksu"
	origin_tech = "combat=4;materials=3"
	mag_type = /obj/item/ammo_box/magazine/aks74u
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	slot_flags = ITEM_SLOT_BACK
	fire_delay = 0.2 SECONDS
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 19, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 2, ATTACHMENT_OFFSET_Y = 6),
	)
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/aks74u/get_ru_names()
	return alist(
		NOMINATIVE = "автомат АГС74-У",
		GENITIVE = "автомата АГС74-У",
		DATIVE = "автомату АГС74-У",
		ACCUSATIVE = "автомат АГС74-У",
		INSTRUMENTAL = "автоматом АГС74-У",
		PREPOSITIONAL = "автомате АГС74-У",
	)

/obj/item/gun/projectile/automatic/aks74u/rusted
	damage_mod = 0.75
	fire_delay = 0.3 SECONDS

/obj/item/gun/projectile/automatic/aks74u/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 25, destroy_max_chance = 5, malf_low_bound = 10, malf_high_bound = 30)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 15, misfire_low_bound = 10, misfire_high_bound = 30)

// MARK: SGM-BR52
/obj/item/gun/projectile/automatic/m52
	name = "SGM-BR52 battle rifle"
	desc = "Боевая винтовка калибра 7,62x51 мм производства \"Shellguard Munitions\". \
			Высокая точность и впечатляющая огневая мощь делают её эффективной против живой силы в тяжёлом снаряжении. \
			Состоит на вооружении подразделений быстрого реагирования \"Нанотрейзен\"."
	gender = FEMALE
	icon_state = "M52"
	item_state = "arg"
	fire_sound = 'sound/weapons/gunshots/aussec.ogg'
	mag_type = /obj/item/ammo_box/magazine/m52mag
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 20, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 2, ATTACHMENT_OFFSET_Y = 9),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = -7),
	)
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/m52/get_ru_names()
	return alist(
		NOMINATIVE = "боевая винтовка SGM-BR52",
		GENITIVE = "боевой винтовки SGM-BR52",
		DATIVE = "боевой винтовке SGM-BR52",
		ACCUSATIVE = "боевую винтовку SGM-BR52",
		INSTRUMENTAL = "боевой винтовкой SGM-BR52",
		PREPOSITIONAL = "боевой винтовке SGM-BR52",
	)

/obj/item/gun/projectile/automatic/m52/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "SGM-BR52 — боевая винтовка под винтовочный патрон 7,62x51 мм, разработанная \"Shellguard Munitions\" \
		для рынка корпоративных и частных силовых структур, которым недостаточно стандартных армейских платформ. \
		Создавалась как инструмент поражения живой силы в тяжёлом снаряжении и за лёгкими укрытиями.<br>\
		<br>\
		Массивная затворная группа и удлинённый ствол под мощный патрон 7,62x51 мм обеспечивают высокую точность и убойность \
		на дистанции, недоступной стандартным штурмовым винтовкам. Управляемая для своего класса отдача достигается за счёт \
		значительной массы оружия.<br>\
		<br>\
		Среди корпоративных заказчиков SGM-BR52 не снискала широкой популярности — высокая масса и избыточная для большинства \
		сценариев мощность ограничивают круг применения. Тем не менее, \"Нанотрейзен\" закупила партию данных винтовок для оснащения \
		подразделений быстрого реагирования."\
	)

// MARK: IK-60
/obj/item/gun/projectile/automatic/ik60
	name = "IK-60 Laser Carbine"
	desc = "Укороченная винтовка с магазинным питанием, использующая специализированные патроны для стрельбы лазеро-подобными снарядами."
	gender = MALE
	icon_state = "lasercarbine"
	item_state = "laser"
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/ik60mag
	fire_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_amount = 2
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 3, ATTACHMENT_OFFSET_Y = 6),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = -4),
	)
	recoil = GUN_RECOIL_MIN

/obj/item/gun/projectile/automatic/ik60/get_ru_names()
	return alist(
		NOMINATIVE = "лазерный карабин IK-60",
		GENITIVE = "лазерного карабина IK-60",
		DATIVE = "лазерному карабину IK-60",
		ACCUSATIVE = "лазерный карабин IK-60",
		INSTRUMENTAL = "лазерным карабином IK-60",
		PREPOSITIONAL = "лазерном карабине IK-60",
	)

/obj/item/gun/projectile/automatic/ik60/update_icon_state()
	icon_state = "lasercarbine[magazine ? "-[ceil(get_ammo(FALSE)/5)*5]" : ""]"

// MARK: LR-30
/obj/item/gun/projectile/automatic/lr30
	name = "LR-30 Laser Rifle"
	desc = "Штурмовая винтовка с магазинным питанием, использующая специализированные патроны для стрельбы лазеро-подобными снарядами."
	gender = FEMALE
	icon_state = "lr30"
	item_state = "lr30"
	origin_tech = "combat=3;materials=2"
	mag_type = /obj/item/ammo_box/magazine/lr30mag
	fire_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_amount = 1
	fire_delay = 0.4 SECONDS
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 3, ATTACHMENT_OFFSET_Y = 9),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = -2),
	)
	recoil = GUN_RECOIL_MIN
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)

/obj/item/gun/projectile/automatic/lr30/get_ru_names()
	return alist(
		NOMINATIVE = "лазерная винтовка LR-30",
		GENITIVE = "лазерной винтовки LR-30",
		DATIVE = "лазерной винтовке LR-30",
		ACCUSATIVE = "лазерную винтовку LR-30",
		INSTRUMENTAL = "лазерной винтовкой LR-30",
		PREPOSITIONAL = "лазерной винтовке LR-30",
	)

/obj/item/gun/projectile/automatic/lr30/update_icon_state()
	icon_state = "lr30[magazine ? "-[ceil(get_ammo(FALSE)/3)*3]" : ""]"
