//A slow but strong beast that tries to stun using its tentacles
/mob/living/simple_animal/hostile/asteroid/goliath
	name = "goliath"
	desc = "Массивный зверь, использующий длинные щупальца для поимки добычи. Угрожать ему – плохая идея при любых обстоятельствах."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_to_delay = 40
	ranged = TRUE
	ranged_cooldown_time = 120
	friendly = "воет на"
	speak_emote = list("ревёт")
	tts_seed = "Bloodseeker"
	vision_range = 4
	speed = 3
	maxHealth = 300
	health = 300
	harm_intent_damage = 1 //Only the manliest of men can kill a Goliath with only their fists.
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "сокрушает"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "не наносит вреда его прочной шкуре"
	vision_range = 5
	aggro_vision_range = 9
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	var/pre_attack = FALSE
	var/pre_attack_icon = "Goliath_preattack"
	loot = list(/obj/item/stack/sheet/animalhide/goliath_hide)
	footstep_type = FOOTSTEP_MOB_HEAVY
	emote_taunt = list("грозно рычит")
	taunt_chance = 30
	var/turf/charge_turf
	var/reflect_chance = 30
	food_type = list(/obj/item/reagent_containers/food/snacks/meat, /obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit, /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_leaf)
	tame_chance = 0
	bonus_tame_chance = 10
	COOLDOWN_DECLARE(post_charge_delay)

/mob/living/simple_animal/hostile/asteroid/goliath/get_ru_names()
	return list(
		NOMINATIVE = "голиаф",
		GENITIVE = "голиафа",
		DATIVE = "голиафу",
		ACCUSATIVE = "голиафа",
		INSTRUMENTAL = "голиафом",
		PREPOSITIONAL = "голиафе"
	)

/mob/living/simple_animal/hostile/asteroid/goliath/bullet_act(obj/projectile/P)
	if(prob(reflect_chance) && !istype(P, /obj/projectile/destabilizer))
		visible_message(span_danger("[capitalize(P.declent_ru(NOMINATIVE))] отскакивает от крепкой шкуры [declent_ru(GENITIVE)]!"), span_userdanger("[capitalize(P.declent_ru(NOMINATIVE))] отскакивает от крепой шкуры [declent_ru(GENITIVE)]!"), projectile_message = TRUE)
		P.reflect_back(src, list(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3))

		return -1 // complete projectile permutation
	return (..(P))

/mob/living/simple_animal/hostile/asteroid/goliath/Life()
	. = ..()
	handle_preattack()

/mob/living/simple_animal/hostile/asteroid/goliath/proc/handle_preattack()
	if(ranged_cooldown <= world.time + ranged_cooldown_time * 0.25 && !pre_attack)
		pre_attack++
	if(!pre_attack || stat || AIStatus == AI_IDLE)
		return
	if(stat == DEAD)
		return
	icon_state = pre_attack_icon

/mob/living/simple_animal/hostile/asteroid/goliath/revive()//who the fuck anchors mobs
	if(..())
		move_resist = MOVE_FORCE_VERY_STRONG
		return TRUE


/mob/living/simple_animal/hostile/asteroid/goliath/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	..(gibbed)


/mob/living/simple_animal/hostile/asteroid/goliath/handle_automated_action()
	if(charge_turf || !COOLDOWN_FINISHED(src, post_charge_delay))
		return FALSE
	return ..()


/mob/living/simple_animal/hostile/asteroid/goliath/handle_automated_movement()
	if(charge_turf || !COOLDOWN_FINISHED(src, post_charge_delay))
		return FALSE
	return ..()


/mob/living/simple_animal/hostile/asteroid/goliath/AttackingTarget() //override to OpenFire close by
	if(charge_turf)
		return FALSE
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(!client && ranged && ranged_cooldown <= world.time)
				OpenFire()
				ranged_cooldown = world.time + ranged_cooldown_time


/mob/living/simple_animal/hostile/asteroid/goliath/OpenFire()
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 1) //if target close by
		melee_attack(GLOB.alldirs)
	if(get_dist(src, target) > 1 && get_dist(src, target) <= 7) //Screen range check, so you can't get tentacle'd offscreen
		if(prob(50))
			ranged_attack()
		else
			charge()


/mob/living/simple_animal/hostile/asteroid/goliath/proc/melee_attack(list/dirs)
	if(!islist(dirs))
		dirs = GLOB.alldirs.Copy()
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] выпускает щупальца из-под земли вокруг себя!"))
	for(var/d in dirs)
		var/turf/E = get_step(src, d)
		new /obj/effect/temp_visual/goliath_tentacle(E, src)
	pre_attack = FALSE


