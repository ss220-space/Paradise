PROCESSING_SUBSYSTEM_DEF(wet_floors)
	name = "Wet floors"
	priority = FIRE_PRIORITY_WET_FLOORS
	wait = 1 SECONDS
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING|SS_NO_INIT|SS_HIBERNATE
	stat_tag = "WFP" //Used for logging
	ss_id = "wet_floors"
	var/temperature_coeff = 2
	var/time_ratio = 1.5 SECONDS

