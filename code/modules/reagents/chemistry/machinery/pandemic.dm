/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 220"
	desc = "Высокотехнологичная машина, предназначенная для исследования и работы с вирусными культурами. Лучший друг вирусолога!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	circuit = /obj/item/circuitboard/pandemic
	idle_power_usage = 20
	resistance_flags = ACID_PROOF
	var/obj/item/reagent_containers/beaker = null
	var/wait = null
	var/printing = null

/obj/machinery/computer/pandemic/get_ru_names()
	return alist(
		NOMINATIVE = "Панд.Е.М.И.К 220",
		GENITIVE = "Панд.Е.М.И.К 220",
		DATIVE = "Панд.Е.М.И.К 220",
		ACCUSATIVE = "Панд.Е.М.И.К 220",
		INSTRUMENTAL = "Панд.Е.М.И.К 220",
		PREPOSITIONAL = "Панд.Е.М.И.К 220",
	)

/obj/machinery/computer/pandemic/examine(mob/user)
	. = ..()
	if(panel_open)
		. += span_notice("Панель техобслуживания открыта.")

/obj/machinery/computer/pandemic/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/computer/pandemic/set_broken()
	stat |= BROKEN
	update_icon()

/obj/machinery/computer/pandemic/update_icon_state()
	if(stat & BROKEN)
		icon_state = "mixer[beaker ? "1" : "0"]_b"
		return
	icon_state = "mixer[beaker ? "1" : "0"][(powered()) ? "" : "_nopower"]"

/obj/machinery/computer/pandemic/update_overlays()
	. = ..()
	if(!(stat & BROKEN) && !wait)
		. += "waitlight"

/obj/machinery/computer/pandemic/attack_ai(mob/user)
	add_hiddenprint(user)
	attack_hand(user)

/obj/machinery/computer/pandemic/attack_hand(mob/user)
	add_fingerprint(user)
	if(..(user))
		return
	if(stat & (NOPOWER|BROKEN))
		return
	SStgui.update_uis(src)
	ui_interact(user)

