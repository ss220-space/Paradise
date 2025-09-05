#define DNA_COUNT 54
#define DNA_COLOR_UNKNOWN "gray"
#define DNA_COLOR_DISABILITY "red"
#define DNA_COLOR_POWER "green"
#define DNA_NO_DATA "???"
#define DNA_EMPTY_DATA "Пустой"
#define DNA_UNKNOWN_DISABILITY_DATA "Неизвестная болезнь"


/obj/item/dna_notepad
	name = "genetic notepad"
	desc = "Планшет генетика, способный хранить данные блоков генов в удобном виде."
	gender = MALE
	icon = 'icons/obj/device.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "genetic_tablet_on"
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	item_state = "genetic_tablet_on"
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=2000, MAT_GLASS = 1000)
	origin_tech = "programming=2"
	var/dna_data = list()
	var/printing = FALSE

/obj/item/dna_notepad/get_ru_names()
	return list(
		NOMINATIVE = "планшет генетика",
		GENITIVE = "планшета генетика",
		DATIVE = "планшету генетика",
		ACCUSATIVE = "планшет генетика",
		INSTRUMENTAL = "планшетом генетика",
		PREPOSITIONAL = "планшете генетика"
	)

/obj/item/dna_notepad/Initialize(mapload)
	. = ..()
	create_empty_data()

/obj/item/dna_notepad/proc/read_dna_data(block)
	for(var/list/dna_detail_data as anything in dna_data)
		if(dna_detail_data["num"] == "[block]")
			return dna_detail_data
	var/list/current_dna_detail_data = list(
		num = "[block]",
		name = DNA_NO_DATA,
		color = DNA_COLOR_UNKNOWN
	)
	dna_data += list(current_dna_detail_data)
	return current_dna_detail_data

/obj/item/dna_notepad/proc/write_dna_data(block, name, color)
	var/list/current_dna_detail_data = null
	for(var/list/dna_detail_data as anything in dna_data)
		if(dna_detail_data["num"] == "[block]")
			current_dna_detail_data = dna_detail_data
			break
	if(!current_dna_detail_data)
		current_dna_detail_data = list(
			num = "[block]",
			name = "[name]",
			color = "[color]"
		)
		dna_data += list(current_dna_detail_data)
	current_dna_detail_data["name"] = "[name]"
	current_dna_detail_data["color"] = "[color]"

/obj/item/dna_notepad/proc/create_empty_data()
	for(var/i = 1; i <= DNA_COUNT; i++)
		write_dna_data(i, DNA_NO_DATA, DNA_COLOR_UNKNOWN)

/obj/item/dna_notepad/proc/print_report(var/mob/living/user)
	if(printing)
		return
	printing = TRUE
	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
	flick("genetic_tablet_print", src)
	addtimer(CALLBACK(src, PROC_REF(create_report_paper)), 3 SECONDS)

/obj/item/dna_notepad/proc/create_report_paper()
	var/obj/item/paper/paper = new(drop_location())
	paper.name = "Блоки генов"
	paper.header += "<center><b>Блоки генов</b></center><br>"
	paper.header += "<b>Время печати:</b> [station_time_timestamp()]<br><br>"
	paper.header += "<hr>"
	for(var/list/block as anything in dna_data)
		paper.header += "[block["num"]]: <span style='color: [block["color"]];'>[block["name"]]</span><br>"
	paper.header += "<hr>"
	if(in_range(usr, src))
		usr.put_in_hands(paper, ignore_anim = FALSE)
		usr.visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] дребезжит, после чего из окна печати выпадает лист бумаги."))
	printing = FALSE

/obj/item/dna_notepad/proc/all_dna_names()
	var/list/arr = list()
	arr += DNA_NO_DATA
	arr += DNA_EMPTY_DATA
	arr += DNA_UNKNOWN_DISABILITY_DATA
	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		arr += "[gene.name]"
	arr -= "Monkey"  // Remove other genomes
	arr -= "Ordinary Gene"
	arr -= "Ordinary Gene"
	arr -= "Ordinary Gene"
	return arr

