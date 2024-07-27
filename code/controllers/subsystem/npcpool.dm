#ifdef UNIT_TESTS
GLOBAL_VAR_INIT(npcpool_suspension, FALSE)
#else
GLOBAL_VAR_INIT(npcpool_suspension, TRUE)
#endif

#define DEFAULT_ACTIONS_DELAY (0.5 SECONDS)

SUBSYSTEM_DEF(npcpool)
	name = "NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 2 SECONDS
	offline_implications = "Simple animals will no longer process. Shuttle call recommended."
	ss_id = "npc_pool"

	var/list/currentrun = list()


/datum/controller/subsystem/npcpool/get_stat_details()
	return "SimpleAnimals: [length(GLOB.simple_animals[AI_ON])]"


/datum/controller/subsystem/npcpool/fire(resumed = FALSE)
	if(!resumed)
		var/list/activelist = GLOB.simple_animals[AI_ON]
		src.currentrun = activelist.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	//var/suspension = GLOB.npcpool_suspension

	while(currentrun.len)
		var/mob/living/simple_animal/SA = currentrun[currentrun.len]
		--currentrun.len

		if(QDELETED(SA)) // Some issue causes nulls to get into this list some times. This keeps it running, but the bug is still there.
			GLOB.simple_animals[AI_ON] -= SA
			stack_trace("Found a null in simple_animals active list [SA?.type]!")
			continue

		//var/turf/T = get_turf(SA)
		//if(suspension && T && !length(SSmobs.clients_by_zlevel[T.z]))
		//	continue

		if(!SA.ckey && SA.AI_delay_current <= world.time && !HAS_TRAIT(SA, TRAIT_NO_TRANSFORM))
			SA.AI_delay_current = world.time + wait + rand(DEFAULT_ACTIONS_DELAY, max(DEFAULT_ACTIONS_DELAY, SA.AI_delay_max))

			if(SA.stat != DEAD)
				SA.handle_automated_movement()
			if(SA.stat != DEAD)
				SA.handle_automated_action()
			if(SA.stat != DEAD)
				SA.handle_automated_speech()

		if(MC_TICK_CHECK)
			return


#undef DEFAULT_ACTIONS_DELAY