/obj/machinery/computer/pandemic/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM || (stat & (NOPOWER|BROKEN)))
		return ..()

	if(istype(item, /obj/item/reagent_containers/dropper) && beaker)
		add_fingerprint(user)
		balloon_alert(user, "добавление реагента")
		var/obj/item/reagent_containers/dropper/dropper = item
		dropper.afterattack(beaker, user, TRUE, params, .)
		beaker.attackby(item, user, params)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(is_reagent_container(item))
		add_fingerprint(user)
		if(!(item.container_type & OPENCONTAINER))
			balloon_alert(user, "несовместимо!")
			return ATTACK_CHAIN_PROCEED
		if(beaker)
			balloon_alert(user, "слот для ёмкости занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(item, src))
			return ..()
		beaker = item
		balloon_alert(user, "ёмкость вставлена")
		var/datum/reagents/reagents = beaker.reagents
		for(var/datum/reagent/reagent as anything in reagents.reagent_list)
			var/list/reagent_data = reagent.data
			if((reagent.id in GLOB.diseases_carrier_reagents) && reagent_data && reagent_data["resistances"])
				var/list/original_resistances = reagent_data["resistances"]
				var/list/resistances = original_resistances.Copy()
				for(var/path in resistances)
					var/datum/disease/virus/virus_res = path
					if(initial(virus_res.no_vaccine))
						reagent_data["resistances"] -= path
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/machinery/computer/pandemic/screwdriver_act(mob/user, obj/item/item)
	. = TRUE
	if(!beaker)
		add_fingerprint(user)
		balloon_alert(user, "ёмкость отсутствует!")
		to_chat(user, span_warning("Ёмкость не установлена."))
		return .
	if(!item.use_tool(src, user, volume = item.tool_volume))
		return .
	beaker.forceMove(drop_location())
	beaker = null
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/computer/pandemic/wrench_act(mob/living/user, obj/item/item)
	return default_unfasten_wrench(user, item)

// MARK: TGUI
/obj/machinery/computer/pandemic/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PandemicSuper")
		ui.open()

/obj/machinery/computer/pandemic/ui_data(mob/user)
	var/list/data = list()
	// Transfer modal information if there is one
	data["modal"] = ui_modal_data(src)
	. = data

	data["error_message"] = null
	if(!beaker)
		data["error_message"] = "Ёмкость отсутствует!"
		data["beaker_exists"] = FALSE
		return
	data["beaker_exists"] = TRUE

	var/datum/reagents/reagents = beaker.reagents
	if(!reagents.total_volume || !length(reagents.reagent_list))
		data["error_message"] = "Ёмкость пуста!"
		return

	var/datum/reagent/blood = null
	for(var/datum/reagent/reagent in reagents.reagent_list)
		if(reagent.id in GLOB.diseases_carrier_reagents)
			blood = reagent
			if(!blood.data)
				continue
			break
	if(!blood)
		data["error_message"] = "В ёмкости отсутствует образец крови!"
		return

	if(!blood.data)
		data["error_message"] = "В ёмкости отсутствует данные крови!"
		return

	var/list/blood_data = list()
	blood_data["dna"] = blood.data["blood_DNA"] || "нет"
	blood_data["group"] = blood.data["blood_type"] || "нет"
	blood_data["type"] = blood.data["blood_species"] || "нет"
	data["blood_data"] = blood_data

	data["diseases"] = null
	if(blood.data["diseases"])
		var/list/diseases = list()
		var/i = 0
		for(var/datum/disease/disease in blood.data["diseases"])
			i++
			if(disease.visibility_flags & HIDDEN_PANDEMIC)
				continue

			var/list/disease_data = list()
			disease_data["index"] = i

			if(istype(disease, /datum/disease/virus/advance))
				var/datum/disease/virus/advance/adv_virus = disease
				disease = GLOB.archive_diseases[adv_virus.GetDiseaseID()]
				if(disease)
					if(disease.name == UNKNOWN_STATUS_RUS)
						disease_data["name"] = "Неизвестно"
					else
						disease_data["name"] = disease.name
			else
				disease_data["name"] = disease.name

			if(!disease)
				CRASH("We weren't able to get the advance disease from the archive.")


			disease_data["agent"] = disease ? disease.agent : "нет"
			disease_data["description"] = disease.desc || "нет"
			disease_data["route"] = disease.additional_info || "нет"
			disease_data["possibleMedicine"] = disease.cure_text || "нет"
			disease_data["antibodiesPossibility"] = disease.can_immunity ? "Присутствует" : "Отсутствует"
			disease_data["allow_remove_sympthoms"] = FALSE
			disease_data["allow_add_sympthoms"] = FALSE

			if(istype(disease, /datum/disease/virus/advance))
				var/datum/disease/virus/advance/advance_virus = disease
				var/symptoms_list = list()
				for(var/datum/symptom/symptom in advance_virus.symptoms)
					symptoms_list += symptom.name
				disease_data["symptoms"] = russian_list(symptoms_list)
				if(length(symptoms_list) > 1)
					disease_data["allow_remove_sympthoms"] = TRUE
				disease_data["allow_add_sympthoms"] = TRUE
			else
				disease_data["symptoms"] = "Отсутствуют"

			diseases += list(disease_data)

		if(length(diseases))
			data["diseases"] = diseases

		data["antibodies"] = null
		if(blood.data["resistances"])
			var/list/res = blood.data["resistances"]
			if(length(res))
				var/list/antibodies = list()
				var/index = 0
				for(var/type in blood.data["resistances"])
					index++
					var/list/antibody = list()
					antibody["index"] = index
					var/disease_name = UNKNOWN_STATUS_RUS

					if(!ispath(type))
						var/datum/disease/virus/advance/A = GLOB.archive_diseases[type]
						if(A)
							disease_name = A.name
					else
						var/datum/disease/disease = new type()
						disease_name = disease.name

					antibody["name"] = disease_name
					antibodies += list(antibody)

				data["antibodies"] = antibodies


	return data

/obj/machinery/computer/pandemic/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return FALSE
	add_fingerprint(usr)
	playsound(loc, SFX_TERMINAL_TYPE, 25, TRUE)
	if(ui_act_modal(action, params))
		return TRUE
	. = TRUE
	switch(action)
		if("extractBeaker")
			eject_beaker()

		if("clearAndExtractBeaker")
			beaker.reagents.clear_reagents()
			eject_beaker()

		if("renameDisease")
			var/new_name = tgui_input_text(usr, "Назовите вирус:", "Введите название вируса", max_length = MAX_NAME_LEN)
			if(!new_name)
				return
			var/id = GetDiseaseTypeByIndex(text2num(params["index"]))
			if(GLOB.archive_diseases[id])
				var/datum/disease/virus/advance/advanced_disease = GLOB.archive_diseases[id]
				advanced_disease.AssignName(new_name)
				for(var/datum/disease/virus/advance/adv_disease in GLOB.active_diseases)
					adv_disease.Refresh(update_properties = FALSE)
			SStgui.update_uis(src)

		if("printForm")
			var/datum/disease/disease = GetDiseaseByIndex(text2num(params["index"]))
			disease = GLOB.archive_diseases[disease.GetDiseaseID()]//We know it's advanced no need to check
			print_form(disease, usr)

		if("createExample")
			if(wait)
				return
			var/datum/disease/disease = GetDiseaseByIndex(text2num(params["index"]))
			var/datum/disease/copy
			if(istype(disease, /datum/disease/virus/advance))
				var/datum/disease/virus/advance/adv_disease = GLOB.archive_diseases[disease.GetDiseaseID()]
				if(adv_disease)
					copy = adv_disease.Copy()
			if(!copy)
				copy = disease.Copy()
			if(!copy)
				return
			var/name = tgui_input_text(usr, "Название:", "Введите название культуры", disease.name, MAX_NAME_LEN)
			if(name == null || wait)
				return
			var/obj/item/reagent_containers/glass/bottle/bottle = new(loc)
			bottle.icon_state = "round_bottle"
			bottle.pixel_x = rand(-3, 3)
			bottle.pixel_y = rand(-3, 3)
			replicator_cooldown(5 SECONDS)
			var/list/data = list("diseases"=list(copy))
			bottle.name = "культура [capitalize(name)]"
			bottle.ru_names = alist(
				NOMINATIVE = "культура [capitalize(name)]",
				GENITIVE = "культуры [capitalize(name)]",
				DATIVE = "культуре [capitalize(name)]",
				ACCUSATIVE = "культуру [capitalize(name)]",
				INSTRUMENTAL = "культурой [capitalize(name)]",
				PREPOSITIONAL = "культуре [capitalize(name)]",
			)
			bottle.desc = "Небольшая бутылка. Содержит синтетическую кровь, заражённую культурой [capitalize(copy.agent)]."
			bottle.reagents.add_reagent("blood", 20, data)

		if("addSympthom")
			add_random_symptom(text2num(params["index"]))
			SStgui.update_uis(src)

		if("removeSympthom")
			remove_random_symptom(text2num(params["index"]))
			SStgui.update_uis(src)

		if("createVaccine")
			if(wait)
				return
			var/obj/item/reagent_containers/glass/bottle/bottle = new/obj/item/reagent_containers/glass/bottle(loc)
			if(!bottle)
				return
			bottle.pixel_x = rand(-3, 3)
			bottle.pixel_y = rand(-3, 3)
			var/path = GetResistancesByIndex(text2num(params["index"]))
			var/vaccine_type = path
			var/vaccine_name = UNKNOWN_STATUS_RUS

			if(!ispath(vaccine_type))
				if(GLOB.archive_diseases[path])
					var/datum/disease/disease = GLOB.archive_diseases[path]
					if(disease)
						vaccine_name = disease.name
						vaccine_type = path
			else if(vaccine_type)
				var/datum/disease/disease = new vaccine_type
				if(disease)
					vaccine_name = disease.name

			if(vaccine_type)
				bottle.name = "вакцина [capitalize(vaccine_name)]"
				bottle.ru_names = alist(
					NOMINATIVE = "вакцина [capitalize(vaccine_name)]",
					GENITIVE = "вакцины [capitalize(vaccine_name)]",
					DATIVE = "вакцине [capitalize(vaccine_name)]",
					ACCUSATIVE = "вакцину [capitalize(vaccine_name)]",
					INSTRUMENTAL = "вакциной [capitalize(vaccine_name)]",
					PREPOSITIONAL = "вакцине [capitalize(vaccine_name)]",
				)
				bottle.reagents.add_reagent("vaccine", 15, list(vaccine_type))
				replicator_cooldown(20 SECONDS)

/obj/machinery/computer/pandemic/proc/ui_act_modal(action, params)
	return FALSE


// MARK: Actions
/obj/machinery/computer/pandemic/proc/eject_beaker()
	beaker.forceMove(loc)
	beaker = null
	icon_state = "mixer0"


//Prints a nice virus release form. Props to Urbanliner for the layout
/obj/machinery/computer/pandemic/proc/print_form(datum/disease/virus/advance/disease, mob/living/user)
	disease = GLOB.archive_diseases[disease.GetDiseaseID()]
	if(!(printing) && disease)
		var/reason = tgui_input_text(user,"Укажите причину выпуска", "Указать", multiline = TRUE)
		reason += "<span class=\"paper_field\"></span>"
		var/symptoms_list = list()
		for(var/datum/symptom/symptom in disease.symptoms)
			symptoms_list += symptom.name
		var/symtoms = russian_list(symptoms_list)

		var/signature
		if(tgui_alert(user, "Вы хотите подписать этот документ?", "Подпись", list("Да","Нет")) == "Да")
			signature = "<span style='font-face: \"[SIGNFONT]\";'><i>[user ? user.real_name : UNKNOWN_NAME_RUS]</i></span>"
		else
			signature = "<span class=\"paper_field\"></span>"

		printing = 1
		var/obj/item/paper/form = new /obj/item/paper(loc)
		visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] дребезжит, после чего из окна печати выпадает лист бумаги."))
		playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)

		form.info = span_fontsize4("<u><b><center> Выпуск вируса </b></center></u>")
		form.info += "<hr>"
		form.info += "<u>Название вируса:</u> [disease.name] <br>"
		form.info += "<u>Симптомы:</u> [symtoms]<br>"
		form.info += "<u>Путь передачи:</u> [disease.additional_info]<br>"
		form.info += "<u>Лекарство от вируса:</u> [disease.cure_text]<br>"
		form.info += "<br>"
		form.info += "<u>Причина выпуска:</u> [reason]"
		form.info += "<hr>"
		form.info += "Вирусолог, ответственный за любые биологические угрозы, возникшие вследствие выпуска вируса.<br>"
		form.info += "<u>Подпись вирусолога:</u> [signature]<br>"
		form.info += "Печать ответственного лица, разрешившего выпуск вируса:"
		form.populatefields()
		form.updateinfolinks()
		form.name = "Выпуск вируса «[disease.name]»"
		form.update_icon()
		printing = null


