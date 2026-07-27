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
		PATH_BLUESPACE = COLOR_DARK_CYAN,
	))

/// Generates a string of garbled symbols up to [length] characters, used for spooky ascension announcements.
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
	clown_removal_text = "По мере того, как ваши еретические знания рассеиваются, вы возвращаетесь к своему неуклюжему, клоунскому \"я\"."
	antag_menu_name = "Еретик"
	/// Automaticly allow to ascend
	var/force_can_ascend = FALSE
	/// Whether we've ascended! (Completed one of the final rituals)
	var/ascended = FALSE
	/// The tree column datum of the path our heretic has chosen, null until they pick a starting knowledge.
	var/datum/heretic_knowledge_tree_column/main/heretic_path
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
	/// Reference to the eldritch aura overlay a heretic radiates once they grow strong enough.
	var/static/mutable_appearance/eldritch_overlay = mutable_appearance('icons/mob/effects/heretic_aura.dmi', "heretic_aura")
	/// Cumulative knowledge points ever gained (only ever climbs). Drives the [points_to_aura] threshold.
	var/knowledge_gained = 0
	/// Once TRUE the heretic radiates a visible aura and can forge blades without limit (tg's "unlimited_blades").
	/// Set when they craft their robe (passive tier 2) or reach [points_to_aura] knowledge.
	var/unlimited_blades = FALSE
	/// How many cumulative knowledge points are needed before the visible aura kicks in (tg uses 8).
	var/points_to_aura = 8
	var/summoned_creature = FALSE

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
	var/static/list/dreams_allowed_typecaches_by_root_type = null

/datum/antagonist/heretic/Destroy()
	LAZYNULL(sac_targets)
	return ..()


/datum/antagonist/heretic/proc/get_icon_of_knowledge(datum/heretic_knowledge/knowledge)
	var/icon_path = 'icons/mob/actions/actions_ecult.dmi'
	var/icon_state = "eye"
	var/icon_frame = knowledge.research_tree_icon_frame
	var/icon_dir = knowledge.research_tree_icon_dir
	var/icon_moving = 0

	if(!isnull(knowledge.research_tree_icon_path))
		icon_path = knowledge.research_tree_icon_path
		icon_state = knowledge.research_tree_icon_state

	else if(ispath(knowledge,/datum/heretic_knowledge/spell))
		var/datum/heretic_knowledge/spell/spell_knowledge = knowledge
		var/datum/action/result_action = spell_knowledge.spell_to_add
		icon_path = result_action.button_icon
		icon_state = result_action.button_icon_state

	else if(ispath(knowledge,/datum/heretic_knowledge/limited_amount/summon))
		var/datum/heretic_knowledge/limited_amount/summon/summon_knowledge = knowledge
		var/mob/living/result_mob = summon_knowledge.mob_to_summon
		icon_path = result_mob.icon
		icon_state = result_mob.icon_state

	var/list/result_parameters = list()
	result_parameters["icon"] = icon_path
	result_parameters["state"] = icon_state
	result_parameters["frame"] = icon_frame
	result_parameters["dir"] = icon_dir
	result_parameters["moving"] = icon_moving
	return result_parameters

/datum/antagonist/heretic/proc/get_knowledge_data(datum/heretic_knowledge/knowledge, done, list/meta = null)

	var/list/knowledge_data = list()

	var/cost = meta ? meta[HKT_COST] : initial(knowledge.cost)
	var/list/tree_entry = meta ? null : GLOB.heretic_research_tree[knowledge]
	knowledge_data["path"] = knowledge
	knowledge_data["icon_params"] = get_icon_of_knowledge(knowledge)
	knowledge_data["name"] = initial(knowledge.name)
	knowledge_data["gainFlavor"] = initial(knowledge.gain_text)
	knowledge_data["cost"] = cost
	knowledge_data["disabled"] = (!done) && (cost > knowledge_points)
	knowledge_data["bgr"] = tree_entry ? tree_entry[HKT_UI_BGR] : BGR_SIDE
	knowledge_data["depth"] = meta ? meta[HKT_DEPTH] : (tree_entry ? tree_entry[HKT_DEPTH] : 1)
	knowledge_data["finished"] = done
	knowledge_data["ascension"] = ispath(knowledge,/datum/heretic_knowledge/ultimate)

	if(done)
		var/datum/heretic_knowledge/knowledge_instance = researched_knowledge[knowledge]
		knowledge_data["desc"] = knowledge_instance.desc
		knowledge_data["transmuteText"] = knowledge_instance.transmute_text
	else
		knowledge_data["desc"] = initial(knowledge.desc)
		knowledge_data["transmuteText"] = initial(knowledge.transmute_text)
	knowledge_data["notice"] = initial(knowledge.notice)

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
	ui.set_autoupdate(FALSE)
	ui.open()


