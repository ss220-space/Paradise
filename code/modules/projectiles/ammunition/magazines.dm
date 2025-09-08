// MARK: Internal magazines
/obj/item/ammo_box/magazine/internal
	desc = "Oh god, this shouldn't be here!"
	can_fast_load = TRUE


//internals magazines are accessible, so replace spent ammo if full when trying to put a live one in
/obj/item/ammo_box/magazine/internal/give_round(obj/item/ammo_casing/new_casing, replace_spent = TRUE, count_chambered = FALSE, mob/user)
	. = ..()


// Revolver internal mags
/obj/item/ammo_box/magazine/internal/cylinder
	name = "revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = CALIBER_DOT_357
	max_ammo = 7


/obj/item/ammo_box/magazine/internal/cylinder/Initialize(mapload)
	. = ..()
	if(start_empty)
		for(var/i in 1 to max_ammo)
			stored_ammo += null	// thats right, we fill empty cylinders with nulls


/obj/item/ammo_box/magazine/internal/cylinder/ammo_count(countempties = TRUE)
	. = 0
	for(var/obj/item/ammo_casing/bullet in stored_ammo)
		if(bullet.BB || countempties)
			.++


/obj/item/ammo_box/magazine/internal/cylinder/get_round(keep = FALSE)
	rotate()

	var/b = stored_ammo[1]
	if(!keep)
		stored_ammo[1] = null

	return b

/obj/item/ammo_box/magazine/internal/cylinder/proc/rotate()
	var/b = stored_ammo[1]
	stored_ammo.Cut(1,2)
	stored_ammo.Insert(0, b)

/obj/item/ammo_box/magazine/internal/cylinder/proc/spin()
	for(var/i in 1 to rand(0, max_ammo*2))
		rotate()


/obj/item/ammo_box/magazine/internal/cylinder/give_round(obj/item/ammo_casing/new_casing, replace_spent = FALSE, count_chambered = FALSE, mob/user)
	if(!ammo_suitability(new_casing))
		return FALSE

	for(var/i in 1 to length(stored_ammo))
		var/obj/item/ammo_casing/casing = stored_ammo[i]
		if(!casing || !casing.BB) // found a spent ammo
			if(user && new_casing.loc == user && !user.drop_transfer_item_to_loc(new_casing, src))
				return FALSE
			stored_ammo[i] = new_casing
			if(new_casing.loc != src)
				new_casing.forceMove(src)
			if(casing)
				casing.forceMove(drop_location())
				playsound(casing.loc, casing.casing_drop_sound, 60, TRUE)
				casing.pixel_x = rand(-10, 10)
				casing.pixel_y = rand(-10, 10)
				casing.setDir(pick(GLOB.alldirs))
				casing.update_appearance()
				casing.SpinAnimation(10, 1)
			return TRUE

	return FALSE


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

/obj/item/ammo_box/magazine/internal/cylinder/rev762
	name = "nagant revolver cylinder"
	ammo_type = /obj/item/ammo_casing/n762
	caliber = CALIBER_7_DOT_62X38MM
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/rev36
	name = ".36 revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c38/c36
	caliber = CALIBER_DOT_36
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/improvised
	name = "improvised bullet cylinder"
	desc = "A roughly made revolver cylinder."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "rev_cylinder"
	ammo_type = null
	start_empty = TRUE
	caliber = list(CALIBER_DOT_257)
	max_ammo = 4


/obj/item/ammo_box/magazine/internal/cylinder/improvised/ammo_suitability(obj/item/ammo_casing/new_casing)
	if(!new_casing || !(new_casing.caliber in caliber))
		return FALSE
	return TRUE


/obj/item/ammo_box/magazine/internal/cylinder/improvised/steel
	name = "steel bullet cylinder"
	desc = "High quality steel revolver cylinder with increased amount of bullets."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "s_rev_cylinder"
	caliber = list(CALIBER_DOT_257, CALIBER_DOT_38)
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/cap
	name = "cap gun revolver cylinder"
	desc = "Oh god, this shouldn't be here!"
	ammo_type = /obj/item/ammo_casing/cap
	caliber = CALIBER_CAP
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/ga12
	name = ".12 revolver cylinder"
	ammo_type = /obj/item/ammo_casing/shotgun
	caliber = CALIBER_12X70
	max_ammo = 3

// Shotgun internal mags
/obj/item/ammo_box/magazine/internal/shot
	name = "shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = CALIBER_12X70
	max_ammo = 4
	multiload = FALSE


/obj/item/ammo_box/magazine/internal/shot/ammo_count(countempties = TRUE)
	. = 0
	for(var/obj/item/ammo_casing/bullet in stored_ammo)
		if(bullet.BB || countempties)
			.++


/obj/item/ammo_box/magazine/internal/shot/tube
	name = "dual feed shotgun internal tube"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/shot/lethal
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/internal/shot/com
	name = "combat shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/dual
	name = "double-barrel shotgun internal magazine"
	max_ammo = 2

/obj/item/ammo_box/magazine/internal/shot/improvised
	name = "improvised shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/shot/improvised/cane
	ammo_type = /obj/item/ammo_casing/shotgun/assassination

/obj/item/ammo_box/magazine/internal/shot/riot
	name = "riot shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/riot/short
	max_ammo = 3

/obj/item/ammo_box/magazine/internal/shot/riot/buckshot
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/internal/grenadelauncher
	name = "grenade launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = CALIBER_40MM
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = null
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/speargun
	name = "speargun internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/magspear
	caliber = CALIBER_SPEAR
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/rocketlauncher
	name = "rocket launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/rocket
	caliber = CALIBER_84MM
	max_ammo = 1

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


/obj/item/ammo_box/magazine/internal/boltaction
	name = "bolt action rifle internal magazine"
	desc = "Oh god, this shouldn't be here!"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = CALIBER_7_DOT_62X54MM
	max_ammo = 5
	multiload = TRUE

/obj/item/ammo_box/magazine/internal/boltaction/enchanted
	max_ammo =1
	ammo_type = /obj/item/ammo_casing/a762/enchanted

/obj/item/ammo_box/magazine/internal/shot/toy
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	caliber = CALIBER_FOAM_FORCE
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/shot/toy/crossbow
	max_ammo = 5

/obj/item/ammo_box/magazine/internal/shot/toy/tommygun
	max_ammo = 10

// MARK: External magazines
/obj/item/ammo_box/magazine
	materials = list(MAT_METAL = 2000)
	can_fast_load = FALSE

/obj/item/ammo_box/magazine/m10mm
	name = "pistol magazine (10mm)"
	desc = "Магазин пистолета \"Стечкин\", заряженный патронами калибра 10 мм. Эти патроны примерно в два раза менее эффективны, чем патроны .357 калибра."
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = CALIBER_10MM
	max_ammo = 15
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m10mm/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Стечкин\" (10 мм)",
		GENITIVE = "магазина пистолета \"Стечкин\" (10 мм)",
		DATIVE = "магазину пистолета \"Стечкин\" (10 мм)",
		ACCUSATIVE = "магазин пистолета \"Стечкин\" (10 мм)",
		INSTRUMENTAL = "магазином пистолета \"Стечкин\" (10 мм)",
		PREPOSITIONAL = "магазине пистолета \"Стечкин\" (10 мм)"
	)

