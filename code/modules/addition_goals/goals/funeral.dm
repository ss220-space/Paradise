/// Funeral shuttle addition goal
#define CORPSE_METHOD_CREMATION "кремация"
#define CORPSE_METHOD_SPACE "космирование"
#define CORPSE_METHOD_UTILIZATION "утилизация тела"

#define CREDITS_BY_CREMATION 2000
#define CARGOPOINTS_BY_CREMATION 5
#define CREDITS_BY_SPACE 3000
#define CARGOPOINTS_BY_SPACE 10
#define CREDITS_BY_UTILIZATION 1000
#define CARGOPOINTS_BY_UTILIZATION 2

////////////////////////////////////////
// MARK:	Goal datum
////////////////////////////////////////

/datum/addition_goal/funeral
	id = "funeral"
	var/corpse_count
	var/list/corpses = list()
	var/list/corpse_data = list()
	var/obj/effect/mob_spawn/human/spawner


/datum/addition_goal/funeral/setup()
	corpse_count = rand(3, 5)
	request_number = "[rand(100, 999)]"
	name = "Запрос похорон №[request_number]"
	description = "Запрос проведения похорон №[request_number]. На станцию прибудет шаттл с [corpse_count] трупами для проведения похорон."


/datum/addition_goal/funeral/spawn_shuttle_contain(list/turf/shuttle_turfs)
	spawner = new /obj/effect/mob_spawn/human/addition_goal/funeral(shuttle_turfs[1])
	reward_credits = 0
	reward_cargopoints = 0
	for(var/i = 0; i < corpse_count; i++)
		var/turf/random_turf = pick(shuttle_turfs)
		shuttle_turfs -= random_turf
		var/mob/living/carbon/human/corpse = spawn_corpse(random_turf)
		var/datum/addition_goal_corpse_data/data = create_corpse_data(corpse.real_name)
		create_paper_about_corpse(random_turf, corpse, data)
		create_body_bag_and_close(random_turf)
		calculate_reward(data)
		if(data.preffered_method == CORPSE_METHOD_CREMATION)
			register_cremated_signal_handler(corpse)
	qdel(spawner)
	return TRUE

/datum/addition_goal/funeral/proc/spawn_corpse(turf/location)
	spawner.loc = location
	var/mob/living/carbon/human/corpse = spawner.create()
	corpses += corpse
	return corpse

/datum/addition_goal/funeral/proc/create_corpse_data(corpse_name)
	var/datum/addition_goal_corpse_data/data = new ()
	data.name = corpse_name
	switch(rand(1, 5))
		if(1, 2)
			data.preffered_method = CORPSE_METHOD_CREMATION
		if(3, 4)
			data.preffered_method = CORPSE_METHOD_SPACE
		if(5)
			data.preffered_method = CORPSE_METHOD_UTILIZATION
	data.request_number = "[request_number]-[rand(1000, 9999)]"
	corpse_data[corpse_name] = data
	return data

