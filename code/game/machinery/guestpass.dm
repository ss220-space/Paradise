/////////////////////////////////////////////
//Guest pass ////////////////////////////////
/////////////////////////////////////////////
/obj/item/card/id/guest
	name = "guest pass"
	desc = "Предоставляет временный доступ в определённые места на станции."
	ru_names = list(
		NOMINATIVE = "гостевой пропуск",
		GENITIVE = "гостевого пропуска",
		DATIVE = "гостевому пропуску",
		ACCUSATIVE = "гостевой пропуск",
		INSTRUMENTAL = "гостевым пропуском",
		PREPOSITIONAL = "гостевом пропуске"
	)
	gender = FEMALE
	icon_state = "guest"
	item_state = "guestpass-id"

	var/temp_access = list() //to prevent agent cards stealing access as permanent
	var/expiration_time = 0
	var/reason = "НЕ УКАЗАНА"

/obj/item/card/id/guest/GetAccess()
	if(world.time > expiration_time)
		return access
	else
		return temp_access

/obj/item/card/id/guest/examine(mob/user)
	. = ..()
	if(world.time < expiration_time)
		. += span_notice("Пропуск истекает в <b>[station_time_timestamp("hh:mm:ss", expiration_time)]</b>.")
	else
		. += span_warning("Пропуск истекает в <b>[station_time_timestamp("hh:mm:ss", expiration_time)]</b>.")
	. += span_notice("<b>Даёт доступ к следующим местам:</b>")
	for(var/A in temp_access)
		. += span_notice("[get_access_desc(A)].")
	. += span_notice("<b>Причина создания: [reason].</b>")

/////////////////////////////////////////////
//Guest pass terminal////////////////////////
/////////////////////////////////////////////

/obj/machinery/computer/guestpass
	name = "guest pass terminal"
	desc = "Терминал, используюемый для создания гостевых пропусков."
	ru_names = list(
		NOMINATIVE = "терминал гостевых пропусков",
		GENITIVE = "терминала гостевых пропусков",
		DATIVE = "терминалу гостевых пропусков",
		ACCUSATIVE = "терминал гостевых пропусков",
		INSTRUMENTAL = "терминалом гостевых пропусков",
		PREPOSITIONAL = "терминале гостевых пропусков"
	)
	icon_state = "guest"
	icon_screen = "pass"
	icon_keyboard = null
	density = FALSE


	var/obj/item/card/id/giver
	var/list/accesses = list()
	var/giv_name = "НЕ УКАЗАНО"
	var/reason = "НЕ УКАЗАНА"
	var/duration = 5

	var/list/internal_log = list()
	var/mode = 0  // 0 - making pass, 1 - viewing logs


/obj/machinery/computer/guestpass/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/card/id))
		add_fingerprint(user)
		if(giver)
			balloon_alert(user, "слот для ID-карты занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		giver = I
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/computer/guestpass/proc/get_changeable_accesses()
	return giver.access

/obj/machinery/computer/guestpass/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/computer/guestpass/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.set_machine(src)
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}

	if(mode == 1) //Logs
		dat += "<h3>История активности</h3><br>"
		for(var/entry in internal_log)
			dat += "[entry]<br><hr>"
		dat += "<a href='byond://?src=[UID()];action=print'>Распечатать</a><br>"
		dat += "<a href='byond://?src=[UID()];mode=0'>Назад</a><br>"
	else
		dat += "<h3>Терминал гостевых пропусков №[uid]</h3><br>"
		dat += "<a href='byond://?src=[UID()];mode=1'>Посмотреть историю активности</a><br><br>"
		dat += "Основная ID-карта: <a href='byond://?src=[UID()];action=id'>[giver]</a><br>"
		dat += "Создаётся для: <a href='byond://?src=[UID()];choice=giv_name'>[giv_name]</a><br>"
		dat += "Причина:  <a href='byond://?src=[UID()];choice=reason'>[reason]</a><br>"
		dat += "Длительность действия (в минутах):  <a href='byond://?src=[UID()];choice=duration'>[duration] m</a><br>"
		dat += "Доступ к:<br>"
		if(giver && giver.access)
			for(var/A in get_changeable_accesses())
				var/area = get_access_desc(A)
				if(A in accesses)
					area = "<b>[area]</b>"
				dat += "<a href='byond://?src=[UID()];choice=access;access=[A]'>[area]</a><br>"
		dat += "<br><a href='byond://?src=[UID()];action=issue'>Создать пропуск</a><br>"

	var/datum/browser/popup = new(user, "guestpass", name, 400, 520)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "guestpass")


