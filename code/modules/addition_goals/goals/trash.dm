// Trash addition goal shuttle

#define AGS_CREDITS_PER_TRASH 100
#define AGS_CAPRGOPOINTS_PER_TRASH 1

/datum/addition_goal/trash
	id = "trash_utilization"
	name = "Шаттл с утилизацией мусора"
	var/trash_count


/datum/addition_goal/trash/setup()
	trash_count = rand(20, 40)
	request_number = "[rand(100, 999)]"
	name = "Запрос утилизации мусора №[request_number]"
	description = "Запрос утилизации мусора №[request_number]. На станцию прибудет шаттл с мусором, необходимо разгрузить мусор с шаттла и вернуть его обратно. Дальнейшая судьба мусора нас не интересует."


/datum/addition_goal/trash/spawn_shuttle_contain(list/turf/shuttle_turfs)
	var/list/available_trash = subtypesof(/obj/item/trash)
	for(var/i = 0; i < trash_count; i++)
		var/trash_type = pick(available_trash)
		var/turf/trash_location = pick(shuttle_turfs)
		new trash_type(trash_location)
	return TRUE


/datum/addition_goal/trash/format_accept_report(mob/user)
	return {"<center><b>Запрос на утилизацию мусора</b></center><br>
		В ваш адрес напревлен шаттл с мусором. Необходимо выгрузить весь мусор с шаттла и отправить его обратно.<br>
		Мусор после разгрузки вы можете сжечь в крематории, либо утилизировать в измельчителе мусора. Впрочем судьба мусора нас не интересует.<br>
		Награда за выполнение:<br>
		1. [trash_count * AGS_CREDITS_PER_TRASH] кредитов на счет станции.<br>
		2. [trash_count * AGS_CAPRGOPOINTS_PER_TRASH] очков поставки в карго.<br>"}


/datum/addition_goal/trash/complete_goal(datum/controller/subsystem/addition_goals/system)
	var/shuttle_turfs = system.get_shuttle_turfs()
	var/trash_in_shuttle = 0
	for(var/turf/shittle_turf as anything in shuttle_turfs)
		//open all containers before check
		for(var/obj/structure/closet/closet in shittle_turf.contents)
			closet.open()
		// search trash
		for(var/obj/item/trash in shittle_turf.contents)
			trash_in_shuttle++
	var/complete_trash_count = trash_count - trash_in_shuttle
	var/progress = clamp(complete_trash_count / trash_count * 100, 0, 100)
	var/report_text = "<b>Отправлено мусора</b>: [trash_count] шт.<br>"
	report_text += "<b>Обнаружено мусора после прилета</b>: [trash_count] шт.<br>"
	report_text += "<b>Общий прогресс запроса</b>: [progress]%<br>"
	report_text += "<b>Ваша награда</b>:<br>"
	reward_credits = complete_trash_count * AGS_CREDITS_PER_TRASH
	reward_cargopoints = complete_trash_count * AGS_CAPRGOPOINTS_PER_TRASH
	var/reward_number = 1
	if(reward_credits > 0)
		report_text += "[reward_number]. [reward_credits] кредитов на счет станции.<br>"
		reward_number++
	if(reward_cargopoints > 0)
		report_text += "[reward_number]. [reward_cargopoints] очков поставки в карго.<br>"
	if(reward_credits <= 0 && reward_cargopoints <= 0)
		report_text += "Отсутствует.<br>"
	system.add_reward(reward_credits, reward_cargopoints)
	var/paper_content = system.create_paper_content("Отчет об утилизации мусора №[request_number]", report_text, "Официальный документ заверенный печатью Центрального командования Нанотрейзен")
	system.print_report_on_console("Отчет [name]", paper_content, stamp = TRUE)
