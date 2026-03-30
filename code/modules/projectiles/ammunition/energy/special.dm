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

/obj/item/ammo_casing/energy/flora/gamma/fire(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/firer_source_atom, damage_mod = 1, stamina_mod = 1)
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
