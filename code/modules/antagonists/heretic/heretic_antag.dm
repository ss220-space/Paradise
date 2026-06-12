// Maps each heretic PATH_* to the colour its transmutation runes / UI accents are tinted with.
// MUST live in the heretic module (not __DEFINES/colors.dm): colors.dm is #included before the PATH_*
// macros are defined, so defining it there yields null keys → every rune drew the default green.
GLOBAL_LIST_INIT(heretic_path_to_color, list(
		PATH_START = COLOR_LIME,
		PATH_RUST = COLOR_CARGO_BROWN,
		PATH_FLESH = COLOR_SOFT_RED,
		PATH_ASH = COLOR_VIVID_RED,
		PATH_VOID = COLOR_CYAN,
		PATH_BLADE = COLOR_SILVER,
		PATH_COSMIC = COLOR_PURPLE,
		PATH_LOCK = COLOR_YELLOW,
		PATH_MOON = COLOR_BLUE_LIGHT,
	))

/*
 * Simple helper to generate a string of
 * garbled symbols up to [length] characters.
 *
 * Used in creating spooky-text for heretic ascension announcements.
 */
/proc/generate_heretic_text(length = 25)
	if(!isnum(length)) // stupid thing so we can use this directly in replacetext
		length = 25
	. = ""
	for(var/i in 1 to length)
		. += pick("!", "$", "^", "@", "&", "#", "*", "(", ")", "?")

/// The heretic antagonist itself.
/datum/antagonist/heretic
	name = "Еретик"
	roundend_category = "Heretics"
	job_rank = ROLE_HERETIC
	special_role = SPECIAL_ROLE_HERETIC
	antag_hud_name = "heretic"
	antag_hud_type = ANTAG_HUD_HERETIC
	wiki_page_name = "Heretic"
	russian_wiki_name = "Еретик"
	clown_gain_text = "Вы обрели знания противоречащие учениям Хонкоматери и теперь можете владеть оружием, не причиняя себе вреда."
	clown_removal_text = "По мере того, как ваши еретические знания рассеиваются, вы возвращаетесь к своему неуклюжему, клоунскому «я»."
	antag_menu_name = "Еретик"
	/// Automaticly allow to ascend
	var/force_can_ascend = FALSE
	/// Whether we've ascended! (Completed one of the final rituals)
	var/ascended = FALSE
	/// The path our heretic has chosen. Mostly used for flavor.
	var/heretic_path = PATH_START
	/// A sum of how many knowledge points this heretic CURRENTLY has. Used to research.
	var/knowledge_points = 1
	/// The time between gaining influence passively. The heretic gain +1 knowledge points every this duration of time.
	var/passive_gain_timer = 20 MINUTES
	/// Assoc list of [typepath] = [knowledge instance]. A list of all knowledge this heretic's reserached.
	var/list/researched_knowledge = list()
	/// Per-heretic DRAFT pool (TG): assoc [typepath] = metadata. Each tier offers a random pick of side
	/// knowledges (one free, picking one bans the siblings). Generated when the path is chosen.
	var/list/drafted_knowledge = list()
	/// Per-heretic SHOP pool (TG): assoc [typepath] = metadata. Buy any side knowledge for points,
	/// unlocked tier-by-tier as you research the path. Generated when the path is chosen.
	var/list/shop_knowledge_pool = list()
	/// The organ slot we place our Living Heart in.
	var/living_heart_organ_slot = INTERNAL_ORGAN_HEART
	/// A list of TOTAL how many sacrifices completed. (Includes high value sacrifices)
	var/total_sacrifices = 0
	/// A list of TOTAL how many high value sacrifices completed. (Heads of staff)
	var/high_value_sacrifices = 0
	/// Lazy assoc list of [refs to humans] to [image previews of the human]. Humans that we have as sacrifice targets.
	var/list/mob/living/carbon/human/sac_targets
	/// List of all sacrifice target's names, used for end of round report
	var/list/all_sac_targets = list()
	/// Whether we're drawing a rune or not
	var/drawing_rune = FALSE
	/// A static typecache of all tools we can scribe with.
	var/static/list/scribing_tools = typecacheof(list(/obj/item/pen, /obj/item/toy/crayon))
	/// A blacklist of turfs we cannot scribe on.
	var/static/list/blacklisted_rune_turfs = typecacheof(list(/turf/space, /turf/space/openspace, /turf/simulated/floor/lava, /turf/simulated/floor/chasm))
	/// Controls what types of turf we can spread rust to, increases as we unlock more powerful rust abilites
	var/rust_strength = 0
	/// Our current path passive ("empowerment") tier (1-3). Climbs as we gain power (pick path -> blade -> ascend).
	var/passive_level = 1
	/// The active path-passive status effect instance (see /datum/status_effect/heretic_passive).
	var/datum/status_effect/heretic_passive/passive_effect
	/// Wether we are allowed to ascend
	var/feast_of_owls = FALSE

	/// List that keeps track of which items have been gifted to the heretic after a cultist was sacrificed. Used to alter drop chances to reduce dupes.
	var/list/unlocked_heretic_items = list(
		/obj/item/melee/sickly_blade/cursed = 0,
		/obj/item/clothing/neck/heretic_focus/crimson_medallion = 0,
		/mob/living/simple_animal/hostile/construct/harvester/heretic = 0,
	)
	/// Simpler version of above used to limit amount of loot that can be hoarded
	var/rewards_given = 0

	var/list/dreams_what_you_can_see = list(
		/obj/item,
		/obj/structure,
		/obj/machinery,
	)
	var/static/list/dreams_what_you_cant_see = typecacheof(list(
		// Underfloor stuff and default wallmounts
		/obj/item/radio/intercom,
		/obj/structure/cable,
		/obj/structure/disposalpipe/segment,
		/obj/machinery/atmospherics,
		/obj/machinery/atmospherics/unary/vent_scrubber,
		/obj/machinery/atmospherics/unary/vent_pump,
		/obj/machinery/navbeacon,
		/obj/machinery/power/terminal,
		/obj/machinery/power/apc,
		/obj/machinery/light_switch,
		/obj/machinery/light,
		/obj/machinery/camera,
		/obj/machinery/door/firedoor,
		/obj/machinery/firealarm,
		/obj/machinery/alarm,
		/obj/structure/window,
		/obj/structure/grille,
		/obj/structure/sign/poster,
	))
	/// Cached list of allowed typecaches for each type in dreams_what_you_can_see
	var/static/list/dreams_allowed_typecaches_by_root_type = null


/datum/antagonist/heretic/Destroy()
	LAZYNULL(sac_targets)
	return ..()


