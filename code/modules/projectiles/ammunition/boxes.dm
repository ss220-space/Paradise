/**
 * AMMO BOX
 */

// REVOLVER
/obj/item/ammo_box/a357
	name = "ammo box (.357)"
	icon_state = "357OLD"  // see previous entry for explanation of these vars
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 20


/obj/item/ammo_box/a357/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(length(stored_ammo) / 3)]"


/obj/item/ammo_box/n762
	name = "ammo box (7.62x38mm)"
	icon_state = "riflebox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 14

// SHOTGUN
/obj/item/ammo_box/shotgun
	name = "Ammunition Box (Slug)"
	icon_state = "slugbox"
	ammo_type = /obj/item/ammo_casing/shotgun
	max_ammo = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/shotgun/buck
	name = "Ammunition Box (Buckshot)"
	icon_state = "buckshotbox"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/shotgun/buck/assassination
	name = "Ammunition Box (Assassination shells)"
	ammo_type = /obj/item/ammo_casing/shotgun/assassination

/obj/item/ammo_box/shotgun/buck/nuclear
	name = "Elite Ammunition Box (Buckshot)"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/nuclear

/obj/item/ammo_box/shotgun/rubbershot
	name = "Ammunition Box (Rubbershot shells)"
	icon_state = "rubbershotbox"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/shotgun/rubbershot/dart
	name = "Ammunition Box (Dart shells)"
	ammo_type = /obj/item/ammo_casing/shotgun/dart

/obj/item/ammo_box/shotgun/beanbag
	name = "Ammunition Box (Beanbag shells)"
	icon_state = "beanbagbox"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/shotgun/beanbag/fake
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag/fake

/obj/item/ammo_box/shotgun/stunslug
	name = "Ammunition Box (Stun shells)"
	icon_state = "stunslugbox"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/shotgun/breaching
	name = "Ammunition Box (Breaching shells)"
	icon_state = "meteorshotbox"
	ammo_type = /obj/item/ammo_casing/shotgun/breaching

/obj/item/ammo_box/shotgun/pulseslug
	name = "Ammunition Box (Pulse slugs)"
	icon_state = "pulseslugbox"
	ammo_type = /obj/item/ammo_casing/shotgun/pulseslug

/obj/item/ammo_box/shotgun/incendiary
	name = "Ammunition Box (Incendiary slugs)"
	icon_state = "incendiarybox"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/ammo_box/shotgun/frag12
	name = "Ammunition Box (FRAG-12 slugs)"
	icon_state = "frag12box"
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/shotgun/dragonsbreath
	name = "Ammunition Box (Dragonsbreath)"
	icon_state = "dragonsbreathbox"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/ammo_box/shotgun/dragonsbreath/nuclear
	name = "Elite Ammunition Box (Dragonsbreath)"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/nuclear

/obj/item/ammo_box/shotgun/ion
	name = "Ammunition Box (Ion shells)"
	icon_state = "ionbox"
	ammo_type = /obj/item/ammo_casing/shotgun/ion

/obj/item/ammo_box/shotgun/laserslug
	name = "Ammunition Box (Laser slugs)"
	icon_state = "laserslugbox"
	ammo_type = /obj/item/ammo_casing/shotgun/laserslug

/obj/item/ammo_box/shotgun/bioterror
	name = "Ammunition Box (Bioterror shells)"
	icon_state = "bioterrorbox"
	ammo_type = /obj/item/ammo_casing/shotgun/bioterror

/obj/item/ammo_box/shotgun/tranquilizer
	name = "Ammunition Box (Tranquilizer darts)"
	icon_state = "tranquilizerbox"
	ammo_type = /obj/item/ammo_casing/shotgun/tranquilizer

/obj/item/ammo_box/shotgun/flechette
	name = "Ammunition Box (Flechette)"
	icon_state = "flechettebox"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/shotgun/improvised
	name = "Ammunition Box (Improvised shells)"
	icon = 'icons/obj/storage.dmi'
	icon_state = "largebox"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised

/obj/item/ammo_box/shotgun/improvised/overload
	name = "Ammunition Box (Overload shells)"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised/overload

