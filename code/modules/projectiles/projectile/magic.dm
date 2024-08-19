/obj/item/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	damage = 0
	hitsound = 'sound/weapons/magic.ogg'
	hitsound_wall = 'sound/weapons/magic.ogg'
	damage_type = OXY
	nodamage = TRUE
	armour_penetration = 100
	flag = "magic"

/obj/item/projectile/magic/death
	name = "bolt of death"
	icon_state = "pulse1_bl"

/obj/item/projectile/magic/fireball
	name = "bolt of fireball"
	icon_state = "fireball"
	damage = 10
	damage_type = BRUTE
	nodamage = FALSE

	//explosion values
	var/exp_devastate = -1
	var/exp_heavy = 0
	var/exp_light = 2
	var/exp_flash = 3
	var/exp_fire = 2

/obj/item/projectile/magic/death/on_hit(mob/living/carbon/C)
	. = ..()
	if(isliving(C))
		if(ismachineperson(C)) //speshul snowfleks deserv speshul treetment
			C.adjustFireLoss(6969)  //remember - slimes love fire
		else
			C.death()

		visible_message("<span class='danger'>[C] topples backwards as the death bolt impacts [C.p_them()]!</span>")

/obj/item/projectile/magic/fireball/Range()
	var/turf/T1 = get_step(src,turn(dir, -45))
	var/turf/T2 = get_step(src,turn(dir, 45))
	var/turf/T3 = get_step(src,dir)
	var/mob/living/L = locate(/mob/living) in T1 //if there's a mob alive in our front right diagonal, we hit it.
	if(L && L.stat != DEAD)
		Bump(L) //Magic Bullet #teachthecontroversy
		return
	L = locate(/mob/living) in T2
	if(L && L.stat != DEAD)
		Bump(L)
		return
	L = locate(/mob/living) in T3
	if(L && L.stat != DEAD)
		Bump(L)
		return
	..()

/obj/item/projectile/magic/fireball/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	var/turf/T = get_turf(target)
	explosion(T, exp_devastate, exp_heavy, exp_light, exp_flash, 0, flame_range = exp_fire, cause = src)
	if(ismob(target)) //multiple flavors of pain
		var/mob/living/M = target
		M.take_overall_damage(0,10) //between this 10 burn, the 10 brute, the explosion brute, and the onfire burn, your at about 65 damage if you stop drop and roll immediately


/obj/item/projectile/magic/fireball/infernal
	name = "infernal fireball"
	exp_heavy = -1
	exp_light = -1
	exp_flash = 4
	exp_fire= 5

/obj/item/projectile/magic/resurrection
	name = "bolt of resurrection"
	icon_state = "ion"

/obj/item/projectile/magic/resurrection/on_hit(var/mob/living/carbon/target)
	. = ..()
	if(ismob(target))
		var/old_stat = target.stat
		target.suiciding = 0
		target.revive()
		if(!target.ckey)
			for(var/mob/dead/observer/ghost in GLOB.player_list)
				if(target.real_name == ghost.real_name)
					ghost.reenter_corpse()
					break
		if(old_stat != DEAD)
			to_chat(target, "<span class='notice'>You feel great!</span>")
		else
			to_chat(target, "<span class='notice'>You rise with a start, you're alive!!!</span>")

/obj/item/projectile/magic/teleport
	name = "bolt of teleportation"
	icon_state = "bluespace"
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

/obj/item/projectile/magic/teleport/on_hit(var/mob/target)
	. = ..()
	var/teleammount = 0
	var/teleloc = target
	if(!isturf(target))
		teleloc = target.loc
	for(var/atom/movable/stuff in teleloc)
		if(!stuff.anchored && stuff.loc)
			teleammount++
			do_teleport(stuff, stuff, 10)
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(max(round(10 - teleammount),1), 0, stuff.loc) //Smoke drops off if a lot of stuff is moved for the sake of sanity
			smoke.start()

/obj/item/projectile/magic/door
	name = "bolt of door creation"
	icon_state = "energy"
	var/list/door_types = list(/obj/structure/mineral_door/wood,/obj/structure/mineral_door/iron,/obj/structure/mineral_door/silver,\
		/obj/structure/mineral_door/gold,/obj/structure/mineral_door/uranium,/obj/structure/mineral_door/sandstone,/obj/structure/mineral_door/transparent/plasma,\
		/obj/structure/mineral_door/transparent/diamond)

/obj/item/projectile/magic/door/on_hit(var/atom/target)
	. = ..()
	var/atom/T = target.loc
	if(isturf(target) && target.density)
		CreateDoor(target)
	else if(isturf(T) && T.density)
		CreateDoor(T)
	else if(istype(target, /obj/machinery/door))
		OpenDoor(target)
	else if(istype(target, /obj/structure/closet))
		OpenCloset(target)

/obj/item/projectile/magic/door/proc/CreateDoor(turf/T)
	var/door_type = pick(door_types)
	var/obj/structure/mineral_door/D = new door_type(T)
	T.ChangeTurf(/turf/simulated/floor/plasteel)
	D.Open()

