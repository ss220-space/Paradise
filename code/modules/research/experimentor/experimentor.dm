/obj/machinery/r_n_d/experimentor
	name = "E.X.P.E.R.I-MENTOR"
	desc = "Experimental Xeon Particle Entropy Reaction Infuser or something like that. Nanotrasen's new reaction infuser, with a slight less tendency to catastrophically fail than the previous model... or so they say."
	icon = 'icons/obj/machines/heavy_lathe.dmi'
	icon_state = "h_lathe"
	base_icon_state = "h_lathe"

	/// Weakref to the station Ian the corgi (or whichever we can find)
	var/datum/weakref/tracked_ian_ref
	/// Weakref to the station Runtime the cat (or whichever we can find)
	var/datum/weakref/tracked_runtime_ref
	/// The current probability of a malfunction
	var/malfunction_probability_coeff = 0
	/// How many times we've had a critical reaction
	var/critical_malfunction_counter = 0
	/// How long is the cooldown between experiments
	var/cooldown = EXPERIMENT_COOLDOWN_BASE
	/// List of experiment handler datums by scantype
	var/list/experimentor_result_handlers = list()
	/// Reactions that can occur for specific items
	var/list/item_reactions = list()
	/// Items that we can get by transforming
	var/static/list/valid_items = list()
	/// Items that will cause critical reactions
	var/static/list/critical_items_typecache
	/// Items that the machine shouldn't interact with
	var/static/list/banned_typecache
	var/clone_mode = FALSE
	var/clone_count = 0
	/// Clones the next inserted technological item.
	var/clone_next = FALSE
	/// The distance to your rnd console. Useful for creative mapping.
	var/console_dist = 3

	var/datum/wires/experimentator_wires

	COOLDOWN_DECLARE(run_experiment)

/obj/machinery/r_n_d/experimentor/Initialize(mapload)
	. = ..()
	experimentator_wires = new /datum/wires/experimentor(src)

	load_handlers()

	component_parts = list()
	component_parts += new /obj/item/circuitboard/experimentor(src)
	component_parts += new /obj/item/stock_parts/scanning_module(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)

	if(!critical_items_typecache)
		critical_items_typecache = typecacheof(list(
			/obj/item/rcd,
			/obj/item/grenade,
			/obj/item/aicard,
			/obj/item/storage/backpack/holding,
			/obj/item/slime_extract,
			/obj/item/onetankbomb,
			/obj/item/transfer_valve
		))

	if(!banned_typecache)
		banned_typecache = typecacheof(list(
			/obj/item/stock_parts/cell/infinite
		))

	if(!length(valid_items))
		for(var/obj/item/item_path as anything in valid_subtypesof(/obj/item))
			if(ispath(item_path, /obj/item/stock_parts) || ispath(item_path, /obj/item/grenade/chem_grenade) || ispath(item_path, /obj/item/kitchen))
				valid_items[item_path] += 15

			if(ispath(item_path, /obj/item/reagent_containers/food))
				valid_items[item_path] += rand(1, 4)
		RefreshParts()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/r_n_d/experimentor/LateInitialize()
	. = ..()
	console_connect()
	// GLOB.mob_living_list gets populated in /mob/Initialize()
	// so we need to delay searching for those until after the Initialize()
	tracked_ian_ref = WEAKREF(locate(/mob/living/simple_animal/pet/dog/corgi/Ian) in GLOB.mob_living_list)
	tracked_runtime_ref = WEAKREF(locate(/mob/living/simple_animal/pet/cat/Runtime) in GLOB.mob_living_list)

/obj/machinery/r_n_d/experimentor/RefreshParts()
	malfunction_probability_coeff = critical_malfunction_counter
	cooldown = initial(cooldown)
	for(var/obj/item/stock_parts/manipulator/manipulator in component_parts)
		cooldown = max(1, cooldown - manipulator.rating)
	for(var/obj/item/stock_parts/scanning_module/scanning_module in component_parts)
		malfunction_probability_coeff += scanning_module.rating * 2
	for(var/obj/item/stock_parts/micro_laser/micro_laser in component_parts)
		malfunction_probability_coeff += micro_laser.rating

