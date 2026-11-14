/proc/overmap_format_ship_name(pattern, faction, class_code, registration, ship_name)
	var/result = pattern || OVERMAP_SHIP_NAME_TEMPLATE
	result = replacetext(result, "$faction$", GLOB.overmap_faction_prefixes[faction] || "UN")
	result = replacetext(result, "$class$", class_code)
	result = replacetext(result, "$id$", registration)
	result = replacetext(result, "$shipname$", ship_name)
	return trim(strip_html(result, MAX_NAME_LEN))
