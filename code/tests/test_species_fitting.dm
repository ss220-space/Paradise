/datum/unit_test/species_fitting

/datum/species_fit/pixel_map_test
	target_sheet = 'icons/mob/human_races/r_swine.dmi'
	pixel_map = 'code/modules/mob/living/carbon/human/species/fitting/maps/human-to-trottine.json'

/datum/unit_test/species_fitting_pixel_map

/datum/unit_test/species_fitting_pixel_map/Run()
	var/datum/species_fit/mapped = new /datum/species_fit/pixel_map_test
	var/datum/species_fit/unmapped = new /datum/species_fit/swine
	unmapped.pixel_map = null
	mapped.build()
	unmapped.build()
	TEST_ASSERT(mapped.cache_key != unmapped.cache_key, "the pixel map did not invalidate the disk cache")
	var/list/map = mapped.pixel_maps["[SOUTH]"]
	TEST_ASSERT_EQUAL(map[32 * 19 + 10], 32 * 19 + 11, "tool (9,12) must pull (10,12), at BYOND (10,20) and (11,20)")
	var/list/pixels = new(32 * 32)
	pixels[32 * 19 + 11] = "#12345678"
	pixels[32 * 19 + 10] = "#abcdef"
	var/datum/fit_context/context = new(mapped, SOUTH, pixels)
	for(var/datum/fit_step/step in mapped.step_instances)
		step.apply(context)
	TEST_ASSERT_EQUAL(context.working[32 * 19 + 10], "#abcdef", "equal-width map correction failed to restore the original detail")
	TEST_ASSERT_EQUAL(context.working[32 * 19 + 11], "#12345678", "map correction lost source alpha")
	mapped.pixel_maps["[NORTH]"] = list()
	var/icon/fitted = mapped.build_fitted_icon(DEFAULT_ICON_JUMPSUIT, "security_s")
	var/icon/fallback = unmapped.build_fitted_icon(DEFAULT_ICON_JUMPSUIT, "security_s")
	for(var/y in 1 to 32)
		for(var/x in 1 to 32)
			TEST_ASSERT_EQUAL(fitted.GetPixel(x, y, dir = NORTH), fallback.GetPixel(x, y, dir = NORTH), "a direction without mappings must retain geometry")
	map = mapped.pixel_maps["[SOUTH]"]
	map[32 * 19 + 10] = 0
	context = new(mapped, SOUTH, pixels)
	var/datum/fit_step/pixel_map/map_step = new
	map_step.apply(context)
	TEST_ASSERT_NULL(context.working[32 * 19 + 10], "an explicit null mapping was treated as an absent mapping")
	TEST_ASSERT_EQUAL(context.working[32 * 19 + 11], "#12345678", "mapping used its own output instead of the original pixels")
	mapped.manual_sheets = list(DEFAULT_ICON_JUMPSUIT = DEFAULT_ICON_JUMPSUIT)
	TEST_ASSERT_EQUAL(mapped.describe_source(null, DEFAULT_ICON_JUMPSUIT, "maid_s"), "manual patch", "pixel maps bypassed the artist's patch")


/datum/unit_test/species_fitting_map_refit

/datum/unit_test/species_fitting_map_refit/Run()
	var/datum/fit_step/pixel_map/step = new
	var/list/source = list(null, "#202020", "#c0c0c080", "#c0c0c080", "#202020", null)
	var/list/adapted = list("#202020", "#202020", "#c0c0c080", "#c0c0c080", "#202020", "#202020")
	var/list/result = step.refit(source, adapted, 6, 1, list(TRUE))
	TEST_ASSERT_EQUAL(result[1], "#202020", "the left outline moved")
	TEST_ASSERT_EQUAL(result[6], "#202020", "the right outline moved")
	for(var/index in 2 to 5)
		TEST_ASSERT_EQUAL(result[index], "#c0c0c080", "the outline thickened instead of extending the fill, or alpha was lost")
	result = step.refit(source, adapted, 6, 1, list(FALSE))
	TEST_ASSERT_EQUAL(result[2], "#202020", "an unmapped row was refitted")
	source = list("#202020", "#c0c0c0", null, "#c0c0c0", "#202020")
	adapted = list("#202020", "#202020", "#202020", "#202020", "#202020")
	result = step.refit(source, adapted, 5, 1, list(TRUE))
	TEST_ASSERT_EQUAL(result[3], "#c0c0c0", "the coverage guard exposed skin instead of filling with adjacent cloth")
	result = step.refit(adapted, list(null, "#202020", "#c0c0c0", "#202020", null), 5, 1, list(TRUE))
	TEST_ASSERT_NULL(result[1], "the refit tried to reconstruct a narrowed row")
	var/datum/species_fit/profile = new /datum/species_fit/pixel_map_test
	profile.build()
	var/list/pixels = new(32 * 32)
	pixels[322] = "#202020"
	pixels[323] = "#c0c0c080"
	pixels[324] = "#c0c0c080"
	pixels[325] = "#202020"
	var/list/map = new(32 * 32)
	map[321] = 322
	map[326] = 325
	profile.pixel_maps["[SOUTH]"] = map
	var/datum/fit_context/context = new(profile, SOUTH, pixels)
	step.apply(context)
	TEST_ASSERT_EQUAL(context.working[322], "#c0c0c080", "the map step never applied its outline correction")
	TEST_ASSERT_EQUAL(context.working[325], "#c0c0c080", "the map step left the duplicated right outline")
	TEST_ASSERT_EQUAL(context.working[321], "#202020", "the map step lost the expanded silhouette")

