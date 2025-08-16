#define PRINT_TIMER 3 SECONDS

/obj/item/autopsy_scanner
	name = "autopsy scanner"
	desc = "Небольшое устройство, используемое для проведения аутопсии."
	icon = 'icons/obj/autopsy_scanner.dmi'
	icon_state = "autopsy_scanner"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "magnets=1;biotech=1"
	var/list/datum/autopsy_data_scanner/wdata
	var/list/chemtraces
	var/target_UID = null
	var/target_name = null	// target.name can change after scanning, so better save it here.
	var/timeofdeath = null
	var/target_rank = null
	STATIC_COOLDOWN_DECLARE(print_cooldown)

/obj/item/autopsy_scanner/get_ru_names()
	return list(
		NOMINATIVE = "сканер аутопсии",
		GENITIVE = "сканера аутопсии",
		DATIVE = "сканеру аутопсии",
		ACCUSATIVE = "сканер аутопсии",
		INSTRUMENTAL = "сканером аутопсии",
		PREPOSITIONAL = "сканере аутопсии"
	)

/obj/item/autopsy_scanner/Destroy()
	QDEL_LIST_ASSOC_VAL(wdata)
	return ..()

/datum/autopsy_data_scanner
	var/weapon = null // this is the DEFINITE weapon type that was used
	var/list/organs_scanned = list() // this maps a number of scanned organs to
									 // the wounds to those organs with this data's weapon type
	var/organ_names = ""

/datum/autopsy_data_scanner/Destroy()
	QDEL_LIST_ASSOC_VAL(organs_scanned)
	return ..()

/datum/autopsy_data
	var/weapon = null
	var/damage = 0
	var/hits = 0
	var/time_inflicted = 0

/datum/autopsy_data/proc/copy()
	var/datum/autopsy_data/weapon_data = new()
	weapon_data.weapon = weapon
	weapon_data.damage = damage
	weapon_data.hits = hits
	weapon_data.time_inflicted = time_inflicted
	return weapon_data

/obj/item/autopsy_scanner/proc/add_autopsy_data(obj/item/organ/check_organ)
	if(!length(check_organ.autopsy_data))
		return

	for(var/index in check_organ.autopsy_data)
		var/datum/autopsy_data/weapon_data = check_organ.autopsy_data[index]

		if(!LAZYACCESS(wdata, index))
			var/datum/autopsy_data_scanner/scanner_data = new
			scanner_data.weapon = weapon_data.weapon
			wdata[index] = scanner_data

		var/datum/autopsy_data_scanner/scanner_data = wdata[index]
		var/organ_name = check_organ.declent_ru(NOMINATIVE)

		if(!scanner_data.organs_scanned[organ_name])
			if(scanner_data.organ_names == "")
				scanner_data.organ_names = organ_name
			else
				scanner_data.organ_names += ", [organ_name]"

		qdel(scanner_data.organs_scanned[organ_name])
		scanner_data.organs_scanned[organ_name] = weapon_data.copy()

/obj/item/autopsy_scanner/proc/add_chemical_traces(obj/item/organ/check_organ)
	if(!length(check_organ.trace_chemicals))
		return

	for(var/chemID in check_organ.trace_chemicals)
		if(check_organ.trace_chemicals[chemID] <= 0)
			continue
		if(LAZYIN(chemtraces, chemID))
			continue
		LAZYADD(chemtraces, chemID)

/obj/item/autopsy_scanner/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += span_notice("Вы можете воспользоваться ручкой, чтобы быстро написать отчет.")

/obj/item/autopsy_scanner/proc/paper_work(mob/user)
	var/dead_name = tgui_input_text(user, "Укажите имя субъекта", default = target_name, title = "Отчёт патологоанатома", max_length = 60)
	var/dead_rank = tgui_input_text(user, "Укажите должность субъекта", default = target_rank, title = "Отчёт патологоанатома", max_length = 60)
	var/dead_tod = tgui_input_text(user, "Укажите время смерти", default = station_time_timestamp("hh:mm", timeofdeath), title = "Отчёт патологоанатома", max_length = 60)
	var/dead_cause = tgui_input_text(user, "Укажите причину смерти", title = "Отчёт патологоанатома", max_length = 60)
	var/dead_chems = tgui_input_text(user, "Укажите химические следы", multiline = TRUE, title = "Отчёт патологоанатома")
	var/dead_notes = tgui_input_text(user, "Укажите важные детали", multiline = TRUE, title = "Отчёт патологоанатома")

	COOLDOWN_START(src, print_cooldown, PRINT_TIMER)
	var/obj/item/paper/paper = new(user.loc)
	paper.name = "Отчёт патологоанатома – [dead_name]"
	paper.info = "<b><center>[station_name()] – Отчёт патологоанатома</b></center><br><br><b>Имя погибшего:</b> [dead_name]</br><br><b>Должность погибшего:</b> [dead_rank]<br><br><b>Время смерти:</b> [dead_tod]<br><br><b>Причина смерти:</b> [dead_cause]<br><br><b>Химические следы:</b> [dead_chems]<br><br><b>Дополнительные детали:</b> [dead_notes]<br><br><b>Подпись патологоанатома:</b> <span class=\"paper_field\">"
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
	user.put_in_hands(paper, ignore_anim = FALSE)

