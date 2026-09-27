/datum/unit_test/headphone_case

/datum/unit_test/headphone_case/Run()
	var/obj/item/headphone_case/case = allocate(/obj/item/headphone_case)
	var/mob/living/carbon/human/listener = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/latecomer = allocate(/mob/living/carbon/human)

	if(case.icon_state != "case_white")
		TEST_FAIL("Headphone case did not start closed with both earbuds inside, its state was [case.icon_state]!")

	case.dispense_bud(listener, case.left_bud)
	if(case.left_bud.loc != listener)
		TEST_FAIL("Headphone case did not hand out an earbud!")
	if(case.icon_state != "case_white_open")
		TEST_FAIL("Headphone case did not open after handing out an earbud, its state was [case.icon_state]!")

	case.toggle_power()
	if(case.icon_state != "case_white_open_on")
		TEST_FAIL("Headphone case did not light up after being turned on, its state was [case.icon_state]!")

	var/list/open_data = case.ui_data(listener)
	if(open_data["left_bud_overlay"] || !open_data["right_bud_overlay"])
		TEST_FAIL("The panel drew the wrong earbuds for an open case holding only the right one!")

	listener.equip_to_slot_if_possible(case.left_bud, ITEM_SLOT_EAR_LEFT, disable_warning = TRUE)
	if(listener.l_ear != case.left_bud)
		TEST_FAIL("The earbud could not be worn in an ear slot!")

	var/datum/track/track = new("Test Track", 'sound/misc/disco.ogg', 1 MINUTES)
	case.play_track(track)
	if(!(listener in case.player.get_active_listeners()))
		TEST_FAIL("Headphone case did not play music to the mob wearing its earbud!")
	if(isnull(case.player.active_song_sound))
		TEST_FAIL("Headphone case did not build its sound when the track started, so late listeners cannot be synced!")

	case.dispense_bud(listener, case.right_bud)
	listener.equip_to_slot_if_possible(case.right_bud, ITEM_SLOT_EAR_RIGHT, disable_warning = TRUE)
	if(listener.r_ear != case.right_bud)
		TEST_FAIL("The second earbud could not be worn in the other ear!")

	listener.drop_item_ground(case.right_bud, force = TRUE)
	if(!(listener in case.player.get_active_listeners()))
		TEST_FAIL("Headphone case stopped the music when one of the two earbuds a mob was wearing came out!")

	case.player.start_time = world.time - 30 SECONDS
	latecomer.put_in_hands(case.right_bud)
	latecomer.equip_to_slot_if_possible(case.right_bud, ITEM_SLOT_EAR_RIGHT, disable_warning = TRUE)
	if(!(latecomer in case.player.get_active_listeners()))
		TEST_FAIL("Headphone case did not pick up a mob that put an earbud in mid track!")
	if(case.player.active_song_sound.offset)
		TEST_FAIL("Headphone case left a seek offset on its sound, so every later update would rewind the track!")

	listener.drop_item_ground(case.left_bud, force = TRUE)
	if(listener in case.player.get_active_listeners())
		TEST_FAIL("Headphone case kept playing music to a mob that took the earbud out!")
	if(!(latecomer in case.player.get_active_listeners()))
		TEST_FAIL("Headphone case stopped playing to the other listener when one of them took their earbud out!")

	latecomer.drop_item_ground(case.right_bud, force = TRUE)
	listener.put_in_hands(case.left_bud)
	case.item_interaction(listener, case.left_bud)
	listener.put_in_hands(case.right_bud)
	case.item_interaction(listener, case.right_bud)
	if(case.left_bud.loc != case || case.right_bud.loc != case)
		TEST_FAIL("Headphone case did not take its earbuds back!")
	if(case.icon_state != "case_white_on")
		TEST_FAIL("Headphone case did not close after both earbuds were back inside, its state was [case.icon_state]!")

	var/list/closed_data = case.ui_data(listener)
	if(closed_data["left_bud_overlay"] || closed_data["right_bud_overlay"])
		TEST_FAIL("The panel drew earbuds on top of a closed case!")

	case.toggle_power()
	if(!isnull(case.song_timerid))
		TEST_FAIL("Headphone case kept its track running after being turned off!")

	text2file("unit test leftovers", "[SONG_CACHE_DIRECTORY]/unit_test.mp3")
	if(!fexists("[SONG_CACHE_DIRECTORY]/unit_test.mp3"))
		TEST_FAIL("Could not seed the song cache, the cleanup check below proves nothing!")
	SSsounds.clear_song_cache()
	if(length(flist("[SONG_CACHE_DIRECTORY]/")))
		TEST_FAIL("The song cache still had tracks in it after being cleared!")
