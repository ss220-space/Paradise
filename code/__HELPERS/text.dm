/proc/format_table_name(table as text)
	return CONFIG_GET(string/feedback_tableprefix) + table

/// Simply removes < and > and limits the length of the message
/proc/strip_html_simple(t, limit=MAX_MESSAGE_LEN)
	var/list/strip_chars = list("<",">")
	t = copytext(t,1,limit)
	for(var/char in strip_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + copytext(t, index+1)
			index = findtext(t, char)
	return t

/// Removes a few problematic characters
/proc/sanitize_simple(t, list/repl_chars = list("\n"="#","\t"="#"))
	for(var/char in repl_chars)
		t = replacetext(t, char, repl_chars[char])
	return t

/proc/sanitize_censored_patterns(t)
	if(!global.config || !CONFIG_GET(flag/twitch_censor) || !GLOB.twitch_censor_list)
		return t

	var/text = sanitize_simple(t, GLOB.twitch_censor_list)
	if(t != text)
		message_admins("CENSOR DETECTION: [ADMIN_FULLMONTY(usr)] inputs: \"[html_encode(t)]\"")
		log_adminwarn("CENSOR DETECTION: [key_name_log(usr)] inputs: \"[t]\"")

	return text

/proc/readd_quote(t)
	var/list/repl_chars = list("&#39;" = "'")
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+5)
			index = findtext(t, char)
	return t

/// Runs byond's sanitization proc along-side sanitize_simple
/proc/sanitize(t, list/repl_chars = null)
	return sanitize_censored_patterns(html_encode(sanitize_simple(t,repl_chars)))

/// Gut ANYTHING that isnt alphanumeric, or brackets
/proc/filename_sanitize(t)
	var/regex/alphanum_only = regex("\[^a-zA-Z0-9._/-]", "g")
	return alphanum_only.Replace(t, "")

/// Gut ANYTHING that isnt alphanumeric, or brackets
/proc/paranoid_sanitize(t)
	var/regex/alphanum_only = regex("\[^a-zA-Z0-9# ,.?!:;()]", "g")
	return alphanum_only.Replace(t, "#")

/proc/random_string(length, list/characters)
	. = ""
	for(var/i in 1 to length)
		. += pick(characters)

/proc/repeat_string(times, string = "")
	. = ""
	for(var/i in 1 to times)
		. += string

/// Runs sanitize and strip_html_simple
/// I believe strip_html_simple() is required to run first to prevent '<' from displaying as '&lt;' after sanitize() calls byond's html_encode()
/proc/strip_html(t, limit=MAX_MESSAGE_LEN)
	return copytext((sanitize(strip_html_simple(t))),1,limit)

/// Used to get a properly sanitized multiline input, of max_length
/proc/stripped_multiline_input(mob/user, message = "", title = "", default = "", max_length=MAX_MESSAGE_LEN, no_trim=FALSE)
	var/name = input(user, message, title, default) as message|null
	if(no_trim)
		return copytext(html_encode(name), 1, max_length)
	else
		return trim(html_encode(name), max_length)

/// Runs byond's sanitization proc along-side strip_html_simple
/// I believe strip_html_simple() is required to run first to prevent '<' from displaying as '&lt;' that html_encode() would cause
/proc/adminscrub(t, limit=MAX_MESSAGE_LEN)
	return copytext((html_encode(strip_html_simple(t))),1,limit)

/// Returns null if there is any bad text in the string
/proc/reject_bad_text(text, max_length=512)
	if(length_char(text) > max_length)	return			//message too long
	var/non_whitespace = 0
	for(var/i=1, i<=length_char(text), i++)
		switch(text2ascii_char(text,i))
			if(62,60,92,47)	return			//rejects the text if it contains these bad characters: <, >, \ or /
			if(127 to 255)	return			//rejects weird letters like �
			if(0 to 31)		return			//more weird stuff
			if(32)			continue		//whitespace
			else			non_whitespace = 1
	if(non_whitespace)		return text		//only accepts the text if it has some non-spaces

/// Used to get a sanitized input.
/proc/stripped_input(mob/user, message = "", title = "", default = "", max_length=MAX_MESSAGE_LEN, no_trim=FALSE)
	var/name = html_encode(input(user, message, title, default) as text|null)
	if(!no_trim)
		name = trim(name) //trim is "outside" because html_encode can expand single symbols into multiple symbols (such as turning < into &lt;)
	return copytext(name, 1, max_length)

