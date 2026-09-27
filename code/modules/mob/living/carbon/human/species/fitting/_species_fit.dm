#define FIT_SKIP "fit_skip"
#define FIT_DEFAULT_SIZE 32

GLOBAL_LIST_EMPTY(species_fits)

/proc/get_species_fit(fit_type)
	RETURN_TYPE(/datum/species_fit)
	if(!ispath(fit_type, /datum/species_fit))
		return null
	var/datum/species_fit/fit = GLOB.species_fits[fit_type]
	if(!fit)
		fit = new fit_type
		GLOB.species_fits[fit_type] = fit
	return fit

/datum/species_fit
	var/reference_sheet = 'icons/mob/human_races/r_human.dmi'
	var/target_sheet
	var/pixel_map
	var/list/pixel_maps
	var/list/trunk_states = list("torso_m", "groin_m")
	var/list/limb_states = list("l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")
	var/list/head_states = list("head_m")
	var/list/bare_parts
	var/list/tier_states
	var/max_squash = 0
	var/list/steps = list(
		/datum/fit_step/mark_bare_skin,
		/datum/fit_step/warp,
		/datum/fit_step/edge_repair,
		/datum/fit_step/span_remap,
		/datum/fit_step/vertical_warp,
		/datum/fit_step/cover_skin,
		/datum/fit_step/keep_solid,
		/datum/fit_step/head_warp,
		/datum/fit_step/trim,
		/datum/fit_step/head_trim,
		/datum/fit_step/bare_part_trim,
		/datum/fit_step/pixel_map,
	)
	var/list/manual_sheets
	var/list/blocked_sheets
	var/list/item_overrides
	var/width = FIT_DEFAULT_SIZE
	var/height = FIT_DEFAULT_SIZE
	var/list/reference_trunk_masks
	var/list/reference_body_masks
	var/list/target_trunk_masks
	var/list/target_body_masks
	var/list/warp_maps
	var/list/row_maps
	var/list/span_maps
	var/list/pixel_tier_maps
	var/list/reference_head_masks
	var/list/target_head_masks
	var/list/head_shifts
	var/list/reference_bare_masks
	var/list/target_bare_masks
	var/list/shrunk_masks
	var/list/step_instances
	var/list/icon_cache
	var/list/disk_cache
	var/cache_key
	var/built = FALSE

/datum/species_fit/New()
	if(!tier_states)
		tier_states = list(head_states, list("l_foot", "r_foot"), list("l_hand", "r_hand"), trunk_states,
			list("l_leg", "r_leg"), list("l_arm", "r_arm"))
	icon_cache = list()
	disk_cache = list()
	step_instances = list()
	for(var/step_type in steps)
		step_instances += new step_type