/datum/addition_goal/funeral/proc/create_paper_about_corpse(turf/location, mob/living/carbon/human/corpse, datum/addition_goal_corpse_data/data)
	var/obj/item/paper/paper = new (location)
	paper.name = "Документ о проведении погребения №[data.request_number]"
	paper.info = {"<center><b>Документ о проведении погребения [data.request_number]</b></center><br>
		Настоящим подтверждается, что гражданин [data.name] подлежит захоронению в соответствии с указанным способом.<br>
		<b>Форма погребения:</b> [data.preffered_method]."}

/datum/addition_goal/funeral/proc/create_body_bag_and_close(turf/location)
	var/obj/structure/closet/body_bag/body_bag = new /obj/structure/closet/body_bag(location)
	body_bag.open()
	body_bag.close()

/datum/addition_goal/funeral/proc/calculate_reward(datum/addition_goal_corpse_data/data)
	switch(data.preffered_method)
		if(CORPSE_METHOD_CREMATION)
			reward_credits += CREDITS_BY_CREMATION
			reward_cargopoints += CARGOPOINTS_BY_CREMATION
		if(CORPSE_METHOD_SPACE)
			reward_credits += CREDITS_BY_SPACE
			reward_cargopoints += CARGOPOINTS_BY_SPACE
		if(CORPSE_METHOD_UTILIZATION)
			reward_credits += CREDITS_BY_UTILIZATION
			reward_cargopoints += CARGOPOINTS_BY_UTILIZATION

/datum/addition_goal/funeral/format_accept_report(mob/user)
	var/text = {"В ваш адрес направлены [corpse_count] [declension_ru(corpse_count, "тело", "тела", "тел")] для организации процедуры захоронения.<br>
		Просим произвести погребение в соответствии с нижеуказанным списком:<br>"}
	var/number = 1
	for(var/mob/living/corpse as anything in corpses)
		var/datum/addition_goal_corpse_data/data = corpse_data[corpse.name]
		text += "<br>[number]. [data.name] – [data.preffered_method]."
		number++
	return text

/datum/addition_goal/funeral/proc/register_cremated_signal_handler(mob/living/corpse)
	RegisterSignal(corpse, COMSIG_LIVING_CREMATED, PROC_REF(on_corpse_cremated))

/datum/addition_goal/funeral/proc/on_corpse_cremated(mob/living/corpse)
	SIGNAL_HANDLER
	var/datum/addition_goal_corpse_data/data = corpse_data[corpse.real_name]
	if(!data)
		return
	data.complete = TRUE

/datum/addition_goal/funeral/complete_goal(datum/controller/subsystem/addition_goals/system)
	var/complete_count = 0
	var/report_text = ""
	var/number = 1
	for(var/mob/living/corpse in corpses)
		var/datum/addition_goal_corpse_data/data = corpse_data[corpse.name]
		report_text += "[number]. [corpse.name]: "
		number++
		switch(data.preffered_method)
			if(CORPSE_METHOD_CREMATION)
				if(data.complete)
					report_text += "успешно кремирован.<br>"
					complete_count++
					continue
			if(CORPSE_METHOD_UTILIZATION)
				if(!corpse || !corpse.loc)
					report_text += "успешно утилизирован.<br>"
					complete_count++
			if(CORPSE_METHOD_SPACE)
				if(!corpse || !corpse.loc)
					report_text += "тело уничтожено.<br>"
					continue
				if(!istype(corpse.loc, /obj/structure/closet/coffin))
					report_text += "тело не находится в гробу.<br>"
					continue
				var/obj/structure/closet/coffin/coffin = corpse.loc
				if(istype(coffin.loc, /turf/space))
					report_text += "успешно похоронен.<br>"
					complete_count++
				else
					report_text += "гроб с телом не космирован.<br>"
			else
				report_text += "неизвестно.<br>"
	var/progress = (complete_count) / corpse_count * 100
	report_text += "<b>Общий прогресс запроса</b>: [progress]%<br>"
	report_text += "<b>Ваша награда</b>:<br>"
	reward_credits = reward_credits * (progress / 100)
	reward_cargopoints = reward_cargopoints * (progress / 100)
	var/reward_number = 1
	if(reward_credits > 0)
		report_text += "[reward_number]. [reward_credits] кредитов на счет станции.<br>"
		reward_number++
	if(reward_cargopoints > 0)
		report_text += "[reward_number]. [reward_cargopoints] очков поставки в карго.<br>"
	system.add_reward(reward_credits, reward_cargopoints)
	var/paper_content = system.create_paper_content("Отчет о проведении погребения №[request_number]", report_text, "Официальный документ заверенный печатью Центрального командования Нанотрейзен")
	system.print_report_on_console("Отчет [name]", paper_content, stamp = TRUE)




////////////////////////////////////////
// MARK:	Misc
////////////////////////////////////////

/datum/addition_goal_corpse_data
	var/name = "unknown"
	var/preffered_method = CORPSE_METHOD_CREMATION
	var/request_number = 1
	var/complete = 0

/obj/effect/mob_spawn/human/addition_goal/funeral
	death = TRUE
	uniform = /obj/item/clothing/under/suit_jacket/charcoal
	shoes = /obj/item/clothing/shoes/centcom
