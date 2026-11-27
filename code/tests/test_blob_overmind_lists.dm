/// Checks that a blob tile grown by one overmind from another overmind's tile is tracked and released only by its own overmind
/datum/unit_test/room_test/blob_cross_overmind_expand

/datum/unit_test/room_test/blob_cross_overmind_expand/Run()
	var/mob/camera/blob/attacking_overmind = allocate(/mob/camera/blob)
	var/mob/camera/blob/neighbour_overmind = allocate(/mob/camera/blob)
	var/turf/neighbour_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/turf/target_turf = get_step(neighbour_turf, EAST)
	var/obj/structure/blob/normal/neighbour_tile = allocate(/obj/structure/blob/normal, neighbour_turf, neighbour_overmind)

	var/obj/structure/blob/new_tile = neighbour_tile.expand(target_turf, attacking_overmind, expand_reaction = FALSE)
	TEST_ASSERT_NOTNULL(new_tile, "The blob tile did not expand into an empty floor")
	TEST_ASSERT_EQUAL(new_tile.overmind, attacking_overmind, "The new tile does not belong to the overmind that expanded it")
	TEST_ASSERT(new_tile in attacking_overmind.blobs_legit, "The new tile is not counted by the overmind that expanded it")
	if(new_tile in neighbour_overmind.blobs_legit)
		TEST_FAIL("The new tile is counted by the overmind that owns the tile it grew from")

	qdel(new_tile)
	for(var/mob/camera/blob/overmind as anything in GLOB.overminds)
		if(new_tile in overmind.all_blobs)
			TEST_FAIL("A destroyed blob tile is still in the all_blobs list of [overmind]")
		if(new_tile in overmind.blobs_legit)
			TEST_FAIL("A destroyed blob tile is still in the blobs_legit list of [overmind]")
