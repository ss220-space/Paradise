/obj/item/ammo_box/magazine/toy
	gun_name = "игрушечного оружия"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	caliber = CALIBER_FOAM_FORCE

// MARK: SMG
/obj/item/ammo_box/magazine/toy/smg
	gun_name = "игрушечного пистолет-пулемёта \"Saber SMG\""
	icon_state = "smg9mm-20"
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smg/update_icon_state()
	icon_state = "smg9mm-[round(ammo_count()+1,4)]"

/obj/item/ammo_box/magazine/toy/smg/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

// MARK: Pistol
/obj/item/ammo_box/magazine/toy/pistol
	gun_name = "игрушечного пистолета FK-69 \"Стечкин\""
	icon_state = "9x19p"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/pistol/update_icon_state()
	icon_state = "9x19p-[ammo_count() ? "15" : "0"]"

// MARK: Enforcer
/obj/item/ammo_box/magazine/toy/enforcer
	gun_name = "игрушечного пистолета \"Блюститель\""
	icon_state = "enforcer"
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_box/magazine/toy/enforcer/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/enforcer/update_overlays()
	. = ..()
	var/ammo = ammo_count()
	if(ammo && is_riot())
		. += image('icons/obj/weapons/ammo.dmi', icon_state = "enforcer-rd")
	else if(ammo)
		. += image('icons/obj/weapons/ammo.dmi', icon_state = "enforcer-bd")

/obj/item/ammo_box/magazine/toy/enforcer/proc/is_riot()//if the topmost bullet is a riot dart
	var/ammo = ammo_count()
	if(!ammo)
		return FALSE
	if(istype(contents[length(contents)], /obj/item/ammo_casing/caseless/foam_dart/riot))
		return TRUE
	return FALSE

// MARK: C-20r
/obj/item/ammo_box/magazine/toy/smgm45
	gun_name = "игрушечного пистолет-пулемёта C-20r"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smgm45/update_icon_state()
	icon_state = "c20r45-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/toy/smgm45/riot

// MARK: L6 SAW
/obj/item/ammo_box/magazine/toy/m762
	gun_name = "игрушечного пулемёта L6 SAW"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	max_ammo = 100

/obj/item/ammo_box/magazine/toy/m762/update_icon_state()
	icon_state = "a762-[round(ammo_count(), 20)]"

/obj/item/ammo_box/magazine/toy/m762/riot

// MARK: Sniper rifle
/obj/item/ammo_box/magazine/toy/sniper_rounds
	gun_name = "игрушечной снайперской винтовки Bubz FX1000"
	icon_state = ".50mag"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper/riot
	max_ammo = 6
	caliber = CALIBER_FOAM_FORCE_SNIPER

/obj/item/ammo_box/magazine/toy/sniper_rounds/update_icon_state()
	return

/obj/item/ammo_box/magazine/toy/sniper_rounds/update_overlays()
	. = ..()
	var/ammo = ammo_count()
	if(ammo && istype(contents[length(contents)], /obj/item/ammo_casing/caseless/foam_dart/sniper/riot))
		. += ".50mag-r"
	else if(ammo)
		. += ".50mag-f"