/obj/item/dna_notepad/proc/find_gene_by_name(name)
	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		if(gene.name == name)
			return gene
	return null

/obj/item/dna_notepad/attack_self(mob/user as mob)
	add_fingerprint(user)
	SStgui.update_uis(src)
	ui_interact(user)

/obj/item/dna_notepad/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		SStgui.update_uis(src)
		ui_interact(user)
		return
	. += span_notice("Нужно подойти ближе, чтобы посмотреть содержмое.")
	balloon_alert("слишком далеко")

/obj/item/dna_notepad/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DnaNotepad")
		ui.open()

/obj/item/dna_notepad/ui_data(mob/user)
	var/list/data = list()
	data["dna_data"] = dna_data
	// Transfer modal information if there is one
	data["modal"] = ui_modal_data(src)
	return data

/obj/item/dna_notepad/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return FALSE
	add_fingerprint(usr)
	playsound(loc, SFX_TERMINAL_TYPE, 25, TRUE)
	if(ui_act_modal(action, params))
		return TRUE
	. = TRUE
	switch(action)
		if("clear")
			to_chat(usr, "Экран [declent_ru(GENITIVE)] моргает и все данные пропадают.")
			create_empty_data()
		if("print")
			print_report(usr)
		if("edit_dna_block")
			var/block_num = text2num(params["id"])
			if(block_num < 1 || block_num > DNA_COUNT)
				return
			var/list/choices = all_dna_names()
			ui_modal_choice(src, "edit_dna_block_name", "Выберите эффект блока [block_num]:", null, list("id" = block_num), null, choices)

/obj/item/dna_notepad/proc/ui_act_modal(action, params)
	. = FALSE
	var/id = params["id"] // The modal's ID
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]
	var/choice = ui_modal_act(src, action, params)
	if(choice != UI_MODAL_ANSWER)
		return
	var/answer = params["answer"]
	if(id != "edit_dna_block_name")
		return //other modals are ignored
	var/block_num = text2num(arguments["id"])
	if(block_num < 1 || block_num > DNA_COUNT)
		return TRUE
	var/gene = find_gene_by_name(answer)
	if(!gene)
		if(answer == DNA_UNKNOWN_DISABILITY_DATA)
			write_dna_data(block_num, answer, DNA_COLOR_DISABILITY)
		else
			write_dna_data(block_num, answer, DNA_COLOR_UNKNOWN)
		return TRUE
	var/color = DNA_COLOR_UNKNOWN
	if(istype(gene, /datum/dna/gene/disability))
		color = DNA_COLOR_DISABILITY
	if(istype(gene, /datum/dna/gene/basic))
		color = DNA_COLOR_POWER
	write_dna_data(block_num, answer, color)
	return TRUE

/obj/item/dna_notepad/verb/print_report_verb()
	set name = "Печать отчёта"
	set category = STATPANEL_OBJECT
	var/mob/user = usr
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	print_report(user)

