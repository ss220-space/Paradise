/datum/unit_test/reagent_id_typos

/datum/unit_test/reagent_id_typos/Run()
	for(var/I in GLOB.chemical_reactions_list)
		for(var/V in GLOB.chemical_reactions_list[I])
			var/datum/chemical_reaction/R = V
			for(var/reagent_type in (R.required_reagents + R.required_catalysts))
				TEST_ASSERT(ispath(reagent_type), "Non-path reagent \"[reagent_type]\" in recipe [R.type]")
				TEST_ASSERT(GLOB.chemical_reagents_list[reagent_type], "Unknown reagent path \"[reagent_type]\" in recipe [R.type]")
