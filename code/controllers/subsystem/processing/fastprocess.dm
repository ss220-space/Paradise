//Fires five times every second.

PROCESSING_SUBSYSTEM_DEF(fastprocess)
	name = "Fast Processing"
	wait = 2
	stat_tag = "FP"
	flags = parent_type::flags & ~SS_HIBERNATE
	offline_implications = "Objects using the 'Fast Processing' processor will no longer process. Shuttle call recommended."
	ss_id = "fast_processing"
