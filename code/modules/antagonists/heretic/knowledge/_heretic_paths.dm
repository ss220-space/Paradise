
GLOBAL_LIST(heretic_research_tree)
/// Assoc list of [route string] to the single instance of that route's tree column.
GLOBAL_LIST_INIT(heretic_path_datums, init_heretic_path_datums())

/proc/init_heretic_path_datums()
	var/list/paths = list()
	for(var/datum/heretic_knowledge_tree_column/column_path as anything in valid_subtypesof(/datum/heretic_knowledge_tree_column))
		var/datum/heretic_knowledge_tree_column/heretic_route = new column_path()
		paths[heretic_route.route] = heretic_route
	return paths

/datum/heretic_knowledge_tree_column
	///Route that symbolizes what path this is
	var/route
	abstract_type = /datum/heretic_knowledge_tree_column
	///UI background
	var/ui_bgr = "node_side"

/datum/heretic_knowledge_tree_column/main
	abstract_type = /datum/heretic_knowledge_tree_column/main

	///Starting knowledge - first thing you pick
	var/start
	///Blade upgrade
	var/blade
	///Ascension
	var/ascension

	///Tier-1 knowledge (replaces legacy grasp+tier1)
	var/knowledge_tier1
	///Tier-2 knowledge
	var/knowledge_tier2
	///Tier-3 knowledge
	var/knowledge_tier3
	///Tier-4 knowledge (the path's "final" power before ascension)
	var/knowledge_tier4
	///Path-specific robes (e.g. Scorched Mantle). Sits between tier2 and tier3.
	var/robes
	///Side knowledge guaranteed to be offered in this path's first draft
	var/guaranteed_side_tier1
	///Side knowledge guaranteed to be offered in this path's second draft
	var/guaranteed_side_tier2
	///Side knowledge guaranteed to be offered in this path's third draft
	var/guaranteed_side_tier3
	///Subtracted from each shop tier's cost for this path (min 1)
	var/shop_cost_discount = 0
	var/disabled_reason

	///Difficulty label shown in the Path Info tab
	var/complexity = "Средняя"
	///Colour of the complexity label
	var/complexity_color = "#bd54e0"
	///Short description lines of the path's playstyle
	var/list/path_description = list()
	///Strengths of the path
	var/list/path_pros = list()
	///Weaknesses of the path
	var/list/path_cons = list()
	///Gameplay tips for the path
	var/list/path_tips = list()
	///Display name of this path's passive ("empowerment"), shown in the Path Info tab. Null = no passive yet.
	var/passive_name
	///Per-tier descriptions of this path's passive (index = tier), shown in the Path Info tab.
	var/list/passive_descriptions = list()

/proc/get_heretic_path_column_by_start(datum/heretic_knowledge/start_type)
	for(var/route in GLOB.heretic_path_datums)
		var/datum/heretic_knowledge_tree_column/main/column = GLOB.heretic_path_datums[route]
		if(istype(column) && column.start == start_type)
			return column

/// Builds this path's entry for the "Path Info" tab of the heretic's antag UI.
/datum/heretic_knowledge_tree_column/main/proc/get_ui_data(datum/antagonist/heretic/our_heretic)
	var/list/data = list(
		"route" = route,
		"complexity" = complexity,
		"complexity_color" = complexity_color,
		"description" = path_description.Copy(),
		"pros" = path_pros.Copy(),
		"cons" = path_cons.Copy(),
		"tips" = path_tips.Copy(),
		"starting_knowledge" = our_heretic.get_knowledge_data(start, !!our_heretic.researched_knowledge[start]),
	)

	if(passive_name)
		data["passive"] = list(
			"name" = passive_name,
			"description" = passive_descriptions.Copy(),
		)

	var/list/preview_abilities = list()
	for(var/knowledge in list(knowledge_tier1, knowledge_tier2, robes, knowledge_tier3, blade, knowledge_tier4))
		if(!knowledge)
			continue
		preview_abilities += list(our_heretic.get_knowledge_data(knowledge, !!our_heretic.researched_knowledge[knowledge]))
	data["preview_abilities"] = preview_abilities

	return data

