/obj/lavalake_landmark
	name = "lavalake"
	icon = 'icons/misc/Testing/turf_analysis.dmi'
	icon_state = "lavalake_landmark"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE

/obj/lavalake_landmark/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(load_map))

/obj/lavalake_landmark/proc/load_map()
	var/turf/spawn_area = get_turf(src)

	var/datum/map_template/ruin/lavaland/lavalake/map = new()

	map.load(spawn_area, TRUE)

	qdel(src, force=TRUE)
