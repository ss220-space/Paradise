// MARK: 5.56x56mm - AR-15
/obj/item/ammo_box/magazine/m556
	name = "toploader magazine (5.56x45mm)"
	desc = "Коробчатый магазин, предназначенный для патронов калибра 5,56x45 мм."
	icon_state = "5.56m"
	origin_tech = "combat=5"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = CALIBER_5_DOT_56X45MM
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m556/get_ru_names()
	return list(
		NOMINATIVE = "автоматный магазин (5,56x45 мм)",
		GENITIVE = "автоматного магазина (5,56x45 мм)",
		DATIVE = "автоматному магазину (5,56x45 мм)",
		ACCUSATIVE = "автоматного магазина (5,56x45 мм)",
		INSTRUMENTAL = "автоматным магазином (5,56x45 мм)",
		PREPOSITIONAL = "автоматном магазине (5,56x45 мм)",
	)

// MARK: 5.45x39mm - AK-814
/obj/item/ammo_box/magazine/ak814
	name = "AK magazine (5.45x39mm)"
	desc = "Магазин к автомату AK-814, предназначенный для патронов калибра 5,45x39 мм."
	icon_state = "ak814"
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545
	caliber = CALIBER_5_DOT_45X39MM
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/ak814/get_ru_names()
	return list(
		NOMINATIVE = "автоматный магазин AK-814 (5,45x39 мм)",
		GENITIVE = "автоматного магазина AK-814 (5,45x39 мм)",
		DATIVE = "автоматному магазину AK-814 (5,45x39 мм)",
		ACCUSATIVE = "автоматного магазина AK-814 (5,45x39 мм)",
		INSTRUMENTAL = "автоматным магазином AK-814 (5,45x39 мм)",
		PREPOSITIONAL = "автоматном магазине AK-814 (5,45x39 мм)",
	)

// MARK: 5.45x39mm - AKS-74U
/obj/item/ammo_box/magazine/aks74u
	name = "AK magazine (5.45x39mm)"
	desc = "Магазин к автомату АКС-74У, предназначенный для патронов калибра 5,45x39 мм."
	icon_state = "ak47mag"
	origin_tech = "combat=4;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545/fusty
	caliber = CALIBER_5_DOT_45X39MM
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/aks74u/get_ru_names()
	return list(
		NOMINATIVE = "автоматный магазин АКС-74У (5,45x39 мм)",
		GENITIVE = "автоматного магазина АКС-74У (5,45x39 мм)",
		DATIVE = "автоматному магазину АКС-74У (5,45x39 мм)",
		ACCUSATIVE = "автоматного магазина АКС-74У (5,45x39 мм)",
		INSTRUMENTAL = "автоматным магазином АКС-74У (5,45x39 мм)",
		PREPOSITIONAL = "автоматном магазине АКС-74У (5,45x39 мм)",
	)

// MARK: 7.62x51mm - M-52
/obj/item/ammo_box/magazine/m52mag
	name = "M-52 magazine"
	desc = "Коробчатый магазин M-52, предназначенный для патронов калибра 7,62x51 мм."
	icon_state = "m52_ammo"
	ammo_type = /obj/item/ammo_casing/a762x51
	caliber = CALIBER_7_DOT_62X51MM
	max_ammo = 24
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m52mag/get_ru_names()
	return list(
		NOMINATIVE = "автоматный магазин M-52 (7,62x51 мм)",
		GENITIVE = "автоматного магазина M-52 (7,62x51 мм)",
		DATIVE = "автоматному магазину M-52 (7,62x51 мм)",
		ACCUSATIVE = "автоматного магазина M-52 (7,62x51 мм)",
		INSTRUMENTAL = "автоматным магазином M-52 (7,62x51 мм)",
		PREPOSITIONAL = "автоматном магазине M-52 (7,62x51 мм)",
	)

// MARK: Laser - IK-60
/obj/item/ammo_box/magazine/ik60mag
	name = "encased laser projector magazine"
	desc = "Коробчатый магазин IK-60, предназначенный для лазерных патронов."
	icon_state = "laser"
	ammo_type = /obj/item/ammo_casing/laser
	caliber = CALIBER_LASER
	max_ammo = 20

/obj/item/ammo_box/magazine/ik60mag/get_ru_names()
	return list(
		NOMINATIVE = "автоматный магазин IK-60 (лазерный)",
		GENITIVE = "автоматного магазина IK-60 (лазерный)",
		DATIVE = "автоматному магазину IK-60 (лазерный)",
		ACCUSATIVE = "автоматного магазина IK-60 (лазерный)",
		INSTRUMENTAL = "автоматным магазином IK-60 (лазерный)",
		PREPOSITIONAL = "автоматном магазине IK-60 (лазерный)",
	)

/obj/item/ammo_box/magazine/ik60mag/update_icon_state()
	icon_state = "[initial(icon_state)]-[ceil(ammo_count(FALSE)/20)*20]"

// MARK: Laser - LR-30
/obj/item/ammo_box/magazine/lr30mag
	name = "small encased laser projector magazine"
	desc = "Коробчатый магазин LR-30, предназначенный для лазерных патронов."
	icon_state = "lmag"
	ammo_type = /obj/item/ammo_casing/laser
	caliber = CALIBER_LASER
	max_ammo = 12

/obj/item/ammo_box/magazine/lr30mag/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/lr30mag/get_ru_names()
	return list(
		NOMINATIVE = "автоматный магазин LR-30 (лазерный)",
		GENITIVE = "автоматного магазина LR-30 (лазерный)",
		DATIVE = "автоматному магазину LR-30 (лазерный)",
		ACCUSATIVE = "автоматного магазина LR-30 (лазерный)",
		INSTRUMENTAL = "автоматным магазином LR-30 (лазерный)",
		PREPOSITIONAL = "автоматном магазине LR-30 (лазерный)",
	)

/obj/item/ammo_box/magazine/lr30mag/update_icon_state()
	icon_state = "lmag-[CEILING(ammo_count(), 3)]"