/datum/unit_test/species_fitting_map_cache

/datum/unit_test/species_fitting_map_cache/Run()
	var/map_path = "data/species-fitting-test-map.json"
	var/list/data = list("version" = 1, "resolution" = list("width" = 32, "height" = 32), "supportedDirections" = "eight")
	data["mappings"] = list("South" = list(list("source" = list("x" = 0, "y" = 0), "target" = null)))
	rustg_file_write(json_encode(data), map_path, "false")
	var/datum/species_fit/first = new /datum/species_fit/swine
	first.pixel_map = map_path
	first.build()
	var/list/map = first.pixel_maps["[SOUTH]"]
	TEST_ASSERT_EQUAL(map[993], 0, "an explicit transparent output was not loaded")
	map = first.pixel_maps["[NORTH]"]
	TEST_ASSERT_NULL(map[993], "a missing direction did not fall back to geometry")
	data["mappings"] = list("South" = list(list("source" = list("x" = 0, "y" = 0), "target" = list("x" = 1, "y" = 1))))
	rustg_file_write(json_encode(data), map_path, "false")
	var/datum/species_fit/second = new /datum/species_fit/swine
	second.pixel_map = map_path
	second.build()
	TEST_ASSERT(first.cache_key != second.cache_key, "editing the map at the same path did not invalidate L2")
	fdel(map_path)

/datum/unit_test/species_fitting_preview

/datum/unit_test/species_fitting_preview/Run()
	for(var/species_type in list(/datum/species/human, /datum/species/swine, /datum/species/vox, /datum/species/drask))
		var/datum/species/species = new species_type
		var/icon/preview = worn_preview_icon(species, DEFAULT_ICON_JUMPSUIT, "security_s")
		var/icon/expected = get_fitted_worn_icon(species, null, DEFAULT_ICON_JUMPSUIT, "security_s") || icon(species.worn_sheets?[DEFAULT_ICON_JUMPSUIT] || DEFAULT_ICON_JUMPSUIT, "security_s")
		for(var/fit_dir in GLOB.cardinal)
			for(var/y in 1 to 32)
				for(var/x in 1 to 32)
					TEST_ASSERT_EQUAL(preview.GetPixel(x, y, dir = fit_dir), expected.GetPixel(x, y, dir = fit_dir), "the character preview bypassed worn sprite selection")

/datum/unit_test/species_fitting/Run()
	var/datum/species_fit/swine_fit = get_species_fit(/datum/species_fit/swine)
	TEST_ASSERT_NOTNULL(swine_fit, "the swine fit profile was not created")

	var/icon/vanilla = icon(DEFAULT_ICON_JUMPSUIT, "security_s", SOUTH)
	TEST_ASSERT_NULL(vanilla.GetPixel(11, 16), "the vanilla uniform is expected to leave this pixel bare")

	var/icon/fitted = swine_fit.fit_worn_icon(null, DEFAULT_ICON_JUMPSUIT, "security_s")
	TEST_ASSERT_NOTNULL(fitted, "the swine profile refused to fit a plain uniform state")
	TEST_ASSERT_NOTNULL(fitted.GetPixel(11, 16, dir = SOUTH), "the fitted uniform still leaves swine skin bare at the widened torso")

	TEST_ASSERT(fitted == swine_fit.fit_worn_icon(null, DEFAULT_ICON_JUMPSUIT, "security_s"), "fitting the same state twice did not hit the cache")

	TEST_ASSERT_NULL(swine_fit.fit_worn_icon(null, DEFAULT_ICON_WEAR_MASK, "gas_alt"), "a blocked sheet was fitted anyway")
	TEST_ASSERT_NULL(swine_fit.fit_worn_icon(null, DEFAULT_ICON_JUMPSUIT, "there_is_no_such_state"), "a missing icon state was fitted anyway")

/datum/unit_test/species_fitting_priority

