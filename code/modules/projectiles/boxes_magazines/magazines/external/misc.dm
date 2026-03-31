// MARK: .75 Gyro pistol
/obj/item/ammo_box/magazine/m75
	name = "specialized magazine (.75)"
	desc = "Магазин гиро-пистолета, предназначенный для патронов .75 калибра"
	icon_state = "75"
	ammo_type = /obj/item/ammo_casing/caseless/a75
	caliber = CALIBER_DOT_75
	multiple_sprites = 2
	max_ammo = 8

/obj/item/ammo_box/magazine/m75/get_ru_names()
	return list(
		NOMINATIVE = "магазин гиро-пистолета (.75)",
		GENITIVE = "магазина гиро-пистолета (.75)",
		DATIVE = "магазину гиро-пистолета (.75)",
		ACCUSATIVE = "магазина гиро-пистолета (.75)",
		INSTRUMENTAL = "магазином гиро-пистолета (.75)",
		PREPOSITIONAL = "магазине гиро-пистолета (.75)",
	)

// MARK: Speargun
/obj/item/ammo_box/magazine/internal/speargun
	name = "speargun internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/magspear
	caliber = CALIBER_SPEAR
	max_ammo = 1
