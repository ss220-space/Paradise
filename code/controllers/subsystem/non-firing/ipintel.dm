SUBSYSTEM_DEF(ipintel)
	name = "XKeyScore"
	wait = 1
	ss_flags = SS_NO_INIT|SS_NO_FIRE

	var/enabled = FALSE //disable at round start to avoid checking reconnects
	var/throttle = 0
	var/errors = 0

	var/list/cache = list()

/datum/controller/subsystem/ipintel/Initialize()
	enabled = TRUE
	return SS_INIT_SUCCESS
