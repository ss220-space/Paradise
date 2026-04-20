// MARK: Rocket
/obj/item/ammo_casing/rocket
	name = "rocket shell"
	desc = "Ракеты для стрельбы из ракетницы."
	icon_state = "rocketshell"
	materials = list(MAT_METAL = 10000)
	caliber = CALIBER_ROCKET
	projectile_type = /obj/item/missile
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	no_update_desc = TRUE
	no_update_names = TRUE

/obj/item/ammo_casing/rocket/get_ru_names()
	return list(
		NOMINATIVE = "ракета",
		GENITIVE = "ракеты",
		DATIVE = "ракете",
		ACCUSATIVE = "ракету",
		INSTRUMENTAL = "ракетой",
		PREPOSITIONAL = "ракете",
	)

// MARK: 84mm HE
/obj/item/ammo_casing/caseless/rocket
	ammo_marking = "84 мм HE"
	desc = "Осколочно-фугасная ракета. Предназначена для поражения пехоты."
	caliber = CALIBER_84MM
	w_class = WEIGHT_CLASS_NORMAL //thats the rocket!
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "84mm-he"
	projectile_type = /obj/projectile/bullet/a84mm_he
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'	// better than default casing but not ideal

/obj/item/ammo_casing/caseless/rocket/hedp
	ammo_marking = "84 мм HEDP"
	desc = "Кумулятивно-осколочная ракета двойного назначения. Предназначена для поражения бронированной техники и тяжёлых экзоскелетов."
	icon_state = "84mm-hedp"
	projectile_type = /obj/projectile/bullet/a84mm_hedp

// MARK: 40mm HE
/obj/item/ammo_casing/a40mm
	ammo_marking = "40 мм HE"
	icon_state = "40mmHE"
	materials = list(MAT_METAL = 8000)
	caliber = CALIBER_40MM
	projectile_type = /obj/projectile/bullet/a40mm
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/a40mm/get_ru_names()
	return list(
		NOMINATIVE = "выстрел [ammo_marking]",
		GENITIVE = "выстрела [ammo_marking]",
		DATIVE = "выстрелу [ammo_marking]",
		ACCUSATIVE = "выстрел [ammo_marking]",
		INSTRUMENTAL = "выстрелом [ammo_marking]",
		PREPOSITIONAL = "выстреле [ammo_marking]",
	)

/obj/item/ammo_casing/a40mm/update_desc(updates = ALL)
	. = ..()
	desc = "Заряженный и готовый к использованию боеприпас [ammo_marking] для стрельбы из гранатомёта. [extra_info]"

// MARK: 40mm - GL-06
/obj/item/ammo_casing/a40mm/secgl
	ammo_marking = "40 мм"
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "secgl_solid"
	item_state = "secgl_solid"
	drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'

/obj/item/ammo_casing/a40mm/secgl/solid
	ammo_marking = "40 мм ЦР"
	extra_info = "Цельная резиновая	граната для нелетальной нейтрализации целей."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/solid

/obj/item/ammo_casing/a40mm/secgl/flash
	ammo_marking = "40 мм СШ"
	extra_info = "Светошумовая граната для дезориентации противников."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/flash
	icon_state = "secgl_flash"
	item_state = "secgl_flash"

/obj/item/ammo_casing/a40mm/secgl/gas
	ammo_marking = "40 мм СГ"
	extra_info = "Слезоточивый газ для нелетальной нейтрализации целей без защиты органов дыхания."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/gas
	icon_state = "secgl_gas"
	item_state = "secgl_gas"

/obj/item/ammo_casing/a40mm/secgl/barricade
	ammo_marking = "40 мм ПБ"
	extra_info = "Портативная баррикада для создания укрытий на открытой местности."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/barricade
	icon_state = "secgl_barricade"
	item_state = "secgl_barricade"

/obj/item/ammo_casing/a40mm/secgl/exp
	ammo_marking = "40 мм ОГ"
	extra_info = "Осколочная граната для летальной нейтрализации целей."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/exp
	icon_state = "secgl_exp"
	item_state = "secgl_exp"

/obj/item/ammo_casing/a40mm/secgl/paint
	ammo_marking = "40 мм \"Краска\""
	extra_info = "Граната с краской, закрашивающая цель при попадании для её отслеживания."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/paint
	icon_state = "secgl_paint"
	item_state = "secgl_paint"

// MARK: 40mm - Bombarda
/obj/item/ammo_casing/a40mm/improvised
	ammo_marking = "40 мм импровизированная"
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "exp_shell"
	item_state = "exp_shell"
	drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'

/obj/item/ammo_casing/a40mm/improvised/update_desc(updates = ALL)
	. = ..()
	desc = "Самодельная граната [ammo_marking] для стрельбы из гранатомёта. Крайне нестабильная. [extra_info]"

/obj/item/ammo_casing/a40mm/improvised/exp_shell
	ammo_marking = "40 мм импровизированная \"Взрыв\""
	extra_info = "Взрывается при ударе."
	projectile_type = /obj/projectile/grenade/improvised/exp_shot

/obj/item/ammo_casing/a40mm/improvised/flame_shell
	ammo_marking = "40 мм импровизированная \"Огонь\""
	extra_info = "Воспламеняется при ударе."
	projectile_type = /obj/projectile/grenade/improvised/flame_shot
	icon_state = "flame_shell"
	item_state = "flame_shell"

/obj/item/ammo_casing/a40mm/improvised/smoke_shell
	ammo_marking = "40 мм импровизированная \"Дым\""
	extra_info = "Создаёт облако дыма при ударе."
	projectile_type = /obj/projectile/grenade/improvised/smoke_shot
	icon_state = "smoke_shell"
	item_state = "smoke_shell"