/datum/antagonist/heretic/proc/get_icon_of_knowledge(datum/heretic_knowledge/knowledge)
	//basic icon parameters
	var/icon_path = 'icons/mob/actions/actions_ecult.dmi'
	var/icon_state = "eye"
	var/icon_frame = knowledge.research_tree_icon_frame
	var/icon_dir = knowledge.research_tree_icon_dir
	//can't imagine why you would want this one, so it can't be overridden by the knowledge
	var/icon_moving = 0

	//item transmutation knowledge does not generate its own icon due to implementation difficulties, the icons have to be specified in the override vars

	//if the knowledge has a special icon, use that
	if(!isnull(knowledge.research_tree_icon_path))
		icon_path = knowledge.research_tree_icon_path
		icon_state = knowledge.research_tree_icon_state

	//if the knowledge is a spell, use the spell's button
	else if(ispath(knowledge,/datum/heretic_knowledge/spell))
		var/datum/heretic_knowledge/spell/spell_knowledge = knowledge
		var/datum/action/result_action = spell_knowledge.spell_to_add
		icon_path = result_action.button_icon
		icon_state = result_action.button_icon_state

	//if the knowledge is a summon, use the mob sprite
	else if(ispath(knowledge,/datum/heretic_knowledge/limited_amount/summon))
		var/datum/heretic_knowledge/limited_amount/summon/summon_knowledge = knowledge
		var/mob/living/result_mob = summon_knowledge.mob_to_summon
		icon_path = result_mob.icon
		icon_state = result_mob.icon_state

	//if the knowledge is an eldritch mark, use the mark sprite
	else if(ispath(knowledge,/datum/heretic_knowledge/mark))
		var/datum/heretic_knowledge/mark/mark_knowledge = knowledge
		var/datum/status_effect/eldritch/mark_effect = mark_knowledge.mark_type
		icon_path = mark_effect.effect_icon
		icon_state = mark_effect.effect_icon_state

	var/list/result_parameters = list()
	result_parameters["icon"] = icon_path
	result_parameters["state"] = icon_state
	result_parameters["frame"] = icon_frame
	result_parameters["dir"] = icon_dir
	result_parameters["moving"] = icon_moving
	return result_parameters

// [meta] is an optional per-heretic draft/shop metadata list (cost/depth/bgr come from it instead of
// the global tree). Used to render the per-tier drafts and the tiered Knowledge Shop.
/datum/antagonist/heretic/proc/get_knowledge_data(datum/heretic_knowledge/knowledge, done, list/meta = null)

	var/list/knowledge_data = list()

	var/cost = meta ? meta[HKT_COST] : initial(knowledge.cost)
	knowledge_data["path"] = knowledge
	knowledge_data["icon_params"] = get_icon_of_knowledge(knowledge)
	knowledge_data["name"] = initial(knowledge.name)
	knowledge_data["gainFlavor"] = initial(knowledge.gain_text)
	knowledge_data["cost"] = cost
	knowledge_data["disabled"] = (!done) && (cost > knowledge_points)
	knowledge_data["bgr"] = meta ? BGR_SIDE : GLOB.heretic_research_tree[knowledge][HKT_UI_BGR]
	knowledge_data["depth"] = meta ? meta[HKT_DEPTH] : GLOB.heretic_research_tree[knowledge][HKT_DEPTH]
	knowledge_data["finished"] = done
	knowledge_data["ascension"] = ispath(knowledge,/datum/heretic_knowledge/ultimate)

	//description of a knowledge might change, make sure we are not shown the initial() value in that case
	if(done)
		var/datum/heretic_knowledge/knowledge_instance = researched_knowledge[knowledge]
		knowledge_data["desc"] = knowledge_instance.desc
	else
		knowledge_data["desc"] = initial(knowledge.desc)

	return knowledge_data


/// Appends a knowledge_data entry to the research-tree tiers list, growing it to the node's depth.
/datum/antagonist/heretic/proc/add_node_to_tiers(list/tiers, list/knowledge_data)
	var/depth = knowledge_data["depth"] || 1
	while(depth > tiers.len)
		tiers += list(list("nodes" = list()))
	tiers[depth]["nodes"] += list(knowledge_data)

/datum/antagonist/heretic/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return

	ui = new(user, src, "AntagInfoHeretic", name)
	ui.open()


/datum/antagonist/heretic/ui_data(mob/user)
	var/list/data = list()

	data["charges"] = knowledge_points
	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended

	// The Research Tree (path progression, grouped by depth) and the Knowledge Shop (route == PATH_SIDE:
	// general, non-path-locked purchases like the Codex) are shown as two separate lists in the UI.
	var/list/tiers = list()
	var/list/shop = list()

	// Path-start ("choose this path") nodes are surfaced ONLY in the Пути (Path Info) tab, never in the
	// research tree - so that picking a path happens exclusively there, matching TG. Collect their types.
	var/list/path_start_knowledges = list()
	for(var/datum/heretic_knowledge_tree_column/main/column_type as anything in subtypesof(/datum/heretic_knowledge_tree_column/main))
		if(initial(column_type.abstract_parent_type) == column_type)
			continue
		var/start_type = initial(column_type.start)
		if(start_type)
			path_start_knowledges[start_type] = TRUE

	// --- Main research-tree line (researched + researchable). Per-heretic draft/shop side nodes are
	//     handled separately below from their own metadata, so skip them here.
	for(var/datum/heretic_knowledge/knowledge as anything in researched_knowledge)
		if(drafted_knowledge[knowledge] || shop_knowledge_pool[knowledge])
			continue
		if(path_start_knowledges[knowledge])
			continue
		var/list/knowledge_data = get_knowledge_data(knowledge, TRUE)
		if(GLOB.heretic_research_tree[knowledge][HKT_ROUTE] == PATH_SIDE)
			shop += list(knowledge_data)
			continue
		add_node_to_tiers(tiers, knowledge_data)

	for(var/datum/heretic_knowledge/knowledge as anything in get_researchable_knowledge())
		if(drafted_knowledge[knowledge] || shop_knowledge_pool[knowledge])
			continue
		if(path_start_knowledges[knowledge])
			continue
		var/list/knowledge_data = get_knowledge_data(knowledge, FALSE)
		// Final knowledge can't be learned until all objectives are complete.
		if(ispath(knowledge, /datum/heretic_knowledge/ultimate))
			knowledge_data["disabled"] ||= !can_ascend()
		if(GLOB.heretic_research_tree[knowledge][HKT_ROUTE] == PATH_SIDE)
			shop += list(knowledge_data)
			continue
		add_node_to_tiers(tiers, knowledge_data)

	// --- Per-tier DRAFTS: rendered in the research tree at their draft depth (free pick, one of three).
	for(var/knowledge_type in drafted_knowledge)
		var/list/meta = drafted_knowledge[knowledge_type]
		if(researched_knowledge[knowledge_type])
			add_node_to_tiers(tiers, get_knowledge_data(knowledge_type, TRUE, meta))
		else if(is_available_draft(knowledge_type))
			add_node_to_tiers(tiers, get_knowledge_data(knowledge_type, FALSE, meta))

	// --- Knowledge SHOP: every side knowledge, grouped by shop tier ("Тир N"). A side currently offered
	//     as a free draft is shown there instead (so it isn't double-listed at a price).
	for(var/knowledge_type in shop_knowledge_pool)
		var/list/meta = shop_knowledge_pool[knowledge_type]
		if(researched_knowledge[knowledge_type])
			if(drafted_knowledge[knowledge_type])
				continue // already shown as a finished draft in the tree
			shop += list(get_knowledge_data(knowledge_type, TRUE, meta))
		else if(is_available_shop(knowledge_type) && !is_available_draft(knowledge_type))
			shop += list(get_knowledge_data(knowledge_type, FALSE, meta))

	data["knowledge_tiers"] = tiers
	data["knowledge_shop"] = shop

	// Our current path-passive ("empowerment") tier. The per-path passive text is sent with each path below.
	data["passive_level"] = passive_level

	// Path Info tab: one entry per main path with its playstyle blurb and its "choose path" start node.
	// NOTE: initial() returns null for /list vars in BYOND, so we instantiate each column to read its
	// description/pros/cons/tips lists, then discard it (columns are lightweight, transient datums).
	var/list/paths_data = list()
	for(var/column_type in subtypesof(/datum/heretic_knowledge_tree_column/main))
		var/datum/heretic_knowledge_tree_column/main/column = column_type
		if(initial(column.abstract_parent_type) == column_type)
			continue
		if(!initial(column.start))
			continue
		var/datum/heretic_knowledge_tree_column/main/column_instance = new column_type()
		var/datum/heretic_knowledge/start_knowledge = column_instance.start
		var/list/path_entry = list()
		path_entry["route"] = column_instance.route
		path_entry["complexity"] = column_instance.complexity
		path_entry["complexity_color"] = column_instance.complexity_color
		path_entry["description"] = column_instance.path_description
		path_entry["pros"] = column_instance.path_pros
		path_entry["cons"] = column_instance.path_cons
		path_entry["tips"] = column_instance.path_tips
		if(column_instance.passive_name)
			path_entry["passive"] = list(
				"name" = column_instance.passive_name,
				"description" = column_instance.passive_descriptions,
			)
		path_entry["starting_knowledge"] = get_knowledge_data(start_knowledge, (start_knowledge in researched_knowledge))

		// "Guaranteed Abilities" preview (TG's preview_abilities): the path's guaranteed main-line
		// knowledges in unlock order, minus the "choose path" start node and the big ascension node.
		// Slots are optional (TG-style paths fold grasp/mark into start) and tiers may be lists.
		var/list/preview_abilities = list()
		var/list/preview_slots
		if(column_instance.knowledge_tier1) // TG-format column (e.g. Ash)
			preview_slots = list(
				column_instance.knowledge_tier1,
				column_instance.knowledge_tier2,
				column_instance.robes,
				column_instance.knowledge_tier3,
				column_instance.blade,
				column_instance.knowledge_tier4,
			)
		else // legacy column
			preview_slots = list(
				column_instance.grasp,
				column_instance.tier1,
				column_instance.mark,
				column_instance.ritual_of_knowledge,
				column_instance.unique_ability,
				column_instance.tier2,
				column_instance.blade,
				column_instance.tier3,
			)
		for(var/slot in preview_slots)
			if(!slot)
				continue
			if(islist(slot))
				for(var/sub_knowledge in slot)
					preview_abilities += list(get_knowledge_data(sub_knowledge, (sub_knowledge in researched_knowledge)))
			else
				preview_abilities += list(get_knowledge_data(slot, (slot in researched_knowledge)))
		path_entry["preview_abilities"] = preview_abilities

		paths_data += list(path_entry)
		qdel(column_instance)

	data["paths"] = paths_data

	return data

