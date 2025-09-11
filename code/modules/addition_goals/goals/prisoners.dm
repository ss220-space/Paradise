// Prisoners addition goal shuttle

#define AGS_CREDITS_PER_PRISONER 5000
#define AGS_CAPRGOPOINTS_PER_PRISONER 30

/datum/addition_goal/prisoners
	id = "prisoners"
	name = "Шаттл с заключенными"
	var/prisoners_count
	var/list/prisoners = list()
	var/list/prisoners_data = list()
	var/obj/effect/mob_spawn/human/spawner

/datum/addition_goal_prisoner_data
	var/crimes = "202"
	var/duration = 10
	var/complete_percent = 0
	var/complete_reason = "не отсидел"


/datum/addition_goal/prisoners/setup()
	prisoners_count = rand(3, 5)
	request_number = "[rand(100, 999)]"
	name = "Запрос исполнения наказания №[request_number]"
	description = "Запрос исполнения наказания №[request_number]. На станцию прибудет шаттл с [prisoners_count] [declension_ru(prisoners_count, "заключенным", "заключенными", "заключенными")] для исполнения наказания."


/datum/addition_goal/prisoners/spawn_shuttle_contain(list/turf/shuttle_turfs)
	reward_credits = 0
	reward_cargopoints = 0
	spawner = new /obj/effect/mob_spawn/human/addition_goal/prisoners(shuttle_turfs[1])
	for(var/i = 0; i < prisoners_count; i++)
		var/turf/random_turf = pick(shuttle_turfs)
		shuttle_turfs -= random_turf
		create_prisoner_at(random_turf)
	qdel(spawner)
	return TRUE

/datum/addition_goal/prisoners/proc/create_prisoner_at(turf/location)
	spawner.loc = location
	var/mob/living/carbon/human/prisoner = spawner.create()
	prisoners += prisoner
	var/obj/structure/chair/chair = new /obj/structure/chair(location)
	addtimer(CALLBACK(chair, TYPE_PROC_REF(/atom/movable/, buckle_mob), prisoner, TRUE, FALSE), 1)
	handcuff_prisoner(prisoner)
	switch_ai_to_angry_mode(prisoner)
	create_prisoner_data(prisoner)
	calculate_prionser_reward(prisoner)
	create_crimes_paper(location, prisoner)
	register_complete_signal_handler(prisoner)

/datum/addition_goal/prisoners/proc/switch_ai_to_angry_mode(mob/living/prisoner)
	prisoner.ai_controller = /datum/ai_controller/monkey/angry
	prisoner.InitializeAIController()

/datum/addition_goal/prisoners/proc/handcuff_prisoner(mob/living/carbon/target)
	var/obj/item/restraints/handcuffs/cable/zipties/cuffs = new (target.loc)
	if(prob(90))
		target.equip_to_slot(cuffs, ITEM_SLOT_HANDCUFFED)

/datum/addition_goal/prisoners/proc/create_prisoner_data(mob/living/prisoner)
	var/list/hard_crimes = list("300", "302", "303", "304", "305", "306", "307", "308")
	var/list/middle_crimes = list("200", "201", "202", "203", "204", "205", "206", "207")
	var/list/light_crimes = list("100", "101", "102", "103", "104", "105", "106", "107", "108")
	var/datum/addition_goal_prisoner_data/crime = new()
	prisoners_data[prisoner.real_name] = crime
	if(prob(30))
		crime.crimes = "[pick(hard_crimes)]"
		crime.duration = rand(10, 15)
		return
	if(prob(50))
		crime.crimes = "[pick(middle_crimes)], [pick(light_crimes)]"
		crime.duration = rand(10, 15)
		return
	var/crime1 = pick(light_crimes)
	light_crimes -= crime1
	var/crime2 = pick(light_crimes)
	light_crimes -= crime2
	var/crime3 = pick(light_crimes)
	crime.crimes = "[crime1], [crime2], [crime3]"
	crime.duration = rand(10, 15)

/datum/addition_goal/prisoners/proc/calculate_prionser_reward(mob/living/prisoner)
	reward_credits += AGS_CREDITS_PER_PRISONER
	reward_cargopoints += AGS_CAPRGOPOINTS_PER_PRISONER

