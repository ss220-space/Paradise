
GLOBAL_LIST(heretic_research_tree)

/datum/heretic_knowledge_tree_column
	///Route that symbolizes what path this is
	var/route
	///Used to determine if this is a side path or a main path
	var/abstract_parent_type = /datum/heretic_knowledge_tree_column
	///UI background
	var/ui_bgr = "node_side"

/datum/heretic_knowledge_tree_column/main
	abstract_parent_type = /datum/heretic_knowledge_tree_column/main

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

	var/list/paths = list()
	for(var/type in subtypesof(/datum/heretic_knowledge_tree_column))
		var/datum/heretic_knowledge_tree_column/column_path = type
		if(initial(column_path.abstract_parent_type) == column_path)
			continue

		var/datum/heretic_knowledge_tree_column/column = new type()
		paths[column.type] = column

	var/list/start_blacklist = list()
	var/list/blade_blacklist = list()
	var/list/asc_blacklist = list()

	for(var/id in paths)
		if(!istype(paths[id],/datum/heretic_knowledge_tree_column/main))
			continue
		var/datum/heretic_knowledge_tree_column/main/column = paths[id]

		start_blacklist += column.start
		blade_blacklist += column.blade
		asc_blacklist += column.ascension

	heretic_research_tree[/datum/heretic_knowledge/spell/basic][HKT_NEXT] += start_blacklist

	for(var/id in paths)
		var/datum/heretic_knowledge_tree_column/this_column = paths[id]
		if(!istype(this_column, /datum/heretic_knowledge_tree_column/main))
			continue
		var/datum/heretic_knowledge_tree_column/main/main_column = this_column
		if(!main_column.knowledge_tier1)
			continue
		build_tg_path_chain(heretic_research_tree, main_column, start_blacklist, asc_blacklist, blade_blacklist)

	heretic_research_tree[/datum/heretic_knowledge/reroll_targets][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/reroll_targets][HKT_DEPTH] = 2

	heretic_research_tree[/datum/heretic_knowledge/codex_cicatrix][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/codex_cicatrix][HKT_DEPTH] = 1

	heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_NEXT] += /datum/heretic_knowledge/rifle_ammo
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_DEPTH] = 2

	QDEL_LIST_ASSOC_VAL(paths)
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
