#define MENU_MAIN 1
#define MENU_RECORDS 2

/obj/machinery/computer/cloning
	name = "biomass pod console"
	desc = "Консоль для управления капсулой клонирования."
	ru_names = list(
		NOMINATIVE = "консоль капсулы клонирования",
		GENITIVE = "консоли капсулы клонирования",
		DATIVE = "консоли капсулы клонирования",
		ACCUSATIVE = "консоль капсулы клонирования",
		INSTRUMENTAL = "консолью капсулы клонирования",
		PREPOSITIONAL = "консоли капсулы клонирования"
	)
	icon = 'icons/obj/machines/computer.dmi'
	icon_keyboard = "med_key"
	icon_screen = "dna"
	circuit = /obj/item/circuitboard/cloning
	req_access = list(ACCESS_HEADS) //Only used for record deletion right now.
	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/list/pods = null //Linked cloning pods.
	var/list/temp = null
	var/list/scantemp = null
	var/menu = MENU_MAIN //Which menu screen to display
	var/list/records = null
	var/datum/dna2/record/active_record = null
	var/obj/item/disk/data/diskette = null //Mostly so the geneticist can steal everything.
	var/loading = 0 // Nice loading text
	var/autoprocess = 0
	var/obj/machinery/clonepod/selected_pod
	// 0: Standard body scan
	// 1: The "Best" scan available
	var/scan_mode = 1

	light_color = LIGHT_COLOR_DARKBLUE

/obj/machinery/computer/cloning/Initialize()
	. = ..()
	pods = list()
	records = list()
	set_scan_temp(emagged ? "Уничтожитель готов." : "Сканер готов.", "good")
	updatemodules()

/obj/machinery/computer/cloning/Destroy()
	releasecloner()
	return ..()

/obj/machinery/computer/cloning/process()
	if(!scanner || !pods.len || !autoprocess || stat & NOPOWER)
		return

	if(scanner.occupant && can_autoprocess())
		scan_mob(scanner.occupant)

	if(!LAZYLEN(records))
		return

	for(var/obj/machinery/clonepod/pod in pods)
		if(!(pod.occupant || pod.mess) && (pod.efficiency > 5))
			for(var/datum/dna2/record/R in records)
				if(!(pod.occupant || pod.mess))
					if(pod.growclone(R))
						records.Remove(R)

/obj/machinery/computer/cloning/proc/updatemodules()
	src.scanner = findscanner()
	releasecloner()
	findcloner()
	if(!selected_pod && pods.len)
		selected_pod = pods[1]

/obj/machinery/computer/cloning/proc/findscanner()
	var/obj/machinery/dna_scannernew/scannerf = null

	//Try to find scanner on adjacent tiles first
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, dir))
		if(scannerf)
			return scannerf

	//Then look for a free one in the area
	if(!scannerf)
		var/area/search_area = get_area(src)
		if(!search_area)
			return

		for(var/obj/machinery/dna_scannernew/S in search_area.machinery_cache)
			return S

	return 0

/obj/machinery/computer/cloning/proc/releasecloner()
	for(var/obj/machinery/clonepod/P in pods)
		P.connected = null
		P.name = initial(P.name)
	pods.Cut()

/obj/machinery/computer/cloning/proc/findcloner()
	var/num = 1
	for(var/obj/machinery/clonepod/P in get_area(src))
		if(!P.connected)
			pods += P
			P.connected = src
			P.name = "[initial(P.name)] #[num++]"


/obj/machinery/computer/cloning/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/disk/data)) //INSERT SOME DISKETTES
		add_fingerprint(user)
		if(diskette)
			balloon_alert(user, "слот для дискеты занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		diskette = I
		balloon_alert(user, "дискета вставлена")
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/computer/cloning/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	var/obj/item/multitool/multitool = I
	if(!multitool.buffer || !istype(multitool.buffer, /obj/machinery/clonepod))
		return .
	if(multitool.buffer in pods)
		balloon_alert(user, "уже подключено!")
		return .
	var/obj/machinery/clonepod/clonepod = multitool.buffer
	pods += clonepod
	clonepod.connected = src
	clonepod.name = "[initial(clonepod.name)] #[length(pods)]"
	balloon_alert(user, "устройства связаны")


/obj/machinery/computer/cloning/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/computer/cloning/attack_hand(mob/user)
	if(..())
		return TRUE

	user.set_machine(src)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	updatemodules()
	ui_interact(user)

/obj/machinery/computer/cloning/deconstruct(disassembled = TRUE, mob/user)
	if (emagged)
		circuit = /obj/item/circuitboard/broken
	..()


/obj/machinery/computer/cloning/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		add_attack_logs(user, src, "emagged")
		set_scan_temp(emagged ? "Уничтожитель готов." : "Сканер готов.", "good")
		emp_act(1)
		SStgui.update_uis(src)
	else
		ui_interact(user)

/obj/machinery/computer/cloning/emp_act(severity)
	for(var/obj/machinery/clonepod/P in pods)
		if(P.occupant)
			var/mob/living/carbon/human/H = P.occupant
			H.adjustCloneLoss(500)
			P.go_out()

/obj/machinery/computer/cloning/ui_interact(mob/user, datum/tgui/ui = null)
	if(stat & (NOPOWER|BROKEN))
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CloningConsole", "Консоль клонирования")
		ui.open()

/obj/machinery/computer/cloning/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/cloning)
	)