/datum/species_fit/proc/build()
	if(built)
		return
	built = TRUE
	load_pixel_map()
	var/list/tier_names = list()
	for(var/list/tier_group in tier_states)
		tier_names += jointext(tier_group, ",")
	var/list/bare_names = list()
	for(var/list/part_group in bare_parts)
		bare_names += jointext(part_group, ",")
	cache_key = rustg_hash_string(RUSTG_HASH_XXH64, "[FIT_CACHE_VERSION]|[reference_sheet]|[sheet_hash(reference_sheet)]|[target_sheet]|[sheet_hash(target_sheet)]|[jointext(steps, "|")]|[max_squash]|[jointext(limb_states, ",")]|[jointext(tier_names, ";")]|[jointext(bare_names, ";")]|[FIT_PART_GARMENT_SHARE]|[FIT_HEAD_WARP_SHARE]")
	cache_key = rustg_hash_string(RUSTG_HASH_XXH64, "[cache_key]|[pixel_map]|[pixel_map ? md5(file2text(pixel_map)) : ""]")
	reference_trunk_masks = list()
	reference_body_masks = list()
	target_trunk_masks = list()
	target_body_masks = list()
	warp_maps = list()
	row_maps = list()
	span_maps = list()
	pixel_tier_maps = list()
	reference_head_masks = list()
	target_head_masks = list()
	head_shifts = list()
	reference_bare_masks = list()
	target_bare_masks = list()
	shrunk_masks = list()
	for(var/fit_dir in GLOB.cardinal)
		var/key = "[fit_dir]"
		reference_trunk_masks[key] = build_mask(reference_sheet, trunk_states, fit_dir)
		reference_body_masks[key] = build_mask(reference_sheet, trunk_states + limb_states, fit_dir)
		target_trunk_masks[key] = build_mask(target_sheet, trunk_states, fit_dir)
		target_body_masks[key] = build_mask(target_sheet, trunk_states + limb_states, fit_dir)
		var/list/reference_tiers = list()
		var/list/target_tiers = list()
		for(var/list/tier_group in tier_states)
			reference_tiers += list(build_mask(reference_sheet, tier_group, fit_dir))
			target_tiers += list(build_mask(target_sheet, tier_group, fit_dir))
		warp_maps[key] = build_warp_map(fit_dir)
		row_maps[key] = build_row_map(fit_dir)
		var/list/pixel_tier = new(width * height)
		span_maps[key] = build_span_map(reference_tiers, target_tiers, pixel_tier)
		pixel_tier_maps[key] = pixel_tier
		reference_head_masks[key] = build_mask(reference_sheet, head_states, fit_dir)
		target_head_masks[key] = build_mask(target_sheet, head_states, fit_dir)
		head_shifts[key] = build_head_shift(fit_dir)
		var/list/reference_bare = list()
		var/list/target_bare = list()
		for(var/list/part_states in bare_parts)
			reference_bare += list(build_mask(reference_sheet, part_states, fit_dir))
			target_bare += list(build_mask(target_sheet, part_states, fit_dir))
		reference_bare_masks[key] = reference_bare
		target_bare_masks[key] = target_bare
		shrunk_masks[key] = build_shrunk_mask(fit_dir)

/datum/species_fit/proc/load_pixel_map()
	pixel_maps = list()
	if(!pixel_map)
		return
	var/list/data = json_decode(file2text(pixel_map))
	var/list/resolution = data["resolution"]
	if(data["version"] != 1 || resolution?["width"] != width || resolution?["height"] != height)
		CRASH("Invalid species fitting pixel map: [pixel_map]")
	if(!(data["supportedDirections"] in list("four", "eight")))
		CRASH("Unsupported pixel map directions: [pixel_map]")
	var/list/mappings = data["mappings"]
	var/list/directions = list("South" = SOUTH, "North" = NORTH, "East" = EAST, "West" = WEST)
	for(var/direction_name in directions)
		var/list/map = new(width * height)
		var/list/pairs = mappings[direction_name]
		for(var/list/pair in pairs)
			var/output_index = pixel_map_index(pair["source"])
			var/list/target = pair["target"]
			map[output_index] = isnull(target) ? 0 : pixel_map_index(target)
		pixel_maps["[directions[direction_name]]"] = map

/datum/species_fit/proc/pixel_map_index(list/point)
	var/x = point?["x"]
	var/y = point?["y"]
	if(!isnum(x) || !isnum(y) || x != round(x) || y != round(y) || x < 0 || x >= width || y < 0 || y >= height)
		CRASH("Invalid pixel map coordinate in [pixel_map]")
	return width * (height - 1 - y) + x + 1

/datum/species_fit/proc/build_mask(sheet, list/state_names, fit_dir)
	var/list/mask = new(width * height)
	for(var/state_name in state_names)
		if(!icon_exists(sheet, state_name))
			continue
		var/icon/frame = icon(sheet, state_name, fit_dir)
		for(var/y in 1 to height)
			var/row_offset = width * (y - 1)
			for(var/x in 1 to width)
				if(!isnull(frame.GetPixel(x, y)))
					mask[row_offset + x] = TRUE
	return mask

/datum/species_fit/proc/build_warp_map(fit_dir)
	var/key = "[fit_dir]"
	var/list/reference_trunk = reference_trunk_masks[key]
	var/list/reference_body = reference_body_masks[key]
	var/list/target_trunk = target_trunk_masks[key]
	var/list/target_body = target_body_masks[key]
	var/list/map = new(width * height)
	for(var/y in 1 to height)
		var/row_offset = width * (y - 1)
		var/list/trunk_columns = list()
		var/list/body_columns = list()
		for(var/x in 1 to width)
			if(reference_trunk[row_offset + x])
				trunk_columns += x
			if(reference_body[row_offset + x])
				body_columns += x
		for(var/x in 1 to width)
			var/index = row_offset + x
			if(target_trunk[index] && length(trunk_columns))
				map[index] = nearest_line(trunk_columns, x)
			else if(target_body[index] && length(body_columns))
				map[index] = nearest_line(body_columns, x)
			else
				map[index] = x
	return map

