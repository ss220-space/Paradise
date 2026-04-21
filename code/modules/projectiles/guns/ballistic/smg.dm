// MARK: Saber SMG
/obj/item/gun/projectile/automatic/proto
	name = "Nanotrasen Saber SMG"
	desc = "A prototype three-round burst 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	origin_tech = "combat=4;materials=2"
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_LOW
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = 3),
	)

/obj/item/gun/projectile/automatic/proto/rubber

/obj/item/gun/projectile/automatic/proto/rubber/Initialize(mapload)
	magazine = new/obj/item/ammo_box/magazine/smgm9mm/rubber
	. = ..()

// MARK: C-20r SMG
/obj/item/gun/projectile/automatic/c20r
	name = "C-20r SMG"
	desc = "A .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
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
	fire_modes = GUN_MODE_SINGLE_BURST_AUTO
	autofire_delay = 0.25 SECONDS

/obj/item/gun/projectile/automatic/c20r/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/gun/projectile/automatic/c20r/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/ammo_alarm, 'sound/weapons/smg_empty_alarm.ogg')

/obj/item/gun/projectile/automatic/c20r/update_icon_state()
	icon_state = "c20r[magazine ? "-[ceil(get_ammo(FALSE)/4)*4]" : ""][chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/c20r/auto
	name = "C-20rm SMG"
	desc = "Новейшая модификация автоматического пистолет-пулемёта \"C-20r\" под .45 калибр. Отличается высоким темпом стрельбы в автоматическом режиме."
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_LOW
	autofire_delay = 0.15 SECONDS
	fire_delay = 0.15 SECONDS

/obj/item/gun/projectile/automatic/c20r/auto/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт C-20rm",
		GENITIVE = "пистолет-пулемёта C-20rm",
		DATIVE = "пистолет-пулемёту C-20rm",
		ACCUSATIVE = "пистолет-пулемёт C-20rm",
		INSTRUMENTAL = "пистолет-пулемётом C-20rm",
		PREPOSITIONAL = "пистолет-пулемёте C-20rm",
	)

/obj/item/gun/projectile/automatic/c20r/rusted
	name = "C-20r SMG (Rusted)"
	desc = "A .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp. Looks rusty."
	damage_mod = 0.85

/obj/item/gun/projectile/automatic/c20r/rusted/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт C-20r (ржавый)",
		GENITIVE = "пистолет-пулемёта C-20r (ржавый)",
		DATIVE = "пистолет-пулемёту C-20r (ржавый)",
		ACCUSATIVE = "пистолет-пулемёт C-20r (ржавый)",
		INSTRUMENTAL = "пистолет-пулемётом C-20r (ржавый)",
		PREPOSITIONAL = "пистолет-пулемёте C-20r (ржавый)",
	)

/obj/item/gun/projectile/automatic/c20r/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 10, destroy_max_chance = 3, malf_low_bound = 50, malf_high_bound = 100)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 5, misfire_low_bound = 50, misfire_high_bound = 100)

// MARK: WT550
/obj/item/gun/projectile/automatic/wt550
	name = "WT-550 PDW"
	desc = "An outdated personal defense weapon utilized by law enforcement. Chambered in 4.6x30mm."
	icon_state = "wt550"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/wt550m9
	fire_sound = 'sound/weapons/gunshots/1wt.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_size = 2
	accuracy = new /datum/gun_accuracy/rifle/extend_spread()
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 20, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 7),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -5),
	)
	recoil = GUN_RECOIL_MEDIUM
	weapon_weight = WEAPON_HEAVY
	fire_modes = GUN_MODE_SINGLE_BURST_AUTO

/obj/item/gun/projectile/automatic/wt550/update_icon_state()
	icon_state = "wt550[magazine ? "-[ceil(get_ammo(FALSE)/6)*6]" : ""]"

// MARK: SP-91-RC
/obj/item/gun/projectile/automatic/sp91rc
	name = "SP-91-RC"
	desc = "Компактный пистолет-пулемёт, предназначенный для \"нелетального\" подавления беспорядков."
	icon_state = "SP-91-RC"
	item_state = "SP-91-RC"
	mag_type = /obj/item/ammo_box/magazine/sp91rc
	fire_sound = 'sound/weapons/gunshots/1sp_91.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	accuracy = new /datum/gun_accuracy/rifle/extend_spread()
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 19, ATTACHMENT_OFFSET_Y = 3),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = -2, ATTACHMENT_OFFSET_Y = 7),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -5),
	)
	recoil = GUN_RECOIL_MEDIUM
	weapon_weight = WEAPON_HEAVY
	fire_modes = GUN_MODE_SINGLE_BURST_AUTO

