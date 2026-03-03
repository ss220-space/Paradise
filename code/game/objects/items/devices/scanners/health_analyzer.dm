/obj/item/healthanalyzer
	name = "health analyzer"
	desc = "Ручной сканер тела, способный определить жизненные показатели субъекта."
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	item_state = "healthanalyzer"
	belt_icon = "health_analyzer"
	flags = CONDUCT
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	materials = list(MAT_METAL=200)
	origin_tech = "magnets=1;biotech=1"
	custom_price = PAYCHECK_LOWER
	var/mode = 1
	var/advanced = FALSE
	var/theme

	var/scan_title
	var/scan_data

	var/reports_printed = 0
	var/reports_per_device = 20

	var/isPrinting = FALSE

	var/datum/money_account/connected_acc = null

	var/mob/scanned = null

/obj/item/healthanalyzer/get_ru_names()
	return list(
		NOMINATIVE = "анализатор здоровья",
		GENITIVE = "анализатора здоровья",
		DATIVE = "анализатору здоровья",
		ACCUSATIVE = "анализатор здоровья",
		INSTRUMENTAL = "анализатором здоровья",
		PREPOSITIONAL = "анализаторе здоровья",
	)

/obj/item/healthanalyzer/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	add_fingerprint(user)
	scan_title = "Сканирование: [target]"
	scan_data = medical_scan_action(user, target, src, mode, advanced)
	show_results(user)
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/item/healthanalyzer/attack_self(mob/user)
	if(!scan_data)
		to_chat(user, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] не содержит сохранённых данных."))
		return
	show_results(user)

/obj/item/healthanalyzer/proc/print_report_verb()
	set name = "Печать отчёта"
	set category = VERB_CATEGORY_OBJECT
	set src = usr

	var/mob/user = usr
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	print_report(user)

