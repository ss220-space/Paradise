/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	desc = "Used to work with viruses."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	circuit = /obj/item/circuitboard/pandemic
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = ACID_PROOF
	var/temp_html = ""
	var/printing = null
	var/wait = null
	var/obj/item/reagent_containers/beaker = null

/obj/machinery/computer/pandemic/New()
	..()
	update_icon()

/obj/machinery/computer/pandemic/set_broken()
	stat |= BROKEN
	update_icon()

/obj/machinery/computer/pandemic/proc/GetDiseaseByIndex(index)
	if(beaker?.reagents?.reagent_list.len)
		for(var/datum/reagent/BL in beaker.reagents.reagent_list)
			if(BL?.data && BL.data["diseases"])
				var/list/diseases = BL.data["diseases"]
				return diseases[index]

/obj/machinery/computer/pandemic/proc/GetResistancesByIndex(index)
	if(beaker?.reagents?.reagent_list.len)
		for(var/datum/reagent/BL in beaker.reagents.reagent_list)
			if(BL?.data && BL.data["resistances"])
				var/list/resistances = BL.data["resistances"]
				return resistances[index]

/obj/machinery/computer/pandemic/proc/GetDiseaseTypeByIndex(index)
	var/datum/disease/D = GetDiseaseByIndex(index)
	if(D)
		return D.GetDiseaseID()

/obj/machinery/computer/pandemic/proc/replicator_cooldown(waittime)
	wait = 1
	update_icon()
	spawn(waittime)
		wait = null
		update_icon()
		playsound(loc, 'sound/machines/ping.ogg', 30, 1)


/obj/machinery/computer/pandemic/update_icon_state()
	if(stat & BROKEN)
		icon_state = "mixer[beaker ? "1" : "0"]_b"
		return
	icon_state = "mixer[beaker ? "1" : "0"][(powered()) ? "" : "_nopower"]"


/obj/machinery/computer/pandemic/update_overlays()
	. = ..()
	if(!(stat & BROKEN) && !wait)
		. += "waitlight"


/obj/machinery/computer/pandemic/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	if(!beaker) return

	if(href_list["create_vaccine"])
		if(!wait)
			var/obj/item/reagent_containers/glass/bottle/B = new/obj/item/reagent_containers/glass/bottle(loc)
			if(B)
				B.pixel_x = rand(-3, 3)
				B.pixel_y = rand(-3, 3)
				var/path = GetResistancesByIndex(text2num(href_list["create_vaccine"]))
				var/vaccine_type = path
				var/vaccine_name = "Unknown"

				if(!ispath(vaccine_type))
					if(GLOB.archive_diseases[path])
						var/datum/disease/D = GLOB.archive_diseases[path]
						if(D)
							vaccine_name = D.name
							vaccine_type = path
				else if(vaccine_type)
					var/datum/disease/D = new vaccine_type
					if(D)
						vaccine_name = D.name

				if(vaccine_type)

					B.name = "[vaccine_name] vaccine bottle"
					B.reagents.add_reagent("vaccine", 15, list(vaccine_type))
					replicator_cooldown(200)
		else
			temp_html = "The replicator is not ready yet."
		updateUsrDialog()
		return
	else if(href_list["create_disease_culture"])
		if(!wait)
			var/datum/disease/D = GetDiseaseByIndex(text2num(href_list["create_disease_culture"]))
			var/datum/disease/copy
			if(istype(D, /datum/disease/virus/advance))
				var/datum/disease/virus/advance/A = GLOB.archive_diseases[D.GetDiseaseID()]
				if(A)
					copy = A.Copy()
			if(!copy)
				copy = D.Copy()
			if(!copy)
				return
			var/name = tgui_input_text(usr, "Name:", "Name the culture", D.name, MAX_NAME_LEN)
			if(name == null || wait)
				return
			var/obj/item/reagent_containers/glass/bottle/B = new(loc)
			B.icon_state = "round_bottle"
			B.pixel_x = rand(-3, 3)
			B.pixel_y = rand(-3, 3)
			replicator_cooldown(50)
			var/list/data = list("diseases"=list(copy))
			B.name = "[name] culture bottle"
			B.desc = "A small bottle. Contains [copy.agent] culture in synthblood medium."
			B.reagents.add_reagent("blood",20,data)
			updateUsrDialog()
		else
			temp_html = "The replicator is not ready yet."
		updateUsrDialog()
		return
	else if(href_list["empty_beaker"])
		beaker.reagents.clear_reagents()
		eject_beaker()
		updateUsrDialog()
		return
	else if(href_list["eject"])
		eject_beaker()
		updateUsrDialog()
		return
	else if(href_list["clear"])
		temp_html = ""
		updateUsrDialog()
		return
	else if(href_list["name_disease"])
		var/new_name = tgui_input_text(usr, "Name the Disease", "New Name", max_length = MAX_NAME_LEN)
		if(!new_name)
			return
		if(..())
			return
		var/id = GetDiseaseTypeByIndex(text2num(href_list["name_disease"]))
		if(GLOB.archive_diseases[id])
			var/datum/disease/virus/advance/A = GLOB.archive_diseases[id]
			A.AssignName(new_name)
			for(var/datum/disease/virus/advance/AD in GLOB.active_diseases)
				AD.Refresh(update_properties = FALSE)
		updateUsrDialog()
	else if(href_list["print_form"])
		var/datum/disease/D = GetDiseaseByIndex(text2num(href_list["print_form"]))
		D = GLOB.archive_diseases[D.GetDiseaseID()]//We know it's advanced no need to check
		print_form(D, usr)


	else
		usr << browse(null, "window=pandemic")
		updateUsrDialog()
		return

	add_fingerprint(usr)

