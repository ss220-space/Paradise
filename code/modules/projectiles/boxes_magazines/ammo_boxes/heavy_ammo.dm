// MARK: 7.62x54mm
/obj/item/ammo_box/a762x54
	icon_state = "ammobox_mosin"
	ammo_type = /obj/item/ammo_casing/a762x54
	max_ammo = 40

// MARK: 7.62x51mm
/obj/item/ammo_box/a762x51
	icon_state = "ammobox_762x51"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a762x51
	max_ammo = 60

/obj/item/ammo_box/a762x51/weak
	ammo_type = /obj/item/ammo_casing/a762x51/weak

/obj/item/ammo_box/a762x51/bleeding
	ammo_type = /obj/item/ammo_casing/a762x51/bleeding

/obj/item/ammo_box/a762x51/hollow
	ammo_type = /obj/item/ammo_casing/a762x51/hollow

/obj/item/ammo_box/a762x51/ap
	ammo_type = /obj/item/ammo_casing/a762x51/ap

/obj/item/ammo_box/a762x51/incen
	ammo_type = /obj/item/ammo_casing/a762x51/incen

// MARK: .50
/obj/item/ammo_box/sniper_rounds_penetrator
	icon_state = "ammobox_sniperPE"
	origin_tech = "combat=6"
	ammo_type = /obj/item/ammo_casing/penetrator
	max_ammo = 20

// MARK: .50L
/obj/item/ammo_box/sniper_rounds_compact
	icon_state = "ammobox_sniperCOMP"
	origin_tech = "combat=5"
	ammo_type = /obj/item/ammo_casing/compact
	max_ammo = 20

/obj/item/ammo_box/sniper_rounds_compact/penetrator
	ammo_type = /obj/item/ammo_casing/compact/penetrator

// MARK: .338
/obj/item/ammo_box/a338
	icon_state = "ammobox_338"
	origin_tech = "combat=5"
	ammo_type = /obj/item/ammo_casing/a338
	max_ammo = 20

/obj/item/ammo_box/a338/explosive
	ammo_type = /obj/item/ammo_casing/a338_explosive

/obj/item/ammo_box/a338/penetrator
	ammo_type = /obj/item/ammo_casing/a338_penetrator