/obj/item/healthanalyzer/proc/print_report(mob/living/user)
	if(!scan_data)
		to_chat(user, "Нет данных для печати.")
		return
	isPrinting = TRUE
	if(reports_printed > reports_per_device || GLOB.copier_items_printed >= GLOB.copier_max_items)
		visible_message(span_warning("Ничего не происходит. Устройство печати сломано?"))
		if(!GLOB.copier_items_printed_logged)
			message_admins("Photocopier cap of [GLOB.copier_max_items] papers reached, all photocopiers/printers are now disabled. This may be the cause of any lag.")
			GLOB.copier_items_printed_logged = TRUE
		sleep(3 SECONDS)
		isPrinting = FALSE
		return

	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
	flick("health_anim", src)
	sleep(3 SECONDS)
	var/obj/item/paper/P = new(drop_location())

	P.name = scan_title
	P.header += "<center><b>[scan_title]</b></center><br>"
	P.header += "<b>Время сканирования:</b> [station_time_timestamp()]<br><br>"
	P.header += "<hr>"

	if(scan_data["status"] == 2)
		P.header += "Состояние: <font color='red'><b>Смерть</b></font><br>"
	else
		P.header += "Состояние: [scan_data["status"] > 1 ? "<font color='red'><b>Смерть</b></font>" : scan_data["health"] > 0 ? "[scan_data["health"]]%" : "<font color='red'><b>[scan_data["health"]]%</b></font>"]<br>"

	P.header += "Тип повреждений: <font color='#0080ff'>Удушье</font>/<font color='green'>Отравление</font>/<font color='#FF8000'>Терм.</font>/<font color='red'>Мех.</font><br>"
	P.header += "Уровень повреждений: <font color='#0080ff'>[scan_data["damageLevels"]["oxy"]]</font> - <font color='green'>[scan_data["damageLevels"]["tox"]]</font> - <font color='#FF8000'>[scan_data["damageLevels"]["burn"]]</font> - <font color='red'>[scan_data["damageLevels"]["brute"]]</font><br>"
	P.header += "Температура тела: [scan_data["bodyTemperatureC"]] &deg;C ([scan_data["bodyTemperatureF"]] &deg;F)<br>"
	P.header += "Пульс: <font color='[scan_data["pulse_status"] == PULSE_NORM ? "#0080ff" : "red"]'>[scan_data["pulse"]] уд/мин.</font><br>"

	if(scan_data["genes"])
		if(scan_data["genes"] < 40)
			P.header += "<font color='red'><b>Критическая генная нестабильность!</b></font><br>"
		else if(scan_data["genes"] < 70)
			P.header += "<font color='red'><b>Тяжёлая генная нестабильность.</b></font><br>"
		else if(scan_data["genes"] < 85)
			P.header += "<font color='red'>Незначительная генная нестабильность.</font><br>"
		else
			P.header += "Гены стабильны.<br>"

	if(scan_data["bloodData"])
		var/blood_percent = scan_data["bloodData"]["blood_percent"]
		var/blood_volume = scan_data["bloodData"]["blood_volume"]
		var/blood_type = scan_data["bloodData"]["blood_type"]
		var/blood_species = scan_data["bloodData"]["blood_species"]
		var/ru_blood_species = list(
			"Diona" = "Диона",
			"Drask" = "Драск",
			"Grey" = "Грей",
			"Human" = "Человек",
			"Tajaran" = "Таяран",
			"Vulpkanin" = "Вульпканин",
			"Skrell" = "Скрелл",
			"Nian" = "Ниан",
			"Unathi" = "Унатх",
			"Kidan" = "Кидан",
			"Vox" = "Вокс",
			"Wryn" = "Врин",
		)

		var/blood_species_text = ""
		if(ru_blood_species[blood_species])
			blood_species_text = ", кровь расы: [ru_blood_species[blood_species]]"

		if(blood_volume <= BLOOD_VOLUME_SAFE && blood_percent > BLOOD_VOLUME_OKAY)
			P.header += "Уровень крови: [span_red("НИЗКИЙ")] - [blood_percent] %, [blood_volume] u, тип: [blood_type][blood_species_text].<br>"
		else if(blood_volume <= BLOOD_VOLUME_OKAY)
			P.header += "Уровень крови: [span_red("<b>КРИТИЧЕСКИЙ</b>")] - [blood_percent] %, [blood_volume] u, тип: [blood_type][blood_species_text].<br>"
		else
			P.header += "Уровень крови: [blood_percent] %, [blood_volume] u, тип: [blood_type][blood_species_text]."

	if(scan_data["timeofdeath"])
		P.header += "Время смерти: [scan_data["timeofdeath"]]<br>"
		if(scan_data["timetodefibText"])
			P.header += span_red("&emsp;Субъект умер [scan_data["timetodefib"]] назад<br>")
			P.header += "&emsp;Дефибриляция возможна!</font><br>"
		else
			P.header += span_red("&emsp;Субъект умер [scan_data["timetodefib"]] назад<br>")

	if(scan_data["damageLocalization"])
		P.header += "<hr>"
		P.header += "Локализация повреждений, <font color='#FF8000'>Терм.</font>/<font color='red'>Мех.</font>:<br>"
		for(var/damage in scan_data["damageLocalization"])
			P.header += "&emsp;[span_notice(capitalize(damage["name"]))]: <font color='#FF8000'>[damage["burn"]]</font> - <font color='red'>[damage["brute"]]</font><br>"

	if(scan_data["bleedingList"])
		for(var/bleeding in scan_data["bleedingList"])
			P.header += span_red("Кровотечение в [bleeding].<br>")

	if(scan_data["fractureList"])
		for(var/fracture in scan_data["fractureList"])
			P.header += span_red("Обнаружен перелом в [fracture].<br>")

	if(scan_data["infectedList"])
		for(var/infection in scan_data["infectedList"])
			P.header += span_red("Заражение в [infection].<br>")

	if(scan_data["extraFacture"] == 1)
		P.header += span_red("Обнаружено перелом. Локализация невозможна.<br>")

	if(scan_data["extraBleeding"] == 1)
		P.header += span_red("Обнаружено внутреннее кровотечение. Локализация невозможна.<br>")

	if(scan_data["reagentList"])
		P.header += "Обнаружены реагенты:<br>"
		for(var/reagent in scan_data["reagentList"])
			P.header += "&emsp;[reagent["volume"]]u [reagent["name"]] [reagent["overdosed"] == "1" ? " - <b>ПЕРЕДОЗИРОВКА</b>" : "."]<br>"
	else
		P.header += "<br>Реагенты не обнаружены.<br>"

	if(scan_data["addictionList"])
		P.header += "<b>Обнаружены зависимости от реагентов:</b><br>"
		for(var/addiction in scan_data["addictionList"])
			P.header += span_red("&emsp;[addiction["name"]] Стадия: [addiction["addiction_stage"]]/5<br>")
	else
		P.header += "Зависимости от реагентов не обнаружены.<br>"

	P.header += "<hr>"

	if(scan_data["diseases"])
		for(var/disease in scan_data["diseases"])
			P.header += "<font color='red'><b>Внимание: [disease["form"]]</b></font><br>"
			P.header += "&emsp;Название: [disease["name"]]<br>"
			P.header += "&emsp;Тип: [disease["additional_info"]]<br>"
			P.header += "&emsp;Стадия: [disease["stage"]]/[disease["max_stages"]]<br>"
			P.header += "&emsp;Лечение: [disease["cure_text"]]<br>"

	if(scan_data["heartCondition"] == "CRIT")
		P.header += "<font color='#d82020'><b>Внимание: Критическое состояние</b></font><br>"
		P.header += "&emsp;Название: Остановка сердца<br>"
		P.header += "&emsp;Тип: Сердце пациента остановилось<br>"
		P.header += "&emsp;Стадия: 1/1<br>"
		P.header += "&emsp;Лечение: Электрический шок<br>"
	else if(scan_data["heartCondition"] == "NECROSIS")
		P.header += "<font color='#d82020'><b>Обнаружен некроз сердца.</b></font><br>"
	else if(scan_data["heartCondition"] == "LESS")
		P.header += "<font color='#d82020'><b>Сердце не обнаружено.</b></font><br>"

	if(scan_data["staminaStatus"] == 1)
		P.header += span_notice("Обнаружено переутомление.<br>")

	if(scan_data["cloneStatus"] > 0)
		P.header += "<font color='#d82020'>Обнаружено [scan_data["cloneStatus"] > 30 ? "серьёзное" : "незначительное"] клеточное повреждение.</font><br>"

	if(scan_data["brainWorms"])
		P.header += "<font color='#d82020'>Обнаружены отклонения в работе мозга.</font><br>"

	if(scan_data["brainDamage"] == "LESS")
		P.header += "<font color='#d82020'><b>Мозг не обнаружен.</b></font><br>"
	else if(scan_data["brainDamage"] >= 100)
		P.header += "<font color='#d82020'><b>Мозг мёртв.</b></font><br>"
	else if(scan_data["brainDamage"] >= 60)
		P.header += "<font color='#d82020'><b>Обнаружено серьёзное повреждение мозга.</b></font><br>"
	else if(scan_data["brainDamage"] >= 10)
		P.header += "<font color='#d82020'>Обнаружено значительное повреждение мозга.</font><br>"

	if(scan_data["implantDetect"])
		P.header += "Обнаружены кибернетические модификации:<br>"
		for(var/implant in scan_data["implantDetect"])
			P.header += "&emsp;[implant]<br>"

	P.header += "<hr>"
	P.header += "Тип страховки — [scan_data["insuranceType"]].<br>"
	P.header += "Требуемое количество очков страховки: [scan_data["reqInsurance"]].<br>"
	if(scan_data["insurance"])
		P.header += "Текущее количество очков страховки: [scan_data["insurance"]].<br>"

	P.info += "<br><br><b>Заметки:</b><br>"

	if(in_range(user, src))
		user.put_in_hands(P, ignore_anim = FALSE)
		user.visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] дребезжит, после чего из окна печати выпадает лист бумаги."))
	GLOB.copier_items_printed++
	reports_printed++
	isPrinting = FALSE

