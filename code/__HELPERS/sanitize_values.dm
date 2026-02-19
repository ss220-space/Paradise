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
 * * default_color - The default color to return if invalid (default: "#000000")
 */
/proc/sanitize_hexcolor(input_color, default_color = "#000000")
	if(!istext(input_color))
		return default_color
	var/color_length = length(input_color)
	if(color_length != 7 && color_length != 4)
		return default_color
	if(text2ascii(input_color, 1) != 35)
		return default_color // 35 is the ASCII code for "#"
	var/valid_color = "#"
	for(var/character_position = 2, character_position <= color_length, character_position++)
		var/character_code = text2ascii(input_color, character_position)
		switch(character_code)
			if(48 to 57)
				valid_color += ascii2text(character_code) // numbers 0 to 9
			if(97 to 102)
				valid_color += ascii2text(character_code) // letters a to f
			if(65 to 70)
				valid_color += ascii2text(character_code + 32) // letters A to F - translates to lowercase
			else
				return default_color
	return valid_color