/obj/item/ammo_box/magazine/m10mm/fire
	name = "pistol magazine (10mm incendiary)"
	desc = "Магазин пистолета \"Стечкин\", заряженный зажигательными патронами калибра 10 мм. Эти патроны поджигают цель при попадании."
	icon_state = "9x19pI"
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/magazine/m10mm/fire/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Стечкин\" (зажигательные 10 мм)",
		GENITIVE = "магазина пистолета \"Стечкин\" (зажигательные 10 мм)",
		DATIVE = "магазину пистолета \"Стечкин\" (зажигательные 10 мм)",
		ACCUSATIVE = "магазин пистолета \"Стечкин\" (зажигательные 10 мм)",
		INSTRUMENTAL = "магазином пистолета \"Стечкин\" (зажигательные 10 мм)",
		PREPOSITIONAL = "магазине пистолета \"Стечкин\" (зажигательные 10 мм)"
	)

/obj/item/ammo_box/magazine/m10mm/hp
	name = "pistol magazine (10mm HP)"
	desc = "Магазин пистолета \"Стечкин\", заряженный экспансивными патронами калибра 10 мм. Эти патроны наносят намного больше повреждений, чем стандартные, но они совершенно бесполезны против брони."
	icon_state = "9x19pH"
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/m10mm/hp/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Стечкин\" (экспансивные 10 мм)",
		GENITIVE = "магазина пистолета \"Стечкин\" (экспансивные 10 мм)",
		DATIVE = "магазину пистолета \"Стечкин\" (экспансивные 10 мм)",
		ACCUSATIVE = "магазин пистолета \"Стечкин\" (экспансивные 10 мм)",
		INSTRUMENTAL = "магазином пистолета \"Стечкин\" (экспансивные 10 мм)",
		PREPOSITIONAL = "магазине пистолета \"Стечкин\" (экспансивные 10 мм)"
	)

/obj/item/ammo_box/magazine/m10mm/ap
	name = "pistol magazine (10mm AP)"
	desc = "Магазин пистолета \"Стечкин\", заряженный бронебойными патронами калибра 10 мм. Эти патроны наносят немного меньше повреждений, чем стандартные, но обладают высокой пробивной силой."
	icon_state = "9x19pA"
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/magazine/m10mm/ap/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Стечкин\" (бронебойные 10 мм)",
		GENITIVE = "магазина пистолета \"Стечкин\" (бронебойные 10 мм)",
		DATIVE = "магазину пистолета \"Стечкин\" (бронебойные 10 мм)",
		ACCUSATIVE = "магазин пистолета \"Стечкин\" (бронебойные 10 мм)",
		INSTRUMENTAL = "магазином пистолета \"Стечкин\" (бронебойные 10 мм)",
		PREPOSITIONAL = "магазине пистолета \"Стечкин\" (бронебойные 10 мм)"
	)

/obj/item/ammo_box/magazine/m10mm/update_icon_state()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "15" : "0"]"

/obj/item/ammo_box/magazine/m45
	name = "handgun magazine (.45)"
	desc = "Магазин пистолета \"M1911\", заряженный патронами .45 калибра. Эти патроны обладают сильным останавливающим действием, способным сбить с ног большинство целей, однако они не наносят серьёзных повреждений."
	icon_state = "45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_DOT_45
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_box/magazine/m45/get_ru_names()
	return list(
		NOMINATIVE = "пистолетный магазин пистолета \"M1911\" (.45)",
		GENITIVE = "магазина пистолета \"M1911\" (.45)",
		DATIVE = "магазину пистолета \"M1911\" (.45)",
		ACCUSATIVE = "магазин пистолета \"M1911\" (.45)",
		INSTRUMENTAL = "магазином пистолета \"M1911\" (.45)",
		PREPOSITIONAL = "магазине пистолета \"M1911\" (.45)"
	)

/obj/item/ammo_box/magazine/enforcer
	name = "handgun magazine (9mm rubber)"
	desc = "Магазин пистолета \"Блюститель\", заряженный нелетальными патронами калибра 9 мм. Эти патроны обладают хорошим останавливающим действием, способным сбить с ног большинство целей не нанося значительных повреждений."
	icon_state = "enforcer"
	ammo_type = /obj/item/ammo_casing/rubber9mm
	max_ammo = 8
	multiple_sprites = 1
	caliber = CALIBER_9MM

/obj/item/ammo_box/magazine/enforcer/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Блюститель\" (нелетальные 9 мм)",
		GENITIVE = "магазина пистолета \"Блюститель\" (нелетальные 9 мм)",
		DATIVE = "магазину пистолета \"Блюститель\" (нелетальные 9 мм)",
		ACCUSATIVE = "магазин пистолета \"Блюститель\" (нелетальные 9 мм)",
		INSTRUMENTAL = "магазином пистолета \"Блюститель\" (нелетальные 9 мм)",
		PREPOSITIONAL = "магазине пистолета \"Блюститель\" (нелетальные 9 мм)"
	)

/obj/item/ammo_box/magazine/enforcer/update_overlays()
	. = ..()
	if(ammo_count() && is_rubber())
		. += image('icons/obj/weapons/ammo.dmi', icon_state = "enforcer-r")


/obj/item/ammo_box/magazine/enforcer/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		. += span_notice("В нем заряжены патроны с [is_rubber() ? "резиновыми" : "летальными"] пулями.") //only can see the topmost one.

/obj/item/ammo_box/magazine/enforcer/proc/is_rubber()//if the topmost bullet is a rubber one
	var/ammo = ammo_count()
	if(!ammo)
		return FALSE
	if(istype(contents[contents.len], /obj/item/ammo_casing/rubber9mm))
		return TRUE
	return FALSE

/obj/item/ammo_box/magazine/enforcer/lethal
	name = "handgun magazine (9mm)"
	desc = "Магазин пистолета \"Блюститель\", заряженный патронами калибра 9 мм. Стандартные патроны для пистолета \"Блюститель\" службы безопасности."
	ammo_type = /obj/item/ammo_casing/c9mm

/obj/item/ammo_box/magazine/enforcer/lethal/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Блюститель\" (9 мм)",
		GENITIVE = "магазина пистолета \"Блюститель\" (9 мм)",
		DATIVE = "магазину пистолета \"Блюститель\" (9 мм)",
		ACCUSATIVE = "магазин пистолета \"Блюститель\" (9 мм)",
		INSTRUMENTAL = "магазином пистолета \"Блюститель\" (9 мм)",
		PREPOSITIONAL = "магазине пистолета \"Блюститель\" (9 мм)"
	)