/obj/machinery/computer/pandemic/proc/eject_beaker()
	beaker.forceMove(loc)
	beaker = null
	icon_state = "mixer0"

//Prints a nice virus release form. Props to Urbanliner for the layout
/obj/machinery/computer/pandemic/proc/print_form(var/datum/disease/virus/advance/D, mob/living/user)
	D = GLOB.archive_diseases[D.GetDiseaseID()]
	if(!(printing) && D)
		var/reason = tgui_input_text(user,"Укажите причину выпуска", "Указать", multiline = TRUE)
		reason += "<span class=\"paper_field\"></span>"
		var/english_symptoms = list()
		for(var/I in D.symptoms)
			var/datum/symptom/S = I
			english_symptoms += S.name
		var/symtoms = english_list(english_symptoms)


		var/signature
		if(tgui_alert(user, "Вы хотите подписать этот документ?", "Подпись", list("Да","Нет")) == "Да")
			signature = "<font face=\"[SIGNFONT]\"><i>[user ? user.real_name : "Аноним"]</i></font>"
		else
			signature = "<span class=\"paper_field\"></span>"

		printing = 1
		var/obj/item/paper/P = new /obj/item/paper(loc)
		visible_message("<span class='notice'>[src] гремит и печатает лист бумаги.</span>")
		playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)

		P.info = "<U><font size=\"4\"><B><center> Выпуск вируса </B></center></font></U>"
		P.info += "<HR>"
		P.info += "<U>Название вируса:</U> [D.name] <BR>"
		P.info += "<U>Симптомы:</U> [symtoms]<BR>"
		P.info += "<U>Путь передачи:</U> [D.additional_info]<BR>"
		P.info += "<U>Лекарство от вируса:</U> [D.cure_text]<BR>"
		P.info += "<BR>"
		P.info += "<U>Причина выпуска:</U> [reason]"
		P.info += "<HR>"
		P.info += "Вирусолог, ответственный за любые биологические угрозы, возникшие вследствие выпуска вируса.<BR>"
		P.info += "<U>Подпись вирусолога:</U> [signature]<BR>"
		P.info += "Печать ответственного лица, разрешившего выпуск вируса:"
		P.populatefields()
		P.updateinfolinks()
		P.name = "Выпуск вируса «[D.name]»"
		P.update_icon()
		printing = null