/proc/generate_heretic_research_tree()
	var/list/heretic_research_tree = list()

	for(var/type in subtypesof(/datum/heretic_knowledge))
		heretic_research_tree[type] = list()
		heretic_research_tree[type][HKT_NEXT] = list()
		heretic_research_tree[type][HKT_BAN] = list()
		heretic_research_tree[type][HKT_DEPTH] = 1
		heretic_research_tree[type][HKT_UI_BGR] = "node_side"

		var/datum/heretic_knowledge/knowledge = type
		if(initial(knowledge.is_starting_knowledge))
			heretic_research_tree[type][HKT_ROUTE] = PATH_START
			continue

		heretic_research_tree[type][HKT_ROUTE] = null

	var/list/start_blacklist = list()
	var/list/blade_blacklist = list()
	var/list/asc_blacklist = list()

	for(var/route in GLOB.heretic_path_datums)
		var/datum/heretic_knowledge_tree_column/main/column = GLOB.heretic_path_datums[route]
		if(!istype(column))
			continue

		start_blacklist += column.start
		blade_blacklist += column.blade
		asc_blacklist += column.ascension

	heretic_research_tree[/datum/heretic_knowledge/spell/basic][HKT_NEXT] += start_blacklist

	for(var/route in GLOB.heretic_path_datums)
		var/datum/heretic_knowledge_tree_column/main/column = GLOB.heretic_path_datums[route]
		if(!istype(column) || !column.knowledge_tier1)
			continue
		build_tg_path_chain(heretic_research_tree, column, start_blacklist, asc_blacklist, blade_blacklist)

	heretic_research_tree[/datum/heretic_knowledge/reroll_targets][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/reroll_targets][HKT_DEPTH] = 2

	heretic_research_tree[/datum/heretic_knowledge/codex_cicatrix][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/codex_cicatrix][HKT_DEPTH] = 1

	heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_NEXT] += /datum/heretic_knowledge/rifle_ammo
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_DEPTH] = 2

	return heretic_research_tree

/**
 * Builds the modern research chain for a main column into the (global) research tree.
 * Vertical order: start -> knowledge_tier1 -> knowledge_tier2 -> robes -> knowledge_tier3 -> blade ->
 * knowledge_tier4 -> ascension. The full side-knowledge pool is unlocked tier-by-tier
 * (shop_unlock order) off this path's nodes, so the shop progresses as you research.
 */
/proc/build_tg_path_chain(list/tree, datum/heretic_knowledge_tree_column/main/column, list/start_blacklist, list/asc_blacklist, list/blade_blacklist)
	var/start = column.start
	var/t1 = column.knowledge_tier1
	var/t2 = column.knowledge_tier2
	var/robes = column.robes
	var/t3 = column.knowledge_tier3
	var/blade = column.blade
	var/t4 = column.knowledge_tier4
	var/asc = column.ascension

	var/list/chain = list(start, t1, t2, robes, t3, blade, t4, asc)
	tree[/datum/heretic_knowledge/spell/basic][HKT_NEXT] |= start
	for(var/stage in 1 to length(chain) - 1)
		tree[chain[stage]][HKT_NEXT] |= chain[stage + 1]

	for(var/node in chain)
		tree[node][HKT_ROUTE] = column.route
		tree[node][HKT_UI_BGR] = column.ui_bgr

	tree[start][HKT_DEPTH] = HKT_DEPTH_START
	tree[t1][HKT_DEPTH] = HKT_DEPTH_TIER_1
	tree[t2][HKT_DEPTH] = HKT_DEPTH_TIER_2
	tree[robes][HKT_DEPTH] = HKT_DEPTH_ROBES
	tree[t3][HKT_DEPTH] = HKT_DEPTH_TIER_3
	tree[blade][HKT_DEPTH] = HKT_DEPTH_ARMOR
	tree[t4][HKT_DEPTH] = HKT_DEPTH_TIER_4
	tree[asc][HKT_DEPTH] = HKT_DEPTH_ASCENSION

	tree[start][HKT_BAN] |= (start_blacklist - start) + (asc_blacklist - asc)
	tree[blade][HKT_BAN] |= (blade_blacklist - blade)

	tree[t1][HKT_NEXT] |= /datum/heretic_knowledge/codex_cicatrix
	tree[t2][HKT_NEXT] |= /datum/heretic_knowledge/reroll_targets

