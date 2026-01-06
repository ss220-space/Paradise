SUBSYSTEM_DEF(turfs_visualization)
	name = "Turfs visualization"
	priority = FIRE_PRIORITY_TURFS_VISUALIZATION
	wait = 30 SECONDS
	flags = SS_BACKGROUND | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	cpu_display = SS_CPUDISPLAY_LOW
	var/list/turfs_visualisation = list()

/datum/controller/subsystem/turfs_visualization/Recover()
	turfs_visualisation = SSturfs_visualization.turfs_visualisation

/datum/controller/subsystem/turfs_visualization/fire(resumed)
	if(!length(turfs_visualisation))
		return

	var/list/current_run = turfs_visualisation
	for(var/i in length(turfs_visualisation) to 1 step -1)
		var/turf/simulated/tile = current_run[i]
		tile.update_visuals()
		if(MC_TICK_CHECK)
			turfs_visualisation.Cut(i)
			return

	turfs_visualisation.Cut()
