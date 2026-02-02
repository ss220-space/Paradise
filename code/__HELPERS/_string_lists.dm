/// Pick a random string from a JSON string file by key
#define pick_list(FILE, KEY) (pick(strings(FILE, KEY)))
/// Pick a random string from a JSON string file with weighted selection
#define pick_list_weighted(FILE, KEY) (pick_weight(strings(FILE, KEY)))
/// Pick a string with @pick(SOME_KEY) replacements for nested random selection
#define pick_list_replacements(FILE, KEY) (strings_replacement(FILE, KEY))
/// Load and parse a JSON file
#define json_load(FILE) (json_decode(wrap_file2text(FILE)))

/// Global cache for loaded string files
GLOBAL_LIST(string_cache)
/// Current filename key for nested string lookups during replacements
GLOBAL_VAR(string_filename_current_key)

/**
 * Get a random string with nested @pick() replacements
 *
 * Retrieves a random string from the string cache and processes any @pick(KEY) patterns
 * by replacing them with random strings from the specified KEY in the same file.
 *
 * Arguments:
 * * filepath - Path to the JSON string file
 * * key - Key in the JSON file to get strings from
 */
/proc/strings_replacement(filepath, key)
	filepath = sanitize_filepath(filepath)
	load_strings_file(filepath)

	if((filepath in GLOB.string_cache) && (key in GLOB.string_cache[filepath]))
		var/selected_string = pick(GLOB.string_cache[filepath][key])
		var/regex/pick_pattern_regex = regex("@pick\\((\\D+?)\\)", "g")
		selected_string = pick_pattern_regex.Replace(selected_string, GLOBAL_PROC_REF(strings_subkey_lookup))
		return selected_string
	else
		CRASH("strings list not found: [STRING_DIRECTORY]/[filepath], index=[key]")

/**
 * Get strings array from a JSON string file
 *
 * Loads the specified file if not already cached and returns the array of strings
 * for the given key. Throws a runtime error if file or key not found.
 *
 * Arguments:
 * * filepath - Path to the JSON string file
 * * key - Key in the JSON file to get strings from
 * * directory - Directory to look for string files in (default: STRING_DIRECTORY)
 */
/proc/strings(filepath, key, directory = STRING_DIRECTORY)
	if(IsAdminAdvancedProcCall())
		return

	filepath = sanitize_filepath(filepath)
	load_strings_file(filepath, directory)
	if((filepath in GLOB.string_cache) && (key in GLOB.string_cache[filepath]))
		return GLOB.string_cache[filepath][key]
	else
		CRASH("strings list not found: [directory]/[filepath], index=[key]")

/**
 * Callback for regex replacement in strings_replacement
 *
 * Used to replace @pick(KEY) patterns with random strings from the specified KEY
 * in the current string file being processed.
 *
 * Arguments:
 * * full_match - The full regex match including the @pick() pattern
 * * captured_key - The captured key name from the @pick() pattern
 */
/proc/strings_subkey_lookup(full_match, captured_key)
	return pick_list(GLOB.string_filename_current_key, captured_key)

/**
 * Load and cache a JSON string file
 *
 * Loads the specified JSON file into the global string cache if not already loaded.
 * Throws a runtime error if the file doesn't exist.
 *
 * Arguments:
 * * filepath - Path to the JSON string file to load
 * * directory - Directory to look for string files in (default: STRING_DIRECTORY)
 */
/proc/load_strings_file(filepath, directory = STRING_DIRECTORY)
	if(IsAdminAdvancedProcCall())
		return

	GLOB.string_filename_current_key = filepath
	if(filepath in GLOB.string_cache)
		return //no work to do

	if(!GLOB.string_cache)
		GLOB.string_cache = new

	if(fexists("[directory]/[filepath]"))
		GLOB.string_cache[filepath] = json_load("[directory]/[filepath]")
	else
		CRASH("file not found: [directory]/[filepath]")
