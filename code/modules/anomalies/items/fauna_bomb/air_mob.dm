/mob/living/simple_animal/hostile/airmob
	gender = FEMALE
	healable = FALSE // It would be strange if styptic powder treated compressed air.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	sentience_type = SENTIENCE_OTHER
	deathmessage = "распадается."
	pressure_resistance = 500
	weather_immunities = list("air_mob")
	robust_searching = TRUE
	search_objects = TRUE
	/// Armor of this mob. Req if mob was made of human with armor.
	var/list/armor
	/// Fauna bomb that spawned this mob.
	var/obj/item/fauna_bomb/spawner
	/// Amount of charge that req for this mob.
	var/req_charge = 0
	/// Number of scan data. Used to find mob of some type.
	var/scan_num = 0

/mob/living/simple_animal/hostile/airmob/Destroy()
	armor = null
	spawner = null
	. = ..()

/mob/living/simple_animal/hostile/airmob/Initialize(mapload, obj/item/fauna_bomb/spawner, datum/airmob_data/data)
	. = ..()
	src.spawner = spawner
	scan_num = data.scan_num
	name = data.name
	ru_names = data.ru_names
	desc = data.desc
	maxHealth = data.maxHealth
	armor = data.armor
	health = data.maxHealth
	response_help = data.response_help
	response_disarm = data.response_disarm
	response_harm = data.response_harm
	harm_intent_damage = data.harm_intent_damage
	melee_damage_lower = max(5, data.melee_damage_lower)
	melee_damage_upper = max(5, data.melee_damage_upper)
	obj_damage = data.obj_damage
	armour_penetration = data.armour_penetration
	friendly = data.friendly
	environment_smash = data.environment_smash
	speed = data.speed
	leash = spawner
	leash_radius = round(spawner.core.get_strength() / 15 + 0.5)
	mob_size = data.mob_size
	rapid_melee = data.rapid_melee
	if(data.appearance)
		appearance = data.appearance

	alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	var/turf/simulated/turf = get_turf(spawner)
	if(istype(turf) && turf.air.toxins > MOLES_PLASMA_VISIBLE)
		can_be_on_fire = TRUE
		fire_damage = 20 // Fire kills plasma creatures.
		add_atom_colour(COLOR_PINK, FIXED_COLOUR_PRIORITY)
	else
		color = MATRIX_GREYSCALE

	req_charge = data.req_charge

/mob/living/simple_animal/hostile/airmob/getarmor(def_zone, attack_flag = MELEE)
	return armor[attack_flag]

/mob/living/simple_animal/hostile/airmob/death(gibbed)
	spawner.use_charge(-req_charge)
	spawner.used_charge -= req_charge
	spawner.max_charge += req_charge
	. = ..()
	spawner.created_mobs.Remove(src)
	qdel(src)

/mob/living/simple_animal/hostile/airmob/MeleeAction(patience)
	. = ..()
	sidestep_per_cycle = rand(1, 2)

/mob/living/simple_animal/hostile/airmob/PickTarget()
	if(spawner.last_command == "attack")
		return spawner.current_target

	// We won't attack in go and stop mods.
	return

/mob/living/simple_animal/hostile/airmob/Move(atom/newloc, direct, glide_size_override, update_dir)
	if(get_dist(spawner, newloc) + 3 <= leash_radius) // We don't want to risk.
		return ..()

/mob/living/simple_animal/hostile/airmob/proc/do_commands()
	if(!spawner)
		death()

	if(!spawner.current_target)
		return

	if(spawner.last_command == "attack")
		FindTarget()
		return

	if(spawner.last_command == "go")
		Goto(get_turf(spawner?.current_target), move_to_delay, get_dist(src, spawner.current_target) - 1)
		return

	if(!spawner.last_command || spawner.last_command == "stop")
		lose_target()
		return

	if(get_dist(src, spawner.current_target) > 7)
		Goto(get_turf(spawner.current_target), move_to_delay, get_dist(src, spawner.current_target) - 3)

/mob/living/simple_animal/hostile/airmob/Life(seconds, times_fired)
	. = ..()
	do_commands()
	if(get_dist(src, spawner) + 4 > leash_radius)
		Goto(get_turf(spawner), move_to_delay, 3)
		return

