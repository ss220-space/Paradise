/*
Reverse Engineering Console

Protolathe designs are no longer unlocked by raising tech levels. Instead they are obtained here:
- Items are destroyed in the console. Every tech branch of the item (origin_tech) gives points of that branch,
  and the best single item remembers the maximum level that can be invested in that branch.
- The points of every branch can be raised or lowered in the UI. When the invested points exactly match the
  tech requirements of a protolathe design, the design can be written to a design disk.
  If several designs share the same requirements the player can switch between them.
- Writing a disk spends the invested points. The disk is read by a regular R&D console, after which
  the protolathe can print the design.
*/

/// Time it takes to write a design disk.
#define REVERSE_ENGINEERING_DELAY (2 SECONDS)

/// List of list("id", "name", "secret") for every tech branch, in a fixed order.
GLOBAL_LIST_EMPTY(reverse_engineering_branches)
/// Signature ("materials=3;engineering=2;") -> list of protolathe designs with exactly these requirements.
GLOBAL_LIST_EMPTY(reverse_engineering_designs)
GLOBAL_VAR_INIT(reverse_engineering_index_built, FALSE)

/proc/get_reverse_engineering_branches()
	if(!length(GLOB.reverse_engineering_branches))
		for(var/tech_path in subtypesof(/datum/tech))
			var/datum/tech/tech = tech_path
			GLOB.reverse_engineering_branches += list(list(
				"id" = initial(tech.id),
				"name" = initial(tech.name),
				"secret" = (initial(tech.level) <= 0),
			))
	return GLOB.reverse_engineering_branches

/// Builds a string out of tech levels. Only the order of the branches matters, so equal requirements always give equal strings.
/proc/reverse_engineering_signature(list/levels)
	var/signature = ""
	for(var/list/branch in get_reverse_engineering_branches())
		var/id = branch["id"]
		var/level = levels[id]
		if(level > 0)
			signature += "[id]=[level];"
	return signature

/proc/get_reverse_engineering_index()
	if(GLOB.reverse_engineering_index_built)
		return GLOB.reverse_engineering_designs

	var/list/branch_ids = list()
	for(var/list/branch in get_reverse_engineering_branches())
		branch_ids += branch["id"]

	for(var/design_path in subtypesof(/datum/design))
		var/datum/design/design = new design_path()
		if(!design.build_path || !design.requires_analysis())
			qdel(design)
			continue

		var/valid = TRUE
		for(var/tech_id in design.req_tech)
			if(!(tech_id in branch_ids) || design.req_tech[tech_id] <= 0)
				valid = FALSE
				break
		if(!valid)
			qdel(design)
			continue

		var/signature = reverse_engineering_signature(design.req_tech)
		var/list/bucket = GLOB.reverse_engineering_designs[signature]
		if(!bucket)
			bucket = list()
			GLOB.reverse_engineering_designs[signature] = bucket
		bucket += design

	GLOB.reverse_engineering_index_built = TRUE
	return GLOB.reverse_engineering_designs

/obj/machinery/computer/reverse_engineering
	name = "reverse engineering console"
	desc = "Компьютер, обеспечивающий разбор объектов на технологические данные и создание на их основе дискет с шаблонами печати для протолата."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_LAVENDER
	circuit = /obj/item/circuitboard/reverse_engineering
	req_access = list(ACCESS_TOX)
	var/list/points = list()
	var/list/max_points = list()
	/// Connected R&D console with server connetion
	var/obj/machinery/computer/rdconsole/linked_console
	/// Tech id -> points that are currently invested.
	var/list/allocation = list()
	/// Index of the shown design, when several designs have the same requirements.
	var/selected_match = 1
	/// A disk is being written.
	var/busy = FALSE
	/// What the last destroyed item gave.
	var/last_result

/obj/machinery/computer/reverse_engineering/get_ru_names()
	return alist(
		NOMINATIVE = "консоль обратной инженерии",
		GENITIVE = "консоли обратной инженерии",
		DATIVE = "консоли обратной инженерии",
		ACCUSATIVE = "консоль обратной инженерии",
		INSTRUMENTAL = "консолью обратной инженерии",
		PREPOSITIONAL = "консоли обратной инженерии",
	)

/obj/machinery/computer/reverse_engineering/emag_act(mob/user)
	if(emagged)
		return
	add_attack_logs(user, src, "emagged")
	playsound(loc, 'sound/effects/sparks4.ogg', 75, TRUE)
	req_access = list()
	emagged = TRUE
	if(user)
		balloon_alert_to_viewers("искрит и жужжит!", "протоколы безопасности взломаны")

