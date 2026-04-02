// MARK: 9mm - Sparkle-A12
/obj/item/ammo_box/magazine/sparkle_a12
	name = "Sparkle-A12 magazine (9mm)"
	desc = "Магазин пистолет пулемета А9 \"Искра\", заряженный патронами калибра 9 мм."
	icon_state = "sparkle_a12"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 24

/obj/item/ammo_box/magazine/sparkle_a12/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/sparkle_a12/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолет-пулемета А9 \"Искра\" (9 мм)",
		GENITIVE = "магазина пистолет-пулемета А9 \"Искра\" (9 мм)",
		DATIVE = "магазину пистолет-пулемета А9 \"Искра\" (9 мм)",
		ACCUSATIVE = "магазин пистолет-пулемета А9 \"Искра\" (9 мм)",
		INSTRUMENTAL = "магазином пистолет-пулемета А9 \"Искра\" (9 мм)",
		PREPOSITIONAL = "магазине пистолет-пулемета А9 \"Искра\" (9 мм)"
	)

/obj/item/ammo_box/magazine/sparkle_a12/update_icon_state()
	icon_state = "[initial(icon_state)][ammo_count() > 0 ? "" : "-e"]"

// MARK: 9mm - UZI SMG
/obj/item/ammo_box/magazine/uzim9mm
	name = "uzi magazine (9mm)"
	desc = "Магазин пистолет-пулемета \"UZI\", заряженный патронами калибра 9 мм."
	icon_state = "uzi9mm-32"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 32

/obj/item/ammo_box/magazine/uzim9mm/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолет-пулемета \"UZI\" (9 мм)",
		GENITIVE = "магазина пистолет-пулемета \"UZI\" (9 мм)",
		DATIVE = "магазину пистолет-пулемета \"UZI\" (9 мм)",
		ACCUSATIVE = "магазин пистолет-пулемета \"UZI\"(9 мм)",
		INSTRUMENTAL = "магазином пистолет-пулемета \"UZI\" (9 мм)",
		PREPOSITIONAL = "магазине пистолет-пулемета \"UZI\" (9 мм)",
	)

/obj/item/ammo_box/magazine/uzim9mm/update_icon_state()
	icon_state = "uzi9mm-[round(ammo_count(),4)]"

// MARK: 9mm - SMG
/obj/item/ammo_box/magazine/smgm9mm
	name = "SMG magazine (9mm)"
	desc = "Магазин пистолет-пулемёта SMG, предназначенный для патронов калибра 9 мм."
	icon_state = "smg9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 21

/obj/item/ammo_box/magazine/smgm9mm/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (9 мм)",
		GENITIVE = "магазина SMG (9 мм)",
		DATIVE = "магазину SMG (9 мм)",
		ACCUSATIVE = "магазина SMG(9 мм)",
		INSTRUMENTAL = "магазином SMG (9 мм)",
		PREPOSITIONAL = "магазине SMG (9 мм)",
	)

/obj/item/ammo_box/magazine/smgm9mm/rubber
	name = "magazine SMG (rubber)"
	desc = "Магазин пистолет-пулемёта SMG, предназначенный для резиновых патронов калибра 9 мм."
	ammo_type = /obj/item/ammo_casing/rubber9mm

/obj/item/ammo_box/magazine/smgm9mm/rubber/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (резиновый 9 мм)",
		GENITIVE = "магазина SMG (резиновый 9 мм)",
		DATIVE = "магазину SMG (резиновый 9 мм)",
		ACCUSATIVE = "магазина SMG (резиновый 9 мм)",
		INSTRUMENTAL = "магазином SMG (резиновый 9 мм)",
		PREPOSITIONAL = "магазине SMG (резиновый 9 мм)",
	)

/obj/item/ammo_box/magazine/smgm9mm/ap
	name = "SMG magazine (Armour Piercing 9mm)"
	desc = "Магазин пистолет-пулемёта SMG, предназначенный для бронебойных патронов калибра 9 мм."
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/magazine/smgm9mm/ap/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (бронебойный 9 мм)",
		GENITIVE = "магазина SMG (бронебойный 9 мм)",
		DATIVE = "магазину SMG (бронебойный 9 мм)",
		ACCUSATIVE = "магазина SMG (бронебойный 9 мм)",
		INSTRUMENTAL = "магазином SMG (бронебойный 9 мм)",
		PREPOSITIONAL = "магазине SMG (бронебойный 9 мм)",
	)

/obj/item/ammo_box/magazine/smgm9mm/toxin
	name = "SMG magazine (Toxin Tipped 9mm)"
	desc = "Магазин пистолет-пулемёта SMG, предназначенный для токсичных патронов калибра 9 мм."
	ammo_type = /obj/item/ammo_casing/c9mm/tox

/obj/item/ammo_box/magazine/smgm9mm/toxin/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (токсичный 9 мм)",
		GENITIVE = "магазина SMG (токсичный 9 мм)",
		DATIVE = "магазину SMG (токсичный 9 мм)",
		ACCUSATIVE = "магазина SMG (токсичный 9 мм)",
		INSTRUMENTAL = "магазином SMG (токсичный 9 мм)",
		PREPOSITIONAL = "магазине SMG (токсичный 9 мм)",
	)

