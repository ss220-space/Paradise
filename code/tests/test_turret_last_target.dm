/// Checks that a turret forgets the target it fired at once that target is deleted.
/datum/unit_test/room_test/turret_forgets_deleted_target

/datum/unit_test/room_test/turret_forgets_deleted_target/Run()
	var/obj/machinery/porta_turret/syndicate/turret = allocate(/obj/machinery/porta_turret/syndicate)
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/brood = allocate(/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion, run_loc_floor_top_right)

	// Puts the turret on cooldown so it aims without firing a projectile.
	turret.last_fired = world.time
	TEST_ASSERT(turret.target(brood), "The turret did not take the target")
	TEST_ASSERT_EQUAL(turret.last_target, brood, "The turret did not remember its target")

	qdel(brood)

	if(turret.last_target)
		TEST_FAIL("The turret kept its deleted target in last_target")

/// Checks that a turret switching between targets keeps the live one when an earlier target is deleted.
/datum/unit_test/room_test/turret_keeps_live_target_after_switch

/datum/unit_test/room_test/turret_keeps_live_target_after_switch/Run()
	var/obj/machinery/porta_turret/syndicate/turret = allocate(/obj/machinery/porta_turret/syndicate)
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/first = allocate(/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion, run_loc_floor_top_right)
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/second = allocate(/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion, run_loc_floor_top_right)

	turret.last_fired = world.time
	turret.target(first)
	turret.target(second)
	turret.target(first)
	turret.target(second)

	qdel(first)

	TEST_ASSERT_EQUAL(turret.last_target, second, "The turret lost its live target when an earlier target was deleted")

/// Checks that a turret which is switched off drops deleted mobs from the targets it tracks.
/datum/unit_test/room_test/turret_off_drops_deleted_targets

/datum/unit_test/room_test/turret_off_drops_deleted_targets/Run()
	var/obj/machinery/porta_turret/syndicate/turret = allocate(/obj/machinery/porta_turret/syndicate)
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/brood = allocate(/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion, run_loc_floor_top_right)

	turret.enabled = FALSE
	turret.handleInterloper(brood)
	TEST_ASSERT(turret.processing_targets[brood], "The turret did not track the mob")

	qdel(brood)
	turret.process()

	if(length(turret.processing_targets))
		TEST_FAIL("The switched off turret kept a deleted mob in processing_targets")
