/mob/living/simple_animal/hostile/plant
	name = "base plant"
	desc = "Выглядит как то что не должно было быть увиденным."
	icon = 'icons/mob/alien.dmi'
	icon_state = "alienh_running"
	icon_living = "alienh_running"
	icon_dead = "alienh_dead"
	icon_gib = "syndicate_gib"
	gender = MALE
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	maxHealth = 50
	health = 50
	harm_intent_damage = 0
	obj_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	heat_damage_per_tick = 0
	faction = list("plants", "vines", "terraformers")
	AI_delay_max = 0.5 SECONDS
	AIStatus = AI_OFF
	dodging = FALSE
	var/obj/machinery/hydroponics/our_tray = null

/mob/living/simple_animal/hostile/plant/proc/on_connected_simplemob_death()
	SIGNAL_HANDLER
	our_tray.connected_simplemob = null
	our_tray.plantdies()

/mob/living/simple_animal/hostile/plant/Initialize(mapload)
	. = ..()
	status_flags &= ~CANPUSH
	move_resist = MOVE_FORCE_OVERPOWERING
	src.pixel_y += 10

/mob/living/simple_animal/hostile/plant/pea_shooter/death(gibbed)
	STOP_PROCESSING(SSprocessing, src)
	. = ..(TRUE)

/mob/living/simple_animal/hostile/plant/proc/find_target(range)
	. = null

	var/best_dist = range + 1
	for(var/mob/living/target in view(range, src))
		if ("terraformers" in target.faction)
			continue
		if (target.is_dead())
			continue

		var/new_dist = get_dist(src, target)
		if (new_dist < best_dist)
			best_dist = new_dist
			. = target

/obj/item/projectile/pea
	name = "pea"
	icon = 'icons/obj/hydroponics/plants_vs_zombies/peagun.dmi'
	icon_state = "pea-bullet"
	damage = 20
	damage_type = BRUTE
	flag = "bullet"
	hitsound = "bullet"
	hitsound_wall = "ricochet"
	impact_effect_type = /obj/effect/temp_visual/pea_destroy
	/// Count of passed torchwoods
	var/fired = 0

/obj/item/projectile/pea/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..(target, blocked, hit_zone)

	var/mob/living/target_mob = target

	if (!istype(target_mob))
		return

	if (fired > 0)
		target_mob.adjust_fire_stacks(5)
		target_mob.IgniteMob()

/obj/item/projectile/pea/Initialize()
	. = ..()
	whitelist = subtypesof(/mob/living/simple_animal/hostile/plant)

/obj/item/ammo_casing/pea
	desc = "A pea casing."
	caliber = "pea"
	projectile_type = /obj/item/projectile/pea
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/projectile/pea/frost_pea
	name = "frost pea"
	damage = 15
	fired = -1

/obj/item/projectile/pea/frost_pea/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..(target, blocked, hit_zone)

	if (!ismob(target))
		return

	if (fired >= 0)
		return

	var/mob/target_mob = target

	if (ishuman(target))
		target_mob.reagents.add_reagent("frostoil", 5)
		target_mob.adjust_bodytemperature(-50)
	else
		target_mob.adjust_bodytemperature(-100)

/obj/item/ammo_casing/frost_pea
	desc = "A frost pea casing."
	caliber = "pea"
	projectile_type = /obj/item/projectile/pea/frost_pea
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL


/mob/living/simple_animal/hostile/plant/pea_shooter
	name = "pea shooter"
	desc = "Выглядит как живой и слегка разумный горох."
	icon = 'icons/obj/hydroponics/plants_vs_zombies/peagun.dmi'
	icon_state = "peagun-static"
	icon_living = "peagun-static"
	icon_dead = "peagun-dead"
	var/obj/item/ammo_casing/chambered = null
	var/bullet_type = /obj/item/ammo_casing/pea
	var/range = 10

/mob/living/simple_animal/hostile/plant/pea_shooter/Initialize()
	. = ..()
	chambered = new bullet_type()
	START_PROCESSING(SSprocessing, src)

/mob/living/simple_animal/hostile/plant/pea_shooter/proc/rotate_to(mob/living/target)
	var/dx = target.x - x
	var/dy = target.y - y
	var/bigger_X = abs(dx) >= abs(dy) * 2.5
	var/bigger_Y = abs(dy) >= abs(dx) * 2.5
	if (dx > 0 && bigger_X)
		setDir(EAST)
	else if (dy > 0 && bigger_Y)
		setDir(NORTH)
	else if (dx < 0 && bigger_X)
		setDir(WEST)
	else if (dy < 0 && bigger_Y)
		setDir(SOUTH)
	else if (dx > 0 && dy > 0)
		setDir(NORTHEAST)
	else if (dx < 0 && dy > 0)
		setDir(NORTHWEST)
	else if (dx < 0 && dy < 0)
		setDir(SOUTHWEST)
	else
		setDir(SOUTHEAST)

/mob/living/simple_animal/hostile/plant/pea_shooter/proc/fire(mob/living/target)
	if (!target)
		return
	rotate_to(target)
	icon_state = "peagun-attack"
	sleep(2)
	SEND_SIGNAL(src, COMSIG_GUN_FIRED, src, target)
	chambered.fire(target = target, user = src, firer_source_atom = src, zone_override = random_body_accessory(SPECIES_HUMAN))
	chambered = new bullet_type()
	sleep(2)
	rotate_to(target)
	icon_state = "peagun-static"

/mob/living/simple_animal/hostile/plant/pea_shooter/process()
	if (HAS_TRAIT(src, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		return

	var/mob/living/target = find_target(range)
	fire(target)

/mob/living/simple_animal/hostile/plant/pea_shooter/double
	name = "double pea shooter"
	desc = "Выглядит как живой, опасный и слегка разумный горох."
	maxHealth = 60
	health = 60

/mob/living/simple_animal/hostile/plant/pea_shooter/double/process()
	if (HAS_TRAIT(src, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		return

	var/mob/living/target = find_target(range)
	fire(target)
	sleep(2)
	fire(target)

/mob/living/simple_animal/hostile/plant/pea_shooter/ultra
	name = "pea machine gun"
	desc = "Выглядит как живой, невероятно опасный и слегка разумный горох."
	maxHealth = 75
	health = 75

/mob/living/simple_animal/hostile/plant/pea_shooter/ultra/process()
	if (HAS_TRAIT(src, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		return

	var/mob/living/target = find_target(range)
	fire(target)
	sleep(2)
	fire(target)
	sleep(2)
	fire(target)
	sleep(2)
	fire(target)

/mob/living/simple_animal/hostile/plant/pea_shooter/frost
	name = "frost pea shooter"
	desc = "Выглядит как живой, холодный и слегка разумный горох."
	bullet_type = /obj/item/ammo_casing/frost_pea
