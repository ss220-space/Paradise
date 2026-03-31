// MARK: Laser ammo
/obj/item/ammo_box/laserammobox
	name = "laser ammo box"
	desc = "Коробка, содержащая лазерные патроны."
	icon_state = "laserbox"
	ammo_type = /obj/item/ammo_casing/laser
	max_ammo = 36

/obj/item/ammo_box/laserammobox/get_ru_names()
	return list(
		NOMINATIVE = "коробка лазерных патронов",
		GENITIVE = "коробки лазерных патронов",
		DATIVE = "коробке лазерных патронов",
		ACCUSATIVE = "коробку лазерных патронов",
		INSTRUMENTAL = "коробкой лазерных патронов",
		PREPOSITIONAL = "коробке лазерных патронов",
	)

// MARK: .75
/obj/item/ammo_box/a75
	name = "ammo box (.75)"
	desc = "Коробка, содержащая ракетные заряды калибра .75."
	icon_state = "75box"
	ammo_type = /obj/item/ammo_casing/caseless/a75
	max_ammo = 10

/obj/item/ammo_box/a75/get_ru_names()
	return list(
		NOMINATIVE = "коробка ракетных зарядов (.75)",
		GENITIVE = "коробки ракетных зарядов (.75)",
		DATIVE = "коробке ракетных зарядов (.75)",
		ACCUSATIVE = "коробку ракетных зарядов (.75)",
		INSTRUMENTAL = "коробкой ракетных зарядов (.75)",
		PREPOSITIONAL = "коробке ракетных зарядов (.75)",
	)

// MARK: Enforcer laser
/obj/item/ammo_box/enforcer
	origin_tech = "combat=2"
	max_ammo = 30

/obj/item/ammo_box/enforcer/laser
	name = "ammo box (Enforcer laser)"
	desc = "Коробка, содержащая 30 лазерных патронов для пистолета \"Блюститель\"."
	icon_state = "speclaser"
	ammo_type = /obj/item/ammo_casing/enforcer/laser

/obj/item/ammo_box/enforcer/laser/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (Блюститель лазерные)",
		GENITIVE = "коробка патронов (Блюститель лазерные)",
		DATIVE = "коробка патронов (Блюститель лазерные)",
		ACCUSATIVE = "коробка патронов (Блюститель лазерные)",
		INSTRUMENTAL = "коробка патронов (Блюститель лазерные)",
		PREPOSITIONAL = "коробка патронов (Блюститель лазерные)",
	)

/obj/item/ammo_box/enforcer/disabler
	name = "ammo box (Enforcer disabler)"
	desc = "Коробка, содержащая 30 парализующих патронов для пистолета \"Блюститель\"."
	icon_state = "specstamina"
	ammo_type = /obj/item/ammo_casing/enforcer/disable
	materials = list(MAT_METAL = 1000)

/obj/item/ammo_box/enforcer/disabler/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (Блюститель парализующие)",
		GENITIVE = "коробка патронов (Блюститель парализующие)",
		DATIVE = "коробке патронов (Блюститель парализующие)",
		ACCUSATIVE = "коробку патронов (Блюститель парализующие)",
		INSTRUMENTAL = "коробкой патронов (Блюститель парализующие)",
		PREPOSITIONAL = "коробке патронов (Блюститель парализующие)",
	)
