GLOBAL_LIST_INIT(bluespace_rifts_list, list())
GLOBAL_LIST_INIT(bluespace_rifts_server_list, list())

// BRS - Bluespace Rift Scanner
// The goal is to research the anomalous bluespace rift with the creation of portable and static scanners
/datum/station_goal/brs
	name = "Сканер Блюспейс Разлома"
	var/scanner_goal = 25000
	var/list/rifts_list = list()
	var/is_give_reward = FALSE

/datum/station_goal/brs/get_report()
	return {"<b>Сканирование блюспейс разломов</b><br>
	Научно-исследовательская станция расположена на месте дислокации блюспейс разлома. <br>
	Задача станции изучить все аномалии производимые разломом с сбором данных. <br>
	Собранные данные отправятся на изучение центральным научно-исследовательским отделом Нанотрейзен. <br>
	<br>
	Обнаруженные разломы: <br>
	[get_rift_types()]
	<br>
	Изучите блюспейс и получите платы для исследования разлома через научный отдел."}

/datum/station_goal/brs/proc/get_rift_types()
	var/result = ""
	for (var/obj/brs_rift/rift in rifts_list)
		result += "[rift.name] <br>"
	return result

/datum/station_goal/brs/on_report()
	random_bluespace_rift()

/datum/station_goal/brs/check_completion()
	if(..())
		return TRUE
	return check_scanners_goal()

/datum/station_goal/brs/proc/check_scanners_goal()
	for(var/obj/machinery/brs_server/S in GLOB.bluespace_rifts_server_list)
		if(S.research_points < scanner_goal)
			continue
		return TRUE
	return FALSE

/datum/station_goal/brs/proc/get_max_server_points_goal()
	var/max_points = 0
	for(var/obj/machinery/brs_server/S in GLOB.bluespace_rifts_server_list)
		max_points = max(max_points, S.research_points)
	return max_points

/datum/station_goal/brs/proc/check_can_give_reward()
	for(var/datum/station_goal/brs/G in SSticker.mode.station_goals)
		if(!G.is_give_reward)
			return TRUE
	return FALSE


/datum/station_goal/brs/Destroy()
	QDEL_LIST(rifts_list)
	. = ..()

/datum/station_goal/brs/proc/random_bluespace_rift()
	if (length(rifts_list))
		return

	var/type_rift = rand(1, MAX_TYPES_RIFT)
	switch(type_rift)
		if(TWINS_RIFT)		// the same occurrence of anomalies between the two
			for(var/i in 1 to 2)
				var/obj/brs_rift/rift = create_bluespace_rift(type_rift)
				rifts_list.Add(rift)
		if(CRACK_RIFT)	// random appearance of anomalies in 4 places
			for(var/i in 1 to 4)
				var/obj/brs_rift/rift = create_bluespace_rift(type_rift)
				rifts_list.Add(rift)
		else
			var/obj/brs_rift/rift = create_bluespace_rift(type_rift)
			rifts_list.Add(rift)

	for(var/obj/brs_rift/rift in rifts_list)
		rift.related_rifts_list = rifts_list

/datum/station_goal/brs/proc/create_bluespace_rift(var/type_rift = DEFAULT_RIFT)
	var/turf/temp_turf = find_safe_turf()
	var/obj/brs_rift/rift

	switch(type_rift)
		if(CRACK_RIFT)
			rift = new /obj/brs_rift/crack(temp_turf)
		if(TWINS_RIFT)
			rift = new /obj/brs_rift/twin(temp_turf)
		if(DEFAULT_RIFT)
			rift = new /obj/brs_rift(temp_turf)
		if(BIG_RIFT)
			rift = new /obj/brs_rift/big(temp_turf)
		if(FOG_RIFT)
			rift = new /obj/brs_rift/fog(temp_turf)
		if(HUNTER_RIFT)
			rift = new /obj/brs_rift/hunter(temp_turf)

	return rift
