//Global typecache of all heretic knowledges -> instantiate the tree columns -> make them link themselves -> replace the old heretic stuff

//heretic research tree is a directional graph so we can use some basic graph stuff to make internally handling it easier
GLOBAL_LIST(heretic_research_tree)

//HKT = Heretic Knowledge Tree (Heretic Research Tree :3) these objects really only exist for a short period of time at startup and then get deleted
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

	// --- "Path Info" tab metadata (TG-style; shown before/while choosing the path) ---
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

	//Initialize the data structure
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
		// grasp/mark are optional: TG-style paths (e.g. Ash) fold those effects into the starting
		// knowledge and have no separate node, so only blacklist them when present.
		if(column.grasp)
			grasp_blacklist += column.grasp
		if(column.mark)
			mark_blacklist += column.mark
		blade_blacklist += column.blade
		asc_blacklist += column.ascension

	heretic_research_tree[/datum/heretic_knowledge/spell/basic][HKT_NEXT] += start_blacklist

	for(var/id in paths)
		var/datum/heretic_knowledge_tree_column/this_column = paths[id]
		var/datum/heretic_knowledge_tree_column/neighbour_0 = paths[this_column.neighbour_type_left]
		var/datum/heretic_knowledge_tree_column/neighbour_1 = paths[this_column.neighbour_type_right]
		//horizontal (two way)
		var/list/tier1 = this_column.tier1
		var/list/tier2 = this_column.tier2
		var/list/tier3 = this_column.tier3

		//Tier1, 2 and 3 can technically be lists so we handle them here
		if(!islist(this_column.tier1))
			tier1 = list(this_column.tier1)

		if(!islist(this_column.tier2))
			tier2 = list(this_column.tier2)

		if(!islist(this_column.tier3))
			tier3 = list(this_column.tier3)

		for(var/t1_knowledge in tier1)
			heretic_research_tree[t1_knowledge][HKT_NEXT] += neighbour_0.tier1
			heretic_research_tree[t1_knowledge][HKT_NEXT] += neighbour_1.tier1
			heretic_research_tree[t1_knowledge][HKT_ROUTE] = this_column.route
			heretic_research_tree[t1_knowledge][HKT_UI_BGR] = this_column.ui_bgr
			heretic_research_tree[t1_knowledge][HKT_DEPTH] = 4

		for(var/t2_knowledge in tier2)
			heretic_research_tree[t2_knowledge][HKT_NEXT] += neighbour_0.tier2
			heretic_research_tree[t2_knowledge][HKT_NEXT] += neighbour_1.tier2
			heretic_research_tree[t2_knowledge][HKT_ROUTE] = this_column.route
			heretic_research_tree[t2_knowledge][HKT_UI_BGR] = this_column.ui_bgr
			heretic_research_tree[t2_knowledge][HKT_DEPTH] = 8

		for(var/t3_knowledge in tier3)
			heretic_research_tree[t3_knowledge][HKT_NEXT] += neighbour_0.tier3
			heretic_research_tree[t3_knowledge][HKT_NEXT] += neighbour_1.tier3
			heretic_research_tree[t3_knowledge][HKT_ROUTE] = this_column.route
			heretic_research_tree[t3_knowledge][HKT_UI_BGR] = this_column.ui_bgr
			heretic_research_tree[t3_knowledge][HKT_DEPTH] = 10

		//Everything below this line is considered to be a "main path" and not a side path
		//Since we are handling the heretic research tree column by column this is required
		if(this_column.abstract_parent_type != /datum/heretic_knowledge_tree_column/main)
			continue

		var/datum/heretic_knowledge_tree_column/main/main_column = this_column
		//vertical (one way) — build an ordered chain of stages, then link each stage to the next.
		//Optional slots (grasp/mark/ritual_of_knowledge) are skipped when null, so a TG-style path
		//like Ash (which folds the grasp blind + mark into its starting knowledge) links straight
		//through start -> tier1 -> ... without empty hops.
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

		//blacklist
		heretic_research_tree[main_column.start][HKT_BAN] += (start_blacklist - main_column.start) + (asc_blacklist - main_column.ascension)
		if(main_column.grasp)
			heretic_research_tree[main_column.grasp][HKT_BAN] += (grasp_blacklist - main_column.grasp)
		if(main_column.mark)
			heretic_research_tree[main_column.mark][HKT_BAN] += (mark_blacklist - main_column.mark)
		heretic_research_tree[main_column.blade][HKT_BAN] += (blade_blacklist - main_column.blade)

		//route stuff
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
		//depth stuff
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

		//Per path bullshit goes here \/\/\/
		for(var/t2_knowledge in tier2)
			heretic_research_tree[t2_knowledge][HKT_NEXT] += /datum/heretic_knowledge/reroll_targets

	// If you want to do any custom bullshit put it here \/\/\/
	heretic_research_tree[/datum/heretic_knowledge/reroll_targets][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/reroll_targets][HKT_DEPTH] = 8

	// The Codex Cicatrix is a Knowledge Shop (side) purchase available from the very start, rather than a
	// free starting craft (matching TG). Reachable straight off the root knowledge so it shows immediately.
	heretic_research_tree[/datum/heretic_knowledge/spell/basic][HKT_NEXT] |= /datum/heretic_knowledge/codex_cicatrix
	heretic_research_tree[/datum/heretic_knowledge/codex_cicatrix][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/codex_cicatrix][HKT_DEPTH] = 2

	heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_NEXT] += /datum/heretic_knowledge/rifle_ammo
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_DEPTH] = heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_DEPTH]

	//and we're done
	QDEL_LIST_ASSOC_VAL(paths)
	return heretic_research_tree
