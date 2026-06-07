// MARK: 12 ammo - Standart
/obj/item/ammo_box/magazine/m12g
	gun_name = "дробовиков с магазинным питанием"
	icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/magnum
	caliber = CALIBER_12G
	max_ammo = 12
	multiple_sprites = 2

/obj/item/ammo_box/magazine/cheap_m12g
	icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = CALIBER_12G
	max_ammo = 12
	multiple_sprites = 2
	color = COLOR_ASSEMBLY_BROWN

/obj/item/ammo_box/magazine/m12g/slug
	icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/m12g/stun
	icon_state = "m12gs"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/magazine/m12g/dragon
	icon_state = "m12gf"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/napalm

/obj/item/ammo_box/magazine/m12g/bioterror
	icon_state = "m12gt"
	ammo_type = /obj/item/ammo_casing/shotgun/bioterror

/obj/item/ammo_box/magazine/m12g/breach
	icon_state = "m12gmt"
	ammo_type = /obj/item/ammo_casing/shotgun/breaching

/obj/item/ammo_box/magazine/m12g/flechette
	icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

// MARK: 24 ammo - Standart
/obj/item/ammo_box/magazine/m12g/XtrLrg
	icon_state = "m12gXlBs"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 24

/obj/item/ammo_box/magazine/m12g/XtrLrg/flechette
	icon_state = "m12gXlSl"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/m12g/XtrLrg/slug
	icon_state = "m12gXlSl"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/m12g/XtrLrg/dragon
	icon_state = "m12gXlDb"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/napalm

// MARK: 8 ammo - C.A.T.S.
/obj/item/ammo_box/magazine/cats12g
	gun_name = "дробовика C.A.T.S."
	icon_state = "cats_mag_slug"
	ammo_type = /obj/item/ammo_casing/shotgun
	multiple_sprites = 2
	max_ammo = 8

/obj/item/ammo_box/magazine/cats12g/beanbang
	icon_state = "cats_mag_bean"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/cats12g/universal
	icon_state = "cats_mag"
	caliber = CALIBER_12G
	ammo_type = null

// MARK: 14 ammo - C.A.T.S.
/obj/item/ammo_box/magazine/cats12g/large
	icon_state = "cats_mag_large_slug"
	max_ammo = 14

/obj/item/ammo_box/magazine/cats12g/large/beanbag
	icon_state = "cats_mag_large_bean"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/cats12g/large/universal
	icon_state = "cats_mag_large"
	caliber = CALIBER_12G
	ammo_type = null