/mob/living/simple_animal/hostile/asteroid/goliath/proc/ranged_attack()
	var/tturf = get_turf(target)
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] опутывает щупальцами [target.declent_ru(ACCUSATIVE)]!"))
	new /obj/effect/temp_visual/goliath_tentacle/original(tturf, src)
	ranged_cooldown = world.time + ranged_cooldown_time
	if((stat == DEAD))
		return
	icon_state = icon_aggro
	pre_attack = FALSE


#define GOLIATH_CHARGE_SPEED 0.7

/mob/living/simple_animal/hostile/asteroid/goliath/proc/charge(atom/chargeat = target, delay = 10, chargepast = 2)
	if(!chargeat)
		return
	var/chargeturf = get_turf(chargeat)
	if(!chargeturf)
		return
	var/dir = get_dir(src, chargeturf)
	var/turf/T = get_ranged_target_turf(chargeturf, dir, chargepast)
	if(!T)
		return
	SSmove_manager.stop_looping(src)
	charge_turf = T
	setDir(dir)
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(loc,src)
	animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 3)
	SLEEP_CHECK_DEATH(src, delay)
	var/datum/move_loop/new_loop = SSmove_manager.home_onto(src, charge_turf, delay = GOLIATH_CHARGE_SPEED, timeout = 2 SECONDS, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	if(!new_loop)
		return
	RegisterSignal(src, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump), override = TRUE)
	RegisterSignal(new_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move), override = TRUE)

#undef GOLIATH_CHARGE_SPEED


/mob/living/simple_animal/hostile/asteroid/goliath/proc/on_bump(datum/source, atom/bumped_atom)
	SIGNAL_HANDLER
	if(ismineralturf(bumped_atom))
		var/turf/simulated/mineral/mineral = bumped_atom
		if(mineral.mineralAmt < 7)
			mineral.mineralAmt++
	end_charge()


/mob/living/simple_animal/hostile/asteroid/goliath/proc/post_move(datum/source)
	SIGNAL_HANDLER
	if(get_turf(src) == charge_turf)
		end_charge()


/mob/living/simple_animal/hostile/asteroid/goliath/proc/end_charge()
	UnregisterSignal(src, COMSIG_MOVABLE_BUMP)
	charge_turf = null
	SSmove_manager.stop_looping(src)
	INVOKE_ASYNC(src, PROC_REF(CheckAndAttack))
	COOLDOWN_START(src, post_charge_delay, 2 SECONDS)


/mob/living/simple_animal/hostile/asteroid/goliath/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	if(amount > 0)
		ranged_cooldown -= 10
		handle_preattack()
	return ..()

/mob/living/simple_animal/hostile/asteroid/goliath/Aggro()
	vision_range = aggro_vision_range
	handle_preattack()
	if(target && prob(taunt_chance))
		emote("me", 1, "[pick(emote_taunt)] на [target].")
		taunt_chance = max(taunt_chance-7,2)
	if(icon_state != icon_aggro && stat != DEAD)
		icon_state = icon_aggro

//Lavaland Goliath
/mob/living/simple_animal/hostile/asteroid/goliath/beast
	name = "goliath"
	desc = "Громадный зверь в бронированном панцире, со щупальцами, изгибающимися у него за спиной."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath"
	icon_living = "goliath"
	icon_aggro = "goliath"
	icon_dead = "goliath_dead"
	throw_message = "не наносит вреда его прочной шкуре"
	pre_attack_icon = "goliath2"
	crusher_loot = /obj/item/crusher_trophy/goliath_tentacle
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/goliath= 2, /obj/item/stack/sheet/animalhide/goliath_hide = 1, /obj/item/stack/sheet/bone = 2)
	loot = list()
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE

/mob/living/simple_animal/hostile/asteroid/goliath/beast/get_ru_names()
	return list(
		NOMINATIVE = "голиаф",
		GENITIVE = "голиафа",
		DATIVE = "голиафу",
		ACCUSATIVE = "голиафа",
		INSTRUMENTAL = "голиафом",
		PREPOSITIONAL = "голиафе"
	)

/mob/living/simple_animal/hostile/asteroid/goliath/beast/random/Initialize(mapload)
	. = ..()
	if(prob(10))
		new /mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient(loc)
		return INITIALIZE_HINT_QDEL

