GLOBAL_LIST_INIT(bluespace_rifts_list, list())
GLOBAL_LIST_INIT(bluespace_rifts_server_list, list())

// Сканер Блюспейс Разлома
// Цель для исследования аномального блюспейс разлома с созданием портативных и статичных сканеров
/datum/station_goal/brs
	name = "Bluespace Rift Scanner"		//BRS
	var/scanner_goal = 25000
	var/list/rifts_list = list()

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
	for(var/obj/machinery/brs_server/S in GLOB.machines)
		if(!S.active || !is_station_level(S.z) || S.research_points < scanner_goal)
			continue
		return TRUE
	return FALSE

/datum/station_goal/brs/Destroy()
	QDEL_LIST(rifts_list)
	. = ..()

/datum/station_goal/brs/proc/random_bluespace_rift()
	var/type_rift = rand(1, MAX_TYPES_RIFT)
	if(type_rift == TWINS_RIFT)
		create_bluespace_rift(type_rift)
		create_bluespace_rift(type_rift)
	else
		create_bluespace_rift(type_rift)

/datum/station_goal/brs/proc/create_bluespace_rift(var/type_rift = DEFAULT_RIFT)
	var/turf/temp_turf = find_safe_turf()
	var/obj/brs_rift/rift = new(temp_turf, type_rift)
	rifts_list.Add(rift)
