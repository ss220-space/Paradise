/obj/item/gun/projectile/bombarda
	name = "Bombarda"
	desc = "Hand made analog of grenade launcher. Can fire improvised shells."
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "bombarda"
	item_state = "bombarda"
	mag_type = /obj/item/ammo_box/magazine/internal/bombarda
	fire_sound = 'sound/weapons/gunshots/1grenlauncher.ogg'
	can_holster = FALSE
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	var/pump_cooldown = 1 SECONDS
	COOLDOWN_DECLARE(last_pump)


/obj/item/gun/projectile/bombarda/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box) || istype(I, /obj/item/ammo_casing))
		add_fingerprint(user)
		if(chambered)
			balloon_alert(user, "уже заряжено!")
			return ATTACK_CHAIN_PROCEED
		var/loaded = magazine.reload(I, user, silent = TRUE)
		if(loaded)
			chambered = magazine.get_round()
			balloon_alert(user, "заряжено")
			update_icon()
			return ATTACK_CHAIN_BLOCKED_ALL
		balloon_alert(user, "не удалось!")
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/gun/projectile/bombarda/update_icon_state()
	icon_state = "bombarda[chambered ? "" : "_open"]"


/obj/item/gun/projectile/bombarda/process_chamber(eject_casing = FALSE, empty_chamber = FALSE)
	. = ..()


/obj/item/gun/projectile/bombarda/chamber_round()
	return


/obj/item/gun/projectile/bombarda/can_shoot(mob/user)
	if(!chambered)
		return FALSE
	return (chambered.BB ? TRUE : FALSE)


/obj/item/gun/projectile/bombarda/attack_self(mob/living/user)
	if(!COOLDOWN_FINISHED(src, last_pump))
		return
	COOLDOWN_START(src, last_pump, pump_cooldown)
	pump(user)


/obj/item/gun/projectile/bombarda/proc/pump(mob/user)
	add_fingerprint(user)
	var/was_chambered = FALSE
	if(chambered)
		was_chambered = TRUE
		chambered.forceMove(drop_location())
		chambered.SpinAnimation(5, 1)
		chambered.pixel_x = rand(-10, 10)
		chambered.pixel_y = rand(-10, 10)
		chambered.setDir(pick(GLOB.alldirs))
		playsound(chambered.loc, chambered.casing_drop_sound, 60, TRUE)
		chambered = null
	if(!magazine.ammo_count())
		if(was_chambered)
			playsound(loc, 'sound/weapons/bombarda/pump.ogg', 60, TRUE)
			update_icon()
		return FALSE
	playsound(loc, 'sound/weapons/bombarda/pump.ogg', 60, TRUE)
	chambered = magazine.get_round()
	update_icon()
	return TRUE


/obj/item/ammo_box/magazine/internal/bombarda
	name = "bombarda internal magazine"
	ammo_type = /obj/item/ammo_casing/grenade/improvised
	caliber = "40mm"
	max_ammo = 1
	insert_sound = 'sound/weapons/bombarda/load.ogg'
	remove_sound = 'sound/weapons/bombarda/open.ogg'
	load_sound = 'sound/weapons/bombarda/load.ogg'
	start_empty = TRUE


/obj/item/ammo_box/magazine/internal/bombarda/ammo_count(countempties = TRUE)
	. = 0
	for(var/obj/item/ammo_casing/bullet in stored_ammo)
		if(bullet.BB || countempties)
			.++


/obj/item/ammo_casing/grenade/improvised
	name = "Improvised shell"
	desc = "Does something upon impact or after some time. If you see this, contact the coder."
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "exp_shell"
	item_state = "exp_shell"
	caliber = "40mm"
	drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'

/obj/item/ammo_casing/grenade/improvised/exp_shell
	name = "Improvised explosive shell"
	desc = "Explodes upon impact or after some time."
	projectile_type = /obj/item/projectile/grenade/improvised/exp_shot
	icon_state = "exp_shell"
	item_state = "exp_shell"

/obj/item/ammo_casing/grenade/improvised/flame_shell
	name = "Improvised flame shell"
	desc = "Explodes with flames upon impact or after some time"
	projectile_type = /obj/item/projectile/grenade/improvised/flame_shot
	icon_state = "flame_shell"
	item_state = "flame_shell"