/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient
	name = "ancient goliath"
	desc = "Голиафы биологически бессмертны, и редкие особи живут веками. Этот явно древний, и его щупальца постоянно взрыхляют землю вокруг."
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	maxHealth = 400
	health = 400
	speed = 4
	pre_attack_icon = "Goliath_preattack"
	throw_message = "не наносит вреда его прочной шкуре"
	crusher_loot = /obj/item/crusher_trophy/eyed_tentacle
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/goliath = 2, /obj/item/stack/sheet/animalhide/goliath_hide = 2, /obj/item/stack/sheet/bone = 2)
	crusher_drop_mod = 30
	wander = FALSE
	var/list/cached_tentacle_turfs
	var/turf/last_location
	var/tentacle_recheck_cooldown = 100
	reflect_chance = 50
	bonus_tame_chance = 5

/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient/get_ru_names()
	return list(
		NOMINATIVE = "древний голиаф",
		GENITIVE = "древнего голиафа",
		DATIVE = "древнему голиафу",
		ACCUSATIVE = "древнего голиафа",
		INSTRUMENTAL = "древним голиафом",
		PREPOSITIONAL = "древнем голиафе"
	)

/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient/Life()
	. = ..()
	if(!.) // dead
		return
	if(isturf(loc))
		if(!LAZYLEN(cached_tentacle_turfs) || loc != last_location || tentacle_recheck_cooldown <= world.time)
			LAZYCLEARLIST(cached_tentacle_turfs)
			last_location = loc
			tentacle_recheck_cooldown = world.time + initial(tentacle_recheck_cooldown)
			for(var/turf/T as anything in RECT_TURFS(4, 4, loc))
				LAZYADD(cached_tentacle_turfs, T)
		for(var/t in cached_tentacle_turfs)
			if(isfloorturf(t))
				if(prob(10))
					new /obj/effect/temp_visual/goliath_tentacle(t, src)
			else
				cached_tentacle_turfs -= t

/mob/living/simple_animal/hostile/asteroid/goliath/beast/tendril
	fromtendril = TRUE

//Tentacles
/obj/effect/temp_visual/goliath_tentacle
	name = "goliath tentacle"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath_tentacle_spawn"
	layer = BELOW_MOB_LAYER
	var/mob/living/spawner

/obj/effect/temp_visual/goliath_tentacle/get_ru_names()
	return list(
		NOMINATIVE = "щупальце голиафа",
		GENITIVE = "щупальца голиафа",
		DATIVE = "щупальцу голиафа",
		ACCUSATIVE = "щупальце голиафа",
		INSTRUMENTAL = "щупальцем голиафа",
		PREPOSITIONAL = "щупальце голиафа"
	)

/obj/effect/temp_visual/goliath_tentacle/Initialize(mapload, mob/living/new_spawner)
	. = ..()
	for(var/obj/effect/temp_visual/goliath_tentacle/T in loc)
		if(T != src)
			return INITIALIZE_HINT_QDEL
	if(!QDELETED(new_spawner))
		spawner = new_spawner
	if(ismineralturf(loc))
		var/turf/simulated/mineral/M = loc
		M.attempt_drill()
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, PROC_REF(tripanim)), 7, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/original/Initialize(mapload, new_spawner)
	. = ..()
	var/list/directions = GLOB.cardinal.Copy()
	for(var/i in 1 to 3)
		var/spawndir = pick_n_take(directions)
		var/turf/T = get_step(src, spawndir)
		if(T)
			new /obj/effect/temp_visual/goliath_tentacle(T, spawner)

/obj/effect/temp_visual/goliath_tentacle/full_cross/Initialize(mapload, new_spawner)
	. = ..()
	for(var/dir in GLOB.cardinal)
		new /obj/effect/temp_visual/goliath_tentacle(get_step(src, dir), spawner)

/obj/effect/temp_visual/goliath_tentacle/proc/tripanim()
	icon_state = "Goliath_tentacle_wiggle"
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, PROC_REF(trip)), 3, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/proc/trip()
	var/latched = FALSE
	for(var/mob/living/L in loc)
		if((!QDELETED(spawner) && spawner.faction_check_mob(L)) || L.stat == DEAD)
			continue
		visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] захватывает [L.declent_ru(ACCUSATIVE)]!"))
		if(!L.IsStunned())
			L.Stun(10 SECONDS)
			L.adjustBruteLoss(rand(10, 15))
		else
			L.adjustBruteLoss(rand(20, 30))
		latched = TRUE
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, PROC_REF(retract)), 10, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/proc/retract()
	icon_state = "Goliath_tentacle_retract"
	deltimer(timerid)
	timerid = QDEL_IN_STOPPABLE(src, 7)
