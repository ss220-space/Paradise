#define SCRAMBLE_CACHE_LEN 20
/*
	Datum based languages. Easily editable and modular.

	Busy letters for language:
	a b d f g j k o q v x y
	aa as bo db fa fm fn fs vu

	Busy symbols for language:
	0 1 2 3 4 5 6 7 8 9
	% ? ^

	Also don't forget about code/__DEFINES/language.dm

	CAUTION! The key must not repeat the key of the radio channel
	and must not contain prohibited characters
*/

/datum/language
	/// Fluff name of language if any.
	var/name = "an unknown language"
	/// Short description for 'Check Languages'.
	var/desc = "A language."
	/// 'says', 'hisses', 'farts'.
	var/list/speech_verbs = list("говор%(ит,ят)%")
	/// Used when sentence ends in a '?'.
	var/list/ask_verbs = list("спрашива%(ет,ют)%")
	/// Used when sentence ends in a '!'.
	var/list/exclaim_verbs = list("восклица%(ет,ют)%", "выкрикива%(ет,ют)%")
	/// Optional. When not specified speech_verbs + quietly/softly is used instead.
	var/list/whisper_verbs
	/// CSS style to use for strings in this language.
	var/colour = "body"
	/// Additional spans this language adds to a runechat message (should be defined in skin.dmf -> window "mapwindow" -> elem "map").
	var/runechat_span
	/// Character used to speak in language eg. '"un"' for Unathi.
	var/key = "key"
	/// Various language flags.
	var/flags = NONE
	/// If set, non-native speakers will have trouble speaking.
	var/native
	/// Used when scrambling text for a non-speaker.
	var/list/syllables
	/// Likelihood of getting a space in the random scramble string.
	var/list/space_chance = 55
	/// Applies to HIVEMIND languages - should a follow link be included for dead mobs?
	var/follow = FALSE
	/// Do we want English names by default, no matter what?
	var/english_names = FALSE
	/// List that saves sentences spoken in this language, so as not to generate different scrambles of syllables for the same sentences.
	var/list/scramble_cache = list()
	/// Do we want to override the word-join character for scrambled text? If null, defaults to " " or ". "
	var/join_override

/datum/language/proc/get_random_name(gender, name_count=2, syllable_count=4)
	if(!syllables || !syllables.len || english_names)
		if(gender==FEMALE)
			return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names_female))
		else
			return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

	var/full_name = ""
	var/new_name = ""

	for(var/i = 0;i<name_count;i++)
		new_name = ""
		for(var/x = rand(FLOOR(syllable_count/2, 1),syllable_count);x>0;x--)
			new_name += pick(syllables)
		full_name += " [capitalize(lowertext(new_name))]"
	return "[trim(full_name)]"

/datum/language/proc/scramble(input)

	if(!syllables || !syllables.len)
		return stars(input)

	// If the input is cached already, move it to the end of the cache and return it
	if(input in scramble_cache)
		var/n = scramble_cache[input]
		scramble_cache -= input
		scramble_cache[input] = n
		return n

	var/input_size = length(input)
	var/scrambled_text = ""
	var/capitalize = TRUE

	while(length(scrambled_text) < input_size)
		var/next = pick(syllables)
		if(capitalize)
			next = capitalize(next)
			capitalize = FALSE
		scrambled_text += next
		var/chance = rand(100)
		if(join_override)
			scrambled_text += join_override
		else if(chance <= 5)
			scrambled_text += ". "
			capitalize = TRUE
		else if(chance > 5 && chance <= space_chance)
			scrambled_text += " "

	scrambled_text = trim(scrambled_text)
	var/ending = copytext(scrambled_text, length(scrambled_text))
	if(ending == "." || ending == "-")
		scrambled_text = copytext(scrambled_text,1,length(scrambled_text)-1)
	var/input_ending = copytext(input, input_size)
	if(input_ending in list("!","?","."))
		scrambled_text += input_ending

	// Add it to cache, cutting old entries if the list is too long
	scramble_cache[input] = scrambled_text
	if(scramble_cache.len > SCRAMBLE_CACHE_LEN)
		scramble_cache.Cut(1, scramble_cache.len-SCRAMBLE_CACHE_LEN-1)


	return scrambled_text

/datum/language/proc/format_message(message, mob/speaker)
	return "<span class='message'><span class='[colour]'>[message]</span></span>"

/datum/language/proc/get_talkinto_msg_range(message)
	// if you yell, you'll be heard from two tiles over instead of one
	return (copytext(message, length(message)) == "!") ? 2 : 1

/datum/language/proc/broadcast(mob/living/speaker, message, speaker_mask)
	if(!check_can_speak(speaker))
		return FALSE

	add_say_logs(speaker, message, language = "([name]-HIVE)")

	if(!speaker_mask)
		speaker_mask = speaker.name
	var/msg = "<i><span class='game say'>[name], <span class='name'>[speaker_mask]</span> [genderize_decode(speaker, get_spoken_verb(message))], [format_message(message, speaker)]</span></i>"

	for(var/mob/player in GLOB.player_list)
		if(istype(player,/mob/dead) && follow)
			var/msg_dead = "<i><span class='game say'>[name], <span class='name'>[speaker_mask]</span> ([ghost_follow_link(speaker, ghost=player)]) [get_spoken_verb(message)], [format_message(message, speaker)]</span></i>"
			to_chat(player, msg_dead)
			continue

		else if(istype(player,/mob/dead) || (LAZYIN(player.languages, src) && check_special_condition(player, speaker)))
			to_chat(player, msg)

/datum/language/proc/check_special_condition(mob/other, mob/living/speaker)
	return TRUE

/datum/language/proc/check_can_speak(mob/living/speaker)
	return TRUE

/datum/language/proc/get_spoken_verb(msg_end)
	switch(msg_end)
		if("!")
			return pick(exclaim_verbs)
		if("?")
			return pick(ask_verbs)
	return pick(speech_verbs)

// Noise "language", for audible emotes.
/datum/language/noise
	name = "Шум"
	desc = "Просто шум."
	flags = RESTRICTED|NONGLOBAL|INNATE|NO_TALK_MSG|NO_STUTTER|NOBABEL


