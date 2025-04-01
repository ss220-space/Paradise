/obj/projectile/hivebotbullet
	damage = 10
	damage_type = BRUTE

/mob/living/simple_animal/hostile/hivebot
	name = "Basic Hivebot"
	desc = "A medium sized robot made from cheap parts. It has a homemade weapon welded to it."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basicDead"
	health = 15
	maxHealth = 15
	melee_damage_lower = 5
	melee_damage_upper = 8
	attacktext = "рвёт"
	attack_sound = 'sound/weapons/throwhard.ogg'
	projectilesound = 'sound/weapons/gunshots/1sp_91.ogg'
	projectiletype = /obj/projectile/hivebotbullet
	faction = list("hivebot")
	check_friendly_fire = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speak_emote = list("states")
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	butcher_results = list(/obj/item/robot_parts/r_arm, /obj/item/robot_parts/head)
	deathmessage = "blows apart!"
	bubble_icon = "machine"
	footstep_type = FOOTSTEP_MOB_CLAW
	AI_delay_max = 0.5 SECONDS

/mob/living/simple_animal/hostile/hivebot/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/hivebot/range
	name = "Hivebot Sniper"
	desc = "The robot is on a four-legged base, with a rifle welded to it."
	butcher_results = list(/obj/item/robot_parts/l_arm, /obj/item/robot_parts/robot_suit)
	health = 30
	maxHealth = 30
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/rapid
	name = "Hivebot Gunner"
	desc = "The robot is on a four-legged base, with an automatic pistol welded to it."
	butcher_results = list(/obj/item/robot_parts/l_leg, /obj/item/robot_parts/robot_suit)
	health = 15
	maxHealth = 15
	ranged = 1
	rapid = 5
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/strong
	name = "Strong Hivebot"
	desc = "The robot is on a four-legged base, this one is armed and looks tough!"
	butcher_results = list(/obj/item/robot_parts/robot_component/armour, /obj/item/robot_parts/robot_suit)
	health = 80
	maxHealth = 80
	ranged = 1
	rapid = 1
	melee_damage_lower = 10
	melee_damage_upper = 15

/mob/living/simple_animal/hostile/hivebot/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	do_sparks(3, 1, src)

/mob/living/simple_animal/hostile/hivebot/tele//this still needs work
	name = "Production robot"
	desc = "Looks like this robot has its own mini factory inside."
	butcher_results = list(/obj/item/rcd, /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster)
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "Ball"
	icon_living = "Ball"
	icon_dead = "BallDead"
	health = 200
	maxHealth = 200
	status_flags = 0
	anchored = TRUE
	stop_automated_movement = 1
	var/bot_type = "norm"
	var/bot_amt = 10
	var/spawn_delay = 600
	var/turn_on = 0
	var/auto_spawn = 1

/mob/living/simple_animal/hostile/hivebot/tele/Initialize(mapload)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = 5, location = src.loc)
	smoke.start()
	visible_message("<span class='danger'>The [src] warps in!</span>")
	playsound(src.loc, 'sound/effects/empulse.ogg', 25, 1)

/mob/living/simple_animal/hostile/hivebot/tele/proc/warpbots()
	icon_state = "Ball"
	visible_message("<span class='warning'>The [src] turns on!</span>")
	while(bot_amt > 0)
		bot_amt--
		switch(bot_type)
			if("norm")
				var/mob/living/simple_animal/hostile/hivebot/H = new /mob/living/simple_animal/hostile/hivebot(get_turf(src))
				H.faction = faction
			if("range")
				var/mob/living/simple_animal/hostile/hivebot/range/R = new /mob/living/simple_animal/hostile/hivebot/range(get_turf(src))
				R.faction = faction
			if("rapid")
				var/mob/living/simple_animal/hostile/hivebot/rapid/F = new /mob/living/simple_animal/hostile/hivebot/rapid(get_turf(src))
				F.faction = faction
	spawn(100)
		qdel(src)
	return

/mob/living/simple_animal/hostile/hivebot/tele/handle_automated_action()
	if(!..())
		return
	if(prob(2))//Might be a bit low, will mess with it likely
		warpbots()