/datum/species_fit/proc/build_row_map(fit_dir)
	var/key = "[fit_dir]"
	var/list/target_trunk = target_trunk_masks[key]
	var/list/target_body = target_body_masks[key]
	var/list/trunk_rows = mask_rows(reference_trunk_masks[key])
	var/list/body_rows = mask_rows(reference_body_masks[key])
	var/list/map = new(width * height)
	for(var/y in 1 to height)
		var/row_offset = width * (y - 1)
		for(var/x in 1 to width)
			var/index = row_offset + x
			var/list/rows = target_trunk[index] ? trunk_rows : (target_body[index] ? body_rows : null)
			if(!length(rows) || (y >= rows[1] && y <= rows[length(rows)]))
				continue
			map[index] = nearest_line(rows, y)
	return map

/datum/species_fit/proc/mask_rows(list/mask)
	var/list/rows = list()
	for(var/y in 1 to height)
		var/row_offset = width * (y - 1)
		for(var/x in 1 to width)
			if(mask[row_offset + x])
				rows += y
				break
	return rows

/datum/species_fit/proc/span_endpoints(list/mask, x)
	var/first = 0
	var/last = 0
	for(var/y in 1 to height)
		if(!mask[width * (y - 1) + x])
			continue
		if(!first)
			first = y
		last = y
	return first ? list(first, last) : null

/datum/species_fit/proc/build_span_map(list/reference_tiers, list/target_tiers, list/pixel_tier)
	var/list/map = new(width * height)
	for(var/x in 1 to width)
		for(var/tier in 1 to length(target_tiers))
			var/list/target_mask = target_tiers[tier]
			var/list/target_span = span_endpoints(target_mask, x)
			if(!target_span)
				continue
			var/list/reference_span = span_endpoints(reference_tiers[tier], x)
			var/first_reference = reference_span ? reference_span[1] : 0
			var/last_reference = reference_span ? reference_span[2] : 0
			var/first_target = target_span[1]
			var/last_target = target_span[2]
			var/grown = first_target <= first_reference && last_target >= last_reference
			var/squashed = (last_reference - first_reference) - (last_target - first_target)
			for(var/y in first_target to last_target)
				var/index = width * (y - 1) + x
				if(pixel_tier[index] || !target_mask[index])
					continue
				pixel_tier[index] = tier
				if(!reference_span || grown || squashed > max_squash)
					continue
				if(last_target == first_target)
					map[index] = first_reference
					continue
				map[index] = first_reference + round((y - first_target) * (last_reference - first_reference) / (last_target - first_target) + 0.5)
	return map

/datum/species_fit/proc/build_head_shift(fit_dir)
	var/key = "[fit_dir]"
	var/list/reference_head = reference_head_masks[key]
	var/list/target_head = target_head_masks[key]
	var/list/rows = new(height)
	var/reference_column = median_column(reference_head)
	var/target_column = median_column(target_head)
	if(!reference_column || !target_column || reference_column == target_column)
		return rows
	for(var/y in max(first_mask_row(reference_head), first_mask_row(target_head)) to height)
		rows[y] = target_column - reference_column
	return rows

/datum/species_fit/proc/median_column(list/mask)
	var/list/counts = new(width)
	var/total = 0
	for(var/y in 1 to height)
		var/row_offset = width * (y - 1)
		for(var/x in 1 to width)
			if(mask[row_offset + x])
				counts[x]++
				total++
	if(!total)
		return 0
	var/middle = round(total / 2)
	var/seen = 0
	for(var/x in 1 to width)
		seen += counts[x]
		if(seen > middle)
			return x
	return width

/datum/species_fit/proc/first_mask_row(list/mask)
	for(var/y in 1 to height)
		var/row_offset = width * (y - 1)
		for(var/x in 1 to width)
			if(mask[row_offset + x])
				return y
	return 0