/datum/language/noise/get_talkinto_msg_range(message)
	// if you make a loud noise (screams etc), you'll be heard from 4 tiles over instead of two
	return (copytext(message, length(message)) == "!") ? 4 : 2

/datum/language/unathi
	name = "Синта'Унати"
	desc = "Общий язык Могеса, состоящий из шипящих звуков и дребезжания. Является родным языком Унатхов."
	speech_verbs = list("шип%(ит,ят)%", "гортанно урч%(ит,ят)%")
	ask_verbs = list("вопросительно шип%(ит,ят)%", "урч%(ит,ят)%")
	exclaim_verbs = list("рыч%(ит,ят)%", "рев%(ёт,ут)%")
	colour = "soghun"
	runechat_span = "soghun"
	key = "o"
	flags = RESTRICTED
	syllables = list("за","аз","зе","ез","зи","из","зо","оз","зу","уз","зс","сз","ха","ах","хе","ех","хи","их", \
	"хо","ох","ху","ух","хс","сх","ла","ал","ле","ел","ли","ил","ло","ол","лу","ул","лс","сл", \
	"ка","ак","ке","ек","ки","ик","ко","ок","ку","ук","кс","ск","са","ас","се","ес","си","ис", \
	"со","ос","су","ус","сс","сс","ра","ар","ре","ер","ри","ир","ро","ор","ру","ур","рс","ср", \
	"а","а","е","е","и","и","о","о","у","у","с","с")
/datum/language/unathi/get_random_name()

	var/new_name = ..()
	while(findtextEx(new_name,"ссс",1,null))
		new_name = replacetext(new_name, "ссс", "сс")
	return capitalize(new_name)

/datum/language/tajaran
	name = "Сик'таир"
	desc = "Традиционный язык Адомая, состоящий из выразительных мяукающих звуков и щебета. Родной язык для Таяран."
	speech_verbs = list("мурч%(ит,ят)%", "мурлыч%(ет,ут)%")
	ask_verbs = list("вопросительно мурч%(ит,ят)%", "вопросительно мурлыч%(ет,ут)%")
	exclaim_verbs = list("во%(ет,ют)%")
	colour = "tajaran"
	runechat_span = "tajaran"
	key = "j"
	flags = RESTRICTED
	syllables = list("рр","рр","тайр","кир","радж","кии","мир","кра","ахк","нал","вах","хаз","джри","ран","дарр", \
	"ми","джри","динх","манк","рхе","зар","ррхаз","кал","чур","иич","тхаа","дра","джурл","мах","сану","дра","иир", \
	"ка","ааси","фар","ва","бак","ара","кара","зир","сам","мак","храр","нджа","рир","хан","джун","дар","рик","ках", \
	"хал","кет","джурл","мах","тул","креш","азу","рагх")

/datum/language/tajaran/get_random_name(gender) //code by @valtor0
	var/static/list/tajaran_female_endings_list = list("и","а","о","е","й","ь") // Customise this with ru_name_syllables changes.
	var/list/ru_name_syllables = list("кан","тай","кир","раи","кии","мир","кра","тэк","нал","вар","хар","марр","ран","дарр", \
	"мирк","ири","дин","манг","рик","зар","раз","кель","шера","тар","кей","ар","но","маи","зир","кер","нир","ра",\
	"ми","рир","сей","эка","гир","ари","нэй","нре","ак","таир","эрай","жин","мра","зур","рин","сар","кин","рид","эра","ри","эна")
	var/apostrophe = "'"
	var/new_name = ""
	var/full_name = ""

	for(var/i = 0; i<2; i++)
		for(var/x = rand(1,2); x>0; x--)
			new_name += pick_n_take(ru_name_syllables)
		new_name += apostrophe
		apostrophe = ""
	full_name = "[capitalize(lowertext(new_name))]"
	if(gender == FEMALE)
		var/ending = copytext(full_name, -2)
		if(!(ending in tajaran_female_endings_list))
			full_name += "а"
	//20% for "Sendai" clan; 18,75% (75%) for other regular clan; 5% for names without clan.
	if(prob(75))
		full_name += " [pick(list("Хадии","Кайтам","Жан-Хазан","Нъярир’Ахан"))]"
	else if(prob(80))
		full_name += " [pick(list("Энай-Сэндай","Наварр-Сэндай","Року-Сэндай","Шенуар-Сэндай"))]"
	return full_name

/datum/language/vulpkanin
	name = "Канилунц"
	desc = "Гортанный язык, на котором говорят обитатели системы Ваззенд. Он состоит из рычания, лая и тявканья, также активно использует движения ушей и хвоста. Вульпканины говорят на нём с лёгкостью."
	speech_verbs = list("тявка%(ет,ют)%", "гавка%(ет,ют)%")
	ask_verbs = list("вопросительно тявка%(ет,ют)%", "вопросительно гавка%(ет,ют)%")
	exclaim_verbs = list("рыч%(ит,ят)%", "ла%(ет, ют)%")
	colour = "vulpkanin"
	runechat_span = "vulpkanin"
	key = "7"
	flags = RESTRICTED
	syllables = list("рур","я","цен","равр","бар","кук","тек","кат","ук","ву","вух","тах","тч","щз","аух", \
	"ист","айн","ентч","цвихс","тут","мир","во","бис","эс","фор","ниц","гро","ллл","енем","цандт","цч","нох", \
	"хель","ишт","фар","ва","барам","иренг","тех","лах","сам","мак","лих","ген","ор","аг","экк","гек","штаг","онн", \
	"бин","кет","ярл","вульф","айнех","крестц","ацунайн","гхзтх")

/datum/language/skrell
	name = "Скреллианский"
	desc = "Мелодичный и сложный язык, на котором говорят Скреллы. Некоторые из его звуков находятся за пределами слышимости человека."
	speech_verbs = list("мыч%(ит,ят)%", "напева%(ет,ют)%", "гуд%(ит,ят)%")
	ask_verbs = list("вопросительно мыч%(ит,ят)%", "вопросительно гуд%(ит,ят)%")
	exclaim_verbs = list("трещ%(ит,ат)%")
	colour = "skrell"
	runechat_span = "skrell"
	key = "k"
	flags = RESTRICTED
	syllables = list("кр","крр","зук","кил","куум","зукм","воль","зрим","заоо","ку-уу","кикс","коо","зикс","*","!")


