//Anomalies, used for events. Note that these DO NOT work by themselves; their procs are called by the event datum.

/// Chance of taking a step per second
#define ANOMALY_MOVECHANCE 70

/obj/effect/old_anomaly
	name = "anomaly"
	desc = "A mysterious anomaly, seen commonly only in the region of space that the station orbits..."
	icon_state = "bhole3"
	density = FALSE
	anchored = TRUE
	light_range = 3
	var/movechance = ANOMALY_MOVECHANCE
	var/obj/item/assembly/signaler/core/aSignal = /obj/item/assembly/signaler/core
	var/area/impact_area
	/// Time in deciseconds before the anomaly triggers
	var/lifespan = 990
	var/death_time

	var/countdown_colour
	var/obj/effect/countdown/anomaly/countdown

	/// Do we drop a core when we're neutralized?
	var/drops_core = TRUE

/obj/effect/old_anomaly/Initialize(mapload, new_lifespan, _drops_core = TRUE)
	. = ..()
	GLOB.poi_list |= src
	START_PROCESSING(SSobj, src)
	impact_area = get_area(src)

	if(!impact_area)
		return INITIALIZE_HINT_QDEL

	drops_core = _drops_core

	aSignal = new aSignal(src)
	aSignal.code = rand(1, 100)
	aSignal.anomaly_type = type

	var/frequency = rand(PUBLIC_LOW_FREQ, PUBLIC_HIGH_FREQ)
	if(ISMULTIPLE(frequency, 2))//signaller frequencies are always uneven!
		frequency++
	aSignal.set_frequency(frequency)

	if(new_lifespan)
		lifespan = new_lifespan
	death_time = world.time + lifespan
	countdown = new(src)
	if(countdown_colour)
		countdown.color = countdown_colour
	countdown.start()

/obj/effect/old_anomaly/Destroy()
	GLOB.poi_list.Remove(src)
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(countdown)
	QDEL_NULL(aSignal)
	return ..()

/obj/effect/old_anomaly/process()
	for(var/obj/item/item in get_turf(src))
		if(!item.origin_tech)
			continue
		if (istype(item, /obj/item/relict_production/rapid_dupe))
			var/amount = rand(1, 3)
			for (var/i; i <= amount; i++)
				new /obj/item/relic(get_turf(item))
				var/datum/effect_system/fluid_spread/smoke/smoke = new
				smoke.set_up(5, get_turf(item))
				smoke.start()
			qdel(item)
			continue
		if (prob(2))
			new /obj/item/relic(get_turf(item))
			qdel(item)

	anomalyEffect()
	if(death_time < world.time)
		if(loc)
			detonate()
		qdel(src)

/obj/effect/old_anomaly/proc/anomalyEffect()
	if(prob(movechance))
		step(src, pick(GLOB.alldirs))

/obj/effect/old_anomaly/proc/detonate()
	return

/obj/effect/old_anomaly/ex_act(severity)
	if(severity == EXPLODE_DEVASTATE)
		qdel(src)

/obj/effect/old_anomaly/proc/anomalyNeutralize()
	new /obj/effect/particle_effect/fluid/smoke/bad(loc)

	if(drops_core)
		aSignal.forceMove(drop_location())
		aSignal = null
	// else, anomaly core gets deleted by qdel(src).

	qdel(src)


/obj/effect/old_anomaly/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/analyzer))
		to_chat(user, span_notice("Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(aSignal.frequency)], code [aSignal.code]."))
	return ATTACK_CHAIN_PROCEED_SUCCESS


///////////////////////

/obj/effect/old_anomaly/gravitational
	name = "gravitational anomaly"
	icon_state = "shield2"
	density = FALSE
	var/boing = FALSE
	var/knockdown = FALSE
	aSignal = /obj/item/assembly/signaler/core/gravitational/tier2


/obj/effect/old_anomaly/gravitational/Initialize(mapload, new_lifespan, _drops_core)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/old_anomaly/gravitational/anomalyEffect()
	..()
	boing = TRUE
	for(var/obj/O in orange(4, src))
		if(!O.anchored)
			step_towards(O,src)
	for(var/mob/living/mob in range(0, src))
		gravShock(mob)
	for(var/mob/living/mob in orange(4, src))
		if(!mob.mob_negates_gravity())
			step_towards(mob,src)
	for(var/obj/O in range(0, src))
		if(!O.anchored && O.loc != src && O.move_resist < MOVE_FORCE_OVERPOWERING) // so it cannot throw the anomaly core or super big things)
			var/mob/living/target = locate() in view(4, src)
			if(target && !target.stat)
				O.throw_at(target, 5, 10)


/obj/effect/old_anomaly/gravitational/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	gravShock(arrived)


/obj/effect/old_anomaly/gravitational/Bump(atom/bumped_atom)
	. = ..()
	if(.)
		return .
	gravShock(bumped_atom)


