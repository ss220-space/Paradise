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
						GLOB.minor_announcement.announce(
							message = "Осталось получить [auth_need - length(authorized)] авторизаци[declension_ru(auth_need - length(authorized), "ю", "и", "й")] для досрочного запуска шаттла."
						)
					else
						message_admins("[key_name_admin(user)] has launched the emergency shuttle [seconds_left] seconds before launch.")
						add_game_logs("has launched the emergency shuttle in [COORD(src)] [seconds_left] seconds before launch.", user)
						GLOB.minor_announcement.announce(
							message = "До запуска эвакуационного шаттла осталось 10 секунд."
						)
						SSshuttle.emergency.setTimer(100)

			if("Repeal")
				if(authorized.Remove(id_card.registered_name))
					GLOB.minor_announcement.announce(
						message = "Для досрочного запуска шаттла необходимо получить [auth_need - length(authorized)] авторизаци[declension_ru(auth_need - length(authorized), "ю", "и", "й")]."
					)

			if("Abort")
				if(length(authorized))
					GLOB.minor_announcement.announce(
						message = "Все авторизации на досрочный запуск шаттла были отозваны."
					)
					authorized.Cut()

		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/machinery/computer/emergency_shuttle/emag_act(mob/user)
	if(!emagged && SSshuttle.emergency.mode == SHUTTLE_DOCKED && user)
		var/time = SSshuttle.emergency.timeLeft()
		add_attack_logs(user, src, "emagged")
		message_admins("[key_name_admin(user)] has emagged the emergency shuttle: [time] seconds before launch.")
		add_game_logs("has emagged the emergency shuttle in [COORD(src)]: [time] seconds before launch.", user)
		GLOB.minor_announcement.announce(
			message = "Запуск эвакуационного шаттла через 10 секунд",
			new_title = "СИСТЕМНАЯ ОШИБКА:"
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
	/// If the launch sound has been sent to all players on the shuttle itself
	var/sound_played = FALSE
	/// No bad condom, do not recall the crew transfer shuttle!
	var/canRecall = TRUE
	/// Forced change of arrival at the syndicate base
	var/force_hijacked = FALSE
	/// Is devil on shuttle?
	var/devil_on_shuttle = FALSE
	var/overmap_leg_started = FALSE
	var/overmap_escape_dock
	var/nav_emag_paused_left
	var/nav_emag_paused_dock

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
	if(istype(S, /obj/docking_port/stationary/transit))
		return ..(S)
	var/call_time = SSshuttle.emergencyCallTime * coefficient
	switch(mode)
		// The shuttle can not normally be called while "recalling", so
		// if this proc is called, it's via admin fiat
		if(SHUTTLE_RECALL, SHUTTLE_IDLE, SHUTTLE_CALL)
			mode = SHUTTLE_CALL
			overmap_leg_started = FALSE
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
			new_sound = ANNOUNCER_SHUTTLECALLED
		)
	else
		GLOB.major_announcement.announce(
			"Был вызван тра+нспортный шаттл. [redAlert ? "Красный уровень угрозы подтверждён: отправлен приоритетный шаттл. " : "" ]Он прибудет в течение [timeLeft(600)] минут.[reason]",
			new_title = ANNOUNCE_PRIORITY_RU,
			new_sound = ANNOUNCER_SHUTTLECALLED
		)

