/datum/unit_test/heretic_knowledge

/datum/unit_test/heretic_knowledge/Run()
	var/list/tree = generate_heretic_research_tree()

	var/list/reachable = list()
	var/list/queue = GLOB.heretic_start_knowledge.Copy()
	var/list/all_knowledge = valid_subtypesof(/datum/heretic_knowledge)
	for(var/datum/heretic_knowledge/knowledge_type as anything in all_knowledge)
		if(knowledge_type::drafting_tier > 0)
			queue += knowledge_type

	var/i = 0
	while(i < length(queue))
		var/datum/heretic_knowledge/node = queue[++i]
		if(reachable[node])
			continue
		reachable[node] = TRUE
		var/list/tree_entry = tree[node]
		for(var/next in tree_entry?[HKT_NEXT])
			if(!reachable[next])
				queue += next

	for(var/datum/heretic_knowledge/knowledge_type as anything in all_knowledge)
		if(reachable[knowledge_type])
			continue
		TEST_FAIL("Heretic Knowledge: [knowledge_type] is unreachable by players! Wire it into a path (knowledge_tier/robes/blade/ascension), give it a drafting_tier for the side pool, or mark is_starting_knowledge.")
