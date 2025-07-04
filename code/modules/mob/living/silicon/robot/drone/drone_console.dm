/obj/machinery/computer/drone_control
	name = "maintenance drone control console"
	ru_names = list(
		NOMINATIVE = "консоль управления дронами",
		GENITIVE = "консоли управления дронами",
		DATIVE = "консоли управления дронами",
		ACCUSATIVE = "консоль управления дронами",
		INSTRUMENTAL = "консолью управления дронами",
		PREPOSITIONAL = "консоли управления дронами"
	)
	desc = "Используется для наблюдения за популяцией дронов на станции и сборщиком, который их обслуживает."
	icon_screen = "power"
	icon_keyboard = "power_key"
	req_access = list(ACCESS_ENGINE_EQUIP)
	circuit = /obj/item/circuitboard/drone_control

	//Used when pinging drones.
	var/drone_call_area = "Engineering"
	//Used to enable or disable drone fabrication.
	var/obj/machinery/drone_fabricator/dronefab
	var/request_cooldown = 30 SECONDS
	var/last_drone_request_time = 0

/obj/machinery/computer/drone_control/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/drone_control/attack_hand(var/mob/user as mob)
	if(..())
		return

	if(!allowed(user))
		balloon_alert(user, "доступ запрещён!")
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return

	interact(user)

/obj/machinery/computer/drone_control/attack_ghost(mob/user as mob)
	interact(user)

/obj/machinery/computer/drone_control/interact(mob/user)

	user.set_machine(src)
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	dat += "<b>Ремонтные дроны</B><br>"

	for(var/mob/living/silicon/robot/drone/D in GLOB.silicon_mob_list)
		dat += "<br>[D.real_name] ([D.stat == 2 ? "<font color='red'>НЕАКТИВЕН" : "<font color='green'>АКТИВЕН"]</font>)"
		dat += "<br>Заряд батареи: [D.cell.charge]/[D.cell.maxcharge]."
		dat += "<br>Текущее местоположение: [get_area(D)]."
		dat += "<br><a href='byond://?src=[UID()];resync=\ref[D]'>Синхронизировать</a> | <a href='byond://?src=[UID()];shutdown=\ref[D]'>Отключить</a>"

	dat += "<br><b><a href='byond://?src=[UID()];request_help=1'>Запросить нового дрона</a></B>"

	dat += "<br><br><b>Запросить присутствие дрона в зоне:</B> <a href='byond://?src=[UID()];setarea=1'>[drone_call_area]</a> (<a href='byond://?src=[UID()];ping=1'>Отправить пинг</a>)"

	dat += "<br><br><b>Фабрикатор дронов</B>: "
	dat += "[dronefab ? "<a href='byond://?src=[UID()];toggle_fab=1'>[(dronefab.produce_drones && !(dronefab.stat & NOPOWER)) ? "АКТИВЕН" : "НЕАКТИВЕН"]</a>" : "<font color='red'><b>ФАБРИКАТОР НЕ ОБНАРУЖЕН.</b></font> (<a href='byond://?src=[UID()];search_fab=1'>Поиск</a>)"]"
	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/drone_control/proc/request_help()
	if((last_drone_request_time + request_cooldown) > world.time)
		return
	notify_ghosts(message = "Требуется дрон для починки и обслуживания.", ghost_sound = null,
		title="Фабрикатор дронов", source = dronefab, action = NOTIFY_ATTACK)
	last_drone_request_time = world.time

/obj/machinery/computer/drone_control/Topic(href, href_list)
	if(..())
		return

	if(!allowed(usr) && !usr.can_admin_interact())
		to_chat(usr, span_warning("Доступ запрещён."))
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return

	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

	if(href_list["setarea"])

		//Probably should consider using another list, but this one will do.
		var/t_area = tgui_input_list(usr, "Выберите зону для отправки пинга.", "Установить целевую зону", GLOB.TAGGERLOCATIONS, null)

		if(!t_area || GLOB.TAGGERLOCATIONS[t_area])
			return

		drone_call_area = t_area
		to_chat(usr, span_notice("Вы установили целевую зону на [drone_call_area]."))

	else if(href_list["request_help"])
		if(!dronefab || !dronefab.produce_drones)
			to_chat(usr, span_warning("Вы не можете запросить дрона, если нет рабочего фабрикатора."))
		else
			if((last_drone_request_time + request_cooldown) > world.time)
				to_chat(usr, span_notice("Вы не можете отправлять запросы на производство слишком часто."))
				return
			to_chat(usr, span_notice("Вы отправили запрос на производство в фабрикатор."))
			request_help()

	else if(href_list["ping"])

		to_chat(usr, span_notice("Вы отправляете запрос на обслуживание для всех активных дронов, выделяя зону [drone_call_area]."))
		for(var/mob/living/silicon/robot/drone/D in GLOB.silicon_mob_list)
			if(D.client && D.stat == 0)
				to_chat(D, "-- Запрошено присутствие дрона в зоне: [drone_call_area].")

	else if(href_list["resync"])

		var/mob/living/silicon/robot/drone/D = locate(href_list["resync"])

		if(D.stat != 2)
			to_chat(usr, span_warning("Вы отправляете директиву на синхронизацию законов для дрона."))
			D.law_resync()

	else if(href_list["shutdown"])

		var/mob/living/silicon/robot/drone/D = locate(href_list["shutdown"])

		if(D.stat != 2)
			to_chat(usr, span_warning("Вы отправляете команду на уничтожение несчастного дрона."))
			add_attack_logs(usr, src, "issued kill order from control console", ATKLOG_FEW)
			D.shut_down()

	else if(href_list["search_fab"])
		if(dronefab)
			return

		for(var/obj/machinery/drone_fabricator/fab in get_area(src))

			if(fab.stat & NOPOWER)
				continue

			dronefab = fab
			to_chat(usr, span_notice("Фабрикатор дронов обнаружен."))
			return

		to_chat(usr, span_warning("Не удалось обнаружить фабрикатор дронов."))

	else if(href_list["toggle_fab"])

		if(!dronefab)
			return

		if(get_dist(src,dronefab) > 3)
			dronefab = null
			to_chat(usr, span_warning("Не удалось обнаружить фабрикатор дронов."))
			return

		dronefab.produce_drones = !dronefab.produce_drones
		dronefab.update_icon(UPDATE_ICON_STATE)
		to_chat(usr, span_notice("Вы [dronefab.produce_drones ? "включаете" : "отключаете"] производство дронов в ближайшем фабрикаторе."))

	src.updateUsrDialog()
