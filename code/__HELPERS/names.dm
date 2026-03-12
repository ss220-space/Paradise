GLOBAL_VAR(church_name)
/// Returns the current church name, generating one if not set
/proc/church_name()
	if(GLOB.church_name)
		return GLOB.church_name

	var/name = ""

	name += pick("Holy", "United", "First", "Second", "Last")

	if(prob(20))
		name += " Space"

	name += " " + pick("Church", "Cathedral", "Body", "Worshippers", "Movement", "Witnesses")
	name += " of [religion_name()]"

	return name

GLOBAL_VAR(command_name)
/// Returns the current command name, falling back to the map's dock name if not set
/proc/command_name()
	return GLOB.command_name? GLOB.command_name : SSmapping.map_datum.dock_name

/**
 * Changes the command name to the specified value
 *
 * Arguments:
 * * new_name - The new command name
 */
/proc/change_command_name(new_name)
	GLOB.command_name = new_name
	return new_name

GLOBAL_VAR(religion_name)
/// Returns the current religion name, generating one if not set
/proc/religion_name()
	if(GLOB.religion_name)
		return GLOB.religion_name

	var/name = ""

	name += pick("bee", "science", "edu", "captain", "civilian", "monkey", "alien", "space", "unit", "sprocket", "gadget", "bomb", "revolution", "beyond", "station", "goon", "robot", "ivor", "hobnob")
	name += pick("ism", "ia", "ology", "istism", "ites", "ick", "ian", "ity")

	return capitalize(name)

/// Returns the system name from the map datum
/proc/system_name()
	return SSmapping.map_datum.starsys_name

GLOBAL_VAR(station_name)
/// Returns the current station name, falling back to the map's station name if not set
/proc/station_name()
	return GLOB.station_name ? GLOB.station_name : SSmapping.map_datum.station_name

/**
 * Changes the station name to the specified designation
 *
 * Arguments:
 * * new_designation - The new station name
 */
/proc/change_station_name(new_designation)
	var/old_name = GLOB.station_name
	GLOB.station_name = new_designation
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_STATION_NAME_CHANGED, new_designation, old_name)

GLOBAL_VAR(english_station_name)
/// Returns the English station name, falling back to appropriate defaults if not set
/proc/english_station_name()
	return GLOB.english_station_name ? GLOB.english_station_name : (SSmapping.map_datum.english_station_name ? SSmapping.map_datum.english_station_name : SSmapping.map_datum.station_name)

/**
 * Changes the English station name and updates the world name
 *
 * Arguments:
 * * new_designation - The new English station name
 */
/proc/change_english_station_name(new_designation)
	GLOB.english_station_name = new_designation
	update_world_name()

/// Updates the world name based on server configuration and station name.
/proc/update_world_name()
	// We use english_station_name() to display correctly in the Byond hub.
	var/current_station_name = english_station_name()
	if(config && CONFIG_GET(string/servername))
		world.name = "[CONFIG_GET(string/servername)] — [current_station_name]"
	else
		world.name = current_station_name

/// Generates a new random station name.
/proc/new_station_name()
	var/name_category = rand(1, 5)
	var/name_component = ""
	var/full_station_name = ""

	// Rare: Pre-Prefix
	if(prob(10))
		name_component = pick("Imperium", "Heretical", "Cuban", "Psychic", "Elegant", "Common", "Uncommon", "Rare", "Unique", "Houseruled", "Religious", "Atheist", "Traditional", "Houseruled", "Mad", "Super", "Ultra", "Secret", "Top Secret", "Deep", "Death", "Zybourne", "Central", "Main", "Government", "Uoi", "Fat", "Automated", "Experimental", "Augmented")
		full_station_name = name_component + " "
		name_component = ""

	// Prefix
	for(var/holiday_name in SSholiday.holidays)
		if(holiday_name == "Friday the 13th")
			name_category = 13
		var/datum/holiday/holiday = SSholiday.holidays[holiday_name]
		name_component = holiday.getStationPrefix()
		// Get normal name if no holiday prefix
	if(!name_component)
		name_component = pick("", "Stanford", "Dorf", "Alium", "Prefix", "Clowning", "Aegis", "Ishimura", "Scaredy", "Death-World", "Mime", "Honk", "Rogue", "MacRagge", "Ultrameens", "Safety", "Paranoia", "Explosive", "Neckbear", "Donk", "Muppet", "North", "West", "East", "South", "Slant-ways", "Widdershins", "Rimward", "Expensive", "Procreatory", "Imperial", "Unidentified", "Immoral", "Carp", "Ork", "Pete", "Control", "Nettle", "Aspie", "Class", "Crab", "Fist","Corrogated","Skeleton","Race", "Fatguy", "Gentleman", "Capitalist", "Communist", "Bear", "Beard", "Derp", "Space", "Spess", "Star", "Moon", "System", "Mining", "Neckbeard", "Research", "Supply", "Military", "Orbital", "Battle", "Science", "Asteroid", "Home", "Production", "Transport", "Delivery", "Extraplanetary", "Orbital", "Correctional", "Robot", "Hats", "Pizza")
	if(name_component)
		full_station_name += name_component + " "

	// Suffix
	name_component = pick("Station", "Fortress", "Frontier", "Suffix", "Death-trap", "Space-hulk", "Lab", "Hazard","Spess Junk", "Fishery", "No-Moon", "Tomb", "Crypt", "Hut", "Monkey", "Bomb", "Trade Post", "Fortress", "Village", "Town", "City", "Edition", "Hive", "Complex", "Base", "Facility", "Depot", "Outpost", "Installation", "Drydock", "Observatory", "Array", "Relay", "Monitor", "Platform", "Construct", "Hangar", "Prison", "Center", "Port", "Waystation", "Factory", "Waypoint", "Stopover", "Hub", "HQ", "Office", "Object", "Fortification", "Colony", "Planet-Cracker", "Roost", "Fat Camp")
	full_station_name += name_component + " "

	// ID Number
	switch(name_category)
		if(1)
			full_station_name += "[rand(1, 99)]"
		if(2)
			full_station_name += pick("Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")
		if(3)
			full_station_name += pick("II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX")
		if(4)
			full_station_name += pick("Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray", "Yankee", "Zulu")
		if(5)
			full_station_name += pick("One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen")
		if(13)
			full_station_name += pick("13","XIII","Thirteen")
	return full_station_name

