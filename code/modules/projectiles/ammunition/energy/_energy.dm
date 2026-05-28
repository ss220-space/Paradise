/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew"
	caliber = "energy"
	projectile_type = /obj/projectile/energy
	fire_sound = 'sound/weapons/gunshots/1laser10.ogg'
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash/energy
	/// The amount of energy a cell needs to expend to create this shot.
	var/e_cost = 100
	/// Identifier for the firemode, mostly used in icon updates.
	var/select_name = "energy"
	/// Fluff fire mode name showed to the user.
	var/fluff_select_name
	/// Sibyl System classification tier
	var/sibyl_tier = SIBYL_TIER_NONLETHAL
