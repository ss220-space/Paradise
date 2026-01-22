/**
 * Syndicate Agent ID card + Taipan variants
 */

#define NOT_SPECIFIED "НЕ ЗАДАНО"

/obj/item/card/id/syndicate
	name = "agent card"
	var/list/initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS)
	origin_tech = "syndicate=1"
	var/mob/living/carbon/human/registered_user = null
	untrackable = 1
	/// Can anyone forge the ID or just syndicate?
	var/anyone = FALSE
	var/list/save_slots = list()
	var/num_of_save_slots = 3
	var/list/appearances = list(
		"data",
		"id",
		"gold",
		"silver",
		"centcom",
		"centcom_old",
		"security",
		"medical",
		"HoS",
		"research",
		"cargo",
		"engineering",
		"CMO",
		"RD",
		"CE",
		"clown",
		"mime",
		"rainbow",
		"prisoner",
		"commander",
		"syndie",
		"syndierd",
		"syndiebotany",
		"syndiecargo",
		"syndiernd",
		"syndieengineer",
		"syndiechef",
		"syndiemedical",
		"deathsquad",
		"ERT_leader",
		"ERT_security",
		"ERT_engineering",
		"ERT_medical",
		"ERT_janitorial",
		"mining_medic",
	)

/obj/item/card/id/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "карта агента \"Синдиката\"",
		GENITIVE = "карты агента \"Синдиката\"",
		DATIVE = "карте агента \"Синдиката\"",
		ACCUSATIVE = "карту агента \"Синдиката\"",
		INSTRUMENTAL = "картой агента \"Синдиката\"",
		PREPOSITIONAL = "карте агента \"Синдиката\"",
	)

/obj/item/card/id/syndicate/anyone
	anyone = TRUE

/obj/item/card/id/syndicate/Initialize(mapload)
	access = initial_access.Copy()
	. = ..()
	save_slots.len = num_of_save_slots
	for(var/i = 1 to num_of_save_slots)
		save_slots[i] = list()

/obj/item/card/id/syndicate/vox
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_VOX, ACCESS_EXTERNAL_AIRLOCKS)

// Added all syndicate 'Taipan' access to the admin officer
/obj/item/card/id/syndicate/command
	initial_access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_SYNDICATE,
		ACCESS_SYNDICATE_LEADER,
		ACCESS_SYNDICATE_COMMAND,
		ACCESS_SYNDICATE_COMMS_OFFICER,
		ACCESS_SYNDICATE_RESEARCH_DIRECTOR,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_SYNDICATE_SCIENTIST,
		ACCESS_SYNDICATE_CARGO,
		ACCESS_SYNDICATE_KITCHEN,
		ACCESS_SYNDICATE_MEDICAL,
		ACCESS_SYNDICATE_BOTANY,
		ACCESS_SYNDICATE_ENGINE,
	)
	icon_state = "commander"
	item_state = "syndieofficer-id"

//MARK: Taipan ID-cards variants

/obj/item/card/id/syndicate/scientist
	icon_state = "syndiernd"
	item_state = "syndiernd-id"
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SYNDICATE_SCIENTIST, ACCESS_SYNDICATE_MEDICAL)
	rank = "Syndicate Scientist"

/obj/item/card/id/syndicate/cargo
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SYNDICATE_CARGO)
	icon_state = "syndiecargo"
	item_state = "syndiecargo-id"
	rank = "Syndicate Cargo Technician"

/obj/item/card/id/syndicate/kitchen
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SYNDICATE_KITCHEN, ACCESS_SYNDICATE_BOTANY)
	icon_state = "syndiechef"
	item_state = "syndiechef-id"
	rank = "Syndicate Chef"

/obj/item/card/id/syndicate/engineer
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SYNDICATE_ENGINE)
	icon_state = "syndieengineer"
	item_state = "syndieengineer-id"
	rank = "Syndicate Atmos Engineer"

/obj/item/card/id/syndicate/medic
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SYNDICATE_MEDICAL)
	icon_state = "syndiemedical"
	item_state = "syndiemedical-id"
	rank = "Syndicate Medic"

