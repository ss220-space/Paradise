#define SEC_DATA_R_LIST	1	// Record list
#define SEC_DATA_MAINT	2	// Records maintenance
#define SEC_DATA_RECORD	3	// Record

#define SEC_FIELD(N, V, E, LB) list(field = N, value = V, edit = E, line_break = LB)

/obj/machinery/computer/secure_data
	name = "security records"
	desc = "Используется для просмотра и редактирования записей службы безопасности о персонале."
	ru_names = list(
		NOMINATIVE = "компьютер записей службы безопасности",
		GENITIVE = "компьютера записей службы безопасности",
		DATIVE = "компьютеру записей службы безопасности",
		ACCUSATIVE = "компьютер записей службы безопасности",
		INSTRUMENTAL = "компьютером записей службы безопасности",
		PREPOSITIONAL = "компьютере записей службы безопасности"
	)
	icon_keyboard = "security_key"
	icon_screen = "security"
	circuit = /obj/item/circuitboard/secure_data
	req_access = list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS)
	/// The current page being viewed.
	var/current_page = SEC_DATA_R_LIST
	/// The current general record being viewed.
	var/datum/data/record/record_general = null
	/// The current security record being viewed.
	var/datum/data/record/record_security = null
	/// Whether the computer is currently printing a paper or not.
	var/is_printing = FALSE
	/// The editable fields and their associated question to display to the user.
	var/static/list/field_edit_questions
	/// The editable fields and their associated choices to display to the user.
	var/static/list/field_edit_choices
	/// The current temporary notice.
	var/temp_notice
	/// For records in pai
	var/atom/movable/parent

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/secure_data/Initialize(mapload)
	. = ..()
	if(!field_edit_questions)
		field_edit_questions = list(
			// General
			"name" = "Введите новое имя:",
			"id" = "Выберите новый ID:",
			"sex" = "Выберите новый пол:",
			"age" = "Введите новый возраст:",
			"fingerprint" = "Введите новый хэш отпечатков пальцев:",
			// Security
			"criminal" = "Выберите новый статус:",
			"mi_crim" = "Введите новые незначительные преступления:",
			"mi_crim_d" = "Введите детали мелких преступлений:",
			"ma_crim" = "Введите новые тяжкие преступления:",
			"ma_crim_d" = "Введите детали тяжких преступлений:",
			"notes" = "Введите новые примечания:",
		)
		field_edit_choices = list(
			// General
			"sex" = list("Мужской", "Женский"),
			// Security
			"criminal" = list(SEC_RECORD_STATUS_NONE, SEC_RECORD_STATUS_ARREST, SEC_RECORD_STATUS_EXECUTE, SEC_RECORD_STATUS_INCARCERATED, SEC_RECORD_STATUS_RELEASED, SEC_RECORD_STATUS_PAROLLED, SEC_RECORD_STATUS_SEARCH, SEC_RECORD_STATUS_MONITOR),
		)

/obj/machinery/computer/secure_data/Destroy()
	record_general = null
	record_security = null
	return ..()


/obj/machinery/computer/secure_data/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(ui_login_attackby(I, user))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/computer/secure_data/attack_hand(mob/user)
	if(..())
		return
	if(is_away_level(z))
		balloon_alert(user, "нет связи!")
		return
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/secure_data/ui_host()
	return parent ? parent : src

