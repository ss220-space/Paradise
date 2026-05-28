// MARK: 7.62x51mm - L6 SAW
/obj/item/ammo_box/magazine/l6saw
	gun_name = "пулемёта L6 SAW"
	icon_state = "a762"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a762x51/weak
	caliber = CALIBER_7_DOT_62X51MM
	max_ammo = 100

/obj/item/ammo_box/magazine/l6saw/update_icon_state()
	icon_state = "a762-[round(ammo_count(), 20)]"

/obj/item/ammo_box/magazine/l6saw/bleeding
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a762x51/bleeding

/obj/item/ammo_box/magazine/l6saw/hollow
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a762x51/hollow

/obj/item/ammo_box/magazine/l6saw/ap
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/a762x51/ap

/obj/item/ammo_box/magazine/l6saw/incen
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/a762x51/incen
