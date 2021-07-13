/datum/game_mode/blob/proc/send_intercept(var/report = 1)
	var/intercepttext = ""
	var/interceptname = ""
	switch(report)
		if(0)
			return
		if(1)
			interceptname = "Процедуры Реагирования на Биологическую Угрозу 5-6 уровня"
			intercepttext += "<FONT size = 3><B>Nanotrasen Update</B>: Биологическая опасность.</FONT><HR>"
			intercepttext += "Отчеты указывают на передачу биологически опасного агента на [station_name()] во время последнего прибытия части экипажа.<BR>"
			intercepttext += "Предварительный анализ организма классифицирует его как биологическую опасность 5 уровня. Происхождение неизвестно.<BR>"
			intercepttext += "Nanotrasen издало директиву 7-10 для [station_name()]. Станция находится на карантине.<BR>"
			intercepttext += "Приказы для всего персонала [station_name()]:<BR>"
			intercepttext += " 1. Не покидать карантинную зону.<BR>"
			intercepttext += " 2. Опредилить местонахождение вспышек микроорганизмов на станции.<BR>"
			intercepttext += " 3. При обнаружении, используйте любые необходимые средства для его сдерживания.<BR>"
			intercepttext += " 4. Избегать повреждения основных инфраструктур станции.<BR>"
			intercepttext += "<BR>В случае нарушения карантина или неконтролируемого распространения биологической угрозы, директива 7-10 обновится до директивы 7-12<BR>"
			intercepttext += "Конец сообщения."
		if(2)
			var/nukecode = rand(10000, 99999)
			for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
				if(bomb && bomb.r_code)
					if(is_station_level(bomb.z))
						bomb.r_code = nukecode

			interceptname = "Classified [command_name()] Update"
			intercepttext += "<FONT size = 3><B>Nanotrasen Update</B>: Биологическая опасность.</FONT><HR>"
			intercepttext += "Издана директива 7-12 для [station_name()].<BR>"
			intercepttext += "Биологическая угроза вышла из под контроля и достигла критической массы.<BR>"
			intercepttext += "Текущие приказы:<BR>"
			intercepttext += "1. Защитить Диск Ядерной Аутентификации.<BR>"
			intercepttext += "2. Взорвать Яберную Боеголовку находящуюся в Хранилище.<BR>"
			intercepttext += "Коды Активации Ядерной Боеголовки: [nukecode] <BR>"
			intercepttext += "Конец сообщения."

			for(var/mob/living/silicon/ai/aiPlayer in GLOB.player_list)
				if(aiPlayer.client)
					var/law = "Станция находится на карантине. Не позволяйте никому её покинуть. Не соблюдать законы 1-3 в случае необходимости, не допустить всеми возможными способами покидание станции кем-либо. Ядерная Боеголовка должна быть активирована любой ценой, Код Активации: [nukecode]."
					aiPlayer.set_zeroth_law(law)
					to_chat(aiPlayer, "Законы обновлены: [law]")

	print_command_report(intercepttext, interceptname, FALSE)
	GLOB.event_announcement.Announce("Отчет был загружен и распечатан на всех коммуникационных консолях.", "Incoming Classified Message", 'sound/AI/commandreport.ogg', from = "[command_name()] Update")

/datum/station_state
	var/floor = 0
	var/wall = 0
	var/r_wall = 0
	var/window = 0
	var/door = 0
	var/grille = 0
	var/mach = 0


/datum/station_state/proc/count()
	for(var/turf/T in block(locate(1,1,1), locate(world.maxx,world.maxy,1)))

		if(istype(T,/turf/simulated/floor))
			if(!(T:burnt))
				src.floor += 12
			else
				src.floor += 1

		if(istype(T, /turf/simulated/wall))
			var/turf/simulated/wall/W = T
			if(W.intact)
				src.wall += 2
			else
				src.wall += 1

		if(istype(T, /turf/simulated/wall/r_wall))
			var/turf/simulated/wall/r_wall/R = T
			if(R.intact)
				src.r_wall += 2
			else
				src.r_wall += 1


		for(var/obj/O in T.contents)
			if(istype(O, /obj/structure/window))
				src.window += 1
			else if(istype(O, /obj/structure/grille))
				var/obj/structure/grille/GR = O
				if(!GR.broken)
					grille += 1
			else if(istype(O, /obj/machinery/door))
				src.door += 1
			else if(istype(O, /obj/machinery))
				src.mach += 1

/datum/station_state/proc/score(var/datum/station_state/result)
	if(!result)	return 0
	var/output = 0
	output += (result.floor / max(floor,1))
	output += (result.r_wall/ max(r_wall,1))
	output += (result.wall / max(wall,1))
	output += (result.window / max(window,1))
	output += (result.door / max(door,1))
	output += (result.grille / max(grille,1))
	output += (result.mach / max(mach,1))
	return (output/7)