#define SKRELL_ADDITIONAL_SYLLABLES 2 // Maximum of additional syllables for first and second names

/datum/language/skrell/get_random_name() // Name generator authors: @saichi23 && @cadavrik
	// Now I love making list in list in list in list in list
	// Two sublists were made by authors so that the names would turn out most consonant for reading (in a way that's possible for skrells)
	var/list/ru_name_syllables = list(
		list(	// list 1
			list("заоо", "зао", "зикс", "зо", "йуо", "кью", "кьюм", "кси", "ксу", "квум", "кву",	// sublist1
				"кви", "квей", "квиш", "куу", "кюан", "киэн", "ку", "кил", "лиа", "люик", "луи",
				"рио", "сейу", "тсой", "уль", "улур", "урр", "ур", "цу", "эль", "эо", "эу"),

			list(
			"аг", "вум", "вул", "вол", "гли", "зи", "заоо", "зао", "зикс", "зуо", "зук", "зуво",	// sublist2
			"икс", "ил", "ис", "йук", "кву", "квум", "куум", "куо", "куа", "куак", "кул", "квол",
			"кью", "кьюа", "кэ", "кин", "кии", "кс", "ки", "киу", "кос", "лоа", "лак", "лум", "лик",
			"лии", "ллак", "мзикс", "мвол", "ори", "ору", "орр", "ррум", "ру", "руум", "руа", "рл",
			"сэк", "су", "сиа", "тейе", "тейку", "тсу", "туа", "туи", "ту", "тал", "уат", "уок", "урр",
			"уоо", "уо", "уик", "уии", "уэк", "эйкс", "эль", "эрр", "эй", "эйс", "о", "у", "а", "з", "э", "м" ,"к", "с", "р"
			)
		),

		list(	// list 2
			list("заоо", "зао", "зо", "йуо", "лиа", "луи", "рио", "сейу", "эо"),	// sublist1

			list(
			"вум", "вул", "вол", "гли", "зи", "заоо", "зао", "зикс", "зуо", "зук", "зуво",	// sublist2
			"йук", "кву", "квум", "куум", "куо", "куа", "куак", "кул", "квол", "кью", "кьюа",
			"кэ", "кин", "кии", "кс", "ки", "киу", "кос", "лоа", "лак", "лум", "лик", "лии", "ллак",
			"мзикс", "мвол", "ррум", "ру", "руум", "руа", "рл", "сэк", "су", "сиа", "тейе", "тейку",
			"тсу", "туа", "туи", "ту", "тал", "з", "м", "к", "с", "р"
			)
		)
	)

	var/full_name = ""

	for(var/i in 1 to 2)	// First and second names, making from 2-3 syllables each.
		var/apostrophe = "'"
		var/new_name = ""
		var/using_list = rand(1, LAZYLEN(ru_name_syllables))	// We use only one list for the first name and one list for the second name, without mixing syllables from different lists.

		new_name += pick(ru_name_syllables[using_list][1])	// The first syllable is only from the first sublist.

		for(var/add_syllables in 1 to rand(1, SKRELL_ADDITIONAL_SYLLABLES))	// Additional 1-2 syllables, taken from sublist2.
			if(apostrophe && prob(50))
				new_name += apostrophe
				apostrophe = null // Adding "'" with chance, but only once for first and second names

			new_name += pick(ru_name_syllables[using_list][2])

		full_name += " [capitalize(new_name)]"

	return "[trim(full_name)]"

#undef SKRELL_ADDITIONAL_SYLLABLES


/datum/language/vox
	name = "Вокс-пиджин"
	desc = "Общий язык различных кораблей Воксов, составляющих Ковчег. Для всех остальных он звучит как помесь чириканья, крика и визга."
	speech_verbs = list("чирика%(ет,ют)%", "визж%(ит,ат)%", "крич%(ит,ат)%")
	ask_verbs = list("вопросительно чирика%(ет,ют)%", "вопросительно визж%(ит,ат)%", "вопросительно крич%(ит,ат)%")
	exclaim_verbs = list("громко чирика%(ет,ют)%", "громко визж%(ит,ат)%", "громко крич%(ит,ат)%")
	colour = "vox"
	runechat_span = "vox"
	key = "v"
	flags = RESTRICTED | WHITELISTED
	syllables = list("ти","ти","ти","хи","хи","ки","ки","ки","ки","я","та","ха","ка","я","йи","чи","ча","ках", \
	"СКРИИИ", "АААХ", "ЭЭЭХ", "РАААК", "КРАА", "ААА", "ИИИ", "КИИ", "ИИИ", "КРИИ", "КАА")

/datum/language/vox/get_random_name()
	var/sounds = rand(2, 8)
	var/i = 0
	var/newname = ""
	var/static/list/vox_name_syllables = list("ти","хи","ки","йа","та","ха","ка","йа","чи","ча","ках")
	while(i <= sounds)
		i++
		newname += pick(vox_name_syllables)
	return capitalize(newname)

/datum/language/diona
	name = "Песнь корней"
	desc = "Скрипучий, подголосочный язык, на котором инстинктивно говорят Дионы. Из-за уникального строения обычной Дионы, фраза на таком языке может представлять собой комбинацию от одного до двенадцати отдельных голосов и звуков."
	speech_verbs = list("трещ%(ит,ат)%", "скрип%(ит,ят)%")
	ask_verbs = list("вопросительно трещ%(ит,ат)%", "вопросительно скрип%(ит,ят)%")
	exclaim_verbs = list("громко шурш%(ит,ат)%", "громко скрип%(ит,ят)%")
	colour = "diona"
	runechat_span = "diona"
	key = "q"
	flags = RESTRICTED
	syllables = list("хс","ят","кр","ст","сш")