/obj/machinery/computer/secure_data/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SecurityRecords", name)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/computer/secure_data/ui_data(mob/user)
	var/list/data = list()
	data["currentPage"] = current_page
	data["isPrinting"] = is_printing
	ui_login_data(data, user)
	data["modal"] = ui_modal_data()
	data["temp"] = temp_notice
	if(data["loginState"]["logged_in"])
		switch(current_page)
			if(SEC_DATA_R_LIST)
				// Prepare the list of security records to associate with the general ones.
				// This is not ideal but datacore code sucks and needs to be rewritten.
				var/list/sec_records_assoc = list()
				for(var/datum/data/record/S in GLOB.data_core.security)
					sec_records_assoc["[S.fields["name"]]|[S.fields["id"]]"] = S
				// List the general records
				var/list/records = list()
				data["records"] = records
				for(var/datum/data/record/G in GLOB.data_core.general)
					var/datum/data/record/S = sec_records_assoc["[G.fields["name"]]|[G.fields["id"]]"]
					var/list/record_line = list("uid_gen" = G.UID(), "id" = G.fields["id"], "name" = G.fields["name"], "rank" = G.fields["rank"], "fingerprint" = G.fields["fingerprint"])
					record_line["status"] = S?.fields["criminal"] || "No record"
					record_line["uid_sec"] = S?.UID() // So we don't have to perform the search through a for loop again later
					records[++records.len] = record_line
			if(SEC_DATA_RECORD)
				var/list/general = list()
				data["general"] = general
				if(record_general && GLOB.data_core.general.Find(record_general))
					var/list/gen_fields = record_general.fields
					general["fields"] = list(
						SEC_FIELD("Имя", 				gen_fields["name"], 		"name",			FALSE),
						SEC_FIELD("ID", 				gen_fields["id"], 			"id",			TRUE),
						SEC_FIELD("Пол", 				gen_fields["sex"], 			"sex",			FALSE),
						SEC_FIELD("Возраст", 				gen_fields["age"], 			"age",			TRUE),
						SEC_FIELD("Должность", 		gen_fields["rank"], 		null,			FALSE),
						SEC_FIELD("Хэш отпечатков пальцев", 		gen_fields["fingerprint"], 	"fingerprint",	TRUE),
						SEC_FIELD("Физическое состояние", 	gen_fields["p_stat"], 		null,			FALSE),
						SEC_FIELD("Психологическое состояние", 		gen_fields["m_stat"], 		null,			TRUE),
						SEC_FIELD("Важные примечания", 	gen_fields["notes"], 		null,			FALSE),
					)
					general["photos"] = list(
						gen_fields["photo-south"],
						gen_fields["photo-west"],
					)
					general["has_photos"] = (gen_fields["photo-south"] || gen_fields["photo-west"]) ? TRUE : FALSE
					general["empty"] = FALSE
				else
					general["empty"] = TRUE

				var/list/security = list()
				data["security"] = security
				if(record_security && GLOB.data_core.security.Find(record_security))
					var/list/sec_fields = record_security.fields
					security["fields"] = list(
						SEC_FIELD("Статус", 	sec_fields["criminal"], 	"criminal", 	TRUE),
						SEC_FIELD("Незначительные преступления", 		sec_fields["mi_crim"], 		"mi_crim", 		FALSE),
						SEC_FIELD("Детали", 			sec_fields["mi_crim_d"], 	"mi_crim_d", 	TRUE),
						SEC_FIELD("Тяжкие преступления", 		sec_fields["ma_crim"], 		"ma_crim", 		FALSE),
						SEC_FIELD("Детали", 			sec_fields["ma_crim_d"], 	"ma_crim_d", 	TRUE),
						SEC_FIELD("Важные примечания", 	sec_fields["notes"], 		null, 			FALSE),
					)
					if(!islist(sec_fields["comments"]))
						sec_fields["comments"] = list()
					security["comments"] = sec_fields["comments"]
					security["empty"] = FALSE
				else
					security["empty"] = TRUE

	return data

