//////////////
//MARK: ROBOT
//////////////

/obj/projectile/hivebot_bullet
	damage = 10
	damage_type = BRUTE

/obj/projectile/hivebot/light_bullet
	damage = 5
	damage_type = BRUTE

/obj/projectile/hivebot/heavy_bullet
	damage = 40
	damage_type = BRUTE
	knockdown = 4
	stamina = 10

// BASIC

/mob/living/simple_animal/hostile/hivebot
	name = "Hivebot"
	desc = "Многофункциональный робот с шестью манипуляторами. Судя по всему, собран из различных деталей, попавшихся под руку. На корпусе видны грубые швы и вмятины от ударов, а также выцарапанная надпись \"ВМС\"."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	health = 15
	maxHealth = 30
	melee_damage_lower = 10
	melee_damage_upper = 20
	ranged = 1
	rapid = 1
	rapid_fire_delay = 3
	attacktext = "рвёт"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	projectilesound = 'sound/weapons/gunshots/gunshot.ogg'
	projectiletype = /obj/projectile/hivebot_bullet
	faction = list("hivebot")
	check_friendly_fire = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speak_emote = list("констатирует")
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot, /obj/effect/loot_spawner/hivebot)
	deathmessage = "разваливается!"
	bubble_icon = "machine"
	del_on_death = 1
	footstep_type = FOOTSTEP_MOB_CLAW
	AI_delay_max = 0.5 SECONDS
	var/retreating = FALSE
	var/can_retreat = TRUE

/mob/living/simple_animal/hostile/hivebot/get_ru_names()
	ru_names = list(
		NOMINATIVE = "кустарный робот",
		GENITIVE = "кустарного робота",
		DATIVE = "кустарному роботу",
		ACCUSATIVE = "кустарного робота",
		INSTRUMENTAL = "кустарным роботом",
		PREPOSITIONAL = "кустарном роботе"
	)

/mob/living/simple_animal/hostile/hivebot/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/hivebot/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(updating_health && stat != DEAD)
		update_retreat_status()

/mob/living/simple_animal/hostile/hivebot/proc/update_retreat_status()
	if(!can_retreat)
		return

	var/health_percent = health / maxHealth
	if(health_percent <= 0.25 && !retreating)
		retreat_distance = 5
		minimum_distance = 4
		retreating = TRUE
	else if(health_percent >= 0.5 && retreating)
		retreat_distance = 0
		minimum_distance = 0
		retreating = FALSE

/mob/living/simple_animal/hostile/hivebot/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	do_sparks(3, 1, src)

//Melee

/mob/living/simple_animal/hostile/hivebot/melee
	name = "Hivebot"
	desc = "Многофункциональный робот с шестью манипуляторами. Его клешни похожи на молотки. Судя по всему, собран из различных деталей, попавшихся под руку. На корпусе видны грубые швы и вмятины от ударов, а также выцарапанная надпись \"ВМС\"."
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	health = 40
	maxHealth = 40
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "вбивает"
	speed = 3
	attack_sound = 'sound/weapons/bladeslice.ogg'
	can_retreat = FALSE

/mob/living/simple_animal/hostile/hivebot/melee/get_ru_names()
	ru_names = list(
		NOMINATIVE = "бронированный кустарный робот",
		GENITIVE = "бронированного кустарного робота",
		DATIVE = "бронированному кустарному роботу",
		ACCUSATIVE = "бронированного кустарного робота",
		INSTRUMENTAL = "бронированным кустарным роботом",
		PREPOSITIONAL = "бронированном кустарном роботе"
	)

