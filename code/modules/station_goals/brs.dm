GLOBAL_LIST_EMPTY(bluespace_rifts_list)
GLOBAL_LIST_EMPTY(bluespace_rifts_server_list)
GLOBAL_LIST_EMPTY(bluespace_rifts_scanner_list)


// BRS - Bluespace Rift Scanner
// The goal is to research the anomalous bluespace rift with the creation of portable and static scanners
/datum/station_goal/bluespace_rift
	name = "Сканер Блюспейс Разлома"
	var/target_research_points = 25000
	var/reward_given = FALSE
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
	var/is_research_complete = (get_current_research_points() >= target_research_points)
	return is_research_complete

/datum/station_goal/bluespace_rift/proc/get_current_research_points()
	var/max_points = 0
	for(var/obj/machinery/brs_server/server as anything in GLOB.bluespace_rifts_server_list)
		max_points = max(max_points, server.research_points)
	return max_points

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
	rift = new rand_rift_type(goal_uid = UID())
