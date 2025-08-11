/obj/machinery/computer/emergency_shuttle
	name = "emergency shuttle console"
	desc = "Для управления шаттлом."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	var/auth_need = 3
	var/list/authorized = list()


/obj/machinery/computer/emergency_shuttle/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	var/obj/item/card/id/id_card = I.GetID()
	if(id_card)
		add_fingerprint(user)
		if(stat & (NOPOWER|BROKEN))
			to_chat(user, span_warning("Консоль сломана или обесточена."))
			return ATTACK_CHAIN_PROCEED
		if(SSshuttle.emergency.mode != SHUTTLE_DOCKED)
			to_chat(user, span_warning("В настоящее время шаттл находится в пути."))
			return ATTACK_CHAIN_PROCEED
		if(SSshuttle.emergency.timeLeft() <= 10)
			to_chat(user, span_warning("Шаттл сейчас недоступен."))
			return ATTACK_CHAIN_PROCEED
		if(!islist(id_card.access) || !length(id_card.access)) //no access
			to_chat(user, span_warning("Недостаточный уровень доступа."))
			return ATTACK_CHAIN_PROCEED
		if(!(ACCESS_HEADS in id_card.access)) //doesn't have this access
			to_chat(user, span_warning("Недостаточный уровень доступа."))
			return ATTACK_CHAIN_PROCEED

		var/choice = tgui_alert(user, "Вы хотите (де)авторизовать досрочный запуск? [auth_need - length(authorized)] авторизаци[declension_ru(auth_need - length(authorized), "ю", "и", "й")] всё ещё необходима. Используйте команду 'Abort', чтобы отозвать все авторизации.", "Shuttle Launch", list("Authorize", "Repeal", "Abort"))
		if(!choice || !Adjacent(user) || QDELETED(id_card) || id_card.loc != user || SSshuttle.emergency.mode != SHUTTLE_DOCKED)
			return ATTACK_CHAIN_PROCEED

		var/seconds_left = SSshuttle.emergency.timeLeft()
		if(seconds_left <= 10)
			return ATTACK_CHAIN_PROCEED

		switch(choice)
			if("Authorize")
				if(!authorized.Find(id_card.registered_name))
					authorized += id_card.registered_name
					if(auth_need - length(authorized) > 0)
						message_admins("[key_name_admin(user)] has authorized early shuttle launch.")
						add_game_logs("has authorized early shuttle launch in [COORD(src)]", user)
						GLOB.minor_announcement.announce("Осталось получить [auth_need - length(authorized)] авторизаци[declension_ru(auth_need - length(authorized), "ю", "и", "й")] для досрочного запуска шаттла.")
					else
						message_admins("[key_name_admin(user)] has launched the emergency shuttle [seconds_left] seconds before launch.")
						add_game_logs("has launched the emergency shuttle in [COORD(src)] [seconds_left] seconds before launch.", user)
						GLOB.minor_announcement.announce("До запуска эвакуационного шаттла осталось 10 секунд.")
						SSshuttle.emergency.setTimer(100)

			if("Repeal")
				if(authorized.Remove(id_card.registered_name))
					GLOB.minor_announcement.announce("Для досрочного запуска шаттла необходимо получить [auth_need - length(authorized)] авторизаци[declension_ru(auth_need - length(authorized), "ю", "и", "й")].")

			if("Abort")
				if(authorized.len)
					GLOB.minor_announcement.announce("Все авторизации на досрочный запуск шаттла были отозваны.")
					authorized.Cut()

		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/computer/emergency_shuttle/emag_act(mob/user)
	if(!emagged && SSshuttle.emergency.mode == SHUTTLE_DOCKED && user)
		var/time = SSshuttle.emergency.timeLeft()
		add_attack_logs(user, src, "emagged")
		message_admins("[key_name_admin(user)] has emagged the emergency shuttle: [time] seconds before launch.")
		add_game_logs("has emagged the emergency shuttle in [COORD(src)]: [time] seconds before launch.", user)
		GLOB.minor_announcement.announce("Запуск эвакуационного шаттла через 10 секунд",
										"СИСТЕМНАЯ ОШИБКА:"
		)
		SSshuttle.emergency.setTimer(100)
		emagged = 1


