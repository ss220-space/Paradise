MOVEMENT_SUBSYSTEM_DEF(spacedrift)
	name = "Space Drift"
	priority = FIRE_PRIORITY_SPACEDRIFT
	flags = SS_NO_INIT|SS_TICKER
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	offline_implications = "Mobs will no longer respect a lack of gravity. No immediate action is needed."
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "space_drift"

