// MARK: 7.62x51mm - L6 SAW
/obj/item/ammo_box/magazine/l6saw
	name = "box magazine (7.62x51mm)"
	icon_state = "a762"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a762x51/weak
	caliber = CALIBER_7_DOT_62X51MM
	max_ammo = 100

/obj/item/ammo_box/magazine/l6saw/bleeding
	name = "box magazine (Bleeding 7.62x51mm)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a762x51/bleeding

/obj/item/ammo_box/magazine/l6saw/hollow
	name = "box magazine (Hollow-Point 7.62x51mm)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a762x51/hollow

/obj/item/ammo_box/magazine/l6saw/ap
	name = "box magazine (Armor Penetrating 7.62x51mm)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/a762x51/ap

/obj/item/ammo_box/magazine/l6saw/incen
	name = "box magazine (Incendiary 7.62x51mm)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/a762x51/incen

/obj/item/ammo_box/magazine/l6saw/update_icon_state()
	icon_state = "a762-[round(ammo_count(), 20)]"