// AUTOMATIC
/obj/item/ammo_box/c9mm
	name = "ammo box (9mm)"
	icon_state = "9mmbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 30

/obj/item/ammo_box/rubber9mm
	name = "ammo box (rubber 9mm)"
	icon_state = "9mmbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/rubber9mm
	max_ammo = 30

/obj/item/ammo_box/c10mm
	name = "ammo box (10mm)"
	icon_state = "10mmbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 20

/obj/item/ammo_box/fortynr
	name = "ammo box 40N&R"
	icon_state = "40n&rbox"
	ammo_type = /obj/item/ammo_casing/fortynr
	max_ammo = 40

/obj/item/ammo_box/c45
	name = "ammo box (.45)"
	icon_state = "45box"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 20

/obj/item/ammo_box/rubber45
	name = "ammo box (.45 rubber)"
	icon_state = "45box-r"
	ammo_type = /obj/item/ammo_casing/rubber45
	max_ammo = 16

/obj/item/ammo_box/c46x30mm
	name = "ammo box (4.6x30mm)"
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	max_ammo = 40

/obj/item/ammo_box/ap46x30mm
	name = "ammo box (Armour Piercing 4.6x30mm)"
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap
	max_ammo = 40

/obj/item/ammo_box/tox46x30mm
	name = "ammo box (Toxin Tipped 4.6x30mm)"
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/tox
	max_ammo = 40

/obj/item/ammo_box/inc46x30mm
	name = "ammo box (Incendiary 4.6x30mm)"
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc
	max_ammo = 40

/obj/item/ammo_box/c9mmte
	name = "ammo box (9mm TE)"
	icon_state = "9mmTEbox"
	ammo_type = /obj/item/ammo_casing/c9mmte
	max_ammo = 60

// MISC
/obj/item/ammo_box/a40mm
	name = "ammo box (40mm grenades)"
	icon_state = "40mm"
	ammo_type = /obj/item/ammo_casing/a40mm
	max_ammo = 4
	multiple_sprites = 1

/obj/item/ammo_box/laserammobox
	name = "laser ammo box"
	icon_state = "laserbox"
	ammo_type = /obj/item/ammo_casing/laser
	max_ammo = 40

/obj/item/ammo_box/foambox
	name = "ammo box (Foam Darts)"
	icon = 'icons/obj/weapons/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	max_ammo = 40

/obj/item/ammo_box/foambox/riot
	icon_state = "foambox_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/foambox/sniper
	name = "ammo box (Foam Sniper Darts)"
	icon = 'icons/obj/weapons/toy.dmi'
	icon_state = "foambox_sniper"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper
	max_ammo = 40

/obj/item/ammo_box/foambox/sniper/riot
	icon_state = "foambox_sniper_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper/riot

/**
 * SPEEDLOADER
 */

// REVOLVER
/obj/item/ammo_box/speedloader/a357
	name = "speed loader (.357)"
	desc = "Designed to quickly reload revolvers."
	materials = list(MAT_METAL = 2000)
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 7
	caliber = ".357"
	icon_state = "357-7" // DEFAULT icon, composed of prefix + "-" + max_ammo for multiple_sprites == 1 boxes
	multiple_sprites = 1 // see: /obj/item/ammo_box/update_icon()
	icon_prefix = "357" // icon prefix, used in above formula to generate dynamic icons

/obj/item/ammo_box/speedloader/improvisedrevolver
	name = "makeshift speedloader"
	desc = "Speedloader made from shit and sticks"
	ammo_type = /obj/item/ammo_casing/revolver/improvised
	icon_state = "makeshift_speedloader-4"
	multiple_sprites = 1
	icon_prefix = "makeshift_speedloader"
	max_ammo = 4
	caliber = ".257"

/obj/item/ammo_box/speedloader/c38
	name = "speed loader (.38)"
	desc = "Designed to quickly reload revolvers."
	icon_state = "38"
	materials = list(MAT_METAL = 2000)
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	caliber = ".38"
	icon_state = "38-6"
	multiple_sprites = 1
	icon_prefix = "38"

/obj/item/ammo_box/speedloader/c38/hp
	name = "speed loader (.38 Hollow-Point)"
	ammo_type = /obj/item/ammo_casing/c38/hp
	icon_state = "38hp-6"
	icon_prefix = "38hp"

