/datum/unit_test/emote/Run()
	// Be aware that some of these values (like message, message_param) are subject to being set at runtime.
	for(var/emote_type in subtypesof(/datum/emote))
		var/datum/emote/cur_emote = new emote_type()
		if(cur_emote.message_param && !cur_emote.param_desc)
			TEST_FAIL("emote [cur_emote] was given a message parameter without a description.")

		// Sanity checks, these emotes probably won't appear to a user but we should make sure they're cleaned up.
		if(!cur_emote.key)
			// Ignoring abstract classes that may have a message for inheritance. Refactor without unit tests moment. -littleboobs
			var/is_abstract = length(typesof(emote_type)) > 1 // there are subtypes
			if((cur_emote.message || cur_emote.message_param) && !is_abstract)
				TEST_FAIL("emote [cur_emote] is missing a key but has a message defined.")
			if(cur_emote.key_third_person)
				TEST_FAIL("emote [cur_emote] has a third-person key defined, but no first-person key. Either first person, both, or neither should be defined.")

		// These are ones that might appear to a user, and so could use some special handling.
		else
			TEST_ASSERT_NOTNULL(cur_emote.emote_type, "emote [cur_emote] has a null target type.")

		if(isnum(cur_emote.max_stat_allowed) && cur_emote.max_stat_allowed < cur_emote.stat_allowed)
			TEST_FAIL("emote [cur_emote]'s max_stat_allowed is greater than its stat_allowed, and would be unusable.")

		if(isnum(cur_emote.max_unintentional_stat_allowed) && cur_emote.max_unintentional_stat_allowed < cur_emote.unintentional_stat_allowed)
			TEST_FAIL("emote [cur_emote]'s max_unintentional_stat_allowed is greater than its unintentional_stat_allowed, and would be unusable.")
