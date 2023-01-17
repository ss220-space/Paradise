//Bluespace rift for create fun and running around the station
/obj/brs_rift
	name = "Блюспейс Разлом"
	desc = "Аномальное образование с неизвестными свойствами загадочного синего космоса."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_fog"
	anchored = TRUE
	density = FALSE
	luminosity = TRUE
	simulated = FALSE
	move_resist = INFINITY
	appearance_flags = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	layer = MASSIVE_OBJ_LAYER
	alpha = 180

	//	to show from T-ray scanner
	invisibility = INVISIBILITY_ANOMALY
	level = 1

	var/timespan = 20 MINUTES		// direction change time
	var/required_time_per_tile = 0	// time required before moving to a tile
	var/counter_direction_time		// time counter before change of direction
	var/counter_move_time 			// time counter before movement

	var/force_sized = 5		// size of rift and critical zone
	var/dir_move = 0		// direction move
	var/dir_loc = null		// location of direction

	var/type_rift = DEFAULT_RIFT
	var/num_related_rifts = 1	// How many rifts can be related
	var/related_rifts_list = list()	// ex. twin rifts
	var/anomaly_mod = 1.5		//	Event container modifier
	var/event_chance = 100		//	Chance of occurrence of events to avoid flooding events

/obj/brs_rift/crack
	name = "Блюспейс Трещина"
	type_rift = CRACK_RIFT
	force_sized = 1
	timespan = 10 MINUTES
	num_related_rifts = 4

/obj/brs_rift/twin
	name = "Разлом-Близнец"
	type_rift = TWINS_RIFT
	force_sized = 3
	timespan = 15 MINUTES
	num_related_rifts = 2

/obj/brs_rift/big
	name = "Блюспейс Жерло"
	type_rift = BIG_RIFT
	force_sized = 7
	timespan = 25 MINUTES

/obj/brs_rift/fog
	name = "Блюспейс Туманность"
	type_rift = FOG_RIFT
	force_sized = 9
	timespan = 30 MINUTES

/obj/brs_rift/hunter
	name = "Блюспейс Трещина"
	type_rift = CRACK_RIFT
	force_sized = 1
	timespan = 10 MINUTES
	num_related_rifts = 4

/obj/brs_rift/hunter
	name = "Разлом-Охотник"
	type_rift = HUNTER_RIFT
	timespan = 1 MINUTES	// The hunter's time is redefined depending on the distance to the target
	force_sized = 3
	var/mob/dir_mob = null	// mob to which rift directed


//For tests and pampering
/obj/brs_rift/twin/test_static
	name = "Статичный Разлом-Близнец"
	timespan = 60 MINUTES
	invisibility = 0
	alpha = 255

/obj/brs_rift/hunter/test_visible
	name = "Видимый Разлом-Охотник"
	invisibility = 0
	alpha = 255


/obj/brs_rift/Initialize(mapload)
	. = ..()
	GLOB.poi_list |= src
	GLOB.bluespace_rifts_list.Add(src)
	START_PROCESSING(SSobj, src)

	transform = matrix(force_sized, 0, 0, 0, force_sized, 0) //+ перекрас?
	name = "[name] [length(GLOB.golem_female) ? "тип: \"[pick(GLOB.golem_female)]\"" : "неизвестного типа"]"

	if (length(related_rifts_list) <= 1)
		make_related_list(num_related_rifts, type_rift)

	change_move_direction()
	change_anomaly_chance(anomaly_mod, 1)

	var/count = length(GLOB.bluespace_rifts_list)
	notify_ghosts("[name] возникло на станции! Всего разломов: [count]", title = "Блюспейс Разлом!", source = src, action = NOTIFY_FOLLOW)

/obj/brs_rift/Destroy()
	GLOB.bluespace_rifts_list.Remove(src)
	GLOB.poi_list.Remove(src)
	STOP_PROCESSING(SSobj, src)
	change_anomaly_chance(anomaly_mod, 0)
	return ..()

/obj/brs_rift/process()
	move_direction()

/obj/brs_rift/proc/event_process(var/is_critical = FALSE, var/dist = 1, var/rift_range = 1)
	var/division = round(force_sized * (1 - max(1, dist) / rift_range))

	if(prob(event_chance))
		event_chance = min(5, event_chance - (15 + division))
	else
		event_chance = max(100, event_chance + 5)
		return FALSE

	var/event_type = is_critical ? BRS_EVENT_CRITICAL : random_event_type(dist, rift_range)

	// give the chances of a regular event appearing frequently with a local event
	if(!is_critical && prob(70))
		make_event(event_type)
	if(!is_critical && prob(50))
		return FALSE
	if (prob(round(100 * max(1, length(related_rifts_list))/4)))
		make_local_related_event()
	else
		make_local_event()
	return TRUE