/obj/machinery/computer/cloning/ui_data(mob/user)
	var/data[0]
	data["menu"] = src.menu
	data["scanner"] = sanitize("[src.scanner]")

	var/canpodautoprocess = 0
	if(pods.len)
		data["numberofpods"] = src.pods.len

		var/list/tempods[0]
		for(var/obj/machinery/clonepod/pod in pods)
			if(pod.efficiency > 5)
				canpodautoprocess = 1

			var/status = "режим ожидания"
			if(pod.mess)
				status = "неопознанный объект"
			else if(pod.occupant && !(pod.stat & NOPOWER))
				status = "клонирование"
			tempods.Add(list(list(
				"pod" = "\ref[pod]",
				"name" = sanitize(capitalize(pod.name)),
				"biomass" = pod.biomass,
				"status" = status,
				"progress" = (pod.occupant && pod.occupant.stat != DEAD) ? pod.get_completion() : 0
			)))
			data["pods"] = tempods

	data["loading"] = loading
	data["autoprocess"] = autoprocess
	data["can_brainscan"] = can_brainscan() // You'll need tier 4s for this
	data["scan_mode"] = scan_mode

	if(scanner && pods.len && ((scanner.scan_level > 2) || canpodautoprocess))
		data["autoallowed"] = 1
	else
		data["autoallowed"] = 0
	if(src.scanner)
		data["occupant"] = src.scanner.occupant
		data["locked"] = src.scanner.locked
	data["temp"] = temp
	data["scantemp"] = scantemp
	data["disk"] = src.diskette
	data["selected_pod"] = "\ref[selected_pod]"
	var/list/temprecords[0]
	for(var/datum/dna2/record/R in records)
		var/tempRealName = R.dna.real_name
		temprecords.Add(list(list("record" = "\ref[R]", "realname" = sanitize(tempRealName))))
	data["records"] = temprecords

	if(selected_pod && (selected_pod in pods) && selected_pod.biomass >= CLONE_BIOMASS)
		data["podready"] = 1
	else
		data["podready"] = 0

	data["modal"] = ui_modal_data(src)

	return data

/obj/machinery/computer/cloning/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/cloning)
	)