/obj/machinery/computer/pandemic/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	if(temp_html)
		dat += "[temp_html]<BR><BR><a href='byond://?src=[UID()];clear=1'>Главное меню</A>"
	else if(!beaker)
		dat += "Пожалуйста, вставьте мензурку.<BR>"
		dat += "<a href='byond://?src=[user.UID()];mach_close=pandemic'>Закрыть</A>"
	else
		var/datum/reagents/R = beaker.reagents
		var/datum/reagent/Blood = null

		for(var/datum/reagent/B in R.reagent_list)
			if(B.id in GLOB.diseases_carrier_reagents)
				Blood = B
				if(!Blood.data)
					continue
				break
		if(!R.total_volume||!R.reagent_list.len)
			dat += "Мензурка пуста<BR>"
		else if(!Blood)
			dat += "В мензурке отсутствует образец крови."
		else if(!Blood.data)
			dat += "В мензурке отсутствует данные крови."
		else
			dat += "<h3>Данные образца крови:</h3>"
			dat += "<b>ДНК крови:</b> [(Blood.data["blood_DNA"]||"нет")]<BR>"
			dat += "<b>Тип крови:</b> [(Blood.data["blood_type"]||"нет")]<BR>"
			dat += "<b>Тип расовой крови:</b> [(Blood.data["blood_species"]||"нет")]<BR>"

			dat += "<h3>Данные о заболеваниях:</h3>"
			if(Blood.data["diseases"])
				var/i = 0
				for(var/datum/disease/D in Blood.data["diseases"])
					i++
					if(!(D.visibility_flags & HIDDEN_PANDEMIC))

						dat += "<b>Общепринятое название: </b>"

						if(istype(D, /datum/disease/virus/advance))
							var/datum/disease/virus/advance/A = D
							D = GLOB.archive_diseases[A.GetDiseaseID()]
							if(D)
								if(D.name == "Unknown")
									dat += "<b><a href='byond://?src=[UID()];name_disease=[i]'>Назвать вирус</a></b><BR>"
								else
									dat += "[D.name] <b><a href='byond://?src=[UID()];print_form=[i]'>Напечатать форму выпуска</a></b><BR>"
						else
							dat += "[D.name]<BR>"

						if(!D)
							CRASH("We weren't able to get the advance disease from the archive.")

						dat += "<b>Болезнетворный агент:</b> [D?"[D.agent] — <a href='byond://?src=[UID()];create_disease_culture=[i]'>Создать образец</A>":"нет"]<BR>"
						dat += "<b>Описание: </b> [(D.desc||"нет")]<BR>"
						dat += "<b>Путь передачи:</b> [(D.additional_info||"нет")]<BR>"
						dat += "<b>Возможное лекарство:</b> [(D.cure_text||"нет")]<BR>"
						dat += "<b>Возможность выработки антител:</b> [(D.can_immunity ? "Присутствует" : "Отсутствует")]<BR>"

						if(istype(D, /datum/disease/virus/advance))
							var/datum/disease/virus/advance/A = D
							dat += "<BR><b>Симптомы:</b> "
							var/english_symptoms = list()
							for(var/datum/symptom/S in A.symptoms)
								english_symptoms += S.name
							dat += english_list(english_symptoms)
						dat += "<BR>"
				if(i == 0)
					dat += "В образце не обнаружен вирус."
			else
				dat += "В образце не обнаружен вирус."

			if(Blood.data["resistances"])
				var/list/res = Blood.data["resistances"]
				if(res.len)
					dat += "<BR><b>Содержит антитела к:</b><ul>"
					var/i = 0
					for(var/type in Blood.data["resistances"])
						i++
						var/disease_name = "Unknown"

						if(!ispath(type))
							var/datum/disease/virus/advance/A = GLOB.archive_diseases[type]
							if(A)
								disease_name = A.name
						else
							var/datum/disease/D = new type()
							disease_name = D.name

						dat += "<li>[disease_name] - <a href='byond://?src=[UID()];create_vaccine=[i]'>Создать бутылёк с вакциной</A></li>"
					dat += "</ul><BR>"
				else
					dat += "<BR><b>Не содержит антител</b><BR>"
			else
				dat += "<BR><b>Не содержит антител</b><BR>"
		dat += "<BR><a href='byond://?src=[UID()];eject=1'>Извлечь мензурку</A>[((R.total_volume&&R.reagent_list.len) ? "-- <a href='byond://?src=[UID()];empty_beaker=1'>Очистить и извлечь мензурку</A>":"")]<BR>"
		dat += "<a href='byond://?src=[user.UID()];mach_close=pandemic'>Закрыть</A>"

	var/datum/browser/popup = new(user, "pandemic", name, 575, 480)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "pandemic")


/obj/machinery/computer/pandemic/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || (stat & (NOPOWER|BROKEN)))
		return ..()

	if(istype(I, /obj/item/reagent_containers))
		add_fingerprint(user)
		if(!(I.container_type & OPENCONTAINER))
			to_chat(user, span_warning("The [I.name] is incompatible."))
			return ATTACK_CHAIN_PROCEED
		if(beaker)
			to_chat(user, span_warning("The [name] already has [beaker] loaded."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		beaker = I
		to_chat(user, span_notice("You have inserted [I] into [src]."))
		updateUsrDialog()
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/computer/pandemic/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!beaker)
		add_fingerprint(user)
		to_chat(user, span_warning("There is no beaker installed."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	beaker.forceMove(drop_location())
	beaker = null
	updateUsrDialog()
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/computer/pandemic/wrench_act(mob/living/user, obj/item/I)
	return default_unfasten_wrench(user, I)

