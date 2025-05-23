/datum/clockwork_objectives //It's mostly same as blood cult
	var/clock_status = RATVAR_IS_ASLEEP
	var/datum/objective/demand_power/obj_demand = new // I demand three things! Power beacons and clockers
	var/datum/objective/clockgod/obj_summon = new
	var/power_goal = 1
	var/beacon_goal = 1
	var/clocker_goal = 1

/datum/clockwork_objectives/proc/setup()
	if(clock_status != RATVAR_IS_ASLEEP)
		return FALSE
	clock_status = RATVAR_DEMANDS_POWER
	//power_goal in gamemode/clockwork_threshold_check
	beacon_goal = 3 + round(length(GLOB.player_list)*0.1) // 3 + all crew* 0.1
	obj_summon.owner = SSticker.mode
	obj_demand.owner = SSticker.mode
	clocker_goal = round(CLOCK_CREW_REVEAL_HIGH * (length(GLOB.player_list) - SSticker.mode.get_clockers()),1)
	if(obj_demand.check_completion())
		ratvar_is_ready()


/**
  * Called by cultists/cult constructs checking their objectives
  *
  * to_chats mob/living/M the currents status.
  *
  * * display_members set FALSE - additionally how many cult members.
  */
/datum/clockwork_objectives/proc/study(mob/living/M, display_members = FALSE)
	if(!M)
		return FALSE

	switch(clock_status)
		if(RATVAR_IS_ASLEEP)
			to_chat(M, span_clock("Ратвар спит."))
		if(RATVAR_DEMANDS_POWER)
			to_chat(M, span_clock("Ратвар ищет источник энергии на станции. Помогите ему преодолеть могущественную завесу!"))
			to_chat(M, span_clock("Текущие цели: "))
			if(!obj_demand.power_get)
				to_chat(M, span_clock("Нам надо набраться энергии. Необходимо энергии: [power_goal]. Текущее значение энергии: [GLOB.clockwork_power]"))
			if(!obj_demand.beacon_get)
				to_chat(M, span_clock("Маяки будут отмечать мягкие точки Завесы. Необходимо маяков: [beacon_goal]. Построено: [length(GLOB.clockwork_beacons)]"))
			if(!obj_demand.clockers_get)
				to_chat(M, span_clock("Пусть сила наших праведников проложит путь для нашего Ратвара! Необходимо праведников: [clocker_goal]. Сейчас нас: [SSticker.mode.get_clockers()]"))
		if(RATVAR_NEEDS_SUMMONING)
			to_chat(M, span_clock("Ратвар достаточно силён! Пора направить его мощь на слабое место Завесы!"))
			to_chat(M, span_clock("Текущая цель: [obj_summon.explanation_text]"))
		if(RATVAR_HAS_RISEN)
			to_chat(M, span_clocklarge("\"Я здесь.\""))
			to_chat(M, span_clock("Текущая цель:[span_clocklarge("\"Принесите мне еретиков.\"")]"))
		if(RATVAR_HAS_FALLEN)
			to_chat(M, span_clocklarge("Ратвар был изгнан!"))
			to_chat(M, span_clock("Текущая цель: Уничтожить неверных!"))
		else
			to_chat(M, span_danger("Ошибка: Статус цели культа часов неизвестен. Что-то пошло не так. Ой."))


	if(display_members)
		var/list/clock_cult = SSticker.mode.get_clockers(TRUE)
		var/total_clockers = clock_cult[1] + clock_cult[2]

		to_chat(M, span_clockitalic("<br><b>Сейчас нас: [total_clockers]</b>"))

		if(clock_cult[2]) // If there are any constructs, separate them out
			to_chat(M, span_clockitalic("Из которых:"))
			to_chat(M, span_clockitalic("  [clock_cult[1]] — <b>Праведники</b>"))
			to_chat(M, span_clockitalic("  [clock_cult[2]] — <b>Механизмы</b>"))

/*
 * Makes a check if power or beacon has been completed.
 *
 * The clockers check is in check_clock_size
 */
/datum/clockwork_objectives/proc/power_check()
	if(GLOB.clockwork_power >= power_goal && !obj_demand.power_get)
		obj_demand.power_get = TRUE
		for(var/datum/mind/clock_mind in SSticker.mode.clockwork_cult)
			if(clock_mind && clock_mind.current)
				to_chat(clock_mind.current, span_clocklarge("Да! Этой энергии достаточно для меня! Отличная работа..."))
				if(!obj_demand.check_completion())
					to_chat(clock_mind.current, span_clock("Но у нас всё еще много дел которые нужно закончить."))
				else
					ratvar_is_ready()
		adjust_clockwork_power(-0.6*power_goal)

