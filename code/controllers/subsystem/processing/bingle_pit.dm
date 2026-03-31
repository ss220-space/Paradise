PROCESSING_SUBSYSTEM_DEF(bingle_pit)
	name = "Bingle Pit Processing"
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING|SS_NO_INIT|SS_HIBERNATE
	wait = 0.2 SECONDS
	offline_implications = "Bingle pits will no longer work. No immediate action is needed."
	ss_id = "bingle_pit"
	stat_tag = "BP"