/obj/item/dna_notepad/proc/load_unknown_disabilities_from_console(obj/machinery/computer/scan_consolenew/dna_console, mob/living/user)
	add_fingerprint(user)
	var/obj/machinery/dna_scannernew/connected = dna_console.connected
	if(!connected)
		to_chat(user, span_warning("[capitalize(dna_console.declent_ru(NOMINATIVE))] не подключен."))
		balloon_alert(user, "ошибка загрузки")
		return
	if(!connected.occupant)
		to_chat(user, span_warning("[capitalize(connected.declent_ru(NOMINATIVE))] пуст."))
		balloon_alert(user, "ошибка загрузки")
		return
	if(!connected.occupant.dna)
		to_chat(user, span_warning("Внутри [connected.declent_ru(GENITIVE)] некорректные гены."))
		balloon_alert(user, "ошибка загрузки")
		return
	for(var/i = 1; i <= DNA_COUNT; i++)
		var/save_block_data = read_dna_data(i)
		if(save_block_data["name"] != DNA_NO_DATA)
			continue
		var/block_value = connected.occupant.dna.SE[i]
		if(block_value < 2050) // HEX=802 DEC=2050
			continue
		write_dna_data(i, DNA_UNKNOWN_DISABILITY_DATA, DNA_COLOR_DISABILITY)
	playsound(loc, SFX_TERMINAL_TYPE, 25, TRUE)
	to_chat(user, "Данные из [dna_console.declent_ru(GENITIVE)] успешно загружены в [declent_ru(NOMINATIVE)].")
	balloon_alert(user, "данные загружены")

/obj/item/dna_notepad/attack_obj(obj/object, mob/living/user, params)
	. = ..()
	if(!istype(object, /obj/machinery/computer/scan_consolenew))
		return
	var/obj/machinery/computer/scan_consolenew/dna_console = object
	var answer = tgui_alert(user, "Загрузить с консоли блоки выше 802 как неизвестные болезни?", "Загрузка данных с консоли", list("Загрузить", "Отмена"))
	if(answer != "Загрузить")
		return
	if(!do_after(user, 2 SECONDS, user))
		return
	load_unknown_disabilities_from_console(dna_console, user)

/obj/item/dna_notepad/proc/sync_data_from_other_notepad(obj/item/dna_notepad/dna_notepad, mob/living/user)
	add_fingerprint(user)
	for(var/i = 1; i <= DNA_COUNT; i++)
		var/self_block = read_dna_data(i)
		var/other_block = dna_notepad.read_dna_data(i)
		if(self_block["name"] == DNA_NO_DATA)
			self_block["name"] = other_block["name"]
			self_block["color"] = other_block["color"]
		if(self_block["name"] != DNA_UNKNOWN_DISABILITY_DATA || other_block["color"] != DNA_COLOR_DISABILITY)
			continue
		self_block["name"] = other_block["name"]
		self_block["color"] = other_block["color"]
	playsound(loc, SFX_TERMINAL_TYPE, 25, TRUE)
	to_chat(user, "Данные из другого [dna_notepad.declent_ru(GENITIVE)] успешно загружены в ваш [declent_ru(NOMINATIVE)].")
	balloon_alert(user, "данные загружены")

/obj/item/dna_notepad/attackby(obj/item/item, mob/living/user, params)
	. = ..()
	if(!istype(item, /obj/item/dna_notepad))
		return
	if(!do_after(user, 2 SECONDS, user))
		return
	var/obj/item/dna_notepad/dna_notepad = item
	dna_notepad.sync_data_from_other_notepad(src, user)

/obj/item/dna_notepad/full

/obj/item/dna_notepad/full/Initialize(mapload)
	. = ..()
	fill_genes_data()

/obj/item/dna_notepad/full/proc/fill_genes_data()
	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		if(gene.block < 1 || gene.block > DNA_COUNT)
			continue
		if(gene.name == "Ordinary Gene")
			write_dna_data(gene.block, DNA_EMPTY_DATA, DNA_COLOR_UNKNOWN)
			continue
		var/color = DNA_COLOR_UNKNOWN
		if(istype(gene, /datum/dna/gene/disability))
			color = DNA_COLOR_DISABILITY
		if(istype(gene, /datum/dna/gene/basic))
			color = DNA_COLOR_POWER
		write_dna_data(gene.block, gene.name, color)


#undef DNA_COUNT
#undef DNA_COLOR_UNKNOWN
#undef DNA_COLOR_DISABILITY
#undef DNA_COLOR_POWER
#undef DNA_NO_DATA
#undef DNA_EMPTY_DATA
#undef DNA_UNKNOWN_DISABILITY_DATA
