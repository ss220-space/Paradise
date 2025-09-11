#define TURF_FIND_TRIES 10

/datum/event/anomaly
	name = "Аномалия"
	startWhen = 3
	announceWhen = 10
	/// Path of spawned anomalies.
	var/obj/effect/anomaly/anomaly_path
	/// Turf where anomalies will be spawned.
	var/turf/target_turf
	/// Number of spawned anomalies.
	var/spawn_num
	/// Should we spawn random anomalies or of the same anomaly_type.
	var/random_types
	/// Tier of spawned anomalies.
	var/tier
	/// Type of spawned anomalies.
	var/anomaly_type
	announceWhen = 1


/datum/event/anomaly/setup()
	target_turf = find_targets(TRUE)
	if(anomaly_path) // Preloaded by event.
		return

	tier = rand(1, 3)
	anomaly_type = pick(GLOB.anomaly_types[TIER1])
	spawn_num = tier > 1 ? 1 : rand(2, 4)
	random_types = tier > 1 ? FALSE : prob(50)
	anomaly_path = text2path("/obj/effect/anomaly/[anomaly_type]/tier[tier]")


/datum/event/anomaly/proc/find_targets(warn_on_fail = FALSE)
	for(var/tries in 1 to TURF_FIND_TRIES)
		impact_area = findEventArea()
		find_turf(impact_area)
		if(target_turf)
			break

		if(!warn_on_fail)
			return

		stack_trace("No valid areas for anomaly found.")
		kill()
		return

	if(target_turf)
		return target_turf

	stack_trace("Anomaly: Unable to find a valid turf to spawn the anomaly. Last area tried: [impact_area] - [anomaly_path]")
	kill()
	return


/datum/event/anomaly/proc/find_turf(impact_area)
	if(!impact_area)
		return

	var/list/candidate_turfs = get_area_turfs(impact_area)
	while(length(candidate_turfs))
		var/turf/candidate = pick_n_take(candidate_turfs)
		if(candidate.is_blocked_turf(exclude_mobs = TRUE))
			continue

		target_turf = candidate
		break


/datum/event/anomaly/announce(false_alarm)
	var/area/target = false_alarm ? findEventArea() : impact_area
	if(false_alarm && !target)
		log_debug("Failed to find a valid area when trying to make a false alarm anomaly!")
		return

	var/prefix_message = "На сканерах дальнего действия обнаружена[spawn_num == 1 ? "" : " группа"] \
						[spawn_num == 1 ? GLOB.anomalies_sizes_one["[tier]"] : GLOB.anomalies_sizes_many["[tier]"]] \
						[random_types ? "" : (spawn_num == 1 ? GLOB.anomalies_preffs_one[anomaly_type] : GLOB.anomalies_preffs_many[anomaly_type])] \
						аномали[spawn_num == 1 ? "я" : "й"]."
	GLOB.minor_announcement.announce("[prefix_message] Предполагаемая локация: [target.name]",
									ANNOUNCE_ANOMALY_RU
	)


/datum/event/anomaly/start()
	for(var/ind = 0; ind < spawn_num; ++ind)
		if(random_types)
			anomaly_path = text2path("/obj/effect/anomaly/[pick(GLOB.anomaly_types[TIER1])]/tier[tier]")

		announce_to_ghosts(new anomaly_path(target_turf))


/datum/event/anomaly/admin_setup()
	if(!check_rights(R_EVENT))
		return

	if(tgui_alert(usr, "Настроить создание аномалий?", "Настройка аномалии", list("Да", "Случайная генерация")) != "Да")
		return

	anomaly_type = tgui_input_list(usr, "Выберите тип аномалий", "Выбор типа", GLOB.anomaly_types[TIER1] + "Рандом", "Рандом")
	tier = tgui_input_number(usr, "Выберите размер аномалий", "Выбор размера", 2, 3, 1)
	spawn_num = tgui_input_number(usr, "Выберите количество аномалий", "Выбор количества", 1, 100, 1)
	if(anomaly_type == "Рандом")
		anomaly_type = pick(GLOB.anomaly_types[TIER1])
		random_types = TRUE

	anomaly_path = text2path("/obj/effect/anomaly/[anomaly_type]/tier[tier]")


#undef TURF_FIND_TRIES
