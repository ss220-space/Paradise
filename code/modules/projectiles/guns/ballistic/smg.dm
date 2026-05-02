/obj/item/gun/projectile/automatic/smg
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
	icon_state = "[base_icon_state]_base"

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
	desc = "A prototype three-round burst 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	origin_tech = "combat=4;materials=2"
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_LOW
	fire_modes = GUN_MODE_SINGLE_BURST
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = 3),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 3, ATTACHMENT_OFFSET_Y = 7),
	)
	starting_attachment_types = list(/obj/item/gun_module/rail/scope/collimator)
	chambered_light_exists = TRUE

/obj/item/gun/projectile/automatic/proto/rubber

/obj/item/gun/projectile/automatic/smg/saber/rubber/Initialize(mapload)
	magazine = new/obj/item/ammo_box/magazine/smgm9mm/rubber
	. = ..()

// MARK: DCA-SMG45 Cutoff
/obj/item/gun/projectile/automatic/smg/c20r
	name = "DCA-SMG45 \"Cutoff\" submachine gun"
	desc = "Пистолет-пулемёт калибра .45 производства \"Donk Co. Arms\". Поддерживает три режима стрельбы: одиночный, очередь по 2 патрона и автоматический. \
			Компактные габариты, управляемая отдача и высокая для класса точность делают его предпочтительным выбором для ближнего и среднего боя."
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

/obj/item/gun/projectile/automatic/c20r/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/gun/projectile/automatic/smg/c20r/ComponentInitialize()
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

/obj/item/gun/projectile/automatic/smg/c20r/auto/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт DCA-SMG45M \"Жнец\" .45",
		GENITIVE = "пистолет-пулемёта DCA-SMG45M \"Жнец\" .45",
		DATIVE = "пистолет-пулемёту DCA-SMG45M \"Жнец\" .45",
		ACCUSATIVE = "пистолет-пулемёт DCA-SMG45M \"Жнец\" .45",
		INSTRUMENTAL = "пистолет-пулемётом DCA-SMG45M \"Жнец\" .45",
		PREPOSITIONAL = "пистолет-пулемёте DCA-SMG45M \"Жнец\" .45",
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
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_SMG_STOCK
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
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_SMG_STOCK
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

/obj/item/gun/projectile/automatic/mini_uzi/get_ru_names()
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
	accuracy = GUN_ACCURACY_RIFLE
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

/obj/item/gun/projectile/automatic/sfg/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"

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

/obj/item/gun/projectile/automatic/ppsh/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемёт ППШ 7,62x25 мм",
		GENITIVE = "пистолет-пулемёта ППШ 7,62x25 мм",
		DATIVE = "пистолет-пулемёту ППШ 7,62x25 мм",
		ACCUSATIVE = "пистолет-пулемёт ППШ 7,62x25 мм",
		INSTRUMENTAL = "пистолет-пулемётом ППШ 7,62x25 мм",
		PREPOSITIONAL = "пистолет-пулемёте ППШ 7,62x25 мм",
	)

/obj/item/gun/projectile/automatic/ppsh/rusted
	name = "Rusted PPSh submachine gun"
	desc = "An old submachine gun favored by Soviet soldiers."
	damage_mod = 0.75

/obj/item/gun/projectile/automatic/smg/ppsh/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 20, destroy_max_chance = 4, malf_low_bound = 15, malf_high_bound = 71)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 15, misfire_low_bound = 30, misfire_high_bound = 71)