// MARK: Utilitary procs
/obj/machinery/computer/pandemic/proc/GetDiseaseByIndex(index)
	if(length(beaker?.reagents?.reagent_list))
		for(var/datum/reagent/BL in beaker.reagents.reagent_list)
			if(BL?.data && BL.data["diseases"])
				var/list/diseases = BL.data["diseases"]
				return diseases[index]

/obj/machinery/computer/pandemic/proc/GetResistancesByIndex(index)
	if(length(beaker?.reagents?.reagent_list))
		for(var/datum/reagent/BL in beaker.reagents.reagent_list)
			if(BL?.data && BL.data["resistances"])
				var/list/resistances = BL.data["resistances"]
				return resistances[index]

/obj/machinery/computer/pandemic/proc/GetDiseaseTypeByIndex(index)
	var/datum/disease/disease = GetDiseaseByIndex(index)
	if(disease)
		return disease.GetDiseaseID()

/obj/machinery/computer/pandemic/proc/replicator_cooldown(waittime)
	wait = 1
	update_icon()
	spawn(waittime)
		wait = null
		update_icon()
		playsound(loc, 'sound/machines/ping.ogg', 30, TRUE)

/obj/machinery/computer/pandemic/proc/add_random_symptom(index)
	var/datum/disease/disease = GetDiseaseByIndex(index)
	if(!istype(disease, /datum/disease/virus/advance))
		balloon_alert(usr, "ошибка!")
		return

	var/datum/disease/virus/advance/advance_virus = disease
	GET_SKILL_LEVEL(usr, /datum/skill/medical/virusology, virusology_skill_level)
	var/random_symptom = null
	if(virusology_skill_level > SKILL_LEVEL_BASIC)
		var/list/random_symptoms = advance_virus.GenerateSymptoms(level_max = virusology_skill_level, count_of_symptoms = (2 + (virusology_skill_level-SKILL_LEVEL_BASIC)))
		random_symptom = tgui_input_list(usr, "Выберите симптом для добавления", "Добавление симптома", random_symptoms)
	else
		random_symptom = safepick(advance_virus.GenerateSymptoms(level_max = virusology_skill_level))

	if(random_symptom)
		advance_virus.AddSymptom(random_symptom)
		advance_virus.Refresh(reset_name = TRUE)


/obj/machinery/computer/pandemic/proc/remove_random_symptom(index)
	var/datum/disease/disease = GetDiseaseByIndex(index)
	if(!istype(disease, /datum/disease/virus/advance))
		balloon_alert(usr, "ошибка!")
		return

	var/datum/disease/virus/advance/advance_virus = disease
	GET_SKILL_LEVEL(usr, /datum/skill/medical/virusology, virusology_skill_level)
	var/random_symptom = null
	if(virusology_skill_level > SKILL_LEVEL_BASIC)
		random_symptom = tgui_input_list(usr, "Выберите симптом для удаления", "Удаление симптома", advance_virus.symptoms)
	else
		random_symptom = safepick(advance_virus.symptoms)

	if(random_symptom)
		advance_virus.RemoveSymptom(random_symptom)
		advance_virus.Refresh(reset_name = TRUE)
