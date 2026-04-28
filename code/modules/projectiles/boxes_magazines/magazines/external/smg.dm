// MARK: 9mm - Sparkle-A12
/obj/item/ammo_box/magazine/sparkle_a12
	gun_name = "пистолет-пулемета А9 \"Искра\""
	icon_state = "sparkle_a12"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 24

/obj/item/ammo_box/magazine/sparkle_a12/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/sparkle_a12/update_icon_state()
	icon_state = "[initial(icon_state)]_[CEILING(ammo_count() / 6, 1) * 6]"


// MARK: 9mm - UZI
/obj/item/ammo_box/magazine/uzim9mm
	gun_name = "пистолет-пулемета UZI"
	icon_state = "uzi9mm-32"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 32

/obj/item/ammo_box/magazine/uzim9mm/update_icon_state()
	icon_state = "uzi9mm-[round(ammo_count(),4)]"

// MARK: 9mm - Saber SMG
/obj/item/ammo_box/magazine/smgm9mm
	gun_name = "пистолет-пулемёта \"Saber SMG\""
	icon_state = "smg9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 21

/obj/item/ammo_box/magazine/smgm9mm/rubber
	ammo_type = /obj/item/ammo_casing/rubber9mm

/obj/item/ammo_box/magazine/smgm9mm/ap
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/magazine/smgm9mm/toxin
	ammo_type = /obj/item/ammo_casing/c9mm/tox

/obj/item/ammo_box/magazine/smgm9mm/fire
	ammo_type = /obj/item/ammo_casing/c9mm/inc

/obj/item/ammo_box/magazine/smgm9mm/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count()+1,4)]"

// MARK: 9mm - SFG-5
/obj/item/ammo_box/magazine/sfg9mm
	gun_name = "пистолет-пулемёта SFG-5"
	icon_state = "sfg5"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 30

/obj/item/ammo_box/magazine/sfg9mm/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count(), 30)]"

// MARK: .45 - C-20r
/obj/item/ammo_box/magazine/smgm45
	gun_name = "пистолет-пулемёта C-20r"
	icon_state = "c20r45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_DOT_45
	max_ammo = 20

/obj/item/ammo_box/magazine/smgm45/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),2)]"

// MARK: .45 - Tommy Gun
/obj/item/ammo_box/magazine/tommygunm45
	gun_name = "пистолет-пулемёта Томпсона"
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_DOT_45
	max_ammo = 50

// MARK: .45 N&R - SP-91-RC
/obj/item/ammo_box/magazine/sp91rc
	gun_name = "пистолет-пулемета SP-91-RC"
	icon_state = "45NRmag"
	ammo_type = /obj/item/ammo_casing/c45nr
	caliber = CALIBER_45NR
	max_ammo = 20
	materials = list(MAT_METAL = 3000)

/obj/item/ammo_box/magazine/sp91rc/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/sp91rc/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count(), 5)]"

// MARK: 7.62x25mm - PPSh
/obj/item/ammo_box/magazine/ppsh
	gun_name = "пистолет-пулемета ППШ"
	icon_state = "ppshDrum"
	origin_tech = "combat=3;syndicate=1"
	ammo_type = /obj/item/ammo_casing/ftt762
	caliber = CALIBER_7_DOT_62X25MM
	max_ammo = 71
	multiple_sprites = 2

// MARK: 4.6x30mm - WT-550 PDW
/obj/item/ammo_box/magazine/wt550m9
	gun_name = "пистолет-пулемета WT-550 PDW"
	icon_state = "46x30mmt"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = CALIBER_4_DOT_6X30MM
	max_ammo = 30

/obj/item/ammo_box/magazine/wt550m9/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/wt550m9/update_icon_state()
	icon_state = "46x30mmt-[round(ammo_count(),6)]"

/obj/item/ammo_box/magazine/wt550m9/wtap
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/magazine/wt550m9/wttx
	ammo_type = /obj/item/ammo_casing/c46x30mm/tox

/obj/item/ammo_box/magazine/wt550m9/wtic
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc
