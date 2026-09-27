/datum/fit_step/proc/apply(datum/fit_context/context)
	return

/datum/fit_step/pixel_map/apply(datum/fit_context/context)
	var/list/map = context.profile.pixel_maps["[context.fit_dir]"]
	if(!length(map))
		return
	var/list/mapped = context.source.Copy()
	var/list/rows = new(context.height)
	var/list/vertical_rows = new(context.height)
	for(var/index in 1 to length(map))
		var/origin = map[index]
		if(isnull(origin))
			continue
		mapped[index] = origin ? context.source[origin] : null
		if(!origin)
			continue
		var/row = round((index - 1) / context.width) + 1
		if(round((origin - 1) / context.width) + 1 == row)
			rows[row] = TRUE
		else
			vertical_rows[row] = TRUE
	for(var/row in 1 to context.height)
		if(vertical_rows[row])
			rows[row] = FALSE
	var/list/corrected = refit(context.source, mapped, context.width, context.height, rows)
	for(var/index in 1 to length(map))
		if(!isnull(map[index]) || corrected[index] != mapped[index])
			context.working[index] = !isnull(map[index]) && !map[index] ? null : corrected[index]

/datum/fit_step/pixel_map/proc/refit(list/source, list/adapted, width, height, list/rows)
	var/list/counts = list()
	var/list/edges = list()
	var/list/light = list()
	for(var/list/grid in list(source, adapted))
		for(var/y in 1 to height)
			for(var/x in 1 to width)
				var/index = width * (y - 1) + x
				var/pixel = grid[index]
				if(!pixel)
					continue
				counts[pixel] = (counts[pixel] || 0) + 1
				if(isnull(light[pixel]))
					var/list/channels = rgb2num(pixel)
					light[pixel] = 299 * channels[1] + 587 * channels[2] + 114 * channels[3]
				if(x == 1 || x == width || y == 1 || y == height || !grid[index - 1] || !grid[index + 1] || !grid[index - width] || !grid[index + width])
					edges[pixel] = TRUE
	var/list/result = adapted.Copy()
	for(var/y in 1 to height)
		if(!rows[y])
			continue
		var/offset = width * (y - 1)
		var/source_first = 0
		var/source_last = 0
		var/target_first = 0
		var/target_last = 0
		for(var/x in 1 to width)
			if(source[offset + x])
				source_first ||= x
				source_last = x
			if(adapted[offset + x])
				target_first ||= x
				target_last = x
		if(!source_first || !target_first)
			continue
		var/list/original = source.Copy(offset + source_first, offset + source_last + 1)
		var/extra = target_last - target_first - (source_last - source_first)
		if(extra < 0 || extra > FIT_REFIT_MAX_GROWTH)
			continue
		var/list/rebuilt = original.Copy()
		if(extra)
			var/list/candidates = list()
			for(var/gap in 2 to length(original))
				var/left = original[gap - 1]
				var/right = original[gap]
				if(!left || !right)
					continue
				var/color = left
				var/cost = 0
				if(left != right)
					var/high = light[left] >= light[right] ? left : right
					var/low = high == left ? right : left
					color = counts[high] >= FIT_REFIT_COMMON_COLOR ? high : low
					cost = FIT_REFIT_COLOR_COST
				if(edges[color])
					cost += FIT_REFIT_EDGE_COST
				if(counts[color] < FIT_REFIT_RARE_COLOR)
					cost += FIT_REFIT_RARE_COST
				candidates += list(list(gap, color, cost))
			if(!length(candidates))
				continue
			var/list/insertions = new(length(original))
			for(var/number in 1 to extra)
				var/ideal = number * length(original) / (extra + 1)
				var/list/best
				var/best_cost = INFINITY
				var/best_distance = INFINITY
				for(var/list/candidate in candidates)
					var/distance = abs(candidate[1] - 1 - ideal)
					var/cost = candidate[3] + FIT_REFIT_DISTANCE_COST * distance
					if(cost < best_cost || (cost == best_cost && distance < best_distance))
						best = candidate
						best_cost = cost
						best_distance = distance
				var/list/at_gap = insertions[best[1]]
				if(!at_gap)
					at_gap = list()
					insertions[best[1]] = at_gap
				at_gap += best[2]
			rebuilt = list()
			for(var/index in 1 to length(original))
				var/list/at_gap = insertions[index]
				if(at_gap)
					rebuilt += at_gap
				rebuilt.len++
				rebuilt[length(rebuilt)] = original[index]
		for(var/index in 1 to length(rebuilt))
			if(rebuilt[index] || !adapted[offset + target_first + index - 1])
				continue
			var/left = index > 1 ? rebuilt[index - 1] : null
			var/right = index < length(rebuilt) ? rebuilt[index + 1] : null
			rebuilt[index] = left && right ? (light[left] >= light[right] ? left : right) : (left || right || adapted[offset + target_first + index - 1])
		for(var/index in 1 to length(rebuilt))
			result[offset + target_first + index - 1] = rebuilt[index]
	return result