/datum/antagonist/heretic/ui_data(mob/user)
	var/list/data = list()

	data["charges"] = knowledge_points
	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended
	data["points_to_aura"] = points_to_aura

	var/list/tiers = list()
	var/list/shop = list()

	var/list/path_start_knowledges = list()
	for(var/route in GLOB.heretic_path_datums)
		var/datum/heretic_knowledge_tree_column/main/column = GLOB.heretic_path_datums[route]
		if(istype(column) && column.start)
			path_start_knowledges[column.start] = TRUE

	for(var/datum/heretic_knowledge/knowledge as anything in researched_knowledge)
		if(drafted_knowledge[knowledge] || shop_knowledge_pool[knowledge])
			continue
		var/list/knowledge_data = get_knowledge_data(knowledge, TRUE)
		var/list/tree_entry = GLOB.heretic_research_tree[knowledge]
		if(!tree_entry || tree_entry[HKT_ROUTE] == PATH_SIDE)
			shop += list(knowledge_data)
			continue
		add_node_to_tiers(tiers, knowledge_data)

	for(var/datum/heretic_knowledge/knowledge as anything in get_researchable_knowledge())
		if(drafted_knowledge[knowledge] || shop_knowledge_pool[knowledge])
			continue
		if(path_start_knowledges[knowledge])
			continue
		var/list/knowledge_data = get_knowledge_data(knowledge, FALSE)
		if(ispath(knowledge, /datum/heretic_knowledge/ultimate))
			knowledge_data["disabled"] ||= !can_ascend()
		if(GLOB.heretic_research_tree[knowledge][HKT_ROUTE] == PATH_SIDE)
			shop += list(knowledge_data)
			continue
		add_node_to_tiers(tiers, knowledge_data)

	for(var/knowledge_type in drafted_knowledge)
		if(researched_knowledge[knowledge_type])
			continue
		if(is_available_draft(knowledge_type))
			add_node_to_tiers(tiers, get_knowledge_data(knowledge_type, FALSE, drafted_knowledge[knowledge_type]))

	for(var/knowledge_type in shop_knowledge_pool)
		if(researched_knowledge[knowledge_type])
			shop += list(get_knowledge_data(knowledge_type, TRUE, shop_knowledge_pool[knowledge_type]))
	for(var/knowledge_type in shop_knowledge_pool)
		if(researched_knowledge[knowledge_type])
			continue
		if(is_available_shop(knowledge_type))
			shop += list(get_knowledge_data(knowledge_type, FALSE, shop_knowledge_pool[knowledge_type]))

	data["knowledge_tiers"] = tiers
	data["knowledge_shop"] = shop

	data["passive_level"] = passive_level

	var/list/paths_data = list()
	for(var/route in GLOB.heretic_path_datums)
		var/datum/heretic_knowledge_tree_column/main/column = GLOB.heretic_path_datums[route]
		if(!istype(column) || !column.start)
			continue
		if(column.disabled_reason && !researched_knowledge[column.start])
			continue
		paths_data += list(column.get_ui_data(src))

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
			if(researched_knowledge[researched_path])
				return TRUE
			var/datum/heretic_knowledge_tree_column/main/path_column = get_heretic_path_column_by_start(researched_path)
			if(path_column?.disabled_reason)
				to_chat(owner.current, span_warning("[path_column.route]: [path_column.disabled_reason]"))
				return TRUE
			if(!(researched_path in get_researchable_knowledge()))
				message_admins("Heretic [key_name(owner)] potentially attempted to href exploit to learn knowledge they can't learn!")
				CRASH("Heretic attempted to learn knowledge they can't learn! (Got: [researched_path])")
			if(ispath(researched_path, /datum/heretic_knowledge/ultimate) && !can_ascend(TRUE))
				message_admins("Heretic [key_name(owner)] potentially attempted to href exploit to learn ascension knowledge without completing objectives!")
				CRASH("Heretic attempted to learn a final knowledge despite not being able to ascend!")
			purchase_knowledge(researched_path)
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
	ADD_TRAIT(owner, TRAIT_BAD_SOUL, HERETIC_TRAIT)
	return ..()


/datum/antagonist/heretic/handle_last_instance_removal()
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(owner.current, src)

	QDEL_LIST_ASSOC_VAL(researched_knowledge)
	return ..()


/datum/antagonist/heretic/add_antag_hud(mob/living/antag_mob)
	. = ..()
	if(summoned_creature)
		add_team_hud(antag_mob, /datum/atom_hud/alternate_appearance/basic/heretic_team, owner)

/datum/antagonist/heretic/remove_antag_hud(mob/living/antag_mob)
	. = ..()
	remove_team_hud()

/datum/antagonist/heretic/proc/reveal_antag_hud()
	if(summoned_creature)
		return
	summoned_creature = TRUE
	var/mob/living/heretic_mob = owner?.current
	if(QDELETED(heretic_mob))
		return
	add_team_hud(heretic_mob, /datum/atom_hud/alternate_appearance/basic/heretic_team, owner)

/datum/antagonist/heretic/proc/hide_antag_hud()
	if(!summoned_creature)
		return
	summoned_creature = FALSE
	remove_team_hud()