/obj/item/projectile/magic/door/proc/OpenDoor(var/obj/machinery/door/D)
	if(istype(D,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		A.locked = FALSE
	D.open()

/obj/item/projectile/magic/door/proc/OpenCloset(var/obj/structure/closet/C)
	if(C?.locked)
		C.locked = FALSE
	C.open()

/obj/item/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage_type = BURN

/obj/item/projectile/magic/change/on_hit(var/atom/change)
	. = ..()
	wabbajack(change)

/proc/wabbajack(mob/living/M)
	if(istype(M) && M.stat != DEAD && !HAS_TRAIT(M, TRAIT_NO_TRANSFORM))
		ADD_TRAIT(M, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
		M.icon = null
		M.cut_overlays()
		M.invisibility = INVISIBILITY_ABSTRACT

		if(isrobot(M))
			var/mob/living/silicon/robot/Robot = M
			QDEL_NULL(Robot.mmi)
			Robot.notify_ai(ROBOT_NOTIFY_AI_CONNECTED)
		else
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				// Make sure there are no organs or limbs to drop
				for(var/t in H.bodyparts)
					qdel(t)
				for(var/i in H.internal_organs)
					qdel(i)
			for(var/obj/item/W in M)
				M.temporarily_remove_item_from_inventory(W, force = TRUE)
				qdel(W)

		var/mob/living/new_mob
		var/briefing_msg
		var/is_new_mind = FALSE

		var/randomize = pick("РОБОТ", "ТЕРРОР", "КСЕНОМОРФ", "ЧЕЛОВЕК", "ЖИВОТНОЕ")
		switch(randomize)
			if("РОБОТ")
				is_new_mind = TRUE
				var/path
				if(prob(50))
					path = pick(typesof(/mob/living/silicon/robot/syndicate))
					new_mob = new path(M.loc)
					briefing_msg = ""
				else
					new_mob = new /mob/living/silicon/robot/ert/gamma(M.loc)
					briefing_msg = ""
				new_mob.gender = M.gender
				new_mob.invisibility = 0
				new_mob.job = JOB_TITLE_CYBORG
				var/mob/living/silicon/robot/Robot = new_mob
				if(ishuman(M))
					Robot.mmi = new /obj/item/mmi(new_mob)
					Robot.mmi.transfer_identity(M)	//Does not transfer key/client.
				else
					Robot.mmi = new /obj/item/mmi/robotic_brain(new_mob)
					Robot.mmi.brainmob.timeofhostdeath = M.timeofdeath
					Robot.mmi.brainmob.set_stat(CONSCIOUS)
					Robot.mmi.update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
				Robot.lawupdate = FALSE
				Robot.disconnect_from_ai()
				Robot.clear_inherent_laws()
				Robot.clear_zeroth_law()
			if("ТЕРРОР")
				is_new_mind = TRUE
				var/terror = pick(prob(20); "lurker", prob(20); "knight", prob(20); "drone", prob(15); "widow", prob(15); "reaper", prob(10); "destroyer")
				switch(terror)
					if("lurker")
						new_mob = new /mob/living/simple_animal/hostile/poison/terror_spider/lurker(M.loc)
					if("knight")
						new_mob = new /mob/living/simple_animal/hostile/poison/terror_spider/knight(M.loc)
					if("drone")
						new_mob = new /mob/living/simple_animal/hostile/poison/terror_spider/builder(M.loc)
					if("widow")
						new_mob = new /mob/living/simple_animal/hostile/poison/terror_spider/widow(M.loc)
					if("reaper")
						new_mob = new /mob/living/simple_animal/hostile/poison/terror_spider/reaper(M.loc)
					if("destroyer")
						new_mob = new /mob/living/simple_animal/hostile/poison/terror_spider/destroyer(M.loc)
				new_mob.universal_speak = TRUE
			if("КСЕНОМОРФ")
				is_new_mind = TRUE
				if(prob(50))
					new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
				else
					new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)
				new_mob.universal_speak = TRUE

				briefing_msg = "Вам разрешается убивать нексеноморфов среди вас. Прежде всего вам лучше обнаружить других себеподобных и подготовить место для улья.."
			if("ЖИВОТНОЕ")
				is_new_mind = TRUE
				var/beast = pick("carp", "bear", "statue", "giantspider", "syndiemouse")
				switch(beast)
					if("carp")
						new_mob = new /mob/living/simple_animal/hostile/carp(M.loc)
					if("bear")
						new_mob = new /mob/living/simple_animal/hostile/bear(M.loc)
					if("statue")
						new_mob = new /mob/living/simple_animal/hostile/statue(M.loc)
					if("giantspider")
						var/spiderType = pick("hunterspider","nursespider","basicspider")
						switch(spiderType)
							if("hunterspider")
								new_mob = new /mob/living/simple_animal/hostile/poison/giant_spider/hunter(M.loc)
							if("nursespider")
								new_mob = new /mob/living/simple_animal/hostile/poison/giant_spider/nurse(M.loc)
							if("basicspider")
								new_mob = new /mob/living/simple_animal/hostile/poison/giant_spider(M.loc)
					if("syndiemouse")
						new_mob = new /mob/living/simple_animal/hostile/retaliate/syndirat(M.loc)
				briefing_msg = "Вы агрессивное животное, питаемое жаждой голода, вы можете совершать убийства, \
				сбиваться в стаи или следовать своему пути одиночки, но цель всегда будет одна - утолить свой голод."
				new_mob.universal_speak = TRUE
			if("ЧЕЛОВЕК")
				if(prob(50))
					new_mob = new /mob/living/carbon/human(M.loc)
					var/mob/living/carbon/human/H = new_mob
					var/datum/preferences/A = new()	//Randomize appearance for the human
					A.species = get_random_species(TRUE)
					A.copy_to(new_mob)
					randomize = H.dna.species.name
					if(ishuman(M))
						briefing_msg = "Вы тот же самый гуманоид, с тем же сознанием и той же памятью, \
						но ваша кожа теперь какая-то другая, да и вы сами теперь какой-то другой."
					else
						is_new_mind = TRUE
						briefing_msg = "Вы превратились в разумного гуманоида, знакомым с устройством мира и НТ."
				else
					new_mob = new /mob/living/carbon/human/lesser/monkey(M.loc)
					if(ishuman(M))
						briefing_msg = "Вы разумная мартышка, вам хоть и хочется бананов, \
						но у вас по прежнему память о своей прошлой жизни..."
					else
						is_new_mind = TRUE
						briefing_msg = "Вы разумная мартышка, и вам хочется бананов."

			else
				return

		add_attack_logs(null, M, "became [new_mob.real_name]", ATKLOG_ALL)

		new_mob.a_intent = INTENT_HARM
		if(M.mind)
			M.mind.transfer_to(new_mob)
			if(is_new_mind)
				new_mob.mind.wipe_memory()
				if(briefing_msg)
					new_mob.mind.store_memory(briefing_msg)
		else
			new_mob.key = M.key

		if(is_new_mind)
			to_chat(new_mob, span_danger("Вы потеряли свою личность и память! Отыгрывайте новое существо!"))
		to_chat(new_mob, span_danger("ТЕПЕРЬ ВЫ [uppertext(randomize)]"))
		if(briefing_msg)
			to_chat(new_mob, span_notice("[briefing_msg]"))

		qdel(M)
		return new_mob

/obj/item/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	damage_type = BURN


/obj/item/projectile/magic/animate/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()

	if(isitem(target) || (isstructure(target) && !is_type_in_list(target, GLOB.protected_objects)))
		if(istype(target, /obj/structure/closet/statue))
			for(var/mob/living/carbon/human/prisoner in target)
				var/mob/living/simple_animal/hostile/statue/statue = new(target.loc, firer)
				statue.name = "statue of [prisoner.real_name]"
				statue.faction = list("\ref[firer]")
				statue.icon = target.icon
				if(prisoner.mind)
					prisoner.mind.transfer_to(statue)
					to_chat(statue, span_warning("You are an animated statue. You cannot move when monitored, but are nearly invincible and deadly when unobserved!"))
					to_chat(statue, span_userdanger("Do not harm [firer.real_name], your creator."))
				prisoner.forceMove(statue)
				qdel(target)
		else
			if(isgun(target))
				new /mob/living/simple_animal/hostile/mimic/copy/ranged(target.loc, target, firer)
			else
				new /mob/living/simple_animal/hostile/mimic/copy(target.loc, target, firer)

	else if(istype(target, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/mimic = target
		mimic.ChangeOwner(firer)


/obj/item/projectile/magic/spellblade
	name = "blade energy"
	icon_state = "lavastaff"
	damage = 15
	damage_type = BURN
	flag = "magic"
	dismemberment = 50
	dismember_head = TRUE
	nodamage = FALSE

/obj/item/projectile/magic/slipping
	name = "magical banana"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	hitsound = 'sound/items/bikehorn.ogg'
	var/slip_disable_time = 10 SECONDS

/obj/item/projectile/magic/slipping/New()
	..()
	SpinAnimation()

/obj/item/projectile/magic/slipping/on_hit(atom/target, blocked = 0)
	if(isrobot(target)) //You think you're safe, cyborg? FOOL!
		var/mob/living/silicon/robot/R = target
		if(!R.IsStunned())
			to_chat(target, span_warning("You get splatted by [src], HONKING your sensors!"))
			R.Stun(slip_disable_time)
	else if(isliving(target))
		var/mob/living/L = target
		playsound(L.loc, 'sound/misc/slip.ogg', 50, TRUE, -3)
		L.stop_pulling()
		// Something something don't run with scissors
		L.moving_diagonally = NONE //If this was part of diagonal move slipping will stop it.
		if(!L.IsWeakened())
			to_chat(target, span_warning("You get splatted by [src]."))
			L.Weaken(slip_disable_time)
	. = ..()

/obj/item/projectile/magic/arcane_barrage
	name = "arcane bolt"
	icon_state = "arcane_barrage"
	damage = 20
	damage_type = BURN
	nodamage = FALSE
	armour_penetration = 0
	flag = "magic"
	hitsound = 'sound/weapons/barragespellhit.ogg'
