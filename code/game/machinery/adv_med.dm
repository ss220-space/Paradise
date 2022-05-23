/obj/machinery/bodyscanner
	name = "сканер тела"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "bodyscanner-open"
	density = TRUE
	dir = WEST
	anchored = TRUE
	idle_power_usage = 1250
	active_power_usage = 2500
	light_color = "#00FF00"
	var/mob/living/carbon/human/occupant
	var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/mindshield, /obj/item/implant/tracking, /obj/item/implant/health)

/obj/machinery/bodyscanner/Destroy()
	go_out()
	return ..()

/obj/machinery/bodyscanner/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/bodyscanner/process()
	for(var/mob/M as mob in src) // makes sure that simple mobs don't get stuck inside a sleeper when they resist out of occupant's grasp
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

/obj/machinery/bodyscanner/attackby(obj/item/I, mob/user)
	if(exchange_parts(user, I))
		return

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/TYPECAST_YOUR_SHIT = I
		if(panel_open)
			to_chat(user, "<span class='notice'>Сначала закройте панель технического обслуживания.</span>")
			return
		if(!ishuman(TYPECAST_YOUR_SHIT.affecting))
			return
		if(occupant)
			to_chat(user, "<span class='notice'>Сканер уже занят!</span>")
			return
		if(TYPECAST_YOUR_SHIT.affecting.has_buckled_mobs()) //mob attached to us
			to_chat(user, "<span class='warning'>[TYPECAST_YOUR_SHIT.affecting] не влез[pluralize_ru(TYPECAST_YOUR_SHIT.affecting.gender,"ет","ут")] в [src], потому что к [genderize_ru(TYPECAST_YOUR_SHIT.affecting.gender,"его","её","его","их")] голове прилип чёртов слайм.</span>")
			return
		var/mob/living/carbon/human/M = TYPECAST_YOUR_SHIT.affecting
		if(M.abiotic())
			to_chat(user, "<span class='notice'>Субъект не должен держать в руках посторонние предметы.</span>")
			return
		M.forceMove(src)
		occupant = M
		icon_state = "body_scanner_1"
		add_fingerprint(user)
		qdel(TYPECAST_YOUR_SHIT)
		SStgui.update_uis(src)
		return

	return ..()

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
		to_chat(user, "<span class='notice'>Сканер уже занят.</span>")
		return
	if(panel_open)
		to_chat(user, "<span class='notice'>Сначала закройте панель технического обслуживания.</span>")
		return
	if(dir == EAST)
		setDir(WEST)
	else
		setDir(EAST)

