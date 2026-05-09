SUBSYSTEM_DEF(ipintel)
	name = "XKeyScore"
	wait = 1
	ss_flags = SS_NO_FIRE

	/// Are we enabled? Auto disable at world init to avoid checking reconnects
	var/enabled = FALSE
	var/throttle = 0
	var/errors = 0

	var/list/cache = list()

/datum/controller/subsystem/ipintel/Initialize()
	enabled = TRUE
	return SS_INIT_SUCCESS