/obj/machinery/computer/cloning/ui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	. = TRUE
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_ANSWER)
			if(params["id"] == "del_rec" && active_record)
				var/obj/item/C = usr.get_active_hand()
				if(!istype(C) || !C.GetID())
					set_temp("ID карта не предъявлена.", "danger")
					return
				if(check_access(C.GetID()))
					records.Remove(active_record)
					qdel(active_record)
					set_temp("Запись удалена.", "success")
					menu = MENU_RECORDS
				else
					set_temp("Отказано в доступе.", "danger")
					playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
			return

	switch(action)
		if("scan")
			if(!scanner || !scanner.occupant || loading)
				return
			set_scan_temp(emagged ? "Уничтожитель готов." : "Сканер готов.", "good")
			loading = TRUE

			spawn(20)
				if(can_brainscan() && scan_mode)
					scan_mob(scanner.occupant, scan_brain = TRUE)
				else
					scan_mob(scanner.occupant)
				loading = FALSE
				SStgui.update_uis(src)
		if("autoprocess")
			autoprocess = text2num(params["on"]) > 0
		if("lock")
			if(isnull(scanner) || !scanner.occupant) //No locking an open scanner.
				return
			scanner.locked = !scanner.locked
		if("view_rec")
			var/ref = params["ref"]
			if(!length(ref))
				return
			active_record = locate(ref)
			if(istype(active_record))
				if(isnull(active_record.ckey))
					qdel(active_record)
					set_temp("Ошибка: запись повреждена.", "danger")
				else
					var/obj/item/implant/health/H = null
					if(active_record.implant)
						H = locate(active_record.implant)
					var/list/payload = list(
						activerecord = "\ref[active_record]",
						health = (H && istype(H)) ? H.sensehealth() : "",
						realname = sanitize(active_record.dna.real_name),
						unidentity = active_record.dna.uni_identity,
						strucenzymes = active_record.dna.struc_enzymes,
					)
					ui_modal_message(src, action, "", null, payload)
			else
				active_record = null
				set_temp(emagged ? "Ошибка: жертва не обнаружена." : "Ошибка: запись не обнаружена.", "danger")
		if("del_rec")
			if(!active_record)
				return
			ui_modal_boolean(src, action, "Для удаления записи предъявите свою ID-карту и нажмите на кнопку\"Удалить\":", yes_text = "Удалить", no_text = "Отмена")
		if("disk") // Disk management.
			if(!length(params["option"]))
				return
			switch(params["option"])
				if("load")
					if(isnull(diskette) || isnull(diskette.buf))
						set_temp("Ошибка: не удалось считать данные с дискеты.", "danger")
						return
					else if(isnull(active_record))
						set_temp(emagged ? "Ошибка: жертва не обнаружена." : "Ошибка: запись не обнаружена", "danger")
						menu = MENU_MAIN
						return

					active_record = diskette.buf.copy()
					set_temp("Данные загружены с дискеты.", "success")
				if("save")
					if(isnull(diskette) || diskette.read_only || isnull(active_record))
						set_temp("Ошибка: сохранение данных невозможно.", "danger")
						return

					// DNA2 makes things a little simpler.
					var/types
					switch(params["savetype"]) // Save as Ui/Ui+Ue/Se
						if("ui")
							types = DNA2_BUF_UI
						if("ue")
							types = DNA2_BUF_UI|DNA2_BUF_UE
						if("se")
							types = DNA2_BUF_SE
						else
							set_temp("Ошибка: неподходящий для сохранения формат данных.", "danger")
							return
					diskette.buf = active_record.copy()
					diskette.buf.types = types
					diskette.name = "data disk - '[active_record.dna.real_name]'"
					set_temp("Данные сохранены на дискету.", "success")
				if("eject")
					if(!isnull(diskette))
						diskette.loc = loc
						diskette = null
		if("refresh")
			SStgui.update_uis(src)
		if("selectpod")
			var/ref = params["ref"]
			if(!length(ref))
				return
			var/obj/machinery/clonepod/selected = locate(ref)
			if(istype(selected) && (selected in pods))
				selected_pod = selected
		if("clone")
			var/ref = params["ref"]
			if(!length(ref))
				return
			var/datum/dna2/record/C = locate(ref)
			//Look for that player! They better be dead!
			if(istype(C))
				ui_modal_clear(src)
				//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
				if(!length(pods))
					set_temp(emagged ? "Ошибка: капсула уничтожения не обнаружена." : "Ошибка: капсула клонирования не обнаружена.", "danger")
				else
					var/obj/machinery/clonepod/pod = selected_pod
					var/cloneresult
					if(!selected_pod)
						set_temp(emagged ? "Ошибка: капсула уничтожения не выбрана." : "Ошибка: капсула клонирования не выбрана.", "danger")
					else if(pod.occupant)
						set_temp("Ошибка: капсула клонирования занята.", "danger")
					else if(pod.biomass < CLONE_BIOMASS)
						set_temp(emagged ? "Ошибка: недостаточно ПЛОТИ!" : "Ошибка: недостаточно биомассы", "danger")
					else if(pod.mess)
						set_temp(emagged ? "Ошибка: капсула уничтожения в порядке." : "Ошибка: капсула клонирования неисправна.", emagged? "good" : "danger")
					else if(!CONFIG_GET(flag/revival_cloning))
						set_temp(emagged ? "Ошибка: запуск процесса уничтожения невозможен." : "Ошибка: запуск процесса клонирования невозможен.", "danger")
					else
						cloneresult = pod.growclone(C)
						if(cloneresult)
							set_temp(emagged ? "Запуск процеса уничтожения... Субъект успешно уничтожен!" : "Запуск процеса клонирования...", "success")
							records.Remove(C)
							qdel(C)
							menu = MENU_MAIN
							if(emagged)
								emp_act()
						else
							set_temp(emagged ? "Успех: всё идёт хорошо!" : "Ошибка: сбой инициализации клонирования.", emagged ? "good" : "danger")
			else
				set_temp("Ошибка: данные повреждены.", "danger")
		if("menu")
			menu = clamp(text2num(params["num"]), MENU_MAIN, MENU_RECORDS)
		if("toggle_mode")
			if(loading)
				return
			if(can_brainscan())
				scan_mode = !scan_mode
			else
				scan_mode = FALSE
		if("eject")
			if(usr.incapacitated() || !scanner || loading)
				return
			scanner.eject_occupant(usr)
			scanner.add_fingerprint(usr)
		if("cleartemp")
			temp = null
		else
			return FALSE

	src.add_fingerprint(usr)

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject as mob, var/scan_brain = 0)
	if(stat & NOPOWER)
		return
	if(scanner.stat & (NOPOWER|BROKEN))
		return
	if(scan_brain && !can_brainscan())
		return
	if(isnull(subject) || (!(ishuman(subject))) || (!subject.dna))
		if(isalien(subject))
			set_scan_temp("Ксеноморфы не подлежат сканированию.", "bad")
			SStgui.update_uis(src)
			return
		// can add more conditions for specific non-human messages here
		else
			set_scan_temp("Субъект данной расы не подлежит сканированию.", "bad")
			SStgui.update_uis(src)
			return
	var/obj/item/organ/internal/brain/brain = subject.get_int_organ(/obj/item/organ/internal/brain)
	if(!brain)
		set_scan_temp("Мозг в теле субъекта не обнаружен.", emagged ? "good" : "bad")
		SStgui.update_uis(src)
		return
	if(HAS_TRAIT(brain, TRAIT_NO_SCAN))
		set_scan_temp("Субъект не подлежит сканированию.", "bad")
		SStgui.update_uis(src)
		return
	if(subject.suiciding)
		set_scan_temp(emagged ? "Жертва ушла в лучший мир. Да будет так." : "Субъект совершил самоубийство и не подлежит сканированию.", emagged ? "good" : "bad")
		SStgui.update_uis(src)
		return
	if((!subject.ckey) || (!subject.client))
		set_scan_temp(emagged ? "Мозг жертвы в идеальном состоянии. Дальнейшие попытки сканирования не требуются." : "Мозг субъекта не подаёт сигналов. Дальнейшии попытки сканирования могут быть успешны.", emagged ? "good" : "bad")
		SStgui.update_uis(src)
		return
	if(HAS_TRAIT(subject, TRAIT_NO_CLONE) && scanner.scan_level < 2)
		set_scan_temp(emagged ? "Тело жертвы слишком идеально. Поплачь об этом." : "Субъект подвергся генетическим мутациям, не совместимым со сканированием.", emagged ? "good" : "bad")
		SStgui.update_uis(src)
		return
	if(!isnull(find_record(subject.ckey)))
		set_scan_temp(emagged ? "Баян." : "Данные о субъекте уже занесены в базу данных.")
		SStgui.update_uis(src)
		return

	for(var/obj/machinery/clonepod/pod in pods)
		if(pod.occupant && pod.clonemind == subject.mind)
			set_scan_temp("Субъект уже клонируется.")
			SStgui.update_uis(src)
			return

	subject.dna.check_integrity()

	var/datum/dna2/record/R = new /datum/dna2/record()
	R.ckey = subject.ckey
	var/extra_info = ""
	if(scan_brain)
		brain.dna.check_integrity()
		R.dna = brain.dna.Clone()
		R.id = copytext(md5(brain.dna.real_name), 2, 6)
		R.name = brain.dna.real_name
	else
		R.dna = subject.dna.Clone()
		R.id = copytext(md5(subject.real_name), 2, 6)
		R.name = R.dna.real_name

	R.types=DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	R.languages=subject.languages
	//Add an implant if needed
	var/obj/item/implant/health/imp = locate(/obj/item/implant/health, subject)
	if(!imp)
		imp = new /obj/item/implant/health(subject)
		imp.implant(subject)
	R.implant = "\ref[imp]"

	if(!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.mind = "\ref[subject.mind]"

	src.records += R
	set_scan_temp(emagged ? "Жертва успешно отсканирована. [extra_info]" : "Субъект успешно отсканирован. [extra_info]", "good")
	SStgui.update_uis(src)

//Find a specific record by key.
/obj/machinery/computer/cloning/proc/find_record(var/find_key)
	var/selected_record = null
	for(var/datum/dna2/record/R in src.records)
		if(R.ckey == find_key)
			selected_record = R
			break
	return selected_record

/obj/machinery/computer/cloning/proc/can_autoprocess()
	return (scanner && scanner.scan_level > 2)

/obj/machinery/computer/cloning/proc/can_brainscan()
	return (scanner && scanner.scan_level > 3)

/**
  * Sets a temporary message to display to the user
  *
  * Arguments:
  * * text - Text to display, null/empty to clear the message from the UI
  * * style - The style of the message: (color name), info, success, warning, danger
  */
/obj/machinery/computer/cloning/proc/set_temp(text = "", style = "info", update_now = FALSE)
	temp = list(text = text, style = style)
	if(update_now)
		SStgui.update_uis(src)

/**
  * Sets a temporary scan message to display to the user
  *
  * Arguments:
  * * text - Text to display, null/empty to clear the message from the UI
  * * color - The color of the message: (color name)
  */
/obj/machinery/computer/cloning/proc/set_scan_temp(text = "", color = "", update_now = FALSE)
	scantemp = list(text = text, color = color)
	if(update_now)
		SStgui.update_uis(src)

#undef MENU_MAIN
#undef MENU_RECORDS
