GLOBAL_VAR_INIT(global_degenerate, FALSE)

/datum/team/terror_spiders
	name = "Пауки Ужаса"
	antag_datum_type = /datum/antagonist/terror_spider
	need_antag_hud = FALSE
	var/list/main_spiders = list(TERROR_QUEEN = list(), TERROR_PRINCE = list(), TERROR_PRINCESS = list(), TERROR_DEFILER = list())
	var/list/terror_infections = list()
	var/list/terror_eggs = list()
	var/datum/objective/spider_get_power/eat_humans/prince_target
	var/datum/objective/spider_get_power/alife_spiders/lay_eggs_target
	var/datum/objective/spider_get_power/spider_infections/infect_target
	var/datum/objective/spider_protect/other_target
	var/datum/objective/spider_protect_egg/protect_egg
	var/obj/structure/spider/eggcluster/terror_eggcluster/empress/empress_egg
	var/terror_announce = FALSE
	var/terror_stage = TERROR_STAGE_START
	var/delay_terror_end = FALSE

/datum/team/terror_spiders/New(list/starting_members)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_EMPRESS_EGG_DESTROYED, PROC_REF(on_empress_egg_destroyed))
	RegisterSignal(SSdcs, COMSIG_GLOB_EMPRESS_EGG_BURST, PROC_REF(on_empress_egg_burst))
	RegisterSignal(SSdcs, COMSIG_GLOB_IFECTION_CREATED, PROC_REF(on_terror_infection_created))
	RegisterSignal(SSdcs, COMSIG_GLOB_IFECTION_REMOVED, PROC_REF(on_terror_infection_removed))


/datum/team/terror_spiders/Destroy(force)
	. = ..()
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_EMPRESS_EGG_DESTROYED, COMSIG_GLOB_IFECTION_REMOVED, COMSIG_GLOB_EMPRESS_EGG_BURST, COMSIG_GLOB_IFECTION_CREATED))

/datum/team/terror_spiders/add_member(datum/mind/new_member, add_objectives)
	if(!new_member?.current || !isterrorspider(new_member.current))
		return
	var/already_in = (new_member in members)
	var/mob/living/simple_animal/hostile/poison/terror_spider/spider = new_member.current
	spider.add_datum_if_not_exist()
	. = ..()
	if(!already_in)
		on_minor_spider_created(new_member)