/obj/machinery/computer/secure_data/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	if(ui_act_modal(action, params))
		return
	if(ui_login_act(action, params))
		return

	var/logged_in = ui_login_get().logged_in
	switch(action)
		if("cleartemp")
			temp_notice = null
		if("page") // Select Page
			if(!logged_in)
				return
			var/page_num = clamp(text2num(params["page"]), SEC_DATA_R_LIST, SEC_DATA_MAINT) // SEC_DATA_RECORD cannot be accessed through this act
			current_page = page_num
			record_general = null
			record_security = null
		if("view") // View Record
			if(!logged_in)
				return
			var/datum/data/record/G = locateUID(params["uid_gen"])
			var/datum/data/record/S = locateUID(params["uid_sec"])
			if(!istype(G)) // No general record!
				set_temp("Запись не найдена!", "danger")
				return
			if(istype(S) && !(G.fields["name"] == S.fields["name"] && G.fields["id"] == S.fields["id"])) // General and security records don't match!
				S = null
			record_general = G
			record_security = S
			current_page = SEC_DATA_RECORD
		if("new_general") // New General Record
			if(!logged_in)
				return
			if(record_general)
				return
			var/datum/data/record/G = new /datum/data/record()
			G.fields["name"] = "Новая Запись"
			G.fields["id"] = "[add_zero(num2hex(rand(1, 1.6777215E7), 2), 6)]"
			G.fields["rank"] = "Не присвоено"
			G.fields["real_rank"] = "Не присвоено"
			G.fields["sex"] = "Мужской"
			G.fields["age"] = "Не указано"
			G.fields["fingerprint"] = "Не указано"
			G.fields["p_stat"] = "Активный"
			G.fields["m_stat"] = "Стабильный"
			G.fields["species"] = SPECIES_HUMAN
			G.fields["notes"] = "Нет примечаний."
			GLOB.data_core.general += G
			record_general = G
			record_security = null
			current_page = SEC_DATA_RECORD
		if("new_security") // New Security Record
			if(!logged_in)
				return
			if(!record_general || record_security)
				return
			var/datum/data/record/S = new /datum/data/record()
			S.fields["name"] = record_general.fields["name"]
			S.fields["id"] = record_general.fields["id"]
			S.name = "Запись безопасности #[S.fields["id"]]"
			S.fields["criminal"] = SEC_RECORD_STATUS_NONE
			S.fields["mi_crim"] = "Нет"
			S.fields["mi_crim_d"] = "Отсутствие судимостей за незначительные преступления."
			S.fields["ma_crim"] = "Нет"
			S.fields["ma_crim_d"] = "Отсутствие судимостей за тяжкие преступления."
			S.fields["notes"] = "Нет примечаний."
			GLOB.data_core.security += S
			record_security = S
			update_all_mob_security_hud()
		if("delete_general") // Delete General, Security and Medical Records
			if(!logged_in)
				return
			if(!record_general)
				return
			message_admins("[ADMIN_LOOKUPFLW(usr)] удалил общие, медицинские и охранные записи [record_general.fields["name"]] в [ADMIN_COORDJMP(usr)]")
			add_misc_logs(usr, "удалил [record_general.fields["name"]] общие, медицинские и записи безопасности")
			usr.investigate_log("удалил [record_general.fields["name"]] общие, медицинские и записи безопасности", INVESTIGATE_RECORDS)
			for(var/datum/data/record/M in GLOB.data_core.medical)
				if(M.fields["name"] == record_general.fields["name"] && M.fields["id"] == record_general.fields["id"])
					qdel(M)
			QDEL_NULL(record_general)
			QDEL_NULL(record_security)
			update_all_mob_security_hud()
			current_page = SEC_DATA_R_LIST
			set_temp("Все записи удалены.")
		if("delete_security") // Delete Security Record
			if(!logged_in)
				return
			if(!record_security)
				return
			message_admins("[ADMIN_LOOKUPFLW(usr)] удалил запись безопасности [record_security.fields["name"]] в [ADMIN_COORDJMP(usr)]")
			add_misc_logs(usr, "deleted [record_security.fields["name"]]'s security record")
			usr.investigate_log("deleted [record_security.fields["name"]]'s security record", INVESTIGATE_RECORDS)
			QDEL_NULL(record_security)
			update_all_mob_security_hud()
			set_temp("Запись удалена.")
		if("delete_security_all") // Delete All Security Records
			if(!logged_in)
				return
			for(var/datum/data/record/S in GLOB.data_core.security)
				qdel(S)
			message_admins("[ADMIN_LOOKUPFLW(usr)] удалил все записи службы безопасности [ADMIN_COORDJMP(usr)]")
			add_misc_logs(usr, "deleted all security records")
			usr.investigate_log("deleted all security records", INVESTIGATE_RECORDS)
			update_all_mob_security_hud()
			set_temp("Все записи службы безопасности удалены.")
		if("delete_cell_logs") // Delete All Cell Logs
			if(!logged_in)
				return
			if(!length(GLOB.cell_logs))
				set_temp("Нет записей камер заключения для удаления.")
				return
			message_admins("[ADMIN_LOOKUPFLW(usr)] удалил все записи камер заключения в [ADMIN_COORDJMP(usr)]")
			add_misc_logs(usr, "deleted all cell logs")
			usr.investigate_log("deleted all cell logs", INVESTIGATE_RECORDS)
			GLOB.cell_logs.Cut()
			set_temp("Все записи камер заключения удалены.")
		if("comment_delete") // Delete Comment
			if(!logged_in)
				return
			var/index = text2num(params["id"])
			if(!index || !record_security)
				return

			var/list/comments = record_security.fields["comments"]
			if(!length(comments))
				return
			index = clamp(index, 1, length(comments))
			comments.Cut(index, index + 1)
		if("print_record")
			if(!logged_in)
				return
			if(is_printing)
				return
			is_printing = TRUE
			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
			addtimer(CALLBACK(src, PROC_REF(print_record_finish)), 5 SECONDS)
		else
			return FALSE

	add_fingerprint(usr)

/**
  * Called in ui_act() to process modal actions
  *
  * Arguments:
  * * action - The action passed by tgui
  * * params - The params passed by tgui
  */