/obj/machinery/computer/guestpass/Topic(href, href_list)
	if(..())
		return 1
	usr.set_machine(src)
	if(href_list["mode"])
		mode = text2num(href_list["mode"])

	if(href_list["choice"])
		switch(href_list["choice"])
			if("giv_name")
				var/nam = strip_html_simple(input("Гостевой пропуск создан на имя", "Имя", giv_name) as text|null)
				if(nam)
					giv_name = nam
			if("reason")
				var/reas = strip_html_simple(input("Причина создания", "Причина", reason) as text|null)
				if(reas)
					reason = reas
			if("duration")
				var/dur = input("Длительность действия (до 30 минут).", "Длительность") as num|null
				if(dur)
					if(dur > 0 && dur <= 30)
						duration = dur
					else
						to_chat(usr, span_warning("Недопустимая длительность."))
			if("access")
				var/A = text2num(href_list["access"])
				if(A in accesses)
					accesses.Remove(A)
				else
					if(giver && giver.access && (A in get_changeable_accesses()))
						accesses.Add(A)
	if(href_list["action"])
		switch(href_list["action"])
			if("id")
				if(giver)
					if(ishuman(usr))
						giver.loc = usr.loc
						if(!usr.get_active_hand())
							giver.forceMove_turf()
							usr.put_in_hands(giver, ignore_anim = FALSE)
						giver = null
					else
						giver.loc = src.loc
						giver = null
					accesses.Cut()
				else
					var/obj/item/I = usr.get_active_hand()
					if(istype(I, /obj/item/card/id))
						usr.drop_transfer_item_to_loc(I, src)
						giver = I
				updateUsrDialog()

			if("print")
				var/dat = "<h3>История активности терминала гостевых пропусков #[uid]</h3><br>"
				for(var/entry in internal_log)
					dat += "[entry]<br><hr>"
//				to_chat(usr, "Printing the log, standby...")
				//sleep(50)
				var/obj/item/paper/P = new/obj/item/paper( loc )
				playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
				P.name = "activity log"
				P.info = dat

			if("issue")
				if(giver)
					var/number = add_zero("[rand(0,9999)]", 4)
					var/entry = "\[[station_time()]\] [giver.registered_name] ([giver.assignment]) создал[genderize_ru(giver.gender, "", "а", "о", "и")] пропуск №[number] для [giv_name]. Причина: [reason]. Даёт доступ в следующие места: "
					for(var/i=1 to accesses.len)
						var/A = accesses[i]
						if(A)
							var/area = get_access_desc(A)
							entry += "[i > 1 ? ", [area]" : "[area]"]"
					entry += ". Истекает в [station_time(world.time + duration*10*60)]."
					internal_log.Add(entry)

					var/obj/item/card/id/guest/pass = new(src.loc)
					pass.temp_access = accesses.Copy()
					pass.registered_name = giv_name
					pass.expiration_time = world.time + duration*10*60
					pass.reason = reason
					pass.name = "guest pass №[number]"
				else
					to_chat(usr, span_warning("Невозможно создать без основной ID-карты."))
	updateUsrDialog()
	return

/obj/machinery/computer/guestpass/hop
	name = "\improper HoP guest pass terminal"
	desc = "Терминал Главы Персонала, используюемый для создания гостевых пропусков."
	ru_names = list(
		NOMINATIVE = "терминал гостевых пропусков ГП",
		GENITIVE = "терминала гостевых пропусков ГП",
		DATIVE = "терминалу гостевых пропусков ГП",
		ACCUSATIVE = "терминал гостевых пропусков ГП",
		INSTRUMENTAL = "терминалом гостевых пропусков ГП",
		PREPOSITIONAL = "терминале гостевых пропусков ГП"
	)

/obj/machinery/computer/guestpass/hop/get_changeable_accesses()
	. = ..()
	if(. && (ACCESS_CHANGE_IDS in .))
		return get_all_accesses()

/obj/machinery/computer/guestpass/syndicate
	name = "\improper Syndicate guest pass terminal"
	desc = "Терминал Синдиката, используюемый для создания гостевых пропусков."
	ru_names = list(
		NOMINATIVE = "терминал гостевых пропусков Синдиката",
		GENITIVE = "терминала гостевых пропусков Синдиката",
		DATIVE = "терминалу гостевых пропусков Синдиката",
		ACCUSATIVE = "терминал гостевых пропусков Синдиката",
		INSTRUMENTAL = "терминалом гостевых пропусков Синдиката",
		PREPOSITIONAL = "терминале гостевых пропусков Синдиката"
	)

/obj/machinery/computer/guestpass/syndicate/get_changeable_accesses()
	. = ..()
	if(. && (ACCESS_CHANGE_IDS in .))
		return get_taipan_syndicate_access()

/obj/machinery/computer/guestpass/syndicate/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.set_machine(src)
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}

	if(mode == 1) //Logs
		dat += "<h3>История активности</h3><br>"
		for(var/entry in internal_log)
			dat += "[entry]<br><hr>"
		dat += "<a href='byond://?src=[UID()];action=print'>Распечатать</a><br>"
		dat += "<a href='byond://?src=[UID()];mode=0'>Назад</a><br>"
	else
		dat += "<h3>Терминал гостевых пропусков №[uid]</h3><br>"
		dat += "<a href='byond://?src=[UID()];mode=1'>Посмотреть историю активности</a><br><br>"
		dat += "Основная ID-карта: <a href='byond://?src=[UID()];action=id'>[giver]</a><br>"
		dat += "Создаётся для: <a href='byond://?src=[UID()];choice=giv_name'>[giv_name]</a><br>"
		dat += "Причина:  <a href='byond://?src=[UID()];choice=reason'>[reason]</a><br>"
		dat += "Длительность действия (в минутах):  <a href='byond://?src=[UID()];choice=duration'>[duration] m</a><br>"
		dat += "Доступ к:<br>"
		if(giver && giver.access)
			for(var/A in get_changeable_accesses())
				var/area = get_syndicate_access_desc(A)
				if(A in accesses)
					area = "<b>[area]</b>"
				dat += "<a href='byond://?src=[UID()];choice=access;access=[A]'>[area]</a><br>"
		dat += "<br><a href='byond://?src=[UID()];action=issue'>Создать пропуск</a><br>"

	var/datum/browser/popup = new(user, "guestpass", name, 400, 520)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "guestpass")