/datum/addition_goal/prisoners/proc/create_crimes_paper(turf/location, mob/living/prisoner)
	var/datum/addition_goal_prisoner_data/data = prisoners_data[prisoner.real_name]
	var/obj/item/paper/paper = new (location)
	var/number = "[request_number]-[rand(1000, 9999)]"
	paper.name = "Приказ о заключении под стражу №[number]"
	paper.info = {"<center><b>Приказ о заключении [number]</b></center><br>
		Настоящим подтверждается, что гражданин [prisoner.real_name] подлежит тюремному заключению сроком в [data.duration] минут в камере брига.<br>
		<b>Вменяемые статьи:</b> [data.crimes]."}

/datum/addition_goal/prisoners/proc/register_complete_signal_handler(mob/living/prisoner)
	RegisterSignal(prisoner, COMSIG_DOOR_TIMER_FINISH, PROC_REF(on_prisoner_timer_finish))

/datum/addition_goal/prisoners/proc/on_prisoner_timer_finish(mob/living/prisoner, crimes, duration_min)
	SIGNAL_HANDLER
	var/datum/addition_goal_prisoner_data/data = prisoners_data[prisoner.real_name]
	if(!data)
		return
	data.complete_percent = 100
	data.complete_reason = "отсидел"
	if(duration_min < data.duration) {
		data.complete_percent -= 50
		data.complete_reason += " меньше, чем надо"
	}
	if(duration_min > data.duration) {
		data.complete_percent -= 10
		data.complete_reason += " больше, чем надо"
	}
	if(data.crimes != crimes) {
		data.complete_percent -= 10
		data.complete_reason += " с неправильными статьями"
	}


/datum/addition_goal/prisoners/format_accept_report(mob/user)
	var/text = {"<center><b>Запрос на временное заключение</b></center><br>
		В ваш адрес [declension_ru(prisoners_count, "направлен", "напревлены", "направлены")] [prisoners_count] [declension_ru(prisoners_count, "заключенный", "заключенных", "заключенных")] для отбытия наказания.<br>
		Просим произвести заключение в соответствии с нижеуказанным списком:<br>"}
	var/number = 1
	for(var/mob/living/prisoner as anything in prisoners)
		var/datum/addition_goal_prisoner_data/data = prisoners_data[prisoner.real_name]
		text += "<br>[number]. [prisoner.real_name] - [data.crimes] ([data.duration] минут заключения)."
		number++
	return text


/datum/addition_goal/prisoners/complete_goal(datum/controller/subsystem/addition_goals/system)
	var/shuttle_turfs = system.get_shuttle_turfs()
	var/summary_complete_percent = 0
	var/report_text = ""
	var/number = 1
	for(var/mob/living/carbon/prisoner as anything in prisoners)
		report_text += "[number]. [prisoner.real_name]: "
		number++
		var/datum/addition_goal_prisoner_data/data = prisoners_data[prisoner.real_name]
		if(!data) //not exists crimes data, skip this prisoner
			report_text += "потерян (<i>штраф 5000 кредитов</i>).<br>"
			reward_credits -= 5000
			continue
		if(!prisoner.loc) //prisoner not exists in game (gibbed, cremated ...)
			report_text += "потерян (<i>штраф 5000 кредитов</i>).<br>"
			reward_credits -= 5000
			continue
		if(!contains_in_shuttle(shuttle_turfs, prisoner)) //prisoner not in shuttle!
			data.complete_percent = max(0, data.complete_percent - 50)
			report_text += "остался на станции (<i>штраф 5000 кредитов</i>) "
			reward_credits -= 5000
		if(prisoner.stat == DEAD)
			data.complete_percent = max(0, data.complete_percent - 25)
			report_text += "мертв (<i>штраф 2000 кредитов</i>) "
			reward_credits -= 2000
		else if(prisoner.health < 95) //prisoner hearts
			data.complete_percent = max(0, data.complete_percent - 25)
			report_text += "имеет ранения (<i>штраф 1000 кредитов</i>) "
			reward_credits -= 1000
		if(!prisoner.handcuffed)
			data.complete_percent = max(0, data.complete_percent - 10)
			report_text += "не в наручниках (<i>штраф 500 кредитов</i>) "
			reward_credits -= 500
		summary_complete_percent += data.complete_percent
		report_text += data.complete_reason + ".<br>"
	var/progress = (summary_complete_percent) / prisoners_count
	report_text += "<b>Общий прогресс запроса</b>: [progress]%<br>"
	report_text += "<b>Ваша награда</b>:<br>"
	reward_credits = reward_credits * (progress / 100)
	reward_cargopoints = reward_cargopoints * (progress / 100)
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
	system.add_reward(reward_credits, reward_cargopoints)
	var/paper_content = system.create_paper_content("Отчет о заключении под стражу №[request_number]", report_text, "Официальный документ заверенный печатью Центрального командования Нанотрейзен")
	system.print_report_on_console("Отчет [name]", paper_content, stamp = TRUE)



////////////////////////////////////////
// MARK:	Misc
////////////////////////////////////////

/obj/effect/mob_spawn/human/addition_goal/prisoners
	death = FALSE
	mob_type = /mob/living/carbon/human/monkeybrain
	uniform = /obj/item/clothing/under/prison
	shoes = /obj/item/clothing/shoes/prison
	head = /obj/item/clothing/head/prison
	id = /obj/item/card/id/prisoner

#undef AGS_CREDITS_PER_PRISONER
#undef AGS_CAPRGOPOINTS_PER_PRISONER