//Traitors and traitor silicons will get these. Revs will not.
GLOBAL_VAR(syndicate_code_phrase) //Code phrase for traitors.
GLOBAL_VAR(syndicate_code_response) //Code response for traitors.

//Cached regex search - for checking if codewords are used.
GLOBAL_DATUM(syndicate_code_phrase_regex, /regex)
GLOBAL_DATUM(syndicate_code_response_regex, /regex)

	/*
	Should be expanded.
	How this works:
	Instead of "I'm looking for James Smith," the traitor would say "James Smith" as part of a conversation.
	Another traitor may then respond with: "They enjoy running through the void-filled vacuum of the derelict."
	The phrase should then have the words: James Smith.
	The response should then have the words: run, void, and derelict.
	This way assures that the code is suited to the conversation and is unpredicatable.
	Obviously, some people will be better at this than others but in theory, everyone should be able to do it and it only enhances roleplay.
	Can probably be done through "{ }" but I don't really see the practical benefit.
	One example of an earlier system is commented below.
	/N
	*/

/proc/generate_code_phrase(return_list = FALSE) // Proc is used for phrase and response in master_controller.dm

	if(!return_list)
		. = ""
	else
		. = list()
	var/words = pick(//How many words there will be. Minimum of two. 2, 4 and 5 have a lesser chance of being selected. 3 is the most likely.
		50; 2,
		200; 3,
		50; 4,
		25; 5
	)

	var/safety[] = list(1,2,3)//Tells the proc which options to remove later on.
//	var/nouns[] = list("love","hate","anger","peace","pride","sympathy","bravery","loyalty","honesty","integrity","compassion","charity","success","courage","deceit","skill","beauty","brilliance","pain","misery","beliefs","dreams","justice","truth","faith","liberty","knowledge","thought","information","culture","trust","dedication","progress","education","hospitality","leisure","trouble","friendships", "relaxation")
//	var/drinks[] = list("vodka and tonic","gin fizz","bahama mama","manhattan","black Russian","whiskey soda","long island tea","margarita","Irish coffee"," manly dwarf","Irish cream","doctor's delight","Beepksy Smash","tequila sunrise","brave bull","gargle blaster","bloody mary","whiskey cola","white Russian","vodka martini","martini","Cuba libre","kahlua","vodka","wine","moonshine")
//	var/locations[] = length(GLOB.teleportlocs) ? GLOB.teleportlocs : drinks//if null, defaults to drinks instead.

	var/names[] = list()
	for(var/datum/data/record/t in GLOB.data_core.general)//Picks from crew manifest.
		if(!t)
			stack_trace("Null record: [t]")
			continue
		if(!t.fields["name"])
			stack_trace("Nameless record: [t.fields]")
			continue
		names += escape_regex_smart(t.fields["name"])

	var/maxwords = words//Extra var to check for duplicates.

	for(words,words>0,words--)//Randomly picks from one of the choices below.

		if(words==1&&(1 in safety)&&(2 in safety))//If there is only one word remaining and choice 1 or 2 have not been selected.
			safety = list(pick(1,2))//Select choice 1 or 2.
		else if(words==1&&maxwords==2)//Else if there is only one word remaining (and there were two originally), and 1 or 2 were chosen,
			safety = list(3)//Default to list 3

		switch(pick(safety))//Chance based on the safety list.
			if(1)//1 and 2 can only be selected once each to prevent more than two specific names/places/etc.
				switch(rand(1, 2)) // Mainly to add more options later.
					if(1)
						if(length(names))
							. += pick(names)
					if(2)
						. += pick(GLOB.jobs)//Returns a job.
				safety -= 1
			if(2)
				switch(rand(1, 2))//Places or things.
					if(1)
						. += pick(GLOB.cocktails)
					if(2)
						. += pick(GLOB.locations)
				safety -= 2
			if(3)
				switch(rand(1, 3))//Nouns, adjectives, verbs. Can be selected more than once.
					if(1)
						. += pick(GLOB.nouns)
					if(2)
						. += pick(GLOB.adjectives)
					if(3)
						. += pick(GLOB.verbs)
		if(!return_list)
			if(words == 1)
				. += "."
			else
				. += ", "

/// Generates a random key by combining words and numbers
/proc/GenerateKey()
	var/new_key
	new_key += pick("the", "if", "of", "as", "in", "a", "you", "from", "to", "an", "too", "little", "snow", "dead", "drunk", "rosebud", "duck", "al", "le")
	new_key += pick("diamond", "beer", "mushroom", "civilian", "clown", "captain", "twinkie", "security", "nuke", "small", "big", "escape", "yellow", "gloves", "monkey", "engine", "nuclear", "ai")
	new_key += pick("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	return new_key
