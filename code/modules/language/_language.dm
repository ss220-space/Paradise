#define SCRAMBLE_CACHE_LEN 20
/**
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
	var/name = "неизвестный язык"
	/// Short description for 'Check Languages'.
	var/desc = "Язык."
	/// Character used to speak in language eg. '"un"' for Unathi.
	/// If key is null, then the language isn't real or learnable.
	var/key = "key"
	/// Various language flags.
	var/flags = NONE

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

	// These modify how syllables are combined.
	/// Likelihood of making a new sentence after each syllable.
	var/sentence_chance = 2
	/// Likelihood of making a new sentence after each word.
	var/between_word_sentence_chance = 0
	/// Likelihood of adding a space between syllables.
	var/space_chance = 20
	/// Likelyhood of adding a space between words.
	var/between_word_space_chance = 100
	/// Scramble word interprets the word as this much longer than it really is (low end)
	/// You can set this to an arbitarily large negative number to make all words only one syllable.
	var/additional_syllable_low = -1
	/// Scramble word interprets the word as this much longer than it really is (high end)
	/// You can set this to an arbitarily large negative number to make all words only one syllable.
	var/additional_syllable_high = 3

	/**
	 * Cache of recently scrambled text
	 * This allows commonly reused words to not require a full re-scramble every time.
	 * Is limited to the last SCRAMBLE_CACHE_LEN words spoken. After surpassing this limit,
	 * the oldest word will be removed from the cache and rescrambled if spoken again.
	 *
	 * Case insensitive, punctuation insensitive.
	 */
	VAR_PRIVATE/list/scramble_cache = list()
	/**
	 * Scramble cache, but for the 1000 most common words in the English language.
	 * These are never rescrambled, so they will consistently be the same thing.
	 *
	 * Case insensitive, punctuation insensitive.
	 */
	VAR_PRIVATE/list/most_common_cache = list()
	/**
	 * Cache of recently spoken sentences
	 * So if one person speaks over the radio, everyone hears the same thing.
	 *
	 * This is an assoc list [sentence] = [key, scrambled_text]
	 * Where key is a string that is used to determine context about the listener (like what languages they know)
	 *
	 * Case sensitive, punctuation sensitive.
	 */
	VAR_PRIVATE/list/last_sentence_cache = list()

	/// The language that an atom knows with the highest "default_priority" is selected by default.
	var/default_priority = 0
	/// If TRUE, when generating names, we will always use the default human namelist, even if we have syllables set.
	/// This is to be used for languages with very outlandish syllable lists (like pirates).
	var/always_use_default_namelist = FALSE
	/// Icon displayed in the chat window when speaking this language.
	/// if you are seeing someone speak popcorn language, then something is wrong.
	var/icon = 'icons/ui/chat/language.dmi'
	/// Icon state displayed in the chat window when speaking this language.
	var/icon_state = "unknown"

	/// By default, random names picks this many names
	var/default_name_count = 2
	/// By default, random names picks this many syllables (min)
	var/default_name_syllable_min = 2
	/// By default, random names picks this many syllables (max)
	var/default_name_syllable_max = 4
	/// What char to place in between randomly generated names
	var/random_name_spacer = " "

	/**
	 * Assoc Lazylist of other language types that would have a degree of mutual understanding with this language.
	 * For example, you could do `list(/datum/language/common = 50)` to say that this language has a 50% chance to understand common words
	 * And yeah if you give a 100% chance, they can basically just understand the language.
	 * Not sure why you would do that though.
	 */
	var/list/mutual_understanding

// Primarily for debugging, allows for easy iteration and testing of languages.
/datum/language/vv_edit_var(var_name, var_value)
	. = ..()
	var/list/delete_cache = list(
		NAMEOF(src, additional_syllable_high),
		NAMEOF(src, additional_syllable_low),
		NAMEOF(src, between_word_sentence_chance),
		NAMEOF(src, between_word_space_chance),
		NAMEOF(src, sentence_chance),
		NAMEOF(src, space_chance),
		NAMEOF(src, special_characters),
		NAMEOF(src, syllables),
	)
	if(var_name in delete_cache)
		scramble_cache.Cut()
		most_common_cache.Cut()
		last_sentence_cache.Cut()

/// Checks whether we should display the language icon to the passed hearer.
/datum/language/proc/display_icon(atom/movable/hearer)
	var/understands = hearer.has_language(src.type)
	if((flags & LANGUAGE_HIDE_ICON_IF_UNDERSTOOD) && understands)
		return FALSE
	if((flags & LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD) && !understands)
		return FALSE
	return TRUE

/// Returns the icon to display in the chat window when speaking this language.
/datum/language/proc/get_icon()
	var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
	return sheet.icon_tag("language-[icon_state]")

/// Simple helper for getting a default firstname lastname
/datum/language/proc/default_name(gender = NEUTER)
	if(gender != MALE && gender != FEMALE)
		gender = pick(MALE, FEMALE)
	if(gender == FEMALE)
		return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

/datum/language/proc/get_random_name(gender, name_count=2, syllable_count=4)
	if(!length(syllables) || always_use_default_namelist)
		if(gender==FEMALE)
			return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names_female))
		else
			return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names_male))

	var/full_name = ""
	var/new_name = ""

	for(var/i = 0;i<name_count;i++)
		new_name = ""
		for(var/x = rand(FLOOR(syllable_count/2, 1),syllable_count);x>0;x--)
			new_name += pick(syllables)
		full_name += " [capitalize(lowertext(new_name))]"
	return "[trim(full_name)]"

/datum/language/proc/scramble(input)

	if(!syllables || !length(syllables))
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
	if(length(scramble_cache) > SCRAMBLE_CACHE_LEN)
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
	var/msg = span_gamesay("[name], [span_name("[speaker_mask]")] [genderize_decode(speaker, get_spoken_verb(message))], [format_message(message, speaker)]")
	for(var/mob/player in GLOB.player_list)
		if(istype(player,/mob/dead) && follow)
			var/msg_dead = span_gamesay("[name], [span_name("[speaker_mask]")] ([ghost_follow_link(speaker, ghost=player)]) [genderize_decode(speaker, get_spoken_verb(message))], [format_message(message, speaker)]")
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

#undef SCRAMBLE_CACHE_LEN