/datum/unit_test/species_fitting_priority/Run()
	var/datum/species_fit/swine_fit = get_species_fit(/datum/species_fit/swine)
	TEST_ASSERT_NULL(swine_fit.manual_sheets, "the swine still depends on pre-fitted clothing sheets")
	TEST_ASSERT_NOTNULL(swine_fit.pixel_map, "the swine lost its fitting template")
	TEST_ASSERT_EQUAL(swine_fit.describe_source(null, DEFAULT_ICON_JUMPSUIT, "maid_s"), "generated", "a former patch state did not switch to template generation")
	TEST_ASSERT_EQUAL(swine_fit.describe_source(null, DEFAULT_ICON_JUMPSUIT, "security_s"), "generated", "a state with no hand-drawn patch was not generated")
	TEST_ASSERT_EQUAL(swine_fit.describe_source(null, DEFAULT_ICON_WEAR_MASK, "gas_alt"), "blocked", "the deliberately vanilla mask slot was fitted anyway")

	var/mob/living/carbon/human/trottine = allocate(/mob/living/carbon/human)
	trottine.set_species(/datum/species/swine)
	var/obj/item/clothing/under/uniform = allocate(/obj/item/clothing/under/rank/security)
	trottine.equip_to_slot_or_del(uniform, ITEM_SLOT_CLOTH_INNER)

	var/mutable_appearance/worn = uniform.build_worn_icon(default_icon_file = DEFAULT_ICON_JUMPSUIT, override_state = "[uniform.icon_state]_s")
	TEST_ASSERT_NOTNULL(worn, "a worn uniform produced no appearance at all")
	TEST_ASSERT_EQUAL("[worn.icon]", "", "the worn uniform came straight from a file instead of the generator")

/datum/unit_test/species_fitting_contour

/datum/unit_test/species_fitting_contour/Run()
	var/datum/species_fit/swine_fit = get_species_fit(/datum/species_fit/swine)
	var/icon/fitted = swine_fit.fit_worn_icon(null, DEFAULT_ICON_OUTER_SUIT, "labcoat")
	TEST_ASSERT_NOTNULL(fitted, "the swine profile refused to fit a labcoat")

	TEST_ASSERT_EQUAL(fitted.GetPixel(12, 9, dir = EAST), "#898989", "the left outline of the coat was smeared away when the row was widened")
	TEST_ASSERT_EQUAL(fitted.GetPixel(22, 9, dir = EAST), "#848484", "the right outline of the coat was smeared away when the row was widened")
	TEST_ASSERT_EQUAL(fitted.GetPixel(12, 14, dir = EAST), "#898989", "the coat outline was lost on the chest row")

/datum/unit_test/species_fitting_shoulders

/datum/unit_test/species_fitting_shoulders/Run()
	var/datum/species_fit/swine_fit = get_species_fit(/datum/species_fit/swine)

	var/icon/vanilla = icon(DEFAULT_ICON_JUMPSUIT, "security_s", SOUTH)
	TEST_ASSERT_NULL(vanilla.GetPixel(11, 9), "the vanilla uniform is expected to stop short of the wider swine hip")

	var/icon/fitted = swine_fit.fit_worn_icon(null, DEFAULT_ICON_JUMPSUIT, "security_s")
	TEST_ASSERT_NOTNULL(fitted.GetPixel(11, 21, dir = SOUTH), "the swine shoulder lost the cloth that only the vertical pass puts back after the horizontal steps strip it")
	TEST_ASSERT_NOTNULL(fitted.GetPixel(11, 9, dir = SOUTH), "the fitted uniform still leaves the swine bare where its body is wider than a human one")

/datum/unit_test/species_fitting_greyscale

/datum/unit_test/species_fitting_greyscale/Run()
	var/mob/living/carbon/human/trottine = allocate(/mob/living/carbon/human)
	trottine.set_species(/datum/species/swine)
	var/obj/item/clothing/under/color/jumpsuit = allocate(/obj/item/clothing/under/color)
	trottine.equip_to_slot_or_del(jumpsuit, ITEM_SLOT_CLOTH_INNER)

	TEST_ASSERT_NULL(jumpsuit.sprite_sheets?[SPECIES_SWINE], "a hand-made swine greyscale sheet is back, so the generator never gets to see this item")

	var/human_sheet = jumpsuit.onmob_sheets[ITEM_SLOT_CLOTH_INNER_STRING]
	var/datum/species_fit/swine_fit = get_species_fit(/datum/species_fit/swine)
	TEST_ASSERT_NOTNULL(swine_fit.fit_worn_icon(null, human_sheet, "[jumpsuit.icon_state]_s"), "the fitter cannot read a greyscale-generated sheet, so a species without greyscale configs gets nothing")

	var/mutable_appearance/worn = jumpsuit.build_worn_icon(default_icon_file = human_sheet, override_state = "[jumpsuit.icon_state]_s")
	TEST_ASSERT_EQUAL("[worn.icon]", "", "the greyscale jumpsuit reached the swine body without being fitted")

/datum/unit_test/species_fitting_trim

