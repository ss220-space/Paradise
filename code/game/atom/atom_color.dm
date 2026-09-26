/*!
 * Atom Colour Priority System
 * A System that gives finer control over which atom colour to colour the atom with.
 * The "highest priority" one is always displayed as opposed to the default of
 * "whichever was set last is displayed"
 *
 * It can also be used for color filters, since some effects (using non-RGB space matrices)
 * are impossible to achieve with just the color variable
 */

///Adds an instance of colour_type to the atom's atom_colours list
/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!atom_colours || !length(atom_colours))
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(!coloration)
		return
	if(colour_priority > length(atom_colours))
		return
	var/color_type = ATOM_COLOR_TYPE_NORMAL
	if(islist(coloration))
		var/list/color_matrix = coloration
		if(color_matrix["type"] == "color")
			color_type = ATOM_COLOR_TYPE_FILTER
	atom_colours[colour_priority] = list(coloration, color_type)
	update_atom_colour()

///Removes an instance of colour_type from the atom's atom_colours list
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		return
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority])
		if(atom_colours[colour_priority][ATOM_COLOR_TYPE_INDEX] == ATOM_COLOR_TYPE_NORMAL)
			if(atom_colours[colour_priority][ATOM_COLOR_VALUE_INDEX] != coloration)
				return //if we don't have the expected color (for a specific priority) to remove, do nothing
		else
			if(!islist(coloration) || !compare_list(coloration, atom_colours[colour_priority][ATOM_COLOR_VALUE_INDEX]["color"]))
				return
	atom_colours[colour_priority] = null
	update_atom_colour()

///Resets the atom's color to null, and then sets it to the highest priority colour available
/atom/proc/update_atom_colour()
	var/old_filter = cached_color_filter
	var/old_color = color
	color = null
	cached_color_filter = null
	remove_filter(ATOM_PRIORITY_COLOR_FILTER)
	REMOVE_KEEP_TOGETHER(src, ATOM_COLOR_TRAIT)

	if(!atom_colours)
		if(!(SEND_SIGNAL(src, COMSIG_ATOM_COLOR_UPDATED, old_color || old_filter) & COMPONENT_CANCEL_COLOR_APPEARANCE_UPDATE) && old_filter)
			update_appearance()
		return

	for(var/list/checked_color in atom_colours)
		if(checked_color[ATOM_COLOR_TYPE_INDEX] == ATOM_COLOR_TYPE_FILTER)
			add_filter(ATOM_PRIORITY_COLOR_FILTER, ATOM_PRIORITY_COLOR_FILTER_PRIORITY, checked_color[ATOM_COLOR_VALUE_INDEX])
			cached_color_filter = checked_color[ATOM_COLOR_VALUE_INDEX]
			break

		if(length(checked_color[ATOM_COLOR_VALUE_INDEX]))
			color = checked_color[ATOM_COLOR_VALUE_INDEX]
			break

	ADD_KEEP_TOGETHER(src, ATOM_COLOR_TRAIT)
	if(!(SEND_SIGNAL(src, COMSIG_ATOM_COLOR_UPDATED, old_color != color || old_filter != cached_color_filter) & COMPONENT_CANCEL_COLOR_APPEARANCE_UPDATE) && cached_color_filter != old_filter)
		update_appearance()

/// Same as update_atom_color, but simplifies overlay coloring
/atom/proc/color_atom_overlay(mutable_appearance/overlay)
	overlay.color = color
	if(!cached_color_filter)
		return overlay
	// Apply the atom's color filter to the overlay using named filters so that
	// later calls to add_filter/update_filters (e.g., height displacement filters)
	// do not wipe out our coloration. Mirror prior behavior by propagating to
	// child overlays unless KEEP_TOGETHER is present.
	overlay.add_filter(ATOM_PRIORITY_COLOR_FILTER, ATOM_PRIORITY_COLOR_FILTER_PRIORITY, cached_color_filter)

	if(!(overlay.appearance_flags & KEEP_TOGETHER))
		// Recursively ensure any nested overlays/underlays also get the color filter
		for(var/mutable_appearance/child_overlay as anything in overlay.overlays)
			if(!(child_overlay.appearance_flags & KEEP_APART))
				color_atom_overlay(child_overlay)
		for(var/mutable_appearance/child_underlay as anything in overlay.underlays)
			if(!(child_underlay.appearance_flags & KEEP_APART))
				color_atom_overlay(child_underlay)

	return overlay