/datum/species_fit/proc/build_shrunk_mask(fit_dir)
	var/list/reference_full = build_mask(reference_sheet, trunk_states + limb_states + head_states, fit_dir)
	var/list/target_full = build_mask(target_sheet, trunk_states + limb_states + head_states, fit_dir)
	var/list/mask = new(width * height)
	for(var/index in 1 to width * height)
		mask[index] = reference_full[index] && !target_full[index]
	return mask

/datum/species_fit/proc/nearest_line(list/lines, line)
	var/best = line
	var/best_distance = INFINITY
	for(var/candidate in lines)
		var/distance = abs(candidate - line)
		if(distance < best_distance)
			best = candidate
			best_distance = distance
	return best

/proc/get_fitted_worn_icon(datum/species/wearer_species, obj/item/clothing_item, sheet, state_name)
	RETURN_TYPE(/icon)
	if(!wearer_species || wearer_species.worn_sheets?[sheet])
		return null
	var/datum/species_fit/species_fit = get_species_fit(wearer_species.fit_profile)
	return species_fit?.fit_worn_icon(clothing_item, sheet, state_name)

/proc/worn_preview_icon(datum/species/preview_species, sheet, state_name)
	RETURN_TYPE(/icon)
	var/icon/fitted = get_fitted_worn_icon(preview_species, null, sheet, state_name)
	if(fitted)
		return new /icon(fitted)
	return new /icon(preview_species?.worn_sheets?[sheet] || sheet, state_name)

/proc/fitted_underwear_icon(datum/species/wearer_species, datum/sprite_accessory/accessory, state_name)
	var/species_sheet = accessory.sprite_sheets?[wearer_species.name]
	if(species_sheet)
		return new /icon(species_sheet, state_name)
	var/datum/species_fit/fit = get_species_fit(wearer_species.fit_profile)
	if(fit?.pixel_map)
		var/icon/fitted = fit.fit_worn_icon(null, accessory.icon, state_name)
		if(fitted)
			return new /icon(fitted)
	return new /icon(accessory.icon, state_name)

/proc/get_worn_icon_source(mob/living/carbon/human/wearer, obj/item/clothing_item, sheet, state_name)
	var/datum/species/wearer_species = wearer.dna?.species
	if(clothing_item.species_worn_sheet(wearer_species?.name, state_name))
		return "sprite_sheets"
	if(wearer_species?.worn_sheets?[sheet])
		return "worn_sheets"
	var/datum/species_fit/species_fit = get_species_fit(wearer_species?.fit_profile)
	return species_fit ? species_fit.describe_source(clothing_item, sheet, state_name) : "vanilla"

/datum/species_fit/proc/describe_source(obj/item/clothing_item, sheet, state_name)
	var/override_sheet = get_item_override(clothing_item)
	if(override_sheet == FIT_SKIP)
		return "override skip"
	if(override_sheet)
		return "override sheet"
	if(sheet in blocked_sheets)
		return "blocked"
	var/manual_sheet = manual_sheets?[sheet]
	if(manual_sheet && icon_exists(manual_sheet, state_name))
		return "manual patch"
	return fit_worn_icon(clothing_item, sheet, state_name) ? "generated" : "vanilla"

/datum/species_fit/proc/get_item_override(obj/item/clothing_item)
	if(!length(item_overrides) || !clothing_item)
		return null
	for(var/override_type in item_overrides)
		if(istype(clothing_item, override_type))
			return item_overrides[override_type]
	return null

/datum/species_fit/proc/fit_worn_icon(obj/item/clothing_item, sheet, state_name)
	if(!target_sheet || !state_name)
		return null
	if(!isfile(sheet))
		return null
	if(sheet in blocked_sheets)
		return null
	var/override_sheet = get_item_override(clothing_item)
	if(override_sheet == FIT_SKIP)
		return null
	if(override_sheet)
		return icon_exists(override_sheet, state_name) ? icon(override_sheet, state_name) : null
	var/cache_key = "[sheet]|[state_name]"
	var/cached = icon_cache[cache_key]
	if(cached)
		return cached == FIT_SKIP ? null : cached
	var/manual_sheet = manual_sheets?[sheet]
	var/icon/fitted
	if(manual_sheet && icon_exists(manual_sheet, state_name))
		fitted = icon(manual_sheet, state_name)
	else if(icon_exists(sheet, state_name))
		fitted = read_disk_cache(sheet, state_name)
		if(!fitted)
			fitted = build_fitted_icon(sheet, state_name)
			if(fitted)
				write_disk_cache(sheet, state_name, fitted)
	icon_cache[cache_key] = fitted || FIT_SKIP
	return fitted

