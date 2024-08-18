SUBSYSTEM_DEF(statistics)
	name = "Statistics"
	wait = 6000 // 10 minute delay between fires
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME // Only count time actually ingame to avoid logging pre-round dips
	offline_implications = "Player count and admin count statistics will no longer be logged to the database. No immediate action is needed."
	ss_id = "statistics"


/datum/controller/subsystem/statistics/Initialize()
	if(!CONFIG_GET(flag/sql_enabled))
		flags |= SS_NO_FIRE // Disable firing if SQL is disabled
	return SS_INIT_SUCCESS


/datum/controller/subsystem/statistics/fire(resumed = 0)
	sql_poll_players()


/datum/controller/subsystem/statistics/proc/sql_poll_players()
	if(!SSdbcore.IsConnected())
		return
	else
		var/datum/db_query/statquery = SSdbcore.NewQuery(
			"INSERT INTO [format_table_name("legacy_population")] (playercount, admincount, time, server_id) VALUES (:playercount, :admincount, NOW(), :server_id)",
			list(
				"playercount" = length(GLOB.clients),
				"admincount" = length(GLOB.admins),
				"server_id" = CONFIG_GET(string/instance_id)
			)
		)
		statquery.warn_execute()
		qdel(statquery)