/obj/item/card/id/syndicate/botanist
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SYNDICATE_BOTANY)
	icon_state = "syndiebotany"
	item_state = "syndiebotany-id"
	rank = "Syndicate Botanist"

/obj/item/card/id/syndicate/comms_officer
	initial_access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_SYNDICATE,
		ACCESS_SYNDICATE_COMMS_OFFICER,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_SYNDICATE_SCIENTIST,
		ACCESS_SYNDICATE_CARGO,
		ACCESS_SYNDICATE_KITCHEN,
		ACCESS_SYNDICATE_ENGINE,
		ACCESS_SYNDICATE_MEDICAL,
		ACCESS_SYNDICATE_BOTANY,
		ACCESS_SYNDICATE_RESEARCH_DIRECTOR,
	)
	icon_state = "commander"
	item_state = "syndieofficer-id"
	rank = "Syndicate Comms Officer"

/obj/item/card/id/syndicate/research_director
	initial_access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_SYNDICATE,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_SYNDICATE_SCIENTIST,
		ACCESS_SYNDICATE_CARGO,
		ACCESS_SYNDICATE_KITCHEN,
		ACCESS_SYNDICATE_ENGINE,
		ACCESS_SYNDICATE_MEDICAL,
		ACCESS_SYNDICATE_BOTANY,
		ACCESS_SYNDICATE_RESEARCH_DIRECTOR,
	)
	icon_state = "syndierd"
	item_state = "syndierd-id"
	rank = "Syndicate Research Director"

/obj/item/card/id/syndicate/afterattack(obj/item/O, mob/user, proximity, params)
	if(!proximity || !istype(O))
		return
	if(O.GetID())
		var/obj/item/card/id/I = O.GetID()
		if(isliving(user) && user.mind)
			if(user.mind.special_role || anyone)
				to_chat(usr, span_notice("Микросканеры карты активируются, пока вы проводите ей по [I.declent_ru(DATIVE)], копируя доступы."))
				access |= I.access //Don't copy access if user isn't an antag -- to prevent metagaming