/mob/living/simple_animal/hostile/hivebot/heavy_melee
	name = "Hivebot"
	desc = "Многофункциональный робот, грубо обшитый металлическими пластинами. На корпусе видны заклёпки, а щели между пластинами залиты бетоном. Судя по всему, собран из различных деталей, попавшихся под руку. На корпусе видны вмятины, а также выцарапанная надпись \"ВМС\"."
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	health = 80
	maxHealth = 80
	melee_damage_lower = 20
	melee_damage_upper = 20
	attacktext = "сокрушает"
	speed = 5
	ranged = FALSE
	attack_sound = 'sound/weapons/bladeslice.ogg'
	deathmessage = "скидывает щиты!"
	loot = list(/obj/effect/spawner/hivebot_heavy, /obj/effect/loot_spawner/hivebot, /obj/effect/loot_spawner/hivebot)
	can_retreat = FALSE

/mob/living/simple_animal/hostile/hivebot/heavy_melee/get_ru_names()
	ru_names = list(
		NOMINATIVE = "бронированный кустарный робот",
		GENITIVE = "бронированного кустарного робота",
		DATIVE = "бронированному кустарному роботу",
		ACCUSATIVE = "бронированного кустарного робота",
		INSTRUMENTAL = "бронированным кустарным роботом",
		PREPOSITIONAL = "бронированном кустарном роботе"
	)

//Range

/mob/living/simple_animal/hostile/hivebot/range
	name = "Hivebot"
	desc = "Многофункциональный робот с шестью манипуляторами. К его клешням приварены гвоздомёты. Судя по всему, собран из различных деталей, попавшихся под руку. На корпусе видны грубые швы и вмятины от ударов, а также выцарапанная надпись \"ВМС\"."
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	health = 25
	maxHealth = 25
	ranged = 1
	rapid = 5
	speed = 2
	rapid_fire_delay = 3
	retreat_distance = 4
	minimum_distance = 2
	projectiletype = /obj/projectile/hivebot/light_bullet
	projectilesound = 'sound/weapons/gunshots/1autorifle.ogg'

/mob/living/simple_animal/hostile/hivebot/range/get_ru_names()
	ru_names = list(
		NOMINATIVE = "кустарный робот с гвоздомётами",
		GENITIVE = "кустарного робота с гвоздомётами",
		DATIVE = "кустарному роботу с гвоздомётами",
		ACCUSATIVE = "кустарного робота с гвоздомётами",
		INSTRUMENTAL = "кустарным роботом с гвоздомётами",
		PREPOSITIONAL = "кустарном роботе с гвоздомётами"
	)

/mob/living/simple_animal/hostile/hivebot/range_heavy
	name = "Hivebot"
	desc = "Многофункциональный робот с шестью манипуляторами. В его клешнях модифицированный заклёпочный аппарат. Судя по всему, собран из различных деталей, попавшихся под руку. На корпусе видны грубые швы и вмятины от ударов, а также выцарапанная надпись \"ВМС\"."
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	ranged = 1
	rapid = 1
	rapid_fire_delay = 12
	retreat_distance = 8
	minimum_distance = 4
	melee_damage_lower = 0
	melee_damage_upper = 0
	speed = -2
	projectiletype = /obj/projectile/hivebot/heavy_bullet
	projectilesound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'

/mob/living/simple_animal/hostile/hivebot/range_heavy/get_ru_names()
	ru_names = list(
		NOMINATIVE = "кустарный робот с заклёпкомётом",
		GENITIVE = "кустарного робота с заклёпкомётом",
		DATIVE = "кустарному роботу с заклёпкомётом",
		ACCUSATIVE = "кустарного робота с заклёпкомётом",
		INSTRUMENTAL = "кустарным роботом с заклёпкомётом",
		PREPOSITIONAL = "кустарном роботе с заклёпкомётом"
	)

// Инженер

