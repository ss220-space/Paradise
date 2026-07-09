#define DELAM_MAX_DEVASTATION 17.5

// These are supposed to be discrete effects so we can tell at a glance what does each override
// of [/datum/sm_delam/proc/delaminate] does.
// Please keep them discrete and give them proper, descriptive function names.
// Oh and all of them returns true if the effect succeeded.

/// Irradiates mobs around 20 tiles of the sm.
/// Just the mobs apparently.
/datum/sm_delam/proc/effect_irradiate(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	var/datum/controller/subsystem/radiation/cached_SSradiation = SSradiation
	for(var/mob/living/victim in range(DETONATION_RADIATION_RANGE, sm))
		if(!is_valid_z_level(get_turf(victim), sm_turf))
			continue
		if(victim.z == 0)
			continue
		cached_SSradiation.irradiate(victim)
	return TRUE

/// Hallucinates and makes mobs in Z level sad.
/datum/sm_delam/proc/effect_demoralize(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	for(var/mob/living/victim as anything in GLOB.alive_mob_list)
		if(!istype(victim) || !is_valid_z_level(get_turf(victim), sm_turf))
			continue
		if(victim.z == 0)
			continue

		//Hilariously enough, running into a closet should make you get hit the hardest.
		//duration between min and max, calculated by distance from the supermatter and size of the delam explosion
		var/hallucination_amount = LERP(DETONATION_HALLUCINATION_MIN, DETONATION_HALLUCINATION_MAX, 1 - get_dist(victim, sm) / 128) * LERP(0.75, 1.25, calculate_explosion(sm) * 0.5 / DELAM_MAX_DEVASTATION)
		victim.AdjustHallucinate(hallucination_amount)

	for(var/mob/victim as anything in GLOB.player_list)
		var/turf/victim_turf = get_turf(victim)
		if(!is_valid_z_level(victim_turf, sm_turf))
			continue
		victim.playsound_local(victim_turf, 'sound/magic/charge.ogg')
		if(victim.z == 0) //victim is inside an object, this is to maintain an old bug turned feature with lockers n shit i guess. tg issue #69687
			var/message = ""
			var/location = victim.loc
			if(istype(location, /obj/structure/disposalholder)) // sometimes your loc can be a disposalsholder when you're inside a disposals type, so let's just pass a message that makes sense.
				message = "Вы слышите громкое дребезжание в мусоропроводных трубах вокруг, пока сама реальность искажается. И всё же вы чувствуете себя в безопасности."
			else
				message = "Вы изо всех сил держитесь за [victim.loc.declent_ru(ACCUSATIVE)], пока реальность искажается вокруг вас. Вы чувствуете себя в безопасности."
			to_chat(victim, span_bolddanger(message))
			continue
		to_chat(victim, span_bolddanger("Вы чувствуете, как реальность на мгновение искажается..."))
		//if(isliving(victim))
		//	var/mob/living/living_victim = victim
		//	living_victim.add_mood_event("delam", /datum/mood_event/delam)
	return TRUE

/// Spawns anomalies all over the station. Half instantly, the other half over time.
/datum/sm_delam/proc/effect_anomaly(obj/machinery/power/supermatter_crystal/sm)
	var/anomalies = 10
	var/list/anomaly_types = list(GRAVITATIONAL_ANOMALY = 55, /*HALLUCINATION_ANOMALY = 45, DIMENSIONAL_ANOMALY = 35, BIOSCRAMBLER_ANOMALY = 35, */FLUX_ANOMALY = 20, PYRO_ANOMALY = 10, VORTEX_ANOMALY = 1)
	var/list/anomaly_places = GLOB.xeno_spawn // i'am sorry, it must be GLOB.generic_event_spawns - littleboobs

	// Spawns this many anomalies instantly. Spawns the rest with callbacks.
	var/cutoff_point = round(anomalies * 0.5, 1)

	for(var/i in 1 to anomalies)
		var/anomaly_to_spawn = pick_weight_classic(anomaly_types)
		var/anomaly_location = pick_n_take(anomaly_places)

		if(i < cutoff_point)
			supermatter_anomaly_gen(anomaly_location, anomaly_to_spawn, has_changed_lifespan = FALSE)
			continue

		var/current_spawn = rand(5 SECONDS, 10 SECONDS)
		var/next_spawn = rand(5 SECONDS, 10 SECONDS)
		var/extended_spawn = 0
		if(SPT_PROB(1, next_spawn))
			extended_spawn = rand(5 MINUTES, 15 MINUTES)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(supermatter_anomaly_gen), anomaly_location, anomaly_to_spawn, TRUE), current_spawn + extended_spawn)
	return TRUE

