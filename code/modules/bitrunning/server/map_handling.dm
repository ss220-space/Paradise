#define POLLING_COOLDOWN_TIME 2 MINUTES

/obj/machinery/quantum_server/proc/cold_boot_map(map_key, was_random_selection = FALSE)
	if(!is_ready)
		return FALSE

	if(isnull(map_key))
		balloon_alert_to_viewers("домен не выбран!")
		return FALSE

	if(generated_domain)
		balloon_alert_to_viewers("сначала остановите домен!")
		return FALSE

	if(length(avatar_connection_refs))
		balloon_alert_to_viewers("сначала отключите всех!")
		return FALSE

	is_ready = FALSE
	playsound(src, 'sound/machines/terminal_processing.ogg', 30, TRUE)

	if(!load_domain(map_key) || !load_map_items() || !load_mob_segments())
		balloon_alert_to_viewers("сбой инициализации!")
		scrub_vdom()
		is_ready = TRUE
		return FALSE

	is_ready = TRUE
	domain_randomized = was_random_selection

	if(prob(clamp(threat * glitch_chance, 5, threat_prob_max)))
		INVOKE_ASYNC(src, PROC_REF(setup_glitch))

	points -= generated_domain.cost
	generated_domain.start_time = world.time

	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 30, TRUE)
	balloon_alert_to_viewers("домен загружен")
	update_use_power(ACTIVE_POWER_USE)
	update_appearance()

	if(generated_domain.announce_to_ghosts)
		notify_ghosts("Битраннеры загрузили домен, в котором есть роли для наблюдателей.", source = src, title = "Matrix Glitch")

	return TRUE

/obj/machinery/quantum_server/proc/load_domain(map_key)
	for(var/datum/lazy_template/virtual_domain/available as anything in get_virtual_domains())
		if(map_key == available.key && points >= available.cost)
			generated_domain = available
			break

	if(isnull(generated_domain))
		return FALSE

	if(generated_domain.mission_min_candidates && !poll_advanced_npcs())
		generated_domain = null
		return FALSE

	RegisterSignal(generated_domain, COMSIG_LAZY_TEMPLATE_LOADED, PROC_REF(on_template_loaded))
	domain_reservation = generated_domain.lazy_load()
	if(isnull(domain_reservation))
		generated_domain = null
		polled_ghosts = null
		return FALSE

	return TRUE

