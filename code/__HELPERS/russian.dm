/// Global list mapping English keyboard keys to Russian characters
GLOBAL_LIST_INIT(english_to_russian_keys, list(
	"q" = "й", "w" = "ц", "e" = "у", "r" = "к", "t" = "е", "y" = "н",
	"u" = "г", "i" = "ш", "o" = "щ", "p" = "з",
	"a" = "ф", "s" = "ы", "d" = "в", "f" = "а", "g" = "п", "h" = "р",
	"j" = "о", "k" = "л", "l" = "д", ";" = "ж", "'" = "э", "z" = "я",
	"x" = "ч", "c" = "с", "v" = "м", "b" = "и", "n" = "т", "m" = "ь",
	"," = "б", "." = "ю",
))

/// Global list mapping Russian keyboard keys to English characters
GLOBAL_LIST_INIT(russian_to_english_keys, list(
	"Й" = "Q", "Ц" = "W", "У" = "E", "К" = "R", "Е" = "T", "Н" = "Y",
	"Г" = "U", "Ш" = "I", "Щ" = "O", "З" = "P",
	"Ф" = "A", "Ы" = "S", "В" = "D", "А" = "F", "П" = "G", "Р" = "H",
	"О" = "J", "Л" = "K", "Д" = "L", "Ж" = ";", "Э" = "'", "Я" = "Z",
	"Ч" = "X", "С" = "C", "М" = "V", "И" = "B", "Т" = "N", "Ь" = "M",
	"Б" = ",", "Ю" = ".",
))

/**
 * Converts a single English keyboard character to its Russian equivalent
 *
 * Arguments:
 * * input_character - The English character to convert
 */
/proc/sanitize_english_key_to_russian(input_character)
	if(LAZYIN(GLOB.english_to_russian_keys, lowertext(input_character)))
		return GLOB.english_to_russian_keys[lowertext(input_character)]
	return input_character

/**
 * Converts a single Russian keyboard character to its English equivalent
 *
 * Arguments:
 * * input_character - The Russian character to convert
 */
/proc/sanitize_russian_key_to_english(input_character)
	if(LAZYIN(GLOB.russian_to_english_keys, uppertext(input_character)))
		return GLOB.russian_to_english_keys[uppertext(input_character)]
	return input_character

/**
 * Converts an entire English string to Russian keyboard layout
 *
 * Arguments:
 * * input_text - The English text to convert to Russian layout
 */
/proc/sanitize_english_string_to_russian(input_text)
	var/converted_text = ""
	for(var/character_position in 1 to length_char(input_text))
		converted_text += sanitize_english_key_to_russian(copytext_char(input_text, character_position, character_position + 1))
	return converted_text

/// Global list mapping special symbols to number equivalents
GLOBAL_LIST_INIT(special_symbols_to_numbers, list(
	"!" = "1", "\"" = "2", "@" = "2", "№" = "3", "#" = "3",
	";" = "4", "$" = "4", "%" = "5", "^" = "6", ":" = "6",
	"&" = "7", "?" = "7", "*" = "8", "(" = "9", ")" = "0", "_" = "-",
))

/**
 * Converts special symbols to their number equivalents for keybindings
 *
 * Arguments:
 * * input_character - The special character to convert
 */
/proc/sanitize_specsymbols_key_to_numbers(input_character)
	var/converted_character = GLOB.special_symbols_to_numbers[uppertext(input_character)]
	return (converted_character != null) ? converted_character : input_character