/datum/language/diona/get_random_name()
	var/new_name = "[pick(list("To Sleep Beneath", "Wind Over", "Embrace Of", "Dreams Of", "Witnessing", "To Walk Beneath", "Approaching The", "Glimmer Of", "The Ripple Of", "Colors Of", "The Still Of", "Silence Of", "Gentle Breeze Of", "Glistening Waters Under", "Child Of", "Blessed Plant-Ling Of", "Grass-Walker Of", "Element Of", "Spawn Of"))]"
	new_name += " [pick(list("The Void", "The Sky", "Encroaching Night", "Planetsong", "Starsong", "The Wandering Star", "The Empty Day", "Daybreak", "Nightfall", "The Rain", "The Stars", "The Waves", "Dusk", "Night", "The Wind", "The Summer Wind", "The Blazing Sun", "The Scorching Sun", "Eternal Fields", "The Soothing Plains", "The Undying Fiona", "Mother Nature's Bousum"))]"
	return new_name

/datum/language/trinary
	name = "Троичный"
	desc = "Модификация двоичного кода, позволяющая использовать нечёткую логику. 0 — нет, 1 — возможно, 2 — да. Считается, что именно эта система дала способность позитронным системам мыслить творчески."
	speech_verbs = list("сообща%(ет,ют)%", "констатиру%(ет,ют)%")
	ask_verbs = list("запрашива%(ет,ют)%", "дела%(ет,ют)% запрос")
	exclaim_verbs = list("восклица%(ет,ют)%")
	colour = "trinary"
	runechat_span = "trinary"
	key = "5"
	flags = RESTRICTED | WHITELISTED
	syllables = list("0+2+0+1+1","0+1+2+2+2","1+0+1+0+0","1+0+2+1+0","2+1+0+1+2","0+2+0+1+1","2+1+2+0+0","1+0+0+2","2+0+0+1","0+0+0+2","0+0+1+2","0+0+1+2","0+0+0","1+2+0","1+2+1","2+0+1","2+2+0","1+0","1+1","0")

/datum/language/trinary/get_random_name()
	var/new_name
	if(prob(70))
		new_name = "[pick(list("СИМ","АИС","ТЕК","АРМА","АОС"))]-[rand(100, 999)]"
	else
		new_name = pick(GLOB.ai_names)
	return new_name

/datum/language/kidan
	name = "Хитин"
	desc = "Звук, который издают Киданы, потирая усики друг о друга, на самом деле является сложной формой общения."
	speech_verbs = list("потира%(ет,ют)% свои усики")
	ask_verbs = list("потира%(ет,ют)% свои усики")
	exclaim_verbs = list("потира%(ет,ют)% свои усики")
	colour = "kidan"
	runechat_span = "kidan"
	key = "4"
	flags = RESTRICTED | WHITELISTED
	syllables = list("клик","клак")

/datum/language/kidan/get_random_name()
	var/new_name = "[pick(list("Вракс","Крек","Вриз","Зрик","Зарак","Клик","Зерк","Дракс","Звен","Дрэкс"))]"
	new_name += ", "
	new_name += "[pick(list("Дворянин","Рабочий","Разведчик","Строитель","Фермер","Собиратель","Солдат","Охранник","Старатель"))]"
	new_name += " Клана "
	new_name += "[pick(list("Тристан","Зарлан","Клак","Краз","Крамн","Орлан","Зракс"))]"
	return new_name


/datum/language/slime
	name = "Пузырчатый"
	desc = "Язык Плазмолюдов. Это смесь булькающих и хлюпающих звуков. Другим гуманоидам очень сложно говорить на нём без механической помощи."
	speech_verbs = list("булька%(ет,ют)%", "хлюпа%(ет,ют)%")
	ask_verbs = list("булька%(ет,ют)%", "хлюпа%(ет,ют)%")
	exclaim_verbs = list("булька%(ет,ют)%", "хлюпа%(ет,ют)%")
	colour = "slime"
	runechat_span = "slime"
	key = "f"
	flags = RESTRICTED | WHITELISTED
	syllables = list("блоб","плоп","поп","боп","буп","хлюп")

/datum/language/grey
	name = "Псисвязь"
	desc = "Псионическое общение Серых, менее мощная версия телепатии их дальних родственников. Позволяет общаться с другими Серыми в ограниченном радиусе."
	speech_verbs = list("сообща%(ет,ют)%")
	ask_verbs = list("интересу%(ет,ют)%ся")
	exclaim_verbs = list("со всей важностью сообща%(ет,ют)%")
	colour = "abductor"
	runechat_span = "abductor"
	key = "^"
	flags = RESTRICTED | HIVEMIND
	follow = TRUE

/datum/language/grey/broadcast(mob/living/speaker, message, speaker_mask)
	..(speaker,message,speaker.real_name)

/datum/language/grey/check_can_speak(mob/living/speaker)
	if(ishuman(speaker))
		var/mob/living/carbon/human/S = speaker
		var/obj/item/organ/external/rhand = S.get_organ(BODY_ZONE_PRECISE_R_HAND)
		var/obj/item/organ/external/lhand = S.get_organ(BODY_ZONE_PRECISE_L_HAND)
		if((!rhand || !rhand.is_usable()) && (!lhand || !lhand.is_usable()))
			to_chat(speaker, span_warning("Вы не можете использовать руки для телепатии!"))
			return FALSE
	if(speaker.incapacitated())
		to_chat(speaker, span_warning("Вы не можете поднести руки к голове для телепатии!"))
		return FALSE

	speaker.visible_message( span_notice("[speaker] прикладыва[pluralize_ru(speaker.gender, "ет", "ют")] пальцы к виску.")) //If placed in grey/broadcast, it will happen regardless of the success of the action.

	return TRUE

/datum/language/grey/check_special_condition(mob/living/carbon/human/other, mob/living/carbon/human/speaker)
	if(are_zs_connected(other, speaker))
		return TRUE
	return FALSE

/datum/language/drask
	name = "Орлуум"
	desc = "Монотонный, гудящий, вибрирующий язык Драсков. Звучит примерно как песня китов."
	speech_verbs = list("гуд%(ит,ят)%", "напева%(ет,ют)%", "мыч%(ит,ат)%", "грохоч%(ет,ут)%")
	ask_verbs = list("вопросительно гуд%(ит,ят)%", "вопросительно мыч%(ит,ат)%", "вопросительно грохоч%(ет,ут)%")
	exclaim_verbs = list("громко гуд%(ит,ят)%", "громко грохоч%(ет,ут)%", "рев%(ёт,ут)%")
	colour = "drask"
	runechat_span = "drask"
	key = "%"
	flags = RESTRICTED | WHITELISTED
	syllables = list("хуурб", "врруумм", "оорм", "уррум", "уум", "ии", "ффм", "ххх", "мн", "онг", "оо", "о", "уу", "ууу", "мм", "ммм", "груумм")