/// Uses client.typing to check if the popup should appear or not
/proc/typing_input(mob/user, message = "", title = "", default = "")
	var/client/C = user.client // Save it in a var in case the client disconnects from the mob
	C.typing = TRUE
	var/msg = tgui_input_text(user, message, title, default)
	if(!C)
		return null
	C.typing = FALSE
	if(!user || C != user.client) // User got out of the mob for some reason or the mob is gone
		return null
	return msg

/// Filters out undesirable characters from names
/proc/reject_bad_name(t_in, allow_numbers=0, max_length=MAX_NAME_LEN)
	// Decode so that names with characters like < are still rejected
	t_in = html_decode(t_in)
	if(!t_in || length_char(t_in) > max_length)
		return //Rejects the input if it is null or if it is longer than the max length allowed

	var/number_of_alphanumeric	= 0
	var/last_char_group			= 0
	var/t_out = ""

	for(var/i=1, i<=length_char(t_in), i++)
		var/ascii_char = text2ascii_char(t_in,i)
		switch(ascii_char)
			// A  .. Z, А .. Я, Ё
			if(65 to 90, 1040 to 1071, 1025)			//Uppercase Letters
				t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 4

			// a  .. z, а .. я, ё
			if(97 to 122, 1072 to 1103, 1105)			//Lowercase Letters
				if(last_char_group<2)		t_out += uppertext(ascii2text(ascii_char))	//Force uppercase first character
				else						t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 4

			// 0  .. 9
			if(48 to 57)			//Numbers
				if(!last_char_group)		continue	//suppress at start of string
				if(!allow_numbers)			continue
				t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 3

			// '  -  . ,
			if(39, 45, 46, 44)			//Common name punctuation
				if(!last_char_group) continue
				t_out += ascii2text(ascii_char)
				last_char_group = 2

			// ~   |   @  :  #  $  %  & *  +  !
			if(126, 124, 64, 58, 35, 36, 37, 38, 42, 43, 33)			//Other symbols that we'll allow (mainly for AI)
				if(!last_char_group)		continue	//suppress at start of string
				if(!allow_numbers)			continue
				t_out += ascii2text(ascii_char)
				last_char_group = 2

			//Space
			if(32)
				if(last_char_group <= 1)	continue	//suppress double-spaces and spaces at start of string
				t_out += ascii2text(ascii_char)
				last_char_group = 1
			else
				return

	if(number_of_alphanumeric < 2)	return		//protects against tiny names like "A" and also names like "' ' ' ' ' ' ' '"

	if(last_char_group == 1)
		t_out = copytext(t_out,1,length(t_out))	//removes the last character (in this case a space)

	for(var/bad_name in list("space","floor","wall","r-wall","monkey","unknown","inactive ai","plating"))	//prevents these common metagamey names
		if(cmptext(t_out,bad_name))	return	//(not case sensitive)

	return t_out

/// Checks the beginning of a string for a specified sub-string. This proc is case sensitive
/// Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix_case(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtextEx_char(text, prefix, start, end)

/// Checks the end of a string for a specified substring.
/// Returns the position of the substring or 0 if it was not found
/proc/dd_hassuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtext_char(text, suffix, start, null)
	return

/proc/replace_characters(t, list/repl_chars, case_sensitive = FALSE)
	for(var/char in repl_chars)
		if(case_sensitive)
			t = replacetextEx_char(t, char, repl_chars[char])
		else
			t = replacetext_char(t, char, repl_chars[char])
	return t

/// Adds 'u' number of zeros ahead of the text 't'
/proc/add_zero(t, u)
	while(length(t) < u)
		t = "0[t]"
	return t

/// Returns a string with reserved characters and spaces before the first letter removed
/proc/trim_left(text)
	for(var/i = 1 to length(text))
		if(text2ascii(text, i) != 32)
			return copytext(text, i)
	return ""

/// Returns a string with reserved characters and spaces after the last letter removed
/proc/trim_right(text)
	for(var/i = length(text), i > 0, i--)
		if(text2ascii(text, i) != 32)
			return copytext(text, 1, i + 1)

	return ""

/// Returns a string with reserved characters and spaces before the first word and after the last word removed.
/proc/trim(text, max_length)
	if(max_length)
		text = copytext_char(text, 1, max_length)

	return trimtext(text) || ""