/obj/machinery/computer/reverse_engineering/examine(mob/user)
	. = ..()
	. += span_notice("Предметы с технологическим потенциалом можно поместить в консоль, чтобы уничтожить их и получить очки исследований.")

/obj/machinery/computer/reverse_engineering/attackby(obj/item/I, mob/user, params)
	// Tools are handled by the usual interactions, they can be destroyed with the button in the UI.
	if(user.a_intent == INTENT_HARM || (stat & (NOPOWER|BROKEN)) || I.tool_behaviour || !I.origin_tech)
		return ..()

	add_fingerprint(user)
	if(!allowed(user))
		balloon_alert(user, "отказано в доступе!")
		playsound(src, SFX_BUTTON_DENIED, 20)
		return ATTACK_CHAIN_PROCEED

	return ATTACK_CHAIN_PROCEED

// /// Destroys the item and adds its tech to the points. Returns TRUE if the item was destroyed.
// /obj/machinery/computer/reverse_engineering/proc/try_destroy_item(obj/item/I, mob/user)
// 	if(stat & (NOPOWER|BROKEN))
// 		return FALSE
// 	if(!I.origin_tech)
// 		balloon_alert(user, "не подходит для анализа!")
// 		return FALSE
// 	if(iscore(I))
// 		balloon_alert(user, "слишком сложный объект!")
// 		return FALSE

// 	var/list/branch_ids = list()
// 	for(var/list/branch in get_reverse_engineering_branches())
// 		branch_ids += branch["id"]

// 	var/list/origin = params2list(I.origin_tech)
// 	var/list/gained = list()
// 	for(var/tech_id in origin)
// 		var/level = round(text2num(origin[tech_id]))
// 		if(!(tech_id in branch_ids) || isnull(level) || level <= 0)
// 			continue
// 		gained[tech_id] = level
// 	if(!length(gained))
// 		balloon_alert(user, "не подходит для анализа!")
// 		return FALSE

// 	var/item_name = DECLENT_RU_CAP(I, NOMINATIVE)

// 	if(istype(I, /obj/item/stack))
// 		// Only one unit of the stack is destroyed.
// 		var/obj/item/stack/S = I
// 		if(!S.use(1))
// 			return FALSE
// 	else
// 		for(var/mob/living/contained_mob in I.contents)
// 			contained_mob.death()
// 		if(!user.drop_transfer_item_to_loc(I, src))
// 			return FALSE
// 		qdel(I)

// 	var/list/result = list()
// 	for(var/tech_id in gained)
// 		var/level = gained[tech_id]
// 		points[tech_id] = (points[tech_id] || 0) + level
// 		max_levels[tech_id] = max(max_levels[tech_id] || 0, level)
// 		result += "[CallTechName(tech_id)] +[level]"

// 	last_result = "[item_name]: [jointext(result, ", ")]"
// 	investigate_log("[key_name_log(user)] destroyed [item_name] in [src]: [last_result].", INVESTIGATE_RESEARCH)
// 	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
// 	balloon_alert(user, "объект уничтожен")
// 	SStgui.update_uis(src)
// 	return TRUE

/// Returns the designs whose tech requirements exactly match the invested points.
/obj/machinery/computer/reverse_engineering/proc/get_matches()
	var/signature = reverse_engineering_signature(allocation)
	if(!length(signature))
		return list()
	var/list/index = get_reverse_engineering_index()
	var/list/bucket = index[signature]
	return bucket ? bucket : list()

/// The most points that can be invested in the branch.
/obj/machinery/computer/reverse_engineering/proc/get_cap(tech_id)
	return min((linked_console ? linked_console.files.known_tech[tech_id].level : 0) || 0, points[tech_id] || 0)

/// Lowers the investments if they are no longer affordable.
/obj/machinery/computer/reverse_engineering/proc/clamp_allocation()
	for(var/tech_id in allocation)
		allocation[tech_id] = min(allocation[tech_id], get_cap(tech_id))
		if(allocation[tech_id] <= 0)
			allocation -= tech_id

/obj/machinery/computer/reverse_engineering/attack_hand(mob/user)
	if(..())
		return TRUE
	if(!allowed(user) && !isobserver(user))
		balloon_alert(user, "отказано в доступе!")
		playsound(src, SFX_BUTTON_DENIED, 20)
		return TRUE
	ui_interact(user)

