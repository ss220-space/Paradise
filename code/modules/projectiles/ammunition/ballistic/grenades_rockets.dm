// MARK: Rocket
/obj/item/ammo_casing/rocket
	name = "rocket shell"
	desc = "A high explosive designed to be fired from a launcher."
	icon_state = "rocketshell"
	materials = list(MAT_METAL = 10000)
	caliber = CALIBER_ROCKET
	projectile_type = /obj/item/missile
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

// MARK: 84mm HE
/obj/item/ammo_casing/caseless/rocket
	name = "PM-9HE"
	desc = "An 84mm High Explosive rocket. Fire at people and pray."
	caliber = CALIBER_84MM
	w_class = WEIGHT_CLASS_NORMAL //thats the rocket!
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "84mm-he"
	projectile_type = /obj/projectile/bullet/a84mm_he
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'	// better than default casing but not ideal

/obj/item/ammo_casing/caseless/rocket/hedp
	name = "PM-9HEDP"
	desc = "An 84mm High Explosive Dual Purpose rocket. Pointy end toward mechs and unarmed civilians."
	icon_state = "84mm-hedp"
	projectile_type = /obj/projectile/bullet/a84mm_hedp

// MARK: 40mm HE
/obj/item/ammo_casing/a40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	icon_state = "40mmHE"
	materials = list(MAT_METAL = 8000)
	caliber = CALIBER_40MM
	projectile_type = /obj/projectile/bullet/a40mm
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

// MARK: 40mm - GL-06
/obj/item/ammo_casing/a40mm/secgl
	name = "40mm grenade"
	desc = "Граната калибра 40 мм."
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "secgl_solid"
	item_state = "secgl_solid"
	drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'

/obj/item/ammo_casing/a40mm/secgl/get_ru_names()
	return list(
		NOMINATIVE = "граната (40 мм)",
		GENITIVE = "гранаты (40 мм)",
		DATIVE = "гранате (40 мм)",
		ACCUSATIVE = "гранату (40 мм)",
		INSTRUMENTAL = "гранатой (40 мм)",
		PREPOSITIONAL = "гранате (40 мм)",
	)

/obj/item/ammo_casing/a40mm/secgl/solid
	name = "40mm grenade (rubber slug)"
	desc = "Граната калибра 40 мм с цельной резиновой пулей. Отлично подходит для нейтрализации активных митингующих из толпы нелетальным способом."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/solid

/obj/item/ammo_casing/a40mm/secgl/solid/get_ru_names()
	return list(
		NOMINATIVE = "граната (40 мм цельная резина)",
		GENITIVE = "гранаты (40 мм цельная резина)",
		DATIVE = "гранате (40 мм цельная резина)",
		ACCUSATIVE = "гранату (40 мм цельная резина)",
		INSTRUMENTAL = "гранатой (40 мм цельная резина)",
		PREPOSITIONAL = "гранате (40 мм цельная резина)",
	)

/obj/item/ammo_casing/a40mm/secgl/flash
	name = "40mm grenade (flashbang)"
	desc = "Граната калибра 40 мм со светошумовой гранатой. Отличная возможность закинуть светошумовую гранату на далекие расстояния."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/flash
	icon_state = "secgl_flash"
	item_state = "secgl_flash"

/obj/item/ammo_casing/a40mm/secgl/flash/get_ru_names()
	return list(
		NOMINATIVE = "граната (40 мм светошумовая)",
		GENITIVE = "гранаты (40 мм светошумовая)",
		DATIVE = "гранате (40 мм светошумовая)",
		ACCUSATIVE = "гранату (40 мм светошумовая)",
		INSTRUMENTAL = "гранатой (40 мм светошумовая)",
		PREPOSITIONAL = "гранате (40 мм светошумовая)",
	)

/obj/item/ammo_casing/a40mm/secgl/gas
	name = "40mm grenade (gatears)"
	desc = "Граната калибра 40 мм со слезоточивым газом. Позволяет разогнать толпу митингующих без защиты органов дыхания."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/gas
	icon_state = "secgl_gas"
	item_state = "secgl_gas"