/datum/atom_hud/alternate_appearance/basic/heretic_team
	var/datum/mind/master_mind

/datum/atom_hud/alternate_appearance/basic/heretic_team/New(key, image/hud, datum/mind/master_mind)
	src.master_mind = master_mind
	..(key, hud, NONE)

/datum/atom_hud/alternate_appearance/basic/heretic_team/Destroy(force)
	master_mind = null
	return ..()

/datum/atom_hud/alternate_appearance/basic/heretic_team/mob_should_see(mob/viewer)
	var/datum/mind/viewer_mind = viewer.mind
	if(!viewer_mind || !master_mind)
		return FALSE
	if(viewer_mind == master_mind)
		return TRUE
	var/datum/antagonist/heretic_monster/monster = viewer_mind.has_antag_datum(/datum/antagonist/heretic_monster)
	return monster?.master == master_mind

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	our_mob.faction |= FACTION_HERETIC

	if(!issilicon(our_mob))
		GLOB.reality_smash_track.add_tracked_mind(owner)

	ADD_TRAIT(our_mob, TRAIT_MANSUS_TOUCHED, UID())
	RegisterSignal(our_mob, COMSIG_LIVING_CULT_SACRIFICED, PROC_REF(on_cult_sacrificed))
	RegisterSignal(our_mob, COMSIG_LIVING_CLOCK_SACRIFICED, PROC_REF(on_clock_sacrificed))
	RegisterSignals(our_mob, list(COMSIG_MOB_BEFORE_SPELL_CAST, COMSIG_MOB_SPELL_ACTIVATED), PROC_REF(on_spell_cast))
	RegisterSignal(our_mob, SIGNAL_ADDTRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_regained))
	RegisterSignal(our_mob, COMSIG_MOB_ITEM_AFTERATTACK, PROC_REF(on_item_use))
	RegisterSignal(our_mob, COMSIG_MOB_LOGIN, PROC_REF(on_login), override = TRUE)

	RegisterSignal(our_mob, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_aura_overlay))
	RegisterSignal(our_mob, COMSIG_ATOM_EXAMINE, PROC_REF(on_heretic_examine))
	RegisterSignals(our_mob, list(SIGNAL_ADDTRAIT(TRAIT_HERETIC_AURA_HIDDEN), SIGNAL_REMOVETRAIT(TRAIT_HERETIC_AURA_HIDDEN)), PROC_REF(update_heretic_aura))
	RegisterSignal(our_mob, COMSIG_HUMAN_REGENERATE_ICONS, PROC_REF(on_regenerate_icons))
	RegisterSignal(our_mob, COMSIG_GET_DREAMS, PROC_REF(get_dreams), override = TRUE)
	our_mob.update_appearance(UPDATE_OVERLAYS)

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	our_mob.faction -= FACTION_HERETIC
	clear_passive()

	if(owner in GLOB.reality_smash_track.tracked_heretics)
		GLOB.reality_smash_track.remove_tracked_mind(owner)

	REMOVE_TRAIT(our_mob, TRAIT_MANSUS_TOUCHED, UID())
	UnregisterSignal(our_mob, list(
		COMSIG_MOB_BEFORE_SPELL_CAST,
		COMSIG_MOB_SPELL_ACTIVATED,
		COMSIG_MOB_ITEM_AFTERATTACK,
		COMSIG_LIVING_CULT_SACRIFICED,
		COMSIG_LIVING_CLOCK_SACRIFICED,
		COMSIG_MOB_LOGIN,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_EXAMINE,
		COMSIG_HUMAN_REGENERATE_ICONS,
		COMSIG_GET_DREAMS,
		SIGNAL_ADDTRAIT(TRAIT_ALLOW_HERETIC_CASTING),
		SIGNAL_ADDTRAIT(TRAIT_HERETIC_AURA_HIDDEN),
		SIGNAL_REMOVETRAIT(TRAIT_HERETIC_AURA_HIDDEN),
	))
	our_mob.update_appearance(UPDATE_OVERLAYS)

/// Draws the eldritch aura overlay (+ its emissive glow) onto the heretic, if it should currently show.
/datum/antagonist/heretic/proc/add_aura_overlay(mob/living/source, list/overlays)
	SIGNAL_HANDLER
	if(!should_show_aura())
		return
	overlays += eldritch_overlay
	overlays += emissive_appearance(eldritch_overlay.icon, eldritch_overlay.icon_state, source)

/// Re-applies the aura after a full regenerate_icons() (which cut_overlays() wiped). master220's human
/// icon rebuild bypasses the managed-overlay/COMSIG_ATOM_UPDATE_OVERLAYS path, so we re-add the aura
/// directly here, the same way /datum/component/shielded re-draws its shield on this signal.
/datum/antagonist/heretic/proc/on_regenerate_icons(mob/living/source)
	SIGNAL_HANDLER
	if(!should_show_aura())
		return
	source.add_overlay(eldritch_overlay)
	source.add_overlay(emissive_appearance(eldritch_overlay.icon, eldritch_overlay.icon_state, source))