/obj/item/ammo_box/magazine/enforcer/extended
	name = "extended handgun magazine (9mm)"
	desc = "Расширенный магазин пистолета \"Блюститель\", заряжается патронами калибра 9 мм. Эти патроны обладают хорошим останавливающим действием, способным сбить с ног большинство целей, не нанося значительных повреждений."
	max_ammo = 12
	start_empty = TRUE
	icon_state = "enforcer-ext"

/obj/item/ammo_box/magazine/enforcer/extended/get_ru_names()
	return list(
		NOMINATIVE = "расширенный магазин пистолета \"Блюститель\" (9 мм)",
		GENITIVE = "расширенного магазина пистолета \"Блюститель\" (9 мм)",
		DATIVE = "расширенному магазину пистолета \"Блюститель\" (9 мм)",
		ACCUSATIVE = "расширенный магазин пистолета \"Блюститель\" (9 мм)",
		INSTRUMENTAL = "расширенным магазином пистолета \"Блюститель\" (9 мм)",
		PREPOSITIONAL = "расширенном магазине пистолета \"Блюститель\" (9 мм)"
	)

/obj/item/ammo_box/magazine/sp8
	name = "handgun magazine .40 S&W"
	desc = "Магазин пистолета \"SP-8\", заряженный патронами .40 калибра S&W."
	icon_state = "sp8mag"
	ammo_type = /obj/item/ammo_casing/fortynr
	max_ammo = 10
	caliber = CALIBER_40NR

/obj/item/ammo_box/magazine/sp8/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"SP-8\" (.40 S&W)",
		GENITIVE = "магазина пистолета \"SP-8\" (.40 S&W)",
		DATIVE = "магазину пистолета \"SP-8\" (.40 S&W)",
		ACCUSATIVE = "магазин пистолета \"SP-8\" (.40 S&W)",
		INSTRUMENTAL = "магазином пистолета \"SP-8\" (.40 S&W)",
		PREPOSITIONAL = "магазине пистолета \"SP-8\" (.40 S&W)"
	)

/obj/item/ammo_box/magazine/sp8/update_icon_state()
	icon_state = "sp8mag-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/wt550m9
	name = "wt550 magazine (4.6x30mm)"
	desc = "Магазин пистолет-пулемета \"WT-550 PDW\", заряженный патронами калибра 4,6x30 мм."
	icon_state = "46x30mmt-20"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = CALIBER_4_DOT_6X30MM
	max_ammo = 30

/obj/item/ammo_box/magazine/wt550m9/get_ru_names()
	return list(
		NOMINATIVE = "пистолет-пулемета \"WT-550 PDW\" (4,6x30 мм)",
		GENITIVE = "магазина пистолет-пулемета \"WT-550 PDW\" (4,6x30 мм)",
		DATIVE = "магазину пистолет-пулемета \"WT-550 PDW\" (4,6x30 мм)",
		ACCUSATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (4,6x30 мм)",
		INSTRUMENTAL = "магазином пистолет-пулемета \"WT-550 PDW\" (4,6x30 мм)",
		PREPOSITIONAL = "магазине пистолет-пулемета \"WT-550 PDW\" (4,6x30 мм)"
	)

/obj/item/ammo_box/magazine/wt550m9/update_icon_state()
	icon_state = "46x30mmt-[round(ammo_count(),6)]"

/obj/item/ammo_box/magazine/wt550m9/wtap
	name = "wt550 magazine (Armour Piercing 4.6x30mm)"
	desc = "Магазин пистолет-пулемета \"WT-550 PDW\", заряженный бронебойными патронами калибра 4,6x30 мм."
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/magazine/wt550m9/wtap/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (бронебойные 4,6x30 мм)",
		GENITIVE = "магазина пистолет-пулемета \"WT-550 PDW\" (бронебойные 4,6x30 мм)",
		DATIVE = "магазину пистолет-пулемета \"WT-550 PDW\" (бронебойные 4,6x30 мм)",
		ACCUSATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (бронебойные 4,6x30 мм)",
		INSTRUMENTAL = "магазином пистолет-пулемета \"WT-550 PDW\" (бронебойные 4,6x30 мм)",
		PREPOSITIONAL = "магазине пистолет-пулемета \"WT-550 PDW\" (бронебойные 4,6x30 мм)"
	)

/obj/item/ammo_box/magazine/wt550m9/wttx
	name = "wt550 magazine (Toxin Tipped 4.6x30mm)"
	desc = "Магазин пистолет-пулемета \"WT-550 PDW\", заряженный токсичными патронами калибра 4,6x30 мм."
	ammo_type = /obj/item/ammo_casing/c46x30mm/tox

/obj/item/ammo_box/magazine/wt550m9/wttx/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (токсичные 4,6x30 мм)",
		GENITIVE = "магазина пистолет-пулемета \"WT-550 PDW\" (токсичные 4,6x30 мм)",
		DATIVE = "магазину пистолет-пулемета \"WT-550 PDW\" (токсичные 4,6x30 мм)",
		ACCUSATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (токсичные 4,6x30 мм)",
		INSTRUMENTAL = "магазином пистолет-пулемета \"WT-550 PDW\" (токсичные 4,6x30 мм)",
		PREPOSITIONAL = "магазине пистолет-пулемета \"WT-550 PDW\" (токсичные 4,6x30 мм)"
	)

/obj/item/ammo_box/magazine/wt550m9/wtic
	name = "wt550 magazine (Incendiary 4.6x30mm)"
	desc = "Магазин пистолет-пулемета \"WT-550 PDW\", заряженный зажигательными патронами калибра 4,6x30 мм."
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc

/obj/item/ammo_box/magazine/wt550m9/wtic/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (зажигательные 4,6x30 мм)",
		GENITIVE = "магазина пистолет-пулемета \"WT-550 PDW\" (зажигательные 4,6x30 мм)",
		DATIVE = "магазину пистолет-пулемета \"WT-550 PDW\" (зажигательные 4,6x30 мм)",
		ACCUSATIVE = "магазин пистолет-пулемета \"WT-550 PDW\" (зажигательные 4,6x30 мм)",
		INSTRUMENTAL = "магазином пистолет-пулемета \"WT-550 PDW\" (зажигательные 4,6x30 мм)",
		PREPOSITIONAL = "магазине пистолет-пулемета \"WT-550 PDW\" (зажигательные 4,6x30 мм)"
	)

/obj/item/ammo_box/magazine/sp91rc
	name = "SP-91-RC magazine (9mm TE)"
	desc = "Магазин пистолет-пулемета \"SP-91-RC\", заряженный нелетальными патронами калибра 9 мм TE."
	icon_state = "9mm-te"
	ammo_type = /obj/item/ammo_casing/c9mmte
	caliber = CALIBER_9MM_TE
	max_ammo = 20

