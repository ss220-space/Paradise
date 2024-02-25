GLOBAL_VAR_INIT(security_level, 0)
//0 = code green
//1 = code blue
//2 = code red
//3 = gamma
//4 = epsilon
//5 = code delta

//config.alert_desc_blue_downto
GLOBAL_DATUM_INIT(security_announcement_up, /datum/announcement/priority/security, new(do_log = 0, do_newscast = 0, new_sound = sound('sound/misc/notice1.ogg')))
GLOBAL_DATUM_INIT(security_announcement_down, /datum/announcement/priority/security, new(do_log = 0, do_newscast = 0))


/proc/set_security_level(level)
	level = istext(level) ? seclevel2num(level) : level

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != GLOB.security_level)
		if(level >= SEC_LEVEL_RED && GLOB.security_level < SEC_LEVEL_RED)
			// Mark down this time to prevent shuttle cheese
			SSshuttle.emergency_sec_level_time = world.time

		switch(level)
			if(SEC_LEVEL_GREEN)
				GLOB.security_announcement_down.Announce("Все угрозы для станции устранены. Все оружие должно быть в кобуре, и законы о конфиденциальности вновь полностью соблюдаются.","ВНИМАНИЕ! Уровень угрозы понижен до ЗЕЛЁНОГО.")
				GLOB.security_level = SEC_LEVEL_GREEN
				unset_stationwide_emergency_lighting()
				if(SSshuttle.emergency.timer)
					post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
				else
					post_status(STATUS_DISPLAY_TIME)
				update_station_firealarms()

			if(SEC_LEVEL_BLUE)
				if(GLOB.security_level < SEC_LEVEL_BLUE)
					GLOB.security_announcement_up.Announce("На станции обнаружено присутствие враждебных элементов, представляющих незначительную угрозу экипажу и активам корпорации. Служба Безопасности может держать оружие на виду и использовать летальную силу в соответствии с рабочими процедурами отдела защиты активов.","ВНИМАНИЕ! Уровень угрозы повышен до СИНЕГО")
				else
					GLOB.security_announcement_down.Announce("Непосредственная угроза миновала. Служба безопасности может больше не держать оружие в полной боевой готовности, но может по-прежнему держать его на виду. Выборочные обыски запрещены.","ВНИМАНИЕ! Уровень угрозы понижен до СИНЕГО")
				GLOB.security_level = SEC_LEVEL_BLUE

				post_status(STATUS_DISPLAY_ALERT, "default")
				unset_stationwide_emergency_lighting()
				update_station_firealarms()

			if(SEC_LEVEL_RED)
				if(GLOB.security_level < SEC_LEVEL_RED)
					GLOB.security_announcement_up.Announce("На борту станции подтверждена серьезная угроза для экипажа и активов корпорации. Службе Безопасности рекомендуется иметь оружие в полной боевой готовности. Выборочные обыски разрешены и рекомендуются.","ВНИМАНИЕ! КОД КРАСНЫЙ!")
				else
					GLOB.security_announcement_down.Announce("Угроза уничтожения станции миновала, но враждебная активность остается на высоком уровне. Службе Безопасности рекомендуется иметь оружие в полной боевой готовности. Выборочные обыски разрешены.","ВНИМАНИЕ! КОД КРАСНЫЙ!")
					unset_stationwide_emergency_lighting()
				GLOB.security_level = SEC_LEVEL_RED
				var/obj/machinery/door/airlock/highsecurity/red/R = locate(/obj/machinery/door/airlock/highsecurity/red) in GLOB.airlocks
				if(R && is_station_level(R.z))
					R.locked = 0
					R.update_icon()

				post_status(STATUS_DISPLAY_ALERT, "redalert")
				update_station_firealarms()

			if(SEC_LEVEL_GAMMA)
				GLOB.security_announcement_up.Announce("Центральным Командованием был установлен Код Гамма. Станция находится под угрозой полного уничтожения. Службе безопасности следует получить полное вооружение и приготовиться к ведению боевых действий с враждебными элементами на борту станции. Гражданский персонал обязан немедленно обратиться к Главам отделов для получения дальнейших указаний.", "Внимание! Код ГАММА!", sound('sound/effects/new_siren.ogg'))
				GLOB.security_level = SEC_LEVEL_GAMMA

				if(GLOB.security_level < SEC_LEVEL_RED)
					for(var/obj/machinery/door/airlock/highsecurity/red/R in GLOB.airlocks)
						if(is_station_level(R.z))
							R.locked = 0
							R.update_icon()

				post_status(STATUS_DISPLAY_ALERT, "gammaalert")
				update_station_firealarms()

			if(SEC_LEVEL_EPSILON)
				for(var/mob/M in GLOB.player_list)
					var/turf/T = get_turf(M)
					if(!M.client || !is_station_level(T.z))
						continue
					SEND_SOUND(M, sound('sound/effects/powerloss.ogg'))
				set_stationwide_emergency_lighting()
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(epsilon_process)), 15 SECONDS)
				SSblackbox.record_feedback("tally", "security_level_changes", 1, level)
				return

			if(SEC_LEVEL_DELTA)
				GLOB.security_announcement_up.Announce("Механизм самоуничтожения станции задействован. Все члены экипажа обязан подчиняться всем указаниям, данными Главами отделов. Любые нарушения этих приказов наказуемы уничтожением на месте. Это не учебная тревога.","ВНИМАНИЕ! КОД ДЕЛЬТА!", new_sound = sound('sound/effects/deltaalarm.ogg'))
				GLOB.security_level = SEC_LEVEL_DELTA

				post_status(STATUS_DISPLAY_ALERT, "deltaalert")
				set_stationwide_emergency_lighting()
				update_station_firealarms()
				SSblackbox.record_feedback("tally", "security_level_changes", 1, level)
				return

		SSnightshift.check_nightshift(TRUE)
		SSblackbox.record_feedback("tally", "security_level_changes", 1, level)

		if(GLOB.sibsys_automode && !isnull(GLOB.sybsis_registry))
			for(var/obj/item/sibyl_system_mod/mod in GLOB.sybsis_registry)
				mod.sync_limit()