/obj/item/ammo_casing/grenade/improvised/smoke_shell
	name = "Improvised smoke shell"
	desc = "Explodes with smoke upon impact or after some time"
	projectile_type = /obj/item/projectile/grenade/improvised/smoke_shot
	icon_state = "smoke_shell"
	item_state = "smoke_shell"

/obj/item/projectile/grenade/improvised
	icon = 'icons/obj/weapons/bombarda.dmi'
	hitsound = "bullet"
	hitsound_wall = "ricochet"

/obj/item/projectile/grenade/improvised/exp_shot
	icon_state = "exp_shot"

/obj/item/projectile/grenade/improvised/exp_shot/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	explosion(loc, -1, -1, 2, flame_range = 3, cause = src)

/obj/item/projectile/grenade/improvised/flame_shot
	icon_state = "flame_shot"

/obj/item/projectile/grenade/improvised/flame_shot/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	explosion(loc, 0, 0, 0, flame_range = 8, cause = src)
	fireflash(loc, 2, 682)

/obj/item/projectile/grenade/improvised/smoke_shot
	icon_state = "smoke_shot"

/obj/item/projectile/grenade/improvised/smoke_shot/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/datum/effect_system/smoke_spread/smoke = new /datum/effect_system/smoke_spread/bad()
	smoke.set_up(18, FALSE, loc)
	smoke.custom_lifetime = 20
	smoke.color = "#800080"
	smoke.start()

/datum/crafting_recipe/bombarda
	name = "Bombarda"
	result = /obj/item/gun/projectile/bombarda
	reqs = list(/obj/item/restraints/handcuffs/cable = 2,
				/obj/item/stack/tape_roll = 10,
				/obj/item/pipe = 1,
				/obj/item/weaponcrafting/receiver = 1,
				/obj/item/stack/sheet/metal = 2,
				/obj/item/weaponcrafting/stock = 1)
	time = 6 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	always_availible = FALSE

/datum/crafting_recipe/bombarda/New()
	. = ..()
	if(CONFIG_GET(flag/enable_bombarda_craft))
		always_availible = TRUE

/datum/crafting_recipe/explosion_shell
	name = "Improvised explosive shell"
	result = /obj/item/ammo_casing/grenade/improvised/exp_shell
	reqs = list(/obj/item/grenade/iedcasing = 1,
				/obj/item/grenade/chem_grenade = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/assembly/prox_sensor = 1)
	time = 2 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
	always_availible = FALSE

/datum/crafting_recipe/explosion_shell/New()
	. = ..()
	if(CONFIG_GET(flag/enable_bombarda_craft))
		always_availible = TRUE

/datum/crafting_recipe/flame_shell
	name = "Improvised flame shell"
	result = /obj/item/ammo_casing/grenade/improvised/flame_shell
	reqs = list(/obj/item/grenade/chem_grenade = 1,
					/obj/item/stack/cable_coil = 5,
					/obj/item/stack/sheet/metal = 1,
					/obj/item/assembly/igniter = 1,
					/datum/reagent/fuel = 20,
					/datum/reagent/consumable/sugar = 10,
					/datum/reagent/plasma_dust = 10)
	time = 2 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
	always_availible = FALSE

/datum/crafting_recipe/flame_shell/New()
	. = ..()
	if(CONFIG_GET(flag/enable_bombarda_craft))
		always_availible = TRUE

/datum/crafting_recipe/smoke_shell
	name = "Improvised smoke shell"
	result = /obj/item/ammo_casing/grenade/improvised/smoke_shell
	reqs = list(/obj/item/grenade/chem_grenade = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/stack/sheet/metal = 1,
				/datum/reagent/consumable/sugar = 10,
				/datum/reagent/phosphorus = 10,
				/obj/item/reagent_containers/spray/pestspray = 1)
	time = 2 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
	always_availible = FALSE

/datum/crafting_recipe/smoke_shell/New()
	. = ..()
	if(CONFIG_GET(flag/enable_bombarda_craft))
		always_availible = TRUE