/obj/item/ammo_box/magazine/sp91rc/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолет-пулемета \"SP-91-RC\" (9 мм TE)",
		GENITIVE = "магазина пистолет-пулемета \"SP-91-RC\" (9 мм TE)",
		DATIVE = "магазину пистолет-пулемета \"SP-91-RC\" (9 мм TE)",
		ACCUSATIVE = "магазин пистолет-пулемета \"SP-91-RC\" (9 мм TE)",
		INSTRUMENTAL = "магазином пистолет-пулемета \"SP-91-RC\" (9 мм TE)",
		PREPOSITIONAL = "магазине пистолет-пулемета \"SP-91-RC\" (9 мм TE)"
	)

/obj/item/ammo_box/magazine/sp91rc/update_icon_state()
	icon_state = "9mm-te-[round(ammo_count(),5)]"

/* UZI magazine
 name = "Пистолет-пулемёт Uzi — магазин 9 мм"
 desc = "Магазин на 30 патронов калибра 9 мм."
 TODO Use this name and desc for localisation*/

/obj/item/ammo_box/magazine/uzim9mm
	name = "uzi magazine (9mm)"
	desc = "Магазин пистолет-пулемета \"UZI\", заряженный патронами калибра 9 мм."
	icon_state = "uzi9mm-32"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 32

/obj/item/ammo_box/magazine/uzim9mm/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолет-пулемета \"UZI\" (9 мм)",
		GENITIVE = "магазина пистолет-пулемета \"UZI\" (9 мм)",
		DATIVE = "магазину пистолет-пулемета \"UZI\" (9 мм)",
		ACCUSATIVE = "магазин пистолет-пулемета \"UZI\"(9 мм)",
		INSTRUMENTAL = "магазином пистолет-пулемета \"UZI\" (9 мм)",
		PREPOSITIONAL = "магазине пистолет-пулемета \"UZI\" (9 мм)"
	)

/obj/item/ammo_box/magazine/uzim9mm/update_icon_state()
	icon_state = "uzi9mm-[round(ammo_count(),4)]"

/obj/item/ammo_box/magazine/smgm9mm
	name = "SMG magazine (9mm)"
	desc = "Магазин пистолет-пулемёта SMG, предназначенный для патронов калибра 9 мм."
	icon_state = "smg9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 21

/obj/item/ammo_box/magazine/smgm9mm/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (9 мм)",
		GENITIVE = "магазина SMG (9 мм)",
		DATIVE = "магазину SMG (9 мм)",
		ACCUSATIVE = "магазина SMG(9 мм)",
		INSTRUMENTAL = "магазином SMG (9 мм)",
		PREPOSITIONAL = "магазине SMG (9 мм)"
	)

/obj/item/ammo_box/magazine/smgm9mm/rubber
	name = "magazine SMG (rubber)"
	desc = "Магазин пистолет-пулемёта SMG, предназначенный для резиновых патронов калибра 9 мм."
	ammo_type = /obj/item/ammo_casing/rubber9mm

/obj/item/ammo_box/magazine/smgm9mm/rubber/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (резиновый 9 мм)",
		GENITIVE = "магазина SMG (резиновый 9 мм)",
		DATIVE = "магазину SMG (резиновый 9 мм)",
		ACCUSATIVE = "магазина SMG (резиновый 9 мм)",
		INSTRUMENTAL = "магазином SMG (резиновый 9 мм)",
		PREPOSITIONAL = "магазине SMG (резиновый 9 мм)"
	)

/obj/item/ammo_box/magazine/smgm9mm/ap
	name = "SMG magazine (Armour Piercing 9mm)"
	desc = "Магазин пистолет-пулемёта SMG, предназначенный для бронебойных патронов калибра 9 мм."
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/magazine/smgm9mm/ap/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (бронебойный 9 мм)",
		GENITIVE = "магазина SMG (бронебойный 9 мм)",
		DATIVE = "магазину SMG (бронебойный 9 мм)",
		ACCUSATIVE = "магазина SMG (бронебойный 9 мм)",
		INSTRUMENTAL = "магазином SMG (бронебойный 9 мм)",
		PREPOSITIONAL = "магазине SMG (бронебойный 9 мм)"
	)

/obj/item/ammo_box/magazine/smgm9mm/toxin
	name = "SMG magazine (Toxin Tipped 9mm)"
	desc = "Магазин пистолет-пулемёта SMG, предназначенный для токсичных патронов калибра 9 мм."
	ammo_type = /obj/item/ammo_casing/c9mm/tox

/obj/item/ammo_box/magazine/smgm9mm/toxin/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (токсичный 9 мм)",
		GENITIVE = "магазина SMG (токсичный 9 мм)",
		DATIVE = "магазину SMG (токсичный 9 мм)",
		ACCUSATIVE = "магазина SMG (токсичный 9 мм)",
		INSTRUMENTAL = "магазином SMG (токсичный 9 мм)",
		PREPOSITIONAL = "магазине SMG (токсичный 9 мм)"
	)

/obj/item/ammo_box/magazine/smgm9mm/fire
	name = "SMG Magazine (Incendiary 9mm)"
	desc = "Магазин пистолет-пулемёта SMG, предназначенный для зажигательных патронов калибра 9 мм."
	ammo_type = /obj/item/ammo_casing/c9mm/inc

/obj/item/ammo_box/magazine/smgm9mm/fire/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (зажигательный 9 мм)",
		GENITIVE = "магазина SMG (зажигательный 9 мм)",
		DATIVE = "магазину SMG (зажигательный 9 мм)",
		ACCUSATIVE = "магазина SMG (зажигательный 9 мм)",
		INSTRUMENTAL = "магазином SMG (зажигательный 9 мм)",
		PREPOSITIONAL = "магазине SMG (зажигательный 9 мм)"
	)

/obj/item/ammo_box/magazine/smgm9mm/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count()+1,4)]"

/obj/item/ammo_box/magazine/sfg9mm
	name = "SFG Magazine (9mm)"
	desc = "Магазин пистолет-пулемёта SFG-5 SMG, предназначенный для патронов калибра 9 мм."
	icon_state = "sfg5"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 30

/obj/item/ammo_box/magazine/sfg9mm/get_ru_names()
	return list(
		NOMINATIVE = "магазин SFG-5 SMG (9 мм)",
		GENITIVE = "магазина SFG-5 SMG (9 мм)",
		DATIVE = "магазину SFG-5 SMG (9 мм)",
		ACCUSATIVE = "магазина SFG-5 SMG (9 мм)",
		INSTRUMENTAL = "магазином SFG-5 SMG (9 мм)",
		PREPOSITIONAL = "магазине SFG-5 SMG (9 мм)"
	)

/obj/item/ammo_box/magazine/sfg9mm/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count(), 30)]"