/obj/item/autopsy_scanner/attackby(obj/item/used, mob/user, params)
	if(!is_pen(used))
		return ..()

	if(!COOLDOWN_FINISHED(src, print_cooldown))
		user.balloon_alert(user, "идёт печать...")
		return ATTACK_CHAIN_PROCEED_SUCCESS

	add_fingerprint(user)
	paper_work(user)

	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/item/autopsy_scanner/attack_self(mob/user)
	if(..())
		return TRUE

	if(!COOLDOWN_FINISHED(src, print_cooldown))
		user.balloon_alert(user, "идёт печать...")
		return

	COOLDOWN_START(src, print_cooldown, PRINT_TIMER)
	var/scan_data = ""

	if(timeofdeath)
		scan_data += "<b>Время смерти:</b> [station_time_timestamp("hh:mm:ss", timeofdeath)]<br><br>"
	else
		scan_data += "<b>Время смерти:</b> Н/Д<br><br>"

	if(LAZYLEN(wdata))
		var/n = 1
		for(var/wdata_idx in wdata)
			var/datum/autopsy_data_scanner/scanner_data = wdata[wdata_idx]
			var/total_hits = 0
			var/total_score = 0
			var/age = 0

			for(var/wound_idx in scanner_data.organs_scanned)
				var/datum/autopsy_data/weapon_data = scanner_data.organs_scanned[wound_idx]
				total_hits += weapon_data.hits
				total_score += weapon_data.damage
				age = max(age, weapon_data.time_inflicted)

			var/damage_desc
			// total score happens to be the total damage
			switch(total_score)
				if(1 to 5)
					damage_desc = span_green("небольшой тяжести")
				if(5 to 15)
					damage_desc = span_green("средней тяжести")
				if(15 to 30)
					damage_desc = span_orange("тяжёлое")
				if(30 to 1000)
					damage_desc = span_red("критическое")
				else
					damage_desc = "Н/Д"

			scan_data += "<b>Оружие №[n]</b><br>"
			if(total_score > 0)
				scan_data += "Тяжесть: [damage_desc]<br>"
				scan_data += "Нанесено ударов: [total_hits]<br>"
			scan_data += "Приблизительное время нанесения ранения: [station_time_timestamp("hh:mm", age)]<br>"
			scan_data += "Поражённые части тела: [scanner_data.organ_names]<br>"
			scan_data += "Оружие: [scanner_data.weapon]<br>"
			scan_data += "<br>"
			n++

	if(LAZYLEN(chemtraces))
		scan_data += "<b>Химические следы: </b><br>"
		for(var/chemID in chemtraces)
			scan_data += chemID
			scan_data += "<br>"

	user.visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] дребезжит, после чего из окна печати выпадает лист бумаги."))
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
	flick("autopsy_scanner_anim", src)
	sleep(PRINT_TIMER)

	var/obj/item/paper/paper = new(drop_location())
	paper.name = "Отчёт об аутопсии - [target_name]"
	paper.info = "<tt>[scan_data]</tt>"
	paper.update_icon()
	user.put_in_hands(paper, ignore_anim = FALSE)

/obj/item/autopsy_scanner/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ishuman(target) || !on_operable_surface(target))
		return ATTACK_CHAIN_PROCEED

	. = ATTACK_CHAIN_PROCEED_SUCCESS

	if(target_UID != target.UID())
		target_UID = target.UID()
		target_name = target.name
		target_rank = target.get_assignment(if_no_id = "Неизвестный", if_no_job = null)
		LAZYCLEARLIST(wdata)
		LAZYCLEARLIST(chemtraces)
		timeofdeath = null
		to_chat(user, span_notice("Обнаружен новый пациент. Данные о предыдущем пациенте удалены."))

	timeofdeath = target.timeofdeath

	var/obj/item/organ/external/limb = target.get_organ(user.zone_selected)
	if(!limb)
		user.balloon_alert(user, "часть тела нельзя просканировать!")
		return NONE

	target.visible_message(span_notice("[user] сканирует [limb.declent_ru(ACCUSATIVE)] [target] на предмет ранений, используя [declent_ru(ACCUSATIVE)]."))

	add_autopsy_data(limb)
	add_chemical_traces(limb)

#undef PRINT_TIMER