/datum/unit_test/species_fitting_trim/Run()
	var/datum/species_fit/swine_fit = get_species_fit(/datum/species_fit/swine)
	var/icon/fitted = swine_fit.fit_worn_icon(null, DEFAULT_ICON_OUTER_SUIT, "labcoat")
	TEST_ASSERT_NOTNULL(fitted, "the swine profile refused to fit a labcoat")

	var/icon/vanilla = icon(DEFAULT_ICON_OUTER_SUIT, "labcoat")
	var/list/shrunk = swine_fit.shrunk_masks["[SOUTH]"]
	var/shrunk_pixels = 0
	for(var/y in 1 to swine_fit.height)
		for(var/x in 1 to swine_fit.width)
			if(!shrunk[swine_fit.width * (y - 1) + x] || vanilla.GetPixel(x, y, dir = SOUTH))
				continue
			shrunk_pixels++
			TEST_ASSERT_NULL(fitted.GetPixel(x, y, dir = SOUTH), "the fit hung cloth at ([x], [y]), where the swine body is narrower than the human one")
	TEST_ASSERT(shrunk_pixels > 0, "the swine body is nowhere narrower than the human one, so the trim step went untested")

	var/datum/species_fit/vox_fit = get_species_fit(/datum/species_fit/vox)
	var/icon/coat = vox_fit.fit_worn_icon(null, DEFAULT_ICON_OUTER_SUIT, "labcoat")
	TEST_ASSERT_NOTNULL(coat, "the vox profile refused to fit a labcoat")
	TEST_ASSERT_NOTNULL(vanilla.GetPixel(8, 15, dir = SOUTH), "the labcoat lost the skirt the vox is too narrow to fill, so the trim step is no longer tested against hand-drawn cloth")
	TEST_ASSERT_NOTNULL(coat.GetPixel(8, 15, dir = SOUTH), "the trim punched a hole through cloth the coat draws itself, where a vox is narrower than a human")
	TEST_ASSERT_NOTNULL(coat.GetPixel(12, 11, dir = EAST), "the trim ate the coat outline on the vox profile frame")

/datum/unit_test/species_fitting_reach

/datum/unit_test/species_fitting_reach/Run()
	var/datum/species_fit/swine_fit = get_species_fit(/datum/species_fit/swine)
	var/icon/vanilla = icon(DEFAULT_ICON_BELT, "utility", EAST)
	var/icon/fitted = swine_fit.fit_worn_icon(null, DEFAULT_ICON_BELT, "utility")
	TEST_ASSERT_NOTNULL(fitted, "the swine profile refused to fit a belt")

	var/lowest_row = 0
	for(var/y in 1 to swine_fit.height)
		for(var/x in 1 to swine_fit.width)
			if(vanilla.GetPixel(x, y))
				lowest_row = y
				break
		if(lowest_row)
			break
	TEST_ASSERT(lowest_row > 1, "the belt is drawn down to the bottom of its frame, so nothing is left below it to test")

	for(var/y in 1 to lowest_row - 1)
		for(var/x in 1 to swine_fit.width)
			TEST_ASSERT_NULL(fitted.GetPixel(x, y, dir = EAST), "the vertical pass hung belt cloth at ([x], [y]), below anything the belt draws, because it measured the human body one column at a time")

/datum/unit_test/species_fitting_disk_cache