/obj/item/ammo_box/magazine/pistolm9mm
	name = "pistol magazine (9mm)"
	desc = "Магазин пистолета APS, предназначенный для патронов калибра 9 мм."
	icon_state = "9x19p-15"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/get_ru_names()
	return list(
		NOMINATIVE = "магазин APS (9 мм)",
		GENITIVE = "магазина APS (9 мм)",
		DATIVE = "магазину APS (9 мм)",
		ACCUSATIVE = "магазина APS (9 мм)",
		INSTRUMENTAL = "магазином APS (9 мм)",
		PREPOSITIONAL = "магазине APS (9 мм)"
	)

/obj/item/ammo_box/magazine/pistolm9mm/update_icon_state()
	icon_state = "9x19p-[ammo_count() ? "15" : "0"]"

/obj/item/ammo_box/magazine/smgm45
	name = "SMG magazine (.45)"
	desc = "Магазин пистолет-пулемёта SMG, предназначенный для патронов .45 калибра."
	icon_state = "c20r45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_DOT_45
	max_ammo = 20

/obj/item/ammo_box/magazine/smgm45/get_ru_names()
	return list(
		NOMINATIVE = "магазин SMG (.45)",
		GENITIVE = "магазина SMG (.45)",
		DATIVE = "магазину SMG (.45)",
		ACCUSATIVE = "магазина SMG(.45)",
		INSTRUMENTAL = "магазином SMG (.45)",
		PREPOSITIONAL = "магазине SMG (.45)"
	)

/obj/item/ammo_box/magazine/smgm45/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/tommygunm45
	name = "drum magazine (.45)"
	desc = "Барабанный магазин пистолет-пулемёта SMG, предназначенный для патронов .45 калибра."
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_DOT_45
	max_ammo = 50

/obj/item/ammo_box/magazine/tommygunm45/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин SMG (.45)",
		GENITIVE = "барабанного магазина SMG (.45)",
		DATIVE = "барабанному магазину SMG (.45)",
		ACCUSATIVE = "барабанный магазина SMG(.45)",
		INSTRUMENTAL = "барабанным магазином SMG (.45)",
		PREPOSITIONAL = "барабанном магазине SMG (.45)"
	)

/obj/item/ammo_box/magazine/m50
	name = "handgun magazine (.50ae)"
	desc = "Магазин пистолета \"Desert Eagle\", предназначенный для патронов .50 калибра AE."
	icon_state = "50ae"
	ammo_type = /obj/item/ammo_casing/a50
	caliber = CALIBER_DOT_50AE
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/magazine/m50/get_ru_names()
	return list(
		NOMINATIVE = "магазин Desert Eagle (.50 AE)",
		GENITIVE = "магазина Desert Eagle (.50 AE)",
		DATIVE = "магазину Desert Eagle (.50 AE)",
		ACCUSATIVE = "магазина Desert Eagle (.50 AE)",
		INSTRUMENTAL = "магазином Desert Eagle (.50 AE)",
		PREPOSITIONAL = "магазине Desert Eagle (.50 AE)"
	)

/obj/item/ammo_box/magazine/m75
	name = "specialized magazine (.75)"
	desc = "Магазин гиро-пистолета, предназначенный для патронов .75 калибра"
	icon_state = "75"
	ammo_type = /obj/item/ammo_casing/caseless/a75
	caliber = CALIBER_DOT_75
	multiple_sprites = 2
	max_ammo = 8

/obj/item/ammo_box/magazine/m75/get_ru_names()
	return list(
		NOMINATIVE = "магазин гиро-пистолета (.75)",
		GENITIVE = "магазина гиро-пистолета (.75)",
		DATIVE = "магазину гиро-пистолета (.75)",
		ACCUSATIVE = "магазина гиро-пистолета (.75)",
		INSTRUMENTAL = "магазином гиро-пистолета (.75)",
		PREPOSITIONAL = "магазине гиро-пистолета (.75)"
	)

// this magazine uses for M-90gl and ARG guns
/obj/item/ammo_box/magazine/m556
	name = "toploader magazine (5.56mm)"
	desc = "Коробчатый магазин, предназначенный для патронов калибра 5,56 мм."
	icon_state = "5.56m"
	origin_tech = "combat=5"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = CALIBER_5_DOT_56X45MM
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m556/get_ru_names()
	return list(
		NOMINATIVE = "автоматный магазин (5,56 мм)",
		GENITIVE = "автоматного магазина (5,56 мм)",
		DATIVE = "автоматному магазину (5,56 мм)",
		ACCUSATIVE = "автоматного магазина (5,56 мм)",
		INSTRUMENTAL = "автоматным магазином (5,56 мм)",
		PREPOSITIONAL = "автоматном магазине (5,56 мм)"
	)

/obj/item/ammo_box/magazine/ak814
	name = "AK magazine (5.45x39mm)"
	desc = "Магазин к автомату AK-814, предназначенный для патронов калибра 5,45x39 мм."
	icon_state = "ak814"
	desc= "A universal magazine for an AK style rifle."
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545
	caliber = CALIBER_5_DOT_45X39MM
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/ak814/get_ru_names()
	return list(
		NOMINATIVE = "автоматный магазин AK-814 (5,45x39 мм)",
		GENITIVE = "автоматного магазина AK-814 (5,45x39 мм)",
		DATIVE = "автоматному магазину AK-814 (5,45x39 мм)",
		ACCUSATIVE = "автоматного магазина AK-814 (5,45x39 мм)",
		INSTRUMENTAL = "автоматным магазином AK-814 (5,45x39 мм)",
		PREPOSITIONAL = "автоматном магазине AK-814 (5,45x39 мм)"
	)

/obj/item/ammo_box/magazine/aksu
	name = "AK magazine (5.45x39mm)"
	desc = "Магазин к автомату AKSU, предназначенный для патронов калибра 5,45x39 мм."
	icon_state = "ak47mag"
	origin_tech = "combat=4;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545/fusty
	caliber = CALIBER_5_DOT_45X39MM
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/aksu/get_ru_names()
	return list(
		NOMINATIVE = "автоматный магазин AKSU (5,45x39 мм)",
		GENITIVE = "автоматного магазина AKSU (5,45x39 мм)",
		DATIVE = "автоматному магазину AKSU (5,45x39 мм)",
		ACCUSATIVE = "автоматного магазина AKSU (5,45x39 мм)",
		INSTRUMENTAL = "автоматным магазином AKSU (5,45x39 мм)",
		PREPOSITIONAL = "автоматном магазине AKSU (5,45x39 мм)"
	)

/obj/item/ammo_box/magazine/ppsh
	name = "PPSh drum (7.62x25mm)"
	desc = "Магазин к пистолет-пулемету ППШ, предназначенный для патронов калибра 7,62x25 мм."
	icon_state = "ppshDrum"
	desc= "An antique drum for an PPSh submacnine."
	origin_tech = "combat=3;syndicate=1"
	ammo_type = /obj/item/ammo_casing/ftt762
	caliber = CALIBER_7_DOT_62X25MM
	max_ammo = 71
	multiple_sprites = 2