/obj/docking_port/mobile/emergency
	name = "emergency shuttle"
	id = "emergency"

	dwidth = 9
	width = 22
	height = 11
	dir = 4
	roundstart_move = "emergency_away"
	var/sound_played = 0 //If the launch sound has been sent to all players on the shuttle itself

	var/canRecall = TRUE //no bad condom, do not recall the crew transfer shuttle!
	var/forceHijacked = FALSE // forced change of arrival at the syndicate base
	var/devil_on_shuttle = FALSE


/obj/docking_port/mobile/emergency/register()
	if(!..())
		return 0 //shuttle master not initialized

	SSshuttle.emergency = src
	return 1

/obj/docking_port/mobile/emergency/Destroy(force)
	if(force)
		// This'll make the shuttle subsystem use the backup shuttle.
		if(SSshuttle.emergency == src)
			// If we're the selected emergency shuttle
			SSshuttle.emergencyDeregister()


	return ..()

/obj/docking_port/mobile/emergency/request(obj/docking_port/stationary/S, coefficient=1, area/signalOrigin, reason, redAlert)
	var/call_time = SSshuttle.emergencyCallTime * coefficient
	switch(mode)
		// The shuttle can not normally be called while "recalling", so
		// if this proc is called, it's via admin fiat
		if(SHUTTLE_RECALL, SHUTTLE_IDLE, SHUTTLE_CALL)
			mode = SHUTTLE_CALL
			setTimer(call_time)
		else
			return

	if(prob(70))
		SSshuttle.emergencyLastCallLoc = signalOrigin
	else
		SSshuttle.emergencyLastCallLoc = null
	if(canRecall)
		GLOB.major_announcement.announce(
			"Был вызван эвакуационный шаттл. [redAlert ? "Красный уровень угрозы подтверждён: отправлен приоритетный шаттл. " : "" ]Он прибудет в течение [timeLeft(600)] минут.[reason][SSshuttle.emergencyLastCallLoc ? "\n\nВызов шаттла отслежен. Результаты можно посмотреть на любой консоли связи." : "" ]",
			new_title = ANNOUNCE_PRIORITY_RU,
			new_sound = sound('sound/AI/eshuttle_call.ogg')
		)
	else
		GLOB.major_announcement.announce(
			"Был вызван тра+нспортный шаттл. [redAlert ? "Красный уровень угрозы подтверждён: отправлен приоритетный шаттл. " : "" ]Он прибудет в течение [timeLeft(600)] минут.[reason]",
			new_title = ANNOUNCE_PRIORITY_RU,
			new_sound = sound('sound/AI/cshuttle.ogg')
		)

/obj/docking_port/mobile/emergency/cancel(area/signalOrigin)
	if(!canRecall)
		return

	if(mode != SHUTTLE_CALL)
		return

	invertTimer()
	mode = SHUTTLE_RECALL

	if(prob(70))
		SSshuttle.emergencyLastCallLoc = signalOrigin
	else
		SSshuttle.emergencyLastCallLoc = null
	GLOB.major_announcement.announce(
		"Эвакуационный шаттл был отозван.[SSshuttle.emergencyLastCallLoc ? " Отзыв шаттла отслежен. Результаты можно посмотреть на любой консоли связи." : "" ]",
		new_title = ANNOUNCE_PRIORITY_RU,
		new_sound = sound('sound/AI/eshuttle_recall.ogg')
	)

/obj/docking_port/mobile/emergency/proc/is_hijacked()
	for(var/mob/living/player in GLOB.player_list)
		if(!player.mind)
			continue
		if(player.stat == DEAD)  // Corpses
			continue
		if(issilicon(player)) //Borgs are technically dead anyways
			continue
		if(isanimal(player)) //Poly does not own the shuttle
			continue
		if(isascendeddevil(player))
			devil_on_shuttle = TRUE
			continue
		if(isbrain(player))
			continue
		if(ishuman(player)) //hostages allowed on the shuttle, check for restraints
			var/mob/living/carbon/human/H = player
			if(!H.check_death_method() && H.health <= HEALTH_THRESHOLD_DEAD) //new crit users who are in hard crit are considered dead
				continue
			if(H.handcuffed) //cuffs
				continue
			if(H.wear_suit && H.wear_suit.breakout_time) //straight jacket
				continue
			if(istype(H.loc, /obj/structure/closet)) //locked/welded locker, all aboard the clown train honk honk
				var/obj/structure/closet/C = H.loc
				if(C.welded || C.locked)
					continue
		var/special_role = player.mind.special_role
		if(special_role)
			// There's a long list of special roles, but almost all of them are antags anyway.
			// If you manage to escape with a pet slaughter demon - go for it! Greentext well earned!
			if(special_role != SPECIAL_ROLE_EVENTMISC && special_role != SPECIAL_ROLE_ERT && special_role != SPECIAL_ROLE_DEATHSQUAD)
				continue

		if(get_area(player) == areaInstance)
			return FALSE

	return TRUE


