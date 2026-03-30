// MARK: Generic
/obj/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	damage = 0
	hitsound = 'sound/weapons/magic.ogg'
	hitsound_wall = 'sound/weapons/magic.ogg'
	damage_type = OXY
	nodamage = TRUE
	armour_penetration = 100
	flag = "magic"

/obj/projectile/magic/get_ru_names()
	return list(
		NOMINATIVE = "разряд пустоты",
		GENITIVE = "разряда пустоты",
		DATIVE = "разряду пустоты",
		ACCUSATIVE = "разряд пустоты",
		INSTRUMENTAL = "разрядом пустоты",
		PREPOSITIONAL = "разряде пустоты",
	)

// MARK: Death Bolt
/obj/projectile/magic/death
	name = "bolt of death"
	icon_state = null
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/death
	tracer_type = /obj/effect/projectile/tracer/death
	impact_type = /obj/effect/projectile/impact/death
	hitscan_light_intensity = 3
	hitscan_light_color_override = LIGHT_COLOR_PURPLE
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = LIGHT_COLOR_PURPLE
	impact_light_intensity = 7
	impact_light_range =  2.5
	impact_light_color_override = LIGHT_COLOR_PURPLE

/obj/projectile/magic/death/get_ru_names()
	return list(
		NOMINATIVE = "заряд смерти",
		GENITIVE = "заряда смерти",
		DATIVE = "заряду смерти",
		ACCUSATIVE = "заряд смерти",
		INSTRUMENTAL = "зарядом смерти",
		PREPOSITIONAL = "заряде смерти",
	)

/obj/projectile/magic/death/on_hit(mob/living/carbon/C)
	. = ..()
	if(isliving(C))
		if(ismachineperson(C)) //speshul snowfleks deserv speshul treetment
			C.adjustFireLoss(6969)  //remember - slimes love fire
		C.death()

		visible_message(span_danger("[DECLENT_RU_CAP(C, NOMINATIVE)] падает замертво, когда [GEND_HIS_HER(C)] поражает заряд смерти!"))

// MARK: Fireball Bolt
/obj/projectile/magic/fireball
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

/obj/projectile/magic/fireball/get_ru_names()
	return list(
		NOMINATIVE = "огненный шар",
		GENITIVE = "огненного шара",
		DATIVE = "огненному шару",
		ACCUSATIVE = "огненный шар",
		INSTRUMENTAL = "огненным шаром",
		PREPOSITIONAL = "огненном шаре",
	)

/obj/projectile/magic/fireball/Range()
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

/obj/projectile/magic/fireball/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	var/turf/T = get_turf(target)
	explosion(T, exp_devastate, exp_heavy, exp_light, exp_flash, adminlog = FALSE, flame_range = exp_fire, cause = src)
	if(!ismob(target)) //multiple flavors of pain
		return
	var/mob/living/M = target
	M.take_overall_damage(0,10) //between this 10 burn, the 10 brute, the explosion brute, and the onfire burn, your at about 65 damage if you stop drop and roll immediately

/obj/projectile/magic/fireball/infernal
	name = "infernal fireball"
	exp_heavy = -1
	exp_light = -1
	exp_flash = 4
	exp_fire= -1
	var/hellfire_power = BURN_LEVEL_TIER_1
	var/hellfire_type = /datum/reagent/napalm/hellfire

/obj/projectile/magic/fireball/infernal/get_ru_names()
	return list(
		NOMINATIVE = "адский фаербол",
		GENITIVE = "адского фаербола",
		DATIVE = "адскому фаерболу",
		ACCUSATIVE = "адский фаербол",
		INSTRUMENTAL = "адским фаерболом",
		PREPOSITIONAL = "адском фаерболе",
	)

/obj/projectile/magic/fireball/infernal/acsend
	name = "acsend fireball"
	hellfire_power = BURN_LEVEL_TIER_9
	hellfire_type = null

/obj/projectile/magic/fireball/infernal/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	var/turf/fire_turf = get_turf(target)
	flame_radius(3, fire_turf, BURN_TIME_DEVIL, hellfire_power, FLAMESHAPE_IRREGULAR, target, FIRE_VARIANT_DEFAULT, hellfire_type)

// MARK: Resurrection Bolt
/obj/projectile/magic/resurrection
	name = "bolt of resurrection"
	icon_state = "ion"

/obj/projectile/magic/resurrection/get_ru_names()
	return list(
		NOMINATIVE = "воскрешающий заряд",
		GENITIVE = "воскрешающего заряда",
		DATIVE = "воскрешающему заряду",
		ACCUSATIVE = "воскрешающий заряд",
		INSTRUMENTAL = "воскрешающим зарядом",
		PREPOSITIONAL = "воскрешающем заряде",
	)