/datum/fit_step/proc/clear_added(datum/fit_context/context, list/mask)
	for(var/index in 1 to length(mask))
		if(mask[index] && !context.source[index])
			context.working[index] = null

/datum/fit_step/mark_bare_skin/apply(datum/fit_context/context)
	var/list/reference_mask = context.reference_mask()
	var/list/target_mask = context.target_mask()
	var/list/dirty = new(context.height)
	for(var/y in 1 to context.height)
		var/row_offset = context.width * (y - 1)
		for(var/x in 1 to context.width)
			var/index = row_offset + x
			if(target_mask[index] && !reference_mask[index] && !context.working[index])
				dirty[y] = TRUE
				break
	context.dirty_rows = dirty

/datum/fit_step/warp/apply(datum/fit_context/context)
	var/list/warped = context.working.Copy()
	for(var/y in 1 to context.height)
		if(context.dirty_rows && !context.dirty_rows[y])
			continue
		var/row_offset = context.width * (y - 1)
		for(var/x in 1 to context.width)
			warped[row_offset + x] = context.working[row_offset + context.warp_map[row_offset + x]]
	context.working = warped

/datum/fit_step/edge_repair/apply(datum/fit_context/context)
	for(var/y in 1 to context.height)
		if(context.dirty_rows && !context.dirty_rows[y])
			continue
		var/row_offset = context.width * (y - 1)
		for(var/list/run in row_runs(context.working, row_offset, context.width))
			var/from_column = context.warp_map[row_offset + run[1]]
			var/to_column = context.warp_map[row_offset + run[2]]
			while(from_column > 1 && context.source[row_offset + from_column - 1])
				from_column--
			while(to_column < context.width && context.source[row_offset + to_column + 1])
				to_column++
			if(to_column < from_column)
				continue
			var/new_width = run[2] - run[1] + 1
			if(new_width <= to_column - from_column + 1)
				continue
			var/list/columns = rebuild_run(context.source, row_offset, from_column, to_column, new_width)
			for(var/offset in 1 to length(columns))
				if(!columns[offset])
					continue
				context.working[row_offset + run[1] + offset - 1] = columns[offset]

/datum/fit_step/edge_repair/proc/row_runs(list/pixels, row_offset, width)
	var/list/found = list()
	var/start = 0
	for(var/x in 1 to width)
		if(pixels[row_offset + x])
			if(!start)
				start = x
		else if(start)
			found += list(list(start, x - 1))
			start = 0
	if(start)
		found += list(list(start, width))
	return found

/datum/fit_step/edge_repair/proc/rebuild_run(list/pixels, row_offset, from_column, to_column, target_width)
	var/list/colors = list()
	var/list/counts = list()
	for(var/x in from_column to to_column)
		var/pixel = pixels[row_offset + x]
		if(length(colors) && colors[length(colors)] == pixel)
			counts[length(counts)]++
			continue
		colors.len++
		colors[length(colors)] = pixel
		counts += 1
	stretch_segments(colors, counts, target_width - (to_column - from_column + 1))
	var/list/rebuilt = new(target_width)
	var/index = 1
	for(var/segment in 1 to length(colors))
		for(var/repeat in 1 to counts[segment])
			rebuilt[index++] = colors[segment]
	return rebuilt

