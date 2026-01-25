/datum/game_test/admin_verb_unique_names/Run()
	var/list/seen_names = list()
	for(var/type in SSadmin_verbs.admin_verbs_by_type)
		var/datum/admin_verb/verb = SSadmin_verbs.admin_verbs_by_type[type]
		if(!verb)
			continue

		var/name = verb.name
		if(!name || name == "")
			continue

		if(seen_names[name])
			var/conflicting_type = seen_names[name]
			TEST_FAIL("Admin verb's name '[name]' is duplicated in [type] and [conflicting_type].")
		else
			seen_names[name] = type