/obj/machinery/quantum_server/proc/poll_advanced_npcs()
	if(!COOLDOWN_FINISHED(src, polling_cooldown))
		atom_say("Алгоритмы продвинутых NPC перезапускаются, подождите или выберите другой домен.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return FALSE

	playsound(src, 'sound/machines/chime.ogg', 50, TRUE)
	atom_say("Загрузка продвинутых NPC...")

	var/list/mob/candidates = SSghost_spawns.poll_candidates(
		question = "Хотите сыграть за [generated_domain.spawner_role] в домене битраннеров?",
		role = ROLE_GHOST,
		poll_time = 15 SECONDS,
		source = src,
		role_cleanname = generated_domain.spawner_role,
	)

	for(var/amount in 1 to generated_domain.mission_max_candidates)
		if(!length(candidates))
			break
		LAZYADD(polled_ghosts, pick_n_take(candidates))

	if(length(polled_ghosts) < generated_domain.mission_min_candidates)
		notify_ghosts("Не хватило кандидатов на роль [generated_domain.spawner_role]! Запуск отменён.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		atom_say("Ошибка. Не удалось загрузить продвинутых NPC.")
		COOLDOWN_START(src, polling_cooldown, POLLING_COOLDOWN_TIME)
		polled_ghosts = null
		return FALSE

	playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
	atom_say("Готово.")
	return TRUE

/obj/machinery/quantum_server/proc/load_map_items()
	var/list/obj/effect/landmark/bitrunning/found_landmarks = list()
	var/list/turf/cache_turfs = list()
	var/list/turf/curiosity_turfs = list()

	for(var/turf/tile as anything in domain_reservation.reserved_turfs)
		for(var/obj/modular_map_root/root in tile)
			root.load_module()

	for(var/turf/tile as anything in domain_reservation.reserved_turfs)
		for(var/obj/effect/landmark/bitrunning/landmark in tile)
			found_landmarks += landmark
		for(var/obj/effect/mob_spawn/spawner in tile)
			LAZYADD(generated_domain.ghost_spawners, spawner)
			RegisterSignal(spawner, COMSIG_BITRUNNER_SPAWNED, PROC_REF(on_threat_created))

	for(var/obj/effect/landmark/bitrunning/landmark as anything in found_landmarks)
		var/turf/tile = get_turf(landmark)

		if(istype(landmark, /obj/effect/landmark/bitrunning/mob_segment))
			continue

		if(istype(landmark, /obj/effect/landmark/bitrunning/hololadder_spawn))
			exit_turfs += tile

		else if(istype(landmark, /obj/effect/landmark/bitrunning/permanent_exit))
			exit_turfs += tile
			new /obj/structure/hololadder(tile, src)

		else if(istype(landmark, /obj/effect/landmark/bitrunning/cache_goal_turf))
			goal_turfs += tile
			RegisterSignal(tile, COMSIG_ATOM_ENTERED, PROC_REF(on_goal_turf_entered))
			RegisterSignal(tile, COMSIG_ATOM_EXAMINE, PROC_REF(on_goal_turf_examined))

		else if(istype(landmark, /obj/effect/landmark/bitrunning/cache_spawn))
			cache_turfs += tile

		else if(istype(landmark, /obj/effect/landmark/bitrunning/curiosity_spawn))
			curiosity_turfs += tile

		else if(istype(landmark, /obj/effect/landmark/bitrunning/loot_signal))
			generated_domain.main_crate_loc = tile

		qdel(landmark)

	if(!length(exit_turfs))
		stack_trace("vdom: no exit turfs on [generated_domain.key]")
		return FALSE

	if(!length(goal_turfs))
		stack_trace("vdom: no goal turfs on [generated_domain.key]")
		return FALSE

	collect_mutation_candidates()
	spawn_curiosities(curiosity_turfs)

	if(length(polled_ghosts))
		generated_domain.load_advanced_npcs(polled_ghosts)
		polled_ghosts = null

	generated_domain.setup_domain(domain_reservation.reserved_turfs)

	if(generated_domain.main_crate_loc)
		return TRUE

	return attempt_spawn_cache(cache_turfs)

/obj/machinery/quantum_server/proc/load_mob_segments()
	if(!length(generated_domain.mob_modules))
		return TRUE

	var/current_index = 1
	shuffle_inplace(generated_domain.mob_modules)

	for(var/turf/tile as anything in domain_reservation.reserved_turfs)
		for(var/obj/effect/landmark/bitrunning/mob_segment/landmark in tile)
			if(current_index > length(generated_domain.mob_modules))
				stack_trace("vdom: mob segments are set to unique, but there are more landmarks than available segments")
				return FALSE

			var/path
			if(generated_domain.modular_unique_mobs)
				path = generated_domain.mob_modules[current_index]
				current_index += 1
			else
				path = pick(generated_domain.mob_modules)

			var/datum/modular_mob_segment/segment = new path()
			mutation_candidate_refs += landmark.spawn_mobs(tile, segment)

			qdel(landmark)
			qdel(segment)

	return TRUE

/obj/machinery/quantum_server/proc/begin_shutdown(mob/living/user)
	if(isnull(generated_domain))
		return

	if(!length(avatar_connection_refs))
		balloon_alert_to_viewers("отключение домена...")
		playsound(src, 'sound/machines/terminal_off.ogg', 40, TRUE)
		reset()
		return

	balloon_alert_to_viewers("оповещение клиентов...")
	playsound(src, 'sound/machines/terminal_alert.ogg', 100, TRUE)
	user.visible_message(
		span_danger("[user] начинает обесточивать [declent_ru(ACCUSATIVE)]!"),
		span_notice("Вы начинаете отключать клиентов..."),
		span_danger("Вы слышите быстрый стук по клавиатуре."),
	)

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SHUTDOWN_ALERT, user)

	if(!do_after(user, 20 SECONDS, src))
		return

	reset()

/obj/machinery/quantum_server/proc/reset()
	is_ready = FALSE
	domain_complete = FALSE
	domain_randomized = FALSE
	retries_spent = 0

	sever_connections()
	notify_spawned_threats()

	addtimer(CALLBACK(src, PROC_REF(scrub_vdom)), 15 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(cool_off)), round(server_cooldown_time * capacitor_coefficient), TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_DELETE_ME)

	update_use_power(IDLE_POWER_USE)
	update_appearance()

/obj/machinery/quantum_server/proc/scrub_vdom()
	sever_connections()
	SEND_SIGNAL(src, COMSIG_BITRUNNER_DOMAIN_SCRUBBED)

	for(var/turf/tile as anything in goal_turfs)
		UnregisterSignal(tile, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXAMINE))

	for(var/datum/weakref/creature_ref as anything in spawned_threat_refs + mutation_candidate_refs)
		var/mob/living/creature = creature_ref?.resolve()
		if(isnull(creature))
			continue

		qdel(creature)

	if(domain_reservation)
		for(var/turf/tile as anything in domain_reservation.reserved_turfs)
			tile.empty()
		generated_domain?.reservations -= domain_reservation
		QDEL_NULL(domain_reservation)

	if(generated_domain)
		generated_domain.secondary_loot_generated = 0
		generated_domain.main_crate_points = 0
		generated_domain.main_crate_loc = null
		generated_domain.ghost_spawners = null
		generated_domain.ghost_mobs = null

	avatar_connection_refs.Cut()
	mutation_candidate_refs.Cut()
	spawned_threat_refs.Cut()
	exit_turfs.Cut()
	goal_turfs.Cut()
	polled_ghosts = null
	generated_domain = null

	update_use_power(IDLE_POWER_USE)
	update_appearance()

#undef POLLING_COOLDOWN_TIME