/obj/item/card/id/syndicate/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!registered_user)
		return
	. = TRUE
	switch(action)
		if("delete_info")
			var/response = tgui_alert(registered_user, "Вы уверены, что хотите удалить всю информацию, сохранённую на карте?", "Удаление информации", list("Нет", "Да"))
			if(response == "Да")
				name = initial(name)
				registered_name = initial(registered_name)
				icon_state = initial(icon_state)
				sex = initial(sex)
				age = initial(age)
				assignment = initial(assignment)
				associated_account_number = initial(associated_account_number)
				blood_type = initial(blood_type)
				dna_hash = initial(dna_hash)
				fingerprint_hash = initial(fingerprint_hash)
				photo = null
				registered_user = null
		if("save_slot")
			save_slot(params["slot"])
			to_chat(registered_user, span_notice("Вы успешно сохранили данные карты в слот [params["slot"]]."))
		if("load_slot")
			load_slot(params["slot"])
			update_label()
			registered_user.update_hud_set()
			to_chat(registered_user, span_notice("Вы успешно загрузили данные карты из слота [params["slot"]]."))
		if("clear_slot")
			clear_slot(params["slot"])
			to_chat(registered_user, span_notice("Вы успешно очистили слот [params["slot"]]."))
		if("clear_access")
			var/response = tgui_alert(registered_user, "Вы уверены, что хотите сбросить доступы карты?", "Сброс доступов", list("Нет", "Да"))
			if(response == "Да")
				access = initial_access.Copy() // Initial() doesn't work on lists
				to_chat(registered_user, span_notice("Доступы карты сброшены."))
		if("change_ai_tracking")
			untrackable = !untrackable
			to_chat(registered_user, span_notice("Теперь эта карта [untrackable ? "не отслеживается" : "отслеживается"] искусственным интеллектом."))
		if("change_name")
			var/new_name = reject_bad_name(tgui_input_text(registered_user, "Какое имя вы хотите использовать на этой карте?", "Имя карты агента", ishuman(registered_user) ? registered_user.real_name : registered_user.name), TRUE)
			if(!Adjacent(registered_user) || isnull(new_name))
				return
			registered_name = new_name
			update_label()
			to_chat(registered_user, span_notice("Имя изменено на [new_name]."))
		if("change_photo")
			if(!Adjacent(registered_user))
				return
			var/job_clothes = null
			if(assignment)
				job_clothes = assignment
			var/icon/newphoto = get_id_photo(registered_user, job_clothes)
			if(!newphoto)
				return
			photo = newphoto
			to_chat(registered_user, span_notice("Фотография изменена. Выберите другую работу и сделайте новое фото, если хотите выглядеть в другой одежде."))
		if("change_appearance")
			var/choice = tgui_input_list(registered_user, "Выберите внешний вид этой карты.", "Внешний вид карты агента", appearances)
			if(!Adjacent(registered_user))
				return
			if(!choice)
				return
			icon_state = choice
			switch(choice)
				if("silver")
					desc = "Серебряная карта, показывающая честь и достоинство."
				if("gold")
					desc = "Золотая карта, показывающая власть и могущество."
				if("clown")
					desc = "Даже вид этой карты вселяет в вас глубокий страх."
				if("mime")
					desc = "..."
				if("prisoner")
					desc = "Вы — номер, а не свободный человек."
				if("centcom")
					desc = "Карта, прибывшая прямо из Центрального Командования."
				else
					desc = "Карта, используемая для удостоверения личности и определения доступа на станции."
			to_chat(usr, span_notice("Внешний вид изменён на [choice]."))
		if("change_appearance_new")
			var/choice = params["new_appearance"]
			icon_state = choice
			to_chat(usr, span_notice("Внешний вид изменён на [choice]."))
		if("change_sex")
			var/new_sex = tgui_input_text(registered_user,"Какой пол вы бы хотели поставить на этой карте?", "Пол карты агента", ishuman(registered_user) ? ((registered_user.gender == MALE) ? "Мужской" : "Женский") : "Мужской")
			if(!Adjacent(registered_user) || isnull(new_sex))
				return
			sex = new_sex
			to_chat(registered_user, span_notice("Пол изменён на [new_sex]."))
		if("change_age")
			var/default = "21"
			if(ishuman(registered_user))
				var/mob/living/carbon/human/H = registered_user
				default = H.age
			var/new_age = tgui_input_number(registered_user, "Какой возраст вы бы хотели написать на этой карте?", "Возраст карты агента", default, 300, 17)
			if(!Adjacent(registered_user) || isnull(new_age))
				return
			age = new_age
			to_chat(registered_user, span_notice("Возраст изменён на [new_age]."))
		if("change_occupation")
			var/list/departments =list(
				"Civilian",
				"Engineering",
				"Medical",
				"Science",
				"Security",
				"Support",
				"Command",
				"Special",
				"Custom",
			)

			var/department = tgui_input_list(registered_user, "Какую работу вы бы хотели указать на карте?\nВыберите отдел или кастомное название.\nСмена профессии не даёт и не забирает уровни доступа.", "Профессия карты агента", departments)
			var/new_job = JOB_TITLE_CIVILIAN
			var/new_rank = JOB_TITLE_CIVILIAN

			if(department == "Custom")
				new_job = tgui_input_text(registered_user, "Введите кастомное название профессии:", "Профессия карты агента", "Assistant")
				var/department_icon = tgui_input_list(registered_user, "Какую работу вы хотите отобразить на этой карте (для Охранных интерфейсов)?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", departments)
				switch(department_icon)
					if("Engineering")
						new_rank = tgui_input_list(registered_user, "Какую работу вы хотите отобразить на этой карте (для Охранных интерфейсов)?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", GLOB.engineering_positions)
					if("Medical")
						new_rank = tgui_input_list(registered_user, "Какую работу вы хотите отобразить на этой карте (для Охранных интерфейсов)?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", GLOB.medical_positions)
					if("Science")
						new_rank = tgui_input_list(registered_user, "Какую работу вы хотите отобразить на этой карте (для Охранных интерфейсов)?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", GLOB.science_positions)
					if("Security")
						new_rank = tgui_input_list(registered_user, "Какую работу вы хотите отобразить на этой карте (для Охранных интерфейсов)?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", GLOB.security_positions)
					if("Support")
						new_rank = tgui_input_list(registered_user, "Какую работу вы хотите отобразить на этой карте (для Охранных интерфейсов)?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", GLOB.support_positions)
					if("Command")
						new_rank = tgui_input_list(registered_user, "Какую работу вы хотите отобразить на этой карте (для Охранных интерфейсов)?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", GLOB.command_positions)
					if("Special")
						new_rank = tgui_input_list(registered_user, "Какую работу вы хотите отобразить на этой карте (для Охранных интерфейсов)?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", (get_all_solgov_jobs() + get_all_soviet_jobs() + get_all_centcom_jobs() + get_all_special_jobs()))
					if("Custom")
						new_rank = null
			else if(department != "Civilian")
				switch(department)
					if("Engineering")
						new_job = tgui_input_list(registered_user, "Какую работу вы бы хотели указать на карте?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", GLOB.engineering_positions)
					if("Medical")
						new_job = tgui_input_list(registered_user, "Какую работу вы бы хотели указать на карте?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", GLOB.medical_positions)
					if("Science")
						new_job = tgui_input_list(registered_user, "Какую работу вы бы хотели указать на карте?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", GLOB.science_positions)
					if("Security")
						new_job = tgui_input_list(registered_user, "Какую работу вы бы хотели указать на карте?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", GLOB.security_positions)
					if("Support")
						new_job = tgui_input_list(registered_user, "Какую работу вы бы хотели указать на карте?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", GLOB.support_positions)
					if("Command")
						new_job = tgui_input_list(registered_user, "Какую работу вы бы хотели указать на карте?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", GLOB.command_positions)
					if("Special")
						new_job = tgui_input_list(registered_user, "Какую работу вы бы хотели отобразить на этой карте (для Охранных интерфейсов)?\nСмена профессии не даёт и не забирает уровни доступа.","Профессия карты агента", (get_all_solgov_jobs() + get_all_soviet_jobs() + get_all_centcom_jobs() + get_all_special_jobs()))
				new_rank = new_job

			if(!Adjacent(registered_user) || isnull(new_job))
				return
			assignment = new_job
			rank = new_rank
			to_chat(registered_user, span_notice("Профессия изменена на [new_job]."))
			update_label()
			registered_user.update_hud_set()
		if("change_money_account")
			var/new_account = tgui_input_number(registered_user, "Какой номер счёта вы хотите привязать к карте?", "Счёт карты агента", 12345, 9999999)
			if(!Adjacent(registered_user) || !isnull(new_account))
				return
			associated_account_number = new_account
			registered_user.med_hud_insurance_set_overlay()
			to_chat(registered_user, span_notice("Привязанный номер счёта изменён на [new_account]."))
		if("change_blood_type")
			var/default = "\[[NOT_SPECIFIED]\]"
			if(ishuman(registered_user))
				var/mob/living/carbon/human/H = registered_user
				if(H.dna)
					default = H.dna.blood_type

			var/new_blood_type = tgui_input_text(registered_user, "Какую группу крови вы хотите указать на карте?", "Группа крови карты агента", default)
			if(!Adjacent(registered_user) || !new_blood_type)
				return
			blood_type = new_blood_type
			to_chat(registered_user, span_notice("Группа крови изменена на [new_blood_type]."))
		if("change_dna_hash")
			var/default = "\[[NOT_SPECIFIED]\]"
			if(ishuman(registered_user))
				var/mob/living/carbon/human/H = registered_user
				if(H.dna)
					default = H.dna.unique_enzymes

			var/new_dna_hash = tgui_input_text(registered_user, "Какой ДНК-хеш вы хотите указать на карте?", "ДНК-хеш карты агента", default)
			if(!Adjacent(registered_user) || !new_dna_hash)
				return
			dna_hash = new_dna_hash
			to_chat(registered_user, span_notice("ДНК-хеш изменён на [new_dna_hash]."))
		if("change_fingerprints")
			var/default = "\[[NOT_SPECIFIED]\]"
			if(ishuman(registered_user))
				var/mob/living/carbon/human/H = registered_user
				if(H.dna)
					default = md5(H.dna.uni_identity)

			var/new_fingerprint_hash = tgui_input_text(registered_user, "Какой хеш отпечатков пальцев вы хотите указать на карте?", "Хеш отпечатков пальцев карты агента", default)
			if(!Adjacent(registered_user) || !new_fingerprint_hash)
				return
			fingerprint_hash = new_fingerprint_hash
			to_chat(registered_user, span_notice("Хеш отпечатков пальцев изменён на [new_fingerprint_hash]."))
	RebuildHTML()