/obj/effect/old_anomaly/gravitational/Bumped(atom/movable/moving_atom)
	. = ..()
	gravShock(moving_atom)


/obj/effect/old_anomaly/gravitational/proc/gravShock(mob/living/mob)
	if(boing && isliving(mob) && !mob.stat)
		if(!knockdown) // no hardstuns with megafauna
			mob.Weaken(4 SECONDS)
		var/atom/target = get_edge_target_turf(mob, get_dir(src, get_step_away(mob, src)))
		mob.throw_at(target, 5, 1)
		boing = FALSE

/////////////////////

/obj/effect/old_anomaly/energetic
	name = "flux wave anomaly"
	icon_state = "electricity2"
	density = TRUE
	aSignal = /obj/item/assembly/signaler/core/energetic/tier2
	var/canshock = FALSE
	var/shockdamage = 20
	var/explosive = TRUE


/obj/effect/old_anomaly/energetic/Initialize(mapload, new_lifespan, drops_core = TRUE, _explosive = TRUE)
	. = ..()
	explosive = _explosive
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/old_anomaly/energetic/anomalyEffect()
	..()
	canshock = TRUE
	for(var/mob/living/mob in get_turf(src))
		mobShock(mob)


/obj/effect/old_anomaly/energetic/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	mobShock(arrived)


/obj/effect/old_anomaly/energetic/Bump(atom/bumped_atom)
	. = ..()
	if(.)
		return .
	mobShock(bumped_atom)

/obj/effect/old_anomaly/energetic/Bumped(atom/movable/moving_atom)
	. = ..()
	mobShock(moving_atom)

/obj/effect/old_anomaly/energetic/proc/mobShock(mob/living/mob)
	if(canshock && istype(mob))
		canshock = FALSE //Just so you don't instakill yourself if you slam into the anomaly five times in a second.
		mob.electrocute_act(shockdamage, "потоковой аномалии", flags = SHOCK_NOGLOVES)

/obj/effect/old_anomaly/energetic/detonate()
	if(explosive)
		explosion(src, 1, 4, 16, 18, cause = src) //Low devastation, but hits a lot of stuff.
	else
		new /obj/effect/particle_effect/sparks(loc)

/////////////////////

/obj/effect/old_anomaly/bluespace
	name = "bluespace anomaly"
	icon = 'icons/obj/weapons/projectiles.dmi'
	icon_state = "bluespace"
	density = TRUE
	var/mass_teleporting = TRUE
	aSignal = /obj/item/assembly/signaler/core/bluespace/tier2

/obj/effect/old_anomaly/bluespace/Initialize(mapload, new_lifespan, drops_core = TRUE, _mass_teleporting = TRUE)
	. = ..()
	mass_teleporting = _mass_teleporting

/obj/effect/old_anomaly/bluespace/anomalyEffect()
	..()
	for(var/mob/living/mob in range(1, src))
		do_teleport(mob, mob, 4)
		investigate_log("teleported [key_name_log(mob)] to [COORD(mob)]", INVESTIGATE_TELEPORTATION)

/obj/effect/old_anomaly/bluespace/Bumped(atom/movable/moving_atom)
	. = ..()
	if(isliving(moving_atom))
		do_teleport(moving_atom, moving_atom, 8)
		investigate_log("teleported [key_name_log(moving_atom)] to [COORD(moving_atom)]", INVESTIGATE_TELEPORTATION)

/obj/effect/old_anomaly/bluespace/detonate()
	if(!mass_teleporting)
		return
	var/turf/turf = pick(get_area_turfs(impact_area))
	if(turf)
		// Calculate new position (searches through beacons in world)
		var/obj/item/radio/beacon/chosen
		var/list/possible = list()
		for(var/obj/item/radio/beacon/W in GLOB.beacons)
			if(!is_station_level(W.z))
				continue
			possible += W

		if(length(possible))
			chosen = pick(possible)

		if(chosen)
			// Calculate previous position for transition
			var/turf/turf_from = turf // the turf of origin we're travelling FROM
			var/turf/turf_to = get_turf(chosen) // the turf of origin we're travelling TO

			playsound(turf_to, 'sound/effects/phasein.ogg', 100, TRUE)
			GLOB.event_announcement.Announce("Обнаружено перемещение крупной блюспейс-аномалии.", "ВНИМАНИЕ: ОБНАРУЖЕНА АНОМАЛИЯ.")

			var/list/flashers = list()
			for(var/mob/living/carbon/C in viewers(turf_to, null))
				if(C.flash_eyes())
					flashers += C

			var/y_distance = turf_to.y - turf_from.y
			var/x_distance = turf_to.x - turf_from.x
			for(var/atom/movable/movable_atom in urange(12, turf_from)) // iterate thru list of mobs in the area
				if(istype(movable_atom, /obj/item/radio/beacon))
					continue // don't teleport beacons because that's just insanely stupid
				if(movable_atom.anchored || movable_atom.move_resist == INFINITY)
					continue

				var/turf/newloc = locate(movable_atom.x + x_distance, movable_atom.y + y_distance, turf_to.z) // calculate the new place
				if(!movable_atom.Move(newloc) && newloc) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
					movable_atom.forceMove(newloc)

				if(ismob(movable_atom) && !(movable_atom in flashers)) // don't flash if we're already doing an effect
					var/mob/mob = movable_atom
					if(mob.client)
						INVOKE_ASYNC(src, PROC_REF(blue_effect), mob)