/proc/update_station_firealarms()
	for(var/obj/machinery/firealarm/alarm as anything in GLOB.firealarms)
		if(is_station_contact(alarm.z))
			alarm.update_icon()
			alarm.update_fire_light()


/proc/get_security_level()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_GAMMA)
			return "gamma"
		if(SEC_LEVEL_EPSILON)
			return "epsilon"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_GAMMA)
			return "gamma"
		if(SEC_LEVEL_EPSILON)
			return "epsilon"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(seclevel)
	switch(lowertext(seclevel))
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("gamma")
			return SEC_LEVEL_GAMMA
		if("epsilon")
			return SEC_LEVEL_EPSILON
		if("delta")
			return SEC_LEVEL_DELTA

/proc/get_security_level_ru()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return "ЗЕЛЕНЫЙ"
		if(SEC_LEVEL_BLUE)
			return "СИНИЙ"
		if(SEC_LEVEL_RED)
			return "КРАСНЫЙ"
		if(SEC_LEVEL_GAMMA)
			return "ГАММА"
		if(SEC_LEVEL_EPSILON)
			return "ЭПСИЛОН"
		if(SEC_LEVEL_DELTA)
			return "ДЕЛЬТА"


/proc/get_security_level_ru_colors()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return "<font color='limegreen'>Зелёный</font>"
		if(SEC_LEVEL_BLUE)
			return "<font color='dodgerblue'>Синий</font>"
		if(SEC_LEVEL_RED)
			return "<font color='red'>Красный</font>"
		if(SEC_LEVEL_GAMMA)
			return "<font color='gold'>Гамма</font>"
		if(SEC_LEVEL_EPSILON)
			return "<font color='blueviolet'>Эпсилон</font>"
		if(SEC_LEVEL_DELTA)
			return "<font color='orangered'>Дельта</font>"

/proc/get_security_level_l_range()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return 1
		if(SEC_LEVEL_BLUE)
			return 2
		if(SEC_LEVEL_RED)
			return 2
		if(SEC_LEVEL_GAMMA)
			return 2
		if(SEC_LEVEL_EPSILON)
			return 2
		if(SEC_LEVEL_DELTA)
			return 2

/proc/get_security_level_l_power()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return 1
		if(SEC_LEVEL_BLUE)
			return 2
		if(SEC_LEVEL_RED)
			return 2
		if(SEC_LEVEL_GAMMA)
			return 2
		if(SEC_LEVEL_EPSILON)
			return 2
		if(SEC_LEVEL_DELTA)
			return 2

/proc/get_security_level_l_color()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return COLOR_GREEN
		if(SEC_LEVEL_BLUE)
			return COLOR_ALARM_BLUE
		if(SEC_LEVEL_RED)
			return COLOR_RED_LIGHT
		if(SEC_LEVEL_GAMMA)
			return COLOR_AMBER
		if(SEC_LEVEL_EPSILON)
			return COLOR_WHITE
		if(SEC_LEVEL_DELTA)
			return COLOR_PURPLE

/proc/set_stationwide_emergency_lighting()
	for(var/A in GLOB.apcs)
		var/obj/machinery/power/apc/apc = A
		var/area/AR = get_area(apc)
		if(!is_station_level(apc.z))
			continue
		apc.emergency_lights = FALSE
		AR.area_emergency_mode = TRUE
		for(var/L in AR.lights_cache)
			var/obj/machinery/light/light = L
			if(light.status)
				continue
			if(GLOB.security_level == SEC_LEVEL_DELTA)
				light.fire_mode = TRUE
			light.on = FALSE
			light.emergency_mode = TRUE
			INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light, update), FALSE)

/proc/unset_stationwide_emergency_lighting()
	for(var/area/A as anything in GLOB.all_areas)
		if(!is_station_level(A.z))
			continue
		if(!A.area_emergency_mode)
			continue
		A.area_emergency_mode = FALSE
		for(var/L in A.lights_cache)
			var/obj/machinery/light/light = L
			if(A.fire)
				continue
			if(light.status)
				continue
			light.fire_mode = FALSE
			light.emergency_mode = FALSE
			light.on = TRUE
			INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light, update), FALSE)


/proc/epsilon_process()
	GLOB.security_announcement_up.Announce("Центральным командованием был установлен код ЭПСИЛОН. Все контракты расторгнуты.","ВНИМАНИЕ! КОД ЭПСИЛОН", new_sound = sound('sound/effects/epsilon.ogg'))
	GLOB.security_level = SEC_LEVEL_EPSILON
	post_status(STATUS_DISPLAY_ALERT, "epsilonalert")
	for(var/area/A as anything in GLOB.all_areas)
		if(!is_station_level(A.z))
			continue
		for(var/obj/machinery/light/light as anything in A.lights_cache)
			if(light.status)
				continue
			light.fire_mode = TRUE
			light.update()
	update_station_firealarms()
	GLOB.PDA_Manifest = list(\
					"heads" = list(),\
					"pro" = list(),\
					"sec" = list(),\
					"eng" = list(),\
					"med" = list(),\
					"sci" = list(),\
					"ser" = list(),\
					"sup" = list(),\
					"bot" = list(),\
					"misc" = list()\
					)
