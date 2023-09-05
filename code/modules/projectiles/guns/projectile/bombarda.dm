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

/obj/item/gun/projectile/bombarda/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
		A.update_icon()
		update_icon()

/obj/item/gun/projectile/bombarda/process_chamber(eject_casing = TRUE, empty_chamber = TRUE)
	..()

/obj/item/gun/projectile/bombarda/chamber_round()
	return

/obj/item/gun/projectile/bombarda/can_shoot()
	if(!chambered)
		return 0
	return (chambered.BB ? 1 : 0)


/obj/item/gun/projectile/bombarda/attack_self(mob/living/user)
	pump(user)
	return

/obj/item/gun/projectile/bombarda/proc/pump(mob/M)
	playsound(M, 'sound/weapons/gun_interactions/sawclose.ogg', 60, 1)
	pump_unload(M)
	pump_reload(M)
	update_icon()
	return 1

/obj/item/gun/projectile/bombarda/proc/pump_unload(mob/M)
	if(chambered)
		chambered.loc = get_turf(src)
		chambered.SpinAnimation(5, 1)
		playsound(src, chambered.drop_sound, 60, 1)
		chambered = null

/obj/item/gun/projectile/bombarda/proc/pump_reload(mob/M)
	if(!magazine.ammo_count())
		return 0
	var/obj/item/ammo_casing/AC = magazine.get_round()
	chambered = AC

/obj/item/ammo_box/magazine/internal/bombarda
	name = "bombarda internal magazine"
	ammo_type = /obj/item/ammo_casing/grenade/improvised
	caliber = "40mm"
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/bombarda/New()
	..()
	stored_ammo = list()	//not supposed to have initial ammo.

/obj/item/ammo_box/magazine/internal/bombarda/ammo_count(countempties = 1)
	if(!countempties)
		var/boolets = 0
		for(var/obj/item/ammo_casing/bullet in stored_ammo)
			if(bullet.BB)
				boolets++
		return boolets
	else
		return ..()

/obj/item/ammo_casing/grenade/improvised
	name = "Improvised shell"
	desc = "Does something upon impact or after some time. If you see this, contact the coder."
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "exp_shell"
	item_state = "exp_shell"
	caliber = "40mm"

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
	explosion(loc, 0, 0, 0, flame_range = 6, cause = src)

/obj/item/projectile/grenade/improvised/smoke_shot
	icon_state = "smoke_shot"

/obj/item/projectile/grenade/improvised/smoke_shot/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/datum/effect_system/smoke_spread/smoke = new /datum/effect_system/smoke_spread()
	smoke.set_up(15, FALSE, loc)
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


/datum/crafting_recipe/explosion_shell
	name = "Improvised explosive shell"
	result = /obj/item/ammo_casing/grenade/improvised/exp_shell
	reqs = list(/obj/item/grenade/iedcasing = 1,
				/obj/item/grenade/chem_grenade = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/assembly/prox_sensor = 1)
	time = 2 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

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
	subcategory = CAT_WEAPON

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
	subcategory = CAT_WEAPON
