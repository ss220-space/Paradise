/// This test spawns various station traits and looks through them to see if there's any errors.
/datum/unit_test/station_traits

/datum/unit_test/station_traits/Run()
	var/datum/station_trait/cybernetic_revolution/cyber_trait = allocate(/datum/station_trait/cybernetic_revolution)
	for(var/datum/job/job as anything in valid_subtypesof(/datum/job))
		// TODO ksaikok replace all this bullshit with TG test when(if) someone refactors job datums
		if(job.admin_only || job.hidden_from_job_prefs)
			continue
		if(initial(job.department) == STATION_DEPARTMENT_SILICON)
			continue
		//if((initial(job.job_flags) & STATION_TRAIT_JOB_FLAGS) == STATION_TRAIT_JOB_FLAGS)
		//	continue
		if(!(job in cyber_trait.job_to_cybernetic))
			TEST_FAIL("Job [job] does not have an assigned cybernetic for [cyber_trait.type] station trait.")