/datum/language/drask/get_random_name()
	var/new_name = "[pick(list("Хоорм","Вииск","Саар","Мнуу","Оумн","Фмонг","Гнии","Вррм","Оорм","Дромнн","Ссуумн","Овв","Хоорб","Ваар","Гаар","Гуум","Руум","Румум"))]"
	new_name += "-[pick(list("Хоорм","Вииск","Саар","Мнуу","Оумн","Фмонг","Гнии","Вррм","Оорм","Дромнн","Ссуумн","Овв","Хоорб","Ваар","Гаар","Гуум","Руум","Румум"))]"
	new_name += "-[pick(list("Хоорм","Вииск","Саар","Мнуу","Оумн","Фмонг","Гнии","Вррм","Оорм","Дромнн","Ссуумн","Овв","Хоорб","Ваар","Гаар","Гуум","Руум","Румум"))]"
	return new_name

/datum/language/moth
	name = "Ткачий язык"
	desc = "Язык мотыльковых гуманоидов Луам, в котором используется прерывистая жестикуляция усиками, крыльями или челюстями, а также жужжание или чириканье."
	speech_verbs = list("жужж%(ит,ат)%")
	ask_verbs = list("хлопа%(ет,ют)% крыльями")
	exclaim_verbs = list("щебеч%(ет,ут)%")
	colour = "moth"
	runechat_span = "moth"
	key = "#"
	flags = RESTRICTED | WHITELISTED
	join_override = "-"
	syllables = list("ор","и","гор","сек","мо","фф","ок","гй","ё","го","ла","ле","лит",
	"игг","ван","дор","нё","мёт","идд","хво","я","по","хан","со","он","дет","атт","но",
	"гё","бра","ин","тыц","ом","нер","тво","мо","даг","шя","вии","вуо","ейл","тун","кяйт",
	"тех","вя","хей","хуо","суо","яя","тен","я","хеу","сту","ур","кён","ве","хён")

/datum/language/moth/get_random_name()
	var/new_name = "[pick(list("Abbot","Archer","Arkwright","Baker","Bard","Biologist","Broker","Caller","Chamberlain","Clerk","Cooper","Culinarian","Dean","Director","Duke","Energizer","Excavator","Explorer","Fletcher","Gatekeeper","Guardian","Guide","Healer","Horner","Keeper","Knight","Laidler","Mapper","Marshall","Mechanic","Miller","Navigator","Pilot","Prior","Seeker","Seer","Smith","Stargazer","Teacher","Tech Whisperer","Tender","Thatcher","Voidcrafter","Voidhunter","Voidwalker","Ward","Watcher","Weaver","Webster","Wright"))]"
	new_name += "[pick(list(" of"," for"," in Service of",", Servant of"," for the Good of",", Student of"," to"))]"
	new_name += " [pick(list("Alkaid","Andromeda","Antlia","Apus","Auriga","Caelum","Camelopardalis","Canes Venatici","Carinae","Cassiopeia","Centauri","Circinus","Cygnus","Dorado","Draco","Eridanus","Errakis","Fornax","Gliese","Grus","Horologium","Hydri","Lacerta","Leo Minor","Lupus","Lynx","Maffei","Megrez","Messier","Microscopium","Monocerotis","Muscae","Ophiuchi","Orion","Pegasi","Persei","Perseus","Polaris","Pyxis","Sculptor","Syrma","Telescopium","Tianyi","Triangulum","Trifid","Tucana","Tycho","Vir","Volans","Zavyava"))]"
	return new_name

/datum/language/common
	name = "Общегалактический"
	desc = "Универсальный язык, разработанный людьми для упрощения общения с другими гуманоидными расами."
	speech_verbs = list("говор%(ит,ят)%")
	exclaim_verbs = list("восклица%(ет,ют)%", "выкрикива%(ет,ют)%")
	whisper_verbs = list("шепч%(ет,ут)%")
	key = "9"
	flags = RESTRICTED
	syllables = list("бла","бле","ме","не","на","ва","блю","вак","ке","бэ","вэ","гэ")
	english_names = TRUE

/datum/language/human
	name = "Общесолнечный"
	desc = "Искуственный язык, созданный на основе английского, китайского и эсперанто. Является основным для Людей."
	speech_verbs = list("говор%(ит,ят)%")
	exclaim_verbs = list("восклица%(ет,ют)%", "выкрикива%(ет,ют)%")
	whisper_verbs = list("шепч%(ет,ут)%")
	colour = "solcom"
	runechat_span = "solcom"
	key = "1"
	flags = RESTRICTED
	syllables = list("тао","ши","тцу","йи","ком","бэ","ис","и","оп","ви","ед","лек","мо","кле","те","дис","е", "ин", "ла", "то", "эн", "тон", "ис", "ас", "ос")
	english_names = TRUE

// Galactic common languages (systemwide accepted standards).
/datum/language/trader
	name = "Торговый"
	desc = "Этот элегантный и структурированный язык используется различными торговыми картелями в крупных системах для торговли и заключения сделок."
	speech_verbs = list("утвержда%(ет,ют)%")
	colour = "say_quote"
	key = "2"
	space_chance = 100
	syllables = list("кредита","активов","сделка","контракт","премиум","лицензию","импорт","экспорт",
	"квоту","тарифу","логисты","транзит","валюта","акций","бонус","претензия","арбитраж",
	"оферта","депозит","лизинг","фрахт","аудит","тендер","лимит","резервов","прибыли","уступка",
	"гаранта","форвард","фьючерсы","опциона","клиринг","депорта","аккредитив","инвойс","консалт",
	"маркет","брокеры","дивидендов","кэшфло","хеджинг","риски","преференция","комиссия","ликвидацию",
	"нотис","овердрафт","репа","спот","своп","трейд","факторы","холдинг","эмиссии","юнита",
	"метнулся","вопросик","обкашлять","цифры","подскок","пошуршать","база","закупаем","фиксируем")