// SHOTGUN
/obj/item/ammo_box/speedloader/shotgun
	name = "Shotgun Speedloader"
	desc = "Designed to quickly reload shotguns."
	icon_state = "shotgunloader"
	origin_tech = "combat=2"
	caliber = ".12"
	max_ammo = 7
	ammo_type = null
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/speedloader/shotgun/New()
	. = ..()
	name = "Shotgun Speedloader"
	icon_state = "shotgunloader"


/obj/item/ammo_box/speedloader/shotgun/update_overlays()
	. = ..()
	for(var/i = 1 to length(stored_ammo))
		var/obj/item/ammo_casing/shotgun/ammo = stored_ammo[i]
		var/icon/new_ammo_icon = icon('icons/obj/weapons/ammo.dmi', "[initial(ammo.icon_state)]_loader")
		if(i < 7)
			new_ammo_icon.Shift((i % 2) == 0 ? WEST : EAST, 3)
		new_ammo_icon.Turn(FLOOR((i - 1) * 45, 90))
		. += new_ammo_icon


/obj/item/ammo_box/speedloader/shotgun/slug
	name = "Shotgun Speedloader (slug)"
	icon_state = "slugloader"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/speedloader/shotgun/buck
	name = "Shotgun Speedloader (buckshot)"
	icon_state = "buckshotloader"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/speedloader/shotgun/rubbershot
	name = "Shotgun Speedloader (rubbershot)"
	icon_state = "rubbershotloader"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/speedloader/shotgun/dart
	name = "Shotgun Speedloader (dart)"
	icon_state = "rubbershotloader"
	ammo_type = /obj/item/ammo_casing/shotgun/dart

/obj/item/ammo_box/speedloader/shotgun/beanbag
	name = "Shotgun Speedloader (beanbag)"
	icon_state = "beanbagloader"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/speedloader/shotgun/stunslug
	name = "Shotgun Speedloader (stunslug)"
	icon_state = "stunslugloader"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/speedloader/shotgun/pulseslug
	name = "Shotgun Speedloader (pulseslug)"
	icon_state = "pulseslugloader"
	ammo_type = /obj/item/ammo_casing/shotgun/pulseslug

/obj/item/ammo_box/speedloader/shotgun/incendiary
	name = "Shotgun Speedloader (incendiary)"
	icon_state = "incendiaryloader"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/ammo_box/speedloader/shotgun/frag12
	name = "Shotgun Speedloader (frag12)"
	icon_state = "frag12loader"
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/speedloader/shotgun/dragonsbreath
	name = "Shotgun Speedloader (dragonsbreath)"
	icon_state = "dragonsbreathloader"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/ammo_box/speedloader/shotgun/ion
	name = "Shotgun Speedloader (ion)"
	icon_state = "ionloader"
	ammo_type = /obj/item/ammo_casing/shotgun/ion

/obj/item/ammo_box/speedloader/shotgun/laserslug
	name = "Shotgun Speedloader (laserslug)"
	icon_state = "laserslugloader"
	ammo_type = /obj/item/ammo_casing/shotgun/laserslug

/obj/item/ammo_box/speedloader/shotgun/tranquilizer
	name = "Shotgun Speedloader (tranquilizer)"
	icon_state = "tranquilizerloader"
	ammo_type = /obj/item/ammo_casing/shotgun/tranquilizer

/obj/item/ammo_box/speedloader/shotgun/improvised
	name = "Shotgun Speedloader (improvised)"
	icon_state = "improvisedloader"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised

/obj/item/ammo_box/speedloader/shotgun/overload
	name = "Shotgun Speedloader (overload)"
	icon_state = "improvisedloader"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised/overload

// MISC
/obj/item/ammo_box/speedloader/caps
	name = "speed loader (caps)"
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/cap
	max_ammo = 7
	multiple_sprites = 1

/**
 * STRIPPER CLIP
 */

/obj/item/ammo_box/speedloader/a762
	name = "stripper clip (7.62mm)"
	desc = "A stripper clip."
	icon_state = "762"
	caliber = "7.62x54mm"
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 5
	multiple_sprites = 1