/mob/living/simple_animal/hostile/hivebot/support
	name = "Hivebot"
	desc = "Специализированный робот с набором ремонтных инструментов. Судя по всему, собран из различных деталей, попавшихся под руку. На корпусе видны грубые швы и вмятины от ударов, а также выцарапанная надпись \"ВМС\"."
	icon_state = "EngBot"
	icon_living = "EngBot"
	icon_dead = "EngBot"
	health = 50
	maxHealth = 50
	melee_damage_lower = 10
	melee_damage_upper = 10
	ranged = FALSE
	retreat_distance = 5
	minimum_distance = 3
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot, /obj/effect/loot_spawner/hivebot, /obj/effect/loot_spawner/hivebot)
	var/heal_cooldown = 5 SECONDS
	var/heal_amount = 15
	var/heal_range = 5
	var/last_heal_time = 0

/mob/living/simple_animal/hostile/hivebot/support/get_ru_names()
	ru_names = list(
		NOMINATIVE = "кустарный робот-механик",
		GENITIVE = "кустарного робота-механика",
		DATIVE = "кустарному роботу-механику",
		ACCUSATIVE = "кустарного робота-механика",
		INSTRUMENTAL = "кустарным роботом-механиком",
		PREPOSITIONAL = "кустарном роботе-механике"
	)

/mob/living/simple_animal/hostile/hivebot/support/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/hivebot/support/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/simple_animal/hostile/hivebot/support/process(delta_time)
	if(world.time < last_heal_time + heal_cooldown)
		return

	var/list/targets = list()
	for(var/mob/living/simple_animal/hostile/hivebot/H in view(heal_range, src))
		if(H != src && H.health < H.maxHealth && H.stat != DEAD)
			targets += H

	if(targets.len > 0)
		var/mob/living/simple_animal/hostile/hivebot/target = pick(targets)

		target.adjustHealth(-heal_amount)
		visible_message("span_redtext(capitalize(declent_ru(NOMINATIVE)] чинит [target.declent_ru(ACCUSATIVE)] с помощью ремонтных нанитов.)")

		var/datum/effect_system/spark_spread/sparks = new
		sparks.set_up(3, 0, get_turf(target))
		sparks.start()

		last_heal_time = world.time

//Фабрикатор

/obj/structure/hivebot_spawner
	name = "Hivebot Fabricator"
	desc = "Крупная машина, печатающая роботов улья из металлолома с определённой периодичностью. На боку грубо нацарапанная надпись \"ВМС\"."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "fab_robot"
	anchored = TRUE
	density = TRUE
	//Настройки Фабрикатора
	var/spawn_count = 2			 //The number of hivebots that will be produced per cycle before going into recharge
	var/spawn_interval = 1500 	 //Production time
	var/cooldown_duration = 3000 //Cooldown after Production time
	// Internal tracking variables
	var/next_spawn_time = 0		// When next spawn/action should occur
	var/cooldown_until = 0		// When cooldown period ends
	var/is_active = FALSE		// Whether currently producing bots

/obj/structure/hivebot_spawner/get_ru_names()
	ru_names = list(
		NOMINATIVE = "фабрикатор",
		GENITIVE = "фабрикатора",
		DATIVE = "фабрикатору",
		ACCUSATIVE = "фабрикатор",
		INSTRUMENTAL = "фабрикатором",
		PREPOSITIONAL = "фабрикаторе"
	)

/obj/structure/hivebot_spawner/Initialize(mapload)
	. = ..()
	next_spawn_time = world.time + spawn_interval
	START_PROCESSING(SSobj, src)

/obj/structure/hivebot_spawner/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/hivebot_spawner/process()
	if(world.time >= cooldown_until && !is_active)
		if(world.time >= next_spawn_time)
			start_production()
	else if(is_active && world.time >= next_spawn_time)
		spawn_bots()

/obj/structure/hivebot_spawner/proc/start_production()
	is_active = TRUE
	icon_state = "fab_robot"
	visible_message("span_warning([capitalize(declent_ru(NOMINATIVE)] начинает гудеть!)")
	next_spawn_time = world.time + (spawn_interval / spawn_count)