/// Refreshes the heretic's overlays so the aura is (re)drawn or cleared.
/datum/antagonist/heretic/proc/update_heretic_aura()
	SIGNAL_HANDLER
	if(!QDELETED(owner?.current))
		owner.current.update_appearance(UPDATE_OVERLAYS)

/// Whether the visible aura should currently be drawn. Mirrors tg's gating.
/datum/antagonist/heretic/proc/should_show_aura()
	if(!unlimited_blades || HAS_TRAIT(owner?.current, TRAIT_HERETIC_AURA_HIDDEN))
		return FALSE // Not powerful enough yet, or temporarily suppressed (e.g. disguised).
	if(feast_of_owls)
		return FALSE // No use giving an aura to a heretic that can't ascend.
	if(heretic_path?.route == PATH_LOCK)
		return FALSE // Lock heretics never get this aura.
	return TRUE

/// Adds the aura description when a grown heretic is examined (tg parity).
/datum/antagonist/heretic/proc/on_heretic_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!should_show_aura())
		return
	var/mob/heretic_mob = owner.current
	var/potential_string = "Вокруг [heretic_mob] клубится зелёный вихрь энергии."
	if(can_ascend())
		potential_string += " Кажется, [heretic_mob] вот-вот сбросит свою смертную оболочку!"
	examine_text += span_green(potential_string)

/// Grants the eldritch aura + lifts the blade-forging cap (tg's disable_blade_breaking). Idempotent.
/// Triggered by crafting the robe (passive tier 2) or by reaching [points_to_aura] knowledge.
/datum/antagonist/heretic/proc/disable_blade_breaking()
	if(unlimited_blades)
		return
	unlimited_blades = TRUE
	var/mob/heretic_mob = owner?.current
	if(!QDELETED(heretic_mob))
		to_chat(heretic_mob, span_boldwarning("Вы обрели немалую силу. Обитель больше не позволит вам ломать свои клинки, но теперь вы можете создавать их без ограничений."))
		heretic_mob.balloon_alert(heretic_mob, "клинки больше не ломаются!")
		heretic_mob.mind?.RemoveSpell(/obj/effect/proc_holder/spell/shadow_cloak)
	update_heretic_aura()

/// Signal handler for [COMSIG_MOB_LOGIN]. Fires when our heretic's client (re)attaches to the body. The
/// mind's spell actions, antag HUD marker, and reality-smash huds can end up missing after a relog or
/// rejuvenate, so re-apply them defensively here.
/datum/antagonist/heretic/proc/on_login(mob/living/source)
	SIGNAL_HANDLER

	if(QDELETED(source) || owner?.current != source)
		return

	if(antag_hud_type && antag_hud_name)
		add_antag_hud(source)

	if(!issilicon(source) && GLOB.reality_smash_track)
		GLOB.reality_smash_track.rework_existing_influences(source)

	resync_knowledge_spells(source)

/// Re-adds any [/datum/heretic_knowledge/spell] spell that is no longer present in [source]'s mind.
/// Dedupe-safe: spells already granted are skipped, so this never double-grants.
/datum/antagonist/heretic/proc/resync_knowledge_spells(mob/living/source)
	if(!source?.mind)
		return
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/spell/spell_knowledge = researched_knowledge[knowledge_index]
		if(!istype(spell_knowledge) || !spell_knowledge.spell_to_add)
			continue
		if(unlimited_blades && spell_knowledge.spell_to_add == /obj/effect/proc_holder/spell/shadow_cloak)
			continue
		if(locate(spell_knowledge.spell_to_add) in source.mind.spell_list)
			continue
		source.mind.AddSpell(new spell_knowledge.spell_to_add())


/datum/antagonist/heretic/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	if(old_body == new_body) // if they were using a temporary body
		return

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(old_body, src, TRUE)
		knowledge.on_gain(new_body, src, TRUE)

/// Signal proc for [COMSIG_MOB_BEFORE_SPELL_CAST] and [COMSIG_MOB_SPELL_ACTIVATED]. Cancels forbidden-school
/// casts unless the heretic has [TRAIT_ALLOW_HERETIC_CASTING] or is ascended.
/datum/antagonist/heretic/proc/on_spell_cast(mob/living/source, obj/effect/proc_holder/spell/spell)
	SIGNAL_HANDLER

	if(ascended)
		return

	if(HAS_TRAIT(source, TRAIT_ALLOW_HERETIC_CASTING))
		return

	if(HAS_TRAIT(source, TRAIT_HERETIC_HOLY_LOCKED))
		source.balloon_alert(source, "разум затуманен!")
		return SPELL_CANCEL_CAST

	if(spell.school != SCHOOL_FORBIDDEN)
		return

	source.balloon_alert(source, "нужен фокус!")
	return SPELL_CANCEL_CAST