/obj/item/ammo_box/magazine/smgm9mm/fire
	name = "SMG Magazine (Incendiary 9mm)"
	desc = "Магазин пистолет-пулемёта SMG, предназначенный для зажигательных патронов калибра 9 мм."
	ammo_type = /obj/item/ammo_casing/c9mm/inc

/obj/item/ammo_box/magazine/smgm9mm/fire/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (зажигательный 9 мм)",
		GENITIVE = "магазина SMG (зажигательный 9 мм)",
		DATIVE = "магазину SMG (зажигательный 9 мм)",
		ACCUSATIVE = "магазина SMG (зажигательный 9 мм)",
		INSTRUMENTAL = "магазином SMG (зажигательный 9 мм)",
		PREPOSITIONAL = "магазине SMG (зажигательный 9 мм)",
	)

/obj/item/ammo_box/magazine/smgm9mm/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count()+1,4)]"

// MARK: 9mm - SFG-5 SMG
/obj/item/ammo_box/magazine/sfg9mm
	name = "SFG Magazine (9mm)"
	desc = "Магазин пистолет-пулемёта SFG-5 SMG, предназначенный для патронов калибра 9 мм."
	icon_state = "sfg5"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 30

/obj/item/ammo_box/magazine/sfg9mm/get_ru_names()
	return list(
		NOMINATIVE = "магазин SFG-5 SMG (9 мм)",
		GENITIVE = "магазина SFG-5 SMG (9 мм)",
		DATIVE = "магазину SFG-5 SMG (9 мм)",
		ACCUSATIVE = "магазина SFG-5 SMG (9 мм)",
		INSTRUMENTAL = "магазином SFG-5 SMG (9 мм)",
		PREPOSITIONAL = "магазине SFG-5 SMG (9 мм)",
	)

/obj/item/ammo_box/magazine/sfg9mm/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count(), 30)]"

// MARK: .45 - C-20r
/obj/item/ammo_box/magazine/smgm45
	name = "SMG magazine (.45)"
	desc = "Магазин пистолет-пулемёта SMG, предназначенный для патронов .45 калибра."
	icon_state = "c20r45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_DOT_45
	max_ammo = 20

/obj/item/ammo_box/magazine/smgm45/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (.45)",
		GENITIVE = "магазина SMG (.45)",
		DATIVE = "магазину SMG (.45)",
		ACCUSATIVE = "магазина SMG(.45)",
		INSTRUMENTAL = "магазином SMG (.45)",
		PREPOSITIONAL = "магазине SMG (.45)",
	)

/obj/item/ammo_box/magazine/smgm45/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),2)]"

// MARK: .45 - Tommy Gun
/obj/item/ammo_box/magazine/tommygunm45
	name = "drum magazine (.45)"
	desc = "Барабанный магазин пистолет-пулемёта SMG, предназначенный для патронов .45 калибра."
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_DOT_45
	max_ammo = 50

/obj/item/ammo_box/magazine/tommygunm45/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин SMG (.45)",
		GENITIVE = "барабанного магазина SMG (.45)",
		DATIVE = "барабанному магазину SMG (.45)",
		ACCUSATIVE = "барабанный магазина SMG(.45)",
		INSTRUMENTAL = "барабанным магазином SMG (.45)",
		PREPOSITIONAL = "барабанном магазине SMG (.45)",
	)
// MARK: .45 N&R - SP-91-RC
/obj/item/ammo_box/magazine/sp91rc
	name = "SP-91-RC magazine (.45 N&R)"
	desc = "Магазин пистолет-пулемета \"SP-91-RC\", заряженный патронами калибра .45 N&R."
	icon_state = "45NRmag"
	ammo_type = /obj/item/ammo_casing/c45nr
	caliber = CALIBER_45NR
	max_ammo = 20
	materials = list(MAT_METAL = 3000)

/obj/item/ammo_box/magazine/sp91rc/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/sp91rc/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолет-пулемета \"SP-91-RC\" (.45 N&R)",
		GENITIVE = "магазина пистолет-пулемета \"SP-91-RC\" (.45 N&R)",
		DATIVE = "магазину пистолет-пулемета \"SP-91-RC\" (.45 N&R)",
		ACCUSATIVE = "магазин пистолет-пулемета \"SP-91-RC\" (.45 N&R)",
		INSTRUMENTAL = "магазином пистолет-пулемета \"SP-91-RC\" (.45 N&R)",
		PREPOSITIONAL = "магазине пистолет-пулемета \"SP-91-RC\" (.45 N&R)",
	)

/obj/item/ammo_box/magazine/sp91rc/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count(), 5)]"

// MARK: 7.62x25mm - PPSh
/obj/item/ammo_box/magazine/ppsh
	name = "PPSh drum (7.62x25mm)"
	desc = "Магазин к пистолет-пулемету ППШ, предназначенный для патронов калибра 7,62x25 мм."
	icon_state = "ppshDrum"
	origin_tech = "combat=3;syndicate=1"
	ammo_type = /obj/item/ammo_casing/ftt762
	caliber = CALIBER_7_DOT_62X25MM
	max_ammo = 71
	multiple_sprites = 2