/obj/docking_port/mobile/emergency/check()
	if(!timer)
		return

	var/time_left = timeLeft(1)

	// The emergency shuttle doesn't work like others so this
	// ripple check is slightly different
	if(!ripples.len && (time_left <= SHUTTLE_RIPPLE_TIME) && ((mode == SHUTTLE_CALL) || (mode == SHUTTLE_ESCAPE)))
		var/destination
		if(mode == SHUTTLE_CALL)
			destination = SSshuttle.getDock("emergency_home")
		else if(mode == SHUTTLE_ESCAPE)
			destination = SSshuttle.getDock("emergency_away")
		create_ripples(destination)

	switch(mode)
		if(SHUTTLE_RECALL)
			if(time_left <= 0)
				mode = SHUTTLE_IDLE
				timer = 0
		if(SHUTTLE_CALL)
			if(time_left <= 0)
				//move emergency shuttle to station
				if(dock(SSshuttle.getDock("emergency_home")))
					setTimer(20)
					return
				mode = SHUTTLE_DOCKED
				setTimer(SSshuttle.emergencyDockTime)
				if(canRecall)
					GLOB.major_announcement.announce(
						"Эвакуационный шаттл совершил стыковку со станцией. У вас есть [timeLeft(600)] минуты, чтобы взобраться на борт эвакуационного шаттла.",
						new_title = ANNOUNCE_PRIORITY_RU,
						new_sound = sound('sound/AI/eshuttle_dock.ogg')
					)
				else
					GLOB.major_announcement.announce(
						"Транспортный шаттл совершил стыковку со станцией. У вас есть [timeLeft(600)] минуты, чтобы взобраться на борт транспортного шаттла.",
						new_title = ANNOUNCE_PRIORITY_RU,
						new_sound = sound('sound/AI/cshuttle_dock.ogg')
					)
		if(SHUTTLE_DOCKED)

			if(time_left <= 0 && SSshuttle.hostile_environment.len)
				GLOB.major_announcement.announce(
					"Обнаружена угроза. Отлёт отложен на неопределённый срок до разрешения конфликта.",
					new_title = ANNOUNCE_PRIORITY_RU
				)
				sound_played = 0
				mode = SHUTTLE_STRANDED

			if(time_left <= 0 && SSshuttle.emergencyNoEscape && mode != SHUTTLE_STRANDED)
				GLOB.major_announcement.announce(
					"Шаттл заблокирован. Свяжитесь с Центральным командованием для уточнения причин и снятия блокировки.",
					new_title = ANNOUNCE_PRIORITY_RU
				)
				sound_played = 0
				mode = SHUTTLE_STRANDED

			if(time_left <= 100) // 9 seconds left - start requesting transit zones for emergency and pods
				for(var/obj/docking_port/mobile/pod/M in SSshuttle.mobile)
					M.check_transit_zone() // yeah, we even check for pods that aren't at station. just for safety
				check_transit_zone()

			if(time_left <= 50 && !sound_played) //4 seconds left - should sync up with the launch
				sound_played = 1
				var/hyperspace_sound = sound('sound/effects/hyperspace_begin.ogg')
				for(var/area/shuttle/escape/E in GLOB.areas)
					SEND_SOUND(E, hyperspace_sound)

			if(time_left <= 0 && !(SSshuttle.emergencyNoEscape || SSshuttle.hostile_environment.len))
				//move each escape pod to its corresponding transit dock
				for(var/obj/docking_port/mobile/pod/M in SSshuttle.mobile)
					if(is_station_level(M.z)) //Will not launch from the mine/planet
						M.enterTransit()
				//now move the actual emergency shuttle to its transit dock
				var/hyperspace_progress_sound = sound('sound/effects/hyperspace_progress.ogg')
				for(var/area/shuttle/escape/E in world)
					SEND_SOUND(E, hyperspace_progress_sound)
				enterTransit()
				mode = SHUTTLE_ESCAPE
				setTimer(SSshuttle.emergencyEscapeTime)
				GLOB.major_announcement.announce(
					"Эвакуационный шаттл покинул станцию. До прибытия в доки ЦК осталось [timeLeft(600)] минуты.",
					new_title = ANNOUNCE_PRIORITY_RU
				)
				for(var/mob/M in GLOB.player_list)
					if(!isnewplayer(M) && !M.client.karma_spent && !(M.client.ckey in GLOB.karma_spenders) && !M.get_preference(PREFTOGGLE_DISABLE_KARMA_REMINDER))
						to_chat(M, "<i>You have not yet spent your karma for the round; was there a player worthy of receiving your reward? Look under Special Verbs tab, Award Karma.</i>")

		if(SHUTTLE_ESCAPE)
			if(time_left <= 0)
				//move each escape pod to its corresponding escape dock
				for(var/obj/docking_port/mobile/pod/M in SSshuttle.mobile)
					M.dock(SSshuttle.getDock("[M.id]_away"))

				var/hyperspace_end_sound = sound('sound/effects/hyperspace_end.ogg')
				for(var/area/shuttle/escape/E in GLOB.areas)
					SEND_SOUND(E, hyperspace_end_sound)

				// now move the actual emergency shuttle to centcomm
				// unless the shuttle is "hijacked"
				var/destination_dock = "emergency_away"
				if(is_hijacked() || forceHijacked)
					destination_dock = "emergency_syndicate"
					GLOB.major_announcement.announce(
						"Обнаружен взлом навигационных протоколов. Пожалуйста, свяжитесь в руководством.",
						new_title = ANNOUNCE_PRIORITY_RU
					)

				if(devil_on_shuttle)
					GLOB.major_announcement.announce("Обнаружен сбой навигационных протоколов. Эвакуационный шаттл сошёл с установленного маршрута и движется в неизвестном направлении.",
													new_title = ANNOUNCE_PRIORITY_RU
					)
				else
					dock_id(destination_dock)

				mode = SHUTTLE_ENDGAME
				timer = 0

