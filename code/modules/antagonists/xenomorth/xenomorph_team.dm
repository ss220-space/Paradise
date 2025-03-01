/datum/team/xenomorph
	name = "Ксеноморфы"
	antag_datum_type = /datum/antagonist/xenomorph
	var/datum/mind/current_queen
	var/list/queens = list()
	var/datum/mind/current_empress
	var/datum/objective/xeno_get_power/xeno_power_objective
	var/datum/objective/create_queen/create_queen
	var/datum/objective/protect_queen/protect_queen
	var/datum/objective/protect_cocon/protect_cocon
	var/announce = FALSE
	var/evolves_count = 0
	var/grant_action = FALSE
	var/stage = XENO_STAGE_START
	var/delay_xeno_end = FALSE

/datum/team/xenomorph/New(list/starting_members)
	. = ..()
	create_queen = new
	create_queen.owner = src
	create_queen.team = src
	add_objective_to_members(create_queen)


/datum/team/xenomorph/add_member(datum/mind/new_member, add_objectives)
	var/is_queen = new_member?.current && isalienqueen(new_member.current)
	. = ..(new_member, !is_queen)
	RegisterSignal(new_member, COMSIG_ALIEN_EVOLVE, PROC_REF(on_alien_evolve))
	if(is_queen && !current_queen)
		add_queen(new_member)
	check_queen_power()

/datum/team/xenomorph/remove_member(datum/mind/new_member)
	UnregisterSignal(new_member, COMSIG_ALIEN_EVOLVE)
	. = ..()

/datum/team/xenomorph/add_objective_to_members(datum/objective/objective, member_blacklist = list(current_queen, current_empress))
	. = ..()


/datum/team/xenomorph/proc/on_alien_evolve(datum/mind/source, old_type, new_type)
	SIGNAL_HANDLER
	if(!istype(source))
		return
	if(ispath(old_type, LARVA_TYPE))
		evolves_count++
		check_announce()
		source.remove_antag_datum(/datum/antagonist/xenomorph)
		var/datum/antagonist/xenomorph/datum = new
		source.add_antag_datum(datum, type)

	if(ispath(new_type, QUEEN_TYPE))
		add_queen(source)

	if(ispath(new_type, EMPRESS_TYPE))
		current_empress = source
		evolve_end()

/datum/team/xenomorph/proc/add_queen(datum/mind/queen)
	current_queen = queen
	queens |= queen
	create_queen.completed = TRUE
	protect_queen = new
	protect_queen.owner = src
	protect_queen.team = src
	add_objective_to_members(protect_queen)
	xeno_power_objective = new
	xeno_power_objective.owner = src
	xeno_power_objective.team = src
	xeno_power_objective.generate_text()
	queen.remove_antag_datum(/datum/antagonist/xenomorph)
	var/datum/antagonist/xenomorph/queen/datum = new
	datum.objectives |= xeno_power_objective
	datum.team = src
	queen.add_antag_datum(datum, type)
	if(announce)
		SSshuttle?.add_hostile_environment(current_queen.current)

/datum/team/xenomorph/proc/check_queen_power()
	var/mob/queen_mob = current_queen?.current
	if(!grant_action && xeno_power_objective?.check_completion(src) && !isnull(queen_mob?.stat) && queen_mob.stat != DEAD)
		var/datum/action/innate/start_evolve_to_empress/evolve = new
		evolve.Grant(queen_mob)
		evolve.xeno_team = WEAKREF(src)
		grant_action = TRUE

/datum/team/xenomorph/proc/check_announce()
	if(announce)
		return TRUE
	var/crew_count = num_station_players()
	var/queen_exist = current_queen?.current && current_queen.current.stat != DEAD
	if(queen_exist && evolves_count > crew_count * EVOLVE_ANNOUNCE_TRIGGER)
		announce = TRUE
		announce()
		return TRUE
	return FALSE