/obj/item/healthanalyzer/proc/show_results(mob/user)
	SStgui.update_uis(src)
	ui_interact(user)

/obj/item/healthanalyzer/examine(mob/user)
	. = ..()
	if(scan_data)
		if(in_range(user, src) || istype(user, /mob/dead/observer))
			show_results(user)
		else
			. += span_notice("Нужно подойти ближе, чтобы прочесть содержмое.")

/obj/item/healthanalyzer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Healthanalyzer")
		ui.open()

/obj/item/healthanalyzer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("clear")
			to_chat(usr, "Вы очистили буфер данных [declent_ru(ACCUSATIVE)].")
			scan_data = null
			scan_title = null
		if("localize")
			to_chat(usr, "Вы переключили локализацию повреждений [declent_ru(ACCUSATIVE)].")
			toggle_mode()
		if("print")
			if(!isPrinting)
				print_report(usr)
		if("insurance")
			do_insurance_collection(usr, scanned, connected_acc)
		else
			return TRUE

	SStgui.update_uis(src)
	playsound(loc, SFX_TERMINAL_TYPE, 25, TRUE)
	return TRUE

/obj/item/healthanalyzer/ui_data(mob/user)
	var/list/data = list()
	data["localize"] = mode
	data["advanced"] = advanced
	data["scan_title"] = scan_title
	data["theme"] = theme
	data["scan_data"] = scan_data

	return data

