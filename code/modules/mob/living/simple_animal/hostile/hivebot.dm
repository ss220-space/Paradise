/obj/item/projectile/hivebotbullet
	damage = 10
	damage_type = BRUTE

/obj/item/projectile/hivebotbullet/invasion
	damage = 25
	damage_type = BRUTE

/mob/living/simple_animal/hostile/hivebot
	name = "Hivebot"
	desc = "A small robot"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	health = 15
	maxHealth = 15
	melee_damage_lower = 2
	melee_damage_upper = 3
	attacktext = "рвёт"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	projectilesound = 'sound/weapons/gunshots/gunshot.ogg'
	projectiletype = /obj/item/projectile/hivebotbullet
	faction = list("hivebot")
	check_friendly_fire = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speak_emote = list("states")
	gold_core_spawnable = HOSTILE_SPAWN
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	deathmessage = "blows apart!"
	bubble_icon = "machine"
	del_on_death = 1

/mob/living/simple_animal/hostile/hivebot/range
	name = "Hivebot"
	desc = "A smallish robot, this one is armed!"
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/rapid
	ranged = 1
	rapid = 3
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/strong
	name = "Strong Hivebot"
	desc = "A robot, this one is armed and looks tough!"
	health = 80
	maxHealth = 80
	ranged = 1

/mob/living/simple_animal/hostile/hivebot/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	do_sparks(3, 1, src)

/mob/living/simple_animal/hostile/hivebot/tele//this still needs work
	name = "Beacon"
	desc = "Some odd beacon thing"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "def_radar-off"
	icon_living = "def_radar-off"
	health = 200
	maxHealth = 200
	status_flags = 0
	anchored = 1
	stop_automated_movement = 1
	var/bot_type = "norm"
	var/bot_amt = 10
	var/spawn_delay = 600
	var/turn_on = 0
	var/auto_spawn = 1

/mob/living/simple_animal/hostile/hivebot/tele/New()
	..()
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(5, 0, src.loc)
	smoke.start()
	visible_message("<span class='danger'>The [src] warps in!</span>")
	playsound(src.loc, 'sound/effects/empulse.ogg', 25, 1)

/mob/living/simple_animal/hostile/hivebot/tele/proc/warpbots()
	icon_state = "def_radar"
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