/datum/antagonist/heretic/proc/on_focus_regained(mob/living/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(source, TRAIT_HERETIC_HOLY_LOCKED, HOLYWATER_TRAIT)

/// Signal proc for [COMSIG_MOB_ITEM_AFTERATTACK]. Lets a heretic draw a transmutation rune when holding a
/// pen with mansus grasp active in their offhand.
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

/// Attempt to draw a rune on [target_turf].
/datum/antagonist/heretic/proc/try_draw_rune(mob/living/user, turf/target_turf, drawing_time = 20 SECONDS, additional_checks)
	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, target_turf))
		if(!iswallturf(nearby_turf) && !is_type_in_typecache(nearby_turf, blacklisted_rune_turfs))
			continue

		target_turf.balloon_alert(user, "неподходящее место!")
		return

	if(locate(/obj/effect/decal/heretic_rune) in range(3, target_turf))
		target_turf.balloon_alert(user, "другая руна рядом!")
		return

	if(drawing_rune)
		target_turf.balloon_alert(user, "вы уже чертите!")
		return

	INVOKE_ASYNC(src, PROC_REF(draw_rune), user, target_turf, drawing_time, additional_checks)

/// The actual process of drawing a rune.
/datum/antagonist/heretic/proc/draw_rune(mob/living/user, turf/target_turf, drawing_time = 20 SECONDS, additional_checks)
	drawing_rune = TRUE

	var/rune_colour = GLOB.heretic_path_to_color[heretic_path?.route || PATH_START]
	target_turf.balloon_alert(user, "черчение руны...")
	var/obj/effect/temp_visual/drawing_heretic_rune/drawing_effect
	if(drawing_time < (10 SECONDS))
		drawing_effect = new /obj/effect/temp_visual/drawing_heretic_rune/fast(target_turf, rune_colour, drawing_time)
	else
		drawing_effect = new(target_turf, rune_colour, drawing_time)

	if(!do_after(user, drawing_time, target_turf, extra_checks = additional_checks, cog_icon = null))
		target_turf.balloon_alert(user, "прервано!")
		new /obj/effect/temp_visual/drawing_heretic_rune/fail(target_turf, rune_colour)
		qdel(drawing_effect)
		drawing_rune = FALSE
		return

	qdel(drawing_effect)
	target_turf.balloon_alert(user, "руна создана")
	new /obj/effect/decal/heretic_rune/big(target_turf, rune_colour)
	drawing_rune = FALSE

/// Callback to check that the user's still got their mansus grasp out when drawing a rune.
/datum/antagonist/heretic/proc/check_mansus_grasp_offhand(mob/living/user)
	var/obj/item/offhand = user.get_inactive_hand()
	return !QDELETED(offhand) && istype(offhand, /obj/item/melee/touch_attack/mansus_fist)

/datum/antagonist/heretic/proc/scatter_sacrificed_loot(mob/living/source, list/invokers)
	var/mob/dead/observer/ghost = source.get_ghost()
	if(ghost?.client)
		ghost.reenter_corpse()

	var/list/dustee_items = source.unequip_everything()
	for(var/obj/item/loot as anything in dustee_items)
		loot.throw_at(get_step_rand(source), 2, 4, pick(invokers), TRUE)

/// Signal proc for [COMSIG_LIVING_CULT_SACRIFICED] to reward cultists for sacrificing a heretic
/datum/antagonist/heretic/proc/on_cult_sacrificed(mob/living/source, list/invokers)
	SIGNAL_HANDLER

	scatter_sacrificed_loot(source, invokers)

	var/obj/item/melee/cultblade/haunted/haunted_blade = new(get_turf(source), source, pick(invokers))

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
		to_chat(culto, span_cultlarge("Душа последователя забытых богов... Ты будешь вознаграждён за столь ценную жертву."))

	SSticker.mode.cult_objs.unlock_heretic_item()

	return SILENCE_SACRIFICE_MESSAGE|DUST_SACRIFICE

/datum/antagonist/heretic/proc/on_clock_sacrificed(mob/living/source, list/invokers)
	SIGNAL_HANDLER

	scatter_sacrificed_loot(source, invokers)

	for(var/mob/living/clocker as anything in invokers)
		to_chat(clocker, span_clocklarge("Душа последователя забытых богов... Механизмы Ратвара с радостью примут столь ценную жертву."))

	SSticker.mode.clocker_objs.unlock_heretic_item()

	return DUST_SACRIFICE

/mob/living/proc/mansus_absorbs_magic(mob/living/user, victim_message)
	var/old_color = color
	color = COLOR_HERETIC_GREEN
	animate(src, color = old_color, time = 4 SECONDS, easing = EASE_IN)
	mob_light(range = 1.5, power = 2.5, color = COLOR_HERETIC_GREEN, duration = 0.5 SECONDS)
	playsound(src, 'sound/magic/curse.ogg', 50, TRUE)

	to_chat(user, span_warning("Потусторонняя сила вмешивается, поглощая большую часть эффектов!"))
	to_chat(src, span_warning(victim_message))
	balloon_alert_to_viewers("поглощено!")

