/datum/unit_test/painted_mask

/datum/unit_test/painted_mask/Run()
	var/obj/item/clothing/mask/painted/mask = allocate(/obj/item/clothing/mask/painted)
	var/list/grid = mask.workspace.get_first_layer_pixel_data()

	var/icon/source = icon('icons/mob/clothing/mask.dmi', "morutopia", SOUTH)
	var/mismatches = 0
	var/opaque = 0
	for(var/y in 1 to 16)
		for(var/x in 1 to 14)
			var/expected = source.GetPixel(10 + x - 1, 17 + 16 - y)
			if(!expected)
				expected = "#00000000"
			else if(length(expected) == 7)
				expected += "ff"
			if(grid[y][x] != expected)
				mismatches++
			if(grid[y][x] != "#00000000")
				opaque++
	if(mismatches)
		TEST_FAIL("Blank mask grid differs from the source sprite in [mismatches] pixels!")
	if(!opaque)
		TEST_FAIL("Blank mask grid came out fully transparent!")
	if(grid[8][7] == "#00000000")
		TEST_FAIL("Blank mask grid has no mask under its centre, the source window is misaligned!")
	if(grid[1][1] != "#00000000")
		TEST_FAIL("Blank mask grid has paint in its corner, the source window is misaligned!")

	var/original_sheet = mask.onmob_sheets[ITEM_SLOT_MASK_STRING]
	mask.ui_close(null)
	if(mask.onmob_sheets[ITEM_SLOT_MASK_STRING] != original_sheet)
		TEST_FAIL("Closing the window rebuilt the mask sheet even though nothing was painted!")

	mask.painted = TRUE
	mask.ui_close(null)
	if(mask.onmob_sheets[ITEM_SLOT_MASK_STRING] == original_sheet)
		TEST_FAIL("Closing the window after painting did not rebuild the mask sheet!")
	if(!icon_exists(mask.onmob_sheets[ITEM_SLOT_MASK_STRING], "morutopia"))
		TEST_FAIL("Rebuilt mask sheet has no morutopia state!")
	if(mask.painted)
		TEST_FAIL("Mask stayed dirty after being rebuilt!")