/obj/machinery/bodyscanner/MouseDrop_T(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return FALSE //not human
	if(user.incapacitated())
		return FALSE //user shouldn't be doing things
	if(H.anchored)
		return FALSE //mob is anchored???
	if(get_dist(user, src) > 1 || get_dist(user, H) > 1)
		return FALSE //doesn't use adjacent() to allow for non-cardinal (fuck my life)
	if(!ishuman(user) && !isrobot(user))
		return FALSE //not a borg or human
	if(panel_open)
		to_chat(user, "<span class='notice'>Сначала закройте панель технического обслуживания.</span>")
		return FALSE //panel open
	if(occupant)
		to_chat(user, "<span class='notice'>[src] уже занят.</span>")
		return FALSE //occupied
	if(H.buckled)
		return FALSE
	if(H.abiotic())
		to_chat(user, "<span class='notice'>Субъект не должен держать в руках посторонние предметы.</span>")
		return FALSE
	if(H.has_buckled_mobs()) //mob attached to us
		to_chat(user, "<span class='warning'>[H] не влез[pluralize_ru(H.gender,"ет","ут")] в [src], потому что к [genderize_ru(H.gender,"его","её","его","их")] голове прилип слайм.</span>")
		return

	if(H == user)
		visible_message("[user] залеза[pluralize_ru(user.gender,"ет","ют")] в [src].")
	else
		visible_message("[user] клад[pluralize_ru(user.gender,"ёт","ут")] [H] в сканер тела.")

	H.forceMove(src)
	occupant = H
	icon_state = "bodyscanner"
	add_fingerprint(user)
	SStgui.update_uis(src)

/obj/machinery/bodyscanner/attack_ai(user)
	return attack_hand(user)

/obj/machinery/bodyscanner/attack_ghost(user)
	ui_interact(user)

/obj/machinery/bodyscanner/attack_hand(user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(occupant == user)
		return // you cant reach that

	if(panel_open)
		to_chat(user, "<span class='notice'>Сначала закройте панель техобслуживания.</span>")
		return

	ui_interact(user)

/obj/machinery/bodyscanner/relaymove(mob/user)
	if(user.incapacitated())
		return FALSE //maybe they should be able to get out with cuffs, but whatever
	go_out()

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Извлечь пациента из сканера тела"

	if(usr.incapacitated())
		return
	go_out()
	add_fingerprint(usr)

/obj/machinery/bodyscanner/proc/go_out()
	if(!occupant)
		return
	occupant.forceMove(loc)
	occupant = null
	icon_state = "body_scanner_0"
	// eject trash the occupant dropped
	for(var/atom/movable/A in contents - component_parts)
		A.forceMove(loc)
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
		update_icon()

/obj/machinery/bodyscanner/narsie_act()
	go_out()
	new /obj/effect/gibspawner/generic(get_turf(loc)) //I REPLACE YOUR TECHNOLOGY WITH FLESH!
	qdel(src)

/obj/machinery/bodyscanner/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BodyScanner", "Сканер тела", 690, 600)
		ui.open()

/obj/machinery/bodyscanner/ui_data(mob/user)
	var/list/data = list()

	data["occupied"] = occupant ? TRUE : FALSE

	var/occupantData[0]
	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth

		var/found_disease = FALSE
		for(var/thing in occupant.viruses)
			var/datum/disease/D = thing
			if(D.visibility_flags & HIDDEN_SCANNER || D.visibility_flags & HIDDEN_PANDEMIC)
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
		occupantData["paralysis"] = occupant.paralysis
		occupantData["paralysisSeconds"] = round(occupant.paralysis * 0.25)
		occupantData["bodyTempC"] = occupant.bodytemperature-T0C
		occupantData["bodyTempF"] = (((occupant.bodytemperature-T0C) * 1.8) + 32)

		occupantData["hasBorer"] = occupant.has_brain_worms()

		var/bloodData[0]
		bloodData["hasBlood"] = FALSE
		if(!(NO_BLOOD in occupant.dna.species.species_traits))
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
		for(var/obj/item/organ/external/E in occupant.bodyparts)
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
			for(var/obj/I in E.embedded_objects)
				var/shrapnelSubData[0]
				shrapnelSubData["name"] = I.name

				shrapnelData.Add(list(shrapnelSubData))

			organData["shrapnel"] = shrapnelData
			organData["shrapnel_len"] = shrapnelData.len

			var/organStatus[0]
			if(E.status & ORGAN_BROKEN)
				organStatus["broken"] = E.broken_description
			if(E.is_robotic())
				organStatus["robotic"] = TRUE
			if(E.status & ORGAN_SPLINTED)
				organStatus["splinted"] = TRUE
			if(E.status & ORGAN_DEAD)
				organStatus["dead"] = TRUE

			organData["status"] = organStatus

			if(istype(E, /obj/item/organ/external/chest) && occupant.is_lung_ruptured())
				organData["lungRuptured"] = TRUE

			if(E.internal_bleeding)
				organData["internalBleeding"] = TRUE

			extOrganData.Add(list(organData))

		occupantData["extOrgan"] = extOrganData

		var/intOrganData[0]
		for(var/obj/item/organ/internal/I in occupant.internal_organs)
			var/organData[0]
			organData["name"] = I.name
			organData["desc"] = I.desc
			organData["germ_level"] = I.germ_level
			organData["damage"] = I.damage
			organData["maxHealth"] = I.max_damage
			organData["bruised"] = I.min_bruised_damage
			organData["broken"] = I.min_broken_damage
			organData["robotic"] = I.is_robotic()
			organData["dead"] = (I.status & ORGAN_DEAD)

			intOrganData.Add(list(organData))

		occupantData["intOrgan"] = intOrganData

		occupantData["blind"] = (BLINDNESS in occupant.mutations)
		occupantData["colourblind"] = (COLOURBLIND in occupant.mutations)
		occupantData["nearsighted"] = (NEARSIGHTED in occupant.mutations)

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
			visible_message("<span class='notice'>[src] жужжит и распечатывает лист бумаги.</span>")
			var/obj/item/paper/P = new /obj/item/paper(loc)
			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
			var/name = occupant ? occupant.name : "Неизвестный"
			P.info = "<CENTER><B>Сканирование тела — [name]</B></CENTER><BR>"
			P.info += "<b>Время сканирования:</b> [station_time_timestamp()]<br><br>"
			P.info += "[generate_printing_text()]"
			P.info += "<br><br><b>Заметки:</b><br>"
			P.name = "Сканирование тела — [name]"
		else
			return FALSE

/obj/machinery/bodyscanner/proc/generate_printing_text()
	var/dat = ""

	dat = "<font color='blue'><b>Параметры пациента:</b></font><br>" //Blah obvious
	if(istype(occupant)) //is there REALLY someone in there?
		var/t1
		switch(occupant.stat) // obvious, see what their status is
			if(0)
				t1 = "В сознании"
			if(1)
				t1 = "Без сознания"
			else
				t1 = "*ТРУП*"
		dat += "[occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"]\tЗдоровье, %: [occupant.health], ([t1])</font><br>"

		var/found_disease = FALSE
		for(var/thing in occupant.viruses)
			var/datum/disease/D = thing
			if(D.visibility_flags & HIDDEN_SCANNER || D.visibility_flags & HIDDEN_PANDEMIC)
				continue
			found_disease = TRUE
			break
		if(found_disease)
			dat += "<font color='red'>У пациента обнаружена болезнь.</font><BR>"

		var/extra_font = null
		extra_font = (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\t-Раны, %: [occupant.getBruteLoss()]</font><br>"

		extra_font = (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\t-Асфиксия, %: [occupant.getOxyLoss()]</font><br>"

		extra_font = (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\t-Интоксикация, %: [occupant.getToxLoss()]</font><br>"

		extra_font = (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\t-Ожоги, %: [occupant.getFireLoss()]</font><br>"

		extra_font = (occupant.radiation < 10 ?"<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tУровень радиации, %: [occupant.radiation]</font><br>"

		extra_font = (occupant.getCloneLoss() < 1 ?"<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tГенетические повреждения тканей, %: [occupant.getCloneLoss()]<br>"

		extra_font = (occupant.getBrainLoss() < 1 ?"<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tПовреждение мозга, %: [occupant.getBrainLoss()]<br>"

		var/prlz_left = round(occupant.paralysis / 4)
		var/prlz_left_pretext = "остал" + declension_ru(prlz_left,"а","о","о") + "сь"
		var/prlz_left_posttext = "секунд" + declension_ru(prlz_left,"а","ы","")
		dat += "Общий паралич, %: [occupant.paralysis] ([prlz_left_pretext] [prlz_left] [prlz_left_posttext]!)<br>"
		dat += "Температура тела: [occupant.bodytemperature-T0C] °C<br>"

		dat += "<hr>"

		if(occupant.has_brain_worms())
			dat += "Во фронтальной коре обнаружен крупный нарост. Потенциальная онкология. Рекомендуется хирургическое вмешательство.<br>"

		var/blood_percent =  round((occupant.blood_volume / BLOOD_VOLUME_NORMAL))
		blood_percent *= 100

		extra_font = (occupant.blood_volume > 448 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tУровень крови, %: [blood_percent] ([occupant.blood_volume] единиц[declension_ru(occupant.blood_volume,"а","ы","")])</font><br>"

		if(occupant.reagents)
			var/epinephrine_amount = occupant.reagents.get_reagent_amount("Epinephrine")
			var/ether_amount = occupant.reagents.get_reagent_amount("ether")
			var/styptic_powder_amount = occupant.reagents.get_reagent_amount("styptic_powder")
			var/salbutamol_powder_amount = occupant.reagents.get_reagent_amount("salbutamol")

			dat += "Эпинефрин: [epinephrine_amount] единиц[declension_ru(epinephrine_amount,"а","ы","")]<BR>"
			dat += "Эфир: [ether_amount] единиц[declension_ru(ether_amount,"а","ы","")]<BR>"

			extra_font = (occupant.reagents.get_reagent_amount("silver_sulfadiazine") < 30 ? "<font color='black'>" : "<font color='red'>")
			dat += "[extra_font]\tСульфадиазин серебра: [occupant.reagents.get_reagent_amount("silver_sulfadiazine")]</font><br>"

			extra_font = (occupant.reagents.get_reagent_amount("styptic_powder") < 30 ? "<font color='black'>" : "<font color='red'>")
			dat += "[extra_font]\tКровоостанавливающая пудра: [styptic_powder_amount] единиц[declension_ru(styptic_powder_amount,"а","ы","")]<BR>"

			extra_font = (occupant.reagents.get_reagent_amount("salbutamol") < 30 ? "<font color='black'>" : "<font color='red'>")
			dat += "[extra_font]\tСальбутамол: [salbutamol_powder_amount] единиц[declension_ru(salbutamol_powder_amount,"а","ы","")]<BR>"

		dat += "<hr><table border='1'>"
		dat += "<tr>"
		dat += "<th>Орган</th>"
		dat += "<th>Ожоги</th>"
		dat += "<th>Раны</th>"
		dat += "<th>Прочие повреждения</th>"
		dat += "</tr>"

		for(var/obj/item/organ/external/e in occupant.bodyparts)
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
			if(e.internal_bleeding)
				internal_bleeding = "<br>Внутреннее кровотечение"
			if(istype(e, /obj/item/organ/external/chest) && occupant.is_lung_ruptured())
				lung_ruptured = "Разрыв лёгкого:"
			if(e.status & ORGAN_SPLINTED)
				splint = "Наложена шина:"
			if(e.status & ORGAN_BROKEN)
				AN = "[e.broken_description]:"
			if(e.status & ORGAN_DEAD)
				dead = "МЁРТВ:"
			if(e.is_robotic())
				robot = "Робопротез:"
			if(e.open)
				open = "Open:"
			switch(e.germ_level)
				if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
					infected = "Лёгкое заражение:"
				if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
					infected = "Лёгкое заражение+:"
				if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
					infected = "Лёгкое заражение++:"
				if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
					infected = "Острая инфекция:"
				if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
					infected = "Острая инфекция+:"
				if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 399)
					infected = "Острая инфекция++:"
				if(INFECTION_LEVEL_TWO + 400 to INFINITY)
					infected = "Сепсис:"

			var/unknown_body = 0
			for(var/I in e.embedded_objects)
				unknown_body++

			if(unknown_body || e.hidden)
				imp += "Обнаружено неизвестное тело:"
			if(!AN && !open && !infected && !imp)
				AN = "Нет:"
			dat += "<td>[e.name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][internal_bleeding][lung_ruptured][dead]</td>"
			dat += "</tr>"
		for(var/obj/item/organ/internal/i in occupant.internal_organs)
			var/mech = i.desc
			var/infection = "Нет"
			var/dead = ""
			if(i.status & ORGAN_DEAD)
				dead = "МЁРТВ:"
			switch(i.germ_level)
				if(1 to INFECTION_LEVEL_ONE + 200)
					infection = "Лёгкое заражение:"
				if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
					infection = "Лёгкое заражение+:"
				if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
					infection = "Лёгкое заражение++:"
				if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
					infection = "Острая инфекция:"
				if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
					infection = "Острая инфекция+:"
				if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 399)
					infection = "Острая инфекция++:"
				if(INFECTION_LEVEL_TWO + 400 to INFINITY)
					infection = "Сепсис:"

			dat += "<tr>"
			dat += "<td>[i.name]</td><td>Нет</td><td>[i.damage]</td><td>[infection]:[mech][dead]</td><td></td>"
			dat += "</tr>"
		dat += "</table>"
		if(BLINDNESS in occupant.mutations)
			dat += "<font color='red'>Обнаружена катаракта.</font><BR>"
		if(COLOURBLIND in occupant.mutations)
			dat += "<font color='red'>Обнаружена аномалия фоторецепторов.</font><BR>"
		if(NEARSIGHTED in occupant.mutations)
			dat += "<font color='red'>Обнаружено смещение сетчатки.</font><BR>"
	else
		dat += "[src] пуст."

	return dat