/obj/item/healthanalyzer/proc/medical_scan_action(mob/living/user, atom/target, obj/item/healthanalyzer/scanner, mode, advanced)
	if(!user.IsAdvancedToolUser())
		to_chat(user, span_warning("Вам не хватает ловкости, чтобы использовать [declent_ru(ACCUSATIVE)]!"))
		balloon_alert(user, "невозможно!")
		return

	if((HAS_TRAIT(user, TRAIT_CLUMSY) || user.getBrainLoss() >= 60) && prob(50))
		user.visible_message(
			span_warning("[user] анализиру[PLUR_ET_YUT(user)] жизненные показатели пола!"),
			span_notice("Вы по глупости проанализировали жизненные показатели пола!")
		)
		var/list/data = list()
		data["status"] = "FLOOR"
		return data

	if(!ishuman(target) || ismachineperson(target))
		var/list/data = list()
		data["status"] = "ERROR"
		return data

	var/mob/living/carbon/human/scan_subject = null
	if(ishuman(target))
		scan_subject = target
	else if(istype(target, /obj/structure/closet/body_bag))
		var/obj/structure/closet/body_bag/B = target
		if(!B.opened)
			var/list/scan_content = list()
			for(var/mob/living/L in B.contents)
				scan_content.Add(L)

			if(length(scan_content) == 1)
				for(var/mob/living/carbon/human/L in scan_content)
					scan_subject = L
			else if(length(scan_content) > 1)
				balloon_alert(user, "внутри слишком много субъектов!")
				return
			else
				balloon_alert(user, "внутри пусто!")
				return

	if(!scan_subject)
		return

	if(user == target)
		user.visible_message(
			span_notice("[user] сканиру[PLUR_ET_YUT(user)] себя с помощью [declent_ru(GENITIVE)]."),
			span_notice("Вы сканируете себя с помощью [declent_ru(GENITIVE)].")
		)
	else
		user.visible_message(
			span_notice("[user] сканиру[PLUR_ET_YUT(user)] [target] с помощью [declent_ru(GENITIVE)]."),
			span_notice("Вы сканируете [target] с помощью [declent_ru(GENITIVE)].")
		)
	var/mob/living/carbon/human/H = target
	var/list/data = medical_scan_results(H, mode, advanced)
	scanner.scanned = scan_subject
	return data

