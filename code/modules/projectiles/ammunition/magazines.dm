////////////////INTERNAL MAGAZINES//////////////////////
/obj/item/ammo_box/magazine/internal
	desc = "Oh god, this shouldn't be here!"


//internals magazines are accessible, so replace spent ammo if full when trying to put a live one in
/obj/item/ammo_box/magazine/internal/give_round(obj/item/ammo_casing/new_casing, replace_spent = TRUE, count_chambered = FALSE, mob/user)
	. = ..()


// Revolver internal mags
/obj/item/ammo_box/magazine/internal/cylinder
	name = "revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = ".357"
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
	caliber = ".38"
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
	caliber = "7.62x38mm"
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/rev36
	name = ".36 revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c38/c36
	caliber = ".36"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/improvised
	name = "improvised bullet cylinder"
	desc = "A roughly made revolver cylinder."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "rev_cylinder"
	ammo_type = null
	start_empty = TRUE
	caliber = list(".257")
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
	caliber = list(".257", ".38")
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/cap
	name = "cap gun revolver cylinder"
	desc = "Oh god, this shouldn't be here!"
	ammo_type = /obj/item/ammo_casing/cap
	caliber = "cap"
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/ga12
	name = ".12 revolver cylinder"
	ammo_type = /obj/item/ammo_casing/shotgun
	caliber = ".12"
	max_ammo = 3

// Shotgun internal mags
/obj/item/ammo_box/magazine/internal/shot
	name = "shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = ".12"
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
	caliber = "40mm"
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = null
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/speargun
	name = "speargun internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/magspear
	caliber = "spear"
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/rocketlauncher
	name = "rocket launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/rocket
	caliber = "84mm"
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/rus357
	name = "russian revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = ".357"
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
	caliber = "7.62x54mm"
	max_ammo = 5
	multiload = TRUE

/obj/item/ammo_box/magazine/internal/boltaction/enchanted
	max_ammo =1
	ammo_type = /obj/item/ammo_casing/a762/enchanted

/obj/item/ammo_box/magazine/internal/shot/toy
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	caliber = "foam_force"
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/shot/toy/crossbow
	max_ammo = 5

/obj/item/ammo_box/magazine/internal/shot/toy/tommygun
 	max_ammo = 10

///////////EXTERNAL MAGAZINES////////////////
/obj/item/ammo_box/magazine
	materials = list(MAT_METAL = 2000)

/obj/item/ammo_box/magazine/m10mm
	name = "pistol magazine (10mm)"
	desc = "A gun magazine."
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 15
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m10mm/fire
	name = "pistol magazine (10mm incendiary)"
	icon_state = "9x19pI"
	desc = "A gun magazine. Loaded with rounds which ignite the target."
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/magazine/m10mm/hp
	name = "pistol magazine (10mm HP)"
	icon_state = "9x19pH"
	desc= "A gun magazine. Loaded with hollow-point rounds, extremely effective against unarmored targets, but nearly useless against protective clothing."
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/m10mm/ap
	name = "pistol magazine (10mm AP)"
	icon_state = "9x19pA"
	desc= "A gun magazine. Loaded with rounds which penetrate armour, but are less effective against normal targets."
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/magazine/m10mm/update_icon_state()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "15" : "0"]"

/obj/item/ammo_box/magazine/m45
	name = "handgun magazine (.45)"
	icon_state = "45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_box/magazine/enforcer
	name = "handgun magazine (9mm rubber)"
	icon_state = "enforcer"
	ammo_type = /obj/item/ammo_casing/rubber9mm
	max_ammo = 8
	multiple_sprites = 1
	caliber = "9mm"


/obj/item/ammo_box/magazine/enforcer/update_overlays()
	. = ..()
	if(ammo_count() && is_rubber())
		. += image('icons/obj/weapons/ammo.dmi', icon_state = "enforcer-r")


/obj/item/ammo_box/magazine/enforcer/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		. += span_notice("It seems to be loaded with [is_rubber() ? "rubber" : "lethal"] bullets.")	//only can see the topmost one.

/obj/item/ammo_box/magazine/enforcer/proc/is_rubber()//if the topmost bullet is a rubber one
	var/ammo = ammo_count()
	if(!ammo)
		return FALSE
	if(istype(contents[contents.len], /obj/item/ammo_casing/rubber9mm))
		return TRUE
	return FALSE

/obj/item/ammo_box/magazine/enforcer/lethal
	name = "handgun magazine (9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm

/obj/item/ammo_box/magazine/sp8
	name = "handgun magazine 40N&R"
	icon_state = "sp8mag"
	ammo_type = /obj/item/ammo_casing/fortynr
	max_ammo = 10
	caliber = "40nr"

/obj/item/ammo_box/magazine/sp8/update_icon_state()
	icon_state = "sp8mag-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/wt550m9
	name = "wt550 magazine (4.6x30mm)"
	icon_state = "46x30mmt-20"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = "4.6x30mm"
	max_ammo = 20

/obj/item/ammo_box/magazine/wt550m9/update_icon_state()
	icon_state = "46x30mmt-[round(ammo_count(),4)]"