/obj/machinery/r_n_d/experimentor/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads:<br>")
		. += span_notice("Malfunction probability reduced by [span_bold("[malfunction_probability_coeff]")].")
		. += span_notice("Cooldown interval between experiments at [span_bold("[cooldown]")] seconds.")


/obj/machinery/r_n_d/experimentor/update_icon_state()
	icon_state = "h_lathe[!COOLDOWN_FINISHED(src, run_experiment) ? "_wloop" : ""]"

/obj/machinery/r_n_d/experimentor/proc/convert_req_string_to_list(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/key, value in temp_list)
		temp_list[key] = text2num(value)
	return temp_list

/obj/machinery/r_n_d/experimentor/proc/load_handlers()
	for(var/datum/experimentor_result_handler/scan/handler_type as anything in valid_subtypesof(/datum/experimentor_result_handler/scan))
		var/datum/experimentor_result_handler/scan/handler = new handler_type()
		experimentor_result_handlers[handler.scantype] = handler

	experimentor_result_handlers[FAIL] = new /datum/experimentor_result_handler/fail

/obj/machinery/r_n_d/experimentor/proc/get_available_reactions()
	var/list/all_reactions = list()
	for(var/scantype in experimentor_result_handlers)
		var/datum/experimentor_result_handler/handler = experimentor_result_handlers[scantype]
		if(handler.is_special)
			continue

		all_reactions += scantype

	return all_reactions

/obj/machinery/r_n_d/experimentor/proc/is_special_reaction(reaction_type)
	var/datum/experimentor_result_handler/handler = experimentor_result_handlers[reaction_type]
	return handler.is_special

/obj/machinery/r_n_d/experimentor/proc/run_experiment(experiment_type)
	if(!loaded_item)
		return

	var/datum/experimentor_result_handler/handler = experimentor_result_handlers[experiment_type]
	if(handler)
		handler.execute(src, loaded_item)
	else
		fail_experiment()

	handle_global_reactions()
	update_appearance()
	COOLDOWN_START(src, run_experiment, cooldown)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), UPDATE_ICON_STATE), cooldown)

/obj/machinery/r_n_d/experimentor/proc/show_start_message(message, type)
	switch(type)
		if(MSG_TYPE_NOTICE)
			visible_message(span_notice("[src] [message]"))
		if(MSG_TYPE_WARNING)
			visible_message(span_warning("[src] [message]"))
		if(MSG_TYPE_DANGER)
			visible_message(span_danger("[src] [message]"))
		else
			visible_message(span_notice("[src] [message]"))

/obj/machinery/r_n_d/experimentor/proc/is_critical_reaction()
	return is_type_in_typecache(loaded_item, critical_items_typecache)

/obj/machinery/r_n_d/experimentor/proc/get_malfunction_chance()
	return (100 - malfunction_probability_coeff) * 0.01

/obj/machinery/r_n_d/experimentor/proc/fail_experiment()
	var/datum/experimentor_result_handler/fail_handler = experimentor_result_handlers[FAIL]
	if(fail_handler)
		fail_handler.execute(src, loaded_item)

/obj/machinery/r_n_d/experimentor/proc/try_generate_reaction_for_item(obj/item/some_item)
	if(is_type_in_typecache(some_item.type, banned_typecache) || item_reactions[some_item.type])
		return

	if(isrelic(some_item))
		return

	item_reactions[some_item.type] = pick(get_available_reactions())

/obj/machinery/r_n_d/experimentor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Experimentator", "E.X.P.E.R.I-MENTOR")
		ui.open()

/obj/machinery/r_n_d/experimentor/ui_static_data(mob/user)
	var/list/data = list()
	if(!linked_console)
		console_connect()
	data["isServerConnected"] = !!linked_console
	return data

