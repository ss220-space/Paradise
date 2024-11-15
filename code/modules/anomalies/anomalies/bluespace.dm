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
	if(target.anchored && target != src)
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

/obj/effect/anomaly/bluespace/mob_touch_effect(mob/living/M)
	..()
	var/radius = bump_tp_min + round((bump_tp_max - bump_tp_min) * get_strenght() / 100)
	teleport(M, radius)
	return FALSE

/obj/effect/anomaly/bluespace/item_touch_effect(obj/item/I)
	..()
	var/radius = bump_tp_min + round((bump_tp_max - bump_tp_min) * get_strenght() / 100)
	teleport(I, radius)
	return FALSE

/obj/effect/anomaly/bluespace/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	var/radius = bump_tp_min + round((bump_tp_max - bump_tp_min) * get_strenght() / 100)
	teleport(user, radius)

/obj/effect/anomaly/bluespace/collapse()
	for(var/atom/movable/atom in range(collapse_radius))
		teleport(atom, collapse_tp_radius)

	. = ..()

/obj/effect/anomaly/bluespace/tier1
	name = "малая блюспейс аномалия"
	ru_names = list(NOMINATIVE = "малая ​​блюспейс аномалия", \
					GENITIVE = "малой ​​блюспейс аномалии", \
					DATIVE = "малой ​​блюспейс аномалии", \
					ACCUSATIVE = "малую ​​блюспейс аномалию", \
					INSTRUMENTAL = "малой ​​блюспейс аномалией", \
					PREPOSITIONAL = "малой ​​блюспейс аномалии")
	icon_state = "bluespace1"
	core_type = /obj/item/assembly/signaler/anomaly/tier1/bluespace
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
	ru_names = list(NOMINATIVE = "​​блюспейс аномалия", \
					GENITIVE = "​​блюспейс аномалии", \
					DATIVE = "​​блюспейс аномалии", \
					ACCUSATIVE = "​​блюспейс аномалию", \
					INSTRUMENTAL = "​​блюспейс аномалией", \
					PREPOSITIONAL = "​​блюспейс аномалии")
	icon_state = "bluespace2"
	core_type = /obj/item/assembly/signaler/anomaly/tier2/bluespace
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
	ru_names = list(NOMINATIVE = "большая ​​блюспейс аномалия", \
					GENITIVE = "большой ​​блюспейс аномалии", \
					DATIVE = "большой ​​блюспейс аномалии", \
					ACCUSATIVE = "большую ​​блюспейс аномалию", \
					INSTRUMENTAL = "большой ​​блюспейс аномалией", \
					PREPOSITIONAL = "большой ​​блюспейс аномалии")
	icon_state = "bluespace3"
	core_type = /obj/item/assembly/signaler/anomaly/tier3/bluespace
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
	for(var/mob/living/M in GLOB.player_list)
		if(M.stat)
			continue

		M.playsound_local(null,'sound/effects/explosionfar.ogg', 15, TRUE)
		to_chat(M, "<span class='bluespace_anomaly'>Вы слышите страшный треск! Это что... трещит пространство?</span>") // It used in one place.

/obj/effect/anomaly/bluespace/tier3/collapse()
	new /datum/event/wormholes/anomaly()
	for(var/i = 1 to rand(0, 5))
		new /obj/effect/anomaly/bluespace/tier1(get_turf(locate(rand(1, world.maxx), rand(1, world.maxy), z)))

	. = ..()