/obj/item/ammo_box/magazine/ppsh/get_ru_names()
	return list(
		NOMINATIVE = "магазин ППШ (7,62x25 мм)",
		GENITIVE = "магазина ППШ (7,62x25 мм)",
		DATIVE = "магазину ППШ (7,62x25 мм)",
		ACCUSATIVE = "магазина ППШ (7,62x25 мм)",
		INSTRUMENTAL = "магазином ППШ (7,62x25 мм)",
		PREPOSITIONAL = "магазине ППШ (7,62x25 мм)"
	)

// this drum magazine uses for Buldog, Mastiff and AS-12 Minotaur shotguns
/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g magnum buckshot)"
	desc = "Барабанный магазин, предназначенный для картечных магнум патронов калибра 12х70."
	icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/magnum
	caliber = CALIBER_12X70
	max_ammo = 12
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m12g/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (12х70)",
		GENITIVE = "барабанного магазина (12х70)",
		DATIVE = "барабанному магазину (12х70)",
		ACCUSATIVE = "барабанный магазина (12х70)",
		INSTRUMENTAL = "барабанным магазином (12х70)",
		PREPOSITIONAL = "барабанном магазине (12х70)"
	)

/obj/item/ammo_box/magazine/cheap_m12g
	name = "shotgun magazine (12g buckshot slugs)"
	desc = "Барабанный магазин, предназначенный для картечных патронов калибра 12х70."
	icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = CALIBER_12X70
	max_ammo = 12
	multiple_sprites = 2
	color = COLOR_ASSEMBLY_BROWN

/obj/item/ammo_box/magazine/cheap_m12g/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (картечный 12х70)",
		GENITIVE = "барабанного магазина (картечный 12х70)",
		DATIVE = "барабанному магазину (картечный 12х70)",
		ACCUSATIVE = "барабанный магазина (картечный 12х70)",
		INSTRUMENTAL = "барабанным магазином (картечный 12х70)",
		PREPOSITIONAL = "барабанном магазине (картечный 12х70)"
	)

/obj/item/ammo_box/magazine/m12g/slug
	name = "shotgun magazine (12g slugs)"
	desc = "Барабанный магазин, предназначенный для пулевых патронов калибра 12х70."
	icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/m12g/slug/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (12х70)",
		GENITIVE = "барабанного магазина (12х70)",
		DATIVE = "барабанному магазину (12х70)",
		ACCUSATIVE = "барабанный магазина (12х70)",
		INSTRUMENTAL = "барабанным магазином (12х70)",
		PREPOSITIONAL = "барабанном магазине (12х70)"
	)

/obj/item/ammo_box/magazine/m12g/stun
	name = "shotgun magazine (12g taser slugs)"
	desc = "Барабанный магазин, предназначенный для шоковых патронов калибра 12х70."
	icon_state = "m12gs"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/magazine/m12g/stun/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (шоковый 12х70)",
		GENITIVE = "барабанного магазина (шоковый 12х70)",
		DATIVE = "барабанному магазину (шоковый 12х70)",
		ACCUSATIVE = "барабанный магазина (шоковый 12х70)",
		INSTRUMENTAL = "барабанным магазином (шоковый 12х70)",
		PREPOSITIONAL = "барабанном магазине (шоковый 12х70)"
	)

/obj/item/ammo_box/magazine/m12g/dragon
	name = "shotgun magazine (12g napalm dragon's breath)"
	desc = "Барабанный магазин, предназначенный для патронов \"напалмовое Дыхание дракона\" калибра 12х70."
	icon_state = "m12gf"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/napalm

/obj/item/ammo_box/magazine/m12g/dragon/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (дыхание дракона 12х70)",
		GENITIVE = "барабанного магазина (дыхание дракона 12х70)",
		DATIVE = "барабанному магазину (дыхание дракона 12х70)",
		ACCUSATIVE = "барабанный магазина (дыхание дракона 12х70)",
		INSTRUMENTAL = "барабанным магазином (дыхание дракона 12х70)",
		PREPOSITIONAL = "барабанном магазине (дыхание дракона 12х70)"
	)

/obj/item/ammo_box/magazine/m12g/bioterror
	name = "shotgun magazine (12g bioterror)"
	desc = "Барабанный магазин, предназначенный для патронов \"Биотеррор\" калибра 12х70."
	icon_state = "m12gt"
	ammo_type = /obj/item/ammo_casing/shotgun/bioterror

/obj/item/ammo_box/magazine/m12g/bioterror/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (биотеррор 12х70)",
		GENITIVE = "барабанного магазина (биотеррор 12х70)",
		DATIVE = "барабанному магазину (биотеррор 12х70)",
		ACCUSATIVE = "барабанный магазина (биотеррор 12х70)",
		INSTRUMENTAL = "барабанным магазином (биотеррор 12х70)",
		PREPOSITIONAL = "барабанном магазине (биотеррор 12х70)"
	)

/obj/item/ammo_box/magazine/m12g/breach
	name = "shotgun magazine (12g breacher slugs)"
	desc = "Барабанный магазин, предназначенный для разрывных патронов калибра 12х70."
	icon_state = "m12gmt"
	ammo_type = /obj/item/ammo_casing/shotgun/breaching

/obj/item/ammo_box/magazine/m12g/breach/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (разрывные 12х70)",
		GENITIVE = "барабанного магазина (разрывные 12х70)",
		DATIVE = "барабанному магазину (разрывные 12х70)",
		ACCUSATIVE = "барабанный магазина (разрывные 12х70)",
		INSTRUMENTAL = "барабанным магазином (разрывные 12х70)",
		PREPOSITIONAL = "барабанном магазине (разрывные 12х70)"
	)

/obj/item/ammo_box/magazine/m12g/flechette
	name = "shotgun magazine (12g flechette)"
	desc = "Барабанный магазин, предназначенный для патронов \"Флешетта\" калибра 12х70."
	icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/m12g/flechette/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (флешетты 12х70)",
		GENITIVE = "барабанного магазина (флешетты 12х70)",
		DATIVE = "барабанному магазину (флешетты 12х70)",
		ACCUSATIVE = "барабанный магазина (флешетты 12х70)",
		INSTRUMENTAL = "барабанным магазином (флешетты 12х70)",
		PREPOSITIONAL = "барабанном магазине (флешетты 12х70)"
	)

/obj/item/ammo_box/magazine/m12g/XtrLrg
	name = "XL shotgun magazine (12g buckshot slugs)"
	desc = "Увеличенный барабанный магазин, предназначенный для картечных магнум патронов калибра 12х70."
	icon_state = "m12gXlBs"
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/magnum
	max_ammo = 24

/obj/item/ammo_box/magazine/m12g/XtrLrg/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин (усиленные 12х70)",
		GENITIVE = "увеличенного барабанного магазина (усиленные 12х70)",
		DATIVE = "увеличенному барабанному магазину (усиленные 12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин (усиленные 12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином (усиленные 12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине (усиленные 12х70)"
	)