/obj/brs_rift/proc/make_event(var/type)
	var/datum/event_container/container = SSevents.brs_event_containers[type]
	var/datum/event_meta/event_meta = container.acquire_event()
	new event_meta.event_type(event_meta)

	//Возвращаем ивент в контейнер и изменяем веса прочих ивентов
	for(var/datum/event_meta/temp_meta in container.available_events)
		temp_meta.weight += 5
	event_meta.weight = max(0, event_meta.weight - 10)
	container.available_events.Add(event_meta)

/obj/brs_rift/proc/make_local_event()
	choose_random_event(related_rifts_list)

/obj/brs_rift/proc/make_local_related_event()
	var/list/objects_range = list()
	for(var/obj/brs_rift/rift in related_rifts_list)
		var/list/temp_range = range(round(force_sized * 2), src)
		for(var/i in temp_range)
			objects_range.Add(i)
	choose_random_related_event(objects_range)

/obj/brs_rift/proc/random_event_type(var/dist, var/rift_range, var/division)
	var/chance = rand(0, 100)
	var/n = division
	if(chance <= (49-n*3))
		return BRS_EVENT_MESS
	else if(chance >= (50-n*3) && chance <=  (79-n*2))
		return BRS_EVENT_MINOR
	else if(chance >= (80-n*2) && chance <=  (94-n))
		return BRS_EVENT_MAJOR
	else if(chance >= (95-n))
		return BRS_EVENT_CRITICAL

/obj/brs_rift/proc/move_direction()
	if(counter_move_time < world.time)
		forceMove(get_step(src, dir_move))
		counter_move_time = world.time + required_time_per_tile
		dir_move = get_dir(src.loc, dir_loc)

	if(counter_direction_time < world.time || extra_condition())
		change_move_direction()

/obj/brs_rift/proc/change_move_direction()
	counter_direction_time = world.time + timespan
	counter_move_time = world.time + required_time_per_tile

	dir_loc = get_random_loc()
	dir_move = get_dir(src, dir_loc)

	var/dist = get_dist(src, dir_loc) + 1
	required_time_per_tile = round(timespan/dist)

/obj/brs_rift/proc/get_random_loc()
	return find_safe_turf(zlevels = src.z)

/obj/brs_rift/attackby(obj/item/I, mob/living/user, params)
	to_chat(user, "<span class='danger'>Невозможно взаимодействовать с разломом!</span>")
	return FALSE

//Working with weight in containers
/obj/brs_rift/proc/change_anomaly_chance(var/mod, var/multi = TRUE)
	var/list/modif_list = list(
			/datum/event/anomaly/anomaly_pyro,
			/datum/event/anomaly/anomaly_vortex,
			/datum/event/anomaly/anomaly_bluespace,
			/datum/event/anomaly/anomaly_flux,
			/datum/event/anomaly/anomaly_grav,
			/datum/event/tear,
			/datum/event/mass_hallucination,
			/datum/event/wormholes
		)

	for(var/datum/event_container/container in SSevents.event_containers)
		for(var/datum/event_meta/M in container.available_events)
			if(M.event_type in modif_list)
				if (multi)
					M.weight_mod *= mod
				else
					M.weight_mod /= mod

/obj/brs_rift/proc/make_related_list(var/num = 1, var/type_rift)
	var/list/temp_list = list()
	temp_list.Add(src)
	var/temp_colour = rand_hex_color()
	color = temp_colour

	if(num <= 1)
		related_rifts_list = temp_list
		return

	for(var/obj/brs_rift/rift in GLOB.bluespace_rifts_list)
		if (rift.type_rift == type_rift && rift != src)
			if (length(rift.related_rifts_list) >= num)
				continue
			temp_list.Add(rift)
			if(length(temp_list) >= num)
				break

	related_rifts_list = temp_list
	for(var/obj/brs_rift/rift in related_rifts_list)
		rift.related_rifts_list = related_rifts_list
		rift.color = temp_colour

/obj/brs_rift/proc/extra_condition()
	return FALSE

/obj/brs_rift/hunter/extra_condition()
	if (dir_loc != dir_mob.loc)
		return TRUE
	return FALSE

//The hunter selects a mob and sets the speed on it
/obj/brs_rift/hunter/get_random_loc()
	var/turf/T = (dir_mob && dir_mob.z == z) ? dir_mob.loc : null
	if(!T || prob(5) || counter_direction_time < world.time)
		dir_mob = null
	if(!dir_mob)
		for(var/mob/M in GLOB.player_list)
			if(M.z != z || !M.client)
				continue
			if(prob(50))	//Not every prey is worthy of the hunt
				continue
			dir_mob = M
			T = M.loc
			break

	//The hunter moves faster and doesn't stupefy if the target is close
	timespan = (get_dist(src, T) SECONDS) + 10 SECONDS
	return T ? T : ..()
