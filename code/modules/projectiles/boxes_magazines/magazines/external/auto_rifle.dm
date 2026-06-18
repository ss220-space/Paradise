// MARK: 5.56x45mm - AR-15
/obj/item/ammo_box/magazine/m556
	gun_name = "AR-15"
	extra_info = "Используется для широкого спектра оружия системы AR-15."
	icon_state = "5.56m"
	origin_tech = "combat=5"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = CALIBER_5_DOT_56X45MM
	max_ammo = 30
	multiple_sprites = 2

// MARK: 5.45x39mm - AK-814
/obj/item/ammo_box/magazine/ak814
	gun_name = "автомата АК-814"
	icon_state = "ak814"
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545
	caliber = CALIBER_5_DOT_45X39MM
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/ak814/get_ru_names()
	return alist(
		NOMINATIVE = "автоматный магазин AK-814 (5,45x39 мм)",
		GENITIVE = "автоматного магазина AK-814 (5,45x39 мм)",
		DATIVE = "автоматному магазину AK-814 (5,45x39 мм)",
		ACCUSATIVE = "автоматного магазина AK-814 (5,45x39 мм)",
		INSTRUMENTAL = "автоматным магазином AK-814 (5,45x39 мм)",
		PREPOSITIONAL = "автоматном магазине AK-814 (5,45x39 мм)",
	)

/obj/item/ammo_box/magazine/ak814/fusty
	ammo_type = /obj/item/ammo_casing/a545/fusty

/obj/item/ammo_box/magazine/ak814/fusty/empty
	start_empty = TRUE

// MARK: 5.45x39mm - AKS-74U
/obj/item/ammo_box/magazine/aks74u
	gun_name = "автомата АКС-74У"
	icon_state = "ak47mag"
	origin_tech = "combat=4;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545/fusty
	caliber = CALIBER_5_DOT_45X39MM
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/aks74u/get_ru_names()
	return alist(
		NOMINATIVE = "автоматный магазин АКС-74У (5,45x39 мм)",
		GENITIVE = "автоматного магазина АКС-74У (5,45x39 мм)",
		DATIVE = "автоматному магазину АКС-74У (5,45x39 мм)",
		ACCUSATIVE = "автоматного магазина АКС-74У (5,45x39 мм)",
		INSTRUMENTAL = "автоматным магазином АКС-74У (5,45x39 мм)",
		PREPOSITIONAL = "автоматном магазине АКС-74У (5,45x39 мм)",
	)

/obj/item/ammo_box/magazine/aksu/empty
	start_empty = TRUE

// MARK: 7.62x51mm - M-52
/obj/item/ammo_box/magazine/m52mag
	gun_name = "боевой винтовки M-52"
	icon_state = "m52_ammo"
	ammo_type = /obj/item/ammo_casing/a762x51
	caliber = CALIBER_7_DOT_62X51MM
	max_ammo = 24
	multiple_sprites = 2

// MARK: Laser - IK-60
/obj/item/ammo_box/magazine/ik60mag
	gun_name = "лазерной винтовки IK-60"
	icon_state = "laser"
	ammo_type = /obj/item/ammo_casing/laser
	caliber = CALIBER_LASER
	max_ammo = 20

/obj/item/ammo_box/magazine/ik60mag/update_icon_state()
	icon_state = "[initial(icon_state)]-[ceil(ammo_count(FALSE)/20)*20]"

/obj/item/ammo_box/magazine/ik60mag/empty
	start_empty = TRUE

// MARK: Laser - LR-30
/obj/item/ammo_box/magazine/lr30mag
	gun_name = "лазерной винтовки LR-30"
	icon_state = "lmag"
	ammo_type = /obj/item/ammo_casing/laser
	caliber = CALIBER_LASER
	max_ammo = 12

/obj/item/ammo_box/magazine/lr30mag/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/lr30mag/update_icon_state()
	icon_state = "lmag-[CEILING(ammo_count(), 3)]"