/obj/machinery/r_n_d/experimentor/ui_data(mob/user)
	var/list/data = list()

	data["hasItem"] = !!loaded_item
	data["isOnCooldown"] = !COOLDOWN_FINISHED(src, run_experiment)
	data["isCloning"] = clone_mode

	var/list/available_experiments = list()
	for(var/scantype in experimentor_result_handlers)
		if(scantype == FAIL)
			continue

		var/datum/experimentor_result_handler/scan/handler = experimentor_result_handlers[scantype]

		if(loaded_item)
			available_experiments += list(list(
				"id" = scantype,
				"name" = handler.name || capitalize(scantype),
				"fa_icon" = handler.fa_icon || "question",
			))

	data["availableExperiments"] = available_experiments

	if(!isnull(loaded_item) && !isnull(linked_console.files))
		var/list/item_data = list()

		item_data["name"] = loaded_item.name
		item_data["icon"] = icon2base64(getFlatIcon(loaded_item, no_anim = TRUE))
		item_data["isRelic"] = isrelic(loaded_item)

		item_data["associatedNodes"] = list()
		var/list/temp_tech = convert_req_string_to_list(loaded_item.origin_tech)
		var/datum/research/research_data = linked_console?.files
		for(var/tech_id, value in temp_tech)
			var/datum/tech/current_tech = research_data.known_tech[tech_id]
			var/added_tech
			var/current_level = current_tech.level
			if(value >= current_level)
				added_tech = (value - current_level) || 1

			item_data["associatedNodes"] += list(list(
				"name" = current_tech.name,
				"current_tech" = current_tech.level,
				"added_tech" = added_tech
			))

		data["loadedItem"] = item_data

	return data

/obj/machinery/r_n_d/experimentor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject")
			item_eject()
			return TRUE

		if("experiment")
			var/reaction = params["id"]
			if(isnull(reaction))
				return

			try_perform_experiment(reaction)
			return TRUE

/obj/machinery/r_n_d/experimentor/proc/item_eject()
	if(isnull(loaded_item))
		return

	var/atom/drop_atom = get_step(src, EAST) || drop_location()
	if(clone_mode && clone_count > 0)
		visible_message(span_notice("A duplicate [loaded_item] pops out!"))
		var/atom/clone = new loaded_item.type(drop_atom)
		if(isstack(clone))
			var/obj/item/stack/stack_clone = clone
			stack_clone.amount = 1
		clone_count--
		if(clone_count == 0)
			clone_mode = FALSE
		return

	loaded_item.forceMove(drop_atom)
	loaded_item = null

/obj/machinery/r_n_d/experimentor/proc/match_reaction(obj/item/matching, target_reaction)
	PRIVATE_PROC(TRUE)
	if(isnull(matching) || isnull(target_reaction))
		return FAIL

	if(isrelic(matching))
		return target_reaction

	if(item_reactions[matching.type] == target_reaction)
		return item_reactions[matching.type]
	return FAIL

/obj/machinery/r_n_d/experimentor/proc/try_perform_experiment(reaction)
	if(isnull(linked_console) || isnull(loaded_item) || clone_mode || !COOLDOWN_FINISHED(src, run_experiment))
		return FALSE

	reaction = match_reaction(loaded_item, reaction)

	if(reaction != FAIL)
		var/list/tech_log = update_tech()
		if(tech_log)
			investigate_log("[usr] increased tech experimentoring [loaded_item]: [tech_log.Join("")]. ", INVESTIGATE_RESEARCH)

	run_experiment(reaction)
	use_power(750)

/obj/machinery/r_n_d/experimentor/proc/update_tech()
	if(!loaded_item?.origin_tech)
		return

	var/list/temp_tech = convert_req_string_to_list(loaded_item.origin_tech)
	var/list/tech_log
	var/datum/research/research_data = linked_console.files
	for(var/tech_id, value in temp_tech)
		var/datum/tech/tech = research_data.known_tech[tech_id]
		var/new_level
		if(tech.level > value && prob(calculate_bonus(tech, value)))
			new_level = research_data.UpdateTech(tech_id, tech.level)
		else
			new_level = research_data.UpdateTech(tech_id, value)
		if(new_level)
			LAZYADD(tech_log, "[tech_id] [new_level], ")

	return tech_log

