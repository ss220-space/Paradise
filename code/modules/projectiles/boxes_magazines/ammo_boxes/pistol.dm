// MARK: 9mm
/obj/item/ammo_box/c9mm
	icon_state = "9mmbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 30

/obj/item/ammo_box/rubber9mm
	icon_state = "9mmbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/rubber9mm
	max_ammo = 30

// MARK: 10mm
/obj/item/ammo_box/m10mm
	icon_state = "ammobox_10AP"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 60
	materials = list(MAT_METAL = 750)

/obj/item/ammo_box/m10mm/ap
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/m10mm/hp
	icon_state = "ammobox_10HP"
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/m10mm/fire
	icon_state = "ammobox_10incendiary"
	ammo_type = /obj/item/ammo_casing/c10mm/fire

// MARK: .40 N&R
/obj/item/ammo_box/fortynr
	icon_state = "40n&rbox"
	ammo_type = /obj/item/ammo_casing/fortynr
	max_ammo = 40
	materials = list(MAT_METAL = 1000)

// MARK: 7.62x25mm
/obj/item/ammo_box/a762x25
	icon_state = "ammobox_762x25"
	ammo_type = /obj/item/ammo_casing/ftt762
	max_ammo = 70

// MARK: .45
/obj/item/ammo_box/c45
	icon_state = "45NRbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 20

/obj/item/ammo_box/c45/ext
	icon_state = "ammobox_45"
	max_ammo = 40

/obj/item/ammo_box/rubber45
	icon_state = "45box-r"
	ammo_type = /obj/item/ammo_casing/rubber45
	max_ammo = 16

/obj/item/ammo_box/rubber45/ext
	icon_state = "ammobox_45"
	max_ammo = 40

// MARK: .45 N&R
/obj/item/ammo_box/dot45NR
	icon_state = "45NRbox"
	ammo_type = /obj/item/ammo_casing/c45nr
	max_ammo = 60

// MARK: .45 Colt
/obj/item/ammo_box/c45colt
	icon_state = "box_c45colt"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45colt
	max_ammo = 30

/obj/item/ammo_box/rubber45colt
	icon_state = "box_rubber45colt"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45colt/rubber
	max_ammo = 30

/obj/item/ammo_box/expansive45colt
	icon_state = "box_hp45colt"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45colt/hp
	max_ammo = 30

/obj/item/ammo_box/ap45colt
	icon_state = "box_ap45colt"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45colt/ap
	max_ammo = 30

// MARK: .50AE
/obj/item/ammo_box/m50
	icon_state = "ammobox_50AE"
	ammo_type = /obj/item/ammo_casing/a50
	max_ammo = 21