/datum/team/terror_spiders/proc/spider_announce()
	GLOB.event_announcement.Announce("Вспышка биологической угрозы 3-го уровня зафиксирована на борту станции [station_name()]. Всему персоналу надлежит сдержать её распространение любой ценой! Особая директива распечатана на всех консолях связи.", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/effects/siren-spooky.ogg')
	SSticker?.mode?.special_directive()
	SSshuttle?.emergency.cancel()
	for(var/datum/mind/mind as anything in get_main_spiders())
		if(mind.current && mind.current.stat != DEAD)
			SSshuttle?.add_hostile_environment(mind)

/datum/team/terror_spiders/proc/egg_announce()
	if(QDELETED(empress_egg))
		return
	GLOB.event_announcement.Announce("На борту станции [station_name()] зафиксирована биологическая сигнатура яйца Императрицы Ужаса в [get_area(empress_egg)]. Уничтожьте его, пока ситуация не вышла из под контроля.", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/effects/siren-spooky.ogg')

/datum/team/terror_spiders/proc/spider_win_announce()
	GLOB.event_announcement.Announce("Подтверждено наличие Императрицы Ужаса на борту [station_name()]. Станция переклассифицированна в гнездо биоугрозы 3-го уровня. Взведение устройства самоуничтожения персоналом или внешними силами в данный момент не представляется возможным. Активация протоколов изоляции.", "Отчет об объекте [station_name()]")

/datum/team/terror_spiders/proc/get_main_spiders()
	return main_spiders[TERROR_QUEEN] + \
			main_spiders[TERROR_PRINCE] + \
			main_spiders[TERROR_PRINCESS] + \
			main_spiders[TERROR_DEFILER]

/datum/team/terror_spiders/proc/check_main_spiders()
	var/list/major_spiders = get_main_spiders()
	for(var/datum/mind/spider as anything in major_spiders)
		if(!QDELETED(spider) && spider?.current?.stat != DEAD)
			return TRUE
	return FALSE


/datum/team/terror_spiders/proc/on_terror_infection_created(source, eggs)
	SIGNAL_HANDLER
	terror_infections |= eggs
	check_announce()
	if(infect_target.check_completion(spider_team = src))
		for(var/datum/spider in main_spiders[TERROR_DEFILER])
			SEND_SIGNAL(spider, COMSIG_SPIDER_CAN_LAY)

/datum/team/terror_spiders/proc/on_minor_spider_created(mind)
	check_announce()
	if(lay_eggs_target?.check_completion(spider_team = src))
		for(var/datum/spider in (main_spiders[TERROR_QUEEN] + main_spiders[TERROR_PRINCESS]))
			SEND_SIGNAL(spider, COMSIG_SPIDER_CAN_LAY)

/datum/team/terror_spiders/proc/get_terror_spiders_alife_count()
	var/alife_count = 0
	for(var/datum/mind/mind as anything in members)
		if(!QDELETED(mind.current) && mind.current.stat != DEAD)
			alife_count++
	return alife_count

/datum/team/terror_spiders/proc/on_major_spider_created(mind, type)
	if(type == TERROR_OTHER)
		return
	var/list/spiders = main_spiders[type]
	spiders |= mind
	other_target?.generate_text(src)
	if(terror_announce)
		SSshuttle?.add_hostile_environment(mind)

/datum/team/terror_spiders/proc/check_announce()
	if(terror_announce)
		return TRUE
	var/crew_count = num_station_players()
	var/result = FALSE

	if(length(main_spiders[TERROR_PRINCE]))
		result = TRUE

	var/main_spider_exist = check_main_spiders()

	if(main_spider_exist && terror_infections.len > crew_count * INFECTIONS_ANNOUNCE_TRIGGER)
		result = TRUE

	if(main_spider_exist && get_terror_spiders_alife_count() > crew_count * SPIDERS_ANNOUNCE_TRIGGER)
		result = TRUE

	if(result)
		terror_announce = TRUE
		spider_announce()
	return result

/datum/team/terror_spiders/proc/on_major_spider_died(mind, type)
	ASYNC
		SSshuttle?.remove_hostile_environment(mind)


/datum/team/terror_spiders/proc/on_terror_infection_removed(source, eggs)
	SIGNAL_HANDLER
	terror_infections -= eggs

/datum/team/terror_spiders/proc/on_empress_egg_layed(egg)
	empress_egg = egg
	terror_stage = TERROR_STAGE_PROTECT_EGG
	for(var/datum/spider as anything in members)
		SEND_SIGNAL(spider, COMSIG_EMPRESS_EGG_LAYED)
	give_protect_egg_objective()
	addtimer(CALLBACK(src, PROC_REF(egg_announce)), TIME_TO_ANNOUNCE)


/datum/team/terror_spiders/proc/give_protect_egg_objective()
	if(!protect_egg)
		protect_egg = new
		protect_egg.owner = src
		protect_egg.generate_text(spider_team = src)
	if(protect_egg in objectives)
		return

	add_objective_to_members(protect_egg)

/datum/team/terror_spiders/proc/on_empress_egg_burst()
	SIGNAL_HANDLER
	empress_egg = null
	RegisterSignal(SSdcs, COMSIG_GLOB_WEB_STORM_ENDED, PROC_REF(on_web_storm_ended))
	INVOKE_ASYNC(SSweather, TYPE_PROC_REF(/datum/controller/subsystem/weather, run_weather), /datum/weather/web_storm)
	protect_egg.completed = TRUE
	terror_stage = TERROR_STAGE_STORM

/datum/team/terror_spiders/proc/on_web_storm_ended()
	SIGNAL_HANDLER
	spider_win_announce()
	terror_stage = TERROR_STAGE_END
	if(delay_terror_end)
		terror_stage = TERROR_STAGE_POST_END
	else
		SSticker?.mode?.end_game()
	UnregisterSignal(SSdcs, COMSIG_GLOB_WEB_STORM_ENDED)

/datum/team/terror_spiders/proc/on_empress_egg_destroyed()
	SIGNAL_HANDLER
	GLOB.global_degenerate = TRUE
	for(var/mob/spider in GLOB.ts_spiderlist)
		if(spider)
			to_chat(spider, span_danger("Вы чувствуесте невообразимую боль. Яйцо Императрицы уничтожено."))
	erase_eggs()

/datum/team/terror_spiders/proc/erase_eggs()
	for(var/infection in terror_infections)
		qdel(infection)
	for(var/egg in terror_eggs)
		qdel(egg)


/datum/team/terror_spiders/proc/delay_terror_win()
	delay_terror_end = TRUE

/datum/team/terror_spiders/proc/return_terror_win()
	delay_terror_end = FALSE

/datum/team/terror_spiders/proc/declare_results()
	if(SSticker?.mode?.station_was_nuked && !terror_stage == TERROR_STAGE_POST_END)
		to_chat(world, "<BR><FONT size = 3><B>Частичная победа Пауков Ужаса!</B></FONT>")
		to_chat(world, "<B>Станция была уничтожена!</B>")
		to_chat(world, "<B>Устройство самоуничтожения сработало, предотвратив распространение Пауков Ужаса.</B>")
	else if(protect_egg.check_completion(src))
		to_chat(world, "<BR><FONT size = 3><B>Полная победа Пауков Ужаса!</B></FONT>")
		to_chat(world, "<B>Пауки захватили станцию!</B>")
		to_chat(world, "<B>Императрица Ужаса появилась на свет, превратив всю станцию в гнездо.</B>")
	else if(!check_main_spiders())
		to_chat(world, "<BR><FONT size = 3><B>Полная победа персонала станции!</B></FONT>")
		to_chat(world, "<B>Экипаж защитил станцию от Пауков Ужаса!</B>")
		to_chat(world, "<B>Пауки Ужаса были истреблены.</B>")
	else
		to_chat(world, "<BR><FONT size = 3><B>Ничья!</B></FONT>")
		to_chat(world, "<B>Экипаж эвакуирован!</B>")
		to_chat(world, "<B>Пауки Ужаса не были истреблены.</B>")
	to_chat(world, "<B>Целями Пауков Ужаса было:</B>")
	if(prince_target)
		to_chat(world, "<br/>Цель Принца: [prince_target.explanation_text] [prince_target.completed?"<font color='green'><B>Успех!</B></font>": "<font color='red'>Провал.</font>"]")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[prince_target.type]", prince_target.completed? "SUCCESS" : "FAIL"))
	if(infect_target)
		to_chat(world, "<br/>Цель Осквернителя: [infect_target.explanation_text] [infect_target.completed?"<font color='green'><B>Успех!</B></font>": "<font color='red'>Провал.</font>"]")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[infect_target.type]", infect_target.completed? "SUCCESS" : "FAIL"))
	if(lay_eggs_target)
		to_chat(world, "<br/>Цель Принцессы/Королевы: [lay_eggs_target.explanation_text] [lay_eggs_target.completed?"<font color='green'><B>Успех!</B></font>": "<font color='red'>Провал.</font>"]")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[lay_eggs_target.type]", lay_eggs_target.completed? "SUCCESS" : "FAIL"))
	if(other_target)
		to_chat(world, "<br/>Цель Пауков Ужаса: [other_target.explanation_text] [other_target.completed?"<font color='green'><B>Успех!</B></font>": "<font color='red'>Провал.</font>"]")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[other_target.type]", other_target.completed? "SUCCESS" : "FAIL"))
	if(protect_egg)
		var/completed = protect_egg.completed && (!SSticker?.mode?.station_was_nuked || terror_stage == TERROR_STAGE_POST_END)
		to_chat(world, "<br/>Защита яйца: [protect_egg.explanation_text] [completed ?"<font color='green'><B>Успех!</B></font>": "<font color='red'>Провал.</font>"]")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[protect_egg.type]", completed ? "SUCCESS" : "FAIL"))
	return TRUE


/datum/team/terror_spiders/declare_completion()
	var/list/terror_queens = main_spiders[TERROR_QUEEN]
	var/list/terror_princes = main_spiders[TERROR_PRINCE]
	var/list/terror_princesses = main_spiders[TERROR_PRINCESS]
	var/list/terror_defilers = main_spiders[TERROR_DEFILER]

	if(terror_queens.len || terror_princes.len || terror_princesses.len || terror_defilers.len)
		declare_results()
		var/text = "<br/><FONT size = 2><B>Основа гнезда:</B></FONT>"
		text += "<br/><FONT size = 1><B>Королев[(terror_queens?.len > 1 ? "ами были" : "ой был")]:</B></FONT>"
		for(var/datum/mind/spider in terror_queens)
			text += "<br/><b>[spider.key]</b> был <b>[spider.name]</b>"
		text += "<br/><FONT size = 1><B>Принц[(terror_queens?.len > 1 ? "ами были" : "ем был")]:</B></FONT>"
		for(var/datum/mind/spider in terror_princes)
			text += "<br/><b>[spider.key]</b> был <b>[spider.name]</b>"
		text += "<br/><FONT size = 1><B>Принцесс[(terror_queens?.len > 1 ? "ами были" : "ой был")]:</B></FONT>"
		for(var/datum/mind/spider in terror_princesses)
			text += "<br/><b>[spider.key]</b> был <b>[spider.name]</b>"
		text += "<br/><FONT size = 1><B>Осквернител[(terror_queens?.len > 1 ? "ями были" : "ем был")]:</B></FONT>"
		for(var/datum/mind/spider in terror_defilers)
			text += "<br/><b>[spider.key]</b> был <b>[spider.name]</b>"
		text += "<br/><FONT size = 2><B>Паук[(members?.len > 1 ? "ами Ужаса были" : "ом Ужаса был")]:</B></FONT>"
		for(var/datum/mind/spider in members)
			text += "<br/><b>[spider.key]</b> был <b>[spider.name]</b>"
		to_chat(world, text)
	return TRUE

/datum/team/terror_spiders/get_admin_texts()
	. = ..()
	var/list/terror_queens = main_spiders[TERROR_QUEEN]
	var/list/terror_princes = main_spiders[TERROR_PRINCE]
	var/list/terror_princesses = main_spiders[TERROR_PRINCESS]
	var/list/terror_defilers = main_spiders[TERROR_DEFILER]
	if(terror_queens?.len || terror_princes?.len || terror_princesses?.len || terror_defilers?.len)
		if(check_rights(R_EVENT))
			. += "<br/><a href='byond://?_src_=holder;team_command=delay_terror_end;team=[UID()]'>Отложить победу Терроров</a> Сейчас: [delay_terror_end? "ON" : "OFF"]<br>"
		var/datum/admins/holder = usr.client.holder
		. += holder.check_role_table("Королевы", terror_queens)
		. += holder.check_role_table("Принцы", terror_princes)
		. += holder.check_role_table("Принцессы", terror_princesses)
		. += holder.check_role_table("Осквернители", terror_defilers)
		var/count_eggs = 0
		var/count_spiderlings = 0
		for(var/obj/structure/spider/eggcluster/terror_eggcluster/E in GLOB.ts_egg_list)
			if(is_station_level(E.z))
				count_eggs += E.spiderling_number
		for(var/obj/structure/spider/spiderling/terror_spiderling/L in GLOB.ts_spiderling_list)
			if(!L.stillborn && is_station_level(L.z))
				count_spiderlings += 1
		. += "<table cellspacing=5><TR><TD>Растущие ПУ на станции: яйца - [count_eggs], спайдерлинги - [count_spiderlings], зараженные гуманоиды - [terror_infections.len]. </TD></TR></TABLE>"

/datum/team/terror_spiders/admin_topic(comand)
	if(comand == "delay_terror_end")
		if(!check_rights(R_ADMIN) || !check_rights(R_EVENT))
			return

		if(!SSticker || !SSticker.mode)
			return

		if(tgui_alert(usr,"Вы действительно хотите [delay_terror_end? "вернуть" : "приостановить"] конец раунда в случае победы Пауков Ужаса?", "", list("Да", "Нет")) == "Нет")
			return

		if(!delay_terror_end)
			delay_terror_win()
		else
			return_terror_win()

		log_and_message_admins("has [delay_terror_end? "stopped" : "returned"] stopped delayed terror win")


/proc/create_terror_spiders(type, count)
	var/spider_type = get_spider_type(type)
	if(!spider_type)
		to_chat(usr, "Некорректный тип паука Ужаса.")
		return FALSE
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Паука Ужаса?", ROLE_TERROR_SPIDER, TRUE, 60 SECONDS, source = spider_type)
	if(length(candidates) < count)
		message_admins("Warning: not enough players volunteered to be terrors. Could only spawn [length(candidates)] out of [count]!")
		return FALSE
	var/successSpawn = FALSE
	while(count && length(candidates))
		var/mob/living/simple_animal/hostile/poison/terror_spider/spider = new spider_type(pick(GLOB.xeno_spawn))
		var/mob/ghost = pick_n_take(candidates)
		spider.key = ghost.key
		spider.add_datum_if_not_exist()
		count--
		successSpawn = TRUE
		log_game("[spider.key] has become [spider].")
	return successSpawn


/proc/get_spider_type(text_type)
	switch(text_type)
		if(TERROR_DEFILER)
			return /mob/living/simple_animal/hostile/poison/terror_spider/defiler
		if(TERROR_PRINCESS)
			return /mob/living/simple_animal/hostile/poison/terror_spider/queen/princess
		if(TERROR_QUEEN)
			return /mob/living/simple_animal/hostile/poison/terror_spider/queen
		if(TERROR_PRINCE)
			return /mob/living/simple_animal/hostile/poison/terror_spider/prince
		else
			return null
