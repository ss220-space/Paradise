/proc/make_types_fancy(list/types)
	if(ispath(types))
		types = list(types)
	var/static/list/types_to_replacement
	var/static/list/replacement_to_text
	if(!types_to_replacement)
		// ignore_root_path so we can draw the root normally
		var/list/fancy_type_cache = GLOB.fancy_type_replacements
		var/list/local_replacements = zebra_typecacheof(fancy_type_cache, ignore_root_path = TRUE)
		var/list/local_texts = list()
		for(var/key in fancy_type_cache)
			local_texts[local_replacements[key]] = "[key]"
		types_to_replacement = local_replacements
		replacement_to_text = local_texts

	. = list()
	var/list/local_replacements = types_to_replacement
	var/list/local_texts = replacement_to_text
	for(var/type in types)
		var/replace_with = local_replacements[type]
		if(!replace_with)
			.["[type]"] = type
			continue
		var/cut_out = local_texts[replace_with]
		// + 1 to account for /
		.[replace_with + copytext("[type]", length(cut_out) + 1)] = type

/// Returns a pre-generated fancy list of all atom types
/proc/get_fancy_list_of_atom_types()
	var/static/list/pre_generated_atom_list
	if(!pre_generated_atom_list) // Initialize on first call
		pre_generated_atom_list = make_types_fancy(typesof(/atom))
	return pre_generated_atom_list

/// Returns a pre-generated fancy list of all datum types (excluding atoms)
/proc/get_fancy_list_of_datum_types()
	var/static/list/pre_generated_datum_list
	if(!pre_generated_datum_list) // Initialize on first call
		pre_generated_datum_list = make_types_fancy(sortList(typesof(/datum) - typesof(/atom)))
	return pre_generated_datum_list

/**
 * Filters a fancy list by a given search term
 *
 * Arguments:
 * * source - The list to filter
 * * filter - The text to search for in keys and values
 */
/proc/filter_fancy_list(list/source, filter as text)
	var/list/matches = new
	var/end_len = -1
	var/list/end_check = splittext(filter, "!")
	if(end_check.len > 1)
		filter = end_check[1]
		end_len = length_char(filter)

	var/endtype = (filter[length(filter)] == "*")
	if(endtype)
		filter = splittext(filter, "*")[1]

	for(var/key in source)
		var/value = source[key]
		if(findtext("[key]", filter, -end_len))
			if(endtype)
				var/list/split_filter = splittext("[key]", filter)
				if(!findtext(split_filter[length(split_filter)], "/"))
					if(value)
						matches[key] = value
					else
						matches += key
					continue
			else
				if(value)
					matches[key] = value
				else
					matches += key
				continue

		if(value && findtext("[value]", filter, -end_len))
			if(endtype)
				var/list/split_filter = splittext("[value]", filter)
				if(findtext(split_filter[length(split_filter)], "/"))
					continue
			matches[key] = value

	return matches

/// Splits a type path into its component names
/proc/return_typenames(type_path)
	return splittext("[type_path]", "/")
