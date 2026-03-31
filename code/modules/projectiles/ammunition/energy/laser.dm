// MARK: Basic lasers
/obj/item/ammo_casing/energy/laser
	projectile_type = /obj/projectile/beam/laser
	muzzle_flash_color = COLOR_SOFT_RED
	select_name = "kill"
	sibyl_tier = SIBYL_TIER_LETHAL
	bullet_type = BULLET_TYPE_LASER

/obj/item/ammo_casing/energy/laser/light
	projectile_type = /obj/projectile/beam/laser/light
	delay = 0.9

/obj/item/ammo_casing/energy/laser/cyborg //to balance cyborg energy cost seperately
	e_cost = 250

/obj/item/ammo_casing/energy/laser/hos //allows balancing of HoS and blueshit guns seperately from other energy weapons
	e_cost = 75

/obj/item/ammo_casing/energy/laser/blueshield
	e_cost = 83

/obj/item/ammo_casing/energy/laser/practice
	projectile_type = /obj/projectile/beam/practice
	select_name = "practice"
	sibyl_tier = SIBYL_TIER_NONLETHAL
	harmful = FALSE
	fire_sound = 'sound/weapons/gunshots/1retrolaser.ogg'

/obj/item/ammo_casing/energy/laser/scatter
	projectile_type = /obj/projectile/beam/scatter
	pellets = 5
	variance = 25
	select_name = "scatter"

/obj/item/ammo_casing/energy/laser/heavy
	projectile_type = /obj/projectile/beam/laser/heavylaser
	select_name = "anti-vehicle"
	fire_sound = 'sound/weapons/gunshots/1pulse2.ogg'

/obj/item/ammo_casing/energy/laser/pulse
	projectile_type = /obj/projectile/beam/pulse/hitscan
	muzzle_flash_color = LIGHT_COLOR_DARK_BLUE
	e_cost = 200
	select_name = "DESTROY"
	sibyl_tier = SIBYL_TIER_DESTRUCTIVE
	fire_sound = 'sound/weapons/gunshots/1pulse2.ogg'

/obj/item/ammo_casing/energy/laser/scatter/pulse
	projectile_type = /obj/projectile/beam/pulse/hitscan
	e_cost = 200
	select_name = "ANNIHILATE"
	sibyl_tier = SIBYL_TIER_DESTRUCTIVE
	fire_sound = 'sound/weapons/gunshots/1pulse2.ogg'

/obj/item/ammo_casing/energy/laser/bluetag
	projectile_type = /obj/projectile/beam/lasertag/bluetag
	muzzle_flash_color = LIGHT_COLOR_BLUE
	select_name = "bluetag"
	sibyl_tier = SIBYL_TIER_NONLETHAL
	harmful = FALSE
	fire_sound = 'sound/weapons/gunshots/1retrolaser.ogg'

/obj/item/ammo_casing/energy/laser/redtag
	projectile_type = /obj/projectile/beam/lasertag/redtag
	select_name = "redtag"
	sibyl_tier = SIBYL_TIER_NONLETHAL
	harmful = FALSE
	fire_sound = 'sound/weapons/gunshots/1retrolaser.ogg'

/obj/item/ammo_casing/energy/laser/accelerator
	projectile_type = /obj/projectile/beam/laser/accelerator
	select_name = "accelerator"
	fire_sound = 'sound/weapons/gunshots/accelerator_cannon.ogg'
	e_cost = 150
	delay = 20
	
/obj/item/ammo_casing/energy/laser/old
	e_cost = 200

// MARK: X-ray
/obj/item/ammo_casing/energy/xray
	projectile_type = /obj/projectile/beam/xray
	muzzle_flash_color = LIGHT_COLOR_GREEN
	delay = 11
	fire_sound = 'sound/weapons/gunshots/1xray.ogg'

// MARK: Immolator
/obj/item/ammo_casing/energy/immolator
	projectile_type = /obj/projectile/beam/immolator
	fire_sound = 'sound/weapons/gunshots/1xray.ogg'
	e_cost = 125
	bullet_type = BULLET_TYPE_FIRE

/obj/item/ammo_casing/energy/immolator/strong
	projectile_type = /obj/projectile/beam/immolator/strong
	e_cost = 50
	select_name = "precise"
	sibyl_tier = SIBYL_TIER_LETHAL

/obj/item/ammo_casing/energy/immolator/strong/cyborg
	// Used by gamma ERT borgs
	e_cost = 250 // 5x that of the standard laser, for 2.25x the damage (if 1/1 shots hit) plus ignite. Not energy-efficient, but can be used for sniping.

/obj/item/ammo_casing/energy/immolator/scatter
	projectile_type = /obj/projectile/beam/immolator/weak
	e_cost = 50
	pellets = 6
	variance = 25
	select_name = "scatter"
	sibyl_tier = SIBYL_TIER_LETHAL

/obj/item/ammo_casing/energy/immolator/scatter/cyborg
	// Used by gamma ERT borgs
	e_cost = 250 // 5x that of the standard laser, for 7.5x the damage (if 6/6 shots hit) plus ignite. Efficient only if you hit with at least 4/6 of the shots.

// MARK: Sniper
// TODO: MAKE IT /laser TYPE PLEASE
/obj/item/ammo_casing/energy/sniper
	projectile_type = /obj/projectile/beam/sniper
	muzzle_flash_color = LIGHT_COLOR_PINK
	fire_sound = 'sound/weapons/marauder.ogg'
	delay = 50
	select_name = "snipe"
	sibyl_tier = SIBYL_TIER_LETHAL

/obj/item/ammo_casing/energy/podsniper/disabler
	projectile_type = /obj/projectile/beam/podsniper/disabler
	muzzle_flash_color = LIGHT_COLOR_BLUE
	fire_sound = 'sound/weapons/LSR-39_disabler.ogg'
	delay = 3 SECONDS
	select_name = "disable"

/obj/item/ammo_casing/energy/podsniper/laser
	projectile_type = /obj/projectile/beam/podsniper/laser
	muzzle_flash_color = COLOR_SOFT_RED
	fire_sound = 'sound/weapons/LSR-39_kill.ogg'
	delay = 3 SECONDS
	e_cost = 150
	select_name = "kill"
	sibyl_tier = SIBYL_TIER_LETHAL