/obj/item/ammo_box/magazine/m12g/XtrLrg/flechette
	name = "XL shotgun magazine (12g flechette)"
	desc = "Увеличенный барабанный магазин, предназначенный для патронов \"Флешетта\" калибра 12х70."
	icon_state = "m12gXlSl"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/m12g/XtrLrg/flechette/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин (флешетты 12х70)",
		GENITIVE = "увеличенного барабанного магазина (флешетты 12х70)",
		DATIVE = "увеличенному барабанному магазину (флешетты 12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин (флешетты 12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином (флешетты 12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине (флешетты 12х70)"
	)

/obj/item/ammo_box/magazine/m12g/XtrLrg/slug
	name = "XL shotgun magazine (12g slugs)"
	desc = "Увеличенный барабанный магазин, предназначенный для пулевых патронов калибра 12х70."
	icon_state = "m12gXlSl"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/m12g/XtrLrg/slug/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин (пулевой 12х70)",
		GENITIVE = "увеличенного барабанного магазина (пулевой 12х70)",
		DATIVE = "увеличенному барабанному магазину (пулевой 12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин (пулевой 12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином (пулевой 12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине (пулевой 12х70)"
	)

/obj/item/ammo_box/magazine/m12g/XtrLrg/dragon
	name = "XL shotgun magazine (12g napalm dragon's breath)"
	desc = "Увеличенный барабанный магазин, предназначенный для патронов \"напалмовое Дыхание дракона\" калибра 12х70."
	icon_state = "m12gXlDb"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/napalm

/obj/item/ammo_box/magazine/m12g/XtrLrg/dragon/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин (напалмовое дыхание дракона 12х70)",
		GENITIVE = "увеличенного барабанного магазина (напалмовое дыхание дракона 12х70)",
		DATIVE = "увеличенному барабанному магазину (напалмовое дыхание дракона 12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин (напалмовое дыхание дракона 12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином (напалмовое дыхание дракона 12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине (напалмовое дыхание дракона 12х70)"
	)

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
		PREPOSITIONAL = "магазине пенных патронов"
	)

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
		PREPOSITIONAL = "магазине SMG (пенный патрон)"
	)

/obj/item/ammo_box/magazine/toy/smg/update_icon_state()
	icon_state = "smg9mm-[round(ammo_count()+1,4)]"

/obj/item/ammo_box/magazine/toy/smg/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

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
		PREPOSITIONAL = "магазине пистолета (пенный патрон)"
	)

/obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/pistol/update_icon_state()
	icon_state = "9x19p-[ammo_count() ? "15" : "0"]"

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
		PREPOSITIONAL = "магазине пистолета \"Блюститель\" (пенный патрон)"
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
		PREPOSITIONAL = "магазине C-20r SMG (пенный патрон)"
	)

/obj/item/ammo_box/magazine/toy/smgm45/update_icon_state()
	icon_state = "c20r45-[round(ammo_count(),2)]"

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
		PREPOSITIONAL = "магазине L6 SAW (пенный патрон)"
	)

/obj/item/ammo_box/magazine/toy/m762/update_icon_state()
	icon_state = "a762-[round(ammo_count(), 20)]"

/obj/item/ammo_box/magazine/toy/m762/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/laser
	name = "encased laser projector magazine"
	desc = "Коробчатый магазин IK-60, предназначенный для лазерных патронов."
	icon_state = "laser"
	ammo_type = /obj/item/ammo_casing/laser
	caliber = CALIBER_LASER
	max_ammo = 20

/obj/item/ammo_box/magazine/laser/get_ru_names()
	return list(
		NOMINATIVE = "автоматный магазин IK-60 (лазерный)",
		GENITIVE = "автоматного магазина IK-60 (лазерный)",
		DATIVE = "автоматному магазину IK-60 (лазерный)",
		ACCUSATIVE = "автоматного магазина IK-60 (лазерный)",
		INSTRUMENTAL = "автоматным магазином IK-60 (лазерный)",
		PREPOSITIONAL = "автоматном магазине IK-60 (лазерный)"
	)

/obj/item/ammo_box/magazine/laser/update_icon_state()
	icon_state = "[initial(icon_state)]-[CEILING(ammo_count(FALSE)/20, 1)*20]"

/obj/item/ammo_box/magazine/lr30mag
	name = "small encased laser projector magazine"
	desc = "Коробчатый магазин LR-30, предназначенный для лазерных патронов."
	icon_state = "lmag"
	ammo_type = /obj/item/ammo_casing/laser
	caliber = CALIBER_LASER
	max_ammo = 20

/obj/item/ammo_box/magazine/lr30mag/get_ru_names()
	return list(
		NOMINATIVE = "автоматный магазин LR-30 (лазерный)",
		GENITIVE = "автоматного магазина LR-30 (лазерный)",
		DATIVE = "автоматному магазину LR-30 (лазерный)",
		ACCUSATIVE = "автоматного магазина LR-30 (лазерный)",
		INSTRUMENTAL = "автоматным магазином LR-30 (лазерный)",
		PREPOSITIONAL = "автоматном магазине LR-30 (лазерный)"
	)

/obj/item/ammo_box/magazine/lr30mag/update_icon_state()
	icon_state = "lmag-[CEILING(ammo_count(), 5)]"


/obj/item/ammo_box/magazine/toy/smgm45/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/m52mag
	name = "M-52 magazine"
	desc = "Коробчатый магазин M-52, предназначенный для патронов калибра 5,56х45 мм."
	icon_state = "m52_ammo"
	ammo_type = /obj/item/ammo_casing/a762x51
	caliber = CALIBER_7_DOT_62X51MM
	max_ammo = 24
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m52mag/get_ru_names()
	return list(
		NOMINATIVE = "автоматный магазин M-52 (5,56х45 мм)",
		GENITIVE = "автоматного магазина M-52 (5,56х45 мм)",
		DATIVE = "автоматному магазину M-52 (5,56х45 мм)",
		ACCUSATIVE = "автоматного магазина M-52 (5,56х45 мм)",
		INSTRUMENTAL = "автоматным магазином M-52 (5,56х45 мм)",
		PREPOSITIONAL = "автоматном магазине M-52 (5,56х45 мм)"
	)

/obj/item/ammo_box/magazine/cats12g
	name = "C.A.T.S. magazine (12g slug)"
	desc = "Барабанный магазин дробовика C.A.T.S., предназначенный для пулевых патронов калибра 12х70."
	icon_state = "cats_mag_slug"
	ammo_type = /obj/item/ammo_casing/shotgun
	multiple_sprites = 2
	max_ammo = 8

