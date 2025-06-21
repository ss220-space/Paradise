/obj/machinery/drone_fabricator
	name = "drone fabricator"
	ru_names = list(
		NOMINATIVE = "фабрикатор дронов",
		GENITIVE = "фабрикатора дронов",
		DATIVE = "фабрикатору дронов",
		ACCUSATIVE = "фабрикатор дронов",
		INSTRUMENTAL = "фабрикатором дронов",
		PREPOSITIONAL = "фабрикаторе дронов"
	)
	desc = "Большая автоматизированная фабрика для производства дронов обслуживания."
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 5000
	var/drone_progress = 0
	var/produce_drones = TRUE
	var/time_last_drone = 500


/obj/machinery/drone_fabricator/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "drone_fab_nopower"
		return

	if(!produce_drones || (!drone_progress || drone_progress >= 100))
		icon_state = "drone_fab_idle"
		return

	icon_state = "drone_fab_active"


/obj/machinery/drone_fabricator/power_change(forced = FALSE)
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/drone_fabricator/process()

	if(SSticker.current_state < GAME_STATE_PLAYING)
		return

	if((stat & NOPOWER) || !produce_drones)
		return

	if(drone_progress >= 100)
		if(icon_state != "drone_fab_idle")
			update_icon(UPDATE_ICON_STATE)
		return

	if(icon_state != "drone_fab_active")
		update_icon(UPDATE_ICON_STATE)
	var/elapsed = world.time - time_last_drone
	drone_progress = round((elapsed/CONFIG_GET(number/drone_build_time))*100)

	if(drone_progress >= 100)
		visible_message("[capitalize(declent_ru(NOMINATIVE))] издаёт резкий звуковой сигнал, указывая на готовность шасси дрона.")

/obj/machinery/drone_fabricator/examine(mob/user)
	. = ..()
	if(produce_drones && drone_progress >= 100 && istype(user,/mob/dead) && CONFIG_GET(flag/allow_drone_spawn) && count_drones() < CONFIG_GET(number/max_maint_drones))
		. += span_info("<br><b>Дрон готов. Выберите 'Присоединиться как дрон' во вкладке Ghost, чтобы появиться как дрон обслуживания.</b>")

/obj/machinery/drone_fabricator/proc/count_drones()
	var/drones = 0
	for(var/mob/living/silicon/robot/drone/D in GLOB.silicon_mob_list)
		if(D.key && D.client)
			drones++
	return drones

/obj/machinery/drone_fabricator/proc/create_drone(var/client/player)

	if(stat & NOPOWER)
		return

	if(!produce_drones || !CONFIG_GET(flag/allow_drone_spawn) || count_drones() >= CONFIG_GET(number/max_maint_drones))
		return

	if(!player || !istype(player.mob,/mob/dead))
		return

	visible_message("[capitalize(declent_ru(NOMINATIVE))] гудит и скрипит, начиная движение, и через несколько мгновений выпускает нового блестящего дрона.")
	flick("h_lathe_leave",src)

	time_last_drone = world.time
	var/mob/living/silicon/robot/drone/new_drone = new(get_turf(src))
	new_drone.transfer_personality(player)

	drone_progress = 0

/obj/machinery/drone_fabricator/attack_ghost(mob/dead/observer/user)
	user.become_drone()

/mob/dead/verb/join_as_drone()
	set category = STATPANEL_GHOST
	set name = "Стать дроном"
	set desc = "If there is a powered, enabled fabricator in the game world with a prepared chassis, join as a maintenance drone."
	become_drone(src)

/mob/dead/proc/become_drone(mob/user)
	if(!(CONFIG_GET(flag/allow_drone_spawn)))
		to_chat(src, span_warning("Это действие сейчас запрещено."))
		return

	if(!src.stat)
		return

	if(usr != src)
		return 0 //something is terribly wrong

	if(jobban_isbanned(src,"nonhumandept") || jobban_isbanned(src,"Drone"))
		to_chat(usr, span_warning("Вам запрещено играть за дронов, и вы не можете появиться как дрон."))
		return

	if(!SSticker || SSticker.current_state < 3)
		to_chat(src, span_warning("Вы не можете присоединиться как дрон до начала игры!"))
		return

	var/drone_age = 14 // 14 days to play as a drone
	var/player_age_check = check_client_age(usr.client, drone_age)
	if(player_age_check && CONFIG_GET(flag/use_age_restriction_for_antags))
		to_chat(usr, span_warning("Эта роль пока недоступна для вас. Вам нужно подождать ещё [player_age_check] [declension_ru(player_age_check,"день","дня","дней")]."))
		return

	var/pt_req = role_available_in_playtime(client, ROLE_DRONE)
	if(pt_req)
		var/pt_req_string = get_exp_format(pt_req)
		to_chat(usr, span_warning("Эта роль пока недоступна для вас. Сыграйте ещё [pt_req_string], чтобы разблокировать её."))
		return

	var/deathtime = world.time - src.timeofdeath
	var/joinedasobserver = 0
	if(istype(src,/mob/dead/observer))
		var/mob/dead/observer/G = src
		if(cannotPossess(G))
			to_chat(usr, span_warning("Используя antagHUD, вы отказались от возможности присоединиться к раунду."))
			return
		if(G.started_as_observer == 1)
			joinedasobserver = 1

	var/deathtimeminutes = round(deathtime / 600)
	var/pluralcheck = "мин"
	if(deathtimeminutes == 0)
		pluralcheck = ""
	else if(deathtimeminutes > 0)
		pluralcheck = " [deathtimeminutes] мин. и"
	var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)

	if(deathtimeminutes < CONFIG_GET(number/respawn_delay_drone) && joinedasobserver == 0)
		to_chat(usr, "Вы были мертвы в течении[pluralcheck] [deathtimeseconds] секунд.")
		to_chat(usr, span_warning("Вы должны подождать [CONFIG_GET(number/respawn_delay_drone)] минут[declension_ru(CONFIG_GET(number/respawn_delay_drone), "у", "ы", "")], чтобы возродиться как дрон!"))
		return

	if(tgui_alert(usr, "Вы уверены, что хотите возродиться как дрон?", "Вы уверены?", list("Да", "Нет")) != "Да")
		return

	for(var/obj/machinery/drone_fabricator/DF in SSmachines.get_by_type(/obj/machinery/drone_fabricator))
		if(DF.stat & NOPOWER || !DF.produce_drones)
			continue

		if(DF.count_drones() >= CONFIG_GET(number/max_maint_drones))
			to_chat(src, span_warning("В мире слишком много активных дронов, чтобы вы могли появиться."))
			return

		if(DF.drone_progress >= 100)
			DF.create_drone(src.client)
			return

	to_chat(src, span_warning("Нет доступных точек спавна для дронов, извините."))