/datum/antagonist/heretic/ui_static_data(mob/user)
	var/list/data = list()

	data["objectives"] = user.mind.get_all_objectives()
	data["can_change_objective"] = FALSE // can_assign_self_objectives

	return data

/datum/antagonist/heretic/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("research")
			var/datum/heretic_knowledge/researched_path = text2path(params["path"])
			if(!ispath(researched_path, /datum/heretic_knowledge))
				CRASH("Heretic attempted to learn non-heretic_knowledge path! (Got: [researched_path || "invalid path"])")
			if(!(researched_path in get_researchable_knowledge()))
				message_admins("Heretic [key_name(owner)] potentially attempted to href exploit to learn knowledge they can't learn!")
				CRASH("Heretic attempted to learn knowledge they can't learn! (Got: [researched_path])")
			if(ispath(researched_path, /datum/heretic_knowledge/ultimate) && !can_ascend(TRUE))
				message_admins("Heretic [key_name(owner)] potentially attempted to href exploit to learn ascension knowledge without completing objectives!")
				CRASH("Heretic attempted to learn a final knowledge despite not being able to ascend!")
			// Effective cost: free if offered as an available draft pick, else the shop/initial cost.
			var/research_cost = get_research_cost(researched_path)
			if(research_cost > knowledge_points)
				return TRUE
			if(!gain_knowledge(researched_path))
				return TRUE

			log_game("[key_name(owner)] gained knowledge: [initial(researched_path.name)]")
			knowledge_points -= research_cost
			return TRUE


/datum/antagonist/heretic/ui_status(mob/user, datum/ui_state/state)
	if(user.stat == DEAD)
		return UI_CLOSE

	return UI_INTERACTIVE //..()


/datum/antagonist/heretic/farewell()
	if(silent)
		return ..()

	to_chat(owner.current, span_userdanger("Ваш разум будто горит, когда потусторонние знания начинают ускользать!"))
	return ..()


/datum/antagonist/heretic/greet()
	. = ..()
	SEND_SOUND(owner.current, sound('sound/music/heretic/heretic_gain.ogg'))


/datum/antagonist/heretic/on_gain()
	SSticker.mode.heretics |= owner
	if(!GLOB.heretic_research_tree)
		GLOB.heretic_research_tree = generate_heretic_research_tree()

	if(give_objectives)
		forge_primary_objectives()

	for(var/starting_knowledge in GLOB.heretic_start_knowledge)
		gain_knowledge(starting_knowledge)

	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer) // Gain +1 knowledge every 20 minutes.
	RegisterSignal(owner.current, COMSIG_GET_DREAMS, PROC_REF(get_dreams))
	ADD_TRAIT(owner, TRAIT_BAD_SOUL, HERETIC_TRAIT)
	return ..()


// master220 calls this final-removal hook from /datum/antagonist/Destroy (was on_removal() in the tg/selfharm source).
/datum/antagonist/heretic/handle_last_instance_removal()
	// (removed a stray `SSticker.mode.changelings -= owner` line from the source — copy-paste bug from
	//  changeling; heretics aren't tracked in that list and master220's remove_owner_from_gamemode() handles it.)
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(owner.current, src)

	QDEL_LIST_ASSOC_VAL(researched_knowledge)
	UnregisterSignal(owner.current, COMSIG_GET_DREAMS)
	return ..()


/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	our_mob.faction |= FACTION_HERETIC

	if(!issilicon(our_mob))
		GLOB.reality_smash_track.add_tracked_mind(owner)

	ADD_TRAIT(our_mob, TRAIT_MANSUS_TOUCHED, UID())
	RegisterSignal(our_mob, COMSIG_LIVING_CULT_SACRIFICED, PROC_REF(on_cult_sacrificed))
	RegisterSignals(our_mob, list(COMSIG_MOB_BEFORE_SPELL_CAST, COMSIG_MOB_SPELL_ACTIVATED), PROC_REF(on_spell_cast))
	RegisterSignal(our_mob, COMSIG_MOB_ITEM_AFTERATTACK, PROC_REF(on_item_use))

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	our_mob.faction -= FACTION_HERETIC

	if(owner in GLOB.reality_smash_track.tracked_heretics)
		GLOB.reality_smash_track.remove_tracked_mind(owner)

	REMOVE_TRAIT(our_mob, TRAIT_MANSUS_TOUCHED, UID())
	UnregisterSignal(our_mob, list(
		COMSIG_MOB_BEFORE_SPELL_CAST,
		COMSIG_MOB_SPELL_ACTIVATED,
		COMSIG_MOB_ITEM_AFTERATTACK,
		COMSIG_LIVING_CULT_SACRIFICED,
	))


