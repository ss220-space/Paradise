/datum/unit_test/spell_targeting/Run()
	var/list/bad_spells = list()
	for(var/obj/effect/proc_holder/spell/spell as anything in typesof(/obj/effect/proc_holder/spell))
		// I don't want to assign abstract types to this legacy. - littleboobs
		if(initial(spell.name) == "Spell")
			continue // Skip abstract spells
		spell = new spell
		if(!spell.targeting)
			bad_spells += spell
	if(length(bad_spells))
		TEST_FAIL("Spells without targeting found: [bad_spells.Join(", ")]")
