// MARK: 84mm HE
/obj/item/ammo_casing/caseless/rocket
	name = "PM-9HE"
	desc = "An 84mm High Explosive rocket. Fire at people and pray."
	caliber = CALIBER_84MM
	w_class = WEIGHT_CLASS_NORMAL //thats the rocket!
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "84mm-he"
	projectile_type = /obj/projectile/bullet/a84mm_he
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'	// better than default casing but not ideal

/obj/item/ammo_casing/caseless/rocket/hedp
	name = "PM-9HEDP"
	desc = "An 84mm High Explosive Dual Purpose rocket. Pointy end toward mechs and unarmed civilians."
	icon_state = "84mm-hedp"
	projectile_type = /obj/projectile/bullet/a84mm_hedp

// MARK: Rocket
/obj/item/ammo_casing/rocket
	name = "rocket shell"
	desc = "A high explosive designed to be fired from a launcher."
	icon_state = "rocketshell"
	materials = list(MAT_METAL = 10000)
	caliber = CALIBER_ROCKET
	projectile_type = /obj/item/missile
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

// MARK: 40mm HE
/obj/item/ammo_casing/a40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	icon_state = "40mmHE"
	materials = list(MAT_METAL = 8000)
	caliber = CALIBER_40MM
	projectile_type = /obj/projectile/bullet/a40mm
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