/datum/antagonist/heretic/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	if(old_body == new_body) // if they were using a temporary body
		return

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(old_body, src, TRUE)
		knowledge.on_gain(new_body, src, TRUE)

/*
 * Signal proc for [COMSIG_MOB_BEFORE_SPELL_CAST] and [COMSIG_MOB_SPELL_ACTIVATED].
 *
 * Checks if our heretic has [TRAIT_ALLOW_HERETIC_CASTING] or is ascended.
 * If so, allow them to cast like normal.
 * If not, cancel the cast, and returns [SPELL_CANCEL_CAST].
 */
/datum/antagonist/heretic/proc/on_spell_cast(mob/living/source, obj/effect/proc_holder/spell/spell)
	SIGNAL_HANDLER

	// Heretic spells are of the forbidden school, otherwise we don't care
	if(spell.school != SCHOOL_FORBIDDEN)
		return

	// If we've got the trait, we don't care
	if(HAS_TRAIT(source, TRAIT_ALLOW_HERETIC_CASTING))
		return

	// All powerful, don't care
	if(ascended)
		return

	// We shouldn't be able to cast this! Cancel it.
	source.balloon_alert(source, "нужен амулет")
	return SPELL_CANCEL_CAST

/*
 * Signal proc for [COMSIG_MOB_ITEM_AFTERATTACK].
 *
 * If a heretic is holding a pen in their main hand,
 * and have mansus grasp active in their offhand,
 * they're able to draw a transmutation rune.
 */
/datum/antagonist/heretic/proc/on_item_use(mob/living/source, atom/target, obj/item/weapon, proximity, params, status)
	SIGNAL_HANDLER
	if(!proximity)
		return NONE

	if(!is_type_in_typecache(weapon, scribing_tools))
		return NONE

	if(!isturf(target) || !isliving(source))
		return NONE

	var/obj/item/offhand = source.get_inactive_hand()
	if(QDELETED(offhand) || !istype(offhand, /obj/item/melee/touch_attack/mansus_fist))
		return NONE

	try_draw_rune(source, target, additional_checks = CALLBACK(src, PROC_REF(check_mansus_grasp_offhand), source))
	return COMPONENT_AFTERATTACK_STOP

/**
 * Attempt to draw a rune on [target_turf].
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 * * drawing_time - how long the do_after takes to make the rune
 * * additional checks - optional callbacks to be ran while drawing the rune
 */
/datum/antagonist/heretic/proc/try_draw_rune(mob/living/user, turf/target_turf, drawing_time = 20 SECONDS, additional_checks)
	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, target_turf))
		if(!iswallturf(nearby_turf) && !is_type_in_typecache(nearby_turf, blacklisted_rune_turfs))
			continue

		target_turf.balloon_alert(user, "не подходящее место!")
		return

	if(locate(/obj/effect/decal/heretic_rune) in range(3, target_turf))
		target_turf.balloon_alert(user, "другая руна рядом!")
		return

	if(drawing_rune)
		target_turf.balloon_alert(user, "уже чертите")
		return

	INVOKE_ASYNC(src, PROC_REF(draw_rune), user, target_turf, drawing_time, additional_checks)

/**
 * The actual process of drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 * * drawing_time - how long the do_after takes to make the rune
 * * additional checks - optional callbacks to be ran while drawing the rune
 */
/datum/antagonist/heretic/proc/draw_rune(mob/living/user, turf/target_turf, drawing_time = 20 SECONDS, additional_checks)
	drawing_rune = TRUE

	var/rune_colour = GLOB.heretic_path_to_color[heretic_path]
	target_turf.balloon_alert(user, "черчение руны...")
	var/obj/effect/temp_visual/drawing_heretic_rune/drawing_effect
	if(drawing_time < (10 SECONDS))
		drawing_effect = new /obj/effect/temp_visual/drawing_heretic_rune/fast(target_turf, rune_colour)
	else
		drawing_effect = new(target_turf, rune_colour)

	if(!do_after(user, drawing_time, target_turf, extra_checks = additional_checks))
		target_turf.balloon_alert(user, "прервано!")
		new /obj/effect/temp_visual/drawing_heretic_rune/fail(target_turf, rune_colour)
		qdel(drawing_effect)
		drawing_rune = FALSE
		return

	qdel(drawing_effect)
	target_turf.balloon_alert(user, "руна создана")
	new /obj/effect/decal/heretic_rune/big(target_turf, rune_colour)
	drawing_rune = FALSE

/**
 * Callback to check that the user's still got their Прикосновение Мансуса out when drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 */
/datum/antagonist/heretic/proc/check_mansus_grasp_offhand(mob/living/user)
	var/obj/item/offhand = user.get_inactive_hand()
	return !QDELETED(offhand) && istype(offhand, /obj/item/melee/touch_attack/mansus_fist)

/// Signal proc for [COMSIG_LIVING_CULT_SACRIFICED] to reward cultists for sacrificing a heretic
/datum/antagonist/heretic/proc/on_cult_sacrificed(mob/living/source, list/invokers)
	SIGNAL_HANDLER

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list) // uhh let's find the guy to shove him back in
		if((ghost.mind?.current == source) && ghost.client) // is it the same guy and do they have the same client
			ghost.reenter_corpse() // shove them in! it doesnt do it automatically

	// Drop all items and splatter them around messily.
	var/list/dustee_items = source.unequip_everything()
	for(var/obj/item/loot as anything in dustee_items)
		loot.throw_at(get_step_rand(source), 2, 4, pick(invokers), TRUE)

	// Create the blade, give it the heretic and a randomly-chosen master for the soul sword component
	var/obj/item/melee/cultblade/haunted/haunted_blade = new(get_turf(source), source, pick(invokers))

	// Cool effect for the rune as well as the item
	var/obj/effect/rune/convert/conversion_rune = locate() in get_turf(source)
	if(conversion_rune)
		conversion_rune.gender_reveal(
			outline_color = COLOR_HERETIC_GREEN,
			ray_color = null,
			do_float = FALSE,
			do_layer = FALSE,
		)

	haunted_blade.gender_reveal(outline_color = null, ray_color = COLOR_HERETIC_GREEN)

	for(var/mob/living/culto as anything in invokers)
		to_chat(culto, span_cultlarge("\"Последователь забытых богов! Ты должен быть вознагражден за столь ценную жертву.\""))
/*
	// Locate a cultist team (Is there a better way??)
	var/mob/living/random_cultist = pick(invokers)
	// Unlock one of 3 special items!
	var/list/possible_unlocks
	for(var/i in cult_team.unlocked_heretic_items)
		if(cult_team.unlocked_heretic_items[i])
			continue

		LAZYADD(possible_unlocks, i)

	if(!length(possible_unlocks))
		return SILENCE_SACRIFICE_MESSAGE|DUST_SACRIFICE

	var/result = pick(possible_unlocks)
	cult_team.unlocked_heretic_items[result] = TRUE

	for(var/datum/mind/mind as anything in SSticker.mode.cult)
		if(!mind.current)
			continue

		SEND_SOUND(mind.current, 'sound/magic/clockwork/narsie_attack.ogg')
		to_chat(mind.current, span_cultlarge(span_warning("Тайные и запретные знания заполонили ваши кузницы и архивы. Культ научился создавать ")) + span_cultlarge(span_purple("[result]!")))
*/
	return SILENCE_SACRIFICE_MESSAGE|DUST_SACRIFICE

