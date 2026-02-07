SUBSYSTEM_DEF(iconforge_cache_clearing)
	name = "Iconforge cache clearing"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY|RUNLEVELS_DEFAULT
	wait = 30 MINUTES

/datum/controller/subsystem/fire(resumed)
	if(SSasset_loading.assets_generating)
		wait = 1 MINUTES
		return
	rustlib_iconforge_cleanup_all()
	wait = 30 MINUTES
