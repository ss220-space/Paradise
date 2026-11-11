/proc/overmap_comms_scramble(text)
	. = ""
	var/static/list/alphabet = list(
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
		"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
	)
	for(var/i in 1 to length_char(text))
		var/char = copytext_char(text, i, i + 1)
		if(char == " " || char == "\n" || char == "\t")
			. += char
			continue
		. += pick(alphabet)

/proc/overmap_comms_mask_key(key)
	var/len = length_char(key)
	if(len <= 1)
		return key
	if(len == 2)
		return "[copytext_char(key, 1, 2)]*"
	var/stars = ""
	for(var/i in 1 to len - 2)
		stars += "*"
	return "[copytext_char(key, 1, 2)][stars][copytext_char(key, len, len + 1)]"