/datum/fit_step/edge_repair/proc/stretch_segments(list/colors, list/counts, extra)
	if(extra <= 0)
		return
	var/first = length(counts) > 2 ? 2 : 1
	var/last = length(counts) > 2 ? length(counts) - 1 : length(counts)
	var/weight = 0
	for(var/segment in first to last)
		weight += counts[segment]
	if(!weight)
		counts[max(round(length(counts) / 2), 1)] += extra
		return
	var/given = 0
	var/list/remainders = new(length(counts))
	for(var/segment in first to last)
		var/share = round(extra * counts[segment] / weight)
		remainders[segment] = (extra * counts[segment]) % weight
		counts[segment] += share
		given += share
	while(given < extra)
		var/best = 0
		for(var/segment in first to last)
			if(!best || remainders[segment] > remainders[best])
				best = segment
		counts[best]++
		remainders[best] = -1
		given++

/datum/fit_step/span_remap/apply(datum/fit_context/context)
	if(!context.span_map)
		return
	var/list/remapped = context.working.Copy()
	for(var/y in 1 to context.height)
		var/row_offset = context.width * (y - 1)
		for(var/x in 1 to context.width)
			var/index = row_offset + x
			var/source_row = context.span_map[index]
			if(!source_row)
				continue
			remapped[index] = context.working[context.width * (source_row - 1) + x]
	context.working = remapped

/datum/fit_step/vertical_warp/apply(datum/fit_context/context)
	if(!context.row_map)
		return
	var/list/stretched = context.working.Copy()
	for(var/y in 1 to context.height)
		var/row_offset = context.width * (y - 1)
		for(var/x in 1 to context.width)
			var/index = row_offset + x
			var/source_row = context.row_map[index]
			if(!source_row || context.working[index])
				continue
			stretched[index] = context.working[context.width * (source_row - 1) + x]
	context.working = stretched

/datum/fit_step/cover_skin/apply(datum/fit_context/context)
	var/list/reference_mask = context.reference_mask()
	var/list/target_mask = context.target_mask()
	for(var/y in 1 to context.height)
		var/row_offset = context.width * (y - 1)
		for(var/x in 1 to context.width)
			var/index = row_offset + x
			if(context.working[index] || !target_mask[index] || reference_mask[index])
				continue
			if(x > 1 && context.working[index - 1])
				context.working[index] = context.working[index - 1]
			else if(x < context.width && context.working[index + 1])
				context.working[index] = context.working[index + 1]

/datum/fit_step/keep_solid/apply(datum/fit_context/context)
	for(var/index in 1 to length(context.working))
		if(context.working[index] || !context.source[index])
			continue
		if(context.span_map?[index] && !holed(context, index))
			continue
		context.working[index] = context.source[index]

/datum/fit_step/keep_solid/proc/holed(datum/fit_context/context, index)
	var/tier = context.pixel_tier[index]
	var/above = index - context.width
	var/below = index + context.width
	if(above >= 1 && context.working[above] && context.pixel_tier[above] == tier)
		return TRUE
	if(below <= length(context.working) && context.working[below] && context.pixel_tier[below] == tier)
		return TRUE
	return FALSE

/datum/fit_step/head_warp/apply(datum/fit_context/context)
	if(!context.warps_head)
		return
	var/list/head_shift = context.head_shift()
	var/list/shifted = context.working.Copy()
	for(var/y in 1 to context.height)
		var/shift = head_shift[y]
		if(!shift)
			continue
		var/row_offset = context.width * (y - 1)
		for(var/x in 1 to context.width)
			var/column = x - shift
			shifted[row_offset + x] = (column >= 1 && column <= context.width) ? context.working[row_offset + column] : null
	context.working = shifted

/datum/fit_step/trim/apply(datum/fit_context/context)
	clear_added(context, context.shrunk_mask())

/datum/fit_step/head_trim/apply(datum/fit_context/context)
	if(context.dresses_head)
		return
	clear_added(context, context.target_head_mask())

/datum/fit_step/bare_part_trim/apply(datum/fit_context/context)
	var/list/target_parts = context.target_bare_masks()
	for(var/part in 1 to length(target_parts))
		if(context.dressed_parts[part])
			continue
		clear_added(context, target_parts[part])