// Scan data to TGUI
/proc/medical_scan_results(mob/living/M, mode = 1, advanced = FALSE)
	var/mob/living/carbon/human/H = M
	var/list/data = list()
	var/DNR = !H.ghost_can_reenter()
	if(HAS_TRAIT(H, TRAIT_FAKEDEATH))
		data["status"] = 2
	else
		data["status"] = H.stat
	data["health"] = H.health
	data["pulse_status"] = H.pulse
	data["pulse"] = H.get_pulse(GETPULSE_TOOL)

	if(H.timeofdeath)
		data["timeofdeath"] = "[station_time_timestamp("hh:mm:ss", H.timeofdeath)]"
		var/tdelta = round(world.time - H.timeofdeath)
		if(tdelta < DEFIB_TIME_LIMIT && !DNR)
			data["timetodefib"] = "[DisplayTimeText(tdelta)]"
			data["timetodefibText"] = "Дефибриляция возможна!"
		else
			data["timetodefib"] = "[DisplayTimeText(tdelta)]"

	var/oxyDamage = "[H.getOxyLoss()]"
	if(HAS_TRAIT(H, TRAIT_FAKEDEATH))
		oxyDamage = "[max(rand(1,40), H.getOxyLoss(), (300 - (H.getToxLoss() + H.getFireLoss() + H.getBruteLoss())))]"
	data["damageLevels"] = list(
		oxy =  oxyDamage,
		tox = "[H.getToxLoss()]",
		burn = "[H.getFireLoss()]",
		brute = "[H.getBruteLoss()]",
	)

	data["bodyTemperatureC"] = "[H.bodytemperature-T0C]"
	data["bodyTemperatureF"] = "[H.bodytemperature*1.8-459.67]"
	data["genes"] = H.gene_stability
	data["DRN"] = DNR

	var/blood_id = H.get_blood_id()
	if(blood_id)
		if(H.bleed_rate)
			data["bleed"] = TRUE

		var/blood_percent =  round((H.blood_volume / BLOOD_VOLUME_NORMAL)*100)
		var/blood_type = H.dna.blood_type
		var/blood_species = H.dna.species.blood_species

		if(blood_id != "blood")
			var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
			if(R)
				blood_type = R.name
			else
				blood_type = blood_id

		data["bloodData"] = list(
			blood_percent = blood_percent,
			blood_volume = H.blood_volume,
			blood_type = "[blood_type]",
			blood_species = "[blood_species]"
		)

	var/list/damaged = H.get_damaged_organs(1,1)
	var/list/damageLocalization = list()
	if(length(damaged) > 0)
		for(var/obj/item/organ/external/org as anything in damaged)
			damageLocalization += list(list(
				name = "[org.name]",
				burn = "[org.burn_dam]",
				brute = "[org.brute_dam]"
			))
		data["damageLocalization"] = damageLocalization

	if(advanced)
		if(H.reagents)
			if(length(H.reagents.reagent_list))
				var/list/reagentList = list()
				for(var/datum/reagent/R in H.reagents.reagent_list)
					reagentList += list(list(
						volume = "[R.volume]",
						name = "[R.name]",
						overdosed = R.overdosed
					))
				data["reagentList"] = reagentList
			else
				data["reagentList"] = FALSE

			if(length(H.reagents.addiction_list))
				var/list/addictionList = list()
				for(var/datum/reagent/R in H.reagents.addiction_list)
					addictionList += list(list(
						name = "[R.name]",
						addiction_stage = "[R.addiction_stage]"
					))
				data["addictionList"] = addictionList
			else
				data["addictionList"] = FALSE

	var/list/diseases = list()
	for(var/thing in H.diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			diseases += list(list(
				form = "[D.form]",
				name = "[D.name]",
				additional_info = "[D.additional_info]",
				stage = "[D.stage]",
				max_stages = "[D.max_stages]",
				cure_text = "[D.cure_text]"
				)
			)
	data["diseases"] = diseases

	if(H.undergoing_cardiac_arrest())
		var/obj/item/organ/internal/heart/heart = H.get_int_organ(/obj/item/organ/internal/heart)
		if(heart && !heart.is_dead())
			data["heartCondition"] = "CRIT"
		else if(heart && heart.is_dead())
			data["heartCondition"] = "NECROSIS"
		else if(!heart)
			data["heartCondition"] = "LESS"

	if(H.getStaminaLoss())
		data["staminaStatus"] = TRUE

	if(H.getCloneLoss())
		data["cloneStatus"] = H.getCloneLoss()

	if(H.borer?.controlling)
		data["brainWorms"] = TRUE

	if(H.get_int_organ(/obj/item/organ/internal/brain))
		data["brainDamage"] = H.getBrainLoss()
	else
		data["brainDamage"] = "LESS"

	var/list/fractureList = list()
	var/list/infectedList = list()
	var/list/bleedingList = list()
	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/bodypart = H.bodyparts_by_name[name]
		if(!bodypart)
			continue
		var/limb = bodypart.declent_ru(PREPOSITIONAL)
		if(bodypart.has_fracture())
			var/list/check_list = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			if((bodypart.limb_zone in check_list) && !bodypart.is_splinted())
				fractureList += "[limb]"
		if(bodypart.has_infected_wound())
			infectedList += "[limb]"
		if(bodypart.bleeding_amount > 0)
			var/bleeding = ""
			if(bodypart.has_arterial_bleeding())
				bleeding += "Артериальное кровотечение"
			else if(bodypart.has_heavy_bleeding())
				bleeding += "Обильное кровотечение"
			else
				bleeding += "Кровотечение"
			bleeding += "  в [limb]"
			if(bodypart.bleeding_amount <= bodypart.bleedsuppress)
				bleeding += " – остановлено"

			bleedingList += bleeding

	data["fractureList"] = fractureList
	data["infectedList"] = infectedList
	data["bleedingList"] = bleedingList

	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/bodypart = H.bodyparts_by_name[name]
		if(!bodypart)
			continue
		if(bodypart.has_fracture())
			data["extraFacture"] = TRUE
			break
	for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
		if(bodypart.has_internal_bleeding())
			data["extraBleeding"] = TRUE
			break

	var/datum/money_account/acc = get_insurance_account(H)
	if(acc)
		data["insuranceType"] = "[acc.insurance_type]"
	else
		data["insuranceType"] = "Аккаунт не обнаружен."
	data["reqInsurance"] = "[get_req_insurance(H)]"
	if(acc)
		data["insurance"] = "[acc.insurance]"

	var/list/implant_detect = list()
	for(var/obj/item/organ/internal/cyberimp/cybernetics in H.internal_organs)
		if(cybernetics.is_robotic())
			implant_detect += "[cybernetics.name]"
	if(length(implant_detect))
		data["implantDetect"] = implant_detect

	return data

// This is the output to the chat
/proc/healthscan(mob/user, mob/living/M, mode = 1, advanced = FALSE)
	var/list/scan_data = list()
	if(!ishuman(M) || ismachineperson(M))
		//these sensors are designed for organic life
		scan_data += "Состояние: [span_danger("ОШИБКА")]"
		scan_data += "Тип повреждений: <font color='#0080ff'>Удушье</font>/<font color='green'>Отравление</font>/<font color='#FF8000'>Терм.</font>/<font color='red'>Мех.</font>"
		scan_data += "Уровень повреждений: <font color='#0080ff'>?</font> - <font color='green'>?</font> - <font color='#FF8000'>?</font> - <font color='red'>?</font>"
		scan_data += "Температура тела: [M.bodytemperature-T0C] &deg;C ([M.bodytemperature*1.8-459.67] &deg;F)"
		scan_data += "Уровень крови: --- %, --- u, тип: ---"
		scan_data += "Пульс: <font color='#0080ff'>--- bpm.</font>"
		scan_data += "Гены не обнаружены."
		to_chat(user, chat_box_healthscan("[jointext(scan_data, "<br>")]"))
		return

	var/mob/living/carbon/human/H = M
	var/fake_oxy = max(rand(1,40), H.getOxyLoss(), (300 - (H.getToxLoss() + H.getFireLoss() + H.getBruteLoss())))
	var/OX = H.getOxyLoss() > 50	?	"<b>[H.getOxyLoss()]</b>"		: H.getOxyLoss()
	var/TX = H.getToxLoss() > 50	?	"<b>[H.getToxLoss()]</b>"		: H.getToxLoss()
	var/BU = H.getFireLoss() > 50	?	"<b>[H.getFireLoss()]</b>"		: H.getFireLoss()
	var/BR = H.getBruteLoss() > 50	?	"<b>[H.getBruteLoss()]</b>"	: H.getBruteLoss()
	var/DNR = !H.ghost_can_reenter()
	if(H.stat == DEAD)
		if(DNR)
			scan_data += "Состояние: [span_danger("Смерть<b>\[НР\]</b>")]"
		else
			scan_data += "Состояние: [span_danger("Смерть")]"
	else //Если живой или отключка
		if(HAS_TRAIT(H, TRAIT_FAKEDEATH))
			OX = fake_oxy > 50			?	"<b>[fake_oxy]</b>"			: fake_oxy
			scan_data += "Состояние: [span_danger("Смерть")]"
		else
			scan_data += "Состояние: [H.stat > 1 ? span_danger("Смерть") : (H.health > 0 ? "[H.health]%" : span_danger("[H.health]%"))]"
	scan_data += "Тип повреждений: <font color='#0080ff'>Удушье</font>/<font color='green'>Отравление</font>/<font color='#FF8000'>Терм.</font>/<font color='red'>Мех.</font>"
	scan_data += "Уровень повреждений: <font color='#0080ff'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FF8000'>[BU]</font> - <font color='red'>[BR]</font>"
	scan_data += "Температура тела: [H.bodytemperature-T0C] &deg;C ([H.bodytemperature*1.8-459.67] &deg;F)"
	if(H.timeofdeath && (H.stat == DEAD || HAS_TRAIT(H, TRAIT_FAKEDEATH)))
		scan_data += "Время смерти: [station_time_timestamp("hh:mm:ss", H.timeofdeath)]"
		var/tdelta = round(world.time - H.timeofdeath)
		if(tdelta < DEFIB_TIME_LIMIT && !DNR)
			scan_data += span_danger("&emsp;Субъект умер [DisplayTimeText(tdelta)] назад")
			scan_data += span_danger("&emsp;Дефибриляция возможна!")
		else
			scan_data += span_danger("&emsp;Субъект умер [DisplayTimeText(tdelta)] назад")
	if(mode == 1)
		var/list/damaged = H.get_damaged_organs(1,1)
		scan_data += "Локализация повреждений, <font color='#FF8000'>Терм.</font>/<font color='red'>Мех.</font>:"
		if(length(damaged) > 0)
			for(var/obj/item/organ/external/org as anything in damaged)
				scan_data += "&emsp;[span_notice(capitalize(org.name))]: [(org.burn_dam > 0) ? "<font color='#FF8000'>[org.burn_dam]</font>" : "<font color='#FF8000'>0</font>"] - [(org.brute_dam > 0) ? "<font color='red'>[org.brute_dam]</font>" : "<font color='red'>0</font>"]"
	if(advanced)
		if(H.reagents)
			if(length(H.reagents.reagent_list))
				scan_data += "Обнаружены реагенты:"
				for(var/datum/reagent/R in H.reagents.reagent_list)
					scan_data += "&emsp;[R.volume]u [R.name][R.overdosed ? " - [span_boldannounceic("ПЕРЕДОЗИРОВКА")]" : "."]"
			else
				scan_data += "Реагенты не обнаружены."
			if(length(H.reagents.addiction_list))
				scan_data += span_danger("Обнаружены зависимости от реагентов:")
				for(var/datum/reagent/R in H.reagents.addiction_list)
					scan_data += span_danger("&emsp;[R.name] Стадия: [R.addiction_stage]/5")
			else
				scan_data += "Зависимости от реагентов не обнаружены."
	for(var/thing in H.diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			scan_data += span_warning("<b>Внимание: обнаружен [D.form]</b>")
			scan_data += "&emsp;Название: [D.name]"
			scan_data += "&emsp;Тип: [D.additional_info]"
			scan_data += "&emsp;Стадия: [D.stage]/[D.max_stages]"
			scan_data += "&emsp;Лечение: [D.cure_text]"
	if(H.undergoing_cardiac_arrest())
		var/obj/item/organ/internal/heart/heart = H.get_int_organ(/obj/item/organ/internal/heart)
		if(heart && !heart.is_dead())
			scan_data += span_warning("<b>Внимание: Критическое состояние</b>")
			scan_data += "&emsp;Название: Остановка сердца"
			scan_data += "&emsp;Тип: Сердце пациента остановилось"
			scan_data += "&emsp;Стадия: 1/1"
			scan_data += "&emsp;Лечение: Электрический шок"
		else if(heart && heart.is_dead())
			scan_data += span_alert("<b>Обнаружен некроз сердца.</b>")
		else if(!heart)
			scan_data += span_alert("<b>Сердце не обнаружено.</b>")

	if(H.getStaminaLoss())
		scan_data += span_notice("Обнаружено переутомление.")
	if(H.getCloneLoss())
		scan_data += span_warning("Обнаружено [H.getCloneLoss() > 30 ? "серьёзное" : "незначительное"] клеточное повреждение.")
	if(H.borer?.controlling)
		scan_data += span_warning("Обнаружены отклонения в работе мозга.")

	if(H.get_int_organ(/obj/item/organ/internal/brain))
		if(H.getBrainLoss() >= 100)
			scan_data += span_warning("Мозг мёртв.")
		else if(H.getBrainLoss() >= 60)
			scan_data += span_warning("Обнаружено серьёзное повреждение мозга.")
		else if(H.getBrainLoss() >= 10)
			scan_data += span_warning("Обнаружено значительное повреждение мозга.")
	else
		scan_data += span_warning(">Мозг не обнаружен.")

	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/bodypart = H.bodyparts_by_name[name]
		if(!bodypart)
			continue
		var/limb = bodypart.name
		if(bodypart.has_fracture())
			var/list/check_list = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			if((bodypart.limb_zone in check_list) && !bodypart.is_splinted())
				scan_data += span_warning("Обнаружен перелом в [limb].")
		if(bodypart.has_infected_wound())
			scan_data += span_warning("Заражение в [limb].")
	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/bodypart = H.bodyparts_by_name[name]
		if(!bodypart)
			continue
		if(bodypart.bleeding_amount > 0)
			var/bleed_stat = ""
			if(bodypart.has_arterial_bleeding())
				bleed_stat += "артериальное "
			else if(bodypart.has_heavy_bleeding())
				bleed_stat += "обильное "

			if(bodypart.bleeding_amount <= bodypart.bleedsuppress)
				bleed_stat += "остановленное "

			scan_data += span_warning("Обнаружено [bleed_stat]кровотечение в [bodypart.declent_ru(PREPOSITIONAL)].")
	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/bodypart = H.bodyparts_by_name[name]
		if(!bodypart)
			continue
		if(bodypart.has_fracture())
			scan_data += span_warning("Обнаружены переломы. Локализация невозможна.")
			break
	for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
		if(bodypart.has_internal_bleeding())
			scan_data += span_warning("Обнаружено внутреннее кровотечение. Локализация невозможна.")
			break
	var/blood_id = H.get_blood_id()
	if(blood_id)
		if(H.bleed_rate)
			scan_data += span_danger("Обнаружено кровотечение.")
		var/blood_percent =  round((H.blood_volume / BLOOD_VOLUME_NORMAL)*100)
		var/blood_type = H.dna.blood_type
		var/blood_species = H.dna.species.blood_species
		var/ru_blood_species = list(
			"Diona" = "Диона",
			"Drask" = "Драск",
			"Grey" = "Грей",
			"Human" = "Человек",
			"Tajaran" = "Таяран",
			"Vulpkanin" = "Вульпканин",
			"Skrell" = "Скрелл",
			"Nian" = "Ниан",
			"Unathi" = "Унатх",
			"Kidan" = "Кидан",
			"Vox" = "Вокс",
			"Wryn" = "Врин",
		)
		var/blood_species_text = ""
		if(ru_blood_species[blood_species])
			blood_species_text = ", кровь расы: [ru_blood_species[blood_species]]"

		if(blood_id != "blood")//special blood substance
			var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
			if(R)
				blood_type = R.name
			else
				blood_type = blood_id

		if(H.blood_volume <= BLOOD_VOLUME_SAFE && H.blood_volume > BLOOD_VOLUME_OKAY)
			scan_data += "Уровень крови: [span_danger("НИЗКИЙ")] - [blood_percent] %, [H.blood_volume] u, тип: [blood_type][blood_species_text]."
		else if(H.blood_volume <= BLOOD_VOLUME_OKAY)
			scan_data += "Уровень крови: [span_danger("<b>КРИТИЧЕСКИЙ</b>")] - [blood_percent] %, [H.blood_volume] u, тип: [blood_type][blood_species_text]."
		else
			scan_data += "Уровень крови: [blood_percent] %, [H.blood_volume] u, тип: [blood_type][blood_species_text]."

	scan_data += "Пульс: <font color='[H.pulse == PULSE_NORM ? "#0080ff" : "red"]'>[H.get_pulse(GETPULSE_TOOL)] уд/мин.</font>"
	var/list/implant_detect = list()
	for(var/obj/item/organ/internal/cyberimp/cybernetics in H.internal_organs)
		if(cybernetics.is_robotic())
			implant_detect += "&emsp;[cybernetics.name]"
	if(length(implant_detect))
		scan_data += "Обнаружены кибернетические модификации:"
		scan_data += implant_detect
	if(H.gene_stability < 40)
		scan_data += span_userdanger("Критическая генная нестабильность.")
	else if(H.gene_stability < 70)
		scan_data += span_danger("Тяжёлая генная нестабильность.")
	else if(H.gene_stability < 85)
		scan_data += span_warning("Незначительная генная нестабильность.")
	else
		scan_data += "Гены стабильны."

	var/datum/money_account/acc = get_insurance_account(H)
	if(acc)
		scan_data += "Тип страховки — [acc.insurance_type]."
	else
		scan_data += "Аккаунт не обнаружен."
	scan_data += "Требуемое количество очков страховки: [get_req_insurance(H)]."
	if(acc)
		scan_data += "Текущее количество очков страховки: [acc.insurance]."
	to_chat(user, chat_box_healthscan("[jointext(scan_data, "<br>")]"))

/obj/item/healthanalyzer/verb/toggle_mode()
	set name = "Вкл/Выкл локализацию"
	set category = VERB_CATEGORY_OBJECT

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	mode = !mode
	switch(mode)
		if(1)
			to_chat(usr, "Локализация повреждений включена.")
		if(0)
			to_chat(usr, "Локализация повреждений выключена.")

/obj/item/healthanalyzer/update_overlays()
	. = ..()
	if(advanced)
		. += "advanced"

/obj/item/healthanalyzer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/healthupgrade))
		add_fingerprint(user)
		if(advanced)
			balloon_alert(user, "уже установлено!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		balloon_alert(user, "модуль установлен")
		playsound(loc, I.usesound, 50, TRUE)
		advanced = TRUE
		update_icon(UPDATE_OVERLAYS)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/card/id))
		add_fingerprint(user)
		if(!advanced)
			to_chat(user, span_warning("Для привязки счёта требуется наличие продвинутого модуля сканирования."))
			return ATTACK_CHAIN_PROCEED

		var/obj/item/card/id/id = I

		if(!id.associated_account_number)
			to_chat(user, span_warning("Привязанный аккаунт не обнаружен."))
			return ATTACK_CHAIN_PROCEED

		connected_acc = id.associated_account_number
		to_chat(user, span_notice("Аккаунт привязан."))
		playsound(loc, I.usesound, 50, TRUE)
		return ATTACK_CHAIN_PROCEED

	return ..()