/// Returns a string that does not exceed max_length characters in size
/proc/trim_length(text, max_length)
	return copytext_char(text, 1, max_length)

/// Returns a string with the first element of the string capitalized.
/proc/capitalize(text)
	. = text
	if(text)
		. = text[1]
		return uppertext(.) + copytext(text, 1 + length(.))

///Returns a string depending on number it receives
/proc/numeric_ending(num, more, one, three)
	var/last_digit = num % 10
	var/last_two_digit = num % 100

	if(last_two_digit >= 11 && last_two_digit <= 14)
		return more
	if(last_digit == 1)
		return one
	if(last_digit >= 2 && last_digit <= 4)
		return three
	else
		return more

/// Limits the length of the text. Note: MAX_MESSAGE_LEN and MAX_NAME_LEN are widely used for this purpose
/proc/dd_limittext(message, length)
	var/size = length(message)
	if(size <= length)
		return message
	return copytext(message, 1, length + 1)

/proc/stringmerge(text,compare,replace = "*")
	//This proc fills in all spaces with the "replace" var (* by default) with whatever
	//is in the other string at the same spot (assuming it is not a replace char).
	//This is used for fingerprints
	var/newtext = text
	if(length(text) != length(compare))
		return 0
	for(var/i = 1, i < length(text), i++)
		var/a = copytext(text,i,i+1)
		var/b = copytext(compare,i,i+1)
	//if it isn't both the same letter, or if they are both the replacement character
	//(no way to know what it was supposed to be)
		if(a != b)
			if(a == replace) //if A is the replacement char
				newtext = copytext(newtext,1,i) + b + copytext(newtext, i+1)
			else if(b == replace) //if B is the replacement char
				newtext = copytext(newtext,1,i) + a + copytext(newtext, i+1)
			else //The lists disagree, Uh-oh!
				return 0
	return newtext

/proc/stringpercent(text,character = "*")
	//This proc returns the number of chars of the string that is the character
	//This is used for detective work to determine fingerprint completion.
	if(!text || !character)
		return 0
	var/count = 0
	for(var/i = 1, i <= length(text), i++)
		var/a = copytext(text,i,i+1)
		if(a == character)
			count++
	return count

/// This proc strips html properly, but it's not lazy like the other procs.
/// This means that it doesn't just remove < and > and call it a day.
/// Also limit the size of the input, if specified.
/proc/strip_html_properly(input, max_length = MAX_MESSAGE_LEN, allow_lines = 0)
	if(!input)
		return
	var/opentag = 1 //These store the position of < and > respectively.
	var/closetag = 1
	while(1)
		opentag = findtext(input, "<")
		closetag = findtext(input, ">")
		if(closetag && opentag)
			if(closetag < opentag)
				input = copytext(input, (closetag + 1))
			else
				input = copytext(input, 1, opentag) + copytext(input, (closetag + 1))
		else if(closetag || opentag)
			if(opentag)
				input = copytext(input, 1, opentag)
			else
				input = copytext(input, (closetag + 1))
		else
			break
	if(max_length)
		input = copytext_char(input,1,max_length)
	return sanitize(input, allow_lines ? list("\t" = " ") : list("\n" = " ", "\t" = " "))

/proc/trim_strip_html_properly(input, max_length = MAX_MESSAGE_LEN, allow_lines = 0)
	return trim(strip_html_properly(input, max_length, allow_lines))

/// Used in preferences' SetFlavorText and human's set_flavor verb
/// Previews a string of len or less length
/proc/TextPreview(string, len=60)
	if(length_char(string) <= len)
		if(!length_char(string))
			return "\[...\]"
		else
			return html_encode(string) //NO DECODED HTML YOU CHUCKLEFUCKS
	else
		return "[copytext_preserve_html(string, 1, len-3)]..."

/// alternative copytext() for encoded text, doesn't break html entities (&#34; and other)
/proc/copytext_preserve_html(text, first, last)
	return html_encode(copytext_char(html_decode(text), first, last))

