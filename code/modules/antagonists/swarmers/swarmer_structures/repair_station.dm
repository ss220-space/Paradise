/// How long does it take to enter a repair station
#define SWARMER_REPAIR_STATION_DELAY 2 SECONDS
/// How much a swarmer gets healed by while being in a repair station per tick
#define SWARMER_REPAIR_STATION_HEAL 5

/**
 * Swarmer repair station
 *
 * Slowly repairs swarmer inside.
 */
/obj/structure/swarmer/repair_station
	name = "swarmer repair station"
	desc = "Ремонтная станция \"Свармеров\"."
	swarmer_examine = "Войти в ремонтную станцию можно с помощью нажатия на него в интенте \"Помощь\"."
	icon_state = "repair_station"
	max_integrity = 100
	/// Current swarmer in src
	var/mob/living/simple_animal/occupant
	/// Turf occupant entered from
	var/turf/enter_turf
	/// How much a swarmer gets healed per tick
	var/heal_per_tick = SWARMER_REPAIR_STATION_HEAL

/obj/structure/swarmer/repair_station/Destroy(force)
	go_out()
	if(datum_flags & DF_ISPROCESSING)
		STOP_PROCESSING(SSobj, src)
	return ..()

// Just kicks the swarmer out of the repair station on strong emp.
/obj/structure/swarmer/repair_station/emp_act(severity)
	..()
	if(!occupant)
		return
	if(severity <= 1)
		return
	go_out()

// Updates icon state based on occupant var
/obj/structure/swarmer/repair_station/update_icon_state()
	icon_state = occupant ? "[initial(icon_state)]_a" : initial(icon_state)

// Updates overlays based on occupant
/obj/structure/swarmer/repair_station/update_overlays()
	. = ..()
	if(!occupant)
		return .
	var/image/swarmer_image = image(icon = occupant.icon, icon_state = occupant.icon_state, layer = ABOVE_MOB_LAYER, dir = SOUTH)
	var/image/repair_image = image(icon = 'icons/effects/swarmer.dmi', icon_state = "repair_effect", layer = ABOVE_ALL_MOB_LAYER)
	. += swarmer_image
	. += repair_image

// Main enter proc
/obj/structure/swarmer/repair_station/swarmer_help_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	. = ..()
	if(!.)
		return
	if(occupant)
		swarmer.balloon_alert(swarmer, "занято!")
		return
	swarmer.balloon_alert(swarmer, "входим...")
	if(!do_after(swarmer, SWARMER_REPAIR_STATION_DELAY, src, max_interact_count = 1))
		swarmer.balloon_alert(swarmer, "сбито!")
		return
	enter_turf = get_turf(swarmer)
	swarmer.forceMove(src)
	occupant = swarmer
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	START_PROCESSING(SSobj, src)

/obj/structure/swarmer/repair_station/swarmer_disarm_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	if(!occupant)
		return ..()

	swarmer.balloon_alert(swarmer, "занято, не починить!")

/obj/structure/swarmer/repair_station/swarmer_grab_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	if(!occupant)
		return ..()

	swarmer.balloon_alert(swarmer, "занято, не открепить!")

/obj/structure/swarmer/repair_station/swarmer_harm_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	if(!occupant)
		return ..()

	swarmer.balloon_alert(swarmer, "занято, не уничтожить!")

/obj/structure/swarmer/repair_station/process(seconds_per_tick)
	if(QDELETED(occupant))
		occupant = null
		update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
		return PROCESS_KILL
	if(!(locate(occupant) in src)) // Extra precaution
		occupant = null
		update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
		return PROCESS_KILL
	if(occupant.health == occupant.maxHealth) // Prevent afkers in repair stations
		to_chat(occupant, span_notice("Мы полностью вылечены! Выходим из ремонтной станции..."))
		go_out()
		return
	occupant.adjustHealth(-heal_per_tick)

/obj/structure/swarmer/repair_station/relaymove()
	go_out()

/// Exit repair station procs
/obj/structure/swarmer/repair_station/proc/go_out()
	if(!occupant)
		enter_turf = null
		return
	occupant.forceMove(enter_turf)
	occupant = null
	enter_turf = null
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	STOP_PROCESSING(SSobj, src)

/obj/structure/swarmer/repair_station/get_ru_names()
	return alist(
		NOMINATIVE = "станция починки \"Свармеров\"",
		GENITIVE = "станции починки \"Свармеров\"",
		DATIVE = "станции починки \"Свармеров\"",
		ACCUSATIVE = "станцию починки \"Свармеров\"",
		INSTRUMENTAL = "станцией починки \"Свармеров\"",
		PREPOSITIONAL = "станции починки \"Свармеров\""
	)

#undef SWARMER_REPAIR_STATION_DELAY
#undef SWARMER_REPAIR_STATION_HEAL