/**
 * Creates an animation of the item slowly lifting up from the floor with a colored outline, then slowly drifting back down.
 * Arguments:
 * * outline_color: Default is between pink and light blue, is the color of the outline filter.
 * * ray_color: Null by default. If not set, just copies outline. Used for the ray filter.
 * * anim_time: Total time of the animation. Split into two different calls.
 * * do_float: Lets you disable the sprite floating up and down.
 * * do_layer: Lets you disable the layering increase.
 */
/obj/proc/gender_reveal(
	outline_color = null,
	ray_color = null,
	anim_time = 10 SECONDS,
	do_float = TRUE,
	do_layer = TRUE,
)

	var/og_layer
	if(do_layer)
		// Layering above to stand out!
		og_layer = layer
		layer = ABOVE_MOB_LAYER

	// Slowly floats up, then slowly goes down.
	if(do_float)
		animate(src, pixel_y = 12, time = anim_time * 0.5, easing = QUAD_EASING | EASE_OUT)
		animate(pixel_y = 0, time = anim_time * 0.5, easing = QUAD_EASING | EASE_IN)

	// Adding a cool outline effect
	if(outline_color)
		add_filter("gender_reveal_outline", 3, list("type" = "outline", "color" = outline_color, "size" = 0.5))
		// Animating it!
		var/gay_filter = get_filter("gender_reveal_outline")
		animate(gay_filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
		animate(alpha = 40, time = 2.5 SECONDS)

	// Adding a cool ray effect
	if(ray_color)
		add_filter(name = "gender_reveal_ray", priority = 1, params = list(
				type = "rays",
				size = 45,
				color = ray_color,
				density = 6
			))
		// Animating it!
		var/ray_filter = get_filter("gender_reveal_ray")
		// I understand nothing but copypaste saves lives
		animate(ray_filter, offset = 100, time = 30 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(src, PROC_REF(remove_gender_reveal_fx), og_layer), anim_time)

/**
 * Removes the non-animate effects from above proc
 */
/obj/proc/remove_gender_reveal_fx(og_layer)
	remove_filter(list("gender_reveal_outline", "gender_reveal_ray"))
	layer = og_layer

/**
 * Create our objectives for our heretic.
 */
/datum/antagonist/heretic/proc/forge_primary_objectives()
	var/datum/objective/heretic_research/research_objective = new()
	research_objective.owner = owner
	objectives += research_objective

	var/num_heads = 0
	for(var/mob/player in GLOB.alive_player_list)
		if(!(player.mind.assigned_role in GLOB.command_positions))
			continue

		num_heads++

	var/datum/objective/heretic_sacrifice/sac_objective = new()
	sac_objective.owner = owner
	if(num_heads < 2) // They won't get major sacrifice, so bump up minor sacrifice a bit
		sac_objective.target_amount += 2
		sac_objective.update_explanation_text()

	objectives += sac_objective

/**
 * Add [target] as a sacrifice target for the heretic.
 * Generates a preview image and associates it with a weakref of the mob.
 */
/datum/antagonist/heretic/proc/add_sacrifice_target(mob/living/carbon/human/target)
	// Guard against re-adding an existing target (e.g. an admin picking someone already on the list):
	// a second RegisterSignal on the same COMSIG_QDELETING would runtime.
	if(target in sac_targets)
		return

	var/image/target_image = image(icon = target.icon, icon_state = target.icon_state)
	target_image.overlays = target.overlays

	LAZYSET(sac_targets, target, target_image)
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_deleted))
	all_sac_targets += target.real_name

/**
 * Removes [target] from the heretic's sacrifice list.
 * Returns FALSE if no one was removed, TRUE otherwise
 */
/datum/antagonist/heretic/proc/remove_sacrifice_target(mob/living/carbon/human/target)
	if(!(target in sac_targets))
		return FALSE

	LAZYREMOVE(sac_targets, target)
	UnregisterSignal(target, COMSIG_QDELETING)
	return TRUE

/**
 * Signal proc for [COMSIG_QDELETING] registered on sac targets
 * if sacrifice targets are deleted (gibbed, dusted, whatever), free their slot and reference
 */
/datum/antagonist/heretic/proc/on_target_deleted(mob/living/carbon/human/source)
	SIGNAL_HANDLER

	remove_sacrifice_target(source)

/**
 * Increments knowledge by one.
 * Used in callbacks for passive gain over time.
 */
/datum/antagonist/heretic/proc/passive_influence_gain()
	knowledge_points++
	var/mob/living/carbon/human/human = owner.current
	if(QDELETED(owner?.current))
		return

	if(human.IsSleeping())
		to_chat(owner.current, "[span_hear("Вы слышите шепот...")] [span_purple(pick_list(HERETIC_INFLUENCE_FILE, "drain_message"))]")

	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer)

/datum/antagonist/heretic/roundend_report()
	var/list/parts = list()

	var/succeeded = TRUE

	parts += printplayer(owner)
	parts += "<b>Принесенные жертвы:</b> [total_sacrifices]"
	parts += "Целями жертвоприношений еретика были: [english_list(all_sac_targets, nothing_text = "-")]."
	if(length(objectives))
		var/count = 1
		for(var/datum/objective/objective as anything in objectives)
			if(!objective.check_completion())
				succeeded = FALSE

			parts += "<b>Цель #[count]</b>: [objective.explanation_text] [span_greentext("Успех!")]"
			count++

	if(feast_of_owls)
		parts += span_greentext("Отрекшиеся Вознеслись")

	if(ascended)
		parts += span_greentext(span_big("ЕРЕТИК ВОЗНЕССЯ!"))

	else
		if(succeeded)
			parts += span_greentext("Еретик выполнил цели, но не вознесся!")
		else
			parts += span_redtext("Еретик провалился.")

	parts += "<b>Изученные Знания:</b> "

	var/list/string_of_knowledge = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		string_of_knowledge += knowledge.name

	parts += english_list(string_of_knowledge)

	return parts.Join("<br>")
/*
/datum/antagonist/heretic/get_admin_commands()
	. = ..()

	switch(has_living_heart())
		if(HERETIC_NO_LIVING_HEART)
			.["Give Living Heart"] = CALLBACK(src, PROC_REF(give_living_heart))
		if(HERETIC_HAS_LIVING_HEART)
			.["Add Heart Target (Marked Mob)"] = CALLBACK(src, PROC_REF(add_marked_as_target))
			.["Remove Heart Target"] = CALLBACK(src, PROC_REF(remove_target))

	.["Adjust Knowledge Points"] = CALLBACK(src, PROC_REF(admin_change_points))
	.["Give Focus"] = CALLBACK(src, PROC_REF(admin_give_focus))
*/
/**
 * Admin proc for giving a heretic a Living Heart easily.
 */