/obj/docking_port/mobile/emergency/cancel(area/signalOrigin)
	if(!canRecall)
		return

	if(mode != SHUTTLE_CALL)
		return

	if(overmap_leg_started)
		var/obj/overmap/entity/vessel = SSovermap?.shuttle_vessels[src]
		vessel?.abort_programmed_mission()
		overmap_follow_programmed_leg("emergency_away")
		overmap_leg_started = FALSE
		mode = SHUTTLE_IDLE
		timer = 0
		GLOB.major_announcement.announce(
			"Эвакуационный шаттл был отозван.[SSshuttle.emergencyLastCallLoc ? " Отзыв шаттла отслежен. Результаты можно посмотреть на любой консоли связи." : "" ]",
			new_title = ANNOUNCE_PRIORITY_RU,
			new_sound = ANNOUNCER_SHUTTLERECALLED
		)
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
		new_sound = ANNOUNCER_SHUTTLERECALLED
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
			if(iscloset(H.loc)) //locked/welded locker, all aboard the clown train honk honk
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
	if(is_nav_emagged())
		return
	if(!timer)
		return

	var/time_left = timeLeft(1)

	// The emergency shuttle doesn't work like others so this
	// ripple check is slightly different
	if(!length(ripples) && !overmap_leg_started && (time_left <= SHUTTLE_RIPPLE_TIME) && ((mode == SHUTTLE_CALL) || (mode == SHUTTLE_ESCAPE)))
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
			if(overmap_leg_started || time_left <= 0)
				var/overmap_result = overmap_follow_programmed_leg("emergency_home")
				if(isnull(overmap_result))
					overmap_leg_started = TRUE
					return
				if(overmap_result == FALSE)
					if(dock(SSshuttle.getDock("emergency_home")))
						setTimer(20)
						return
				overmap_leg_started = FALSE
				mode = SHUTTLE_DOCKED
				setTimer(SSshuttle.emergencyDockTime)
				if(canRecall)
					GLOB.major_announcement.announce(
						"Эвакуационный шаттл совершил стыковку со станцией. У вас есть [timeLeft(600)] минуты, чтобы взобраться на борт эвакуационного шаттла.",
						new_title = ANNOUNCE_PRIORITY_RU,
						new_sound = ANNOUNCER_SHUTTLEDOCK
					)
				else
					GLOB.major_announcement.announce(
						"Транспортный шаттл совершил стыковку со станцией. У вас есть [timeLeft(600)] минуты, чтобы взобраться на борт транспортного шаттла.",
						new_title = ANNOUNCE_PRIORITY_RU,
						new_sound = ANNOUNCER_SHUTTLEDOCK
					)
		if(SHUTTLE_DOCKED)

			if(time_left <= 0 && length(SSshuttle.hostile_environment))
				GLOB.major_announcement.announce(
					"Обнаружена угроза. Отлёт отложен на неопределённый срок до разрешения конфликта.",
					new_title = ANNOUNCE_PRIORITY_RU
				)
				sound_played = FALSE
				mode = SHUTTLE_STRANDED

			if(time_left <= 0 && SSshuttle.emergencyNoEscape && mode != SHUTTLE_STRANDED)
				GLOB.major_announcement.announce(
					"Шаттл заблокирован. Свяжитесь с Центральным командованием для уточнения причин и снятия блокировки.",
					new_title = ANNOUNCE_PRIORITY_RU
				)
				sound_played = FALSE
				mode = SHUTTLE_STRANDED

			if(time_left <= 100) // 9 seconds left - start requesting transit zones for emergency and pods
				for(var/obj/docking_port/mobile/pod/M in SSshuttle.mobile)
					M.check_transit_zone() // yeah, we even check for pods that aren't at station. just for safety
				check_transit_zone()

			if(time_left <= 50 && !sound_played) //4 seconds left - should sync up with the launch
				sound_played = TRUE
				var/hyperspace_sound = sound('sound/effects/hyperspace_begin.ogg')
				for(var/area/shuttle/escape/E in GLOB.areas)
					SEND_SOUND(E, hyperspace_sound)

			if(time_left <= 0 && !(SSshuttle.emergencyNoEscape || length(SSshuttle.hostile_environment)))
				overmap_launch_escape_pods()
				var/hyperspace_progress_sound = sound('sound/effects/hyperspace_progress.ogg')
				for(var/area/shuttle/escape/E in world)
					SEND_SOUND(E, hyperspace_progress_sound)
				var/destination_dock = "emergency_away"
				overmap_escape_dock = destination_dock
				mode = SHUTTLE_ESCAPE
				overmap_leg_started = TRUE
				var/overmap_result = overmap_follow_programmed_leg(destination_dock)
				if(overmap_result == FALSE)
					enterTransit()
					setTimer(SSshuttle.emergencyEscapeTime)
				GLOB.major_announcement.announce(
					"Эвакуационный шаттл покинул станцию. До прибытия в доки ЦК осталось [timeLeft(600)] минуты.",
					new_title = ANNOUNCE_PRIORITY_RU
				)

		if(SHUTTLE_ESCAPE)
			if(overmap_leg_started || time_left <= 0)
				overmap_launch_escape_pods()
				var/destination_dock = overmap_escape_dock || "emergency_away"
				var/overmap_result = overmap_follow_programmed_leg(destination_dock)
				if(isnull(overmap_result))
					overmap_leg_started = TRUE
					return
				if(overmap_result == FALSE)
					dock_id(destination_dock)

				if(devil_on_shuttle || force_hijacked)
					GLOB.major_announcement.announce(
						message = "Обнаружен сбой навигационных протоколов. Эвакуационный шаттл сошёл с установленного маршрута и движется в неизвестном направлении.",
						new_title = ANNOUNCE_PRIORITY_RU,
						new_sound = 'sound/misc/announce_syndi.ogg'
					)

				var/hyperspace_end_sound = sound('sound/effects/hyperspace_end.ogg')
				for(var/area/shuttle/escape/E in GLOB.areas)
					SEND_SOUND(E, hyperspace_end_sound)

				overmap_leg_started = FALSE
				mode = SHUTTLE_ENDGAME
				timer = 0

			if(time_left <= PARALLAX_LOOP_TIME)
				var/area_parallax = FALSE
				for(var/place in shuttle_areas)
					var/area/shuttle/shuttle_area = place
					if(shuttle_area.parallax_movedir)
						area_parallax = TRUE
						break
				if(area_parallax)
					parallax_slowdown()
					for(var/A in SSshuttle.mobile)
						var/obj/docking_port/mobile/M = A
						if(istype(M, /obj/docking_port/mobile/pod))
							M.parallax_slowdown()

