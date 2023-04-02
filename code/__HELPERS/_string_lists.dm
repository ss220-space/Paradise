#define pick_list(FILE, KEY) (pick(strings(FILE, KEY)))
#define json_load(FILE) (json_decode(wrap_file2text(FILE)))
#define pick_list_weight(FILE, KEY) (pickweight(strings(FILE, KEY)))

GLOBAL_LIST_EMPTY(string_cache)
GLOBAL_LIST_EMPTY(string_filename_current_key)

/proc/strings(filename as text, key as text)
	load_strings_file(filename)
	if((filename in GLOB.string_cache) && (key in GLOB.string_cache[filename]))
		return GLOB.string_cache[filename][key]
	else
		CRASH("strings list not found: strings/[filename], index=[key]")

/proc/load_strings_file(filename)
	GLOB.string_filename_current_key = filename
	if(filename in GLOB.string_cache)
		return //no work to do

	if(!GLOB.string_cache)
		GLOB.string_cache = new

	if(fexists("strings/[filename]"))
		GLOB.string_cache[filename] = json_load("strings/[filename]")
	else
		CRASH("file not found: strings/[filename]")
