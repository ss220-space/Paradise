/datum/game_test/room_test/spawn_humans/Run()
	for(var/I in 1 to 5)
		allocate(/mob/living/carbon/human, pick(available_turfs))

	// There is a 5 second delay here so that all the items on the humans have time to initialize and spawn
	sleep(5 SECONDS)

/// Tests [/mob/living/carbon/human/proc/setup_organless_effects], specifically that they aren't applied when init is done
/datum/game_test/room_test/human_default_traits

/datum/game_test/room_test/human_default_traits/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human)
	TEST_ASSERT(!HAS_TRAIT_FROM(dummy, TRAIT_DEAF, NO_EARS), "Dummy is deaf on init, when it should've been removed by its default ears.")
