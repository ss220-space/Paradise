SUBSYSTEM_DEF(hunger)
	name = "Hunger"
	flags = SS_NO_FIRE
	ss_id = "hunger"
	initialized = FALSE

/datum/controller/subsystem/hunger/Initialize()
	. = ..()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/hunger/LateInitialize()
	if(initialized)
		return
	InitHungerLevels()
	initialized = TRUE

/datum/controller/subsystem/hunger/proc/InitHungerLevels()
	return TRUE
