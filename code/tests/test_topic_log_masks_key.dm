/// Checks that world/Topic writes the comms key to the game log only as a mask, and still hands the real key to the handler.
/datum/unit_test/topic_log_masks_key

/datum/unit_test/topic_log_masks_key/Run()
	var/marker = "topiclogkey[rand(100000, 999999)]"
	var/reply = world.Topic("unit_test_key_echo=1&key=[marker]", "127.0.0.1")
	TEST_ASSERT_EQUAL(reply, marker, "The handler did not get the key that was sent")

	var/game_log = file2text(GLOB.world_game_log)
	TEST_ASSERT(findtext(game_log, "WORLD/TOPIC: \"unit_test_key_echo=1&key=SECRET\""), "The topic log line with the masked key was not found")
	TEST_ASSERT(!findtext(game_log, marker), "The topic log line contains the comms key")

/// Replies with the key it was given, so the test above can see what handlers receive.
/datum/world_topic_handler/unit_test_key_echo
	topic_key = "unit_test_key_echo"

/datum/world_topic_handler/unit_test_key_echo/execute(list/input, key_valid)
	return input["key"]