/obj/item/ammo_box/magazine/cats12g/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин C.A.T.S. (пулевой 12х70)",
		GENITIVE = "барабанного магазина C.A.T.S. (пулевой 12х70)",
		DATIVE = "барабанному магазину C.A.T.S. (пулевой 12х70)",
		ACCUSATIVE = "барабанный магазина C.A.T.S. (пулевой 12х70)",
		INSTRUMENTAL = "барабанным магазином C.A.T.S. (пулевой 12х70)",
		PREPOSITIONAL = "барабанном магазине C.A.T.S. (пулевой 12х70)"
	)

/obj/item/ammo_box/magazine/cats12g/large
	name = "C.A.T.S. magazine (12g-slug)-L"
	desc = "Увеличенный барабанный магазин дробовика C.A.T.S., предназначенный для пулевых патронов калибра 12х70."
	icon_state = "cats_mag_large_slug"
	max_ammo = 14

/obj/item/ammo_box/magazine/cats12g/large/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин C.A.T.S. (пулевой 12х70)",
		GENITIVE = "увеличенного барабанного магазина C.A.T.S. (пулевой 12х70)",
		DATIVE = "увеличенному барабанному магазину C.A.T.S. (пулевой 12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин C.A.T.S. (пулевой 12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином C.A.T.S. (пулевой 12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине C.A.T.S. (пулевой 12х70)"
	)

/obj/item/ammo_box/magazine/cats12g/beanbang
	name = "C.A.T.S. magazine (12g-beanbang)"
	desc = "Барабанный магазин дробовика C.A.T.S., предназначенный для резиновых патронов калибра 12х70."
	icon_state = "cats_mag_bean"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/cats12g/beanbang/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин C.A.T.S. (резиновая пуля 12х70)",
		GENITIVE = "барабанного магазина C.A.T.S. (резиновая пуля 12х70)",
		DATIVE = "барабанному магазину C.A.T.S. (резиновая пуля 12х70)",
		ACCUSATIVE = "барабанный магазина C.A.T.S. (резиновая пуля 12х70)",
		INSTRUMENTAL = "барабанным магазином C.A.T.S. (резиновая пуля 12х70)",
		PREPOSITIONAL = "барабанном магазине C.A.T.S. (резиновая пуля 12х70)"
	)

/obj/item/ammo_box/magazine/cats12g/beanbang/large
	name = "C.A.T.S. magazine (12g-beanbang)-L"
	desc = "Увеличенный барабанный магазин дробовика C.A.T.S., предназначенный для резиновых патронов калибра 12х70."
	icon_state = "cats_mag_large_bean"
	max_ammo = 14

/obj/item/ammo_box/magazine/cats12g/beanbang/large/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин C.A.T.S. (резиновая пуля 12х70)",
		GENITIVE = "увеличенного барабанного магазина C.A.T.S. (резиновая пуля 12х70)",
		DATIVE = "увеличенному барабанному магазину C.A.T.S. (резиновая пуля 12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин C.A.T.S. (резиновая пуля 12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином C.A.T.S. (резиновая пуля 12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине C.A.T.S. (резиновая пуля 12х70)"
	)

/obj/item/ammo_box/magazine/cats12g/universal
	name = "C.A.T.S. magazine (12g)-U"
	desc = "Барабанный магазин дробовика C.A.T.S., предназначенный для любых патронов калибра 12х70."
	icon_state = "cats_mag"
	caliber = CALIBER_12X70
	ammo_type = null

/obj/item/ammo_box/magazine/cats12g/universal/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин C.A.T.S. (12х70)",
		GENITIVE = "барабанного магазина C.A.T.S. (12х70)",
		DATIVE = "барабанному магазину C.A.T.S. (12х70)",
		ACCUSATIVE = "барабанный магазина C.A.T.S. (12х70)",
		INSTRUMENTAL = "барабанным магазином C.A.T.S. (12х70)",
		PREPOSITIONAL = "барабанном магазине C.A.T.S. (12х70)"
	)

/obj/item/ammo_box/magazine/cats12g/universal/large
	name = "C.A.T.S. magazine (12g)-UL"
	desc = "Увеличенный барабанный магазин дробовика C.A.T.S., предназначенный для любых патронов калибра 12х70."
	icon_state = "cats_mag_large"
	max_ammo = 14

/obj/item/ammo_box/magazine/cats12g/universal/large/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин C.A.T.S. (12х70)",
		GENITIVE = "увеличенного барабанного магазина C.A.T.S. (12х70)",
		DATIVE = "увеличенному барабанному магазину C.A.T.S. (12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин C.A.T.S. (12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином C.A.T.S. (12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине C.A.T.S. (12х70)"
	)

/obj/item/ammo_box/magazine/specter
	name = "magazine Specter (disabler)"
	desc = "Магазин пистолета \"Спектр\", предназначенный для парализующих патронов."
	icon_state = "specmag"
	ammo_type = /obj/item/ammo_casing/specter/disable
	max_ammo = 8
	multiple_sprites = 1
	caliber = CALIBER_SPECTER
	materials = list(MAT_METAL = 3000)

/obj/item/ammo_box/magazine/specter/get_ru_names()
	return list(
		NOMINATIVE = "магазин Спектр (парализующий)",
		GENITIVE = "магазин Спектр (парализующий)",
		DATIVE = "магазин Спектр (парализующий)",
		ACCUSATIVE = "магазин Спектр (парализующий)",
		INSTRUMENTAL = "магазин Спектр (парализующий)",
		PREPOSITIONAL = "магазин Спектр (парализующий)"
	)

/obj/item/ammo_box/magazine/specter/update_overlays()
	. = ..()
	if(ammo_count() && is_disable())
		. += image('icons/obj/weapons/ammo.dmi', icon_state = "specter-d")


/obj/item/ammo_box/magazine/specter/examine(mob/user)
	. = ..()
	if(get_dist(user, src) > 2)
		return
	. += span_notice("Похоже, что он заряжен [is_disable() ? "парализующими" : "лазерными"] патронами.")

/obj/item/ammo_box/magazine/specter/proc/is_disable()
	var/ammo = ammo_count()
	if(!ammo)
		return FALSE
	if(istype(contents[contents.len], /obj/item/ammo_casing/specter/disable))
		return TRUE
	return FALSE

/obj/item/ammo_box/magazine/specter/laser
	name = "magazine Specter (laser)"
	desc = "Магазин пистолета \"Спектр\", предназначенный для лазерных патронов."
	ammo_type = /obj/item/ammo_casing/specter/laser
	materials = list(MAT_METAL = 5000)

/obj/item/ammo_box/magazine/specter/laser/get_ru_names()
	return list(
		NOMINATIVE = "магазин Спектр (лазерный)",
		GENITIVE = "магазин Спектр (лазерный)",
		DATIVE = "магазин Спектр (лазерный)",
		ACCUSATIVE = "магазин Спектр (лазерный)",
		INSTRUMENTAL = "магазин Спектр (лазерный)",
		PREPOSITIONAL = "магазин Спектр (лазерный)"
	)