/obj/item/ammo_box/magazine/wt550m9/wtap
	name = "wt550 magazine (Armour Piercing 4.6x30mm)"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/magazine/wt550m9/wttx
	name = "wt550 magazine (Toxin Tipped 4.6x30mm)"
	ammo_type = /obj/item/ammo_casing/c46x30mm/tox

/obj/item/ammo_box/magazine/wt550m9/wtic
	name = "wt550 magazine (Incendiary 4.6x30mm)"
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc

/obj/item/ammo_box/magazine/sp91rc
	name = "SP-91-RC magazine (9mm TE)"
	icon_state = "9mm-te"
	ammo_type = /obj/item/ammo_casing/c9mmte
	caliber = "9mm TE"
	max_ammo = 20

/obj/item/ammo_box/magazine/sp91rc/update_icon_state()
	icon_state = "9mm-te-[round(ammo_count(),5)]"

/obj/item/ammo_box/magazine/uzim9mm
	name = "uzi magazine (9mm)"
	icon_state = "uzi9mm-32"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 32

/obj/item/ammo_box/magazine/uzim9mm/update_icon_state()
	icon_state = "uzi9mm-[round(ammo_count(),4)]"

/obj/item/ammo_box/magazine/smgm9mm
	name = "SMG magazine (9mm)"
	icon_state = "smg9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 21

/obj/item/ammo_box/magazine/smgm9mm/ap
	name = "SMG magazine (Armour Piercing 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/magazine/smgm9mm/toxin
	name = "SMG magazine (Toxin Tipped 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/tox

/obj/item/ammo_box/magazine/smgm9mm/fire
	name = "SMG Magazine (Incendiary 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/inc

/obj/item/ammo_box/magazine/smgm9mm/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count()+1,4)]"

/obj/item/ammo_box/magazine/sfg9mm
	name = "SFG Magazine (9mm)"
	icon_state = "sfg5"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 30

/obj/item/ammo_box/magazine/sfg9mm/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count(), 30)]"

/obj/item/ammo_box/magazine/pistolm9mm
	name = "pistol magazine (9mm)"
	icon_state = "9x19p-15"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/update_icon_state()
	icon_state = "9x19p-[ammo_count() ? "15" : "0"]"

/obj/item/ammo_box/magazine/smgm45
	name = "SMG magazine (.45)"
	icon_state = "c20r45"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 20

/obj/item/ammo_box/magazine/smgm45/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/tommygunm45
	name = "drum magazine (.45)"
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 50

/obj/item/ammo_box/magazine/m50
	name = "handgun magazine (.50ae)"
	icon_state = "50ae"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a50
	caliber = ".50ae"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/magazine/m75
	name = "specialized magazine (.75)"
	icon_state = "75"
	ammo_type = /obj/item/ammo_casing/caseless/a75
	caliber = ".75"
	multiple_sprites = 2
	max_ammo = 8

/obj/item/ammo_box/magazine/m556
	name = "toploader magazine (5.56mm)"
	icon_state = "5.56m"
	origin_tech = "combat=5"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = "5.56mm"
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/ak814
	name = "AK magazine (5.45x39mm)"
	icon_state = "ak814"
	desc= "A universal magazine for an AK style rifle."
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545
	caliber = "5.45x39mm"
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/aksu
	name = "AK magazine (5.45x39mm)"
	icon_state = "ak47mag"
	desc= "An antique fusty magazine for an AK rifle."
	origin_tech = "combat=4;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545/fusty
	caliber = "5.45x39mm"
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/ppsh
	name = "PPSh drum (7.62x25mm)"
	icon_state = "ppshDrum"
	desc= "An antique drum for an PPSh submacnine."
	origin_tech = "combat=3;syndicate=1"
	ammo_type = /obj/item/ammo_casing/ftt762
	caliber = "7.62x25mm"
	max_ammo = 71
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g buckshot slugs)"
	desc = "A drum magazine."
	icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/nuclear
	origin_tech = "combat=3"
	caliber = ".12"
	max_ammo = 12
	multiple_sprites = 2

/obj/item/ammo_box/magazine/cheap_m12g
	name = "shotgun magazine (12g buckshot slugs)"
	desc = "A cheaply-made drum magazine."
	icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	origin_tech = "combat=2"
	caliber = ".12"
	max_ammo = 12
	multiple_sprites = 2
	color = COLOR_ASSEMBLY_BROWN

/obj/item/ammo_box/magazine/m12g/slug
	name = "shotgun magazine (12g slugs)"
	icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/m12g/stun
	name = "shotgun magazine (12g taser slugs)"
	icon_state = "m12gs"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/magazine/m12g/dragon
	name = "shotgun magazine (12g dragon's breath)"
	icon_state = "m12gf"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/nuclear

/obj/item/ammo_box/magazine/m12g/bioterror
	name = "shotgun magazine (12g bioterror)"
	icon_state = "m12gt"
	ammo_type = /obj/item/ammo_casing/shotgun/bioterror

