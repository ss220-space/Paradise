/datum/unit_test/room_test/detect_room

/datum/unit_test/room_test/detect_room/Run()
	var/turf/origin = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)

	for(var/turf/neighbor as anything in RANGE_TURFS(1, origin) - origin)
		allocate(/obj/structure/window/full/reinforced, neighbor)
	for(var/turf/beyond as anything in RANGE_TURFS(2, origin) - RANGE_TURFS(1, origin))
		beyond.ChangeTurf(/turf/simulated/floor/plating)

	if(!detect_room(origin, typecacheof(list(/turf/simulated/floor/plating))))
		TEST_FAIL("detect_room walked through full-tile windows and found what lies beyond them")