/datum/species_fit/proc/build_fitted_icon(sheet, state_name)
	build()
	var/icon/assembled = icon('icons/effects/effects.dmi', "nothing")
	var/fitted_anything = FALSE
	var/list/frames = list()
	var/dresses_head = FALSE
	var/warps_head = FALSE
	var/list/dressed_parts = new(length(bare_parts))
	for(var/fit_dir in GLOB.cardinal)
		var/icon/frame = icon(sheet, state_name, fit_dir)
		if(frame.Width() != width || frame.Height() != height)
			return null
		var/list/pixels = read_frame(frame)
		frames["[fit_dir]"] = pixels
		var/head_share = covered_share(pixels, reference_head_masks["[fit_dir]"])
		if(head_share >= FIT_PART_GARMENT_SHARE)
			dresses_head = TRUE
		if(head_share >= FIT_HEAD_WARP_SHARE)
			warps_head = TRUE
		var/list/reference_bare = reference_bare_masks["[fit_dir]"]
		for(var/part in 1 to length(reference_bare))
			if(covered_share(pixels, reference_bare[part]) >= FIT_PART_GARMENT_SHARE)
				dressed_parts[part] = TRUE
	for(var/fit_dir in GLOB.cardinal)
		var/datum/fit_context/context = new(src, fit_dir, frames["[fit_dir]"])
		context.dresses_head = dresses_head
		context.warps_head = warps_head
		context.dressed_parts = dressed_parts
		for(var/datum/fit_step/step in step_instances)
			step.apply(context)
		if(context.changed())
			fitted_anything = TRUE
		assembled.Insert(write_frame(context.working), dir = fit_dir)
	return fitted_anything ? assembled : null

/datum/species_fit/proc/covered_share(list/pixels, list/mask)
	var/part_pixels = 0
	var/dressed = 0
	for(var/index in 1 to length(mask))
		if(!mask[index])
			continue
		part_pixels++
		if(pixels[index])
			dressed++
	if(!part_pixels)
		return 1
	return dressed / part_pixels

/datum/species_fit/proc/read_frame(icon/frame)
	var/list/pixels = new(width * height)
	for(var/y in 1 to height)
		var/row_offset = width * (y - 1)
		for(var/x in 1 to width)
			pixels[row_offset + x] = frame.GetPixel(x, y)
	return pixels

/datum/species_fit/proc/write_frame(list/pixels)
	var/icon/frame = icon('icons/effects/effects.dmi', "nothing")
	for(var/y in 1 to height)
		var/row_offset = width * (y - 1)
		for(var/x in 1 to width)
			var/pixel = pixels[row_offset + x]
			if(pixel)
				frame.DrawBox(pixel, x, y)
	return frame

/datum/species_fit/proc/sheet_hash(sheet)
	var/sheet_path = "[sheet]"
	return fexists(sheet_path) ? rustg_hash_file(RUSTG_HASH_XXH64, sheet_path) : null

/datum/species_fit/proc/cache_directory()
	return "[FIT_CACHE_DIRECTORY]/[cache_key]"

/datum/species_fit/proc/cache_entry_name(sheet_path)
	var/static/regex/unsafe_characters = regex(@"[^a-zA-Z0-9]", "g")
	return replacetext(sheet_path, unsafe_characters, "_")

/datum/species_fit/proc/load_disk_cache()
	var/directory = cache_directory()
	var/manifest_path = "[directory]/manifest.json"
	if(!fexists(manifest_path))
		return
	var/list/manifest = json_decode(file2text(manifest_path))
	for(var/entry_name in manifest)
		var/list/entry = manifest[entry_name]
		var/dmi_path = "[directory]/[entry_name].dmi"
		if(!fexists(dmi_path))
			continue
		if(entry["hash"] != sheet_hash(entry["sheet"]))
			fdel(dmi_path)
			continue
		var/datum/fit_sheet_cache/sheet_cache = new
		var/icon/stored = icon(file(dmi_path))
		sheet_cache.source_hash = entry["hash"]
		for(var/state_name in icon_states(stored))
			if(state_name)
				sheet_cache.states[state_name] = icon(stored, state_name)
		disk_cache[entry["sheet"]] = sheet_cache