/datum/antagonist/heretic/proc/give_living_heart(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Вам не следует это использовать!"))
		return

	var/datum/heretic_knowledge/living_heart/heart_knowledge = get_knowledge(/datum/heretic_knowledge/living_heart)
	if(!heart_knowledge)
		to_chat(admin, span_warning("У еретика почему-то нет знания о Живом сердце. Какого черта?"))
		return

	heart_knowledge.on_research(owner.current, src)

/**
 * Admin proc for adding a marked mob to a heretic's sac list.
 */
/datum/antagonist/heretic/proc/add_marked_as_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Вам не следует это использовать!"))
		return

	var/mob/living/carbon/human/new_target = admin.client?.holder.marked_datum
	if(!istype(new_target))
		to_chat(admin, span_warning("Вы должны быть гуманойдом!"))
		return

	if(tgui_alert(admin, "Сообщать им, что цели были обновлены?", "Шепот Мансуса", list("Да", "Нет")) == "Да")
		to_chat(owner.current, span_danger("Мансус изменил следующую жертву. Иди и найди её!"))
		to_chat(owner.current, span_danger("[new_target.real_name], the [new_target.mind?.assigned_role || "human"]."))

	add_sacrifice_target(new_target)

/**
 * Admin proc for removing a mob from a heretic's sac list.
 */
/datum/antagonist/heretic/proc/remove_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Вы не должны это использовать!"))
		return

	var/list/removable = list()
	for(var/mob/living/carbon/human/old_target as anything in sac_targets)
		removable[old_target.name] = old_target

	var/name_of_removed = tgui_input_list(admin, "Выберите цель которую хотите удалить.", "Кого пощадить", removable)
	if(QDELETED(src) || !admin.client?.holder || isnull(name_of_removed))
		return

	var/mob/living/carbon/human/chosen_target = removable[name_of_removed]
	if(QDELETED(chosen_target) || !ishuman(chosen_target))
		return

	if(!remove_sacrifice_target(chosen_target))
		to_chat(admin, span_warning("Не получилось удалить [name_of_removed] из списка целей [owner]. Возможно [name_of_removed] уже не в списке."))
		return

	if(tgui_alert(admin, "Сообщать им, что цели были обновлены?", "Шепот Мансуса", list("Да", "Нет")) == "Да")
		to_chat(owner.current, span_danger("Мансус изменил ваши задачи."))

/**
 * Admin proc for easily adding / removing knowledge points.
 */
/datum/antagonist/heretic/proc/admin_change_points(admin)
	var/change_num = tgui_input_number(admin, "Добавить или забрать очки знаний", "Очки", 0, 100, -100)
	if(!change_num || QDELETED(src))
		return

	knowledge_points += change_num


/**
 * Admin proc for easily adding new sac target.
 */
/datum/antagonist/heretic/proc/add_sac_target(admin)
	var/list/targets = list()
	for(var/client/client as anything in GLOB.clients)
		var/mob/mob = client.mob
		if(!ishuman(mob))
			continue

		targets[mob.real_name] = mob

	var/target = tgui_input_list(admin, "Выберите новую жертву.", "Добавление жертвы", targets)
	if(!target)
		return

	if(!ishuman(targets[target]))
		to_chat(admin, span_notice("Выбранная цель больше не человек."))
		return

	add_sacrifice_target(targets[target])

/**
 * Admin proc for giving a heretic a focus.
 */
/datum/antagonist/heretic/proc/admin_give_focus(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Вы не должны это использовать!"))
		return

	var/mob/living/pawn = owner.current
	pawn.equip_to_slot_if_possible(new /obj/item/clothing/neck/heretic_focus(get_turf(pawn)), ITEM_SLOT_NECK, TRUE, TRUE)
	to_chat(pawn, span_purple("Мансус даровал вам способность колдовать без амулетов."))


/datum/antagonist/heretic/roundend_report()
	var/list/string_of_knowledge = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		if(istype(knowledge, /datum/heretic_knowledge/ultimate))
			string_of_knowledge += span_bold(knowledge.name)
			continue

		string_of_knowledge += knowledge.name

	return "<br><b>Обретенные знания:</b><br>[english_list(string_of_knowledge, and_text = " и ")]<br>"
/*
/datum/antagonist/heretic/antag_panel_objectives()
	. = ..()
	if(!LAZYLEN(sac_targets))
		. += "<br><i><b>Нет целей!</b></i><br><br>"
		return .

	. += "<br>"
	. += "<i><b>Текущие цели:</b></i><br>"
	for(var/mob/living/carbon/human/target as anything in sac_targets)
		. += " - <b>[target.real_name]</b> - [target.mind?.assigned_role || "обычный гуманоид"].<br>"

	. += "<br>"
*/
/**
 * Learns the passed [typepath] of knowledge, creating a knowledge datum
 * and adding it to our researched knowledge list.
 *
 * Returns TRUE if the knowledge was added successfully. FALSE otherwise.
 */
/datum/antagonist/heretic/proc/gain_knowledge(datum/heretic_knowledge/knowledge_type)
	if(!ispath(knowledge_type))
		stack_trace("[type] gain_knowledge was given an invalid path! (Got: [knowledge_type])")
		return FALSE

	if(get_knowledge(knowledge_type))
		return FALSE

	var/datum/heretic_knowledge/initialized_knowledge = new knowledge_type()
	researched_knowledge[knowledge_type] = initialized_knowledge
	initialized_knowledge.on_research(owner.current, src)
	update_static_data(owner.current)
	return TRUE

/**
 * Get a list of all knowledge TYPEPATHS that we can currently research.
 */
/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		// Side knowledges that belong to our per-heretic draft/shop pool (TG-format paths) are governed by
		// that engine, NOT the legacy tree-bridge. Following their legacy HKT_NEXT would leak an adjacent
		// path's tier ability into our tree out of order, so don't expand it.
		if(!drafted_knowledge[knowledge_index] && !shop_knowledge_pool[knowledge_index])
			researchable_knowledge |= GLOB.heretic_research_tree[knowledge_index][HKT_NEXT]
		banned_knowledge |= GLOB.heretic_research_tree[knowledge_index][HKT_BAN]
		banned_knowledge |= knowledge.type

	researchable_knowledge -= banned_knowledge

	// Per-heretic drafts (free pick) + shop (paid) available once their parent tier knowledge is researched.
	for(var/knowledge_type in drafted_knowledge)
		if(is_available_draft(knowledge_type))
			researchable_knowledge |= knowledge_type
	for(var/knowledge_type in shop_knowledge_pool)
		if(is_available_shop(knowledge_type))
			researchable_knowledge |= knowledge_type

	// Defensive: a malformed HKT_NEXT entry (e.g. a null bridged in from a TG-format neighbour column)
	// must never reach ui_data/get_knowledge_data, or the whole research menu fails to open.
	list_clear_nulls(researchable_knowledge)
	return researchable_knowledge

/**
 * Check if the wanted type-path is in the list of research knowledge.
 */
/datum/antagonist/heretic/proc/get_knowledge(wanted)
	return researched_knowledge[wanted]

/// Returns a freshly instantiated tree column datum for the given route (caller must qdel), or null.
/datum/antagonist/heretic/proc/get_path_column(route)
	for(var/datum/heretic_knowledge_tree_column/main/column_type as anything in subtypesof(/datum/heretic_knowledge_tree_column/main))
		if(initial(column_type.abstract_parent_type) == column_type)
			continue
		var/datum/heretic_knowledge_tree_column/main/column = new column_type()
		if(column.route == route)
			return column
		qdel(column)
	return null

/**
 * Generates this heretic's per-tier DRAFTS and the tiered SHOP for their chosen TG-format path (TG 1:1).
 * Each draft tier offers up to 3 side knowledges (one guaranteed) - picking one is FREE and bans the
 * siblings. The shop lets you BUY any side knowledge for points, unlocked tier-by-tier as you research.
 */
/datum/antagonist/heretic/proc/generate_path_drafts()
	drafted_knowledge = list()
	shop_knowledge_pool = list()

	var/datum/heretic_knowledge_tree_column/main/column = get_path_column(heretic_path)
	if(!column)
		return
	if(!column.knowledge_tier1) // only TG-format paths use the draft/shop engine (legacy paths keep their own)
		qdel(column)
		return

	var/t1 = column.knowledge_tier1
	var/t2 = column.knowledge_tier2
	var/t3 = column.knowledge_tier3
	var/t4 = column.knowledge_tier4
	var/list/guaranteed = list(column.guaranteed_side_tier1, column.guaranteed_side_tier2, column.guaranteed_side_tier3)
	var/list/shop_unlock = list(t1, t2, column.robes, t3, t4)

	var/list/shop_costs = list(1, 2, 2, 2, 3)
	if(column.shop_cost_discount)
		for(var/i in 1 to length(shop_costs))
			shop_costs[i] = max(1, shop_costs[i] - column.shop_cost_discount)

	// Knowledges already on the main line / guaranteed can't be drafted again.
	var/list/draft_ineligible = list(t1, t2, t3, t4) + guaranteed

	// Bucket the whole side pool by drafting_tier: elligible = draftable, shop_pool = everything (incl shop-only).
	var/list/elligible = list()
	var/list/shop_pool = list()
	for(var/tier in 1 to HERETIC_DRAFT_TIER_MAX)
		elligible += list(list())
		shop_pool += list(list())
	for(var/datum/heretic_knowledge/potential as anything in subtypesof(/datum/heretic_knowledge))
		var/draft_tier = initial(potential.drafting_tier)
		if(draft_tier <= 0)
			continue
		if(potential in draft_ineligible)
			continue
		if(!initial(potential.is_shop_only))
			elligible[draft_tier] += potential
		shop_pool[draft_tier] += potential

	// Per-tier draft groups (parent = the tier knowledge that reveals the draft row).
	var/list/draft_specs = list(
		list("parent" = t1, "guaranteed" = guaranteed[1], "weights" = list("1"=50, "2"=50, "3"=0, "4"=0, "5"=0), "depth" = HKT_DEPTH_DRAFT_1),
		list("parent" = t2, "guaranteed" = guaranteed[2], "weights" = list("1"=50, "2"=25, "3"=25, "4"=0, "5"=0), "depth" = HKT_DEPTH_DRAFT_2),
		list("parent" = t3, "guaranteed" = guaranteed[3], "weights" = list("1"=20, "2"=20, "3"=20, "4"=20, "5"=20), "depth" = HKT_DEPTH_DRAFT_3),
		list("parent" = t4, "guaranteed" = null, "weights" = list("1"=0, "2"=0, "3"=0, "4"=0, "5"=100), "depth" = HKT_DEPTH_DRAFT_4),
	)
	for(var/list/spec in draft_specs)
		var/list/group = list()
		for(var/cycle in 1 to 3)
			var/datum/heretic_knowledge/picked
			if(spec["guaranteed"] && cycle == 1)
				picked = spec["guaranteed"]
			else
				var/chosen_tier = min(text2num(pickweight(spec["weights"])), length(elligible))
				if(chosen_tier < 1 || !length(elligible[chosen_tier]))
					continue
				picked = pick_n_take(elligible[chosen_tier])
			if(isnull(picked) || (picked in group))
				continue
			group += picked
			drafted_knowledge[picked] = list(
				HKT_PARENT = spec["parent"],
				HKT_DEPTH = spec["depth"],
				HKT_DRAFT_TIER = initial(picked.drafting_tier),
				HKT_COST = 0,
				HKT_BAN = list(),
			)
		for(var/sibling in group)
			drafted_knowledge[sibling][HKT_BAN] = group - sibling

	// Shop: every side knowledge, buyable for points, unlocked by the tier node above it.
	for(var/tier in 1 to length(shop_pool))
		for(var/knowledge_type in shop_pool[tier])
			shop_knowledge_pool[knowledge_type] = list(
				HKT_PARENT = shop_unlock[tier],
				HKT_DEPTH = tier, // shop "Тир N" label
				HKT_DRAFT_TIER = tier,
				HKT_COST = shop_costs[tier],
				HKT_BAN = list(),
			)
	// rifle -> rifle_ammo follow-on inside the shop.
	if(shop_knowledge_pool[/datum/heretic_knowledge/rifle])
		shop_knowledge_pool[/datum/heretic_knowledge/rifle_ammo] = list(
			HKT_PARENT = /datum/heretic_knowledge/rifle,
			HKT_DEPTH = 2,
			HKT_DRAFT_TIER = 2,
			HKT_COST = 1,
			HKT_BAN = list(),
		)

	qdel(column)

/// Whether a side knowledge is currently offered as an available (free) draft pick.
/datum/antagonist/heretic/proc/is_available_draft(datum/heretic_knowledge/knowledge_type)
	var/list/meta = drafted_knowledge[knowledge_type]
	if(!meta)
		return FALSE
	if(researched_knowledge[knowledge_type])
		return FALSE
	if(meta[HKT_PARENT] && !researched_knowledge[meta[HKT_PARENT]])
		return FALSE
	for(var/sibling in meta[HKT_BAN])
		if(researched_knowledge[sibling])
			return FALSE
	return TRUE

/// Whether a shop side knowledge is currently purchasable (its parent tier is researched).
/datum/antagonist/heretic/proc/is_available_shop(datum/heretic_knowledge/knowledge_type)
	var/list/meta = shop_knowledge_pool[knowledge_type]
	if(!meta)
		return FALSE
	if(researched_knowledge[knowledge_type])
		return FALSE
	if(meta[HKT_PARENT] && !researched_knowledge[meta[HKT_PARENT]])
		return FALSE
	return TRUE

/// The effective point cost to research a knowledge right now (free if an available draft, else shop/initial cost).
/datum/antagonist/heretic/proc/get_research_cost(datum/heretic_knowledge/knowledge_type)
	if(is_available_draft(knowledge_type))
		return 0
	var/list/shop_meta = shop_knowledge_pool[knowledge_type]
	if(shop_meta)
		return shop_meta[HKT_COST]
	return initial(knowledge_type.cost)

/// Makes our heretic more able to rust things.
/// if side_path_only is set to TRUE, this function does nothing for rust heretics.
/datum/antagonist/heretic/proc/increase_rust_strength(side_path_only=FALSE)
	if(side_path_only && get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_rust))
		return

	rust_strength++

/// Grants (or re-grants, e.g. after a body transfer) our path's passive effect of the given type.
/// The effect catches itself up to our current [passive_level] on apply.
/datum/antagonist/heretic/proc/grant_passive(passive_type)
	if(!ispath(passive_type, /datum/status_effect/heretic_passive) || !owner?.current)
		return
	if(passive_effect && passive_effect.type == passive_type)
		return
	clear_passive()
	passive_effect = owner.current.apply_status_effect(passive_type)

/// Removes our current passive effect, if any (used on body transfer / antag removal).
/datum/antagonist/heretic/proc/clear_passive()
	if(passive_effect)
		qdel(passive_effect)
		passive_effect = null

/// Advances our passive to a higher tier (2 = blade upgrade, 3 = ascension) and refreshes the UI.
/datum/antagonist/heretic/proc/set_passive_level(new_level)
	if(new_level <= passive_level)
		return
	passive_level = new_level
	if(passive_effect)
		if(new_level >= 2)
			passive_effect.level_upgrade()
		if(new_level >= 3)
			passive_effect.level_final()
	if(owner?.current)
		update_static_data(owner.current)

/**
 * Get a list of all rituals this heretic can invoke on a rune.
 * Iterates over all of our knowledge and, if we can invoke it, adds it to our list.
 *
 * Returns an associated list of [knowledge name] to [knowledge datum] sorted by knowledge priority.
 */
/datum/antagonist/heretic/proc/get_rituals()
	var/list/rituals = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		if(!knowledge.can_be_invoked(src))
			continue

		rituals[knowledge.name] = knowledge

	return sortTim(rituals, GLOBAL_PROC_REF(cmp_heretic_knowledge), associative = TRUE)

/**
 * Checks to see if our heretic can ccurrently ascend.
 *
 * Returns FALSE if not all of our objectives are complete, or TRUE otherwise.
 */
/datum/antagonist/heretic/proc/can_ascend(say_result)
	var/mob/user = owner.current
	if(force_can_ascend)
		if(!say_result)
			return TRUE

		user.balloon_alert(user, "вам дозволенно вознестись")
		return TRUE

	if(feast_of_owls)
		if(!say_result)
			return FALSE

		user.balloon_alert(user, "ваши амбиции поглощены")
		return FALSE // We sold our ambition for immediate power :/

	for(var/datum/objective/heretic_research/research in objectives)
		if(research.check_completion())
			continue

		if(!say_result)
			return FALSE

		user.balloon_alert(user, "слишком мало знаний")
		return FALSE


	for(var/datum/objective/heretic_sacrifice/sacrifice in objectives)
		if(sacrifice.check_completion())
			continue

		if(!say_result)
			return FALSE

		user.balloon_alert(user, "слишком мало жертв")
		return FALSE

	return TRUE

/**
 * Helper to determine if a Heretic
 * - Has a Living Heart
 * - Has a an organ in the correct slot that isn't a living heart
 * - Is missing the organ they need in the slot to make a living heart
 *
 * Returns HERETIC_NO_HEART_ORGAN if they have no heart (organ) at all,
 * Returns HERETIC_NO_LIVING_HEART if they have a heart (organ) but it's not a living one,
 * and returns HERETIC_HAS_LIVING_HEART if they have a living heart
 */
/datum/antagonist/heretic/proc/has_living_heart()
	var/obj/item/organ/our_living_heart = owner.current?.get_organ_slot(living_heart_organ_slot)
	if(!our_living_heart)
		return HERETIC_NO_HEART_ORGAN

	if(!HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		return HERETIC_NO_LIVING_HEART

	return HERETIC_HAS_LIVING_HEART


#define DREAM_VIEW_RANGE	5

/datum/antagonist/heretic/proc/get_dreams(mob/living/carbon/sleeper, list/dreams)
	SIGNAL_HANDLER
	dreams += "Вы бродите по лесу Мансуса"
	dreams += "Вы видите " + pick("пруд", "колодец", "озеро", "лужу", "ручей", "реку", "болото")

	if(isnull(dreams_allowed_typecaches_by_root_type))
		dreams_allowed_typecaches_by_root_type = list()
		for(var/type in dreams_what_you_can_see)
			dreams_allowed_typecaches_by_root_type[type] = typecacheof(type) - dreams_what_you_cant_see

	var/list/all_objects = oview(DREAM_VIEW_RANGE, pick(GLOB.reality_smash_track.smashes))
	var/something_found = FALSE
	for(var/object_type in dreams_allowed_typecaches_by_root_type)
		var/list/filtered_objects = typecache_filter_list(all_objects, dreams_allowed_typecaches_by_root_type[object_type])
		if(!filtered_objects.len)
			continue

		if(!something_found)
			dreams += "Вы видите отражение на поверхности воды"
			something_found = TRUE

		var/obj/found_object = pick(filtered_objects)
		dreams += found_object.declent_ru(NOMINATIVE)

	if(!something_found)
		dreams += pick("Вода полностью чёрная", "Отражение слишкмо размыто.", "Вы бесцельно бродите")
	else
		dreams += "Изображения на поверхности воды постепенно рассеиваются"

	dreams += "Вы чувствуете сильную усталость"

#undef DREAM_VIEW_RANGE

/// Heretic's minor sacrifice objective. "Minor sacrifices" includes anyone.
/datum/objective/heretic_sacrifice
	name = "жертва мансусу"
	target_amount = 5
	explanation_text = "Принесите мансусу как минимум 5 жертв. \
						В жертву можно приносить только тех, на кого укажет Живое Сердце."


/datum/objective/heretic_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE

	return completed || (heretic_datum.total_sacrifices >= target_amount)

/// Heretic's research objective. "Research" is heretic knowledge nodes (You start with some).
/datum/objective/heretic_research
	name = "исследование"
	/// The length of a main path. Calculated once in New().
	var/static/main_path_length = 0

/datum/objective/heretic_research/New(text)
	. = ..()

	if(!main_path_length)
		// Let's find the length of a main path. We'll use rust because it's the coolest.
		// (All the main paths are (should be) the same length, so it doesn't matter.)
		var/rust_paths_found = 0
		for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
			if(GLOB.heretic_research_tree[knowledge][HKT_ROUTE] != PATH_RUST)
				continue

			rust_paths_found++

		main_path_length = rust_paths_found

	// Factor in the length of the main path first.
	target_amount = main_path_length
	// Add in the base research we spawn with, otherwise it'd be too easy.
	target_amount += length(GLOB.heretic_start_knowledge)
	// And add in some buffer, to require some sidepathing, especially since heretics get some free side paths.
	target_amount += rand(2, 4)
	update_explanation_text()


/datum/objective/heretic_research/update_explanation_text()
	. = ..()
	explanation_text = "Узнайте как минимум о [target_amount] еретических знаниях. Вы начинаете с уже изученными знаниями:\n"
	for(var/datum/heretic_knowledge/knowledge as anything in GLOB.heretic_start_knowledge)
		explanation_text += "[knowledge.name][knowledge != GLOB.heretic_start_knowledge[GLOB.heretic_start_knowledge.len] ? ", " : "."]\n"


/datum/objective/heretic_research/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE

	return completed || (length(heretic_datum.researched_knowledge) >= target_amount)

/datum/objective/heretic_summon
	name = "призыв монстров"
	target_amount = 2
	explanation_text = "Призовите хотябы двух монстров из царства Мансуса в эту реальность."
	/// The total number of summons the objective owner has done
	var/num_summoned = 0

/datum/objective/heretic_summon/check_completion()
	return completed || (num_summoned >= target_amount)


/**
 * Takes any datum `source` and checks it for heretic datum.
 */
/proc/isheretic(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/heretic)

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/heretic)