/obj/docking_port/mobile/emergency/proc/admin_force_move_to_dock(dock_id)
	var/obj/docking_port/stationary/pad = SSshuttle.getDock(dock_id)
	if(!pad)
		return "Площадка [dock_id] не найдена."
	var/obj/overmap/entity/vessel = SSovermap?.shuttle_vessels[src]
	vessel?.abort_programmed_mission()
	if(vessel)
		vessel.programmed_emag_until = 0
	overmap_force_dock = TRUE
	var/failed = dock(pad, force = TRUE)
	overmap_force_dock = FALSE
	if(failed)
		return "Не удалось пристыковать к [dock_id]."
	return TRUE

/obj/docking_port/mobile/emergency/proc/admin_force_dock()
	if(!SSshuttle?.emergency || SSshuttle.emergency != src)
		return "Это не эвак."
	switch(mode)
		if(SHUTTLE_CALL)
			var/moved = admin_force_move_to_dock("emergency_home")
			if(moved != TRUE)
				return moved
			overmap_leg_started = FALSE
			mode = SHUTTLE_DOCKED
			setTimer(SSshuttle.emergencyDockTime)
			if(canRecall)
				GLOB.major_announcement.announce(
					"Эвакуационный шаттл совершил стыковку со станцией. У вас есть [timeLeft(600)] минуты, чтобы взобраться на борт эвакуационного шаттла.",
					new_title = ANNOUNCE_PRIORITY_RU,
					new_sound = ANNOUNCER_SHUTTLEDOCK
				)
			else
				GLOB.major_announcement.announce(
					"Транспортный шаттл совершил стыковку со станцией. У вас есть [timeLeft(600)] минуты, чтобы взобраться на борт транспортного шаттла.",
					new_title = ANNOUNCE_PRIORITY_RU,
					new_sound = ANNOUNCER_SHUTTLEDOCK
				)
			return TRUE
		if(SHUTTLE_ESCAPE, SHUTTLE_IGNITING, SHUTTLE_ENDGAME)
			var/dock_id = overmap_escape_dock || "emergency_away"
			var/moved = admin_force_move_to_dock(dock_id)
			if(moved != TRUE)
				return moved
			overmap_leg_started = FALSE
			mode = SHUTTLE_ENDGAME
			timer = 0
			return TRUE
		if(SHUTTLE_DOCKED, SHUTTLE_STRANDED)
			return "Шаттл уже на станции."
	var/obj/overmap/entity/vessel = SSovermap?.shuttle_vessels[src]
	var/on_overmap = vessel && (vessel.status == OVERMAP_STATUS_OVERMAP || vessel.status == OVERMAP_STATUS_TRANSIT)
	if(!on_overmap && is_physically_at_roundstart())
		return "Шаттл уже на домашней площадке."
	var/home_id = roundstart_move || "emergency_away"
	var/moved = admin_force_move_to_dock(home_id)
	if(moved != TRUE)
		return moved
	overmap_leg_started = FALSE
	mode = SHUTTLE_IDLE
	timer = 0
	return TRUE

