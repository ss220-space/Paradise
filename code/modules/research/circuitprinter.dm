/*///////////////Circuit Imprinter////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/r_n_d/circuit_imprinter
	name = "circuit imprinter"
	desc = "Оборудование, предназначенное для создания печатных плат \
			на основе шаблонов для печати для последующей установки в различное оборудование. \
			Управление происходит с помощью подключаемой консоли."
	icon_state = "circuit_imprinter"
	base_icon_state = "circuit_imprinter"
	container_type = OPENCONTAINER

	///List of designs scanned and saved
	var/list/scanned_designs
	/// The current unlocked circuit component designs. Used by integrated circuits to print off circuit components remotely.
	var/list/current_unlocked_designs
	///Constant material cost per component
	var/cost_per_component = CIRCUIT_COMPONENT_COST

	categories = list(
		CIRCUIT_IMPRINTER_CATEGORY_AI,
		CIRCUIT_IMPRINTER_CATEGORY_COMPUTER,
		CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING,
		CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT,
		CIRCUIT_IMPRINTER_CATEGORY_HYDROPONICS,
		CIRCUIT_IMPRINTER_CATEGORY_MEDICAL,
		CIRCUIT_IMPRINTER_CATEGORY_MISC,
		CIRCUIT_IMPRINTER_CATEGORY_RESEARCH,
		CIRCUIT_IMPRINTER_CATEGORY_TELECOMS,
		CIRCUIT_IMPRINTER_CATEGORY_TELEPORTATION,
		CIRCUIT_IMPRINTER_CATEGORY_CIRCUIT,
	)

	reagents = new()

/obj/machinery/r_n_d/circuit_imprinter/get_ru_names()
	return alist(
		NOMINATIVE = "принтер плат",
		GENITIVE = "принтера плат",
		DATIVE = "принтеру плат",
		ACCUSATIVE = "принтер плат",
		INSTRUMENTAL = "принтером плат",
		PREPOSITIONAL = "принтере плат",
	)

/obj/machinery/r_n_d/circuit_imprinter/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/circuit_imprinter(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	RefreshParts()
	if(is_taipan(z))
		icon_state = "syndie_circuit_imprinter"
		base_icon_state = "syndie_circuit_imprinter"
	reagents.my_atom = src

/obj/machinery/r_n_d/circuit_imprinter/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/circuit_imprinter(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	RefreshParts()
	if(is_taipan(z))
		icon_state = "syndie_circuit_imprinter"
		base_icon_state = "syndie_circuit_imprinter"
	reagents.my_atom = src

/obj/machinery/r_n_d/circuit_imprinter/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)

	materials.max_amount = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		materials.max_amount += M.rating * 75000

	var/T = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T += M.rating
	T = clamp(T, 1, 5)
	efficiency_coeff = 1 / (2 ** (T - 1))

/obj/machinery/r_n_d/circuit_imprinter/check_mat(datum/design/being_built, M)
	var/list/all_materials = being_built.reagents_list + being_built.materials

	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)

	return round(A / max(1, (all_materials[M] * efficiency_coeff)))

/obj/machinery/r_n_d/circuit_imprinter/proc/update_components_list()
	LAZYCLEARLIST(current_unlocked_designs)

	if(!linked_console)
		return

	var/datum/research/research_console = linked_console.files
	for(var/desing_id in research_console.known_designs)
		var/datum/design/design = research_console.known_designs[desing_id]
		if(!(design.build_type & IMPRINTER) || !ispath(design.build_path, /obj/item/circuit_component))
			continue

		LAZYADDASSOC(current_unlocked_designs, design.build_path, design.id)

/obj/machinery/r_n_d/circuit_imprinter/attack_hand(mob/user)
	if(..(user, 0))
		return
	interact(user)

/obj/machinery/r_n_d/circuit_imprinter/attack_ghost(mob/user)
	return interact(user)

/obj/machinery/r_n_d/circuit_imprinter/interact(mob/user)
	if(disabled)
		return

	ui_interact(user)

/obj/machinery/r_n_d/circuit_imprinter/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)

	if(ui)
		return

	ui = new(user, src, "ComponentPrinter", DECLENT_RU_CAP(src, NOMINATIVE))
	ui.open()

/obj/machinery/r_n_d/circuit_imprinter/attackby(obj/item/tool, mob/user, params)
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	var/is_open_container = tool.is_open_container()
	if(user.a_intent == INTENT_HARM)
		if(is_open_container)
			return ..() | ATTACK_CHAIN_NO_AFTERATTACK
		return ..()

	if(exchange_parts(user, tool))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(is_open_container)
		if(panel_open)
			balloon_alert(user, "панель открыта!")
			return ATTACK_CHAIN_PROCEED_NO_AFTERATTACK
		return ATTACK_CHAIN_PROCEED	// afterattack will handle this

	if(is_circuit(tool))
		circuit_iteract(user, tool)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/machinery/r_n_d/circuit_imprinter/proc/recycling_component(mob/living/user, obj/item/tool)
	//to allow quick recycling of circuits
	if(!is_circuit_component(tool))
		return

	var/amount_inserted = materials.insert_item(tool)
	if(!amount_inserted)
		to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] отклоняет переработку [tool.declent_ru(GENITIVE)]."))
		return

	qdel(tool)
	to_chat(user, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] перерабатывает [tool.declent_ru(ACCUSATIVE)] в [amount_inserted /  SHEET_VOLUME] единиц[DECL_SEC_MIN(amount_inserted /  SHEET_VOLUME)] материала."))


#define LINK_CIRCUIT "Привязать схему"
#define SAVE_CIRCUIT "Сохранить схему"

/obj/machinery/r_n_d/circuit_imprinter/proc/circuit_iteract(mob/user, obj/item/circuit)
	if(!is_circuit(circuit))
		return FALSE

	var/image/save_icon = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_save1")
	var/image/link_icon = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_link")
	var/choices = list(
		LINK_CIRCUIT = link_icon,
		SAVE_CIRCUIT = save_icon,
	)
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user, circuit), require_near = TRUE)

	if(!check_menu(user, circuit))
		return FALSE

	switch(choice)
		if(LINK_CIRCUIT)
			link_circuit(user, circuit)
			return TRUE

		if(SAVE_CIRCUIT)
			save_circuit(user, circuit)
			return TRUE

	return TRUE

#undef LINK_CIRCUIT
#undef SAVE_CIRCUIT

/obj/machinery/r_n_d/circuit_imprinter/proc/check_menu(mob/living/user, obj/item/circuit)
	if(!istype(user))
		return FALSE

	if(panel_open)
		return FALSE

	if(user.incapacitated() || (user.get_active_hand() != circuit))
		return FALSE

	return TRUE

/obj/machinery/r_n_d/circuit_imprinter/proc/link_circuit(mob/living/user, obj/item/tool)
	if(!is_circuit(tool))
		return FALSE

	var/obj/item/integrated_circuit/circuit

	if(is_integrated_circuit(tool))
		circuit = tool

	if(is_module_circuit(tool))
		var/obj/item/circuit_component/module/module = tool
		circuit = module.internal_circuit

	circuit.linked_circuit_imprinter = WEAKREF(src)
	circuit.update_static_data_for_all_viewers()
	balloon_alert(user, "схема подключена")

/obj/machinery/r_n_d/circuit_imprinter/proc/can_save_circuit(mob/living/user, obj/item/circuit)
	if(!circuit)
		return FALSE

	if(!is_circuit(circuit))
		return FALSE

	if(!linked_console)
		balloon_alert(user, "не привязано к консоли!")
		return FALSE

	if(HAS_TRAIT(circuit, TRAIT_CIRCUIT_UNDUPABLE))
		balloon_alert(user, "не подлежит сохранению!")
		return FALSE

	return TRUE

/// Maximum number of characters in the description of the circuit
#define MAX_CHAR_IN_DESC 200

/obj/machinery/r_n_d/circuit_imprinter/proc/save_circuit(mob/living/user, obj/item/circuit)
	if(!can_save_circuit(user, circuit))
		return

	var/list/data = list()

	if(is_module_circuit(circuit))
		var/obj/item/circuit_component/module/module = circuit

		data["dupe_data"] = list()
		module.save_data_to_list(data["dupe_data"])

		data["name"] = module.display_name
		data["materials"] = list(MAT_GLASS = module.circuit_size * cost_per_component)

	else
		var/obj/item/integrated_circuit/integrated_circuit = circuit
		data["dupe_data"] = integrated_circuit.convert_to_json()

		data["name"] = integrated_circuit.display_name

		var/datum/design/integrated_circuit/circuit_design = new /datum/design/integrated_circuit
		var/materials = list(MAT_GLASS = integrated_circuit.current_size * cost_per_component)
		for(var/material_type in circuit_design.materials)
			materials[material_type] += circuit_design.materials[material_type]

		data["materials"] = materials
		data["integrated_circuit"] = TRUE

	data["Icon"] = circuit.icon
	data["IconState"] = circuit.icon_state

	if(!length(data))
		return

	if(!data["name"])
		balloon_alert(user, "требуется название!")
		return

	for(var/list/component_data as anything in scanned_designs)
		if(component_data["name"] == data["name"])
			balloon_alert(user, "название занято!")
			return

	var/circuit_desc = reject_bad_name(sanitize(tgui_input_text(user, "Введите описание схемы.", "Описание", "", max_length = MAX_CHAR_IN_DESC)), allow_numbers = TRUE)

	data["desc"] = circuit_desc ? circuit_desc : "Схема, сохранённая пользователем \"[user]\"."

	LAZYADD(scanned_designs, list(data))

	balloon_alert(user, "схема сохранена")
	playsound(src, 'sound/machines/ping.ogg', 50)

	update_static_data_for_all_viewers()

/obj/machinery/r_n_d/circuit_imprinter/proc/can_save_circuit_by_import(mob/living/user, list/data)
	if(isnull(data) || !islist(data))
		return FALSE
	var/static/list/required_keys = list("dupe_data", "name", "Icon", "IconState", "desc")
	for(var/key in required_keys)
		if(!LAZYACCESS(data, key))
			return FALSE
	return TRUE

#define MAX_COMPONENT_COUNT 200

/obj/machinery/r_n_d/circuit_imprinter/proc/save_circuit_by_import(mob/living/user, list/data)
	if(!can_save_circuit_by_import(user, data))
		tgui_alert(user, "Невозможно сохранить схему!", "Ошибка импорта")
		return

	var/list/dupe_data = data["dupe_data"]
	if(istext(dupe_data))
		dupe_data = json_decode(dupe_data)

	if(!islist(dupe_data) || !islist(dupe_data["components"]) || length(dupe_data["components"]) > MAX_COMPONENT_COUNT)
		tgui_alert(user, "Некорректный формат данных схемы или превышен лимит компонентов!", "Ошибка импорта")
		return

	for(var/list/component_data as anything in scanned_designs)
		if(component_data["name"] == data["name"])
			to_chat(user, span_alert("Название занято!"))
			return

	var/current_size = 0

	for(var/component_data, value in dupe_data["components"])
		var/list/comp = value

		if(!islist(comp))
			if(!islist(component_data))
				continue
			comp = component_data

		var/path = text2path(comp["type"])
		if(!path || !ispath(path, /obj/item/circuit_component))
			to_chat(user, span_alert("Неккоректные данные JSON!"))
			return

		var/obj/item/circuit_component/component_type = path

		current_size += initial(component_type.circuit_size)

	var/materials = list(MAT_GLASS = current_size * cost_per_component)

	if(data["integrated_circuit"])
		var/datum/design/integrated_circuit/circuit_design = new /datum/design/integrated_circuit
		for(var/material_type, value in circuit_design.materials)
			materials[material_type] += value
		qdel(circuit_design)

	data["materials"] = materials

	var/obj/item/integrated_circuit/circuit = new /obj/item/integrated_circuit
	data["Icon"] = circuit.icon
	data["IconState"] = circuit.icon_state
	qdel(circuit)

	if(!length(data))
		return

	if(!data["name"])
		to_chat(user, span_alert("Требуется название!"))
		return

	LAZYADD(scanned_designs, list(data))

	to_chat(user, "Схема сохранена")
	playsound(src, 'sound/machines/ping.ogg', 50)

	update_static_data_for_all_viewers()

#undef MAX_COMPONENT_COUNT

/obj/machinery/r_n_d/circuit_imprinter/proc/print_module(list/design)
	flick("[base_icon_state]_ani", src)

	addtimer(CALLBACK(src, PROC_REF(finish_module_print), design), 1.6 SECONDS)

/obj/machinery/r_n_d/circuit_imprinter/proc/finish_module_print(list/design)
	var/atom/movable/created_atom
	if(design["integrated_circuit"])
		var/obj/item/integrated_circuit/circuit = new(drop_location())
		var/list/errors = list()
		circuit.load_circuit_data(design["dupe_data"], errors)
		if(length(errors))
			stack_trace("Error loading user saved circuit [errors.Join(", ")].")
		created_atom = circuit
	else
		var/obj/item/circuit_component/module/module = new(drop_location())
		module.load_data_from_list(design["dupe_data"])
		created_atom = module

	balloon_alert_to_viewers("напечатано: [design["name"]]")
	created_atom.pixel_x = created_atom.base_pixel_x + rand(-5, 5)
	created_atom.pixel_y = created_atom.base_pixel_y + rand(-5, 5)

/obj/machinery/r_n_d/circuit_imprinter/proc/print_component(typepath)
	var/design_id = LAZYACCESS(current_unlocked_designs, typepath)
	var/datum/design/design = linked_console.files.known_designs[design_id]

	if(!(design?.build_type & IMPRINTER))
		return

	if(!try_use_materials(design.materials))
		return

	flick("[base_icon_state]_ani", src)
	return new design.build_path(drop_location())

/obj/machinery/r_n_d/circuit_imprinter/proc/try_use_materials(list/design_materials)
	return materials.use_amount(design_materials, efficiency_coeff)

/// Maximum number of characters in the name of the circuit
#define MAX_CHAR_IN_NAME 30

/obj/machinery/r_n_d/circuit_imprinter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("print")
			var/design_id = text2num(params["designId"])

			if(design_id < 1 || design_id > length(scanned_designs))
				return TRUE

			var/list/design = LAZYACCESS(scanned_designs, design_id)
			var/list/design_materials = design["materials"]

			try_use_materials(design_materials) ? print_module(design) : atom_say("Недостаточно материала для печати!")

		if("del_design")
			var/design_id = text2num(params["designId"])

			if(design_id < 1 || design_id > length(scanned_designs))
				return TRUE

			var/list/design = list(LAZYACCESS(scanned_designs, design_id))

			LAZYREMOVE(scanned_designs, design)

			update_static_data_for_all_viewers()

		if("export")
			var/mob/user = ui.user
			tgui_alert(user, "Функция отключена до исправления по соображениям безопасности", "ВНИМАНИЕ!")
			/*
			var/design_id = text2num(params["designId"])

			if(design_id < 1 || design_id > length(scanned_designs))
				return TRUE

			var/list/design = LAZYACCESS(scanned_designs, design_id)

			var/list/data = list(
				"dupe_data" = design["dupe_data"],
				"name" = design["name"],
				"desc" = design["desc"],
				"integrated_circuit" = design["integrated_circuit"],
				"Icon" = design["Icon"],
				"IconState" = design["IconState"]
			)

			var/json_base64 = rustg_encode_base64(json_encode(data))

			if(!json_base64)
				tgui_alert(user, message = "Ошибка экспорта!", title = "Ошибка!")
				return

			tgui_input_text(user, "Скопируйте текст схемы:", "Экспорт схемы", default = json_base64)
			*/

		if("import")
			var/mob/user = ui.user
			tgui_alert(user, "Функция отключена до исправления по соображениям безопасности", "ВНИМАНИЕ!")
			/*
			var/json_base64 = params["import"]
			if(!json_base64)
				return TRUE

			json_base64 = replacetext(json_base64, "\n", "")
			json_base64 = trim(json_base64)

			var/decoded = rustg_decode_base64(json_base64)
			if(!decoded)
				tgui_alert(user, "Не удалось декодировать Base64!", "Ошибка импорта")
				return TRUE

			var/list/data = json_decode(decoded)
			if(!islist(data))
				tgui_alert(user, "Некорректный формат JSON!", "Ошибка импорта")
				return TRUE

			if(data["name"])
				data["name"] = copytext(sanitize(data["name"]), 1, MAX_CHAR_IN_NAME)
			if(data["desc"])
				data["desc"] = copytext(sanitize(data["desc"]), 1, MAX_CHAR_IN_DESC)

			save_circuit_by_import(user, data)
			*/

	return TRUE