/obj/item/ammo_box/magazine/ppsh/get_ru_names()
	return list(
		NOMINATIVE = "магазин ППШ (7,62x25 мм)",
		GENITIVE = "магазина ППШ (7,62x25 мм)",
		DATIVE = "магазину ППШ (7,62x25 мм)",
		ACCUSATIVE = "магазина ППШ (7,62x25 мм)",
		INSTRUMENTAL = "магазином ППШ (7,62x25 мм)",
		PREPOSITIONAL = "магазине ППШ (7,62x25 мм)",
	)

// MARK: 4.6x30mm - WT-550
/obj/item/ammo_box/magazine/wt550m9
	name = "wt550 magazine (4.6x30mm)"
	desc = "Магазин пистолет-пулемета \"WT-550 PDW\", заряженный патронами калибра 4,6x30 мм."
	icon_state = "46x30mmt"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = CALIBER_4_DOT_6X30MM
	max_ammo = 30

/obj/item/ammo_box/magazine/wt550m9/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/wt550m9/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемета \"WT-550 PDW\" (4,6x30 мм)",
		GENITIVE = "магазина пистолет-пулемета \"WT-550 PDW\" (4,6x30 мм)",
		DATIVE = "магазину пистолет-пулемета \"WT-550 PDW\" (4,6x30 мм)",
		ACCUSATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (4,6x30 мм)",
		INSTRUMENTAL = "магазином пистолет-пулемета \"WT-550 PDW\" (4,6x30 мм)",
		PREPOSITIONAL = "магазине пистолет-пулемета \"WT-550 PDW\" (4,6x30 мм)",
	)

/obj/item/ammo_box/magazine/wt550m9/update_icon_state()
	icon_state = "46x30mmt-[round(ammo_count(),6)]"

/obj/item/ammo_box/magazine/wt550m9/wtap
	name = "wt550 magazine (Armour Piercing 4.6x30mm)"
	desc = "Магазин пистолет-пулемета \"WT-550 PDW\", заряженный бронебойными патронами калибра 4,6x30 мм."
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/magazine/wt550m9/wtap/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (бронебойные 4,6x30 мм)",
		GENITIVE = "магазина пистолет-пулемета \"WT-550 PDW\" (бронебойные 4,6x30 мм)",
		DATIVE = "магазину пистолет-пулемета \"WT-550 PDW\" (бронебойные 4,6x30 мм)",
		ACCUSATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (бронебойные 4,6x30 мм)",
		INSTRUMENTAL = "магазином пистолет-пулемета \"WT-550 PDW\" (бронебойные 4,6x30 мм)",
		PREPOSITIONAL = "магазине пистолет-пулемета \"WT-550 PDW\" (бронебойные 4,6x30 мм)",
	)

/obj/item/ammo_box/magazine/wt550m9/wttx
	name = "wt550 magazine (Toxin Tipped 4.6x30mm)"
	desc = "Магазин пистолет-пулемета \"WT-550 PDW\", заряженный токсичными патронами калибра 4,6x30 мм."
	ammo_type = /obj/item/ammo_casing/c46x30mm/tox

/obj/item/ammo_box/magazine/wt550m9/wttx/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (токсичные 4,6x30 мм)",
		GENITIVE = "магазина пистолет-пулемета \"WT-550 PDW\" (токсичные 4,6x30 мм)",
		DATIVE = "магазину пистолет-пулемета \"WT-550 PDW\" (токсичные 4,6x30 мм)",
		ACCUSATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (токсичные 4,6x30 мм)",
		INSTRUMENTAL = "магазином пистолет-пулемета \"WT-550 PDW\" (токсичные 4,6x30 мм)",
		PREPOSITIONAL = "магазине пистолет-пулемета \"WT-550 PDW\" (токсичные 4,6x30 мм)",
	)

/obj/item/ammo_box/magazine/wt550m9/wtic
	name = "wt550 magazine (Incendiary 4.6x30mm)"
	desc = "Магазин пистолет-пулемета \"WT-550 PDW\", заряженный зажигательными патронами калибра 4,6x30 мм."
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc

/obj/item/ammo_box/magazine/wt550m9/wtic/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (зажигательные 4,6x30 мм)",
		GENITIVE = "магазина пистолет-пулемета \"WT-550 PDW\" (зажигательные 4,6x30 мм)",
		DATIVE = "магазину пистолет-пулемета \"WT-550 PDW\" (зажигательные 4,6x30 мм)",
		ACCUSATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (зажигательные 4,6x30 мм)",
		INSTRUMENTAL = "магазином пистолет-пулемета \"WT-550 PDW\" (зажигательные 4,6x30 мм)",
		PREPOSITIONAL = "магазине пистолет-пулемета \"WT-550 PDW\" (зажигательные 4,6x30 мм)",
	)
