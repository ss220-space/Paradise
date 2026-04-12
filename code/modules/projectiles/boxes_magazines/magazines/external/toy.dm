/obj/item/ammo_box/magazine/toy
	name = "foam force META magazine"
	desc = "Магазин предназначенный для пенных патронов."
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	caliber = CALIBER_FOAM_FORCE

/obj/item/ammo_box/magazine/toy/get_ru_names()
	return list(
		NOMINATIVE = "магазин пенных патронов",
		GENITIVE = "магазина пенных патронов",
		DATIVE = "магазину пенных патронов",
		ACCUSATIVE = "магазин пенных патронов",
		INSTRUMENTAL = "магазином пенных патронов",
		PREPOSITIONAL = "магазине пенных патронов",
	)

// MARK: SMG
/obj/item/ammo_box/magazine/toy/smg
	name = "foam force SMG magazine"
	desc = "Магазин игрушечного SMG, предназначенный для пенных патронов."
	icon_state = "smg9mm-20"
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smg/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (пенный патрон)",
		GENITIVE = "магазина SMG (пенный патрон)",
		DATIVE = "магазину SMG (пенный патрон)",
		ACCUSATIVE = "магазин SMG (пенный патрон)",
		INSTRUMENTAL = "магазином SMG (пенный патрон)",
		PREPOSITIONAL = "магазине SMG (пенный патрон)",
	)

/obj/item/ammo_box/magazine/toy/smg/update_icon_state()
	icon_state = "smg9mm-[round(ammo_count()+1,4)]"

/obj/item/ammo_box/magazine/toy/smg/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

// MARK: Pistol
/obj/item/ammo_box/magazine/toy/pistol
	name = "foam force pistol magazine"
	desc = "Магазин игрушечного пистолета, предназначенный для пенных патронов."
	icon_state = "9x19p"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/toy/pistol/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета (пенный патрон)",
		GENITIVE = "магазина пистолета (пенный патрон)",
		DATIVE = "магазину пистолета (пенный патрон)",
		ACCUSATIVE = "магазин пистолета (пенный патрон)",
		INSTRUMENTAL = "магазином пистолета (пенный патрон)",
		PREPOSITIONAL = "магазине пистолета (пенный патрон)",
	)

/obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/pistol/update_icon_state()
	icon_state = "9x19p-[ammo_count() ? "15" : "0"]"

// MARK: Enforcer
/obj/item/ammo_box/magazine/toy/enforcer
	name = "foam enforcer magazine"
	desc = "Магазин игрушечного пистолета \"Блюститель\", предназначенный для пенных патронов."
	icon_state = "enforcer"
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_box/magazine/toy/enforcer/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Блюститель\" (пенный патрон)",
		GENITIVE = "магазина пистолета \"Блюститель\" (пенный патрон)",
		DATIVE = "магазину пистолета \"Блюститель\" (пенный патрон)",
		ACCUSATIVE = "магазин пистолета \"Блюститель\" (пенный патрон)",
		INSTRUMENTAL = "магазином пистолета \"Блюститель\" (пенный патрон)",
		PREPOSITIONAL = "магазине пистолета \"Блюститель\" (пенный патрон)",
	)

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
	name = "donksoft SMG magazine"
	desc = "Магазин игрушечного C-20r SMG, предназначенный для пенных патронов."
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smgm45/get_ru_names()
	return list(
		NOMINATIVE = "магазин C-20r SMG (пенный патрон)",
		GENITIVE = "магазина C-20r SMG (пенный патрон)",
		DATIVE = "магазину C-20r SMG (пенный патрон)",
		ACCUSATIVE = "магазин C-20r SMG (пенный патрон)",
		INSTRUMENTAL = "магазином C-20r SMG (пенный патрон)",
		PREPOSITIONAL = "магазине C-20r SMG (пенный патрон)",
	)

/obj/item/ammo_box/magazine/toy/smgm45/update_icon_state()
	icon_state = "c20r45-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/toy/smgm45/riot

// MARK: L6 SAW
/obj/item/ammo_box/magazine/toy/m762
	name = "donksoft box magazine"
	desc = "Магазин игрушечного L6 SAW, предназначенный для пенных патронов."
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	max_ammo = 100

/obj/item/ammo_box/magazine/toy/m762/get_ru_names()
	return list(
		NOMINATIVE = "магазин L6 SAW (пенный патрон)",
		GENITIVE = "магазина L6 SAW (пенный патрон)",
		DATIVE = "магазину L6 SAW (пенный патрон)",
		ACCUSATIVE = "магазин L6 SAW (пенный патрон)",
		INSTRUMENTAL = "магазином L6 SAW (пенный патрон)",
		PREPOSITIONAL = "магазине L6 SAW (пенный патрон)",
	)

/obj/item/ammo_box/magazine/toy/m762/update_icon_state()
	icon_state = "a762-[round(ammo_count(), 20)]"

/obj/item/ammo_box/magazine/toy/m762/riot

// MARK: Sniper rifle
/obj/item/ammo_box/magazine/toy/sniper_rounds
	name = "donksoft Sniper magazine"
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
