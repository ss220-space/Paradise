/obj/effect/spawner/window
	name = "window spawner"
	icon = 'icons/obj/structures.dmi'
	icon_state = "window_spawner"
	var/useFull = 0
	var/useGrille = 1
	var/window_to_spawn_regular = /obj/structure/window/basic
	var/window_to_spawn_full = /obj/structure/window/full/basic
	anchored = TRUE // No sliding out while you prime

/obj/effect/spawner/window/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	for(var/obj/structure/grille/G in get_turf(src))
		// Complain noisily
		log_runtime(EXCEPTION("Extra grille on turf: ([T.x],[T.y],[T.z])"), src)
		qdel(G) //just in case mappers don't know what they are doing

	if(!useFull && window_to_spawn_regular)
		for(var/cdir in GLOB.cardinal)
			for(var/obj/effect/spawner/window/WS in get_step(src,cdir))
				cdir = null
				break
			if(!cdir)	continue
			var/obj/structure/window/WI = new window_to_spawn_regular(get_turf(src))
			sync_id(WI)
			WI.dir = cdir
	else
		var/obj/structure/window/W = new window_to_spawn_full(get_turf(src))
		W.dir = FULLTILE_WINDOW_DIR // THIS IS DUMB

	if(useGrille)
		new /obj/structure/grille(get_turf(src))

	air_update_turf(1) //atmos can pass otherwise
	// Give some time for nearby window spawners to initialize
	spawn(10)
		qdel(src)
	// why is this line a no-op
	// QDEL_IN(src, 10)

/obj/effect/spawner/window/proc/sync_id(obj/structure/window/reinforced/polarized/W)
	return


/obj/effect/spawner/window/reinforced
	name = "reinforced window spawner"
	icon_state = "rwindow_spawner"
	window_to_spawn_regular = /obj/structure/window/reinforced
	window_to_spawn_full = /obj/structure/window/full/reinforced

/obj/effect/spawner/window/reinforced/Initialize(mapload)
	. = ..()
	if(GLOB.new_year_celebration && is_station_level(z))
		new /obj/structure/garland(loc)

/obj/effect/spawner/window/reinforced/polarized
	name = "polarized reinforced window spawner"
	icon_state = "ewindow_spawner"
	window_to_spawn_regular = /obj/structure/window/reinforced/polarized
	window_to_spawn_full = /obj/structure/window/full/reinforced/tinted // Not polarized one
	/// Used to link electrochromic windows to buttons
	var/id

/obj/effect/spawner/window/reinforced/polarized/sync_id(obj/structure/window/reinforced/polarized/W)
	W.id = id

/obj/effect/spawner/window/reinforced/plasma
	name = "reinforced plasma window spawner"
	icon_state = "pwindow_spawner"
	window_to_spawn_regular = /obj/structure/window/plasmareinforced
	window_to_spawn_full = /obj/structure/window/full/plasmareinforced

/obj/effect/spawner/window/shuttle
	name = "shuttle window spawner"
	icon = 'icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "shuttle_window"
	useFull = TRUE
	window_to_spawn_regular = null
	window_to_spawn_full = /obj/structure/window/full/shuttle

/obj/effect/spawner/window/shuttle/gray
	icon = 'icons/obj/smooth_structures/shuttle_window_gray.dmi'
	icon_state = "shuttle_window_gray"
	window_to_spawn_regular = null
	window_to_spawn_full = /obj/structure/window/full/shuttle/gray

/obj/effect/spawner/window/shuttle/ninja
	icon = 'icons/obj/smooth_structures/shuttle_window_ninja.dmi'
	icon_state = "shuttle_window_ninja"
	window_to_spawn_regular = null
	window_to_spawn_full = /obj/structure/window/full/shuttle/ninja