/datum/unit_test/species_fitting_disk_cache/Run()
	var/datum/species_fit/writer = new /datum/species_fit/swine
	writer.build()
	TEST_ASSERT_NOTNULL(writer.cache_key, "the swine profile produced no key to store its cached sheets under")
	var/test_key = "unit_test_[writer.cache_key]"
	writer.cache_key = test_key

	var/icon/fitted = writer.fit_worn_icon(null, DEFAULT_ICON_JUMPSUIT, "security_s")
	TEST_ASSERT_NOTNULL(fitted, "the swine profile refused to fit a plain uniform state")
	writer.flush_disk_cache()

	var/directory = writer.cache_directory()
	var/entry_name = writer.cache_entry_name("[DEFAULT_ICON_JUMPSUIT]")
	TEST_ASSERT(fexists("[directory]/manifest.json"), "the disk cache was flushed without writing a manifest")
	TEST_ASSERT(fexists("[directory]/[entry_name].dmi"), "the disk cache was flushed without writing the fitted sheet")

	var/datum/species_fit/reader = new /datum/species_fit/swine
	reader.build()
	reader.cache_key = test_key
	reader.load_disk_cache()
	var/icon/restored = reader.read_disk_cache(DEFAULT_ICON_JUMPSUIT, "security_s")
	TEST_ASSERT_NOTNULL(restored, "the flushed uniform state was not found in the cache on the next load")

	var/east_pixels = 0
	for(var/fit_dir in GLOB.cardinal)
		for(var/y in 1 to writer.height)
			for(var/x in 1 to writer.width)
				var/pixel = fitted.GetPixel(x, y, dir = fit_dir)
				if(pixel && fit_dir == EAST)
					east_pixels++
				TEST_ASSERT_EQUAL(restored.GetPixel(x, y, dir = fit_dir), pixel, "the cached uniform lost pixel ([x], [y]) of its [dir2text(fit_dir)] frame")
	TEST_ASSERT(east_pixels > 0, "the east frame is empty, so the cache never proved it round-trips anything but south")

	TEST_ASSERT_NOTNULL(reader.fit_worn_icon(null, DEFAULT_ICON_JUMPSUIT, "maid_s"), "the swine profile refused to fit a second uniform state")
	reader.flush_disk_cache()
	TEST_ASSERT_NOTNULL(reader.fit_worn_icon(null, DEFAULT_ICON_JUMPSUIT, "chef_s"), "the swine profile refused to fit a third uniform state")
	reader.flush_disk_cache()

	var/datum/species_fit/reloader = new /datum/species_fit/swine
	reloader.build()
	reloader.cache_key = test_key
	reloader.load_disk_cache()
	TEST_ASSERT_NOTNULL(reloader.read_disk_cache(DEFAULT_ICON_JUMPSUIT, "security_s"), "writing to a cache loaded from disk dropped the states that were already on disk")
	TEST_ASSERT_NOTNULL(reloader.read_disk_cache(DEFAULT_ICON_JUMPSUIT, "maid_s"), "a state fitted after the cache came back from disk never reached the disk itself")
	TEST_ASSERT_NOTNULL(reloader.read_disk_cache(DEFAULT_ICON_JUMPSUIT, "chef_s"), "the cache stopped taking states once a flush replaced the file it was loaded from")

	var/list/manifest = json_decode(file2text("[directory]/manifest.json"))
	var/list/entry = manifest[entry_name]
	TEST_ASSERT_NOTNULL(entry, "the flushed uniform sheet is missing from the manifest")
	entry["hash"] = "stale"
	rustg_file_write(json_encode(manifest), "[directory]/manifest.json", "false")

	var/datum/species_fit/stale_reader = new /datum/species_fit/swine
	stale_reader.build()
	stale_reader.cache_key = test_key
	stale_reader.load_disk_cache()
	TEST_ASSERT_NULL(stale_reader.read_disk_cache(DEFAULT_ICON_JUMPSUIT, "security_s"), "a cache entry was served even though its source sheet had changed")
	TEST_ASSERT(!fexists("[directory]/[entry_name].dmi"), "an invalidated cache entry was left on disk")

	fdel("[directory]/")

/datum/unit_test/species_fitting_span_remap

/datum/unit_test/species_fitting_span_remap/Run()
	var/datum/species_fit/swine_fit = get_species_fit(/datum/species_fit/swine)
	swine_fit.build()

	var/remapped_pixels = 0
	var/claimed_pixels = 0
	for(var/fit_dir in GLOB.cardinal)
		var/list/span_map = swine_fit.span_maps["[fit_dir]"]
		var/list/pixel_tier = swine_fit.pixel_tier_maps["[fit_dir]"]
		for(var/index in 1 to swine_fit.width * swine_fit.height)
			if(span_map[index])
				remapped_pixels++
			if(pixel_tier[index])
				claimed_pixels++
	TEST_ASSERT(claimed_pixels > 0, "no target pixel was claimed by a body part, so the span map never saw the body")
	TEST_ASSERT(remapped_pixels > 0, "the span map is empty, so the remap step is dead code on the swine")

	TEST_ASSERT_NULL(swine_fit.fit_worn_icon(null, DEFAULT_ICON_SHOES, "workboots"), "a boot was remapped, and the hand-drawn swine sheets say a boot belongs on the vanilla foot")

	var/icon/vanilla = icon(DEFAULT_ICON_JUMPSUIT, "security_s")
	var/icon/fitted = swine_fit.fit_worn_icon(null, DEFAULT_ICON_JUMPSUIT, "security_s")
	TEST_ASSERT_NOTNULL(fitted, "the swine profile refused to fit a plain uniform state")
	for(var/fit_dir in GLOB.cardinal)
		var/list/shrunk = swine_fit.shrunk_masks["[fit_dir]"]
		for(var/y in 1 to swine_fit.height)
			for(var/x in 1 to swine_fit.width)
				if(!vanilla.GetPixel(x, y, dir = fit_dir) || shrunk[swine_fit.width * (y - 1) + x])
					continue
				TEST_ASSERT_NOTNULL(fitted.GetPixel(x, y, dir = fit_dir), "the remap squashed the uniform into a hole at ([x], [y]) of its [dir2text(fit_dir)] frame")

/datum/unit_test/species_fitting_head_trim

