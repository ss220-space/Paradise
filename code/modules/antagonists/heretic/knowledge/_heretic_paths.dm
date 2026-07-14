
GLOBAL_LIST(heretic_research_tree)

/datum/heretic_knowledge_tree_column
	///Route that symbolizes what path this is
	var/route
	///Used to determine if this is a side path or a main path
	var/abstract_parent_type = /datum/heretic_knowledge_tree_column
	///IDs od neighbours (to left and right)
	var/neighbour_type_left
	var/neighbour_type_right
	///Tier1 knowledge (or knowledges)
	var/tier1
	///Tier2 knowledge (or knowledges)
	var/tier2
	///Tier3 knowledge (or knowledges)
	var/tier3
	///UI background
	var/ui_bgr = "node_side"

/datum/heretic_knowledge_tree_column/main
	abstract_parent_type = /datum/heretic_knowledge_tree_column/main

	///Starting knowledge - first thing you pick
	var/start
	///Grasp upgrade
	var/grasp
	///Mark upgrade
	var/mark
	///Unique ritual of knoweldge
	var/ritual_of_knowledge
	///Path specific unique ability
	var/unique_ability
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
	var/list/grasp_blacklist = list()
	var/list/mark_blacklist = list()
	var/list/blade_blacklist = list()
	var/list/asc_blacklist = list()

	for(var/id in paths)
		if(!istype(paths[id],/datum/heretic_knowledge_tree_column/main))
			continue
		var/datum/heretic_knowledge_tree_column/main/column = paths[id]

		start_blacklist += column.start
		if(column.grasp)
			grasp_blacklist += column.grasp
		if(column.mark)
			mark_blacklist += column.mark
		blade_blacklist += column.blade
		asc_blacklist += column.ascension

	heretic_research_tree[/datum/heretic_knowledge/spell/basic][HKT_NEXT] += start_blacklist

	for(var/id in paths)
		var/datum/heretic_knowledge_tree_column/this_column = paths[id]

		if(istype(this_column, /datum/heretic_knowledge_tree_column/main))
			var/datum/heretic_knowledge_tree_column/main/maybe_modern = this_column
			if(maybe_modern.knowledge_tier1)
				build_tg_path_chain(heretic_research_tree, maybe_modern, start_blacklist, asc_blacklist, blade_blacklist)
				continue

		var/datum/heretic_knowledge_tree_column/neighbour_0 = paths[this_column.neighbour_type_left]
		var/datum/heretic_knowledge_tree_column/neighbour_1 = paths[this_column.neighbour_type_right]
		var/list/tier1 = this_column.tier1
		var/list/tier2 = this_column.tier2
		var/list/tier3 = this_column.tier3

		if(!islist(this_column.tier1))
			tier1 = list(this_column.tier1)

		if(!islist(this_column.tier2))
			tier2 = list(this_column.tier2)

		if(!islist(this_column.tier3))
			tier3 = list(this_column.tier3)

		for(var/t1_knowledge in tier1)
			if(isnull(t1_knowledge)) // a side column may legitimately leave a tier unset (e.g. moon_to_lock has no tier1)
				continue
			if(neighbour_0.tier1)
				heretic_research_tree[t1_knowledge][HKT_NEXT] += neighbour_0.tier1
			if(neighbour_1.tier1)
				heretic_research_tree[t1_knowledge][HKT_NEXT] += neighbour_1.tier1
			heretic_research_tree[t1_knowledge][HKT_ROUTE] = this_column.route
			heretic_research_tree[t1_knowledge][HKT_UI_BGR] = this_column.ui_bgr
			heretic_research_tree[t1_knowledge][HKT_DEPTH] = 4

		for(var/t2_knowledge in tier2)
			if(isnull(t2_knowledge))
				continue
			if(neighbour_0.tier2)
				heretic_research_tree[t2_knowledge][HKT_NEXT] += neighbour_0.tier2
			if(neighbour_1.tier2)
				heretic_research_tree[t2_knowledge][HKT_NEXT] += neighbour_1.tier2
			heretic_research_tree[t2_knowledge][HKT_ROUTE] = this_column.route
			heretic_research_tree[t2_knowledge][HKT_UI_BGR] = this_column.ui_bgr
			heretic_research_tree[t2_knowledge][HKT_DEPTH] = 8

		for(var/t3_knowledge in tier3)
			if(isnull(t3_knowledge))
				continue
			if(neighbour_0.tier3)
				heretic_research_tree[t3_knowledge][HKT_NEXT] += neighbour_0.tier3
			if(neighbour_1.tier3)
				heretic_research_tree[t3_knowledge][HKT_NEXT] += neighbour_1.tier3
			heretic_research_tree[t3_knowledge][HKT_ROUTE] = this_column.route
			heretic_research_tree[t3_knowledge][HKT_UI_BGR] = this_column.ui_bgr
			heretic_research_tree[t3_knowledge][HKT_DEPTH] = 10

		if(this_column.abstract_parent_type != /datum/heretic_knowledge_tree_column/main)
			continue

		var/datum/heretic_knowledge_tree_column/main/main_column = this_column
		var/list/vertical_stages = list()
		vertical_stages += list(list(main_column.start))
		if(main_column.grasp)
			vertical_stages += list(list(main_column.grasp))
		vertical_stages += list(tier1)
		if(main_column.mark)
			vertical_stages += list(list(main_column.mark))
		if(main_column.ritual_of_knowledge)
			vertical_stages += list(list(main_column.ritual_of_knowledge))
		vertical_stages += list(list(main_column.unique_ability))
		vertical_stages += list(tier2)
		vertical_stages += list(list(main_column.blade))
		vertical_stages += list(tier3)
		vertical_stages += list(list(main_column.ascension))

		heretic_research_tree[/datum/heretic_knowledge/spell/basic] += main_column.start
		for(var/stage_index in 1 to length(vertical_stages) - 1)
			for(var/from_knowledge in vertical_stages[stage_index])
				for(var/to_knowledge in vertical_stages[stage_index + 1])
					heretic_research_tree[from_knowledge][HKT_NEXT] |= to_knowledge

		heretic_research_tree[main_column.start][HKT_BAN] += (start_blacklist - main_column.start) + (asc_blacklist - main_column.ascension)
		if(main_column.grasp)
			heretic_research_tree[main_column.grasp][HKT_BAN] += (grasp_blacklist - main_column.grasp)
		if(main_column.mark)
			heretic_research_tree[main_column.mark][HKT_BAN] += (mark_blacklist - main_column.mark)
		heretic_research_tree[main_column.blade][HKT_BAN] += (blade_blacklist - main_column.blade)

		heretic_research_tree[main_column.start][HKT_ROUTE] = main_column.route
		if(main_column.grasp)
			heretic_research_tree[main_column.grasp][HKT_ROUTE] = main_column.route
		if(main_column.mark)
			heretic_research_tree[main_column.mark][HKT_ROUTE] = main_column.route
		if(main_column.ritual_of_knowledge)
			heretic_research_tree[main_column.ritual_of_knowledge][HKT_ROUTE] = main_column.route
		heretic_research_tree[main_column.unique_ability][HKT_ROUTE] = main_column.route
		heretic_research_tree[main_column.blade][HKT_ROUTE] = main_column.route
		heretic_research_tree[main_column.ascension][HKT_ROUTE] = main_column.route

		heretic_research_tree[main_column.start][HKT_UI_BGR] = main_column.ui_bgr
		if(main_column.grasp)
			heretic_research_tree[main_column.grasp][HKT_UI_BGR] = main_column.ui_bgr
		if(main_column.mark)
			heretic_research_tree[main_column.mark][HKT_UI_BGR] = main_column.ui_bgr
		if(main_column.ritual_of_knowledge)
			heretic_research_tree[main_column.ritual_of_knowledge][HKT_UI_BGR] = main_column.ui_bgr
		heretic_research_tree[main_column.unique_ability][HKT_UI_BGR] = main_column.ui_bgr
		heretic_research_tree[main_column.blade][HKT_UI_BGR] = main_column.ui_bgr
		heretic_research_tree[main_column.ascension][HKT_UI_BGR] = main_column.ui_bgr
		heretic_research_tree[main_column.start][HKT_DEPTH] = 2
		if(main_column.grasp)
			heretic_research_tree[main_column.grasp][HKT_DEPTH] = 3
		if(main_column.mark)
			heretic_research_tree[main_column.mark][HKT_DEPTH] = 5
		if(main_column.ritual_of_knowledge)
			heretic_research_tree[main_column.ritual_of_knowledge][HKT_DEPTH] = 6
		heretic_research_tree[main_column.unique_ability][HKT_DEPTH] = 7
		heretic_research_tree[main_column.blade][HKT_DEPTH] = 9
		heretic_research_tree[main_column.ascension][HKT_DEPTH] = 11

		for(var/t2_knowledge in tier2)
			heretic_research_tree[t2_knowledge][HKT_NEXT] += /datum/heretic_knowledge/reroll_targets

		for(var/t1_knowledge in tier1)
			heretic_research_tree[t1_knowledge][HKT_NEXT] |= /datum/heretic_knowledge/codex_cicatrix

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
