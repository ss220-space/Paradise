#ifdef UNIT_TESTS
GLOBAL_VAR_INIT(idlenpc_suspension, FALSE)
#else
GLOBAL_VAR_INIT(idlenpc_suspension, TRUE)
#endif

#define DEFAULT_CHECKS_DELAY (4 SECONDS)

SUBSYSTEM_DEF(idlenpcpool)
	name = "Idling NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_IDLE_NPC
	wait = 6 SECONDS
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_IDLENPCS // MUST be after SSmapping since it tracks max Zs
	offline_implications = "Idle simple animals will no longer process. Shuttle call recommended."
	ss_id = "idle_npc_pool"

	var/list/currentrun = list()
	var/static/list/idle_mobs_by_zlevel[][]


/datum/controller/subsystem/idlenpcpool/get_stat_details()
	return "IdleNPCS:[length(GLOB.simple_animals[AI_IDLE])]|Z:[length(GLOB.simple_animals[AI_Z_OFF])]"


/datum/controller/subsystem/idlenpcpool/proc/MaxZChanged()
	if(!islist(idle_mobs_by_zlevel))
		idle_mobs_by_zlevel = new /list(world.maxz,0)
	while(SSidlenpcpool.idle_mobs_by_zlevel.len < world.maxz)
		SSidlenpcpool.idle_mobs_by_zlevel.len++
		SSidlenpcpool.idle_mobs_by_zlevel[idle_mobs_by_zlevel.len] = list()


/datum/controller/subsystem/idlenpcpool/fire(resumed = FALSE)
	if(!resumed)
		var/list/idlelist = GLOB.simple_animals[AI_IDLE]
		src.currentrun = idlelist.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	//var/suspension = GLOB.idlenpc_suspension

	while(currentrun.len)
		var/mob/living/simple_animal/SA = currentrun[currentrun.len]
		--currentrun.len
		if(QDELETED(SA))
			GLOB.simple_animals[AI_IDLE] -= SA
			stack_trace("Found a null in simple_animals deactive list [SA?.type]!")
			continue

		//var/turf/T = get_turf(SA)
		//if(suspension && T && !length(SSmobs.clients_by_zlevel[T.z]))
		//	continue

		if(!SA.ckey && SA.AI_delay_current <= world.time)
			SA.AI_delay_current = world.time + wait + rand(DEFAULT_CHECKS_DELAY)

			if(SA.stat != DEAD)
				SA.handle_automated_movement()
			if(SA.stat != DEAD)
				SA.consider_wakeup()

		if(MC_TICK_CHECK)
			return


#undef DEFAULT_CHECKS_DELAY