/**
 * Generates this heretic's per-tier DRAFTS and the tiered SHOP for their chosen TG-format path (TG 1:1).
 * Each draft tier offers up to 3 side knowledges (one guaranteed) - picking one is FREE and bans the
 * siblings. The shop lets you BUY any side knowledge for points, unlocked tier-by-tier as you research.
 */
/datum/antagonist/heretic/proc/generate_path_drafts()
	drafted_knowledge = list()
	shop_knowledge_pool = list()

	var/datum/heretic_knowledge_tree_column/main/column = heretic_path
	if(!column?.knowledge_tier1)
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

	var/list/draft_ineligible = list(t1, t2, t3, t4) + guaranteed

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

	var/list/draft_specs = list(
		list("parent" = t1, "guaranteed" = guaranteed[1], "supplementary" = list(/datum/heretic_knowledge/spell/cloak_of_shadows), "weights" = list("1"=50, "2"=50, "3"=0, "4"=0, "5"=0), "depth" = HKT_DEPTH_DRAFT_1),
		list("parent" = t2, "guaranteed" = guaranteed[2], "weights" = list("1"=50, "2"=25, "3"=25, "4"=0, "5"=0), "depth" = HKT_DEPTH_DRAFT_2),
		list("parent" = t3, "guaranteed" = guaranteed[3], "weights" = list("1"=20, "2"=20, "3"=20, "4"=20, "5"=20), "depth" = HKT_DEPTH_DRAFT_3),
		list("parent" = t4, "guaranteed" = null, "weights" = list("1"=0, "2"=0, "3"=0, "4"=0, "5"=100), "depth" = HKT_DEPTH_DRAFT_4),
	)
	for(var/list/spec in draft_specs)
		var/list/group = list()
		for(var/datum/heretic_knowledge/supplementary as anything in spec["supplementary"])
			group += supplementary
			drafted_knowledge[supplementary] = list(
				HKT_PARENT = spec["parent"],
				HKT_DEPTH = spec["depth"],
				HKT_DRAFT_TIER = initial(supplementary.drafting_tier),
				HKT_COST = 0,
				HKT_BAN = list(),
			)
		for(var/cycle in 1 to 3)
			var/datum/heretic_knowledge/picked
			if(spec["guaranteed"] && cycle == 1)
				picked = spec["guaranteed"]
				var/g_tier = initial(picked.drafting_tier)
				if(g_tier >= 1 && g_tier <= length(shop_pool) && !(picked in shop_pool[g_tier]))
					shop_pool[g_tier] += picked
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

	for(var/tier in 1 to length(shop_pool))
		for(var/knowledge_type in shop_pool[tier])
			shop_knowledge_pool[knowledge_type] = list(
				HKT_PARENT = shop_unlock[tier],
				HKT_DEPTH = tier, // shop "Тир N" label
				HKT_DRAFT_TIER = tier,
				HKT_COST = shop_costs[tier],
				HKT_BAN = list(),
			)
	if(shop_knowledge_pool[/datum/heretic_knowledge/rifle])
		shop_knowledge_pool[/datum/heretic_knowledge/rifle_ammo] = list(
			HKT_PARENT = /datum/heretic_knowledge/rifle,
			HKT_DEPTH = 2,
			HKT_DRAFT_TIER = 2,
			HKT_COST = 0, // TG: free follow-up unlock once you've researched the rifle.
			HKT_BAN = list(),
		)
