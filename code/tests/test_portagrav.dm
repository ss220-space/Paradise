/datum/unit_test/room_test/portagrav

/datum/unit_test/room_test/portagrav/Run()
	var/obj/machinery/power/portagrav/generator = allocate(/obj/machinery/power/portagrav)
	var/turf/near_edge = locate(generator.x + 1, generator.y, generator.z)
	var/turf/far_edge = locate(generator.x + 5, generator.y, generator.z)
	var/mob/living/carbon/human/engineer = allocate(/mob/living/carbon/human)
	var/obj/item/stock_parts/cell/power_cell = allocate(/obj/item/stock_parts/cell/high)
	engineer.put_in_hands(power_cell)

	if(generator.cell)
		TEST_FAIL("Portagrav came with a free cell instead of an empty slot!")
	if(generator.item_interaction(engineer, power_cell) != ITEM_INTERACT_BLOCKING)
		TEST_FAIL("Portagrav took a cell through a closed panel!")

	generator.toggle_panel_open()
	if(generator.item_interaction(engineer, power_cell) != ITEM_INTERACT_SUCCESS)
		TEST_FAIL("Portagrav refused a cell with the panel open!")
	if(generator.cell != power_cell)
		TEST_FAIL("Portagrav did not store the inserted cell!")
	generator.toggle_panel_open()

	generator.turn_on()
	if(generator.on)
		TEST_FAIL("Portagrav turned on while unanchored!")

	generator.anchored = TRUE
	generator.tiles_per_level = 2
	generator.turn_on()
	if(!generator.on)
		TEST_FAIL("Portagrav refused to turn on while anchored with a charged cell!")
	if(!HAS_TRAIT(near_edge, TRAIT_FORCED_GRAVITY))
		TEST_FAIL("Portagrav did not apply gravity to a turf inside its field!")
	if(HAS_TRAIT(far_edge, TRAIT_FORCED_GRAVITY))
		TEST_FAIL("Portagrav applied gravity outside of its field!")
	if(!(locate(/obj/effect/gravity_fluff_field) in near_edge))
		TEST_FAIL("Portagrav did not show its field on a turf inside it!")

	generator.field_level = 3
	generator.update_field()
	if(!HAS_TRAIT(far_edge, TRAIT_FORCED_GRAVITY))
		TEST_FAIL("Portagrav did not extend its field after the level was raised!")

	generator.turn_off()
	if(HAS_TRAIT(near_edge, TRAIT_FORCED_GRAVITY))
		TEST_FAIL("Portagrav kept applying gravity after being turned off!")
	if(locate(/obj/effect/gravity_fluff_field) in near_edge)
		TEST_FAIL("Portagrav left its field visuals behind after being turned off!")

	generator.cell.charge = 0
	generator.turn_on()
	if(generator.on)
		TEST_FAIL("Portagrav turned on with an empty cell!")
