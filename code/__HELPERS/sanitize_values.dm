/**
 * Sanitizes an integer value to ensure it falls within a specified range
 *
 * Arguments:
 * * input_number - The number to sanitize
 * * minimum_value - The minimum allowed value (default: 0)
 * * maximum_value - The maximum allowed value (default: 1)
 * * default_value - The value to return if input is invalid (default: 0)
 */
/proc/sanitize_integer(input_number, minimum_value = 0, maximum_value = 1, default_value = 0)
	if(isnum(input_number))
		input_number = round(input_number)
		if(minimum_value <= input_number && input_number <= maximum_value)
			return input_number
	return default_value

/**
 * Sanitizes a text value to ensure it is valid text
 *
 * Arguments:
 * * input_text - The text to sanitize
 * * default_value - The value to return if input is invalid (default: "")
 */
/proc/sanitize_text(input_text, default_value = "")
	if(istext(input_text))
		return input_text
	return default_value

/**
 * Sanitizes JSON input and returns a decoded list
 *
 * Arguments:
 * * json_input - The JSON string to decode and sanitize
 */
/proc/sanitize_json(json_input)
	if(length(json_input) && istext(json_input))
		return json_decode(json_input)
	return list()

/**
 * Sanitizes a value by ensuring it exists in a list
 *
 * Arguments:
 * * input_value - The value to check
 * * valid_list - The list of valid values
 * * default_value - The default value to return if input is invalid
 */
/proc/sanitize_inlist(input_value, list/valid_list, default_value)
	if(input_value in valid_list)
		return input_value
	if(default_value)
		return default_value
	if(valid_list?.len)
		return pick(valid_list)

/**
 * Sanitizes a gender value to ensure it is valid
 *
 * Arguments:
 * * input_gender - The gender to sanitize
 * * allow_neuter - Whether to allow neuter gender (default: FALSE)
 * * allow_plural - Whether to allow plural gender (default: FALSE)
 * * default_gender - The default gender to return if invalid (default: "male")
 */
/proc/sanitize_gender(input_gender, allow_neuter = FALSE, allow_plural = FALSE, default_gender = "male")
	switch(input_gender)
		if(MALE, FEMALE)
			return input_gender
		if(NEUTER)
			if(allow_neuter)
				return input_gender
			else
				return default_gender
		if(PLURAL)
			if(allow_plural)
				return input_gender
			else
				return default_gender
	return default_gender

/**
 * Sanitizes a hexadecimal color value to ensure it is valid
 *
 * Arguments:
 * * input_color - The color string to sanitize
 * * default - The default color to return if invalid (default: "#000000")
 */
/proc/sanitize_hexcolor(color, desired_format = DEFAULT_HEX_COLOR_LEN, include_crunch = TRUE, default)
	var/crunch = include_crunch ? "#" : ""
	if(!istext(color))
		color = ""

	var/start = 1 + (text2ascii(color, 1) == 35)
	var/len = length(color)
	var/char = ""
	// Used for conversion between RGBA hex formats.
	var/format_input_ratio = "[desired_format]:[length_char(color)-(start-1)]"

	. = ""
	var/i = start
	while(i <= len)
		char = color[i]
		i += length(char)
		switch(text2ascii(char))
			if(48 to 57) //numbers 0 to 9
				. += char
			if(97 to 102) //letters a to f
				. += char
			if(65 to 70) //letters A to F
				char = LOWER_TEXT(char)
				. += char
			else
				break
		switch(format_input_ratio)
			if("3:8", "4:8", "3:6", "4:6") //skip next one. RRGGBB(AA) -> RGB(A)
				i += length(color[i])
			if("6:4", "6:3", "8:4", "8:3") //add current char again. RGB(A) -> RRGGBB(AA)
				. += char

	if(length_char(.) == desired_format)
		return crunch + .
	switch(format_input_ratio) //add or remove alpha channel depending on desired format.
		if("3:8", "3:4", "6:4")
			return crunch + copytext(., 1, desired_format+1)
		if("4:6", "4:3", "8:3")
			return crunch + . + ((desired_format == 4) ? "f" : "ff")
		else //not a supported hex color format.
			return default ? default : crunch + repeat_string(desired_format, "0")