/// Creates an animation of the item slowly lifting up from the floor with a colored outline, then slowly
/// drifting back down.
/obj/proc/gender_reveal(
	outline_color = null,
	ray_color = null,
	anim_time = 10 SECONDS,
	do_float = TRUE,
	do_layer = TRUE,
)

	var/og_layer
	if(do_layer)
		og_layer = layer
		layer = ABOVE_MOB_LAYER

	if(do_float)
		animate(src, pixel_y = 12, time = anim_time * 0.5, easing = QUAD_EASING | EASE_OUT)
		animate(pixel_y = 0, time = anim_time * 0.5, easing = QUAD_EASING | EASE_IN)

	if(outline_color)
		add_filter("gender_reveal_outline", 3, list("type" = "outline", "color" = outline_color, "size" = 0.5))
		var/gay_filter = get_filter("gender_reveal_outline")
		animate(gay_filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
		animate(alpha = 40, time = 2.5 SECONDS)

	if(ray_color)
		add_filter(name = "gender_reveal_ray", priority = 1, params = list(
				type = "rays",
				size = 45,
				color = ray_color,
				density = 6
			))
		var/ray_filter = get_filter("gender_reveal_ray")
		animate(ray_filter, offset = 100, time = 30 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(src, PROC_REF(remove_gender_reveal_fx), og_layer), anim_time)

/// Removes the non-animate effects from above proc
/obj/proc/remove_gender_reveal_fx(og_layer)
	remove_filter(list("gender_reveal_outline", "gender_reveal_ray"))
	layer = og_layer

/// Create our objectives for our heretic.
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

/// Add [target] as a sacrifice target for the heretic. Generates a preview image and associates it with a
/// weakref of the mob.
/datum/antagonist/heretic/proc/add_sacrifice_target(mob/living/carbon/human/target)
	if(target in sac_targets)
		return

	var/image/target_image = image(icon = target.icon, icon_state = target.icon_state)
	target_image.overlays = target.overlays

	LAZYSET(sac_targets, target, target_image)
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_deleted))
	all_sac_targets += target.real_name

/// Removes [target] from the heretic's sacrifice list. Returns FALSE if no one was removed, TRUE otherwise.
/datum/antagonist/heretic/proc/remove_sacrifice_target(mob/living/carbon/human/target)
	if(!(target in sac_targets))
		return FALSE

	LAZYREMOVE(sac_targets, target)
	UnregisterSignal(target, COMSIG_QDELETING)
	return TRUE

/// Signal proc for [COMSIG_QDELETING] registered on sac targets: if a target is deleted (gibbed, dusted,
/// whatever), free their slot and reference.
/datum/antagonist/heretic/proc/on_target_deleted(mob/living/carbon/human/source)
	SIGNAL_HANDLER

	remove_sacrifice_target(source)

/// Increments knowledge by one. Used in callbacks for passive gain over time.
/datum/antagonist/heretic/proc/passive_influence_gain()
	adjust_knowledge_points(1)

	var/mob/living/heretic_mob = owner?.current
	if(!QDELETED(heretic_mob) && (heretic_mob.stat == CONSCIOUS || heretic_mob.IsSleeping()))
		to_chat(heretic_mob, "[span_hear("Вы слышите шёпот...")] [span_mansus(pick_list(HERETIC_INFLUENCE_FILE, "drain_message"))]")

	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer)

/// Adjusts our spendable knowledge points, tracks the cumulative total ever gained, and lights up the
/// eldritch aura once that total passes [points_to_aura] (tg parity). Route ALL point gains through here.
/datum/antagonist/heretic/proc/adjust_knowledge_points(amount)
	knowledge_points = max(0, knowledge_points + amount)
	knowledge_gained += max(0, amount)
	if(knowledge_gained > points_to_aura && !unlimited_blades)
		disable_blade_breaking()
	SStgui.update_uis(src)

/datum/antagonist/heretic/roundend_report()
	var/list/parts = list()

	var/succeeded = TRUE

	parts += printplayer(owner)
	parts += "<b>Принесённые жертвы:</b> [total_sacrifices]"
	parts += "Целями жертвоприношений еретика были: [english_list(all_sac_targets, nothing_text = "-")]."
	if(length(objectives))
		var/count = 1
		for(var/datum/objective/objective as anything in objectives)
			if(objective.check_completion())
				parts += "<b>Цель #[count]</b>: [objective.explanation_text] [span_greentext("Успех!")]"
			else
				parts += "<b>Цель #[count]</b>: [objective.explanation_text] [span_redtext("Провал.")]"
				succeeded = FALSE
			count++

	if(feast_of_owls)
		parts += span_greentext("Отрекшиеся Вознеслись.")

	if(ascended)
		parts += span_greentext(span_big("ЕРЕТИК ВОЗНЕССЯ!"))

	else
		if(succeeded)
			parts += span_greentext("Еретик выполнил цели, но не вознёсся!")
		else
			parts += span_redtext("Еретик провалился.")

	parts += "<b>Изученные Знания:</b> "

	var/list/string_of_knowledge = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		if(istype(knowledge, /datum/heretic_knowledge/ultimate))
			string_of_knowledge += span_bold(knowledge.name)
			continue

		string_of_knowledge += knowledge.name

	parts += english_list(string_of_knowledge, and_text = " и ")

	return parts.Join("<br>")

