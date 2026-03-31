// I FUCKING HATE THE AUTHOR OF THIS BULLSHIT

/obj/item/ammo_casing/energy/rat
	name = "mechanical energy module"
	desc = "Несколько шестерней, запитывающих оружие энергией Ратвара."
	caliber = "ratvar"
	projectile_type = /obj/projectile/energy/rat
	fire_sound = 'sound/weapons/gunshots/1shotgun.ogg'
	e_cost = 1

/obj/item/ammo_casing/energy/rat/get_ru_names()
	return list(
		NOMINATIVE = "механическая энергоячейка",
		GENITIVE = "механической энергоячейки",
		DATIVE = "механической энергоячейке",
		ACCUSATIVE = "механическую энергоячейку",
		INSTRUMENTAL = "механичекой энергоячейкой",
		PREPOSITIONAL = "механической энергоячейке",
	)

/obj/item/ammo_casing/energy/rat/slug
	projectile_type = /obj/projectile/energy/rat/slug

/obj/item/ammo_casing/energy/rat/slug/emp
	projectile_type = /obj/projectile/energy/rat/slug/emp

/obj/item/ammo_casing/energy/rat/slug/heal
	projectile_type = /obj/projectile/energy/rat/slug/heal
	fire_sound = 'sound/magic/staff_healing.ogg'

/obj/item/ammo_casing/energy/rat/slug/stun
	projectile_type = /obj/projectile/energy/rat/slug/stun
	fire_sound =  'sound/weapons/gunshots/gunshot_mg.ogg'

/obj/item/ammo_casing/energy/rat/snipe
	projectile_type = /obj/projectile/energy/rat/snipe
	fire_sound = 'sound/weapons/gunshots/1sniper.ogg'

/obj/item/ammo_casing/energy/rat/snipe/emp
	projectile_type = /obj/projectile/energy/rat/snipe/emp

/obj/item/ammo_casing/energy/rat/snipe/heal
	projectile_type = /obj/projectile/energy/rat/snipe/heal
	fire_sound = 'sound/magic/staff_healing.ogg'

/obj/item/ammo_casing/energy/rat/snipe/stun
	projectile_type = /obj/projectile/energy/rat/snipe/stun
	fire_sound =  'sound/weapons/gunshots/gunshot_mg.ogg'

/obj/item/ammo_casing/energy/laser/light/rat
	projectile_type = /obj/projectile/beam/laser/light/rat
	e_cost = 1
	color = COLOR_TANGERINE_YELLOW
	muzzle_flash_color = COLOR_TANGERINE_YELLOW

/obj/item/ammo_casing/energy/rat_sphere
	projectile_type = /obj/projectile/energy/sphere
	e_cost = 0
	color = COLOR_YELLOW

/obj/item/ammo_casing/energy/rat_sphere/attack
	projectile_type = /obj/projectile/energy/sphere/attack
	muzzle_flash_color = COLOR_DARK_MODERATE_ORANGE

/obj/item/ammo_casing/energy/rat_sphere/heal
	projectile_type = /obj/projectile/energy/sphere/heal
	muzzle_flash_color = LIGHT_COLOR_VIVID_GREEN
