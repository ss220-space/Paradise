// MARK: Specter pistol
/obj/item/ammo_casing/energy/specter/laser
	caliber = CALIBER_SPECTER
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/beam/specter/laser
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = COLOR_SOFT_RED
	select_name = "kill"
	sibyl_tier = SIBYL_TIER_LETHAL
	e_cost = 900
	fire_sound = 'sound/weapons/gunshots/speclaser.ogg'
	bullet_type = BULLET_TYPE_LASER

/obj/item/ammo_casing/energy/specter/disable
	caliber = CALIBER_SPECTER
	materials = list(MAT_METAL = 800)
	projectile_type = /obj/projectile/beam/specter/disabler
	muzzle_flash_color = LIGHT_COLOR_BLUE
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash
	e_cost = 450
	fire_sound = 'sound/weapons/gunshots/specdisabler.ogg'
	harmful = FALSE
	bullet_type = BULLET_TYPE_DISABLER

// MARK: Emmiter gun
/obj/item/ammo_casing/energy/emittergun
	projectile_type = /obj/projectile/beam/emitter
	e_cost = 200
	fire_sound = 'sound/weapons/emitter.ogg'
	delay = 25
	muzzle_flash_color = LIGHT_COLOR_GREEN
	select_name  = "emitter"

/obj/item/ammo_casing/energy/emittergunborg
	projectile_type = /obj/projectile/beam/emitter
	fire_sound = 'sound/weapons/emitter.ogg'
	delay = 30
	muzzle_flash_color = LIGHT_COLOR_GREEN
	select_name  = "emitter"
	e_cost = 750

// MARK: Dominator
// Why does it even need it's own projectiles?
/obj/item/ammo_casing/energy/dominator/stun
	projectile_type = /obj/projectile/energy/electrode/dominator
	muzzle_flash_color = LIGHT_COLOR_BLUE
	select_name = "taser"
	fluff_select_name = "stun"
	fire_sound = 'sound/weapons/gunshots/1taser.ogg'
	e_cost = 250
	delay = 2 SECONDS
	harmful = FALSE

/obj/item/ammo_casing/energy/dominator/paralyzer
	projectile_type = /obj/projectile/beam/dominator/paralyzer
	muzzle_flash_color = LIGHT_COLOR_BLUE
	select_name = "disable"
	fluff_select_name  = "non-lethal paralyzer"
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	harmful = FALSE

/obj/item/ammo_casing/energy/dominator/eliminator
	projectile_type = /obj/projectile/beam/dominator/eliminator
	muzzle_flash_color = LIGHT_COLOR_DARK_BLUE
	select_name = "lethal"
	fluff_select_name = "lethal-eliminator"
	sibyl_tier = SIBYL_TIER_LETHAL
	e_cost = 200

/obj/item/ammo_casing/energy/dominator/slaughter
	projectile_type = /obj/projectile/beam/dominator/slaughter
	muzzle_flash_color = LIGHT_COLOR_DARK_BLUE
	select_name = "destroy"
	fluff_select_name  = "execution-slaughter"
	sibyl_tier = SIBYL_TIER_DESTRUCTIVE
	fire_sound = 'sound/weapons/marauder.ogg'
	e_cost = 250
	delay = 30

// MARK: Mimic gun
// TODO: Delete it. Not used anywhere in game (if it ever was).
/obj/item/ammo_casing/energy/mimic
	projectile_type = /obj/projectile/mimic
	muzzle_flash_effect = null
	fire_sound = 'sound/weapons/bite.ogg'
	select_name = "gun mimic"
	var/mimic_type

/obj/item/ammo_casing/energy/mimic/New()
	..()
	BB = null

/obj/item/ammo_casing/energy/mimic/newshot()
	..(mimic_type)

// MARK: Shock revolver
/obj/item/ammo_casing/energy/shock_revolver
	fire_sound = 'sound/magic/lightningbolt.ogg'
	e_cost = 200
	select_name = "lightning beam"
	muzzle_flash_color = LIGHT_COLOR_LAVENDER
	projectile_type = /obj/projectile/energy/shock_revolver

// MARK: HONK rifle
/obj/item/ammo_casing/energy/clown
	projectile_type = /obj/projectile/clown
	muzzle_flash_effect = null
	fire_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	select_name = "clown"