/obj/item/healthanalyzer/advanced
	advanced = TRUE

/obj/item/healthanalyzer/advanced/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/healthupgrade
	name = "health analyzer upgrade"
	desc = "Модуль, устанавливаемый на анализатор здоровья для расширения его функционала."
	icon = 'icons/obj/device.dmi'
	icon_state = "healthupgrade"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "magnets=2;biotech=2"
	usesound = 'sound/items/deconstruct.ogg'
	custom_price = PAYCHECK_LOWER / 1.5

/obj/item/healthupgrade/get_ru_names()
	return list(
		NOMINATIVE = "модуль улучшения анализатора здоровья",
		GENITIVE = "модуля улучшения анализатора здоровья",
		DATIVE = "модулю улучшения анализатора здоровья",
		ACCUSATIVE = "модуль улучшения анализатора здоровья",
		INSTRUMENTAL = "модулем улучшения анализатора здоровья",
		PREPOSITIONAL = "модуле улучшения анализатора здоровья",
	)

/obj/item/healthanalyzer/gem_analyzer
	name = "eye of health"
	desc = "Необычный самоцвет в форме сердца. Позволяет пользователю ощущать раны и болезни других существ на метафизическом уровне. Магия, не иначе."
	icon_state = "gem_analyzer"
	item_state = "gem_analyzer"
	origin_tech = null

/obj/item/healthanalyzer/gem_analyzer/get_ru_names()
	return list(
		NOMINATIVE = "глаз здоровья",
		GENITIVE = "глаза здоровья",
		DATIVE = "глазу здоровья",
		ACCUSATIVE = "глаз здоровья",
		INSTRUMENTAL = "глазом здоровья",
		PREPOSITIONAL = "глазе здоровья",
	)

/obj/item/healthanalyzer/gem_analyzer/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_BLOCKED_ALL