#undef MAX_CHAR_IN_NAME
#undef MAX_CHAR_IN_DESC

/obj/machinery/r_n_d/circuit_imprinter/ui_data(mob/user)
	var/list/data = list()
	data["materials"] = materials.ui_data()
	return data

/obj/machinery/r_n_d/circuit_imprinter/ui_static_data(mob/user)
	var/list/data = materials.ui_static_data()

	var/list/designs = list()

	var/index = 1
	for(var/list/design as anything in scanned_designs)

		var/list/cost = list()
		var/list/materials = design["materials"]
		for(var/MAT in materials)
			cost[MAT] = max(1, round(materials[MAT] * efficiency_coeff))

		designs["[index]"] = list(
			"name" = design["name"],
			"desc" = design["desc"],
			"cost" = cost,
			"id" = "[index]",
			"icon" = design["Icon"],
			"IconState" = design["IconState"],
			"categories" = list("/Saved Circuits"),
		)
		index++

	data["designs"] = designs

	return data

/obj/machinery/r_n_d/circuit_imprinter/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return TRUE

	. = default_deconstruction_screwdriver(user, "[base_icon_state]_unscrewed", base_icon_state, tool)

	if(. && linked_console)
		linked_console.linked_imprinter = null
		linked_console = null

/obj/machinery/r_n_d/circuit_imprinter/crowbar_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return .

	if(!panel_open)
		add_fingerprint(user)
		balloon_alert(user, "техпанель закрыта!")
		return .

	var/atom/drop_loc = drop_location()
	for(var/obj/component as anything in component_parts)
		if(istype(component, /obj/item/reagent_containers/glass/beaker))
			reagents.trans_to(component, reagents.total_volume)

		component.forceMove(drop_loc)

	materials.retrieve_all()
	default_deconstruction_crowbar(user, tool)