/obj/projectile/magic/resurrection/on_hit(mob/living/carbon/target)
	. = ..()
	if(ismob(target))
		if(target.mind && !target.mind.hasSoul)
			return .
		var/old_stat = target.stat
		target.suiciding = 0
		target.revive()
		if(!target.ckey)
			for(var/mob/dead/observer/ghost in GLOB.player_list)
				if(target.real_name == ghost.real_name)
					ghost.reenter_corpse()
					break
		if(old_stat != DEAD)
			to_chat(target, span_notice("Вы чувствуете себя великолепно!"))
		else
			to_chat(target, span_notice("Вы восстаете из мёртвых. <b>ВЫ СНОВА ЖИВЫ!!!</b>"))

// MARK: Teleportation Bolt
/obj/projectile/magic/teleport
	name = "bolt of teleportation"
	icon_state = "bluespace"
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

/obj/projectile/magic/teleport/get_ru_names()
	return list(
		NOMINATIVE = "телепортационный импульс",
		GENITIVE = "телепортационного импульса",
		DATIVE = "телепортационному импульсу",
		ACCUSATIVE = "телепортационный импульс",
		INSTRUMENTAL = "телепортационным импульсом",
		PREPOSITIONAL = "телепортационном импульсе",
	)

/obj/projectile/magic/teleport/on_hit(mob/target)
	. = ..()
	var/teleammount = 0
	var/teleloc = target
	if(!isturf(target))
		teleloc = target.loc
	for(var/atom/movable/stuff in teleloc)
		if(!stuff.anchored && stuff.loc)
			teleammount++
			do_teleport(stuff, stuff, 10)
			var/datum/effect_system/fluid_spread/smoke/smoke = new
			smoke.set_up(amount = max(round(10 - teleammount),1), location = stuff.loc) //Smoke drops off if a lot of stuff is moved for the sake of sanity
			smoke.start()

// MARK: Door Creation Bolt
/obj/projectile/magic/door
	name = "bolt of door creation"
	var/list/door_types = list(/obj/structure/mineral_door/wood,/obj/structure/mineral_door/iron,/obj/structure/mineral_door/silver,\
		/obj/structure/mineral_door/gold,/obj/structure/mineral_door/uranium,/obj/structure/mineral_door/sandstone,/obj/structure/mineral_door/transparent/plasma,\
		/obj/structure/mineral_door/transparent/diamond)

/obj/projectile/magic/door/get_ru_names()
	return list(
		NOMINATIVE = "заряд создания дверей",
		GENITIVE = "заряда создания дверей",
		DATIVE = "заряду создания дверей",
		ACCUSATIVE = "заряд создания дверей",
		INSTRUMENTAL = "зарядом создания дверей",
		PREPOSITIONAL = "заряде создания дверей",
	)

/obj/projectile/magic/door/on_hit(atom/target)
	. = ..()
	var/atom/T = target.loc
	if(isturf(target) && target.density)
		CreateDoor(target)
	else if(isturf(T) && T.density)
		CreateDoor(T)
	else if(istype(target, /obj/machinery/door))
		OpenDoor(target)
	else if(iscloset(target))
		OpenCloset(target)

/obj/projectile/magic/door/proc/CreateDoor(turf/T)
	var/door_type = pick(door_types)
	var/obj/structure/mineral_door/D = new door_type(T)
	T.ChangeTurf(/turf/simulated/floor/plasteel)
	D.Open()

/obj/projectile/magic/door/proc/OpenDoor(obj/machinery/door/D)
	if(is_airlock(D))
		var/obj/machinery/door/airlock/A = D
		A.locked = FALSE
	D.open()

/obj/projectile/magic/door/proc/OpenCloset(obj/structure/closet/C)
	if(C?.locked)
		C.locked = FALSE
	C.open()

// MARK: Transformation Bolt
/obj/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage_type = BURN

/obj/projectile/magic/change/get_ru_names()
	return list(
		NOMINATIVE = "заряд полиморфа",
		GENITIVE = "заряда полиморфа",
		DATIVE = "заряду полиморфа",
		ACCUSATIVE = "заряд полиморфа",
		INSTRUMENTAL = "зарядом полиморфа",
		PREPOSITIONAL = "заряде полиморфа",
	)

/obj/projectile/magic/change/on_hit(atom/change)
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
				сбиваться в стаи или следовать своему пути одиночки, но цель всегда будет одна — утолить свой голод."
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
			new_mob.possess_by_player(M.ckey)

		if(is_new_mind)
			to_chat(new_mob, span_danger("Вы потеряли свою личность и память! Отыгрывайте новое существо!"))
		to_chat(new_mob, span_danger("ТЕПЕРЬ ВЫ [uppertext(randomize)]"))
		if(briefing_msg)
			to_chat(new_mob, chat_box_red(span_userdanger("[briefing_msg]")))

		qdel(M)
		return new_mob

