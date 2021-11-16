GLOBAL_LIST_INIT(enkeys, list(
	"q" = "й", "w" = "ц", "e" = "у", "r" = "к", "t" = "е", "y" = "н",
	"u" = "г", "i" = "ш", "o" = "щ", "p" = "з",
	"a" = "ф", "s" = "ы", "d" = "в", "f" = "а", "g" = "п", "h" = "р",
	"j" = "о", "k" = "л", "l" = "д", ";" = "ж", "'" = "э", "z" = "я",
	"x" = "ч", "c" = "с", "v" = "м", "b" = "и", "n" = "т", "m" = "ь",
	"," = "б", "." = "ю",
))


/proc/sanitize_english_key_to_russian(char)
	var/new_char = GLOB.enkeys[lowertext(char)]
	return (new_char != null) ? new_char : char

/proc/sanitize_english_string_to_russian(text)
	. = ""
	for(var/i in 1 to length_char(text))
		. += sanitize_english_key_to_russian(copytext_char(text, i, i+1))