/datum/language/gutter
	name = "Гангстерский"
	desc = "Грубая, исковерканная версия Общегалактического языка, используемая криминальными элементами по всей Галактике."
	speech_verbs = list("рявка%(ет,ют)%")
	ask_verbs = list("нагло спрашива%(ет,ют)%")
	exclaim_verbs = list("агрессивно говор%(ит,ят)%")
	colour = "gutter"
	key = "3"
	syllables = list ("грит","шанк","дроч","балк","крип","фанк","зум","варг","треш","клоп",
	"хакс","мут","глох","вирт","брут","крен","шмук","флек","дрюк","клоак","твист","жрэк",
	"блякс","фрот","сквиз","грух","чунк","дрип","шлюх","крут", "ёп", "ёб", "сыш", "ну",
	"хы", "ха", "кха", "хуй", "бля", "сук", "мусор", "пацны", "брат", "браза", "эт",
	"самое", "мдэ", "лох", "фарт", "общак", "стопэ", "лавэ", "бабло", "фраер", "шмон")

/datum/language/clown
	name = "Клоунский"
	desc = "Язык планеты клоунов. Родной язык клоунов по всей Галактике."
	speech_verbs = list("хонка%(ет,ют)%")
	ask_verbs = list("вопросительно хонка%(ет,ют)%")
	exclaim_verbs = list("труб%(ит,ят)%","громко хонка%(ет,ют)%")
	colour = "clown"
	runechat_span = "clown"
	key = "0"
	syllables = list ("хонк","скуик","боньк","тут","нафф","сюз","вии","вуб","нофф", "шмык", "хоп", "ха", "ху", "хи")

/datum/language/com_srus
	name = "Нео-русский"
	desc = "Официальный язык СССП. Является смесью Общесолнечного и старых человеческих языков славянской группы. Лингвистический символ противостояния Транс-солнечной Федерации."
	speech_verbs = list("чётко выговарива%(ет,ют)%", "твёрдо произнос%(ит,ят)%")
	whisper_verbs = list("бормоч%(ет,ут)%")
	exclaim_verbs = list("громко произнос%(ит,ят)%", "твёрдо восклица%(ет,ют)%")
	colour = "com_srus"
	runechat_span = "com_srus"
	key = "?"
	space_chance = 65
	english_names = TRUE
	syllables = list("веда","бар","бота","век","тво","слов","слав","сен","дуп","вах","лаз","глоз","ет",
	"нет","да","ски","глав","глаз","нец","думат","зат","моч","боз",
	"комы","врад","враде","тай","бли","ай","нов","ливн","толв","глаз","глиз",
	"оуй","раб","евт","дат","ботат","нев","новы","его","нов","шо","обш",
	"бяк","боба","овский","ская","биба","студен","вар","бул","вян",
	"елбан","вая","мяк","гино","воло","олам","мити","нино","менов","перов",
	"одаски","тров","ники","ивано","достов","сокол","оупа","первом","щел",
	"тизан","чка","таган","добры","нюни","бода","вета","иди","цык","блыт","на",
	"уди","лички","каса","огуз","толи","анатов","ихний","веч","вуч","той","ка","вод",
	"нус", "ов", "ну", "и", "или", "но", "без", "оч", "под", "над", "не")

/datum/language/wryn
	name = "Разум улья Вринов"
	desc = "У Вринов есть способность общаться через псионическую связь улья."
	speech_verbs = list("щебеч%(ет,ут)%")
	ask_verbs = list("вопросительно щебеч%(ет,ут)%")
	exclaim_verbs = list("громко жужж%(ит,ат)%")
	colour = "alien"
	key = "y"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE

/datum/language/wryn/check_special_condition(mob/other)
	var/mob/living/carbon/M = other
	if(!istype(M))
		return TRUE
	if(locate(/obj/item/organ/internal/wryn/hivenode) in M.internal_organs)
		return TRUE

	return FALSE

/datum/language/xenocommon
	name = "Ксеноморфский"
	colour = "alien"
	desc = "Основной язык Ксеноморфов."
	speech_verbs = list("шип%(ит,ят)%")
	ask_verbs = list("вопросительно шип%(ит,ят)%")
	exclaim_verbs = list("рыч%(ит,ят)%")
	key = "6"
	flags = RESTRICTED
	syllables = list("шшш","шШш","ШШШ", "щщщ", "щЩщ", "ЩЩЩ")

/datum/language/xenos
	name = "Разум улья Ксеноморфов"
	desc = "Ксеноморфы обладают способностью общаться через псионический разум улья."
	speech_verbs = list("шип%(ит,ят)%")
	ask_verbs = list("вопросительно шип%(ит,ят)%")
	exclaim_verbs = list("рыч%(ит,ят)%")
	colour = "alien"
	key = "a"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE

/datum/language/terrorspider
	name = "Разум улья Пауков Ужаса"
	desc = "Пауки Ужаса обладают ограниченной способностью общаться через псионический разум улья, подобно Ксеноморфам."
	speech_verbs = list("щебеч%(ет,ут)%")
	ask_verbs = list("вопросительно щебеч%(ет,ут)%")
	exclaim_verbs = list("громко жужж%(ит,ат)%")
	colour = "terrorspider"
	key = "as"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE


/datum/language/ling
	name = "Коллективный разум Генокрадов"
	desc = "Хотя обычно Генокрады относятся друг к другу с осторожностью и подозрением, они могут общаться на расстоянии."
	speech_verbs = list("сообща%(ет,ют)%")
	colour = "changeling"
	key = "g"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE


/datum/language/ling/broadcast(mob/living/speaker, message, speaker_mask)
	var/datum/antagonist/changeling/cling = speaker?.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(cling)
		..(speaker, message, cling.changelingID)
	else
		..(speaker,message)

/datum/language/eventling
	name = "Инфильтрованный коллективный разум Генокрадов"
	desc = "Хотя обычно Генокрады относятся друг к другу с осторожностью и подозрением, они могут общаться на расстоянии."
	speech_verbs = list("сообща%(ет,ют)%")
	colour = "changeling"
	key = "gi"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE


/datum/language/eventling/broadcast(mob/living/speaker, message, speaker_mask)
	var/datum/antagonist/changeling/evented/cling = speaker?.mind?.has_antag_datum(/datum/antagonist/changeling/evented)
	if(cling)
		..(speaker, message, cling.changelingID)
	else
		..(speaker,message)

/datum/language/shadowling
	name = "Коллективный разум Тенеморфов"
	desc = "Тенеморфы и их рабы способны общаться через псионический коллективный разум."
	speech_verbs = list("сообща%(ет,ют)%")
	colour = "shadowling"
	key = "8"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE

/datum/language/shadowling/broadcast(mob/living/speaker, message, speaker_mask)
	if(speaker.mind && speaker.mind.special_role == SPECIAL_ROLE_SHADOWLING)
		..(speaker,"<font size=3><b>[message]</b></font>", "<span class='shadowling'><font size=3>([speaker.mind.special_role]) [speaker]</font></span>")
	else if(speaker.mind && speaker.mind.special_role)
		..(speaker, message, "([speaker.mind.special_role]) [speaker]")
	else
		..(speaker, message)

/datum/language/abductor
	name = "Псисвязь Абдукторов"
	desc = "Абдукторы не способны к речи, но обладают псионической связью для связи с себе подобными."
	speech_verbs = list("бормоч%(ет,ут)%")
	ask_verbs = list("бормоч%(ет,ут)%")
	exclaim_verbs = list("бормоч%(ет,ут)%")
	colour = "abductor"
	key = "aa"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE

/datum/language/abductor/broadcast(mob/living/speaker, message, speaker_mask)
	..(speaker,message,speaker.real_name)

/datum/language/abductor/check_special_condition(mob/living/carbon/human/other, mob/living/carbon/human/speaker)
	if(isabductor(other) && isabductor(speaker))
		var/datum/species/abductor/A = speaker.dna.species
		var/datum/species/abductor/A2 = other.dna.species
		if(A.team == A2.team)
			return TRUE
	return FALSE

/datum/language/abductor/golem
	name = "Псисвязь Големов"
	desc = "Големы могут общаться с себе подобными при помощи псионической связи."
	follow = TRUE

/datum/language/abductor/golem/check_special_condition(mob/living/carbon/human/other, mob/living/carbon/human/speaker)
	return TRUE

/datum/language/borer
	name = "Кортикальная связь"
	desc = "Бореры обладают псионической связью между своими крошечными разумами."
	colour = "alien"
	key = "bo"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE

/datum/language/borer/broadcast(mob/living/speaker, message, speaker_mask)
	var/mob/living/simple_animal/borer/B

	if(iscarbon(speaker))
		var/mob/living/carbon/M = speaker
		B = M.has_brain_worms()
	else if(istype(speaker,/mob/living/simple_animal/borer))
		B = speaker

	if(B)
		speaker_mask = B.truename
	..(speaker,message,speaker_mask)

/datum/language/binary
	name = "Бинарный канал"
	desc = "Большинство космических станций поддерживают свободные коммуникационные протоколы и маршрутизационные узлы для использования Синтетиками."
	colour = "say_quote"
	speech_verbs = list("сообща%(ет,ют)%", "констатиру%(ет,ют)%")
	ask_verbs = list("запрашива%(ет,ют)%", "дела%(ет,ют)% запрос")
	exclaim_verbs = list("восклица%(ет,ют)%")
	key = "b"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE
	var/drone_only

/datum/language/binary/broadcast(mob/living/speaker, message, speaker_mask)
	if(!speaker.binarycheck())
		return

	if(!message)
		return

	add_say_logs(speaker, message, language = "ROBOT")

	var/message_start = "<i><span class='game say'>[name], <span class='name'>[speaker.name]</span>"
	var/message_body = "<span class='message'>[speaker.say_quote(message)]:</i><span class='robot'>\"[message]\"</span></span></span>"

	for(var/mob/M in GLOB.dead_mob_list)
		if(!isnewplayer(M) && !isbrain(M))
			var/message_start_dead = "<i><span class='game say'>[name], <span class='name'>[speaker.name] ([ghost_follow_link(speaker, ghost=M)])</span>"
			M.show_message("[message_start_dead] [message_body]", 2)

	for(var/mob/living/S in GLOB.alive_mob_list)
		if(drone_only && !(isdrone(S)||iscogscarab(S)))
			continue
		else if(isAI(S))
			message_start = "<i><span class='game say'>[name], <a href='byond://?src=[S.UID()];track=\ref[speaker]'><span class='name'>[speaker.name]</span></a>"
		else if(!S.binarycheck())
			continue

		S.show_message("[message_start] [message_body]", 2)

	var/list/listening = hearers(1, src)
	listening -= src

	for(var/mob/living/M in listening)
		if(issilicon(M) || M.binarycheck())
			continue
		M.show_message("<i><span class='game say'><span class='name'>синтезированный голос</span> <span class='message'>сообщает: \"бип бип бип\"</span></span></i>",2)

/datum/language/binary/drone
	name = "Канал Дронов"
	desc = "Закодированный поток для координирования работы Дронов."
	speech_verbs = list("переда%(ёт,ют)%")
	ask_verbs = list("переда%(ёт,ют)%")
	exclaim_verbs = list("переда%(ёт,ют)%")
	colour = "say_quote"
	key = "d"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	drone_only = TRUE
	follow = TRUE

/datum/language/drone
	name = "Дрон"
	desc = "Зашифрованный поток данных, преобразованный в речевые паттерны."
	speech_verbs = list("сообща%(ет,ют)%", "констатиру%(ет,ют)%")
	ask_verbs = list("запрашива%(ет,ют)%", "дела%(ет,ют)% запрос")
	exclaim_verbs = list("восклица%(ет,ют)%")
	key = "db"
	flags = RESTRICTED
	follow = TRUE
	syllables = list ("бип", "буп")

/datum/language/swarmer
	name = "Связь Роевиков"
	desc = "Сильно закодированный инопланетный бинарный паттерн."
	speech_verbs = list("сообща%(ет,ют)%", "констатиру%(ет,ют)%")
	ask_verbs = list("запрашива%(ет,ют)%", "дела%(ет,ют)% запрос")
	exclaim_verbs = list("восклица%(ет,ют)%")
	colour = "say_quote"
	key = "as"//Zwarmer...Or Zerg!
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE

/datum/language/human/monkey
	name = "Шимпанзиный"
	desc = "Уаа-Ааа-Аа!"
	speech_verbs = list("визж%(ит,ат)%")
	ask_verbs = list("вопросительно визж%(ит,ат)%")
	exclaim_verbs = list("громко визж%(ит,ат)%")
	key = "fm"

/datum/language/skrell/monkey
	name = "Неарский"
	desc = "Пи-пи-пи!"
	key = "fn"

/datum/language/unathi/monkey
	name = "Стокский"
	desc = "Шшш-шш-шшш."
	key = "fs"

/datum/language/tajaran/monkey
	name = "Фарвный"
	desc = "Мяу-мяу-мяу."
	key = "fa"

/datum/language/vulpkanin/monkey
	name = "Вульпинский"
	desc = "Гаф-гав-гаф."
	key = "vu"


/datum/language/angel
	name = "Ангельское пение"
	colour = "colossus yell"
	flags = RESTRICTED|NO_STUTTER|NOBABEL|NONGLOBAL|INNATE


/datum/language/angel/proc/get_spans(mob/speaker)
	. = colour //reset spans, just in case someone gets deculted or the cords change owner
	if(iscultist(speaker))
		. += " narsiesmall"


/datum/language/angel/format_message(message, mob/speaker)
	return "<span class='message'><span class='[get_spans(speaker)]'>[message]</span></span>"


// Can we speak this language, as opposed to just understanding it?
/mob/proc/can_speak_language(datum/language/speaking)
	return universal_speak || (speaking == GLOB.all_languages[LANGUAGE_NOISE]) || LAZYIN(languages, speaking)


//TBD
/mob/proc/check_lang_data()
	. = ""

	for(var/datum/language/L in languages)
		if(!(L.flags & NONGLOBAL))
			. += "<b>[L.name] (:[L.key])</b><br/>[L.desc]<br><br>"


/mob/living/check_lang_data()
	. = ""

	if(default_language)
		. += "Текущий язык по умолчанию: [default_language] - <a href='byond://?src=[UID()];default_lang=reset'>Сброс</a><br><br>"

	for(var/datum/language/L in languages)
		if(!(L.flags & NONGLOBAL))
			if(L == default_language)
				. += "<b>[L.name] (:[L.key])</b> - default - <a href='byond://?src=[UID()];default_lang=reset'>Сброс</a><br>[L.desc]<br><br>"
			else
				. += "<b>[L.name] (:[L.key])</b> - <a href=\"byond://?src=[UID()];default_lang=[L.name]\">По умолчанию</a><br>[L.desc]<br><br>"


/mob/verb/check_languages()
	set name = "Меню языков"
	set category = "IC"
	set src = usr

	var/datum/browser/popup = new(src, "checklanguage", "Меню языков", 420, 470)
	popup.set_content(check_lang_data())
	popup.open()


/mob/living/Topic(href, href_list)
	. = ..()
	if(.)
		return TRUE
	if(href_list["default_lang"])
		if(href_list["default_lang"] == "reset")
			set_default_language(null)
		else
			var/datum/language/L = GLOB.all_languages[href_list["default_lang"]]
			if(L)
				set_default_language(L)
		check_languages()
		return TRUE


// Language handling.
/mob/proc/add_language(language_name)
	var/result_flags = SEND_SIGNAL(src, COMSIG_LANG_PRE_ACT, language_name)
	if(SEND_SIGNAL(src, COMSIG_MOB_LANGUAGE_ADD, language_name, result_flags) & DISEASE_MOB_LANGUAGE_PROCESSED)
		return TRUE

	var/datum/language/new_language = GLOB.all_languages[language_name]
	if(new_language in languages)
		return FALSE

	if(!istype(new_language))
		new_language = GLOB.all_languages[convert_lang_key_to_name(language_name)]
		if(!istype(new_language))
			return FALSE

	. = !LAZYIN(languages, new_language)
	if(.)
		LAZYADD(languages, new_language)


/mob/proc/remove_language(language_name)
	var/result_flags = SEND_SIGNAL(src, COMSIG_LANG_PRE_ACT, language_name)
	if(SEND_SIGNAL(src, COMSIG_MOB_LANGUAGE_REMOVE, language_name, result_flags) & DISEASE_MOB_LANGUAGE_PROCESSED)
		return TRUE

	var/datum/language/rem_language = GLOB.all_languages[language_name]
	if(!istype(rem_language))
		rem_language = GLOB.all_languages[convert_lang_key_to_name(language_name)]
		if(!istype(rem_language))
			return FALSE

	. = LAZYIN(languages, rem_language)
	if(.)
		LAZYREMOVE(languages, rem_language)


/mob/living/remove_language(language_name)
	var/datum/language/rem_language = GLOB.all_languages[language_name]
	if(!istype(rem_language))
		rem_language = GLOB.all_languages[convert_lang_key_to_name(language_name)]
		if(!istype(rem_language))
			return FALSE

	if(default_language == rem_language)
		default_language = null

	return ..()


/mob/proc/grant_all_babel_languages()
	for(var/la in GLOB.all_languages)
		var/datum/language/new_language = GLOB.all_languages[la]
		if(new_language.flags & NOBABEL)
			continue
		LAZYOR(languages, new_language)


/mob/proc/grant_all_languages()
	for(var/la in GLOB.all_languages)
		add_language(la)


/proc/convert_lang_key_to_name(language_key)
	var/static/list/language_keys_and_names = list()
	if(!language_keys_and_names.len)
		for(var/language_name in GLOB.all_languages)
			var/datum/language/language = GLOB.all_languages[language_name]
			language_keys_and_names[language.key] = language_name
	return language_keys_and_names[language_key]


/proc/get_language_prefix(language_name)
	var/datum/language/language = GLOB.all_languages[language_name]
	if(language)
		. = ":[language.key] "
	else
		. = "Non-existent key"
		CRASH("[language_name] language does not exist.")


#undef SCRAMBLE_CACHE_LEN