/obj/machinery/r_n_d/experimentor/proc/calculate_bonus(datum/tech/tech, value)
	var/current_level = tech.level
	var/max_level = tech.max_level
	var/tech_delta = max(current_level - value, 0) / max_level
	var/machine_bonus = 1 + min(malfunction_probability_coeff, 100) / 100
	var/max_level_delta = max(max_level - current_level, 0) / max_level
	return BONUS_TECH_PROB * (1 - (tech_delta - max_level_delta)) * machine_bonus

/obj/machinery/r_n_d/experimentor/proc/handle_global_reactions()
	if(!prob(EFFECT_PROBABILITY * (100 - malfunction_probability_coeff) * 0.01) || !loaded_item)
		return

	var/malf_coefficient = rand(1, 100)
	switch(malf_coefficient)
		if(1 to 15)
			visible_message(span_warning("[src]'s onboard detection system has malfunctioned!"))
			item_reactions[loaded_item.type] = pick(get_available_reactions())
			item_eject()

		if(16 to 35)
			visible_message(span_warning("[src] melts [loaded_item], ian-izing the air around it!"))
			if(summon_mob(tracked_ian_ref, /mob/living/simple_animal/pet/dog/corgi))
				investigate_log("Experimentor has stolen Ian!", INVESTIGATE_EXPERIMENTOR)
				return
			investigate_log("Experimentor has spawned a new corgi.", INVESTIGATE_EXPERIMENTOR)

		if(36 to 50)
			visible_message(span_warning("Experimentor draws the life essence of those nearby!"))
			for(var/mob/living/mob in view(4, src))
				to_chat(mob, span_danger("You feel your flesh being torn from you, mists of blood drifting to [src]!"))
				playsound(src, pick('sound/effects/curse/curse1.ogg', 'sound/effects/curse/curse2.ogg', 'sound/effects/curse/curse3.ogg'), 30)
				mob.apply_damage(50, BRUTE, BODY_ZONE_CHEST)
				investigate_log("Experimentor has taken 50 brute a blood sacrifice from [mob]", INVESTIGATE_EXPERIMENTOR)

		if(51 to 75)
			visible_message(span_warning("[src] encounters a run-time error!"))
			if(summon_mob(tracked_runtime_ref, /mob/living/simple_animal/pet/cat))
				investigate_log("Experimentor has stolen Runtime!", INVESTIGATE_EXPERIMENTOR)
				return
			investigate_log("Experimentor failed to steal Runtime the cat and instead spawned a new cat.", INVESTIGATE_EXPERIMENTOR)

		if(76 to 98)
			visible_message(span_warning("[src] emits a low hum."))
			do_sparks(3, FALSE, src, src)
			use_power(500000)
			investigate_log("Experimentor has drained power from its APC", INVESTIGATE_EXPERIMENTOR)

		if(99)
			visible_message(span_warning("[src] begins to glow and vibrate. It's going to blow!"))
			addtimer(CALLBACK(src, PROC_REF(boom)), 5 SECONDS)

		if(100)
			visible_message(span_warning("[src] begins to glow and vibrate. It's going to blow!"))
			addtimer(CALLBACK(src, PROC_REF(honk)), 5 SECONDS)

/obj/machinery/r_n_d/experimentor/proc/summon_mob(datum/weakref/mob_ref, mob_type)
	do_smoke(range = 1, holder = src, location = get_turf(src))
	var/mob/living/tracked_mob = mob_ref?.resolve()

	if(tracked_mob)
		do_smoke(range = 1, holder = src, location = get_turf(tracked_mob))
		tracked_mob.forceMove(loc)
		return TRUE

	new mob_type(loc)
	return FALSE