/obj/machinery/computer/secure_data/proc/ui_act_modal(action, list/params)
	if(!ui_login_get().logged_in)
		return
	. = TRUE
	var/id = params["id"]
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			switch(id)
				if("edit")
					var/field = arguments["field"]
					if(!length(field) || !field_edit_questions[field])
						return
					var/question = field_edit_questions[field]
					var/choices = field_edit_choices[field]
					if(length(choices))
						ui_modal_choice(src, id, question, arguments = arguments, value = arguments["value"], choices = choices)
					else
						ui_modal_input(src, id, question, arguments = arguments, value = arguments["value"])
				if("comment_add")
					ui_modal_input(src, id, "Введите комментарий:")
				if("print_cell_log")
					if(is_printing)
						return
					if(!length(GLOB.cell_logs))
						set_temp("Нет доступных записей для печати.")
						return
					var/list/choices = list()
					var/list/already_in = list()
					for(var/p in GLOB.cell_logs)
						var/obj/item/paper/P = p
						if(already_in[P.name])
							continue
						choices += P.name
						already_in[P.name] = TRUE
					ui_modal_choice(src, id, "Выберите, что вы хотите распечатать:", choices = choices)
				else
					return FALSE
		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			switch(id)
				if("edit")
					var/field = arguments["field"]
					if(!length(field) || !field_edit_questions[field])
						return
					var/list/choices = field_edit_choices[field]
					if(length(choices) && !(answer in choices))
						return

					if(field == "age")
						if(!record_general)
							return

						var/datum/species/species = GLOB.all_species[record_general.fields["species"]]
						var/new_age = text2num(answer)
						var/age_limits = get_age_limits(species, list(SPECIES_AGE_MIN, SPECIES_AGE_MAX))
						if(new_age < age_limits[SPECIES_AGE_MIN] || new_age > age_limits[SPECIES_AGE_MAX])
							set_temp("Неверный возраст. Он должен быть между [age_limits[SPECIES_AGE_MIN]] и [age_limits[SPECIES_AGE_MAX]].", "danger")
							return

						answer = new_age

					if(field == "criminal")
						var/text = "Укажите причину изменения статуса на [answer]:"
						if(answer == SEC_RECORD_STATUS_EXECUTE)
							text = "Укажите причину казни."
						else if(answer == SEC_RECORD_STATUS_DEMOTE)
							text = "Укажите причину понижения в должности."
						ui_modal_input(src, "criminal_reason", text, arguments = list("status" = answer))
						return

					if(record_security && (field in record_security.fields))
						record_security.fields[field] = answer
					if(record_general && (field in record_general.fields))
						record_general.fields[field] = answer
				if("criminal_reason")
					var/status = arguments["status"]
					if(!record_security || !(status in field_edit_choices["criminal"]))
						return
					if((status in list(SEC_RECORD_STATUS_EXECUTE, SEC_RECORD_STATUS_DEMOTE)) && !length(answer))
						set_temp("Должна быть указана причина.", "danger")
						return
					var/datum/ui_login/state = ui_login_get()
					if(!set_criminal_status(usr, record_security, status, answer, state.rank, state.access, state.name))
						set_temp("Не обнаружен необходимый доступ для установки этого статуса!", "danger")
				if("comment_add")
					var/datum/ui_login/state = ui_login_get()
					if(!length(answer) || !record_security || !length(state.name))
						return
					record_security.fields["comments"] += list(list(
						header = "Создано [state.name] ([state.rank]) в [GLOB.current_date_string] [station_time_timestamp()]",
						text = answer
					))
				if("print_cell_log")
					if(is_printing)
						return
					var/obj/item/paper/T
					for(var/obj/item/paper/P in GLOB.cell_logs)
						if(P.name == answer)
							T = P
							break
					if(!T)
						set_temp("Записи камер не найдены!", "danger")
						return
					is_printing = TRUE
					playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
					addtimer(CALLBACK(src, PROC_REF(print_cell_log_finish), T.name, T.info), 5 SECONDS)
				else
					return FALSE
		else
			return FALSE

/**
  * Called when the print record timer finishes
  */