/obj/item/ammo_casing/a40mm/secgl/gas/get_ru_names()
	return list(
		NOMINATIVE = "граната (40 мм слезоточивый газ)",
		GENITIVE = "гранаты (40 мм слезоточивый газ)",
		DATIVE = "гранате (40 мм слезоточивый газ)",
		ACCUSATIVE = "гранату (40 мм слезоточивый газ)",
		INSTRUMENTAL = "гранатой (40 мм слезоточивый газ)",
		PREPOSITIONAL = "гранате (40 мм слезоточивый газ)",
	)

/obj/item/ammo_casing/a40mm/secgl/barricade
	name = "40mm grenade (barricade)"
	desc = "Граната калибра 40 мм, создающая небольшую металлическую баррикаду при детонации. Полезна для быстрого создания укрытий." 
	projectile_type = /obj/projectile/grenade/a40mm/secgl/barricade
	icon_state = "secgl_barricade"
	item_state = "secgl_barricade"

/obj/item/ammo_casing/a40mm/secgl/barricade/get_ru_names()
	return list(
		NOMINATIVE = "граната (40 мм баррикада)",
		GENITIVE = "гранаты (40 мм баррикада)",
		DATIVE = "гранате (40 мм баррикада)",
		ACCUSATIVE = "гранату (40 мм баррикада)",
		INSTRUMENTAL = "гранатой (40 мм баррикада)",
		PREPOSITIONAL = "гранате (40 мм баррикада)",
	)

/obj/item/ammo_casing/a40mm/secgl/exp
	name = "40mm grenade (frag)"
	desc = "Граната калибра 40 мм с осколочной рубашкой. Летальный боеприпас для закидывания на дальнее расстояние."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/exp
	icon_state = "secgl_exp"
	item_state = "secgl_exp"

/obj/item/ammo_casing/a40mm/secgl/exp/get_ru_names()
	return list(
		NOMINATIVE = "граната (40 мм осколочная)",
		GENITIVE = "гранаты (40 мм осколочная)",
		DATIVE = "гранате (40 мм осколочная)",
		ACCUSATIVE = "гранату (40 мм осколочная)",
		INSTRUMENTAL = "гранатой (40 мм осколочная)",
		PREPOSITIONAL = "гранате (40 мм осколочная)",
	)

/obj/item/ammo_casing/a40mm/secgl/paint
	name = "40mm grenade (paint)"
	desc = "Граната калибра 40 мм с краской. Граната которая закрашивает цель для его отслеживания."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/paint
	icon_state = "secgl_paint"
	item_state = "secgl_paint"

/obj/item/ammo_casing/a40mm/secgl/paint/get_ru_names()
	return list(
		NOMINATIVE = "граната (40 мм краска)",
		GENITIVE = "гранаты (40 мм краска)",
		DATIVE = "гранате (40 мм краска)",
		ACCUSATIVE = "гранату (40 мм краска)",
		INSTRUMENTAL = "гранатой (40 мм краска)",
		PREPOSITIONAL = "гранате (40 мм краска)",
	)

// MARK: 40mm - Bombarda
/obj/item/ammo_casing/a40mm/improvised
	name = "Improvised shell"
	desc = "Does something upon impact or after some time. If you see this, contact the coder."
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "exp_shell"
	item_state = "exp_shell"
	drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'

/obj/item/ammo_casing/a40mm/improvised/exp_shell
	name = "Improvised explosive shell"
	desc = "Explodes upon impact or after some time."
	projectile_type = /obj/projectile/grenade/improvised/exp_shot

/obj/item/ammo_casing/a40mm/improvised/flame_shell
	name = "Improvised flame shell"
	desc = "Explodes with flames upon impact or after some time"
	projectile_type = /obj/projectile/grenade/improvised/flame_shot
	icon_state = "flame_shell"
	item_state = "flame_shell"

/obj/item/ammo_casing/a40mm/improvised/smoke_shell
	name = "Improvised smoke shell"
	desc = "Explodes with smoke upon impact or after some time"
	projectile_type = /obj/projectile/grenade/improvised/smoke_shot
	icon_state = "smoke_shell"
	item_state = "smoke_shell"
