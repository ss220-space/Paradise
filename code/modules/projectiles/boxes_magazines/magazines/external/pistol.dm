// MARK: 10mm - Stechkin
/obj/item/ammo_box/magazine/m10mm
	gun_name = "пистолета FK-69 \"Стечкин\""
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = CALIBER_10MM
	max_ammo = 10
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m10mm/fire
	icon_state = "9x19pI"
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/magazine/m10mm/hp
	icon_state = "9x19pH"
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/m10mm/ap
	icon_state = "9x19pA"
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/magazine/m10mm/update_icon_state()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "15" : "0"]"

// MARK: .45 - M1911
/obj/item/ammo_box/magazine/m45
	gun_name = "пистолета M1911"
	icon_state = "45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_DOT_45
	max_ammo = 8
	multiple_sprites = 1

// MARK: .40 S&W - SP-8
/obj/item/ammo_box/magazine/sp8
	gun_name = "пистолета SP-8"
	icon_state = "sp8mag"
	ammo_type = /obj/item/ammo_casing/fortynr
	max_ammo = 10
	caliber = CALIBER_40NR
	materials = list(MAT_METAL = 2500)

/obj/item/ammo_box/magazine/sp8/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/sp8/update_icon_state()
	icon_state = "sp8mag-[round(ammo_count(),2)]"

// MARK: .50 AE - Desert Eagle
/obj/item/ammo_box/magazine/m50
	gun_name = "пистолета \"Desert Eagle\""
	icon_state = "50ae"
	ammo_type = /obj/item/ammo_casing/a50
	caliber = CALIBER_DOT_50AE
	multiple_sprites = 1

// MARK: 9mm - Enforcer
/obj/item/ammo_box/magazine/enforcer
	gun_name = "пистолета \"Блюститель\""
	icon_state = "enforcer"
	ammo_type = /obj/item/ammo_casing/rubber9mm
	max_ammo = 8
	multiple_sprites = 1
	caliber = CALIBER_9MM

/obj/item/ammo_box/magazine/enforcer/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/enforcer/update_overlays()
	. = ..()
	if(ammo_count() && is_rubber())
		. += image('icons/obj/weapons/ammo.dmi', icon_state = "enforcer-r")

/obj/item/ammo_box/magazine/enforcer/proc/is_rubber()//if the topmost bullet is a rubber one
	var/ammo = ammo_count()
	if(!ammo)
		return FALSE
	if(istype(contents[length(contents)], /obj/item/ammo_casing/rubber9mm))
		return TRUE
	return FALSE

/obj/item/ammo_box/magazine/enforcer/lethal
	ammo_type = /obj/item/ammo_casing/c9mm

/obj/item/ammo_box/magazine/enforcer/extended
	max_ammo = 12
	start_empty = TRUE
	icon_state = "enforcer-ext"

// MARK: 9mm - APS
/obj/item/ammo_box/magazine/pistolm9mm
	gun_name = "АПС"
	icon_state = "9x19p-15"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/update_icon_state()
	icon_state = "9x19p-[ammo_count() ? "15" : "0"]"