/obj/item/card/id/syndicate/ui_data(mob/user)
	var/list/data = list()
	data["registered_name"] = registered_name
	data["sex"] = sex
	data["age"] = age
	data["assignment"] = assignment
	data["associated_account_number"] = associated_account_number
	data["blood_type"] = blood_type
	data["dna_hash"] = dna_hash
	data["fingerprint_hash"] = fingerprint_hash
	data["photo"] = photo
	data["ai_tracking"] = untrackable
	var/list/saved_info = list()
	for(var/I = 1 to length(save_slots))
		var/list/editing_list = save_slots[I]
		saved_info.Add(list(list("id" = I, "registered_name" = editing_list["registered_name"], "assignment" = editing_list["assignment"])))
	data["saved_info"] = saved_info
	return data

/obj/item/card/id/syndicate/ui_static_data(mob/user)
	var/list/data = list()
	data["id_icon"] = icon
	data["appearances"] = appearances
	return data

/obj/item/card/id/syndicate/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AgentCard", name)
		ui.open()

/obj/item/card/id/syndicate/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(!registered_user)
		registered_user = user
	if(!anyone)
		if(user != registered_user)
			return ..()
	switch(tgui_alert(user, "Хотите ли вы показать [declent_ru(ACCUSATIVE)] или изменить?", "Выбор", list("Показать", "Изменить")))
		if("Показать")
			return ..()
		if("Изменить")
			ui_interact(user)
			return

