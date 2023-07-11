GLOBAL_LIST_INIT(bluespace_rifts_list, list())
GLOBAL_LIST_INIT(bluespace_rifts_server_list, list())
GLOBAL_LIST_INIT(bluespace_rifts_scanner_list, list())


// BRS - Bluespace Rift Scanner
// The goal is to research the anomalous bluespace rift with the creation of portable and static scanners
/datum/station_goal/bluespace_rift
	name = "Сканер Блюспейс Разлома"
	var/scanner_goal = 25000
	var/is_give_reward = FALSE
	var/datum/bluespace_rift/rift

/datum/station_goal/bluespace_rift/Destroy()
	QDEL_NULL(rift)
	. = ..()

/datum/station_goal/bluespace_rift/get_report()
	return {"<b>Сканирование блюспейс разломов</b><br>
	Научно-исследовательская станция расположена на месте дислокации блюспейс разлома. <br>
	Задача станции изучить все аномалии производимые разломом с сбором данных. <br>
	Собранные данные отправятся на изучение центральным научно-исследовательским отделом Нанотрейзен. <br>
	<br>
	Обнаруженные разломы: <br>
	[rift.name]
	<br>
	Изучите блюспейс и получите платы для исследования разлома через научный отдел."}

/datum/station_goal/bluespace_rift/on_report()
	spawn_rift()

/datum/station_goal/bluespace_rift/check_completion()
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

/datum/station_goal/bluespace_rift/proc/spawn_rift()
	var/rift_types = list(
		/datum/bluespace_rift,
		/datum/bluespace_rift/big,
		/datum/bluespace_rift/fog,
		/datum/bluespace_rift/twin,
		/datum/bluespace_rift/crack,
		/datum/bluespace_rift/hunter,
	)
	var/rand_rift_type = pick(rift_types)
	rift = new rand_rift_type()
