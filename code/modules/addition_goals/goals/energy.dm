// Energy support addition goal shuttle

#define AGS_CREDITS_PER_SMES 10000
#define AGS_CAPRGOPOINTS_PER_SMES 75
#define AGS_FINE_CREDITS_PER_SMES 25000

/datum/addition_goal/energy_support
	id = "energy_support"
	name = "Шаттл запроса энергии"
	var/smes_count


/datum/addition_goal/energy_support/setup()
	smes_count = rand(2, 3)
	request_number = "[rand(100, 999)]"
	name = "Запрос энергии №[request_number]"
	description = "Запрос энергии №[request_number]. На станцию прибудет шаттл с несколькими мобильными СКАНами. Вам необходимо зарядить их с помощью вашего двигателя и отправить обратно на шаттле."


/datum/addition_goal/energy_support/spawn_shuttle_contain(list/turf/shuttle_turfs)
	for(var/i in 1 to smes_count)
		var/turf/random_location = pick(shuttle_turfs)
		new /obj/machinery/power/smes/portable(random_location)
	return TRUE


/datum/addition_goal/energy_support/format_accept_report(mob/user)
	return {"<center><b>Запрос энергии</b></center><br>
		На станцию прибудет шаттл с несколькими мобильными СКАНами.
		Вам необходимо зарядить их с помощью вашего двигателя и отправить обратно на шаттле.<br>
		Для развертывания мобильного СКАНа, необходимо установить его рядом с узлом энергосети и подключить с помощью гаечного ключа.<br>
		Награда за выполнение:<br>
		1. [smes_count * AGS_CREDITS_PER_SMES] кредитов на счет станции.<br>
		2. [smes_count * AGS_CAPRGOPOINTS_PER_SMES] очков поставки в карго.<br>"}


/datum/addition_goal/energy_support/complete_goal(datum/controller/subsystem/addition_goals/system)
	var/shuttle_turfs = system.get_shuttle_turfs()
	var/total_charge = 0
	var/total_capacity = 0
	var/smes_in_shuttle = 0
	var/report_text = "<b>Состояние мобильных СКАНов</b>: [smes_count] шт.<br>"
	var/scan_number = 1
	for(var/turf/shittle_turf as anything in shuttle_turfs)
		for(var/obj/machinery/power/smes/portable/smes in shittle_turf.contents)
			total_capacity = smes.capacity * smes_count
			smes_in_shuttle++
			var/scan_progress = round(smes.charge / smes.capacity * 100, 1)
			total_charge += scan_progress
			report_text += "Мобильный СКАН #[scan_number]: [scan_progress]%<br>"

	if(smes_in_shuttle < smes_count)
		report_text += "Не обнаружено [smes_count - smes_in_shuttle] мобильных СКАНа, вы будете оштрафованы на значительную сумму!<br>"
	var/progress = round(clamp(total_charge / total_capacity * 100, 0, 100), 1)
	report_text += "<b>Общий прогресс запроса</b>: [progress]%<br>"
	report_text += "<b>Ваша награда</b>:<br>"

	reward_credits = smes_count * AGS_CREDITS_PER_SMES * progress / 100
	reward_cargopoints = smes_count * AGS_CAPRGOPOINTS_PER_SMES * progress / 100
	if(smes_in_shuttle < smes_count)
		var/not_found_count = smes_count - smes_in_shuttle
		reward_credits -= not_found_count * AGS_FINE_CREDITS_PER_SMES

	var/reward_number = 1
	if(reward_credits > 0)
		report_text += "[reward_number]. [reward_credits] кредитов на счет станции.<br>"
		reward_number++
	else if(reward_credits < 0)
		report_text += "[reward_number]. Штраф [reward_credits] кредитов со счета станции.<br>"
		reward_number++
	if(reward_cargopoints > 0)
		report_text += "[reward_number]. [reward_cargopoints] очков поставки в карго.<br>"
	else if(reward_cargopoints < 0)
		report_text += "[reward_number]. Штраф в размере [reward_cargopoints] очков поставки в карго.<br>"
	if(reward_credits == 0 && reward_cargopoints == 0)
		report_text += "Отсутствует.<br>"

	system.add_reward(reward_credits, reward_cargopoints)
	var/paper_content = system.create_paper_content("Отчет о поставке энергии №[request_number]", report_text, "Официальный документ заверенный печатью Центрального командования Нанотрейзен")
	system.print_report_on_console("Отчет [name]", paper_content, stamp = TRUE)

#undef AGS_CREDITS_PER_SMES
#undef AGS_CAPRGOPOINTS_PER_SMES
#undef AGS_FINE_CREDITS_PER_SMES