/proc/dmm_encode(text)
	// First, go through and nix out any of our escape sequences so we don't leave ourselves open to some escape sequence attack
	// Some coder will probably despise me for this, years down the line
	var/list/repl_chars = list("#?qt;", "#?lbr;", "#?rbr;")
	for(var/char in repl_chars)
		var/index = findtext(text, char)
		var/keylength = length(char)
		while(index)
			stack_trace("Bad string given to dmm encoder! [text]")
			// Replace w/ underscore to prevent "&#3&#123;4;" from cheesing the radar
			// Should probably also use canon text replacing procs
			text = copytext(text, 1, index) + "_" + copytext(text, index+keylength)
			index = findtext(text, char)

	// Then, replace characters as normal
	var/list/repl_chars_2 = list("\"" = "#?qt;", "{" = "#?lbr;", "}" = "#?rbr;")
	for(var/char in repl_chars_2)
		var/index = findtext(text, char)
		var/keylength = length(char)
		while(index)
			text = copytext(text, 1, index) + repl_chars_2[char] + copytext(text, index+keylength)
			index = findtext(text, char)
	return text

/proc/dmm_decode(text)
	// Replace what we extracted above
	var/list/repl_chars = list("#?qt;" = "\"", "#?lbr;" = "{", "#?rbr;" = "}")
	for(var/char in repl_chars)
		var/index = findtext(text, char)
		var/keylength = length(char)
		while(index)
			text = copytext(text, 1, index) + repl_chars[char] + copytext(text, index+keylength)
			index = findtext(text, char)
	return text

/**
 * Converts pencode to HTML with various formatting options
 *
 * Arguments:
 * * input_text - The text containing pencode to convert
 * * user_mob - The mob using the pen (for signature and species)
 * * pen_item - The pen item being used (can be null)
 * * enable_formatting - Whether to enable basic formatting (headings, center, etc.)
 * * enable_signature - Whether to enable signature replacement
 * * enable_fields - Whether to enable field replacement
 * * default_font - The default font to use
 * * signature_font - The font to use for signatures
 * * crayon_font - The font to use for crayons
 * * disable_font - Whether to disable font styling entirely
 */