/obj/machinery/computer/reverse_engineering/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReverseEngineeringConsole", DECLENT_RU_CAP(src, NOMINATIVE))
		ui.open()

/obj/machinery/computer/reverse_engineering/ui_data(mob/user)
	var/list/data = list()

	var/list/branches = list()
	var/total_points = 0
	for(var/list/branch in get_reverse_engineering_branches())
		var/id = branch["id"]
		var/pool = points[id] || 0
		var/max_level = (linked_console ? linked_console.files.known_tech[id].level : 0) || 0
		// Secret branches are shown only after something with them was destroyed.
		if(branch["secret"] && !pool && !max_level)
			continue
		var/allocated = allocation[id] || 0
		total_points += allocated
		branches += list(list(
			"id" = id,
			"name" = branch["name"],
			"points" = pool,
			"max_level" = max_level,
			"cap" = min(pool, max_level),
			"allocated" = allocated,
		))
	data["branches"] = branches
	data["total_allocated"] = total_points

	var/list/matches = get_matches()
	selected_match = clamp(selected_match, 1, max(1, length(matches)))
	data["match_count"] = length(matches)
	data["match_index"] = selected_match
	data["design"] = null
	if(length(matches))
		var/datum/design/design = matches[selected_match]
		var/obj/item/created_object = design.build_path
		data["design"] = list(
			"id" = design.id,
			"name" = design.build_object_name,
			"desc" = design.build_object_desc,
			"icon" = initial(created_object.icon),
			"icon_state" = initial(created_object.icon_state),
		)

	data["busy"] = busy
	data["last_result"] = last_result
	return data

/obj/machinery/computer/reverse_engineering/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	if(!allowed(ui.user))
		return

	add_fingerprint(ui.user)

	switch(action)
		if("set_allocation")
			var/tech_id = params["id"]
			var/value = text2num(params["value"])
			if(!istext(tech_id) || isnull(value))
				return
			var/valid_branch = FALSE
			for(var/list/branch in get_reverse_engineering_branches())
				if(branch["id"] == tech_id)
					valid_branch = TRUE
					break
			if(!valid_branch)
				return
			value = clamp(round(value), 0, get_cap(tech_id))
			if(value > 0)
				allocation[tech_id] = value
			else
				allocation -= tech_id
			selected_match = 1
			return TRUE

		if("reset_allocation")
			allocation.Cut()
			selected_match = 1
			return TRUE

		if("select_match")
			var/list/matches = get_matches()
			if(!length(matches))
				return
			var/direction = text2num(params["direction"]) >= 0 ? 1 : -1
			selected_match += direction
			if(selected_match > length(matches))
				selected_match = 1
			else if(selected_match < 1)
				selected_match = length(matches)
			return TRUE

		if("create_disk")
			return create_disk(ui.user)

/obj/machinery/computer/reverse_engineering/proc/create_disk(mob/user)
	if(busy || (stat & (NOPOWER|BROKEN)))
		return FALSE

	var/list/matches = get_matches()
	if(!length(matches))
		return FALSE

	var/datum/design/design = matches[clamp(selected_match, 1, length(matches))]

	// The points could be spent on something else since the UI was updated.
	for(var/tech_id in allocation)
		if(allocation[tech_id] > get_cap(tech_id))
			clamp_allocation()
			return TRUE

	for(var/tech_id in allocation)
		points[tech_id] -= allocation[tech_id]
	clamp_allocation()

	busy = TRUE
	investigate_log("[key_name_log(user)] started writing a design disk for [design.id] in [src].", INVESTIGATE_RESEARCH)
	playsound(src, 'sound/machines/rnd_machines/circuitprinter_print.ogg', 30, TRUE)
	addtimer(CALLBACK(src, PROC_REF(finish_disk), design), REVERSE_ENGINEERING_DELAY)
	return TRUE

/obj/machinery/computer/reverse_engineering/proc/finish_disk(datum/design/design)
	busy = FALSE
	var/obj/item/disk/design_disk/disk = new(get_turf(src))
	disk.load_blueprint(design)
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
	visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] выдаёт дискету с шаблоном печати."))
	SStgui.update_uis(src)

/obj/machinery/computer/reverse_engineering/proc/add_points(list/tech_points)
	for(var/tech_id in tech_points)
		var/level = tech_points[tech_id] || 0
		if(!level)
			continue
		points[tech_id] = (points[tech_id] || 0) + level

#undef REVERSE_ENGINEERING_DELAY