/obj/item/card/id/syndicate/proc/save_slot(number)
	number = text2num(number)
	var/list/editing_list = list()
	editing_list["registered_name"] = registered_name
	editing_list["sex"] = sex
	editing_list["age"] = age
	editing_list["rank"] = rank
	editing_list["assignment"] = assignment
	editing_list["associated_account_number"] = associated_account_number
	editing_list["blood_type"] = blood_type
	editing_list["dna_hash"] = dna_hash
	editing_list["fingerprint_hash"] = fingerprint_hash
	editing_list["photo"] = photo
	editing_list["ai_tracking"] = untrackable
	editing_list["icon_state"] = icon_state
	save_slots[number] = editing_list

/obj/item/card/id/syndicate/proc/load_slot(number)
	number = text2num(number)
	var/list/editing_list = save_slots[number]
	registered_name = editing_list["registered_name"]
	sex = editing_list["sex"]
	age = editing_list["age"]
	rank = editing_list["rank"]
	assignment = editing_list["assignment"]
	associated_account_number = editing_list["associated_account_number"]
	blood_type = editing_list["blood_type"]
	dna_hash = editing_list["dna_hash"]
	fingerprint_hash = editing_list["fingerprint_hash"]
	photo = editing_list["photo"]
	untrackable = editing_list["ai_tracking"]
	icon_state = editing_list["icon_state"]

/obj/item/card/id/syndicate/proc/clear_slot(number)
	number = text2num(number)
	save_slots[number] = list()

#undef NOT_SPECIFIED