/datum/clockwork_objectives/proc/beacon_check()
	if(length(GLOB.clockwork_beacons) >= beacon_goal && !obj_demand.beacon_get)
		obj_demand.beacon_get = TRUE
		for(var/datum/mind/clock_mind in SSticker.mode.clockwork_cult)
			if(clock_mind && clock_mind.current)
				to_chat(clock_mind.current, span_clocklarge("Я вижу слабые точки Завесы... Вы хорошо справляетесь..."))
				to_chat(clock_mind.current, span_clocklarge("Теперь я вижу слабые места Завесы. Вы хорошо поработали..."))
				if(!obj_demand.check_completion())
					to_chat(clock_mind.current, span_clock("Но у нас всё еще много дел которые нужно закончить."))
				else
					ratvar_is_ready()


// After all goals 've completed check this proc for start summoning
/datum/clockwork_objectives/proc/ratvar_is_ready()
	if(clock_status >= RATVAR_NEEDS_SUMMONING) //or already prepared or summoned
		return
	clock_status = RATVAR_NEEDS_SUMMONING
	for(var/datum/mind/clock_mind in SSticker.mode.clockwork_cult)
		if(clock_mind && clock_mind.current)
			to_chat(clock_mind.current, span_clock("Вы и ваши помощники преуспели в подготовке станции к главному ритуалу!"))
			to_chat(clock_mind.current, span_clock("Текущая цель: [obj_summon.explanation_text]"))

/datum/clockwork_objectives/proc/succesful_summon()
	clock_status = RATVAR_HAS_RISEN
	obj_summon.summoned = TRUE

/datum/clockwork_objectives/proc/ratvar_death()
	clock_status = RATVAR_HAS_FALLEN
	obj_summon.killed = TRUE

//Objectives

/datum/objective/serveclock //Given to clockers on conversion/roundstart
	explanation_text = "Помогите своим коллегам-культистам и Могучему Ратвару разорвать завесу! (Используйте действие «Изучение вуали», чтобы проверить свой прогресс.)"
	completed = TRUE
	needs_target = FALSE
	antag_menu_name = "Помогать культу Ратвара"

/datum/objective/demand_power
	var/power_get = FALSE
	var/beacon_get = FALSE
	var/clockers_get = FALSE
	needs_target = FALSE
	explanation_text = "Ратвару требуется сила, чтобы подготовить призыв"
	antag_menu_name = "Набрать силу"

/datum/objective/demand_power/check_anatag_menu_ability()
	return SSticker?.mode.clocker_objs.clock_status != RATVAR_IS_ASLEEP

/datum/objective/demand_power/check_completion()
	return (power_get && beacon_get && clockers_get) || completed


/datum/objective/clockgod
	needs_target = FALSE
	antag_menu_name = "Призвать Ратвара"
	var/summoned = FALSE
	var/killed = FALSE
	var/list/ritual_spots = list()

/datum/objective/clockgod/New()
	..()
	find_summon_locations()

/datum/objective/clockgod/check_anatag_menu_ability()
	return SSticker.mode.clocker_objs.clock_status != RATVAR_IS_ASLEEP

/datum/objective/clockgod/proc/find_summon_locations(reroll = FALSE)
	if(reroll)
		ritual_spots = new()
	var/sanity = 0
	while(length(ritual_spots) < RATVAR_SUMMON_POSSIBILITIES && sanity < 100)
		var/area/summon = pick(get_sorted_areas() - ritual_spots)
		var/valid_spot = FALSE
		if(summon && is_station_level(summon.z) && summon.valid_territory) // Check if there's a turf that you can walk on, if not it's not valid
			for(var/turf/T as anything in get_area_turfs(summon))
				if(!T.density)
					var/clear = TRUE
					for(var/obj/O in T)
						if(O.density)
							clear = FALSE
							break
					if(clear)
						valid_spot = TRUE
						break
		if(valid_spot)
			ritual_spots += summon
		sanity++
	explanation_text = "Призовите Ратвара установив свою веру и укрепив ее.\
	\nПризыв может быть осуществлен только в [english_list(ritual_spots)] - где завеса достаточно слаба, чтобы начать ритуал."

/datum/objective/clockgod/check_completion()
	if(killed)
		return RATVAR_HAS_FALLEN // You failed so hard that even the code went backwards.
	return summoned || completed
