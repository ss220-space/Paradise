/obj/effect/anomaly/bluespace
	anomaly_type = ANOMALY_TYPE_BLUESPACE
	icon = 'icons/effects/anomalies.dmi'
	icon_state = "bluespace1"

	/// Minimum bump teleportation radius.
	var/bump_tp_min = 0
	/// Maximum bump teleportation radius.
	var/bump_tp_max = 0

	/// The radius at which items are randomly teleported when anomaly collapses.
	var/collapse_radius = 0
	/// The radius on which items are randomly teleported when anomaly collapses.
	var/collapse_tp_radius = 0

/obj/effect/anomaly/bluespace/proc/teleport(atom/movable/target, radius)
	if(target.anchored && target != src || isobserver(target) || iseffect(target))
		return

	var/turf/start = get_turf(src)
	var/try_x = start.x + rand(-radius, radius)
	var/try_y = start.y + rand(-radius, radius)
	try_x = clamp(try_x, 1, world.maxx)
	try_y = clamp(try_y, 1, world.maxy)
	var/turf/tp_pos = get_turf(locate(try_x, try_y, start.z))
	do_teleport(target, tp_pos, asoundin = 'sound/effects/phasein.ogg')
	if(isliving(target))
		investigate_log("teleported [key_name_log(target)] to [COORD(target)]", INVESTIGATE_TELEPORTATION)

/obj/effect/anomaly/bluespace/mob_touch_effect(mob/living/mob)
	..()
	var/radius = bump_tp_min + round((bump_tp_max - bump_tp_min) * get_strenght() / 100)
	teleport(mob, radius)
	return FALSE

/obj/effect/anomaly/bluespace/item_touch_effect(obj/item/item)
	..()
	var/radius = bump_tp_min + round((bump_tp_max - bump_tp_min) * get_strenght() / 100)
	if(isturf(item.loc))
		teleport(item, radius)

	return FALSE

/obj/effect/anomaly/bluespace/attackby(obj/item/item, mob/living/user, params)
	. = ..()
	var/radius = bump_tp_min + round((bump_tp_max - bump_tp_min) * get_strenght() / 100)
	teleport(user, radius)

/obj/effect/anomaly/bluespace/collapse()
	for(var/atom/movable/atom in range(collapse_radius))
		if(isturf(atom.loc))
			teleport(atom, collapse_tp_radius)

	. = ..()

/obj/effect/anomaly/bluespace/tier1
	name = "малая блюспейс аномалия"
	ru_names = list(
		NOMINATIVE = "малая ​​блюспейс аномалия", \
		GENITIVE = "малой ​​блюспейс аномалии", \
		DATIVE = "малой ​​блюспейс аномалии", \
		ACCUSATIVE = "малую ​​блюспейс аномалию", \
		INSTRUMENTAL = "малой ​​блюспейс аномалией", \
		PREPOSITIONAL = "малой ​​блюспейс аномалии"
	)
	icon_state = "bluespace1"
	core_type = /obj/item/assembly/signaler/core/bluespace/tier1
	stronger_anomaly_type = /obj/effect/anomaly/bluespace/tier2
	tier = 1
	impulses_types = list(
		/datum/anomaly_impulse/move/bs_selftp/tier1,
	)

	bump_tp_min = 1
	bump_tp_max = 2
	collapse_radius = 3
	collapse_tp_radius = 5

// Moves only by /datum/anomaly_impulse/move/bs_selftp
/obj/effect/anomaly/bluespace/tier1/normal_move()
	return FALSE

/obj/effect/anomaly/bluespace/tier2
	name = "блюспейс аномалия"
	ru_names = list(
		NOMINATIVE = "​​блюспейс аномалия", \
		GENITIVE = "​​блюспейс аномалии", \
		DATIVE = "​​блюспейс аномалии", \
		ACCUSATIVE = "​​блюспейс аномалию", \
		INSTRUMENTAL = "​​блюспейс аномалией", \
		PREPOSITIONAL = "​​блюспейс аномалии"
	)
	icon_state = "bluespace2"
	core_type = /obj/item/assembly/signaler/core/bluespace/tier2
	weaker_anomaly_type = /obj/effect/anomaly/bluespace/tier1
	stronger_anomaly_type = /obj/effect/anomaly/bluespace/tier3
	tier = 2
	impulses_types = list(
		/datum/anomaly_impulse/move/bs_selftp/tier2,
		/datum/anomaly_impulse/bs_tp_other/tier2,
		/datum/anomaly_impulse/wormholes/tier2,
	)

	bump_tp_min = 2
	bump_tp_max = 7
	collapse_radius = 5
	collapse_tp_radius = 50

/obj/effect/anomaly/bluespace/tier3
	name = "большая блюспейс аномалия"
	ru_names = list(
		NOMINATIVE = "большая ​​блюспейс аномалия", \
		GENITIVE = "большой ​​блюспейс аномалии", \
		DATIVE = "большой ​​блюспейс аномалии", \
		ACCUSATIVE = "большую ​​блюспейс аномалию", \
		INSTRUMENTAL = "большой ​​блюспейс аномалией", \
		PREPOSITIONAL = "большой ​​блюспейс аномалии"
	)
	icon_state = "bluespace3"
	core_type = /obj/item/assembly/signaler/core/bluespace/tier3
	weaker_anomaly_type = /obj/effect/anomaly/bluespace/tier2
	tier = 3
	impulses_types = list(
		/datum/anomaly_impulse/move/bs_selftp/tier3,
		/datum/anomaly_impulse/bs_tp_other/tier3,
		/datum/anomaly_impulse/wormholes/tier3,
	)

	bump_tp_min = 4
	bump_tp_max = 10
	collapse_radius = 7
	collapse_tp_radius = 50

