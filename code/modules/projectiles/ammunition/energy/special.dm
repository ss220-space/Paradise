// MARK: Ion (EMP)
/obj/item/ammo_casing/energy/ion
	projectile_type = /obj/projectile/ion
	muzzle_flash_color = LIGHT_COLOR_BLUE
	delay = 0.4 SECONDS
	select_name = "ion"
	fire_sound = 'sound/weapons/ionrifle.ogg'

// MARK: Declone
/obj/item/ammo_casing/energy/declone
	projectile_type = /obj/projectile/energy/declone
	muzzle_flash_color = LIGHT_COLOR_GREEN
	select_name = "declone"
	sibyl_tier = SIBYL_TIER_LETHAL
	fire_sound = 'sound/weapons/gunshots/1declone.ogg'

// MARK: Mindflayer
/obj/item/ammo_casing/energy/mindflayer
	projectile_type = /obj/projectile/beam/mindflayer
	select_name = "MINDFUCK"
	sibyl_tier = SIBYL_TIER_LETHAL
	fire_sound = 'sound/weapons/laser.ogg'

// MARK: Flora rays
/obj/item/ammo_casing/energy/flora
	fire_sound = 'sound/effects/stealthoff.ogg'
	muzzle_flash_color = LIGHT_COLOR_GREEN
	harmful = FALSE

/obj/item/ammo_casing/energy/flora/alpha
	name = "alpha"
	select_name = "floraalpha"
	fire_sound = 'sound/weapons/gunshots/1declone.ogg'
	projectile_type = /obj/projectile/energy/floraalpha
	harmful = TRUE
	click_cooldown_override = 2
	e_cost = 150

/obj/item/ammo_casing/energy/flora/alpha/emag
	projectile_type = /obj/projectile/energy/floraalpha/emag
	e_cost = 225

/obj/item/ammo_casing/energy/flora/beta
	name = "beta"
	select_name = "florabeta"
	projectile_type = /obj/projectile/energy/florabeta
	click_cooldown_override = 1
	e_cost = 75

/obj/item/ammo_casing/energy/flora/gamma
	name = "gamma"
	select_name = "floragamma"
	projectile_type = /obj/projectile/energy/floragamma
	delay = 10
	e_cost = 675

/obj/item/ammo_casing/energy/flora/gamma/fire(atom/target, mob/living/user, list/modifiers, distro, quiet, zone_override, spread, atom/firer_source_atom, damage_mod = 1, stamina_mod = 1)
	playsound(src.loc, 'sound/weapons/floragun_gamma.ogg', 75, TRUE)
	if(!do_after(user, 0.5 SECONDS, user, DA_IGNORE_USER_LOC_CHANGE, progress = FALSE))
		return FALSE
	. = ..()

// MARK: Temperature
/obj/item/ammo_casing/energy/temp
	projectile_type = /obj/projectile/temp
	fire_sound = 'sound/weapons/gunshots/1laser7.ogg'
	var/temp = 300

/obj/item/ammo_casing/energy/temp/Initialize(mapload)
	. = ..()
	BB = null

/obj/item/ammo_casing/energy/temp/newshot()
	..(temp)

// MARK: Meteor
/obj/item/ammo_casing/energy/meteor
	projectile_type = /obj/projectile/meteor
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash
	muzzle_flash_color = null
	select_name = "goddamn meteor"

// MARK: Instakill
/obj/item/ammo_casing/energy/instakill
	projectile_type = /obj/projectile/beam/instakill
	muzzle_flash_color = LIGHT_COLOR_PURPLE
	e_cost = 0
	select_name = "DESTROY"
	sibyl_tier = SIBYL_TIER_DESTRUCTIVE
	fire_sound = 'sound/weapons/marauder.ogg'

/obj/item/ammo_casing/energy/instakill/blue
	projectile_type = /obj/projectile/beam/instakill/blue
	muzzle_flash_color = LIGHT_COLOR_DARK_BLUE

/obj/item/ammo_casing/energy/instakill/red
	projectile_type = /obj/projectile/beam/instakill/red
	muzzle_flash_color = COLOR_SOFT_RED

// MARK: Shuriken
/obj/item/ammo_casing/energy/shuriken
	projectile_type = /obj/projectile/beam/shuriken
	muzzle_flash_color = LIGHT_COLOR_GREEN
	select_name  = "shuriken"
	e_cost = 0
	fire_sound = 'sound/weapons/bulletflyby.ogg'
	click_cooldown_override = 2
	harmful = FALSE
	delay = 3

/obj/item/ammo_casing/energy/shuriken/borg
	e_cost = 50

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

// MARK: Vortex blast
/obj/item/ammo_casing/energy/vortex_blast
	projectile_type = /obj/projectile/energy/vortex_blast
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash/vortex_blast
	variance = 70
	pellets = 8
	delay = 1.2 SECONDS //and delay has to be stored here on energy guns
	select_name = "vortex blast"
	fire_sound = 'sound/weapons/wave.ogg'

// MARK: Sonic
/obj/item/ammo_casing/energy/sonic
	projectile_type = /obj/projectile/energy/sonic
	fire_sound = 'sound/effects/basscannon.ogg'
	delay = 40

// MARK: Energy spike
/obj/item/ammo_casing/energy/spike
	name = "alloy spike"
	desc = "A broadhead spike made out of a weird silvery metal."
	projectile_type = /obj/projectile/bullet/spike
	muzzle_flash_effect = null
	delay = 3 //and delay has to be stored here on energy guns
	select_name = "spike"
	fire_sound = 'sound/weapons/bladeslice.ogg'