/datum/team/xenomorph/proc/announce()
	GLOB.event_announcement.Announce("Вспышка биологической угрозы 4-го уровня зафиксирована на борту станции [station_name()]. Всему персоналу надлежит сдержать её распространение любой ценой! Особая директива распечатана на всех консолях связи.", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/effects/siren-spooky.ogg')
	SSticker?.mode?.special_directive()
	SSshuttle?.emergency.cancel()
	SSshuttle?.add_hostile_environment(current_queen.current)

/datum/team/xenomorph/proc/evolve_announce(area/loc)
	GLOB.event_announcement.Announce("Зафиксировано изменение организации улья, указывающее на начало трансформации в Императрицу Ксеноморфов. Обнаружено значительное скопление биоугрозы в [loc.name]. Уничтожте огранизм до окончания трансформации любой ценой.", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/effects/siren-spooky.ogg')

/datum/team/xenomorph/proc/win_announce()
	GLOB.event_announcement.Announce("Подтверждено наличие Императрицы Ксеноморфов на борту [station_name()]. Обнаружено загрязнение систем жизнеобеспечения. Станция переклассифицирована в гнездо биоугрозы 4-го уровня. Взведение устройства самоуничтожения персоналом или внешними силами в данный момент не представляется возможным. Активация протоколов изоляции.", "Отчёт об объекте [station_name()]")


/datum/team/xenomorph/proc/evolve_start(area/loc)
	protect_queen.completed = TRUE
	protect_cocon = new
	protect_cocon.owner = src
	protect_cocon.team = src
	protect_cocon.generate_text(loc)
	add_objective_to_members(protect_cocon)
	stage = XENO_STAGE_PROTECT_COCON
	addtimer(CALLBACK(src, PROC_REF(evolve_announce), loc), TIME_TO_ANNOUNCE)
	for(var/datum/mind/mind as anything in members)
		if(mind == current_queen || mind == current_empress)
			continue
		if(!mind?.current || mind.current.stat == DEAD)
			continue
		to_chat(mind.current, span_alien("Королева начала эволюционировать в [loc.name]. Она находится в стазисе внутри кокона и полностью беззащитна. Защитите её любой ценой."))

/datum/team/xenomorph/proc/evolve_end()
	RegisterSignal(SSdcs, COMSIG_GLOB_XENO_STORM_ENDED, PROC_REF(on_xeno_storm_ended))
	INVOKE_ASYNC(SSweather, TYPE_PROC_REF(/datum/controller/subsystem/weather, run_weather), /datum/weather/xeno_storm)
	protect_cocon.completed = TRUE
	stage = XENO_STAGE_STORM

/datum/team/xenomorph/proc/on_xeno_storm_ended()
	SIGNAL_HANDLER
	win_announce()
	stage = XENO_STAGE_END
	if(delay_xeno_end)
		stage = XENO_STAGE_POST_END
	else
		SSticker?.mode?.end_game()
	UnregisterSignal(SSdcs, COMSIG_GLOB_XENO_STORM_ENDED)

/datum/team/xenomorph/get_admin_texts()
	. = ..()
	if(current_queen)
		if(check_rights(R_EVENT))
			. += "<br/><a href='byond://?_src_=holder;team_command=delay_xeno_end;team=[UID()]'>Отложить победу Ксеноморфов</a> Сейчас: [delay_xeno_end? "ON" : "OFF"]<br>"
		var/datum/admins/holder = usr.client.holder
		. += holder.check_role_table("Королева", list(current_queen))


/datum/team/xenomorph/proc/declare_results()
	if(SSticker?.mode?.station_was_nuked && !stage == XENO_STAGE_POST_END)
		to_chat(world, "<BR><FONT size = 3><B>Частичная победа Ксеноморфов!</B></FONT>")
		to_chat(world, "<B>Станция была уничтожена!</B>")
		to_chat(world, "<B>Устройство самоуничтожения сработало, предотвратив распространение Ксеноморфов.</B>")
	else if(protect_cocon?.check_completion(src))
		to_chat(world, "<BR><FONT size = 3><B>Полная победа Ксеноморфов!</B></FONT>")
		to_chat(world, "<B>Ксеноморфы захватили станцию!</B>")
		to_chat(world, "<B>Императрица Ксеноморфов появилась на свет, превратив всю станцию в гнездо.</B>")
	else if(!current_queen?.current || current_queen.current.stat == DEAD)
		to_chat(world, "<BR><FONT size = 3><B>Полная победа персонала станции!</B></FONT>")
		to_chat(world, "<B>Экипаж защитил станцию от Ксеноморфов!</B>")
		to_chat(world, "<B>Ксеноморфы были истреблены.</B>")
	else
		to_chat(world, "<BR><FONT size = 3><B>Ничья!</B></FONT>")
		to_chat(world, "<B>Экипаж эвакуирован!</B>")
		to_chat(world, "<B>Ксеноморфы не были истреблены.</B>")

	to_chat(world, "<B>Целями Ксеноморфов было:</B>")

	if(xeno_power_objective)
		to_chat(world, "<br/>Цель Королевы: [xeno_power_objective.explanation_text] [xeno_power_objective.completed?"<font color='green'><B>Успех!</B></font>": "<font color='red'>Провал.</font>"]")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[xeno_power_objective.type]", xeno_power_objective.completed? "SUCCESS" : "FAIL"))
	if(create_queen)
		to_chat(world, "<br/>Создание королевы: [create_queen.explanation_text] [create_queen.completed?"<font color='green'><B>Успех!</B></font>": "<font color='red'>Провал.</font>"]")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[create_queen.type]", create_queen.completed? "SUCCESS" : "FAIL"))
	if(protect_queen)
		to_chat(world, "<br/>Защита королевы: [protect_queen.explanation_text] [protect_queen.completed?"<font color='green'><B>Успех!</B></font>": "<font color='red'>Провал.</font>"]")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[protect_queen.type]", protect_queen.completed? "SUCCESS" : "FAIL"))
	if(protect_cocon)
		to_chat(world, "<br/>Защита кокона: [protect_cocon.explanation_text] [protect_cocon.completed?"<font color='green'><B>Успех!</B></font>": "<font color='red'>Провал.</font>"]")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[protect_cocon.type]", protect_cocon.completed? "SUCCESS" : "FAIL"))
	return TRUE


/datum/team/xenomorph/declare_completion()
	if(members.len)
		declare_results()
		var/text = ""
		if(queens?.len)
			text += "<br/><FONT size = 2><B>Королев[(queens.len > 1 ? "ами были" : "ой была")]:</B></FONT>"
			for(var/datum/mind/queen in queens)
				text += "<br/><b>[queen.key]</b> был <b>[queen.name]</b>"
		text += "<br/><FONT size = 2><B>Ксеноморф[(members?.len > 1 ? "ами были" : "ом был")]:</B></FONT>"
		for(var/datum/mind/spider in members)
			text += "<br/><b>[spider.key]</b> был <b>[spider.name]</b>"
		to_chat(world, text)
	return TRUE

/datum/team/xenomorph/proc/delay_xeno_win()
	delay_xeno_end = TRUE

/datum/team/xenomorph/proc/return_xeno_win()
	delay_xeno_end = FALSE

/datum/team/xenomorph/admin_topic(comand)
	if(comand == "delay_xeno_end")
		if(!check_rights(R_ADMIN) || !check_rights(R_EVENT))
			return

		if(!SSticker || !SSticker.mode)
			return

		if(tgui_alert(usr,"Вы действительно хотите [delay_xeno_end? "вернуть" : "преостановить"] конец раунда в случае победы Ксеноморфов?", "", list("Да", "Нет")) == "Нет")
			return

		if(!delay_xeno_end)
			delay_xeno_win()
		else
			return_xeno_win()

		log_and_message_admins("has [delay_xeno_end? "stopped" : "returned"] stopped delayed xeno win")


/proc/spawn_aliens(spawn_count)
	var/spawn_vectors = tgui_alert(usr, "Какой тип ксеноморфа заспавнить?", "Тип ксеноморфов", list("Вектор", "Грудолом")) == "Вектор"
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	if(spawn_vectors)
		spawn_vectors(vents, spawn_count)
	else
		spawn_larvas(vents, spawn_count)

/proc/spawn_larvas(list/vents, spawncount)
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за Ксеноморфа?", ROLE_ALIEN, TRUE, source = /mob/living/carbon/alien/larva)
	var/first_spawn = TRUE
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/C = pick_n_take(candidates)
		if(C)
			GLOB.respawnable_list -= C
			var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
			new_xeno.evolution_points += (0.75 * new_xeno.max_evolution_points)	//event spawned larva start off almost ready to evolve.
			new_xeno.key = C.key

			if(first_spawn)
				new_xeno.queen_maximum++
				first_spawn = FALSE

			new_xeno.update_datum()

			spawncount--
			log_game("[new_xeno.key] has become [new_xeno].")

/proc/spawn_vectors(list/vents, spawncount)
	spawncount = 1
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за Ксеноморфа (Вектор)?", ROLE_ALIEN, TRUE, source = /mob/living/carbon/alien/humanoid/hunter/vector)
	var/first_spawn = TRUE
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/C = pick_n_take(candidates)
		if(C)
			GLOB.respawnable_list -= C
			var/mob/living/carbon/alien/humanoid/hunter/vector/new_xeno = new(vent.loc)
			new_xeno.key = C.key

			if(first_spawn)
				new_xeno.queen_maximum++
				first_spawn = FALSE
			new_xeno.update_datum()

			spawncount--
			log_game("[new_xeno.key] has become [new_xeno].")
