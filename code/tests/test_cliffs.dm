/datum/unit_test/room_test/cliff_falling
	var/list/turf/original_types = list()

/datum/unit_test/room_test/cliff_falling/Destroy()
	for(var/turf/tile as anything in original_types)
		tile.ChangeTurf(original_types[tile])
	return ..()

/datum/unit_test/room_test/cliff_falling/Run()
	var/turf/anchor = run_loc_floor_bottom_left
	var/list/turf/simulated/floor/cliff/ledge = list()

	for(var/offset in 1 to 4)
		var/turf/tile = locate(anchor.x, anchor.y + offset, anchor.z)
		original_types[tile] = tile.type
		ledge += tile.ChangeTurf(/turf/simulated/floor/cliff/snowrock)

	var/turf/top = ledge[4]
	var/turf/bottom = locate(anchor.x, anchor.y, anchor.z)

	var/mob/living/carbon/human/climber = allocate(/mob/living/carbon/human)
	climber.forceMove(top)
	TEST_ASSERT(climber in SScliff_falling.cliff_grinders, "standing on a cliff did not start a fall")

	sleep(2 SECONDS)

	TEST_ASSERT_EQUAL(get_turf(climber), bottom, "the faller did not grind all the way down the cliff")
	TEST_ASSERT(!(climber in SScliff_falling.cliff_grinders), "the faller was not released after leaving the cliff")

	var/mob/living/carbon/human/cliff_walker = allocate(/mob/living/carbon/human)
	cliff_walker.AddElement(/datum/element/cliff_walking)
	TEST_ASSERT(HAS_TRAIT(cliff_walker, TRAIT_CLIFF_WALKER), "the cliff walking element granted no trait")

	cliff_walker.forceMove(top)
	TEST_ASSERT(!(cliff_walker in SScliff_falling.cliff_grinders), "a cliff walker started falling anyway")
	TEST_ASSERT_EQUAL(get_turf(cliff_walker), top, "a cliff walker was moved off its ledge")

	cliff_walker.death()
	TEST_ASSERT(cliff_walker in SScliff_falling.cliff_grinders, "a dead cliff walker kept its footing")
