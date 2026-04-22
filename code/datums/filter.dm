/proc/cmp_filter_data_priority(list/A, list/B)
	return A["priority"] - B["priority"]

/** Add a filter to the datum.
 * This is on datum level, despite being most commonly / primarily used on atoms, so that filters can be applied to images / mutable appearances.
 * Can also be used to assert a filter's existence. I.E. update a filter regardless if it exists or not.
 *
 * Arguments:
 * * name - Filter name
 * * priority - Priority used when sorting the filter.
 * * params - Parameters of the filter.
 * * update - If we should update our actual filters list, or wait until something updates it later
 */
/datum/proc/add_filter(name, priority, list/params, update = TRUE)
	ASSERT(isatom(src) || isimage(src))
	var/atom/atom_cast = src // filters only work with images or atoms.
	LAZYINITLIST(filter_data)
	LAZYINITLIST(filter_cache)
	var/list/copied_parameters = params.Copy()
	copied_parameters["name"] = name
	copied_parameters["priority"] = priority
	for(var/index in 1 to length(filter_data))
		var/list/filter_info = filter_data[index]
		if(filter_info["name"] != name)
			continue
		filter_data -= list(filter_info)
		filter_cache -= filter_cache[index]
		break

	BINARY_INSERT_DEFINE(list(copied_parameters), filter_data, SORT_VAR_NO_TYPE, copied_parameters, SORT_PRIORITY_INDEX, COMPARE_KEY)

	for(var/index in 1 to length(filter_data))
		var/list/filter_info = filter_data[index]
		if(filter_info["name"] != name)
			continue
		var/list/arguments = filter_info.Copy()
		arguments -= "priority"
		filter_cache.Insert(index, filter(arglist(arguments)))
		break

	if(update)
		atom_cast.filters = filter_cache

/// A version of add_filter that takes a list of filters to add rather than being individual, to limit appearance updates
/datum/proc/add_filters(list/list/filters, update = TRUE)
	ASSERT(isatom(src) || isimage(src))
	var/atom/atom_cast = src // filters only work with images or atoms.
	for(var/list/individual_filter as anything in filters)
		add_filter(individual_filter["name"], individual_filter["priority"], individual_filter["params"], update = FALSE)
	if(update)
		atom_cast.filters = filter_cache

/// Reapplies all the filters. If start_index is passed, only a portion of all filters are reapplied starting from said index
/datum/proc/update_filters(start_index = null)
	ASSERT(isatom(src) || isimage(src))
	var/atom/atom_cast = src // filters only work with images or atoms.
	if(start_index)
		filter_cache.Cut(start_index)
	else
		atom_cast.filters = null
		filter_cache.Cut()

	for(var/index in start_index || 1 to length(filter_data))
		var/list/filter_info = filter_data[index]
		var/list/arguments = filter_info.Copy()
		arguments -= "priority"
		if(start_index) // See https://www.byond.com/forum/post/2980598 as to why we cannot just override the existing filter
			atom_cast.filters -= filter_info["name"] // We're trapped in the belly of this horrible machine
		filter_cache += filter(arglist(arguments)) // And the machine is bleeding to death

	atom_cast.filters = filter_cache
	UNSETEMPTY(filter_data)

/obj/item/update_filters(start_index = null)
	. = ..()
	update_item_action_buttons()


/** Update a filter's parameter to the new one. If the filter doesn't exist we won't do anything.
 *
 * Arguments:
 * * name - Filter name
 * * new_params - New parameters of the filter
 * * overwrite - TRUE means we replace the parameter list completely. FALSE means we only replace the things on new_params.
 * * update - If we should apply our filter cache to our actual filters
 */
/datum/proc/modify_filter(name, list/new_params, overwrite = FALSE, update = TRUE)
	ASSERT(isatom(src) || isimage(src))
	var/atom/atom_cast = src // filters only work with images or atoms.
	for(var/index in 1 to length(filter_data))
		var/list/filter_info = filter_data[index]
		if(filter_info["name"] != name)
			continue

		if(overwrite)
			filter_data[index] = new_params
		else
			for(var/thing in new_params)
				filter_info[thing] = new_params[thing]

		var/list/arguments = filter_info.Copy()
		arguments -= "priority"
		filter_cache[index] = filter(arglist(arguments))

		if(update)
			atom_cast.filters = filter_cache
		return