// This basically opens a big-ass row of blast doors when the shuttle arrives at centcom
/obj/docking_port/mobile/pod
	name = "escape pod"
	id = "pod"

	dwidth = 2
	width = 5
	height = 6

/obj/docking_port/mobile/pod/New()
	..()
	if(id == "pod")
		log_runtime(EXCEPTION("[type] id has not been changed from the default. Use the id convention \"pod1\" \"pod2\" etc."))

/obj/docking_port/mobile/pod/cancel()
	return

/obj/machinery/computer/shuttle/pod
	name = "pod control computer"
	admin_controlled = 1
	shuttleId = "pod"
	possible_destinations = "pod_asteroid"
	icon = 'icons/obj/machines/terminals.dmi'
	icon_state = "dorm_available"
	density = FALSE


/obj/machinery/computer/shuttle/pod/update_icon_state()
	icon_state = "dorm_[emagged ? "emag" : "available"]"


/obj/machinery/computer/shuttle/pod/update_overlays()
	. = list()


/obj/machinery/computer/shuttle/pod/emag_act(mob/user)
	if(user)
		to_chat(user, "<span class='warning'> Access requirements overridden. The pod may now be launched manually at any time.</span>")
	admin_controlled = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/docking_port/stationary/random
	name = "escape pod"
	id = "pod"
	dwidth = 1
	width = 3
	height = 4
	var/target_area = /area/mine/unexplored

/obj/docking_port/stationary/random/Initialize()
	..()
	var/list/turfs = get_area_turfs(target_area)
	var/turf/T = pick(turfs)
	src.loc = T

/obj/docking_port/mobile/emergency/backup
	name = "backup shuttle"
	id = "backup"
	dwidth = 2
	width = 8
	height = 8
	dir = 4

	roundstart_move = "backup_away"

/obj/docking_port/mobile/emergency/backup/register()
	var/current_emergency = SSshuttle.emergency
	..()
	SSshuttle.emergency = current_emergency
	SSshuttle.backup_shuttle = src
