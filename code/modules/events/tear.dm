/**
 * Dimensional tear event.
 *
 * On triggering, nearby machines and lights flicker. After a few seconds,
 * nearby machines and lights break. A [/obj/effect/tear] appears, spawning up
 * to 10 random hell mobs including a guaranteed tear hellhound, then disappears.
 */
/datum/event/tear
	name = "dimensional tear"
	announceWhen = 6
	endWhen = 14
	var/notify_title = "Пространственный разрыв"
	var/notify_image = "hellhound"

	var/obj/effect/tear/TE

/datum/event/tear/setup()
	impact_area = findEventArea()

/datum/event/tear/start()
	if(isnull(impact_area))
		log_debug("No valid event areas could be generated for dimensional tear.")
	var/list/area_turfs = get_area_turfs(impact_area)
	while(length(area_turfs))
		var/turf/turf = pick_n_take(area_turfs)
		if(turf.is_blocked_turf())
			continue

		// Give ghosts some time to jump there before it begins.
		var/image/alert_overlay = image('icons/mob/animal.dmi', notify_image)
		notify_ghosts("[notify_title] вот-вот откроется в [get_area(turf)].", title = notify_title, source = turf, alert_overlay = alert_overlay, flashwindow = FALSE, action = NOTIFY_FOLLOW)
		addtimer(CALLBACK(src, PROC_REF(spawn_tear), turf), 4 SECONDS)
		// Energy overload; we mess with machines as an early warning and for extra spookiness.
		for(var/obj/machinery/machinery in range(8, turf))
			INVOKE_ASYNC(machinery, TYPE_PROC_REF(/atom, get_spooked))

		return

	log_debug("dimensional tear failed to find a valid turf in [impact_area]")

/datum/event/tear/proc/spawn_tear(location)
	TE = new /obj/effect/tear(location)

/datum/event/tear/announce(false_alarm)
	var/area/target_area = impact_area
	if(!target_area)
		if(false_alarm)
			target_area = findEventArea()
			if(isnull(target_area))
				log_debug("Tried to announce a false-alarm tear without a valid area!")
				kill()
		else
			log_debug("Tried to announce a tear without a valid area!")
			kill()
			return
	GLOB.minor_announcement.announce(
		"На борту станции зафиксирован пространственно-временной разрыв. Предполагаемая локация: [target_area.name].",
		ANNOUNCE_ANOMALY_RU,
		'sound/AI/anomaly.ogg'
	)

/datum/event/tear/end()
	if(TE)
		qdel(TE)

/// The portal used in the [/datum/event/tear] midround.
/obj/effect/tear
	name = "dimensional tear"
	desc = "Пространственно-временной разрыв."
	icon = 'icons/effects/tear.dmi'
	icon_state = "tear"
	light_range = 3

	// Huge sprite, we shift it to make it look more natural.
	pixel_x = -106
	pixel_y = -96

	/// What the leader of the dimensional tear will be
	var/leader = /mob/living/simple_animal/hostile/hellhound/tear
	var/spawn_max = 0
	var/spawn_total = 0
	var/list/possible_mobs = list(
		/mob/living/simple_animal/hostile/hellhound,
		/mob/living/simple_animal/hostile/skeleton,
		/mob/living/simple_animal/hostile/netherworld,
		/mob/living/simple_animal/hostile/netherworld/migo,
		/mob/living/simple_animal/hostile/faithless)

/obj/effect/tear/get_ru_names()
	return list(
		NOMINATIVE = "пространственный разрыв",
		GENITIVE = "пространственного разрыва",
		DATIVE = "пространственному разрыву",
		ACCUSATIVE = "пространственный разрыв",
		INSTRUMENTAL = "пространственным разрывом",
		PREPOSITIONAL = "пространственном разрыве"
	)

/obj/effect/tear/Initialize(mapload)
	. = ..()
	spawn_max = roll(6) + 3
	warn_environment()
	addtimer(CALLBACK(src, PROC_REF(spawn_next_mob)), 2 SECONDS)

/obj/effect/tear/proc/warn_environment()
	// Sound cue to warn people nearby.
	playsound(get_turf(src), 'sound/magic/drum_heartbeat.ogg', 100)

	// We break some of those flickering consoles from earlier.
	// Mirrors as well, for the extra bad luck.
	for(var/obj/machinery/computer/computer in range(6, src))
		computer.obj_break()
	for(var/obj/structure/mirror/mirror in range(6, src))
		mirror.obj_break()
	for(var/obj/machinery/light/light in range(4, src))
		light.break_light_tube()

// We spawn a leader mob to make the portal actually dangerous.
/obj/effect/tear/proc/spawn_leader()
	if(!leader)
		return
	var/mob/mob = new leader(get_turf(src))
	playsound(mob, 'sound/goonstation/voice/growl2.ogg', 100)
	visible_message(span_danger("С оглушительным рёвом, [mob.declent_ru(NOMINATIVE)] выход[pluralize_ru(mob.gender, "ит", "ят")] из портала!"))

/obj/effect/tear/proc/spawn_next_mob()
	spawn_total++

	if(spawn_total < spawn_max)
		make_mob(pick(possible_mobs))
		addtimer(CALLBACK(src, PROC_REF(spawn_next_mob)), 2 SECONDS)
	else
		spawn_leader()

/obj/effect/tear/proc/make_mob(mob_type)
	var/mob/mob = new mob_type(get_turf(src))
	mob.faction = list("rift")
	step(mob, pick(GLOB.cardinal))
	if(prob(30))
		visible_message(span_danger("[capitalize(mob.declent_ru(NOMINATIVE))] выход[pluralize_ru(mob.gender, "ит", "ят")] из портала!"))
