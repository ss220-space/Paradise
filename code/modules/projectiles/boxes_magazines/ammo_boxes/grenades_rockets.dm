// MARK: .40mm
/obj/item/ammo_box/a40mm
	icon_state = "40mm"
	ammo_type = /obj/item/ammo_casing/a40mm
	max_ammo = 4
	multiple_sprites = 1

/obj/item/ammo_box/a40mm/get_ammo_descriptor()
	return "выстрелов"

// MARK: .40mm - GL-06
/obj/item/ammo_box/secgl
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "secgl_box_gas"
	ammo_type = /obj/item/ammo_casing/a40mm/secgl
	max_ammo = 4

/obj/item/ammo_box/secgl/get_ammo_descriptor()
	return "выстрелов"

/obj/item/ammo_box/secgl/solid
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/solid
	icon_state = "secgl_box_solid"

/obj/item/ammo_box/secgl/flash
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/flash
	icon_state = "secgl_box_flash"

/obj/item/ammo_box/secgl/gas
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/gas

/obj/item/ammo_box/secgl/barricade
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/barricade
	icon_state = "secgl_box_barricade"

/obj/item/ammo_box/secgl/exp
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/exp
	icon_state = "secgl_box_exp"

/obj/item/ammo_box/secgl/paint
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/paint
	icon_state = "secgl_box_paint"
