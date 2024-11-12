/obj/machinery/bodyscanner
	name = "body scanner"
	desc = "Сложное медицинское устройство, используется для сканирования физического состояния гуманоидов."
	ru_names = list(
		NOMINATIVE = "медицинский сканер",
		GENITIVE = "медицинского сканера",
		DATIVE = "медицинскому сканеру",
		ACCUSATIVE = "медицинский сканер",
		INSTRUMENTAL = "медицинским сканером",
		PREPOSITIONAL = "медицинском сканере"
	)
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "bodyscanner-open"
	density = TRUE
	dir = WEST
	anchored = TRUE
	idle_power_usage = 1250
	active_power_usage = 2500
	light_color = "#00FF00"
	var/mob/living/carbon/human/occupant
	var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/mindshield, /obj/item/implant/tracking, /obj/item/implant/health)
	var/isPrinting = FALSE
	var/obj/item/card/id/inserted_id = null

/obj/machinery/bodyscanner/Destroy()
	go_out()
	eject_id()
	return ..()

/obj/machinery/bodyscanner/power_change(forced = FALSE)
	if(!..())
		return
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light_on(FALSE)


/obj/machinery/bodyscanner/examine(mob/user)
	. = ..()
	if(occupant)
		if(occupant.is_dead())
			. += span_warning("Вы видите гуманоида внутри. Это [occupant.name]. [genderize_ru(occupant.gender, "Он мёртв", "Она мертва", "Оно мертво", "Они мертвы")]!")
		else
			. += span_notice("Вы видите гуманоида внутри. Это [occupant.name].")
	if(Adjacent(user))
		. += span_info("Используйте <b>Alt-ЛКМ</b>, чтобы вытащить пациента. Наведите курсор на пациента, зажмите <b>ЛКМ</b> и перетяните на [declent_ru(ACCUSATIVE)], чтобы поместить пациента внутрь.")


/obj/machinery/bodyscanner/update_icon_state()
	if(occupant)
		icon_state = "bodyscanner"
	else
		icon_state = "bodyscanner-open"


/obj/machinery/bodyscanner/process()
	for(var/mob/M in src) // makes sure that simple mobs don't get stuck inside a sleeper when they resist out of occupant's grasp
		if(M == occupant)
			continue
		else
			M.forceMove(loc)

/obj/machinery/bodyscanner/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/bodyscanner(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()


/obj/machinery/bodyscanner/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !ishuman(grabbed_thing))
		return .
	if(panel_open)
		balloon_alert(grabber, "сначала закройте техпанель")
		return .
	var/mob/living/carbon/human/target = grabbed_thing
	if(occupant)
		balloon_alert(grabber, "внутри кто-то есть!")
		return .
	if(target.abiotic())
		balloon_alert(grabber, "руки пациента заняты")
		return .
	if(target.has_buckled_mobs()) //mob attached to us
		to_chat(grabber, span_warning("[grabbed_thing] не помест[pluralize_ru(grabbed_thing, "ит", "ят")]ся в [declent_ru(ACCUSATIVE)], пока на [genderize_ru(grabbed_thing, "нём", "ней", "нём", "них")]  сидит слайм."))
		return .
	grabbed_thing.forceMove(src)
	occupant = grabbed_thing
	update_icon(UPDATE_ICON_STATE)
	add_fingerprint(grabber)
	SStgui.update_uis(src)


/obj/machinery/bodyscanner/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/bodyscanner/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "bodyscanner-o", "bodyscanner-open", I))
		return TRUE


/obj/machinery/bodyscanner/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(occupant)
		balloon_alert(user, "внутри кто-то есть!")
		return
	if(panel_open)
		balloon_alert(user, "сначала закройте техпанель")
		return

	setDir(turn(dir, -90))


