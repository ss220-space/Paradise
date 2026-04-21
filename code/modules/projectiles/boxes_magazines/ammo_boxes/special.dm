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
