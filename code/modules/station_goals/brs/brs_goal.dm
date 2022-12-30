// Сканейр Блюспейс Разлома
// Цель для исследования аномального блюспейс разлома с созданием портативных и статичных сканеров
/datum/station_goal/brs //BRS - Bluespace Rift Scanner
	name = "Сканер Блюспейс Разломов"
	var/scanner_goal = 25000

/datum/station_goal/brs/get_report()
	return {"<b>Сканирование блюспейс разломов</b><br>
	Научно-исследовательская станция расположена на месте дислокации блюспейс разлома. <br>
	Задача станции изучить все аномалии производимые разломом с сбором данных. <br>
	Собранные данные отправятся на изучение центральным научно-исследовательским отделом Нанотрейзен. <br>
	<br>
	Изучите блюспейс и получите платы для исследования разлома через научный отдел."}

/datum/station_goal/brs/on_report()
	create_bluespace_rift()

/datum/station_goal/brs/check_completion()
	if(..())
		return TRUE
	return check_scanners_goal()

/datum/station_goal/brs/proc/check_scanners_goal()
	for(var/obj/machinery/brs_server/S in GLOB.machines)
		if(!S.active || !is_station_level(S.z) || S.researchpoints < scanner_goal)
			continue
		return TRUE
	return FALSE

/datum/station_goal/brs/proc/create_bluespace_rift()