/obj/machinery/bodyscanner/MouseDrop_T(mob/living/carbon/human/H, mob/user, params)
	if(!istype(H))
		return FALSE //not human
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE //user shouldn't be doing things
	if(H.anchored)
		return FALSE //mob is anchored???
	if(get_dist(user, src) > 1 || get_dist(user, H) > 1)
		return FALSE //doesn't use adjacent() to allow for non-cardinal (fuck my life)
	if(!ishuman(user) && !isrobot(user))
		return FALSE //not a borg or human
	if(panel_open)
		balloon_alert(user, "сначала закройте техпанель")
		return TRUE //panel open
	if(occupant)
		balloon_alert(user, "внутри кто-то есть!")
		return TRUE //occupied
	if(H.buckled)
		return FALSE
	if(H.abiotic())
		balloon_alert(user, "ваши руки заняты")
		return TRUE
	if(H.has_buckled_mobs()) //mob attached to us
		to_chat(user, span_warning("Вы не поместитесь в [declent_ru(ACCUSATIVE)], пока на вас сидит слайм."))
		return TRUE

	if(H == user)
		visible_message("[user] залезает в [declent_ru(ACCUSATIVE)].")
	else
		visible_message("[user] укладывает [H] в [declent_ru(ACCUSATIVE)].")

	add_fingerprint(user)
	H.forceMove(src)
	occupant = H
	update_icon(UPDATE_ICON_STATE)
	add_fingerprint(user)
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/bodyscanner/attack_ai(user)
	return attack_hand(user)

/obj/machinery/bodyscanner/attack_ghost(user)
	ui_interact(user)

/obj/machinery/bodyscanner/attack_hand(user)
	if(..())
		return TRUE

	if(stat & (NOPOWER|BROKEN))
		return

	if(occupant == user)
		return // you cant reach that

	if(panel_open)
		balloon_alert(user, "сначала закройте техпанель")
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/bodyscanner/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/card/id))
		if(inserted_id)
			balloon_alert(user, "слот ID карты занят")
		else if(user.drop_transfer_item_to_loc(I, src))
			inserted_id = I
			balloon_alert(user, "карта вставлена")

	. = ..()