/obj/docking_port/mobile/emergency/proc/is_physically_at_roundstart()
	var/home_id = roundstart_move || "emergency_away"
	return getDockedId() == home_id

/obj/docking_port/mobile/emergency/proc/on_nav_emag()
	nav_emag_paused_left = timer ? timeLeft(1) : 0
	nav_emag_paused_dock = getDockedId()
	timer = world.time + 24 HOURS

/obj/docking_port/mobile/emergency/proc/on_nav_emag_end()
	var/left = nav_emag_paused_left
	var/dock = nav_emag_paused_dock
	nav_emag_paused_left = 0
	nav_emag_paused_dock = null
	if(left <= 0)
		return
	if(getDockedId() != dock)
		return
	if(mode != SHUTTLE_CALL && mode != SHUTTLE_RECALL && mode != SHUTTLE_DOCKED)
		return
	if(mode == SHUTTLE_CALL && overmap_leg_started)
		return
	setTimer(left)

/obj/docking_port/mobile/emergency/proc/overmap_note_arrival(obj/docking_port/stationary/new_dock)
	if(!new_dock || istype(new_dock, /obj/docking_port/stationary/transit))
		return
	if(new_dock.id != "emergency_away" && new_dock.id != "emergency_syndicate")
		return
	if(mode != SHUTTLE_ESCAPE && mode != SHUTTLE_IGNITING && !is_nav_emagged())
		return
	overmap_escape_dock = new_dock.id
	overmap_leg_started = FALSE
	mode = SHUTTLE_ENDGAME
	timer = 0
	if(new_dock.id == "emergency_syndicate")
		GLOB.major_announcement.announce(
			message = "Обнаружен сбой навигационных протоколов. Эвакуационный шаттл сошёл с установленного маршрута. Сигнал потерян, дальнейшее отслеживание эвакуационного шаттла невозможно.",
			new_title = ANNOUNCE_PRIORITY_RU,
			new_sound = 'sound/misc/announce_syndi.ogg'
		)

// This basically opens a big-ass row of blast doors when the shuttle arrives at centcom
/obj/docking_port/mobile/pod
	name = "escape pod"
	id = "pod"

	dwidth = 2
	width = 5
	height = 6

/obj/docking_port/mobile/pod/Initialize(mapload)
	. = ..()
	if(id == "pod")
		WARNING("[type] id has not been changed from the default. Use the id convention \"pod1\" \"pod2\" etc.")

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
		to_chat(user, span_warning(" Access requirements overridden. The pod may now be launched manually at any time."))
	admin_controlled = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/docking_port/stationary/random
	name = "escape pod"
	id = "pod"
	dwidth = 1
	width = 3
	height = 4
	var/target_area = /area/mine/unexplored

/obj/docking_port/stationary/random/Initialize(mapload)
	. = ..()
	var/list/turfs = get_area_turfs(target_area)
	var/turf/T = pick(turfs)
	src.loc = T

/obj/docking_port/mobile/emergency/backup
	name = "backup shuttle"
	id = "backup"
	dwidth = 2
	width = 8
	height = 8

	roundstart_move = "backup_away"

/obj/docking_port/mobile/emergency/backup/register()
	var/current_emergency = SSshuttle.emergency
	..()
	SSshuttle.emergency = current_emergency
	SSshuttle.backup_shuttle = src