/datum/unit_test/species_fitting_head_trim/Run()
	var/datum/species_fit/swine_fit = get_species_fit(/datum/species_fit/swine)

	var/icon/vanilla = icon(DEFAULT_ICON_JUMPSUIT, "security_s", SOUTH)
	TEST_ASSERT_NULL(vanilla.GetPixel(15, 23), "the vanilla uniform is expected to leave the human head bare here")
	TEST_ASSERT_NOTNULL(vanilla.GetPixel(15, 22), "the vanilla uniform is expected to draw its own collar here")

	var/icon/fitted = swine_fit.fit_worn_icon(null, DEFAULT_ICON_JUMPSUIT, "security_s")
	TEST_ASSERT_NOTNULL(fitted, "the swine profile refused to fit a plain uniform state")
	TEST_ASSERT_NULL(fitted.GetPixel(15, 23, dir = SOUTH), "the fitter smeared the uniform onto a head the garment does not dress")
	TEST_ASSERT_NOTNULL(fitted.GetPixel(15, 22, dir = SOUTH), "the head trim ate the collar the garment draws itself")

	var/icon/hat = swine_fit.fit_worn_icon(null, DEFAULT_ICON_HEAD, "welding")
	TEST_ASSERT_NOTNULL(hat, "the swine profile refused to fit a welding helmet")
	for(var/fit_dir in GLOB.cardinal)
		var/list/target_head = swine_fit.target_head_masks["[fit_dir]"]
		var/hat_pixels = 0
		for(var/y in 1 to swine_fit.height)
			for(var/x in 1 to swine_fit.width)
				if(target_head[swine_fit.width * (y - 1) + x] && hat.GetPixel(x, y, dir = fit_dir))
					hat_pixels++
		TEST_ASSERT(hat_pixels > 0, "the head trim stripped a helmet on its [dir2text(fit_dir)] frame, and a helmet is exactly the garment that should dress a head")

	var/icon/vanilla_hood = icon(DEFAULT_ICON_HEAD, "xantholne_winterhood", SOUTH)
	TEST_ASSERT_NULL(vanilla_hood.GetPixel(16, 23), "the vanilla hood is expected to leave this pixel to the fitter")
	var/icon/hood = swine_fit.build_fitted_icon(DEFAULT_ICON_HEAD, "xantholne_winterhood")
	TEST_ASSERT_NOTNULL(hood.GetPixel(16, 23, dir = SOUTH), "the hood was head-trimmed on the one frame where it barely covers a human head, so the gate is being judged per direction instead of per state")

/datum/unit_test/species_fitting_head_warp

/datum/unit_test/species_fitting_head_warp/Run()
	var/datum/species_fit/vox_fit = get_species_fit(/datum/species_fit/vox)

	var/icon/vanilla = icon(DEFAULT_ICON_HEAD, "beret_hos_black", EAST)
	TEST_ASSERT_NULL(vanilla.GetPixel(20, 28), "the vanilla beret is expected to leave the vox beak bare here")
	TEST_ASSERT_NOTNULL(vanilla.GetPixel(13, 28), "the vanilla beret is expected to draw itself where only a human head reaches")

	var/icon/fitted = vox_fit.fit_worn_icon(null, DEFAULT_ICON_HEAD, "beret_hos_black")
	TEST_ASSERT_NOTNULL(fitted, "the vox profile refused to fit a beret")
	TEST_ASSERT_NOTNULL(fitted.GetPixel(20, 28, dir = EAST), "the beret stayed on the human head position instead of following the vox one")
	TEST_ASSERT_NULL(fitted.GetPixel(13, 28, dir = EAST), "the beret kept a tail hanging behind the vox head")
	TEST_ASSERT_NULL(vox_fit.head_shifts["[SOUTH]"][28], "the front frame was shifted, and a vox head faces exactly where a human one does")

	var/icon/coat = vox_fit.fit_worn_icon(null, DEFAULT_ICON_OUTER_SUIT, "armor-combat")
	TEST_ASSERT_NOTNULL(coat, "the vox profile refused to fit combat armour")
	TEST_ASSERT_NOTNULL(coat.GetPixel(13, 22, dir = EAST), "a collar that merely brushes the human head mask was shifted like a hat, tearing the shoulder line")

	var/datum/species_fit/swine_fit = get_species_fit(/datum/species_fit/swine)
	for(var/fit_dir in GLOB.cardinal)
		var/list/shifts = swine_fit.head_shifts["[fit_dir]"]
		TEST_ASSERT_NULL(shifts[swine_fit.height], "the swine head moved on its [dir2text(fit_dir)] frame, and only the snout sits off the human centre line")

/datum/unit_test/species_fitting_bare_parts

/datum/unit_test/species_fitting_bare_parts/Run()
	var/datum/species_fit/vox_fit = get_species_fit(/datum/species_fit/vox)

	var/icon/vanilla = icon(DEFAULT_ICON_JUMPSUIT, "security_s", EAST)
	TEST_ASSERT_NULL(vanilla.GetPixel(22, 11), "the vanilla uniform is expected to leave this pixel to the fitter")

	var/icon/uniform = vox_fit.fit_worn_icon(null, DEFAULT_ICON_JUMPSUIT, "security_s")
	TEST_ASSERT_NOTNULL(uniform, "the vox profile refused to fit a plain uniform state")
	TEST_ASSERT_NULL(uniform.GetPixel(22, 11, dir = EAST), "the fitter smeared a sleeve over the vox hand, which a uniform does not dress")

	var/icon/gloves = vox_fit.fit_worn_icon(null, DEFAULT_ICON_GLOVES, "bgloves")
	TEST_ASSERT_NOTNULL(gloves, "the vox profile refused to fit plain gloves")
	TEST_ASSERT_NOTNULL(gloves.GetPixel(14, 10, dir = EAST), "the bare part trim stripped gloves, and gloves are exactly the garment that dresses a hand")

	var/datum/species_fit/swine_fit = get_species_fit(/datum/species_fit/swine)
	TEST_ASSERT_NULL(swine_fit.bare_parts, "the swine kept its sleeves over the trotters by hand, and its sheets were migrated against that")