/proc/pencode_to_html(input_text, mob/user_mob, obj/item/pen/pen_item = null, enable_formatting = TRUE, enable_signature = TRUE, enable_fields = TRUE, default_font = PEN_FONT, signature_font = SIGNFONT, crayon_font = CRAYON_FONT, disable_font = FALSE)
	input_text = replacetext(input_text, "\[b\]", "<b>")
	input_text = replacetext(input_text, "\[/b\]", "</b>")
	input_text = replacetext(input_text, "\[i\]", "<i>")
	input_text = replacetext(input_text, "\[/i\]", "</i>")
	input_text = replacetext(input_text, "\[u\]", "<u>")
	input_text = replacetext(input_text, "\[/u\]", "</u>")

	if((findtext(input_text, "\[signfont\]") || findtext(input_text, "\[/signfont\]")) && check_rights(R_EVENT)) // Make sure the text is there before giving off an error
		input_text = replacetext(input_text, "\[signfont\]", "<font face=\"[signature_font]\"><i>")
		input_text = replacetext(input_text, "\[/signfont\]", "</i></font>")

	if(enable_signature)
		input_text = replacetext(input_text, "\[sign\]", "<font face=\"[signature_font]\"><i>[user_mob ? user_mob.real_name : "Anonymous"]</i></font>")

	if(enable_fields)
		input_text = replacetext(input_text, "\[field\]", "<span class=\"paper_field\"></span>")

	if(enable_formatting)
		input_text = replacetext(input_text, "\[h1\]", "<h1>")
		input_text = replacetext(input_text, "\[/h1\]", "</h1>")
		input_text = replacetext(input_text, "\[h2\]", "<h2>")
		input_text = replacetext(input_text, "\[/h2\]", "</h2>")
		input_text = replacetext(input_text, "\[h3\]", "<h3>")
		input_text = replacetext(input_text, "\[/h3\]", "</h3>")
		input_text = replacetext(input_text, "\n", "<br>")
		input_text = replacetext(input_text, "\[center\]", "<center>")
		input_text = replacetext(input_text, "\[/center\]", "</center>")
		input_text = replacetext(input_text, "\[br\]", "<br>")
		input_text = replacetext(input_text, "\[large\]", "<font size=\"4\">")
		input_text = replacetext(input_text, "\[/large\]", "</font>")

	// Crayon-specific handling - disable advanced formatting
	if(iscrayon(pen_item) || !enable_formatting)
		input_text = replacetext(input_text, "\[*\]", "")
		input_text = replacetext(input_text, "\[hr\]", "")
		input_text = replacetext(input_text, "\[small\]", "")
		input_text = replacetext(input_text, "\[/small\]", "")
		input_text = replacetext(input_text, "\[list\]", "")
		input_text = replacetext(input_text, "\[/list\]", "")
		input_text = replacetext(input_text, "\[table\]", "")
		input_text = replacetext(input_text, "\[/table\]", "")
		input_text = replacetext(input_text, "\[row\]", "")
		input_text = replacetext(input_text, "\[cell\]", "")
		input_text = replacetext(input_text, "\[logo\]", "")
		input_text = replacetext(input_text, "\[slogo\]", "")
		input_text = replacetext(input_text, "\[time\]", "")
		input_text = replacetext(input_text, "\[date\]", "")
		input_text = replacetext(input_text, "\[station\]", "")

	// Apply crayon formatting if using a crayon
	if(iscrayon(pen_item))
		input_text = "<font face=\"[crayon_font]\" color=[pen_item ? pen_item.colour : "black"]><b>[input_text]</b></font>"
	else
		// Apply advanced formatting for non-crayon writing instruments
		input_text = replacetext(input_text, "\[*\]", "<li>")
		input_text = replacetext(input_text, "\[hr\]", "<hr>")
		input_text = replacetext(input_text, "\[small\]", "<font size = \"1\">")
		input_text = replacetext(input_text, "\[/small\]", "</font>")
		input_text = replacetext(input_text, "\[list\]", "<ul>")
		input_text = replacetext(input_text, "\[/list\]", "</ul>")
		input_text = replacetext(input_text, "\[table\]", "<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>")
		input_text = replacetext(input_text, "\[/table\]", "</td></tr></table>")
		input_text = replacetext(input_text, "\[grid\]", "<table>")
		input_text = replacetext(input_text, "\[/grid\]", "</td></tr></table>")
		input_text = replacetext(input_text, "\[row\]", "</td><tr>")
		input_text = replacetext(input_text, "\[cell\]", "<td>")
		input_text = replacetext(input_text, "\[logo\]", "&ZeroWidthSpace;<img src = ntlogo.png>")
		input_text = replacetext(input_text, "\[slogo\]", "&ZeroWidthSpace;<img src = syndielogo.png>")
		input_text = replacetext(input_text, "\[ussplogo\]", "&ZeroWidthSpace;<img src = ussplogo.png>")
		input_text = replacetext(input_text, "\[solgov\]", "&ZeroWidthSpace;<img src = solgovlogo.png>")
		input_text = replacetext(input_text, "\[time\]", "[station_time_timestamp()]")
		input_text = replacetext(input_text, "\[date\]", "[GLOB.current_date_string]")
		input_text = replacetext(input_text, "\[station\]", "[station_name()]")
		input_text = replacetext(input_text, "\[gender\]", "[user_mob ? user_mob.gender : "neuter"]")
		input_text = replacetext(input_text, "\[species\]", "[user_mob?.dna?.species ? user_mob.dna.species : UNKNOWN_STATUS_RUS]")

		// Apply font styling unless disabled
		if(!disable_font)
			if(pen_item)
				input_text = "<font face=\"[pen_item.fake_signing ? signature_font : default_font]\" color=[pen_item ? pen_item.colour : "black"]>[input_text]</font>"
				if(pen_item.fake_signing)
					input_text = "<i>[input_text]</i>"
			else
				input_text = "<font face=\"[default_font]\">[input_text]</font>"

	input_text = copytext(input_text, 1, MAX_PAPER_MESSAGE_LEN)
	return input_text

/**
 * Converts pencode arguments to HTML tags with safety checks
 * Called by admin_pencode_to_html to handle custom tags
 *
 * Arguments:
 * * original_text - The original text that matched the regex
 * * tag_type - The type of tag (class, style, img)
 * * tag_arguments - The arguments provided for the tag
 */