/datum/game_mode/proc/auto_declare_completion_heretic()
	if(!length(heretics))
		return

	var/list/text = list(span_fontsize2(span_bold("Еретик[declension_ru(length(heretics), "ом был", "ами были", "ами были")]:")))
	for(var/datum/mind/heretic in heretics)
		var/datum/antagonist/heretic/heretic_datum = heretic.has_antag_datum(/datum/antagonist/heretic)
		if(!heretic_datum)
			continue
		text += "[heretic_datum.roundend_report()]<br>"
	return text.Join("")

/// Admin proc for giving a heretic a Living Heart easily.
/datum/antagonist/heretic/proc/give_living_heart(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Вам не следует это использовать!"))
		return

	var/datum/heretic_knowledge/living_heart/heart_knowledge = get_knowledge(/datum/heretic_knowledge/living_heart)
	if(!heart_knowledge)
		to_chat(admin, span_warning("У еретика почему-то нет знания о Живом сердце, сообщите об этом баге."))
		return

	heart_knowledge.on_research(owner.current, src)

/// Admin proc for adding a marked mob to a heretic's sac list.
/datum/antagonist/heretic/proc/add_marked_as_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Вам не следует это использовать!"))
		return

	var/mob/living/carbon/human/new_target = admin.client?.holder.marked_datum
	if(!istype(new_target))
		to_chat(admin, span_warning("Вы должны быть гуманоидом!"))
		return

	if(tgui_alert(admin, "Сообщить им, что цели были обновлены?", "Шёпот Обители", list("Да", "Нет")) == "Да")
		to_chat(owner.current, span_danger("Обитель сменила свою следующую жертву. Отыщи её!"))
		to_chat(owner.current, span_danger("[new_target.real_name], [new_target.mind?.assigned_role || "гуманоид"]."))

	add_sacrifice_target(new_target)

/// Admin proc for removing a mob from a heretic's sac list.
/datum/antagonist/heretic/proc/remove_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Вы не должны это использовать!"))
		return

	var/list/removable = list()
	for(var/mob/living/carbon/human/old_target as anything in sac_targets)
		removable[old_target.name] = old_target

	var/name_of_removed = tgui_input_list(admin, "Выберите цель, которую хотите удалить.", "Кого пощадить", removable)
	if(QDELETED(src) || !admin.client?.holder || isnull(name_of_removed))
		return

	var/mob/living/carbon/human/chosen_target = removable[name_of_removed]
	if(QDELETED(chosen_target) || !ishuman(chosen_target))
		return

	if(!remove_sacrifice_target(chosen_target))
		to_chat(admin, span_warning("Не получилось удалить [name_of_removed] из списка целей [owner]. Возможно, [name_of_removed] уже не в списке."))
		return

	if(tgui_alert(admin, "Сообщить им, что цели были обновлены?", "Шёпот Обители", list("Да", "Нет")) == "Да")
		to_chat(owner.current, span_danger("Обитель изменила ваши задачи."))

/// Admin proc for easily adding / removing knowledge points.
/datum/antagonist/heretic/proc/admin_change_points(admin)
	var/change_num = tgui_input_number(admin, "Добавить или забрать очки знаний", "Очки", 0, 100, -100)
	if(!change_num || QDELETED(src))
		return

	adjust_knowledge_points(change_num)


/// Admin proc for easily adding new sac target.
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

/// Admin proc for giving a heretic a focus.
/datum/antagonist/heretic/proc/admin_give_focus(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Вы не должны это использовать!"))
		return

	var/mob/living/pawn = owner.current
	pawn.equip_to_slot_if_possible(new /obj/item/clothing/neck/heretic_focus(get_turf(pawn)), ITEM_SLOT_NECK, TRUE, TRUE)
	to_chat(pawn, span_mansus("Обитель даровала вам способность колдовать без фокуса."))

/// Pays for and learns the passed [typepath] of knowledge, if we can currently afford and research it.
/// Returns TRUE if the knowledge was bought, FALSE otherwise.
/datum/antagonist/heretic/proc/purchase_knowledge(datum/heretic_knowledge/knowledge_type)
	var/research_cost = get_research_cost(knowledge_type)
	if(research_cost > knowledge_points)
		return FALSE
	if(!gain_knowledge(knowledge_type))
		return FALSE

	log_game("[key_name(owner)] gained knowledge: [initial(knowledge_type.name)]")
	adjust_knowledge_points(-research_cost)
	return TRUE

/// Learns the passed [typepath] of knowledge, creating a knowledge datum and adding it to our researched
/// knowledge list. Returns TRUE if the knowledge was added successfully, FALSE otherwise.
/datum/antagonist/heretic/proc/gain_knowledge(datum/heretic_knowledge/knowledge_type)
	if(!ispath(knowledge_type))
		stack_trace("[type] gain_knowledge was given an invalid path! (Got: [knowledge_type])")
		return FALSE

	if(get_knowledge(knowledge_type))
		return FALSE

	var/datum/heretic_knowledge/initialized_knowledge = new knowledge_type()
	if(!initialized_knowledge.pre_research(owner.current, src))
		qdel(initialized_knowledge)
		return FALSE

	researched_knowledge[knowledge_type] = initialized_knowledge
	initialized_knowledge.on_research(owner.current, src)
	SStgui.update_uis(src)
	return TRUE

/// Get a list of all knowledge TYPEPATHS that we can currently research.
/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		var/list/tree_entry = GLOB.heretic_research_tree[knowledge_index]
		if(!tree_entry)
			banned_knowledge |= knowledge.type
			continue
		if(!drafted_knowledge[knowledge_index] && !shop_knowledge_pool[knowledge_index])
			researchable_knowledge |= tree_entry[HKT_NEXT]
		banned_knowledge |= tree_entry[HKT_BAN]
		banned_knowledge |= knowledge.type

	researchable_knowledge -= banned_knowledge

	for(var/knowledge_type in drafted_knowledge)
		if(is_available_draft(knowledge_type))
			researchable_knowledge |= knowledge_type
	for(var/knowledge_type in shop_knowledge_pool)
		if(is_available_shop(knowledge_type))
			researchable_knowledge |= knowledge_type

	list_clear_nulls(researchable_knowledge)
	return researchable_knowledge

/// Check if the wanted type-path is in the list of research knowledge.
/datum/antagonist/heretic/proc/get_knowledge(wanted)
	return researched_knowledge[wanted]

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
		SStgui.update_uis(src)

/// Get a list of all rituals this heretic can invoke on a rune, as an associated list of [knowledge name] to
/// [knowledge datum] sorted by knowledge priority.
/datum/antagonist/heretic/proc/get_rituals()
	var/list/rituals = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		if(!knowledge.can_be_invoked(src))
			continue

		rituals[knowledge.name] = knowledge

	return sortTim(rituals, GLOBAL_PROC_REF(cmp_heretic_knowledge), associative = TRUE)

/// Checks to see if our heretic can currently ascend. Returns FALSE if not all of our objectives are
/// complete, or TRUE otherwise.
/datum/antagonist/heretic/proc/can_ascend(say_result)
	var/mob/user = owner.current
	if(force_can_ascend)
		if(!say_result)
			return TRUE

		user.balloon_alert(user, "вам дозволено вознестись")
		return TRUE

	if(feast_of_owls)
		if(!say_result)
			return FALSE

		user.balloon_alert(user, "ваши амбиции поглощены!")
		to_chat(user, span_boldnotice("Совы поглотили ваши амбиции!"))
		return FALSE // We sold our ambition for immediate power :/

	for(var/datum/objective/heretic_research/research in objectives)
		if(research.check_completion())
			continue

		if(!say_result)
			return FALSE

		user.balloon_alert(user, "слишком мало знаний!")
		to_chat(user, span_boldnotice("Слишком мало знаний!"))
		return FALSE


	for(var/datum/objective/heretic_sacrifice/sacrifice in objectives)
		if(sacrifice.check_completion())
			continue

		if(!say_result)
			return FALSE

		user.balloon_alert(user, "слишком мало жертв!")
		to_chat(user, span_boldnotice("Слишком мало жертв!"))
		return FALSE

	return TRUE

/// Helper to determine if a Heretic has a Living Heart, has a non-living organ in that slot, or is missing
/// the organ entirely. Returns HERETIC_NO_HEART_ORGAN / HERETIC_NO_LIVING_HEART / HERETIC_HAS_LIVING_HEART.
/datum/antagonist/heretic/proc/has_living_heart()
	var/obj/item/organ/our_living_heart = owner.current?.get_organ_slot(living_heart_organ_slot)
	if(!our_living_heart)
		return HERETIC_NO_HEART_ORGAN

	if(!HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		return HERETIC_NO_LIVING_HEART

	return HERETIC_HAS_LIVING_HEART


/// Heretic's minor sacrifice objective. "Minor sacrifices" includes anyone.
/datum/objective/heretic_sacrifice
	name = "жертва Обители"
	target_amount = 5
	explanation_text = "Принесите Обители как минимум 5 жертв. \
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
		var/rust_paths_found = 0
		for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
			if(GLOB.heretic_research_tree[knowledge][HKT_ROUTE] != PATH_RUST)
				continue

			rust_paths_found++

		main_path_length = rust_paths_found

	target_amount = main_path_length
	target_amount += length(GLOB.heretic_start_knowledge)
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
	explanation_text = "Призовите хотя бы двух монстров из Обители в эту реальность."
	/// The total number of summons the objective owner has done
	var/num_summoned = 0

/datum/objective/heretic_summon/check_completion()
	return completed || (num_summoned >= target_amount)