/obj/effect/anomaly/bluespace/tier3/New()
	. = ..()
	for(var/mob/mob as anything in GLOB.player_list)
		if(mob.stat)
			continue

		if(get_dist(src, mob) > 20 || z != mob.z)
			return

		mob.playsound_local(null,'sound/effects/explosionfar.ogg', 15, TRUE)
		to_chat(mob, span_bluespaceanomaly("Вы слышите страшный треск! Это что... трещит пространство?"))

/obj/effect/anomaly/bluespace/tier3/collapse()
	new /datum/event/wormholes/anomaly()
	for(var/i = 1 to rand(0, 5))
		new /obj/effect/anomaly/bluespace/tier1(get_turf(locate(rand(1, world.maxx), rand(1, world.maxy), z)))

	. = ..()


//		TIER 4 ANOMALY | ADMIN SPAWN ONLY!

/obj/effect/anomaly/bluespace/tier4
	name = "колоссальная блюспейс аномалия"
	ru_names = list(
		NOMINATIVE = "колоссальная ​​блюспейс аномалия", \
		GENITIVE = "колоссальной ​​блюспейс аномалии", \
		DATIVE = "колоссальной ​​блюспейс аномалии", \
		ACCUSATIVE = "колоссальную ​​блюспейс аномалию", \
		INSTRUMENTAL = "колоссальной ​​блюспейс аномалией", \
		PREPOSITIONAL = "колоссальной ​​блюспейс аномалии"
	)
	icon_state = "bluespace3"
	core_type = /obj/item/assembly/signaler/core/bluespace/tier3/tier4
	weaker_anomaly_type = /obj/effect/anomaly/bluespace/tier3
	tier = 4
	impulses_types = list(
		/datum/anomaly_impulse/move/bs_selftp/tier4,
		/datum/anomaly_impulse/bs_tp_other_t4,
		/datum/anomaly_impulse/wormholes/tier4,
	)

	bump_tp_min = 30
	bump_tp_max = 70
	collapse_radius = 7
	collapse_tp_radius = 50

/obj/effect/anomaly/bluespace/tier4/New()
	. = ..()
	for(var/mob/mob as anything in GLOB.player_list)
		if(mob.stat)
			continue

		mob.playsound_local(null,'sound/effects/explosionfar.ogg', 15, TRUE)
		to_chat(mob, span_bluespaceanomaly("Пространство пало..."))

/obj/effect/anomaly/bluespace/tier4/collapse()
	new /datum/event/wormholes/anomaly()
	for(var/i = 1 to rand(3, 7))
		new /obj/effect/anomaly/bluespace/tier2(get_turf(locate(rand(1, world.maxx), rand(1, world.maxy), z)))

	var/list/turf/turfs = list()
	for(var/turf/simulated/turf in range(10, src))
		turfs.Add(turf)

	// swaps
	for(var/i = 1; i <= rand(40, 50); ++i)
		var/turf/T1 = pick(turfs)
		var/turf/T2 = pick(turfs)

		var/dir1 = T1.dir
		var/icon_state1 = T1.icon_state
		var/icon1 = T1.icon
		T2.dir = dir1
		T2.icon = icon1
		T2.icon_state = icon_state1

		var/list/C1 = list()
		for(var/atom/movable/movable_atom in T1)
			if(isturf(movable_atom.loc))
				C1.Add(movable_atom)

		var/list/C2 = list()
		for(var/atom/movable/movable_atom in T2)
			if(isturf(movable_atom.loc))
				C2.Add(movable_atom)

		for(var/atom/movable/movable_atom in C1)
			if(isturf(movable_atom.loc))
				movable_atom.forceMove(T2)

		for(var/atom/movable/movable_atom in C2)
			if(isturf(movable_atom.loc))
				movable_atom.forceMove(T2)

		C1 = list()
		C2 = list()
		for(var/V in T1.vars)
			if(!(V in list("type", "loc", "locs", "vars", "parent", "parent_type", "verbs", "ckey", "key", "x", "y", "z", "destination_z", "destination_x", "destination_y", "contents", "luminosity", "group")))
				C1[V] = T1.vars[V]

		for(var/V in T2.vars)
			if(!(V in list("type", "loc", "locs", "vars", "parent", "parent_type", "verbs", "ckey", "key", "x", "y", "z", "destination_z", "destination_x", "destination_y", "contents", "luminosity", "group")))
				C2[V] = T2.vars[V]

		var/type1 = T1.type
		var/type2 = T2.type
		T2.ChangeTurf(type1)
		T1.ChangeTurf(type2)

	. = ..()

/obj/effect/anomaly/bluespace/tier4/teleport(atom/movable/target, radius)
	if(target.anchored && target != src || isobserver(target) || iseffect(target))
		return

	var/turf/start = get_turf(src)
	var/try_x = start.x + rand(-radius, radius)
	var/try_y = start.y + rand(-radius, radius)
	try_x = clamp(try_x, 1, world.maxx)
	try_y = clamp(try_y, 1, world.maxy)
	var/z = start.z
	if(prob(10) && !isanomaly(target))
		var/list/possible_z = list()
		for(var/i in 1 to world.maxz)
			if(is_admin_level(i) || is_away_level(i) || is_taipan(i) || !is_teleport_allowed(i))
				continue

			possible_z.Add(i)

		z = pick(possible_z)

	var/turf/tp_pos = get_turf(locate(try_x, try_y, z))
	do_teleport(target, tp_pos, asoundin = 'sound/effects/phasein.ogg')
	if(isliving(target))
		investigate_log("teleported [key_name_log(target)] to [COORD(target)]", INVESTIGATE_TELEPORTATION)