/proc/convert_pencode_arg(original_text, tag_type, tag_arguments)
	tag_arguments = sanitize_simple(html_encode(tag_arguments), list("''"="", "\""="", "?"=""))
	tag_arguments = sanitize_censored_patterns(tag_arguments)

	// https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html#rule-4---css-escape-and-strictly-validate-before-inserting-untrusted-data-into-html-style-property-values
	var/list/dangerous_patterns = list("javascript:", "expression", "byond:", "file:")

	for(var/dangerous_pattern in dangerous_patterns)
		if(findtext(tag_arguments, dangerous_pattern))
			// Do not attempt to render dangerous content
			return original_text

	if(tag_type == "class")
		return "<span class='[tag_arguments]'>"

	if(tag_type == "style")
		return "<span style='[tag_arguments]'>"

	if(tag_type == "img")
		var/list/image_properties = splittext(tag_arguments, ";")
		if(length(image_properties) == 3)
			return "<img src='[image_properties[1]]' width='[image_properties[2]]' height='[image_properties[3]]'>"
		if(length(image_properties) == 2)
			return "<img src='[image_properties[1]]' width='[image_properties[2]]'>"
		return "<img src='[tag_arguments]'>"

	return original_text

/**
 * Converts pencode to HTML with additional admin-specific formatting
 * Handles custom classes, styles, and images in pencode
 */
/proc/admin_pencode_to_html()
	var/input_text = pencode_to_html(arglist(args))
	var/regex/style_regex = new(@"\[(.*?) (.*?)\]", "ge")
	input_text = style_regex.Replace(input_text, /proc/convert_pencode_arg)

	input_text = replacetext(input_text, "\[/class\]", "</span>")
	input_text = replacetext(input_text, "\[/style\]", "</span>")
	input_text = replacetext(input_text, "\[/img\]", "</img>")

	return input_text

/**
 * Converts HTML back to pencode format
 *
 * Arguments:
 * * input_text - The HTML text to convert to pencode
 */
/proc/html_to_pencode(input_text)
	input_text = replacetext(input_text, "<br>", "\n")
	input_text = replacetext(input_text, "<center>", "\[center\]")
	input_text = replacetext(input_text, "</center>", "\[/center\]")
	input_text = replacetext(input_text, "<br>", "\[br\]")
	input_text = replacetext(input_text, "<b>", "\[b\]")
	input_text = replacetext(input_text, "</b>", "\[/b\]")
	input_text = replacetext(input_text, "<i>", "\[i\]")
	input_text = replacetext(input_text, "</i>", "\[/i\]")
	input_text = replacetext(input_text, "<u>", "\[u\]")
	input_text = replacetext(input_text, "</u>", "\[/u\]")
	input_text = replacetext(input_text, "<font size=\"4\">", "\[large\]")
	input_text = replacetext(input_text, "<span class=\"paper_field\"></span>", "\[field\]")

	input_text = replacetext(input_text, "<h1>", "\[h1\]")
	input_text = replacetext(input_text, "</h1>", "\[/h1\]")
	input_text = replacetext(input_text, "<h2>", "\[h2\]")
	input_text = replacetext(input_text, "</h2>", "\[/h2\]")
	input_text = replacetext(input_text, "<h3>", "\[h3\]")
	input_text = replacetext(input_text, "</h3>", "\[/h3\]")

	input_text = replacetext(input_text, "<li>", "\[*\]")
	input_text = replacetext(input_text, "<hr>", "\[hr\]")
	input_text = replacetext(input_text, "<font size = \"1\">", "\[small\]")
	input_text = replacetext(input_text, "<ul>", "\[list\]")
	input_text = replacetext(input_text, "</ul>", "\[/list\]")
	input_text = replacetext(input_text, "<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>", "\[table\]")
	input_text = replacetext(input_text, "</td></tr></table>", "\[/table\]")
	input_text = replacetext(input_text, "<table>", "\[grid\]")
	input_text = replacetext(input_text, "</td></tr></table>", "\[/grid\]")
	input_text = replacetext(input_text, "</td><tr>", "\[row\]")
	input_text = replacetext(input_text, "<td>", "\[cell\]")
	input_text = replacetext(input_text, "<img src = ntlogo.png>", "\[logo\]")
	input_text = replacetext(input_text, "<img src = syndielogo.png>", "\[slogo\]")
	input_text = replacetext(input_text, "<img src = ussplogo.png>", "\[ussplogo\]")

	return input_text

