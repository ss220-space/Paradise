/// Checks that a slime forgets a mob that is deleted while it is the slime's target, leader or friend.
/datum/unit_test/room_test/slime_forgets_deleted_mobs

/datum/unit_test/room_test/slime_forgets_deleted_mobs/Run()
	var/mob/living/simple_animal/slime/slime = allocate(/mob/living/simple_animal/slime)
	var/mob/living/simple_animal/slime/target = allocate(/mob/living/simple_animal/slime)
	var/mob/living/simple_animal/slime/leader = allocate(/mob/living/simple_animal/slime)
	var/mob/living/simple_animal/slime/friend = allocate(/mob/living/simple_animal/slime)

	slime.set_target(target)
	slime.set_leader(leader)
	slime.add_friend(friend)
	TEST_ASSERT_EQUAL(slime.Target, target, "The slime did not take the target")
	TEST_ASSERT_EQUAL(slime.Leader, leader, "The slime did not take the leader")
	TEST_ASSERT(friend in slime.Friends, "The slime did not take the friend")

	qdel(target)
	qdel(leader)
	qdel(friend)

	if(slime.Target)
		TEST_FAIL("The slime kept its deleted target in Target")
	if(slime.Leader)
		TEST_FAIL("The slime kept its deleted leader in Leader")
	if(friend in slime.Friends)
		TEST_FAIL("The slime kept its deleted friend in Friends")

/// Checks that the vent clog event lets go of its vents once it is killed.
/datum/unit_test/room_test/vent_clog_kill_clears_vents

/datum/unit_test/room_test/vent_clog_kill_clears_vents/Run()
	var/obj/machinery/atmospherics/unary/vent_scrubber/vent = allocate(/obj/machinery/atmospherics/unary/vent_scrubber)
	var/datum/event/vent_clog/event = allocate(/datum/event/vent_clog, null, TRUE)
	event.vents += vent

	event.kill()

	TEST_ASSERT_EQUAL(length(event.vents), 0, "The vent clog event kept its vents after kill()")