// MARK: Animation Bolt
/obj/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	damage_type = BURN

/obj/projectile/magic/animate/get_ru_names()
	return list(
		NOMINATIVE = "анимационный заряд",
		GENITIVE = "анимационного заряда",
		DATIVE = "анимационному заряду",
		ACCUSATIVE = "анимационный заряд",
		INSTRUMENTAL = "анимационным зарядом",
		PREPOSITIONAL = "анимационном заряде",
	)

/obj/projectile/magic/animate/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()

	if(isitem(target) || (isstructure(target) && !is_type_in_list(target, GLOB.protected_objects)))
		if(istype(target, /obj/structure/closet/statue))
			for(var/mob/living/carbon/human/prisoner in target)
				var/mob/living/simple_animal/hostile/statue/statue = new(target.loc, firer)
				statue.name = "statue of [prisoner.real_name]"
				statue.faction = list(PERSONAL_FACTION(firer))
				statue.icon = target.icon
				if(prisoner.mind)
					prisoner.mind.transfer_to(statue)
					var/list/messages = list()
					messages.Add(span_userdanger("You have been transformed into an animated statue."))
					messages.Add("You cannot move when monitored, but are nearly invincible and deadly when unobserved! Hunt down those who shackle you.")
					messages.Add("Do not harm [firer.real_name], your creator.")
					to_chat(statue, chat_box_red(messages.Join("<br>")))
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

// MARK: Spellblade
/obj/projectile/magic/spellblade
	name = "blade energy"
	icon_state = "lavastaff"
	damage = 15
	damage_type = BURN
	dismemberment = 50
	dismember_head = TRUE
	nodamage = FALSE

/obj/projectile/magic/spellblade/get_ru_names()
	return list(
		NOMINATIVE = "энергия лезвия",
		GENITIVE = "энергии лезвия",
		DATIVE = "энергии лезвия",
		ACCUSATIVE = "энергию лезвия",
		INSTRUMENTAL = "энергией лезвия",
		PREPOSITIONAL = "энергии лезвия",
	)

// MARK: Slipping
/obj/projectile/magic/slipping
	name = "magical banana"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	hitsound = 'sound/items/bikehorn.ogg'
	var/slip_disable_time = 10 SECONDS

/obj/projectile/magic/slipping/get_ru_names()
	return list(
		NOMINATIVE = "волшебный банан",
		GENITIVE = "волшебного банана",
		DATIVE = "волшебному банану",
		ACCUSATIVE = "волшебный банан",
		INSTRUMENTAL = "волшебным бананом",
		PREPOSITIONAL = "волшебном банане",
	)

/obj/projectile/magic/slipping/New()
	..()
	SpinAnimation()

/obj/projectile/magic/slipping/on_hit(atom/target, blocked = 0)
	if(isrobot(target)) //You think you're safe, cyborg? FOOL!
		var/mob/living/silicon/robot/R = target
		if(!R.IsStunned())
			to_chat(target, span_warning("В вас попадает волшебный банан, ХОНКая ваши сенсоры!"))
			R.Stun(slip_disable_time)
	else if(isliving(target))
		var/mob/living/L = target
		playsound(L.loc, 'sound/misc/slip.ogg', 50, TRUE, -3)
		L.stop_pulling()
		// Something something don't run with scissors
		L.moving_diagonally = NONE //If this was part of diagonal move slipping will stop it.
		if(!L.IsWeakened())
			to_chat(target, span_warning("В вас попадает волшебный банан."))
			L.Knockdown(slip_disable_time)
	. = ..()

// MARK: Arcane barrage
/obj/projectile/magic/arcane_barrage
	name = "arcane bolt"
	icon_state = "arcane_barrage"
	damage = 20
	damage_type = BURN
	nodamage = FALSE
	armour_penetration = 0
	hitsound = 'sound/weapons/barragespellhit.ogg'
	forced_accuracy = TRUE

/obj/projectile/magic/arcane_barrage/get_ru_names()
	return list(
		NOMINATIVE = "тайный заряд",
		GENITIVE = "тайного заряда",
		DATIVE = "тайному заряду",
		ACCUSATIVE = "тайный заряд",
		INSTRUMENTAL = "тайным зарядом",
		PREPOSITIONAL = "тайном заряде",
	)

/obj/projectile/magic/arcane_barrage/blood
	name = "blood bolt"
	icon_state = "blood_bolt"
	damage_type = BRUTE
	impact_effect_type = /obj/effect/temp_visual/cult/sparks
	hitsound = 'sound/effects/splat.ogg'