/obj/item/gun/projectile/automatic/sp91rc/update_icon_state()
	icon_state = "SP-91-RC[magazine ? "-[ceil(get_ammo(FALSE)/5)*5]" : ""]"
	item_state = "SP-91-RC[magazine ? "-[get_ammo(FALSE) ? "20" : "0"]" : ""]"

// MARK: Sparkle-A12
/obj/item/gun/projectile/automatic/sparkle_a12
	name = "A9 \"Sparkle\""
	desc = "Пистолет-пулемёт под калибр 9x19 мм, произведённый концерном \"Скарборо\". Штатно используется силовыми структурами \"Нанотрейзен\". Отличается надёжностью, высокой точностью и малыми габаритами. Предназначен для ближнего боя в условиях ограниченного пространства."
	icon_state = "sparkle-a12"
	item_state = "sparkle-a12"
	mag_type = /obj/item/ammo_box/magazine/sparkle_a12
	fire_sound = 'sound/weapons/gunshots/1wt.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 19, ATTACHMENT_OFFSET_Y = 3),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 4, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -5),
	)
	starting_attachment_types = list(/obj/item/gun_module/muzzle/suppressor/integrated)
	recoil = GUN_RECOIL_MEDIUM
	weapon_weight = WEAPON_HEAVY
	fire_delay = 1
	damage_mod = 0.7

/obj/item/gun/projectile/automatic/sparkle_a12/get_ru_names()
	return list(
		NOMINATIVE = "А9 \"Искра\"",
		GENITIVE = "А9 \"Искра\"",
		DATIVE = "А9 \"Искра\"",
		ACCUSATIVE = "А9 \"Искра\"",
		INSTRUMENTAL = "А9 \"Искра\"",
		PREPOSITIONAL = "А9 \"Искра\""
	)

/obj/item/gun/projectile/automatic/sparkle_a12/update_icon_state()
	icon_state = "sparkle-a12[magazine ? "" : "-e"]"

// MARK: Type-U3 Uzi
/obj/item/gun/projectile/automatic/mini_uzi
	name = "Type U3 Uzi"
	desc = "Полностью заряженный лёгкий пистолет-пулемёт, оснащённый магазином на 32 патрона калибра 9 мм. \
			Имеет два режима стрельбы: полуавтоматический и с отсечкой по 4 патрона. Совместим с глушителем."
	icon_state = "mini-uzi"
	origin_tech = "combat=4;materials=2;syndicate=4"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	fire_sound = 'sound/weapons/gunshots/1uzi.ogg'
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_PISTOL_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 14, ATTACHMENT_OFFSET_Y = 7),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = -4, ATTACHMENT_OFFSET_Y = 12),
	)
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_LOW
	fire_modes = GUN_MODE_SINGLE_BURST_AUTO

// MARK: Tommy Gun
/obj/item/gun/projectile/automatic/tommygun
	name = "Thompson SMG"
	desc = "A genuine 'Chicago Typewriter'."
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/gunshots/1saber.ogg'
	burst_size = 4
	fire_delay = 1
	accuracy = GUN_ACCURACY_RIFLE
	recoil = GUN_RECOIL_MEDIUM

// MARK: SFG-5
/obj/item/gun/projectile/automatic/sfg
	name = "SFG-5"
	desc = "Данное оружие, созданное для различных спецслужб по всей галактике одной компанией, имеет в качестве калибра 9мм, возможность стрельбы очередями отсечкой по 3 патрона и имеет место для фонарика и глушителя."
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

/obj/item/gun/projectile/automatic/sfg/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"

// MARK: PPSh
/obj/item/gun/projectile/automatic/ppsh
	name = "PPSh submachine gun"
	desc = "A submachine gun favored by Soviet soldiers."
	icon_state = "ppsh"
	item_state = "ppsh"
	mag_type = /obj/item/ammo_box/magazine/ppsh
	weapon_weight = WEAPON_HEAVY
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_size = 5
	fire_delay = 1.5
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 20, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 5, ATTACHMENT_OFFSET_Y = 5),
	)
	recoil = GUN_RECOIL_HIGH


/obj/item/gun/projectile/automatic/ppsh/rusted
	name = "Rusted PPSh submachine gun"
	desc = "An old submachine gun favored by Soviet soldiers."
	damage_mod = 0.75

/obj/item/gun/projectile/automatic/ppsh/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 20, destroy_max_chance = 4, malf_low_bound = 15, malf_high_bound = 71)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 15, misfire_low_bound = 30, misfire_high_bound = 71)
