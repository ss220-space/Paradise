SUBSYSTEM_DEF(terraforming)
	name = "Terraforming"
	priority = FIRE_PRIORITY_TERRAFORMING
	wait = 2
	flags = SS_BACKGROUND | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	offline_implications = "Терраформации (например изменение вида лазиса) больше не будут функционировать. Не страшно, можно продолжать смену."
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "terraforming"
	var/queue/queue = new()


/datum/controller/subsystem/terraforming/proc/terraform(list/z_levels, list/transformations)
	for(var/z in z_levels)
		for(var/x = 1; x <= world.maxx; ++x)
			for(var/y = 1; y <= world.maxy; ++y)
				var/turf/turf = get_turf(locate(x, y, z))

				for(var/type in transformations)
					if(!istype(turf, type))
						continue

					queue.enqueue(list(turf, "[transformations[type]]")) // As type it was null after all.


#define CHANGES_PER_FIRE 200

/datum/controller/subsystem/terraforming/fire(resumed)
	for(var/num = 0; num < CHANGES_PER_FIRE && !queue.is_empty(); num++)
		var/list/data = queue.peek()
		var/turf/turf = data[1]
		turf.ChangeTurf(text2path(data[2]))
		queue.dequeue()
		if(MC_TICK_CHECK)
			return

#undef CHANGES_PER_FIRE


/proc/set_lazis_type(datum/lavaland_theme/lavaland_theme)
	if(istype(SSmapping.lavaland_theme, lavaland_theme))
		return

	SSmapping.lavaland_theme = new lavaland_theme
	for(var/client/client as anything in GLOB.clients)
		for(var/atom/movable/screen/parallax_layer/planet/planet in client.parallax_layers_cached)
			planet.icon_state = SSmapping.lavaland_theme.planet_icon_state

	/*
	var/list/transformations = list()
	for(var/datum/lavaland_theme/lava_theme as anything in subtypesof(/datum/lavaland_theme))
		transformations[lava_theme.primary_turf_type] = lavaland_theme.primary_turf_type

	SSterraforming.terraform(\
		list(level_name_to_num(MINING)), \
		transformations
	)
	*/

	for(var/turf in GLOB.lazis_primary_turfs)
		SSterraforming.queue.enqueue(list(turf, "[lavaland_theme.primary_turf_type]"))
