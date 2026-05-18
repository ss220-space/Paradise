// MARK: Cylinder magazines
/obj/item/ammo_box/magazine/internal/cylinder/rev38
	name = "detective revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = CALIBER_DOT_38
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible
	name = "finger gun cylinder"
	desc = "Wait, what?"
	ammo_type = /obj/item/ammo_casing/c38/invisible

/obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible/fake
	ammo_type = /obj/item/ammo_casing/c38/invisible/fake

/obj/item/ammo_box/magazine/internal/cylinder/taurus
	name = "taurus revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c45colt/rubber
	caliber = CALIBER_DOT_45_COLT
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/rsh_12
	name = "rsh-12 revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c12_dot_7X55
	caliber = CALIBER_12_DOT_7X55MM
	max_ammo = 5

/obj/item/ammo_box/magazine/internal/cylinder/rev762
	name = "nagant revolver cylinder"
	ammo_type = /obj/item/ammo_casing/n762
	caliber = CALIBER_7_DOT_62X38MM

/obj/item/ammo_box/magazine/internal/cylinder/rev36
	name = ".36 revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c38/c36
	caliber = CALIBER_DOT_36
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/cap
	name = "cap gun revolver cylinder"
	ammo_type = /obj/item/ammo_casing/cap
	caliber = CALIBER_CAP

/obj/item/ammo_box/magazine/internal/cylinder/ga12
	name = ".12 revolver cylinder"
	ammo_type = /obj/item/ammo_casing/shotgun
	caliber = CALIBER_12G
	max_ammo = 3

// MARK: Improvised revolvers
/obj/item/ammo_box/magazine/internal/cylinder/improvised
	gun_name = "импровизированного револьвера"
	icon = 'icons/obj/improvised.dmi'
	icon_state = "rev_cylinder"
	ammo_type = null
	start_empty = TRUE
	caliber = list(CALIBER_DOT_257)
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/cylinder/improvised/get_ru_names()
	return list(
		NOMINATIVE = "кустарный барабан [gun_name] [get_cartridge_marking()]",
		GENITIVE = "кустарного барабана [gun_name] [get_cartridge_marking()]",
		DATIVE = "кустарному барабану [gun_name] [get_cartridge_marking()]",
		ACCUSATIVE = "кустарный барабан [gun_name] [get_cartridge_marking()]",
		INSTRUMENTAL = "кустарным барабаном [gun_name] [get_cartridge_marking()]",
		PREPOSITIONAL = "кустарном барабане [gun_name] [get_cartridge_marking()]",
	)

/obj/item/ammo_box/magazine/internal/cylinder/improvised/ammo_suitability(obj/item/ammo_casing/new_casing)
	if(!new_casing || !(new_casing.caliber in caliber))
		return FALSE
	return TRUE

/obj/item/ammo_box/magazine/internal/cylinder/improvised/get_cartridge_marking()
	return jointext(caliber, "/")

/obj/item/ammo_box/magazine/internal/cylinder/improvised/steel
	extra_info = "Совместим с патронами обоих калибров."
	icon_state = "s_rev_cylinder"
	caliber = list(CALIBER_DOT_257, CALIBER_DOT_38)
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/improvised/steel/get_ru_names()
	return list(
		NOMINATIVE = "стальной барабан [gun_name] [get_cartridge_marking()]",
		GENITIVE = "стального барабана [gun_name] [get_cartridge_marking()]",
		DATIVE = "стальному барабану [gun_name] [get_cartridge_marking()]",
		ACCUSATIVE = "стальной барабан [gun_name] [get_cartridge_marking()]",
		INSTRUMENTAL = "стальным барабаном [gun_name] [get_cartridge_marking()]",
		PREPOSITIONAL = "стальном барабане [gun_name] [get_cartridge_marking()]",
	)

// MARK: Russian roulette .357
/obj/item/ammo_box/magazine/internal/rus357
	name = "russian revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = CALIBER_DOT_357
	max_ammo = 6
	multiload = FALSE
	start_empty = TRUE

/obj/item/ammo_box/magazine/internal/rus357/Initialize(mapload)
	. = ..()
	stored_ammo += new ammo_type(src)	// We only want 1 bullet in there

/obj/item/ammo_box/magazine/internal/rus357/ammo_count(countempties = TRUE)
	. = 0
	for(var/obj/item/ammo_casing/bullet in stored_ammo)
		if(bullet.BB || countempties)
			.++