/** Update a filter's parameter and animate this change. If the filter doesn't exist we won't do anything.
 * Basically a [datum/proc/modify_filter] call but with animations. Unmodified filter parameters are kept.
 *
 * Arguments:
 * * name - Filter name
 * * new_params - New parameters of the filter
 * * time - time arg of the BYOND animate() proc.
 * * easing - easing arg of the BYOND animate() proc.
 * * loop - loop arg of the BYOND animate() proc.
 */
/datum/proc/transition_filter(name, list/new_params, time, easing, loop)
	var/filter = get_filter(name)
	if(!filter)
		return
	// This can get injected by the filter procs, we want to support them so bye byeeeee
	new_params -= "type"
	animate(filter, new_params, time = time, easing = easing, loop = loop)
	modify_filter(name, new_params)

/** Keeps the steps in the correct order.
* Arguments:
* * params - the parameters you want this step to animate to
* * duration - the time it takes to animate this step
* * easing - the type of easing this step has
*/
/proc/filter_chain_step(params, duration, easing, flags)
	params -= "type"
	return list("params" = params, "duration" = duration, "easing" = easing, "flags" = flags)

/** Similar to transition_filter(), except it creates an animation chain that moves between a list of states.
 * Arguments:
 * * name - Filter name
 * * num_loops - Amount of times the chain loops. INDEFINITE = Infinite
 * * ... - a list of each link in the animation chain. Use filter_chain_step(params, duration, easing) for each link
 * Example use:
 * * add_filter("blue_pulse", 1, color_matrix_filter(COLOR_WHITE))
 * * transition_filter_chain(src, "blue_pulse", INDEFINITE,\
 * * filter_chain_step(color_matrix_filter(COLOR_BLUE), 10 SECONDS, CUBIC_EASING),\
 * * filter_chain_step(color_matrix_filter(COLOR_WHITE), 10 SECONDS, CUBIC_EASING))
 * The above code would edit a color_matrix_filter() to slowly turn blue over 10 seconds before returning back to white 10 seconds after, repeating this chain forever.
 */
/datum/proc/transition_filter_chain(name, num_loops, ...)
	var/list/transition_steps = args.Copy(3)
	var/filter = get_filter(name)
	if(!filter)
		return
	var/list/first_step = transition_steps[1]
	animate(filter, first_step["params"], time = first_step["duration"], easing = first_step["easing"], flags = first_step["flags"], loop = num_loops)
	for(var/transition_step in 2 to length(transition_steps))
		var/list/this_step = transition_steps[transition_step]
		animate(this_step["params"], time = this_step["duration"], easing = this_step["easing"], flags = this_step["flags"])

/// Updates the priority of the passed filter key
/datum/proc/change_filter_priority(name, new_priority)
	for(var/list/filter_info as anything in filter_data)
		if(filter_info["name"] != name)
			continue

		remove_filter(name, update = FALSE)
		add_filter(name, new_priority, filter_info)
		return

/// Returns the filter associated with the passed key
/datum/proc/get_filter(name)
	ASSERT(isatom(src) || isimage(src))
	var/atom/atom_cast = src // filters only work with images or atoms.
	return atom_cast.filters[name]

/// Returns filter data associated with the passed key
/datum/proc/get_filter_data(name)
	for(var/list/filter_info as anything in filter_data)
		if(filter_info["name"] == name)
			return filter_info.Copy()

/// Removes the passed filter, or multiple filters, if supplied with a list.
/datum/proc/remove_filter(name_or_names, update = TRUE)
	ASSERT(isatom(src) || isimage(src))
	if(!filter_data)
		return
	var/atom/atom_cast = src // filters only work with images or atoms.
	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)
	. = FALSE
	var/list/new_data = list()
	var/list/new_cache = list()
	for(var/index in 1 to length(filter_data))
		var/list/filter_info = filter_data[index]
		if(!(filter_info["name"] in names))
			new_data += list(filter_info)
			new_cache += filter_cache[index]
	filter_data = new_data
	filter_cache = new_cache
	if(update)
		atom_cast.filters = filter_cache
	return .

/datum/proc/clear_filters()
	ASSERT(isatom(src) || isimage(src))
	var/atom/atom_cast = src // filters only work with images or atoms.
	filter_data = null
	filter_cache = null
	atom_cast.filters = null