/obj/machinery/computer/secure_data/proc/print_record_finish()
	var/obj/item/paper/P = new(loc)
	P.info = "<center><b>Отдел защиты активов</b></center><br>"
	if(record_general && GLOB.data_core.general.Find(record_general))
		P.info += {"Имя: [record_general.fields["name"]]
				<br>\nID: [record_general.fields["id"]]
				<br>\nПол: [record_general.fields["sex"]]
				<br>\nВозраст: [record_general.fields["age"]]
				<br>\nХэш отпечатков пальцев: [record_general.fields["fingerprint"]]
				<br>\nФизическое состояние: [record_general.fields["p_stat"]]
				<br>\nПсихологическое состояние: [record_general.fields["m_stat"]]<br>"}
		P.name = "paper - 'Запись службы безопасности: [record_general.fields["name"]]'"
		var/obj/item/photo/photo = new(loc)
		//photo.img = record_general.fields["photo"]
		var/icon/new_photo = icon('icons/effects/64x32.dmi', "records")
		new_photo.Blend(icon(record_general.fields["photo"], dir = SOUTH), ICON_OVERLAY, 0)
		new_photo.Blend(icon(record_general.fields["photo"], dir = WEST), ICON_OVERLAY, 32)
		new_photo.Scale(new_photo.Width() * 5, new_photo.Height() * 5)
		photo.img = new_photo
		photo.name = "photo - 'Запись службы безопасности: [record_general.fields["name"]]'"
	else
		P.info += "<b>Общие записи утеряны!</b><br>"
	if(record_security && GLOB.data_core.security.Find(record_security))
		P.info += {"<br>\n<center><b>Данные службы безопасности</b></center>
		<br>\nСтатус: [record_security.fields["criminal"]]<br>\n
		<br>\nНезначительные преступления: [record_security.fields["mi_crim"]]
		<br>\nДетали: [record_security.fields["mi_crim_d"]]<br>\n
		<br>\nТяжкие преступления: [record_security.fields["ma_crim"]]
		<br>\nДетали: [record_security.fields["ma_crim_d"]]<br>\n
		<br>\nВажные примечания:
		<br>\n\t[record_security.fields["notes"]]<br>\n<br>\n<center><b>Комментарии:</b></center><br>"}
		for(var/c in record_security.fields["comments"])
			P.info += "[c]<br>"
	else
		P.info += "<b>Запись службы безопасности отсутствует!</b><br>"
	is_printing = FALSE
	SStgui.update_uis(src)

/**
  * Called when the print cell log timer finishes
  */
/obj/machinery/computer/secure_data/proc/print_cell_log_finish(name, info)
	var/obj/item/paper/P = new(loc)
	P.name = name
	P.info = info
	is_printing = FALSE
	SStgui.update_uis(src)

/obj/machinery/computer/secure_data/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	for(var/datum/data/record/R in GLOB.data_core.security)
		if(prob(10 / severity))
			switch(rand(1, 6))
				if(1)
					R.fields["name"] = pick("[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]", "[pick(GLOB.first_names_female)] [pick(GLOB.last_names_female)]")
				if(2)
					R.fields["sex"] = pick("Мужской", "Женский")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["criminal"] = pick(SEC_RECORD_STATUS_NONE, SEC_RECORD_STATUS_ARREST, SEC_RECORD_STATUS_SEARCH, SEC_RECORD_STATUS_MONITOR, SEC_RECORD_STATUS_INCARCERATED, SEC_RECORD_STATUS_PAROLLED, SEC_RECORD_STATUS_RELEASED)
				if(5)
					R.fields["p_stat"] = pick("*Без сознания*", "Активен", "Физически непригоден")
				if(6)
					R.fields["m_stat"] = pick("*Невменяемость*", "*Нестабильное*", "*Рекомендуется наблюдение*", "Стабильное")
			continue

		else if(prob(1))
			qdel(R)
			continue

	..(severity)

/**
  * Sets a temporary message to display to the user
  *
  * Arguments:
  * * text - Text to display, null/empty to clear the message from the UI
  * * style - The style of the message: (color name), info, success, warning, danger
  */
/obj/machinery/computer/secure_data/proc/set_temp(text = "", style = "info", update_now = FALSE)
	temp_notice = list(text = text, style = style)
	if(update_now)
		SStgui.update_uis(src)

/obj/machinery/computer/secure_data/laptop
	name = "security laptop"
	desc = "Ноутбук службы безопасности Nanotrasen. Привносим современные компактные компьютеры в наше столетие!"
	ru_names = list(
		NOMINATIVE = "ноутбук службы безопасности",
		GENITIVE = "ноутбука службы безопасности",
		DATIVE = "ноутбуку службы безопасности",
		ACCUSATIVE = "ноутбук службы безопасности",
		INSTRUMENTAL = "ноутбуком службы безопасности",
		PREPOSITIONAL = "ноутбуке службы безопасности"
	)
	icon_state = "laptop"
	icon_keyboard = "seclaptop_key"
	icon_screen = "seclaptop"
	density = FALSE

#undef SEC_DATA_R_LIST
#undef SEC_DATA_MAINT
#undef SEC_DATA_RECORD
#undef SEC_FIELD