/datum/species_fit/proc/flush_disk_cache()
	if(!length(disk_cache))
		return
	var/directory = cache_directory()
	var/list/manifest = list()
	for(var/sheet_path in disk_cache)
		var/datum/fit_sheet_cache/sheet_cache = disk_cache[sheet_path]
		var/entry_name = cache_entry_name(sheet_path)
		if(sheet_cache.dirty)
			var/dmi_path = "[directory]/[entry_name].dmi"
			var/icon/sheet_icon = icon('icons/effects/effects.dmi', "nothing")
			for(var/state_name in sheet_cache.states)
				sheet_icon.Insert(sheet_cache.states[state_name], state_name)
			fdel(dmi_path)
			fcopy(sheet_icon, dmi_path)
			sheet_cache.dirty = FALSE
		manifest[entry_name] = list("sheet" = sheet_path, "hash" = sheet_cache.source_hash)
	rustg_file_write(json_encode(manifest), "[directory]/manifest.json", "false")

/datum/species_fit/proc/read_disk_cache(sheet, state_name)
	RETURN_TYPE(/icon)
	var/datum/fit_sheet_cache/sheet_cache = disk_cache["[sheet]"]
	return sheet_cache?.states[state_name]

/datum/species_fit/proc/write_disk_cache(sheet, state_name, icon/fitted)
	var/sheet_path = "[sheet]"
	if(findtext(sheet_path, "icons/") != 1)
		return
	var/datum/fit_sheet_cache/sheet_cache = disk_cache[sheet_path]
	if(!sheet_cache)
		sheet_cache = new
		sheet_cache.source_hash = sheet_hash(sheet_path)
		disk_cache[sheet_path] = sheet_cache
	sheet_cache.states[state_name] = fitted
	sheet_cache.dirty = TRUE
	addtimer(CALLBACK(src, PROC_REF(flush_disk_cache)), FIT_CACHE_FLUSH_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/fit_sheet_cache
	var/list/states = list()
	var/source_hash
	var/dirty = FALSE

/datum/fit_context
	var/datum/species_fit/profile
	var/fit_dir
	var/width
	var/height
	var/list/source
	var/list/working
	var/list/warp_map
	var/list/row_map
	var/list/span_map
	var/list/pixel_tier
	var/list/dirty_rows
	var/dresses_head = FALSE
	var/warps_head = FALSE
	var/list/dressed_parts

/datum/fit_context/New(datum/species_fit/profile, fit_dir, list/pixels)
	src.profile = profile
	src.fit_dir = fit_dir
	width = profile.width
	height = profile.height
	source = pixels
	working = pixels.Copy()
	warp_map = profile.warp_maps["[fit_dir]"]
	row_map = profile.row_maps["[fit_dir]"]
	span_map = profile.span_maps["[fit_dir]"]
	pixel_tier = profile.pixel_tier_maps["[fit_dir]"]

/datum/fit_context/proc/changed()
	for(var/index in 1 to length(working))
		if(working[index] != source[index])
			return TRUE
	return FALSE

/datum/fit_context/proc/reference_mask()
	return profile.reference_body_masks["[fit_dir]"]

/datum/fit_context/proc/target_mask()
	return profile.target_body_masks["[fit_dir]"]

/datum/fit_context/proc/shrunk_mask()
	return profile.shrunk_masks["[fit_dir]"]

/datum/fit_context/proc/reference_head_mask()
	return profile.reference_head_masks["[fit_dir]"]

/datum/fit_context/proc/target_head_mask()
	return profile.target_head_masks["[fit_dir]"]

/datum/fit_context/proc/head_shift()
	return profile.head_shifts["[fit_dir]"]

/datum/fit_context/proc/target_bare_masks()
	return profile.target_bare_masks["[fit_dir]"]

#undef FIT_DEFAULT_SIZE