/// Explodes
/datum/sm_delam/proc/effect_explosion(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	explosion(
		epicenter = sm_turf,
		devastation_range = calculate_explosion(sm) * 0.5, // max 17.5
		heavy_impact_range = calculate_explosion(sm) + 2, // max 37
		light_impact_range = calculate_explosion(sm) + 4, // max 39
		flash_range = calculate_explosion(sm) + 6, //max 41
		adminlog = TRUE,
		ignorecap = TRUE,
	)
	return TRUE

/datum/sm_delam/proc/calculate_explosion(obj/machinery/power/supermatter_crystal/sm)
	return sm.explosion_power * max(sm.gas_heat_power_generation, 0.205)

/// Spawns a scrung and eat the SM.
/datum/sm_delam/proc/effect_singulo(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	if(!sm_turf)
		stack_trace("Supermatter [sm] failed to spawn singularity, cant get current turf.")
		return FALSE
	var/obj/singularity/created_singularity = new(sm_turf)
	created_singularity.energy = 800
	created_singularity.consume(sm)
	return TRUE

/// Teslas
/datum/sm_delam/proc/effect_tesla(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	if(!sm_turf)
		stack_trace("Supermatter [sm] failed to spawn tesla, cant get current turf.")
		return FALSE
	var/obj/energy_ball/created_tesla = new(sm_turf)
	created_tesla.energy = 200 //Gets us about 9 balls
	return TRUE

/// Mail the shuttle off to buy milk.
/datum/sm_delam/proc/effect_strand_shuttle()
	set waitfor = FALSE
	// set timer to infinity, so shuttle never arrives
	SSshuttle.emergency.setTimer(INFINITY)
	// disallow shuttle recalls, so people cannot cheese the timer
	SSshuttle.emergency_no_recall = TRUE
	// set supermatter cascade to true, to prevent auto evacuation due to no way of calling the shuttle
	SSshuttle.supermatter_cascade = TRUE
	//// set hijack completion timer to infinity, so that you cant prematurely end the round with a hijack
	//for(var/obj/machinery/computer/emergency_shuttle/console as anything in SSmachines.get_by_type(/obj/machinery/computer/emergency_shuttle))
	//	console.hijack_completion_flight_time_set = INFINITY

	/* This logic is to keep uncalled shuttles uncalled
	In SSshuttle, there is not much of a way to prevent shuttle calls, unless we mess with admin panel vars
	SHUTTLE_STRANDED is different here, because it *can* block the shuttle from being called, however if we don't register a hostile
	environment, it gets unset immediately. Internally, it checks if the count of HEs is zero
	and that the shuttle is in stranded mode, then frees it with an announcement.
	This is a botched solution to a problem that could be solved with a small change in shuttle code, however-
	*/
	if(SSshuttle.emergency.mode == SHUTTLE_IDLE)
		SSshuttle.emergency.mode = SHUTTLE_STRANDED
		SSshuttle.add_hostile_environment(src)
		return

	// say goodbye to that shuttle of yours
	if(SSshuttle.emergency.mode != SHUTTLE_ESCAPE)
		GLOB.major_announcement.announce(
			message = "Во время перехода произошла критическая ошибка в канале связи эвакуационного шаттла. Невозможно восстановить соединение.",
			new_title = "Сбой шаттла",
			new_sound = 'sound/misc/announce_dig.ogg',
		)
	else
	// except if you are on it already, then you are safe c:
		GLOB.minor_announcement.announce(
			message = "ОШИБКА: Обнаружено повреждение навигационных протоколов. Связь с транспондером #XCC-P5831-ES13 потеряна. Расшифрован протокол резервного маршрута эвакуации. Калибровка маршрута...",
			new_title = "Эвакуационный шаттл",
		)
		var/list/mobs = mobs_in_area_type(list(/area/shuttle/escape))
		for(var/mob/living/mob as anything in mobs) // emulate mob/living/lateShuttleMove() behaviour
			if(mob.buckled)
				continue
			if(mob.client)
				shake_camera(mob, 3 SECONDS * 0.25, 1)
			mob.Paralyse(3 SECONDS, TRUE)

/datum/sm_delam/proc/effect_cascade_demoralize()
	for(var/mob/player as anything in GLOB.player_list)
		if(!isdead(player))
			//var/mob/living/living_player = player
			to_chat(player, span_bolddanger("Всё вокруг вас резонирует с мощной энергией. Это не к добру."))
			//living_player.add_mood_event("cascade", /datum/mood_event/cascade)
		SEND_SOUND(player, 'sound/magic/charge.ogg')

/datum/sm_delam/proc/effect_emergency_state()
	if(SSsecurity_level.get_current_level_as_number() != SEC_LEVEL_DELTA)
		SSsecurity_level.set_level(SEC_LEVEL_DELTA) // skip the announcement and shuttle timer adjustment in set_security_level()
	SSmapping.make_station_all_access()
	for(var/obj/machinery/light/light_to_break as anything in SSmachines.get_by_type(/obj/machinery/light))
		if(prob(35))
			light_to_break.set_major_emergency_light()
			continue
		light_to_break.break_light_tube()

/// Spawn an evacuation rift for people to go through.
/datum/sm_delam/proc/effect_evac_rift_start()
	var/obj/cascade_portal/rift = new /obj/cascade_portal(get_turf(pick(GLOB.xeno_spawn)))
	GLOB.major_announcement.announce(
		message = "По нам ударил электромагнитный импульс, охвативший весь сектор. Все наши системы серьёзно повреждены, включая необходимые \
			для навигации шаттла. Мы можем сделать лишь один разумный вывод: на вашей станции или поблизости от неё происходит каскад суперматерии.\n\n\
			Эвакуация обычными средствами более невозможна; однако нам удалось открыть разлом возле [get_area_name(rift)]. \
			Всему персоналу настоящим предписывается войти в разлом любыми доступными способами.\n\n\
			[Gibberish("Эвакуация выживших будет проведена после восстановления необходимого оборудования.", 5)] \
			[Gibberish("Удачи", 25)]",
	)
	return rift

/// Announce the destruction of the rift and end the round.
/datum/sm_delam/proc/effect_evac_rift_end()
	effect_evac_rift_end_step1()

/datum/sm_delam/proc/effect_evac_rift_end_step1()
	GLOB.major_announcement.announce(
		message = "[Gibberish("Разлом уничтожен, мы больше не можем вам помочь.", 5)]",
	)
	addtimer(CALLBACK(src, PROC_REF(effect_evac_rift_end_step2)), 25 SECONDS)

/datum/sm_delam/proc/effect_evac_rift_end_step2()
	GLOB.major_announcement.announce(
		message = "Отчёты указывают на образование кристаллических зёрен после события резонансного сдвига. \
			Стремительное разрастание кристаллической массы пропорционально растущей гравитационной силе. \
			Предвидится коллапс материи под действием гравитационного притяжения.",
		new_title = "Ассоциация наблюдения за звёздами \"Нанотрейзен\"",
	)
	addtimer(CALLBACK(src, PROC_REF(effect_evac_rift_end_step3)), 25 SECONDS)

/datum/sm_delam/proc/effect_evac_rift_end_step3()
	GLOB.major_announcement.announce(
		message = "[Gibberish("Все попытки эвакуации прекращены, и все активы извлечены из вашего сектора.\n \
			Оставшимся выжившим [station_name()], прощайте.", 5)]",
	)

	if(SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
		var/shuttle_msg = "Навигационный протокол установлен на [SSshuttle.emergency.is_hijacked() ? "\[ОШИБКА\]" : "резервный маршрут"]. \
			Переориентация блюспейс-судна на вектор выхода. Расчётное время прибытия 15 секунд."
		if(SSshuttle.emergency.is_hijacked())
			shuttle_msg = Gibberish(shuttle_msg, TRUE, 15)
		GLOB.minor_announcement.announce(
			message = shuttle_msg,
			new_title = "Эвакуационный шаттл",
		)
		SSshuttle.emergency.setTimer(15 SECONDS)
		return

	addtimer(CALLBACK(src, PROC_REF(effect_evac_rift_end_step4)), 10 SECONDS)

/datum/sm_delam/proc/effect_evac_rift_end_step4()
	//SSticker.news_report = SUPERMATTER_CASCADE
	SSsupermatter_cascade.cascade_successful = TRUE
	SSticker.force_ending = TRUE

/// Scatters crystal mass over the event spawns as long as they are at least 30 tiles away from whatever we want to avoid.
/datum/sm_delam/proc/effect_crystal_mass(obj/machinery/power/supermatter_crystal/sm, avoid)
	new /obj/crystal_mass(get_turf(sm))
	var/list/possible_spawns = GLOB.xeno_spawn.Copy()
	for(var/i in 1 to rand(4, 6))
		var/spawn_location
		do
			spawn_location = pick_n_take(possible_spawns)
		while(get_dist(spawn_location, avoid) < 30)
		new /obj/crystal_mass(get_turf(spawn_location))

#undef DELAM_MAX_DEVASTATION