/obj/machinery/r_n_d/experimentor/proc/boom()
	explosion(src, devastation_range = 1, heavy_impact_range = 5, light_impact_range = 10, flash_range = 5, adminlog = TRUE)

/obj/machinery/r_n_d/experimentor/proc/honk()
	playsound(src, 'sound/items/bikehorn.ogg', 500)
	new /obj/item/grown/bananapeel(loc)

/obj/machinery/r_n_d/experimentor/attackby(obj/item/I, mob/user, params)
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(!is_insertion_ready(user))
		return ATTACK_CHAIN_PROCEED

	add_fingerprint(user)

	if(!I.origin_tech)
		to_chat(user, span_warning("The [I.name] has no technological origin."))
		return ATTACK_CHAIN_PROCEED

	if(clone_next)
		var/list/temp_tech = convert_req_string_to_list(I.origin_tech)
		var/techs_sum = 0
		for(var/tech_id, value in temp_tech)
			techs_sum += value

		if(HAS_TRAIT(I, TRAIT_NO_CLONE_IN_EXPERIMENTATOR) || (techs_sum > MAX_DUPE_TECH || isstorage(I)) && !istype(I, /obj/item/storage/backpack/holding))
			to_chat(user, span_warning("Этот предмет слишком сложен для копирования. Попробуйте вставить что-то попроще."))
			return ATTACK_CHAIN_PROCEED

		if(I.type in subtypesof(/obj/item/stack))
			var/obj/item/stack/stack = I
			if(stack.amount > 1)
				to_chat(user, span_warning("Предмет должен быть цельным."))
				return ATTACK_CHAIN_PROCEED

		clone_object_start()

		clone_next = FALSE

	if(!user.drop_transfer_item_to_loc(I, src))
		clone_mode = FALSE
		return ATTACK_CHAIN_PROCEED

	loaded_item = I
	to_chat(user, span_notice("You put [I] in the chamber."))
	flick("h_lathe_load", src)
	try_generate_reaction_for_item(loaded_item)
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/machinery/r_n_d/experimentor/screwdriver_act(mob/living/user, obj/item/I)
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return TRUE
	. = default_deconstruction_screwdriver(user, "h_lathe_maint", "h_lathe", I)
	if(. && linked_console)
		linked_console.linked_destroy = null
		linked_console = null

/obj/machinery/r_n_d/experimentor/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return .

	if(!panel_open)
		add_fingerprint(user)
		to_chat(user, span_warning("Open the maintenance panel first."))
		return FALSE

	item_eject()
	default_deconstruction_crowbar(user, I)

/obj/machinery/r_n_d/experimentor/multitool_act(mob/living/user, obj/item/tool)
	if(panel_open)
		experimentator_wires.Interact(user)
		return TRUE
	return FALSE

/obj/machinery/r_n_d/experimentor/wirecutter_act(mob/living/user, obj/item/tool)
	if(panel_open)
		experimentator_wires.Interact(user)
		return TRUE
	return FALSE

/obj/machinery/r_n_d/experimentor/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/r_n_d/experimentor/attack_ghost(mob/dead/observer/user)
	ui_interact(user)
	. = ..()

/obj/machinery/r_n_d/experimentor/proc/console_connect()
	var/obj/machinery/computer/rdconsole/console = locate() in oview(console_dist, src)
	if(console)
		linked_console = console

/obj/machinery/r_n_d/experimentor/proc/clone_object_start()
	visible_message("[loaded_item] has activated an unknown subroutine!")
	clone_mode = TRUE
	clone_count = malfunction_probability_coeff
	investigate_log("Experimentor has activate clone mode for [loaded_item]", INVESTIGATE_EXPERIMENTOR)

/obj/machinery/r_n_d/experimentor/proc/warn_admins(mob/user, reaction_name)
	var/turf/location = get_turf(user)
	message_admins("Experimentor reaction: [reaction_name] generated by [ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(location)]")
	log_game("Experimentor reaction: [reaction_name] generated by [key_name(user)] in [AREACOORD(location)]")