/obj/item/ammo_box/magazine/m12g/breach
	name = "shotgun magazine (12g breacher slugs)"
	icon_state = "m12gmt"
	ammo_type = /obj/item/ammo_casing/shotgun/breaching

/obj/item/ammo_box/magazine/m12g/flechette
	name = "shotgun magazine (12g flechette)"
	icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/m12g/XtrLrg
	name = "\improper XL shotgun magazine (12g buckshot slugs)"
	desc = "An extra large drum magazine."
	icon_state = "m12gXlBs"
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/nuclear
	max_ammo = 24

/obj/item/ammo_box/magazine/m12g/XtrLrg/flechette
	name = "\improper XL shotgun magazine (12g flechette)"
	icon_state = "m12gXlSl"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/m12g/XtrLrg/slug
	name = "\improper XL shotgun magazine (12g slugs)"
	icon_state = "m12gXlSl"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/m12g/XtrLrg/dragon
	name = "\improper XL shotgun magazine (12g dragon's breath)"
	icon_state = "m12gXlDb"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/nuclear

/obj/item/ammo_box/magazine/toy
	name = "foam force META magazine"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	caliber = "foam_force"

/obj/item/ammo_box/magazine/toy/smg
	name = "foam force SMG magazine"
	icon_state = "smg9mm-20"
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smg/update_icon_state()
	icon_state = "smg9mm-[round(ammo_count()+1,4)]"

/obj/item/ammo_box/magazine/toy/smg/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/pistol
	name = "foam force pistol magazine"
	icon_state = "9x19p"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/pistol/update_icon_state()
	icon_state = "9x19p-[ammo_count() ? "15" : "0"]"

/obj/item/ammo_box/magazine/toy/enforcer
	name = "foam enforcer magazine"
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

/obj/item/ammo_box/magazine/toy/smgm45
	name = "donksoft SMG magazine"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smgm45/update_icon_state()
	icon_state = "c20r45-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/toy/m762
	name = "donksoft box magazine"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	max_ammo = 100

/obj/item/ammo_box/magazine/toy/m762/update_icon_state()
	icon_state = "a762-[round(ammo_count(), 20)]"

/obj/item/ammo_box/magazine/toy/m762/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/laser
	name = "encased laser projector magazine"
	desc = "Fits experimental laser ammo casings."
	icon_state = "laser"
	ammo_type = /obj/item/ammo_casing/laser
	origin_tech = "combat=3"
	caliber = "laser"
	max_ammo = 20

/obj/item/ammo_box/magazine/laser/update_icon_state()
	icon_state = "[initial(icon_state)]-[CEILING(ammo_count(FALSE)/20, 1)*20]"

/obj/item/ammo_box/magazine/lr30mag
	name = "small encased laser projector magazine"
	desc = "Fits experimental laser ammo casings."
	icon_state = "lmag"
	ammo_type = /obj/item/ammo_casing/laser
	origin_tech = "combat=3"
	caliber = "laser"
	max_ammo = 20


/obj/item/ammo_box/magazine/lr30mag/update_icon_state()
	icon_state = "lmag-[CEILING(ammo_count(), 5)]"


/obj/item/ammo_box/magazine/toy/smgm45/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/m52mag
	name = "M-52 magazine"
	icon_state = "m52_ammo"
	ammo_type = /obj/item/ammo_casing/mm556x45
	caliber = "mm55645"
	max_ammo = 24
	multiple_sprites = 2

/obj/item/ammo_box/magazine/cats12g
	name = "C.A.T.S. magazine (12g slug)"
	desc = "Похоже, этот магазин может принять в себя только слаги 12-о калибра."
	icon_state = "cats_mag_slug"
	ammo_type = /obj/item/ammo_casing/shotgun
	multiple_sprites = 2
	max_ammo = 8

/obj/item/ammo_box/magazine/cats12g/large
	name = "C.A.T.S. magazine (12g-slug)-L"
	desc = "Похоже, в этот расширенный магазин лезут только слаги 12-о калибра."
	icon_state = "cats_mag_large_slug"
	max_ammo = 14

/obj/item/ammo_box/magazine/cats12g/beanbang
	name = "C.A.T.S. magazine (12g-beanbang)"
	desc = "Похоже, в этот магазин лезут только патроны-погремушки."
	icon_state = "cats_mag_bean"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/cats12g/beanbang/large
	name = "C.A.T.S. magazine (12g-beanbang)-L"
	desc = "Похоже, в этот расширенный магазин лезут только патроны-погремушки."
	icon_state = "cats_mag_large_bean"
	max_ammo = 14

/obj/item/ammo_box/magazine/cats12g/universal
	name = "C.A.T.S. magazine (12g)-U"
	desc = "Похоже, этот магазин может принять в себя любые патроны 12-о калибра."
	icon_state = "cats_mag"
	caliber = ".12"
	ammo_type = null

/obj/item/ammo_box/magazine/cats12g/universal/large
	name = "C.A.T.S. magazine (12g)-UL"
	desc = "Похоже, этот расширенный магазин может принять в себя любые патроны 12-о калибра."
	icon_state = "cats_mag_large"
	max_ammo = 14