/obj/effect/old_anomaly/bluespace/proc/blue_effect(mob/mob)
	var/obj/blueeffect = new /obj(src)
	blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
	blueeffect.icon = 'icons/effects/effects.dmi'
	blueeffect.icon_state = "shieldsparkles"
	blueeffect.layer = FLASH_LAYER
	blueeffect.plane = FULLSCREEN_PLANE
	blueeffect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	mob.client.screen += blueeffect
	sleep(20)
	mob.client.screen -= blueeffect
	qdel(blueeffect)


/////////////////////

/obj/effect/old_anomaly/atmospheric
	name = "pyroclastic anomaly"
	icon_state = "mustard"
	var/ticks = 0
	var/produces_slime = TRUE
	aSignal = /obj/item/assembly/signaler/core/atmospheric/tier2

/obj/effect/old_anomaly/atmospheric/Initialize(mapload, new_lifespan, drops_core = TRUE, _produces_slime = TRUE)
	. = ..()
	produces_slime = _produces_slime

/obj/effect/old_anomaly/atmospheric/anomalyEffect()
	..()
	ticks++
	if(ticks < 5)
		return
	else
		ticks = 0
	var/turf/simulated/turf = get_turf(src)
	if(istype(turf))
		turf.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS | LINDA_SPAWN_OXYGEN, 5)

/obj/effect/old_anomaly/atmospheric/detonate()
	if(produces_slime)
		INVOKE_ASYNC(src, PROC_REF(makepyroslime))

/obj/effect/old_anomaly/atmospheric/proc/makepyroslime()
	var/turf/simulated/turf = get_turf(src)
	if(istype(turf))
		turf.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS | LINDA_SPAWN_OXYGEN, 500) //Make it hot and burny for the new slime
	var/new_colour = pick("red", "orange")
	var/mob/living/simple_animal/slime/random/slime = new(turf, new_colour)
	slime.rabid = TRUE
	slime.set_nutrition(slime.get_max_nutrition())

	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as a pyroclastic anomaly slime?", ROLE_SENTIENT, FALSE, 100, source = slime, role_cleanname = "pyroclastic anomaly slime")
	if(LAZYLEN(candidates))
		var/mob/dead/observer/chosen = pick(candidates)
		slime.key = chosen.key
		slime.mind.special_role = SPECIAL_ROLE_PYROCLASTIC_SLIME
		add_game_logs("was made into a slime by pyroclastic anomaly at [AREACOORD(turf)].", slime)

/////////////////////

/obj/effect/old_anomaly/bhole
	name = "vortex anomaly"
	icon_state = "bhole3"
	desc = "That's a nice station you have there. It'd be a shame if something happened to it."
	aSignal = /obj/item/assembly/signaler/core/vortex/tier2

/obj/effect/old_anomaly/bhole/anomalyEffect()
	..()
	if(!isturf(loc)) //blackhole cannot be contained inside anything. Weird stuff might happen
		qdel(src)
		return

	grav(rand(0, 3), rand(2, 3), 50, 25)

	//Throwing stuff around!
	for(var/obj/O in range(2, src))
		if(O == src)
			return //DON'turf DELETE YOURSELF GOD DAMN
		if(!O.anchored)
			var/mob/living/target = locate() in view(4, src)
			if(target && !target.stat)
				O.throw_at(target, 7, 5)
		else
			O.ex_act(EXPLODE_HEAVY)

/obj/effect/old_anomaly/bhole/proc/grav(r, ex_act_force, pull_chance, turf_removal_chance)
	for(var/t = -r, t < r, t++)
		affect_coord(x + t, y - r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x - t, y + r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x + r, y + t, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x - r, y - t, ex_act_force, pull_chance, turf_removal_chance)

/obj/effect/old_anomaly/bhole/proc/affect_coord(x, y, ex_act_force, pull_chance, turf_removal_chance)
	//Get turf at coordinate
	var/turf/turf = locate(x, y, z)
	if(isnull(turf))
		return

	//Pulling and/or ex_act-ing movable atoms in that turf
	if(prob(pull_chance))
		for(var/obj/O in turf.contents)
			if(O.anchored)
				O.ex_act(ex_act_force)
			else
				step_towards(O, src)
		for(var/mob/living/mob in turf.contents)
			step_towards(mob, src)

	//Damaging the turf
	if(turf && prob(turf_removal_chance))
		turf.ex_act(ex_act_force)

#undef ANOMALY_MOVECHANCE