/obj/structure/hivebot_spawner/proc/spawn_bots()
	var/list/hivebot_types = list(
		/mob/living/simple_animal/hostile/hivebot,
		/mob/living/simple_animal/hostile/hivebot/melee,
		/mob/living/simple_animal/hostile/hivebot/range,
		/mob/living/simple_animal/hostile/hivebot/range_heavy,
		/mob/living/simple_animal/hostile/hivebot/support
	)

	var/spawn_type = pick(hivebot_types)
	new spawn_type(get_turf(src))

	if(--spawn_count <= 0)
		finish_production()
	else
		next_spawn_time = world.time + (spawn_interval / spawn_count)

/obj/structure/hivebot_spawner/proc/finish_production()
	visible_message("span_warning([capitalize(declent_ru(NOMINATIVE)] останавливается.)")
	is_active = FALSE
	spawn_count = initial(spawn_count)
	cooldown_until = world.time + cooldown_duration
	icon_state = "fab_robot"
	next_spawn_time = cooldown_until + spawn_interval

//////////////
//MARK: LOOT
//////////////

/obj/effect/loot_spawner/hivebot
	var/spawned = FALSE

/obj/effect/loot_spawner/hivebot/Initialize()
	. = ..()
	spawn_loot()
	return INITIALIZE_HINT_QDEL

/obj/effect/loot_spawner/hivebot/proc/spawn_loot()
	if(spawned)
		return
	spawned = TRUE

	var/list/common_loot = list(
		/obj/item/broken_device,
		/obj/item/robot_parts/robot_component/actuator,
		/obj/item/robot_parts/robot_component/armour,
		/obj/item/robot_parts/robot_component/binary_communication_device,
		/obj/item/robot_parts/robot_component/camera,
		/obj/item/robot_parts/robot_component/diagnosis_unit,
		/obj/item/robot_parts/robot_component/radio,
	)

	var/list/uncommon_loot = list(
		/obj/item/robot_parts/chest,
		/obj/item/robot_parts/head,
		/obj/item/robot_parts/l_arm,
		/obj/item/robot_parts/l_leg,
		/obj/item/robot_parts/r_arm,
		/obj/item/robot_parts/r_leg,
		/obj/item/stock_parts/cell,
		/obj/item/robot_parts/robot_suit
	)

	var/list/rare_loot = list(
		/obj/item/flash/synthetic,
		/obj/item/mmi/robotic_brain,
		/obj/item/robot_parts/robot_suit
//		/obj/item/ai_module/hivebot
	)

	var/roll = rand(1,100)
	var/path

	switch(roll)
		if(1 to 55) // 55%
			path = pick(common_loot)
		if(56 to 85) // 30%
			path = pick(uncommon_loot)
		if(86 to 100) // 15%
			path = pick(rare_loot)

	if(path)
		new path(get_turf(src))

//MARK: Спавнер

/obj/effect/spawner/hivebot
	name = "hivebot spawner"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"

/obj/effect/spawner/hivebot/Initialize()
	. = ..()
	var/mob_type = pickweight(list(
		/mob/living/simple_animal/hostile/hivebot = 30,
		/mob/living/simple_animal/hostile/hivebot/melee = 15,
		/mob/living/simple_animal/hostile/hivebot/range = 15,
		/mob/living/simple_animal/hostile/hivebot/heavy_melee = 5,
		/mob/living/simple_animal/hostile/hivebot/support = 5
	))
	new mob_type(loc)
	return qdel(src)

/obj/effect/spawner/hivebot_heavy
	name = "hivebot spawner"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"

/obj/effect/spawner/hivebot_heavy/Initialize()
	. = ..()
	var/mob_type = pickweight(list(
		/mob/living/simple_animal/hostile/hivebot = 50,
		/mob/living/simple_animal/hostile/hivebot/melee = 15,
		/mob/living/simple_animal/hostile/hivebot/range = 15,
		/mob/living/simple_animal/hostile/hivebot/support = 20
	))
	new mob_type(loc)
	return qdel(src)
