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
GLOBAL_LIST_INIT(russian_species, list("Человек", "Абдуктор" ,"Дионея", "Драск", "Голем",
									   "Серый", "Кидан", "КПБ", "Обезьяна", "Ниан", "Нуклеация", "Плазмамен",
									   "Тень", "Тенеморф", "Скелет", "Скрелл", "Слаймомен", "Таяран",
									   "Унати", "Вокс", "Вульпканин", "Врин", "Неопределенная"))


/proc/sanitize_english_key_to_russian(char)
	var/new_char = GLOB.enkeys[lowertext(char)]
	return (new_char != null) ? new_char : char

/proc/sanitize_russian_key_to_english(char)
	var/new_char = GLOB.rukeys[uppertext(char)]
	return (new_char != null) ? new_char : char

/proc/sanitize_english_string_to_russian(text)
	. = ""
	for(var/i in 1 to length_char(text))
		. += sanitize_english_key_to_russian(copytext_char(text, i, i+1))

/proc/gender2rus(gender)
	. = "Неопределенный"
	switch(gender)
		if("male")
			. = "Мужской"
		if("female")
			. = "Женский"

/proc/species2rus(species)
	. = "Неопределенная"
	switch(species)
		if("Human")			. = "Человек"
		if("Abductor")		. = "Абдуктор"
		if("Diona")			. = "Дионея"
		if("Drask")			. = "Драск"
		if("Голем")			. = "Голем"
		if("Gray")			. = "Серый"
		if("Kidan")			. = "Кидан"
		if("Machine")		. = "КПБ"
		if("Monkey")		. = "Обезьяна"
		if("Nian")			. = "Ниан"
		if("Nucleation")	. = "Нуклеация"
		if("Plasmaman")		. = "Плазмамен"
		if("Shadow")		. = "Тень"
		if("Shadowling")    . = "Тенеморф"
		if("Skeleton")		. = "Скелет"
		if("Skrell")		. = "Скрелл"
		if("Slime People")	. = "Слаймомен"
		if("Tajaran")		. = "Таяран"
		if("Unathi")		. = "Унати"
		if("Vox")			. = "Вокс"
		if("Vulpkanin")		. = "Вульпканин"
		if("Wryn")			. = "Врин"



GLOBAL_LIST_INIT(specsymbols, list(
	"!" = "1", "\"" = "2", "@" = "2", "№" = "3", "#" = "3",
	";" = "4", "$" = "4", "%" = "5", "^" = "6", ":" = "6",
	"&" = "7", "?" = "7", "*" = "8", "(" = "9", ")" = "0", "_" = "-",
))

/proc/sanitize_specsymbols_key_to_numbers(char) // for keybindings
	var/new_char = GLOB.specsymbols[uppertext(char)]
	return (new_char != null) ? new_char : char
