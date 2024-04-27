/datum/asset/simple/rpd/register()
	for(var/state in icon_states('icons/obj/pipes_and_stuff/atmospherics/pipe-item.dmi'))
		if(!(state in list("cap", "connector", "dtvalve", "dual-port vent", "dvalve", "filter", "he", "heunary", "injector", "junction", "manifold", "mixer", "tvalve", "mvalve", "passive vent", "passivegate", "pump", "scrubber", "simple", "universal", "uvent", "volumepump", "multiz"))) //Basically all the pipes we want sprites for
			continue
		if(state in list("he", "simple"))
			for(var/D in GLOB.alldirs)
				assets["[state]-[dir2text(D)].png"] = icon('icons/obj/pipes_and_stuff/atmospherics/pipe-item.dmi', state, D)
		for(var/D in GLOB.cardinal)
			assets["[state]-[dir2text(D)].png"] = icon('icons/obj/pipes_and_stuff/atmospherics/pipe-item.dmi', state, D)
	for(var/state in icon_states('icons/obj/pipes_and_stuff/not_atmos/disposal.dmi'))
		if(!(state in list("pipe-c", "pipe-j1", "pipe-s", "pipe-t", "pipe-y", "intake", "outlet", "pipe-j1s","pipe-up", "pipe-down"))) //Pipes we want sprites for
			continue
		for(var/D in GLOB.cardinal)
			assets["[state]-[dir2text(D)].png"] = icon('icons/obj/pipes_and_stuff/not_atmos/disposal.dmi', state, D)

	return ..()
