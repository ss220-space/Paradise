GLOBAL_LIST_INIT(enkeys, list(
	"q" = "й", "w" = "ц", "e" = "у", "r" = "к", "t" = "е", "y" = "н",
	"u" = "г", "i" = "ш", "o" = "щ", "p" = "з",
	"a" = "ф", "s" = "ы", "d" = "в", "f" = "а", "g" = "п", "h" = "р",
	"j" = "о", "k" = "л", "l" = "д", ";" = "ж", "'" = "э", "z" = "я",
	"x" = "ч", "c" = "с", "v" = "м", "b" = "и", "n" = "т", "m" = "ь",
	"," = "б", "." = "ю",
))

GLOBAL_LIST_INIT(rukeys, list(
	"Й" = "Q", "Ц" = "W", "У" = "E", "К" = "R", "Е" = "T", "Н" = "Y",
	"Г" = "U", "Ш" = "I", "Щ" = "O", "З" = "P",
	"Ф" = "A", "Ы" = "S", "В" = "D", "А" = "F", "П" = "G", "Р" = "H",
	"О" = "J", "Л" = "K", "Д" = "L", "Ж" = ";", "Э" = "'", "Я" = "Z",
	"Ч" = "X", "С" = "C", "М" = "V", "И" = "B", "Т" = "N", "Ь" = "M",
	"Б" = ",", "Ю" = ".",
))

/proc/sanitize_english_key_to_russian(char)
	if(LAZYIN(GLOB.enkeys, lowertext(char)))
		return GLOB.enkeys[lowertext(char)]
	return char

/proc/sanitize_russian_key_to_english(char)
	if(LAZYIN(GLOB.rukeys, uppertext(char)))
		return GLOB.rukeys[uppertext(char)]
	return char

/proc/sanitize_english_string_to_russian(text)
	. = ""
	for(var/i in 1 to length_char(text))
		. += sanitize_english_key_to_russian(copytext_char(text, i, i+1))

GLOBAL_LIST_INIT(specsymbols, list(
	"!" = "1", "\"" = "2", "@" = "2", "№" = "3", "#" = "3",
	";" = "4", "$" = "4", "%" = "5", "^" = "6", ":" = "6",
	"&" = "7", "?" = "7", "*" = "8", "(" = "9", ")" = "0", "_" = "-",
))

/proc/sanitize_specsymbols_key_to_numbers(char) // for keybindings
	var/new_char = GLOB.specsymbols[uppertext(char)]
	return (new_char != null) ? new_char : char

GLOBAL_LIST_INIT(body_zone, list(
	BODY_ZONE_HEAD = list(NOMINATIVE = "голова", GENITIVE = "головы", DATIVE = "голове", ACCUSATIVE = "голову", INSTRUMENTAL = "головой", PREPOSITIONAL = "голове"),
	BODY_ZONE_CHEST = list(NOMINATIVE = "грудь", GENITIVE = "груди", DATIVE = "груди", ACCUSATIVE = "грудь", INSTRUMENTAL = "грудью", PREPOSITIONAL = "груди"),
	BODY_ZONE_L_ARM = list(NOMINATIVE = "левая рука", GENITIVE = "левой руки", DATIVE = "левой руке", ACCUSATIVE = "левую руку", INSTRUMENTAL = "левой рукой", PREPOSITIONAL = "левой руке"),
	BODY_ZONE_R_ARM = list(NOMINATIVE = "правая рука", GENITIVE = "правой руки", DATIVE = "правой руке", ACCUSATIVE = "правую руку", INSTRUMENTAL = "правой рукой", PREPOSITIONAL = "правой руке"),
	BODY_ZONE_L_LEG = list(NOMINATIVE = "левая нога", GENITIVE = "левой ноги", DATIVE = "левой ноге", ACCUSATIVE = "левую ногу", INSTRUMENTAL = "левой ногой", PREPOSITIONAL = "левой ноге"),
	BODY_ZONE_R_LEG = list(NOMINATIVE = "правая нога", GENITIVE = "правой ноги", DATIVE = "правой ноге", ACCUSATIVE = "правую ногу", INSTRUMENTAL = "правой ногой", PREPOSITIONAL = "правой ноге"),
	BODY_ZONE_TAIL = list(NOMINATIVE = "хвост", GENITIVE = "хвоста", DATIVE = "хвосту", ACCUSATIVE = "хвост", INSTRUMENTAL = "хвостом", PREPOSITIONAL = "хвосте"),
	BODY_ZONE_WING = list(NOMINATIVE = "крылья", GENITIVE = "крыльев", DATIVE = "крыльям", ACCUSATIVE = "крылья", INSTRUMENTAL = "крыльями", PREPOSITIONAL = "крыльях"),
	BODY_ZONE_PRECISE_EYES = list(NOMINATIVE = "глаза", GENITIVE = "глаз", DATIVE = "глазам", ACCUSATIVE = "глаза", INSTRUMENTAL = "глазами", PREPOSITIONAL = "глазах"),
	BODY_ZONE_PRECISE_MOUTH = list(NOMINATIVE = "рот", GENITIVE = "рта", DATIVE = "рту", ACCUSATIVE = "рот", INSTRUMENTAL = "ртом", PREPOSITIONAL = "рте"),
	BODY_ZONE_PRECISE_GROIN = list(NOMINATIVE = "живот", GENITIVE = "живота", DATIVE = "животу", ACCUSATIVE = "живот", INSTRUMENTAL = "животом", PREPOSITIONAL = "животе"),
	BODY_ZONE_PRECISE_L_HAND = list(NOMINATIVE = "левая кисть", GENITIVE = "левой кисти", DATIVE = "левой кисти", ACCUSATIVE = "левую кисть", INSTRUMENTAL = "левой кистью", PREPOSITIONAL = "левой кисти"),
	BODY_ZONE_PRECISE_R_HAND = list(NOMINATIVE = "правая кисть", GENITIVE = "правой кисти", DATIVE = "правой кисти", ACCUSATIVE = "правую кисть", INSTRUMENTAL = "правой кистью", PREPOSITIONAL = "правой кисти"),
	BODY_ZONE_PRECISE_L_FOOT = list(NOMINATIVE = "левая ступня", GENITIVE = "левой ступни", DATIVE = "левой ступне", ACCUSATIVE = "левую ступню", INSTRUMENTAL = "левой ступнёй", PREPOSITIONAL = "левой ступне"),
	BODY_ZONE_PRECISE_R_FOOT = list(NOMINATIVE = "правая ступня", GENITIVE = "правой ступни", DATIVE = "правой ступне", ACCUSATIVE = "правую ступню", INSTRUMENTAL = "правой ступнёй", PREPOSITIONAL = "правой ступне")
))
