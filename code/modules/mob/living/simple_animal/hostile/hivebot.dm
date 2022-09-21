/obj/item/projectile/hivebotbullet
	damage = 10
	damage_type = BRUTE

/obj/item/projectile/hivebotbullet/invasion
	damage = 20
	stamina = 6.25
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
	pressure_resistance = 2000
	projectilesound = 'sound/weapons/gunshots/gunshot.ogg'
	projectiletype = /obj/item/projectile/hivebotbullet/invasion
	faction = list("hivebot")
	check_friendly_fire = 1
	speed = 0.86
	environment_smash = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speak_emote = list("states")
	gold_core_spawnable = NO_SPAWN
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_MOBS | SEE_SELF | SEE_TURFS | SEE_OBJS
	damage_coeff = list(BRUTE = 0.80, BURN = 0.80, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	deathmessage = "blows apart!"
	bubble_icon = "machine"
	del_on_death = 1

/mob/living/simple_animal/hostile/hivebot/invasion/Login()
	..()
	to_chat(src, "<b>Вы Хайвбот, великое порождение Хозяев. Это самовоспроизводящиеся роботы с целью уничтожения всего что, попадается им на пути, кроме их самих.</b>")
	to_chat(src, "<b>После оккупирования станции Тета, Ульи разделились на Улучшенное и Старое. Старые остались на Тете, в то время как Улучшенное нашло новую жертву... Да, [station_name()]?.</b>")
	to_chat(src, "<b>Защищайте маяки до последнего, это единственный способ восстановления войск против вражеских объектов.</b>")
	to_chat(src, "<b>Хозяева внедрили в нас неплохую броню и систему самопочинки.</b>")
	to_chat(src, "<b>Договоры с Синтетиками и иными объектами, что знают Тринарный, допустимы.</b>")
	to_chat(src, "<b>Заложенные Директивы:</b>")
	to_chat(src, "1. Самовоспроизводись.")
	to_chat(src, "2. Уничтожай.")
	to_chat(src, "3. Захватывай.")
	to_chat(src, "3. Улучшайся.")

/mob/living/simple_animal/hostile/hivebot/invasion/New()
	..()

	add_language("Hivebot")
	add_language("Trinary")
	default_language = GLOB.all_languages["Hivebot"]

	var/list/availableturfs = list()
	for(var/turf/simulated/floor/T in world)
		if(is_station_level(T.z))
			availableturfs += T

	src.Goto(pick(availableturfs), src.move_to_delay)

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
	ranged_cooldown_time = 20
	retreat_distance = 4
	minimum_distance = 4

/mob/living/simple_animal/hostile/hivebot/invasion/ventcrawler
	name = "Ventcrawling Hivebot"
	desc = "A smallish robot, this one is suspicous!"
	speed = 0.78
	melee_damage_lower = 10
	melee_damage_upper = 15
	icon_state = "ventcrawler"
	icon_living = "ventcrawler"
	icon_dead = "ventcrawler"
	health = 26
	maxHealth = 26
	ventcrawler = 2

/mob/living/simple_animal/hostile/hivebot/invasion/rapid
	name = "Rapid Ranged Hivebot"
	ranged = 1
	rapid = 4
	ranged_cooldown_time = 40
	speed = 0.95
	health = 60
	maxHealth = 60
	melee_damage_lower = 20
	melee_damage_upper = 30
	icon_state = "rapid"
	icon_living = "rapid"
	icon_dead = "rapid"
	desc = "A smallish robot, this one is armed with four guns!"
	retreat_distance = 4
	minimum_distance = 4


/mob/living/simple_animal/hostile/hivebot/invasion/laser
	name = "Laser Hivebot"
	ranged = 1
	rapid = 2
	ranged_cooldown_time = 20
	speed = 0.94
	health = 60
	maxHealth = 60
	melee_damage_lower = 20
	melee_damage_upper = 30
	projectiletype = /obj/item/projectile/beam
	icon_state = "laser"
	icon_living = "laser"
	icon_dead = "laser"
	desc = "A smallish robot, this one is armed with laser gun!"
	retreat_distance = 4
	minimum_distance = 4

/mob/living/simple_animal/hostile/hivebot/invasion/engi
	name = "Hivebot Engineer"
	desc = "A robot. This one is yellow and armed with engineering tools!"
	health = 66
	maxHealth = 66
	speed = 1.04
	icon_state = "EngBotEvil"
	icon_living = "EngBotEvil"
	icon_dead = "EngBotEvil"
	obj_damage = 100
	environment_smash = 3
	var/matter = 10
	melee_damage_lower = 10
	melee_damage_upper = 15

/mob/living/simple_animal/hostile/hivebot/invasion/engi/Stat()
	..()
	statpanel("Status")

	show_stat_emergency_shuttle_eta()

	if(client.statpanel == "Status")
		stat("Hivebot RCD Matter", matter)

mob/living/simple_animal/hostile/hivebot/invasion/engi/AttackingTarget()
	matter += rand(0,12)
	var/acted = FALSE

	if(!isliving(target))
		if(istype(target, /turf/simulated/wall/) && matter >= 16)
			if(do_after(src, 60, target = target, progress=TRUE))
				matter -= 16
				var/turf/turf_to_change = get_turf(target)
				turf_to_change.ChangeTurf(/turf/simulated/floor)
				acted = TRUE
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

		if(istype(target, /obj/structure/window/) || istype(target, /obj/structure/grille/) && matter >= 6)
			if(do_after(src, 10, target = target, progress=TRUE))
				matter -= 6
				var/turf/turf_to_change = get_turf(target)
				for(var/obj/structure/delete in turf_to_change)
					if(istype(target, /obj/structure/window/) || istype(target, /obj/structure/grille/))
						qdel(delete)
				acted = TRUE
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

		if(istype(target, /obj/machinery/door) && matter >= 36)
			var/obj/machinery/door/targ = target
			if(!targ.welded)
				if(do_after(src, 40, target = targ, progress=TRUE))
					matter -= 36
					qdel(target)
					acted = TRUE
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

		if(istype(target, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/targe = target
			playsound(src.loc, 'sound/items/welderactivate.ogg', 25, 1)
			sleep(5)
			if(prob(50))
				playsound(src.loc, 'sound/items/welder2.ogg', 25, 1)
			else
				playsound(src.loc, 'sound/items/welder.ogg', 25, 1)
			if(do_after(src, 26, target = targe, progress=TRUE))
				targe.welded = FALSE
				acted = TRUE
				targe.update_icon()
				sleep(5)
				playsound(src.loc, 'sound/items/welderdeactivate.ogg', 25, 1)

		if(istype(target, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/targe = target
			playsound(src.loc, 'sound/items/welderactivate.ogg', 25, 1)
			sleep(5)
			if(prob(50))
				playsound(src.loc, 'sound/items/welder2.ogg', 25, 1)
			else
				playsound(src.loc, 'sound/items/welder.ogg', 25, 1)
			if(do_after(src, 26, target = targe, progress=TRUE))
				targe.welded = FALSE
				acted = TRUE
				targe.update_icon()
				sleep(5)
				playsound(src.loc, 'sound/items/welderdeactivate.ogg', 25, 1)

		if(istype(target, /obj/structure/girder/))
			playsound(src.loc, 'sound/items/ratchet.ogg', 50, 1)
			if(do_after(src, 20, target = target, progress=TRUE))
				var/obj/item/stack/sheet/metal/met = new /obj/item/stack/sheet/metal(get_turf(target))
				acted = TRUE
				met.amount = 2
				qdel(target)

		if(istype(target, /obj/structure/grille/))
			playsound(src.loc, 'sound/items/wirecutter.ogg', 50, 1)
			var/obj/item/stack/rods/rod = new /obj/item/stack/rods(get_turf(target))
			rod.amount = 2
			acted = TRUE
			qdel(target)

		if(istype(target, /obj/structure/barricade/wooden/) || istype(target, /obj/structure/bookcase/))
			playsound(src.loc, 'sound/items/ratchet.ogg', 50, 1)
			if(do_after(src, 10, target = target, progress=TRUE))
				var/obj/item/stack/sheet/wood/wd = new /obj/item/stack/sheet/wood(get_turf(target))
				acted = TRUE
				wd.amount = 5
				qdel(target)

		if(istype(target, /obj/structure/closet))
			playsound(src.loc, 'sound/items/welderactivate.ogg', 25, 1)
			sleep(5)
			if(prob(50))
				playsound(src.loc, 'sound/items/welder2.ogg', 25, 1)
			else
				playsound(src.loc, 'sound/items/welder.ogg', 25, 1)
			if(do_after(src, 26, target = target, progress=TRUE))
				var/obj/item/stack/sheet/metal/met = new /obj/item/stack/sheet/metal(get_turf(target))
				acted = TRUE
				met.amount = 2
				qdel(target)
				sleep(5)
				playsound(src.loc, 'sound/items/welderdeactivate.ogg', 25, 1)

		if(istype(target, /obj/structure/cable))
			var/obj/structure/cable/targe = target
			acted = TRUE
			targe.deconstruct()
			playsound(src.loc, 'sound/items/wirecutter.ogg', 25, 1)

		if(!acted)
			return ..()

	else
		return ..()

/mob/living/simple_animal/hostile/hivebot/invasion/engi/Process_Spacemove(var/movement_dir = 0)
	var/turf/T = get_turf(src)

	if(!has_gravity(T))
		new /obj/effect/particle_effect/ion_trails(T)

	return 1	//jetpack-a-like movement

/mob/living/simple_animal/hostile/hivebot/invasion/engi/verb/weld_door()
	set category = "Hivebot"
	set name = "Weld/Unweld door"
	set desc = "Welding or unwelding selected door."

	var/list/choices = list()

	for(var/obj/machinery/door/tdoor in view(1,src))
		if(istype(tdoor, /obj/machinery/door/))
			choices += tdoor

	var/obj/machinery/door/tdoor = input(src,"Which door you want to weld or unweld.") in null|choices

	if(!tdoor || !src)
		return

	if(tdoor in view(1, src))
		playsound(src.loc, 'sound/items/welderactivate.ogg', 25, 1)
		sleep(5)
		playsound(src.loc, 'sound/items/welder2.ogg', 25, 1)
		if(do_after(src, 26, target = src, progress=TRUE))
			if(tdoor.welded)
				tdoor.welded = FALSE
			else
				tdoor.welded = TRUE
			tdoor.update_icon()
			sleep(5)
			playsound(src.loc, 'sound/items/welderdeactivate.ogg', 25, 1)
	else
		to_chat(src, "[src] its not longer in range!")
		return

/mob/living/simple_animal/hostile/hivebot/invasion/engi/verb/weld_closet()
	set category = "Hivebot"
	set name = "Weld/Unweld closet"
	set desc = "Welding or unwelding selected closet."

	var/list/choices = list()

	for(var/obj/structure/closet/clst in view(1,src))
		if(istype(clst, /obj/structure/closet/))
			choices += clst

	var/obj/structure/closet/clst = input(src,"Which door you want to weld or unweld.") in null|choices

	if(!clst || !src)
		return

	if(clst in view(1, src))
		playsound(src.loc, 'sound/items/welderactivate.ogg', 25, 1)
		sleep(5)
		playsound(src.loc, 'sound/items/welder2.ogg', 25, 1)
		if(do_after(src, 26, target = src, progress=TRUE))
			if(clst.welded)
				clst.welded = FALSE
			else
				clst.welded = TRUE
			clst.update_icon()
			sleep(5)
			playsound(src.loc, 'sound/items/welderdeactivate.ogg', 25, 1)
	else
		to_chat(src, "[src] its not longer in range!")
		return

/mob/living/simple_animal/hostile/hivebot/invasion/engi/verb/lattice()
	set category = "Hivebot"
	set name = "Lattice Construction"
	set desc = "It will construct lattice on your position."

	if(istype(get_turf(src), /turf/space)  && matter >= 2)
		new /obj/structure/lattice/catwalk(src.loc)
		matter -= 2
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

/mob/living/simple_animal/hostile/hivebot/invasion/engi/verb/floor()
	set category = "Hivebot"
	set name = "Floor Construction"
	set desc = "It will construct floor on your position."

	if(!istype(get_turf(src), /turf/simulated/floor)  && matter >= 6)
		if(do_after(src, 5, target = src, progress=TRUE))
			var/turf/turf_to_change = get_turf(src)
			turf_to_change.ChangeTurf(/turf/simulated/floor)
			matter -= 6
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

/mob/living/simple_animal/hostile/hivebot/invasion/engi/verb/grille()
	set category = "Hivebot"
	set name = "Grille Construction"
	set desc = "It will construct grille on your position."

	if(!istype(get_turf(src), /turf/simulated/floor)  && matter >= 2)
		if(do_after(src, 5, target = src, progress=TRUE))
			new /obj/structure/grille(src.loc)
			matter -= 2
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

/mob/living/simple_animal/hostile/hivebot/invasion/engi/verb/wall()
	set category = "Hivebot"
	set name = "Wall Construction"
	set desc = "It will construct wall on your position."

	if(istype(get_turf(src), /turf/simulated/floor)  && matter >= 16)
		if(do_after(src, 28, target = src, progress=TRUE))
			var/turf/turf_to_change = get_turf(src)
			matter -= 16
			turf_to_change.ChangeTurf(/turf/simulated/wall)
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

/mob/living/simple_animal/hostile/hivebot/invasion/engi/verb/rwall()
	set category = "Hivebot"
	set name = "Reinforced Wall Construction"
	set desc = "It will construct reinforced wall on your position."

	if(istype(get_turf(src), /turf/simulated/floor)  && matter >= 40)
		if(do_after(src, 160, target = src, progress=TRUE))
			var/turf/turf_to_change = get_turf(src)
			turf_to_change.ChangeTurf(/turf/simulated/wall/r_wall)
			matter -= 40
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

/mob/living/simple_animal/hostile/hivebot/invasion/engi/verb/window()
	set category = "Hivebot"
	set name = "Window Construction"
	set desc = "It will construct window on your position."

	if(istype(get_turf(src), /turf/simulated/floor)  && matter >= 8)
		if(do_after(src, 16, target = src, progress=TRUE))
			sleep(20)
			new /obj/effect/spawner/window/reinforced(src.loc)
			matter -= 8
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

/mob/living/simple_animal/hostile/hivebot/invasion/engi/verb/airlock()
	set category = "Hivebot"
	set name = "Airlock Construction"
	set desc = "It will construct airlock on your position."

	if(istype(get_turf(src), /turf/simulated/floor)  && matter >= 14)
		if(do_after(src, 46, target = src, progress=TRUE))
			new /obj/machinery/door/airlock/hivebot(src.loc)
			matter -= 14
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

/obj/machinery/door/airlock/hivebot
	name = "hivebot airlock"
	hackProof = TRUE
	aiControlDisabled = AICONTROLDISABLED_ON

/obj/machinery/door/airlock/hivebot/allowed(mob/living/L)
	if(!density)
		return TRUE
	if(istype(L, /mob/living/simple_animal/hostile/hivebot/invasion/))
		return TRUE
	return FALSE

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

	var/max_mobs = 20
	var/spawn_time = 200 //20 seconds
	var/mob_types = list(/mob/living/simple_animal/hostile/hivebot/invasion, /mob/living/simple_animal/hostile/hivebot/invasion/range, /mob/living/simple_animal/hostile/hivebot/invasion/rapid, /mob/living/simple_animal/hostile/hivebot/invasion/strong, /mob/living/simple_animal/hostile/hivebot/invasion/engi, /mob/living/simple_animal/hostile/hivebot/invasion/laser, /mob/living/simple_animal/hostile/hivebot/invasion/ventcrawler)
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

/mob/living/simple_animal/hostile/hivebot/invasion/tele/death(gibbed)
	..()
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(5, 0, src.loc)
	smoke.start()
	playsound(src.loc, 'sound/effects/empulse.ogg', 25, 1)

	var/thenumber = rand(2,8)

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
	if(jobban_isbanned(user, "Syndicate") || jobban_isbanned(user, "Hivebot"))
		to_chat(user,"You are jobbanned from role of syndicate and/or alien lifeform.")
		return

	var/hivebot_ask = alert("Join as Hivebot?",,"Yes", "No")
	if(hivebot_ask == "No" || !src || QDELETED(src))
		return

	if(key)
		to_chat(user, "<span class='notice'>Someone else already took this hivebot.</span>")
		return
	key = user.key

/mob/living/simple_animal/hostile/hivebot/invasion/verb/repair()
	set category = "Hivebot"
	set name = "Repair"
	set desc = "Repair ourself."

	if(do_after(src, 124, target = src, progress=TRUE))
		src.adjustBruteLoss(-1000)
		src.adjustFireLoss(-1000)
