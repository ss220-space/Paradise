// MARK: .50 - Syndicate SR
/obj/item/ammo_box/magazine/sniper_rounds
	gun_name = "снайперской винтовки Bubz FX1000"
	icon_state = ".50mag"
	origin_tech = "combat=6"
	ammo_type = /obj/item/ammo_casing/point50
	max_ammo = 5
	caliber = CALIBER_DOT_50

/obj/item/ammo_box/magazine/sniper_rounds/update_icon_state()
	if(ammo_count())
		icon_state = "[initial(icon_state)]-ammo"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/ammo_box/magazine/sniper_rounds/soporific
	icon_state = "soporific"
	ammo_type = /obj/item/ammo_casing/soporific
	max_ammo = 3

/obj/item/ammo_box/magazine/sniper_rounds/explosive
	icon_state = "explosive"
	ammo_type = /obj/item/ammo_casing/explosive

/obj/item/ammo_box/magazine/sniper_rounds/haemorrhage
	icon_state = "haemorrhage"
	ammo_type = /obj/item/ammo_casing/haemorrhage

/obj/item/ammo_box/magazine/sniper_rounds/penetrator
	icon_state = "penetrator"
	ammo_type = /obj/item/ammo_casing/penetrator

// MARK: .50L - Compact Syndicate SR
/obj/item/ammo_box/magazine/sniper_rounds/compact
	gun_name = "снайперской винтовки Bubz Mini"
	ammo_type = /obj/item/ammo_casing/compact
	max_ammo = 4
	caliber = CALIBER_DOT_50L

/obj/item/ammo_box/magazine/sniper_rounds/compact/penetrator
	icon_state = "penetrator"
	ammo_type = /obj/item/ammo_casing/compact/penetrator
	max_ammo = 5

/obj/item/ammo_box/magazine/sniper_rounds/compact/soporific
	icon_state = "soporific"
	ammo_type = /obj/item/ammo_casing/compact/soporific
	max_ammo = 3

// MARK: .338 - AXMC
/obj/item/ammo_box/magazine/a338
	gun_name = "снайперской винтовки AXMC"
	icon_state = ".338mag"
	origin_tech = "combat=6"
	ammo_type = /obj/item/ammo_casing/a338
	max_ammo = 10
	caliber = CALIBER_DOT_338

/obj/item/ammo_box/magazine/a338/update_icon_state()
	if(ammo_count())
		icon_state = "[initial(icon_state)]-ammo"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/ammo_box/magazine/a338/soporific
	icon_state = ".338soporific"
	ammo_type = /obj/item/ammo_casing/a338_soporific
	max_ammo = 6

/obj/item/ammo_box/magazine/a338/explosive
	icon_state = ".338explosive"
	ammo_type = /obj/item/ammo_casing/a338_explosive

/obj/item/ammo_box/magazine/a338/haemorrhage
	icon_state = ".338haemorrhage"
	ammo_type = /obj/item/ammo_casing/a338_haemorrhage

/obj/item/ammo_box/magazine/a338/penetrator
	icon_state = ".338penetrator"
	ammo_type = /obj/item/ammo_casing/a338_penetrator