// MARK: TODO: DEL
/// Returns the rot13'ed text
/proc/rot13(text = "")
	var/lentext = length(text)
	var/char = ""
	var/ascii = 0
	. = ""
	for(var/i = 1, i <= lentext, i += length(char))
		char = text[i]
		ascii = text2ascii(char)
		switch(ascii)
			if(65 to 77, 97 to 109) //A to M, a to m
				ascii += 13
			if(78 to 90, 110 to 122) //N to Z, n to z
				ascii -= 13
			if(1072 to 1084, 1040 to 1052)
				ascii += 13
			if(1085 to 1097, 1053 to 1065)
				ascii -= 13
		. += ascii2text(ascii)

/// Used for applying byonds text macros to strings that are loaded at runtime
/proc/apply_text_macros(string)
	var/next_backslash = findtext(string, "\\")
	if(!next_backslash)
		return string

	var/leng = length(string)

	var/next_space = findtext(string, " ", next_backslash + length(string[next_backslash]))
	if(!next_space)
		next_space = leng - next_backslash

	if(!next_space)	//trailing bs
		return string

	var/base = next_backslash == 1 ? "" : copytext(string, 1, next_backslash)
	var/macro = lowertext(copytext(string, next_backslash + length(string[next_backslash]), next_space))
	var/rest = next_backslash > leng ? "" : copytext(string, next_space + length(string[next_space]))

	//See https://secure.byond.com/docs/ref/info.html#/DM/text/macros
	switch(macro)
		//prefixes/agnostic
		if("the")
			rest = text("\the []", rest)
		if("a")
			rest = text("\a []", rest)
		if("an")
			rest = text("\an []", rest)
		if("proper")
			rest = text("\proper []", rest)
		if("improper")
			rest = text("\improper []", rest)
		if("roman")
			rest = text("\roman []", rest)
		//postfixes
		if("th")
			base = text("[]\th", rest)
		if("s")
			base = text("[]\s", rest)
		if("he")
			base = text("[]\he", rest)
		if("she")
			base = text("[]\she", rest)
		if("his")
			base = text("[]\his", rest)
		if("himself")
			base = text("[]\himself", rest)
		if("herself")
			base = text("[]\herself", rest)
		if("hers")
			base = text("[]\hers", rest)
		else // Someone fucked up, if you're not a macro just go home yeah?
			// This does technically break parsing, but at least it's better then what it used to do
			return base

	. = base
	if(rest)
		. += .(rest)

/// Removes characters incompatible with file names.
/proc/sanitize_filename(text)
	var/static/regex/regex = regex(@{""|[\\\n\t/?%*:|<>]|\.\."}, "g")
	return regex.Replace(text, "")

/**
 * Formats num with an SI prefix.
 *
 * Returns a string formatted with a multiple of num and an SI prefix corresponding to an exponent of 10.
 * Only considers exponents that are multiples of 3 (deca, deci, hecto, and centi are not included).
 * A unit is not included in the string, the prefix is placed after the number with no spacing added anywhere.
 * Listing of prefixes: https://en.wikipedia.org/wiki/Metric_prefix#List_of_SI_prefixes
 */
/proc/format_si_suffix(num)
	if(num == 0)
		return "[num]"

	var/exponent = round_down(log(10, abs(num)))
	var/ofthree = exponent / 3
	if(exponent < 0)
		ofthree = round(ofthree)
	else
		ofthree = round_down(ofthree)
	if(ofthree == 0)
		return "[num]"
	return "[num / (10 ** (ofthree * 3))][GLOB.si_suffixes[round(length(GLOB.si_suffixes) / 2) + ofthree + 1]]"

/// Returns TRUE if the input_text ends with the ending
/proc/endswith(input_text, ending)
	var/input_length = LAZYLEN(ending)
	return !!findtext(input_text, ending, -input_length)

/// Properly format a string of text by using replacetext()
/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")

/// Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ionnum()
	return "[pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

/**
 * Escapes regex special characters in a string for safe use in regular expressions
 *
 * Arguments:
 * * input_text - The text to escape for regex
 */
/proc/escape_regex_smart(input_text)
	var/list/special_chars = list(".", "*", "+", "?", "^", "$", "(", ")", "[", "]", "{", "}", "|")
	input_text = replacetext(input_text, "\\", "\\\\")
	for(var/current_char in special_chars)
		input_text = replacetext(input_text, current_char, "\\[current_char]")
	for(var/current_char in special_chars)
		input_text = replacetext(input_text, "\\\\\\[current_char]", "\\[current_char]")
	return input_text