/mob/living/simple_animal/hostile/hivebot/invasion
	name = "Hivebot"
	desc = "A small robot"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	health = 40
	maxHealth = 40
	melee_damage_lower = 15
	melee_damage_upper = 20
	attacktext = "рвёт"
	a_intent = INTENT_HARM
	attack_sound = 'sound/weapons/bladeslice.ogg'
	projectilesound = 'sound/weapons/gunshots/gunshot.ogg'
	projectiletype = /obj/item/projectile/hivebotbullet/invasion
	faction = list("hivebot")
	check_friendly_fire = 1
	speed = 0.86
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speak_emote = list("states")
	gold_core_spawnable = NO_SPAWN
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_MOBS
	damage_coeff = list(BRUTE = 0.90, BURN = 0.90, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	deathmessage = "blows apart!"
	bubble_icon = "machine"
	del_on_death = 1

/mob/living/simple_animal/hostile/hivebot/invasion/New()
	..()

	add_language("Hivebot")
	add_language("Trinary")
	default_language = GLOB.all_languages["Hivebot"]

	name += " ([rand(1, 1000)])"
	real_name = name

/mob/living/simple_animal/hostile/hivebot/invasion/range
	name = "Ranged Hivebot"
	desc = "A smallish robot, this one is armed!"
	ranged = 1
	speed = 0.90
	icon_state = "ranged"
	icon_living = "ranged"
	icon_dead = "ranged"
	health = 30
	maxHealth = 30
	ranged_cooldown_time = 30 //default from hostile
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/invasion/rapid
	name = "Rapid Ranged Hivebot"
	ranged = 1
	rapid = 4
	ranged_cooldown_time = 60
	speed = 0.95
	health = 60
	maxHealth = 60
	melee_damage_lower = 20
	melee_damage_upper = 30
	icon_state = "rapid"
	icon_living = "rapid"
	icon_dead = "rapid"
	desc = "A smallish robot, this one is armed with four guns!"
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/invasion/engi
	name = "Hivebot Engineer"
	desc = "A robot. This one is yellow and armed with engineering tools!"
	health = 86
	maxHealth = 86
	speed = 1.05
	icon_state = "EngBotEvil"
	icon_living = "EngBotEvil"
	icon_dead = "EngBotEvil"
	obj_damage = 200
	melee_damage_lower = 15
	melee_damage_upper = 25

/mob/living/simple_animal/hostile/hivebot/invasion/engi/Process_Spacemove(var/movement_dir = 0)
	var/turf/T = get_turf(src)

	if(!has_gravity(T))
		new /obj/effect/particle_effect/ion_trails(T)

	return 1	//jetpack-a-like movement

/mob/living/simple_animal/hostile/hivebot/invasion/engi/verb/lattice()
	set category = "Hivebot"
	set name = "Lattice Construction"
	set desc = "It will construct lattice on your position."

	if(get_turf(src) == /turf/space/)
		new /obj/structure/lattice/catwalk(src.loc)
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

/mob/living/simple_animal/hostile/hivebot/invasion/engi/verb/floor()
	set category = "Hivebot"
	set name = "Floor Construction"
	set desc = "It will construct floor on your position."

	if(!get_turf(src) == /turf/space/)
		if(do_after(src, 5, target = src, progress=TRUE))
			new /turf/simulated/floor(src.loc)
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

/mob/living/simple_animal/hostile/hivebot/invasion/engi/verb/wall()
	set category = "Hivebot"
	set name = "Wall Construction"
	set desc = "It will construct wall on your position."

	if(get_turf(src) == /turf/simulated/floor)
		if(do_after(src, 15, target = src, progress=TRUE))
			var/turf/turf_to_change = get_turf(src)
			turf_to_change.ChangeTurf(/turf/simulated/wall)
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

/mob/living/simple_animal/hostile/hivebot/invasion/strong
	name = "Strong Hivebot"
	desc = "A robot, this one is armed and looks tough!"
	health = 200
	maxHealth = 200
	speed = 1.15
	icon_state = "strong"
	icon_living = "strong"
	icon_dead = "strong"
	obj_damage = 60
	melee_damage_lower = 25
	melee_damage_upper = 35
	ranged = 1

/mob/living/simple_animal/hostile/hivebot/invasion/tele
	name = "Hivebot Beacon"
	desc = "Some odd beacon thing"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "def_radar"
	icon_living = "def_radar"
	health = 400
	obj_damage = 80
	maxHealth = 400
	melee_damage_lower = 36
	melee_damage_upper = 48
	speed = 1.45
	status_flags = 0

	var/max_mobs = 100
	var/spawn_time = 150 //15 seconds
	var/mob_types = list(/mob/living/simple_animal/hostile/hivebot/invasion, /mob/living/simple_animal/hostile/hivebot/invasion/range, /mob/living/simple_animal/hostile/hivebot/invasion/rapid, /mob/living/simple_animal/hostile/hivebot/invasion/strong, /mob/living/simple_animal/hostile/hivebot/invasion/engi)
	var/spawn_text = "constructing from"
	var/spawner_type = /datum/component/spawner

/mob/living/simple_animal/hostile/hivebot/invasion/tele/Initialize(mapload)
	. = ..()
	AddComponent(spawner_type, mob_types, spawn_time, faction, spawn_text, max_mobs)

/mob/living/simple_animal/hostile/hivebot/invasion/tele/New()
	..()
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(5, 0, src.loc)
	smoke.start()
	visible_message("<span class='danger'>The [src] warps in!</span>")
	playsound(src.loc, 'sound/effects/empulse.ogg', 25, 1)

/mob/living/simple_animal/hostile/hivebot/invasion/tele/death()
	..()
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(5, 0, src.loc)
	smoke.start()
	playsound(src.loc, 'sound/effects/empulse.ogg', 25, 1)

	var/thenumber = rand(2,6)

	while(thenumber > 0)
		thenumber--
		var/hivebot = pick(/mob/living/simple_animal/hostile/hivebot/invasion, /mob/living/simple_animal/hostile/hivebot/invasion/range, /mob/living/simple_animal/hostile/hivebot/invasion/rapid, /mob/living/simple_animal/hostile/hivebot/strong, /mob/living/simple_animal/hostile/hivebot/invasion/engi)
		new hivebot(src.loc)

/mob/living/simple_animal/hostile/hivebot/invasion/attack_ghost(mob/user)
	humanize_hivebot(user)

/mob/living/simple_animal/hostile/hivebot/invasion/proc/humanize_hivebot(mob/user)
	if(key)//Someone is in it
		return
	if(stat == DEAD)
		return
	else if(!(user in GLOB.respawnable_list))
		return
	if(jobban_isbanned(user, "Syndicate"))
		to_chat(user,"You are jobbanned from role of syndicate and/or alien lifeform.")
		return

	var/hivebot_ask = alert("Join as Hivebot?",,"Yes", "No")
	if(hivebot_ask == "No" || !src || QDELETED(src))
		return

	if(key)
		to_chat(user, "<span class='notice'>Someone else already took this hivebot.</span>")
		return
	key = user.key
	to_chat(src, "<span class='boldnotice'>Your directives is reproduce and destroy everything living and synthetic that not from your hive.</span>")

/mob/living/simple_animal/hostile/hivebot/invasion/verb/repair()
	set category = "Hivebot"
	set name = "Repair"
	set desc = "Repair ourself."

	if(do_after(src, 100, target = src, progress=TRUE))
		src.adjustBruteLoss(-10)
		src.adjustFireLoss(-10)
