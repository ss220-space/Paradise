// MARK: Grenade launcher
/obj/item/ammo_box/magazine/internal/grenadelauncher
	name = "grenade launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = CALIBER_40MM
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = null
	max_ammo = 6

// MARK: Rocket launcher
/obj/item/ammo_box/magazine/internal/rocketlauncher
	name = "rocket launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/rocket
	caliber = CALIBER_84MM
	max_ammo = 1

// MARK: Bombarda
/obj/item/ammo_box/magazine/internal/bombarda
	name = "bombarda internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm/improvised
	caliber = CALIBER_40MM
	max_ammo = 1
	insert_sound = 'sound/weapons/bombarda/load.ogg'
	remove_sound = 'sound/weapons/bombarda/open.ogg'
	load_sound = 'sound/weapons/bombarda/load.ogg'
	start_empty = TRUE

/obj/item/ammo_box/magazine/internal/bombarda/x2
	max_ammo = 2

/obj/item/ammo_box/magazine/internal/bombarda/ammo_count(countempties = TRUE)
	. = 0
	for(var/obj/item/ammo_casing/bullet in stored_ammo)
		if(bullet.BB || countempties)
			.++

// MARK: GL-06
/obj/item/ammo_box/magazine/internal/bombarda/secgl
	name = "security grenade launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm

// MARK: GL-08-4
/obj/item/ammo_box/magazine/internal/bombarda/secgl/x4
	max_ammo = 4