/datum/unit_test/species_fitting_profiles

/datum/unit_test/species_fitting_profiles/Run()
	for(var/fit_type in list(/datum/species_fit/vox, /datum/species_fit/drask, /datum/species_fit/unathi, /datum/species_fit/golem))
		var/datum/species_fit/fit = get_species_fit(fit_type)
		TEST_ASSERT_NOTNULL(fit, "[fit_type] was never created")
		TEST_ASSERT_NOTNULL(fit.fit_worn_icon(null, DEFAULT_ICON_OUTER_SUIT, "labcoat"), "[fit_type] left a labcoat human-shaped, and no hand-drawn sheet covers that slot")

	for(var/species_name in GLOB.all_species)
		var/datum/species/species = GLOB.all_species[species_name]
		var/datum/species_fit/species_fit = get_species_fit(species.fit_profile)
		if(!species_fit)
			continue
		TEST_ASSERT_EQUAL("[species_fit.target_sheet]", "[species.icobase]", "[species.type] fits clothing against [species_fit.target_sheet] but wears [species.icobase], so a subtype inherited a profile built for another body")

	var/mob/living/carbon/human/raider = allocate(/mob/living/carbon/human)
	raider.set_species(/datum/species/vox)
	var/obj/item/clothing/gloves/gauntlets = allocate(/obj/item/clothing/gloves/vox)
	raider.equip_to_slot_or_del(gauntlets, ITEM_SLOT_GLOVES)
	TEST_ASSERT_EQUAL(get_worn_icon_source(raider, gauntlets, DEFAULT_ICON_GLOVES, gauntlets.icon_state), "sprite_sheets", "a hand-drawn vox sheet lost to the generator")

	var/obj/item/clothing/mask/gas/space_ninja/hood = allocate(/obj/item/clothing/mask/gas/space_ninja)
	raider.equip_to_slot_or_del(hood, ITEM_SLOT_MASK)
	TEST_ASSERT(icon_exists(DEFAULT_ICON_WEAR_MASK, hood.icon_state), "this state left the vanilla sheet, so it no longer tells a missing species state from a missing state")
	TEST_ASSERT_NOT(icon_exists(hood.sprite_sheets[SPECIES_VOX], hood.icon_state), "the vox mask sheet grew this state, so it no longer exercises the fallback")
	TEST_ASSERT_NOTEQUAL(get_worn_icon_source(raider, hood, DEFAULT_ICON_WEAR_MASK, hood.icon_state), "sprite_sheets", "a species sheet without the state still won, and a sheet without the state draws nothing")
	var/mutable_appearance/worn = hood.build_worn_icon(default_icon_file = DEFAULT_ICON_WEAR_MASK, override_state = hood.icon_state)
	TEST_ASSERT(!worn.icon_state || icon_exists("[worn.icon]", worn.icon_state), "the worn mask points at a sheet that has no such state, so the wearer renders bare-faced")

	var/obj/item/clothing/accessory/vest = allocate(/obj/item/clothing/accessory/waistcoat)
	TEST_ASSERT_NOTNULL(vest.sprite_sheets[SPECIES_MONKEY], "this accessory dropped its monkey sheet, so it no longer exercises the accessory fallback")
	TEST_ASSERT(icon_exists(vest.onmob_sheets[ITEM_SLOT_ACCESSORY_STRING], vest.item_state), "this state left the vanilla accessory sheet, so it no longer tells a missing species state from a missing state")
	TEST_ASSERT_NULL(vest.species_worn_sheet(SPECIES_MONKEY, vest.item_state), "a species sheet without the state still won the accessory slot, and a sheet without the state draws nothing")


/datum/unit_test/species_fitting_collar