/obj/projectile/magic/arcane_barrage/blood/prehit(atom/target)
	if(iscultist(target))
		damage = 0
		nodamage = TRUE
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.stat != DEAD)
				H.reagents.add_reagent("unholywater", 4)
		if(isshade(target) || isconstruct(target))
			var/mob/living/simple_animal/M = target
			if(M.health + 5 < M.maxHealth)
				M.adjustHealth(-5)
		new /obj/effect/temp_visual/cult/sparks(target)
	..()

// MARK: Shadow Hand
/obj/projectile/magic/shadow_hand
	name = "shadow hand"
	icon_state = "shadow_hand"
	plane = FLOOR_PLANE
	speed = 1
	hitsound = 'sound/shadowdemon/shadowattack1.ogg' // Plays when hitting something living or a light
	var/hit = FALSE

/obj/projectile/magic/shadow_hand/get_ru_names()
	return list(
		NOMINATIVE = "теневая рука",
		GENITIVE = "теневой руки",
		DATIVE = "теневой руке",
		ACCUSATIVE = "теневую руку",
		INSTRUMENTAL = "теневой рукой",
		PREPOSITIONAL = "теневой руке",
	)

/obj/projectile/magic/shadow_hand/fire(setAngle)
	if(firer)
		firer.Beam(src, icon_state = "grabber_beam", time = INFINITY, maxdistance = INFINITY, beam_type = /obj/effect/ebeam/floor, layer = BELOW_MOB_LAYER)
	return ..()

/obj/projectile/magic/shadow_hand/on_hit(atom/target, blocked, hit_zone)
	if(hit)
		return
	hit = TRUE // to prevent double hits from the pull
	. = ..()
	for(var/atom/extinguish_target in range(2, src))
		extinguish_target.extinguish_light(TRUE)
	if(isliving(target))
		var/mob/living/l_target = target
		l_target.Immobilize(4 SECONDS)
		l_target.apply_damage(40, BRUTE, BODY_ZONE_CHEST)
		l_target.throw_at(get_step(firer, get_dir(firer, target)), 50, 10)
	else
		firer.throw_at(get_step(target, get_dir(target, firer)), 50, 10)

// MARK: Demonic Grasp
/obj/projectile/magic/demonic_grasp
	name = "demonic grasp"
	// parry this you filthy casual
	reflectability = REFLECTABILITY_NEVER
	icon_state = null

/obj/projectile/magic/demonic_grasp/get_ru_names()
	return list(
			NOMINATIVE = "демоническая хватка",
			GENITIVE = "демонической хватки",
			DATIVE = "демонической хватке",
			ACCUSATIVE = "демоническую хватку",
			INSTRUMENTAL = "демонической хваткой",
			PREPOSITIONAL = "демонической хватке",
		)

/obj/projectile/magic/demonic_grasp/pixel_move(trajectory_multiplier)
	. = ..()
	new /obj/effect/temp_visual/demonic_grasp(loc)

/obj/projectile/magic/demonic_grasp/on_hit(mob/living/target, blocked, hit_zone)
	. = ..()
	if(!istype(target) || !firer || !target.affects_vampire(firer))
		return

	var/target_turf = get_turf(target)
	target.Immobilize(5 SECONDS)
	playsound(target_turf, 'sound/misc/demon_attack1.ogg', 50, TRUE)
	new /obj/effect/temp_visual/demonic_grasp(target_turf)

	var/throw_target
	switch(firer.a_intent)
		if(INTENT_DISARM)
			throw_target = get_edge_target_turf(target, get_dir(firer, target))
			target.throw_at(throw_target, 2, 5, spin = FALSE, callback = CALLBACK(src, PROC_REF(create_snare), target)) // shove away
		if(INTENT_GRAB)
			throw_target = get_step(firer, get_dir(firer, target))
			target.throw_at(throw_target, 2, 5, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, PROC_REF(create_snare), target)) // pull towards
		else
			create_snare(target)

/obj/projectile/magic/demonic_grasp/proc/create_snare(mob/living/target)
	new /obj/effect/temp_visual/demonic_snare(get_turf(target))

// MARK: Frost Bolt
/obj/projectile/magic/frost
	name = "bolt of frost"
	icon_state = "ice_2"
	hitsound = 'sound/effects/hit_on_shattered_glass.ogg'
	hitsound_wall = 'sound/effects/hit_on_shattered_glass.ogg'

/obj/projectile/magic/frost/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(isliving(target))
		var/mob/living/victim = target
		freeze(victim)

/obj/projectile/magic/frost/proc/freeze(mob/living/target)
	target.apply_status_effect(/datum/status_effect/freon/frost)