/obj/machinery/bodyscanner/relaymove(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE //maybe they should be able to get out with cuffs, but whatever
	go_out()

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Освободить медицинский сканер"

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	go_out()
	add_fingerprint(usr)

/obj/machinery/bodyscanner/proc/go_out()
	if(!occupant)
		return
	occupant.forceMove(loc)
	occupant = null
	update_icon(UPDATE_ICON_STATE)
	// eject trash the occupant dropped
	for(var/atom/movable/A in contents - component_parts)
		A.forceMove(loc)
	SStgui.update_uis(src)

/obj/machinery/bodyscanner/proc/eject_id()
	if(!inserted_id)
		return
	inserted_id.forceMove(loc)
	inserted_id = null/
	SStgui.update_uis(src)

/obj/machinery/bodyscanner/force_eject_occupant(mob/target)
	go_out()

/obj/machinery/bodyscanner/ex_act(severity)
	if(occupant)
		occupant.ex_act(severity)
	..()

/obj/machinery/bodyscanner/handle_atom_del(atom/A)
	..()
	if(A == occupant)
		occupant = null
		updateUsrDialog()
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/bodyscanner/narsie_act()
	go_out()
	new /obj/effect/gibspawner/generic(get_turf(loc)) //I REPLACE YOUR TECHNOLOGY WITH FLESH!
	qdel(src)

/obj/machinery/bodyscanner/ratvar_act()
	go_out()
	new /obj/effect/decal/cleanable/blood/gibs/clock(get_turf(src))
	qdel(src)

/obj/machinery/bodyscanner/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BodyScanner", "Body Scanner")
		ui.open()

/obj/machinery/bodyscanner/ui_data(mob/user)
	var/list/data = list()

	data["occupied"] = occupant ? TRUE : FALSE
	data["has_id"] = inserted_id ? TRUE : FALSE

	var/occupantData[0]
	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth

		var/found_disease = FALSE
		for(var/thing in occupant.diseases)
			var/datum/disease/D = thing
			if(D.visibility_flags & HIDDEN_SCANNER)
				continue
			if(istype(D, /datum/disease/critical))
				continue
			found_disease = TRUE
			break
		occupantData["hasVirus"] = found_disease

		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()

		occupantData["radLoss"] = occupant.radiation
		occupantData["cloneLoss"] = occupant.getCloneLoss()
		occupantData["brainLoss"] = occupant.getBrainLoss()
		occupantData["paralysis"] = occupant.AmountParalyzed()
		occupantData["paralysisSeconds"] = round(occupant.AmountParalyzed() * 0.25)
		occupantData["bodyTempC"] = occupant.bodytemperature-T0C
		occupantData["bodyTempF"] = (((occupant.bodytemperature-T0C) * 1.8) + 32)

		occupantData["hasBorer"] = occupant.has_brain_worms()

		var/bloodData[0]
		bloodData["hasBlood"] = FALSE
		if(!HAS_TRAIT(occupant, TRAIT_NO_BLOOD))
			bloodData["hasBlood"] = TRUE
			bloodData["volume"] = occupant.blood_volume
			bloodData["percent"] = round(((occupant.blood_volume / BLOOD_VOLUME_NORMAL)*100))
			bloodData["pulse"] = occupant.get_pulse(GETPULSE_TOOL)
			bloodData["bloodLevel"] = occupant.blood_volume
			bloodData["bloodMax"] = occupant.max_blood
		occupantData["blood"] = bloodData

		var/implantData[0]
		for(var/obj/item/implant/I in occupant)
			if(I.implanted && is_type_in_list(I, known_implants))
				var/implantSubData[0]
				implantSubData["name"] = sanitize(I.name)
				implantData.Add(list(implantSubData))
		occupantData["implant"] = implantData
		occupantData["implant_len"] = implantData.len

		var/extOrganData[0]
		for(var/obj/item/organ/external/E as anything in occupant.bodyparts)
			var/organData[0]
			organData["name"] = E.name
			organData["open"] = E.open
			organData["germ_level"] = E.germ_level
			organData["bruteLoss"] = E.brute_dam
			organData["fireLoss"] = E.burn_dam
			organData["totalLoss"] = E.brute_dam + E.burn_dam
			organData["maxHealth"] = E.max_damage
			organData["bruised"] = E.min_bruised_damage
			organData["broken"] = E.min_broken_damage

			var/shrapnelData[0]
			for(var/obj/item/I in E.embedded_objects)
				var/shrapnelSubData[0]
				shrapnelSubData["name"] = I.name

				shrapnelData.Add(list(shrapnelSubData))

			organData["shrapnel"] = shrapnelData
			organData["shrapnel_len"] = shrapnelData.len

			var/organStatus[0]
			if(E.has_fracture())
				organStatus["broken"] = E.broken_description
			if(E.is_robotic())
				organStatus["robotic"] = TRUE
			if(E.is_splinted())
				organStatus["splinted"] = TRUE
			if(E.is_dead())
				organStatus["dead"] = TRUE

			organData["status"] = organStatus

			if(istype(E, /obj/item/organ/external/chest) && occupant.is_lung_ruptured())
				organData["lungRuptured"] = TRUE

			if(E.has_internal_bleeding())
				organData["internalBleeding"] = TRUE

			extOrganData.Add(list(organData))

		occupantData["extOrgan"] = extOrganData

		var/intOrganData[0]
		for(var/obj/item/organ/internal/organ as anything in occupant.internal_organs)
			var/organData[0]
			organData["name"] = organ.name
			organData["desc"] = organ.desc
			organData["germ_level"] = organ.germ_level
			organData["damage"] = organ.damage
			organData["maxHealth"] = organ.max_damage
			organData["bruised"] = organ.min_bruised_damage
			organData["broken"] = organ.min_broken_damage
			organData["robotic"] = organ.is_robotic()
			organData["dead"] = (organ.is_dead())

			intOrganData.Add(list(organData))

		occupantData["intOrgan"] = intOrganData

		occupantData["blind"] = HAS_TRAIT(occupant, TRAIT_BLIND)
		occupantData["colourblind"] = HAS_TRAIT(occupant, TRAIT_COLORBLIND)
		occupantData["nearsighted"] = HAS_TRAIT(occupant, TRAIT_NEARSIGHTED)

	data["occupant"] = occupantData
	return data

/obj/machinery/bodyscanner/ui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	. = TRUE
	switch(action)
		if("ejectify")
			eject()
		if("print_p")
			if(isPrinting)
				return
			isPrinting = TRUE
			if(GLOB.copier_items_printed >= GLOB.copier_max_items)
				visible_message(span_warning("Ничего не происходит. Устройство печати сломано?"))
				if(!GLOB.copier_items_printed_logged)
					message_admins("Photocopier cap of [GLOB.copier_max_items] papers reached, all photocopiers/printers are now disabled. This may be the cause of any lag.")
					GLOB.copier_items_printed_logged = TRUE
				sleep(3 SECONDS)
				isPrinting = FALSE
				return
			visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] дребезжит, после чего из окна печати выпадает лист бумаги."))
			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
			sleep(3 SECONDS)
			var/obj/item/paper/P = new /obj/item/paper(loc)
			var/name = occupant ? occupant.name : "Неизвестный"
			P.info = "<CENTER><B>Отчёт по сканированию пациента - [name]</B></CENTER><BR>"
			P.info += "<b>Время сканирования</b> [station_time_timestamp()]<br><br>"
			P.info += "[generate_printing_text()]"
			P.info += "<br><br><b>Заметки:</b><br>"
			P.name = "Отчёт по сканированию пациента - [name]"
			isPrinting = FALSE
		if("insurance")
			do_insurance_collection(usr, occupant, inserted_id ? inserted_id.associated_account_number : null)
		if("eject_id")
			eject_id()
		else
			return FALSE