/datum/unit_test/species_fitting_collar/Run()
	var/obj/item/clothing/suit/bomb_suit/security/bomb_suit = allocate(/obj/item/clothing/suit/bomb_suit/security)
	var/collar_sheet = bomb_suit.onmob_sheets[ITEM_SLOT_COLLAR_STRING]
	TEST_ASSERT(icon_exists(collar_sheet, bomb_suit.icon_state), "this suit lost its human collar sprite, so nothing is left to fall back to")
	TEST_ASSERT_NOTNULL(bomb_suit.sprite_sheets[SPECIES_VULPKANIN], "this suit dropped its vulpkanin sheet, so it no longer exercises the collar fallback")

	var/mob/living/carbon/human/scout = allocate(/mob/living/carbon/human)
	scout.set_species(/datum/species/vulpkanin)
	scout.equip_to_slot_or_del(bomb_suit, ITEM_SLOT_CLOTH_OUTER)
	TEST_ASSERT_NOTNULL(scout.overlays_standing[COLLAR_LAYER], "a suit with a species sheet but no hand-drawn species collar lost its collar entirely")

	var/mob/living/carbon/human/raider = allocate(/mob/living/carbon/human)
	raider.set_species(/datum/species/vox)
	raider.equip_to_slot_or_del(allocate(/obj/item/clothing/suit/bomb_suit/security), ITEM_SLOT_CLOTH_OUTER)
	var/mutable_appearance/vox_collar = raider.overlays_standing[COLLAR_LAYER]
	TEST_ASSERT_NOTNULL(vox_collar, "the vox lost the collar somebody drew for it by hand")
	TEST_ASSERT_NOTEQUAL("[vox_collar.icon]", "", "the hand-drawn vox collar lost to the generator")

/datum/unit_test/species_fitting_underwear

/datum/unit_test/species_fitting_underwear/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human)
	wearer.set_species(/datum/species/swine)
	wearer.underwear = "Mens Briefs"
	wearer.undershirt = null
	wearer.socks = null
	wearer.color_underwear = "#5577aa"
	var/datum/sprite_accessory/accessory = GLOB.underwear_list[wearer.underwear]
	TEST_ASSERT_NULL(accessory.sprite_sheets[SPECIES_SWINE], "the swine still uses a pre-fitted underwear sheet")
	var/datum/species_fit/fit = get_species_fit(wearer.dna.species.fit_profile)
	var/icon/cached = fit.fit_worn_icon(null, accessory.icon, "uw_[accessory.icon_state]_s")
	TEST_ASSERT_NOTNULL(cached, "the template did not fit the briefs")
	var/icon/untinted = new /icon(cached)
	var/icon/expected = new /icon(cached)
	expected.Blend(wearer.color_underwear, ICON_MULTIPLY)
	wearer.update_body()
	var/mutable_appearance/underwear_layer = wearer.overlays_standing[UNDERWEAR_LAYER]
	TEST_ASSERT_NOTNULL(underwear_layer, "generated underwear never reached the worn layer")
	var/icon/actual = new /icon(underwear_layer.icon)
	var/icon/preview = fitted_underwear_icon(wearer.dna.species, accessory, "uw_[accessory.icon_state]_s")
	for(var/fit_dir in GLOB.cardinal)
		for(var/y in 1 to 32)
			for(var/x in 1 to 32)
				TEST_ASSERT_EQUAL(actual.GetPixel(x, y, dir = fit_dir), expected.GetPixel(x, y, dir = fit_dir), "the worn underwear bypassed fitting or tinting")
				TEST_ASSERT_EQUAL(preview.GetPixel(x, y, dir = fit_dir), untinted.GetPixel(x, y, dir = fit_dir), "tinting underwear mutated the shared fitting cache")
	var/datum/species/vox_species = new /datum/species/vox
	var/icon/vox_result = fitted_underwear_icon(vox_species, accessory, "uw_[accessory.icon_state]_s")
	var/icon/vox_expected = new /icon(accessory.sprite_sheets[SPECIES_VOX], "uw_[accessory.icon_state]_s")
	for(var/fit_dir in GLOB.cardinal)
		for(var/y in 1 to 32)
			for(var/x in 1 to 32)
				TEST_ASSERT_EQUAL(vox_result.GetPixel(x, y, dir = fit_dir), vox_expected.GetPixel(x, y, dir = fit_dir), "another species lost its underwear sheet")

/datum/unit_test/species_fitting_live_cache

/datum/unit_test/species_fitting_live_cache/Run()
	var/datum/species_fit/live = get_species_fit(/datum/species_fit/swine)
	var/datum/fit_sheet_cache/sheet_cache = live.disk_cache["[DEFAULT_ICON_JUMPSUIT]"]
	if(!length(sheet_cache?.states))
		return

	var/fresh_state
	for(var/state_name in icon_states(DEFAULT_ICON_JUMPSUIT))
		if(!state_name || sheet_cache.states[state_name])
			continue
		if(live.fit_worn_icon(null, DEFAULT_ICON_JUMPSUIT, state_name))
			fresh_state = state_name
			break
	TEST_ASSERT_NOTNULL(fresh_state, "every uniform state was already cached, so writing into a cache inherited from an earlier round went untested")

	live.flush_disk_cache()
	var/datum/species_fit/reloaded = new /datum/species_fit/swine
	reloaded.build()
	reloaded.load_disk_cache()
	TEST_ASSERT_NOTNULL(reloaded.read_disk_cache(DEFAULT_ICON_JUMPSUIT, fresh_state), "a state fitted in a round that inherited its cache from an earlier round never reached the disk")