/obj/machinery/bodyscanner/proc/generate_printing_text()
	var/dat = ""

	dat = "<font color='blue'><b>Состояние пациента:</b></font><br>" //Blah obvious
	if(istype(occupant)) //is there REALLY someone in there?
		var/t1
		switch(occupant.stat) // obvious, see what their status is
			if(0)
				t1 = "в сознании"
			if(1)
				t1 = "без сознания"
			else
				t1 = "*[genderize_ru(occupant.gender, "мёртв", "мертва", "мертво", "мертвы")]*"
		dat += "[occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"]\tПроцентная оценка состояния: [occupant.health]%, ([t1])</font><br>"

		var/found_disease = FALSE
		for(var/thing in occupant.diseases)
			var/datum/disease/D = thing
			if(D.visibility_flags & HIDDEN_SCANNER)
				continue
			found_disease = TRUE
			break
		if(found_disease)
			dat += "<font color='red'>У пациента выявлено заболевание</font><BR>"

		var/extra_font = null
		extra_font = (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\t-Травмы: [occupant.getBruteLoss()]</font><br>"

		extra_font = (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\t-Удушение: [occupant.getOxyLoss()]</font><br>"

		extra_font = (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\t-Токсины: [occupant.getToxLoss()]</font><br>"

		extra_font = (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\t-Ожоги: [occupant.getFireLoss()]</font><br>"

		extra_font = (occupant.radiation < 10 ?"<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tРадиация: [occupant.radiation]</font><br>"

		extra_font = (occupant.getCloneLoss() < 1 ?"<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tГенетическое повреждение: [occupant.getCloneLoss()]<br>"

		extra_font = (occupant.getBrainLoss() < 1 ?"<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tПовреждение мозга: [occupant.getBrainLoss()]<br>"

		dat += "Паралич тела: [occupant.AmountParalyzed()] ([round(occupant.AmountParalyzed() / 10)] секунд осталось!)<br>"
		dat += "Температура тела: [occupant.bodytemperature-T0C]&deg;C ([occupant.bodytemperature*1.8-459.67]&deg;F)<br>"

		dat += "<hr>"

		if(occupant.has_brain_worms())
			dat += "В лобной доле обнаружено крупное образование, возможно, злокачественное. Рекомендуется хирургическое удаление."

		var/blood_percent =  round((occupant.blood_volume / BLOOD_VOLUME_NORMAL))
		blood_percent *= 100

		extra_font = (occupant.blood_volume > 448 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tУровень крови: [blood_percent] ([occupant.blood_volume] u)</font><br>"

		if(occupant.reagents)
			dat += "Эпинефрин: [occupant.reagents.get_reagent_amount("Epinephrine")] u<BR>"
			dat += "Эфир: [occupant.reagents.get_reagent_amount("ether")] u<BR>"

			extra_font = (occupant.reagents.get_reagent_amount("silver_sulfadiazine") < 30 ? "<font color='black'>" : "<font color='red'>")
			dat += "[extra_font]\tСульфадиазин серебра: [occupant.reagents.get_reagent_amount("silver_sulfadiazine")] u</font><br>"

			extra_font = (occupant.reagents.get_reagent_amount("styptic_powder") < 30 ? "<font color='black'>" : "<font color='red'>")
			dat += "[extra_font]\tКровоостанавливающая пудра: [occupant.reagents.get_reagent_amount("styptic_powder")] u<BR>"

			extra_font = (occupant.reagents.get_reagent_amount("salbutamol") < 30 ? "<font color='black'>" : "<font color='red'>")
			dat += "[extra_font]\tСальбутамол: [occupant.reagents.get_reagent_amount("salbutamol")] u<BR>"

		dat += "<hr><table border='1'>"
		dat += "<tr>"
		dat += "<th>Орган</th>"
		dat += "<th>Ожоги</th>"
		dat += "<th>Травмы</th>"
		dat += "<th>Другие повреждения</th>"
		dat += "</tr>"

		for(var/obj/item/organ/external/e as anything in occupant.bodyparts)
			dat += "<tr>"
			var/AN = ""
			var/open = ""
			var/infected = ""
			var/dead = ""
			var/robot = ""
			var/imp = ""
			var/bled = ""
			var/splint = ""
			var/internal_bleeding = ""
			var/lung_ruptured = ""
			if(e.has_internal_bleeding())
				internal_bleeding = "<br>Внутреннее кровотечение"
			if(istype(e, /obj/item/organ/external/chest) && occupant.is_lung_ruptured())
				lung_ruptured = "Пробито лёгкое"
			if(e.is_splinted())
				splint = "Наложена шина"
			if(e.has_fracture())
				AN = "[e.broken_description]"
			if(e.is_dead())
				dead = "Мертво"
			if(e.is_robotic())
				robot = "Синтетическое"
			if(e.open)
				open = "Открыто"
			switch(e.germ_level)
				if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
					infected = "Лёгкая инфекция"
				if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
					infected = "Лёгкая инфекция+"
				if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
					infected = "Лёгкая инфекция++"
				if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
					infected = "Острая инфекция"
				if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
					infected = "Острая инфекция+"
				if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 399)
					infected = "Острая инфекция++"
				if(INFECTION_LEVEL_TWO + 400 to INFINITY)
					infected = "Сепсис"

			if(LAZYLEN(e.embedded_objects) || e.hidden)
				imp += "Обнаружено инородное тело"
			if(!AN && !open && !infected && !imp)
				AN = "Отсутствуют"
			dat += "<td>[e.name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][internal_bleeding][lung_ruptured][dead]</td>"
			dat += "</tr>"
		for(var/obj/item/organ/internal/organ as anything in occupant.internal_organs)
			var/mech = organ.desc
			var/infection = "Отсутствуют"
			var/dead = ""
			if(organ.is_dead())
				dead = "Мертво"
			switch(organ.germ_level)
				if(1 to INFECTION_LEVEL_ONE + 200)
					infection = "Лёгкая инфекция"
				if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
					infection = "Лёгкая инфекция+"
				if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
					infection = "Лёгкая инфекция++"
				if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
					infection = "Острая инфекция"
				if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
					infection = "Острая инфекция+"
				if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 399)
					infection = "Острая инфекция++"
				if(INFECTION_LEVEL_TWO + 400 to INFINITY)
					infection = "Сепсис"

			dat += "<tr>"
			dat += "<td>[organ.name]</td><td>Н/Д</td><td>[organ.damage]</td><td>[infection]:[mech][dead]</td><td></td>"
			dat += "</tr>"
		dat += "</table>"
		if(HAS_TRAIT(occupant, TRAIT_BLIND))
			dat += "<font color='red'>Обнаружена катаракта.</font><BR>"
		if(HAS_TRAIT(occupant, TRAIT_COLORBLIND))
			dat += "<font color='red'>Обнаружены нарушения в работе фоторецепторов.</font><BR>"
		if(HAS_TRAIT(occupant, TRAIT_NEARSIGHTED))
			dat += "<font color='red'>Обнаружено смещение сетчатки.</font><BR>"
	else
		dat += "[capitalize(declent_ru(NOMINATIVE))] пуст."

	return dat
