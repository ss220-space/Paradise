/*
	NTTC system
	This is basically the replacement for NTSL and allows tickbox features such as job titles and colours, without needing a script
	This also means that there is no user input here, which means the system isnt prone to exploits since its only selecting options, no user input
	Basically, just imagine pfSense for tcomms

	All this code was written by Tigercat2000. I take no credit -aa07
*/

#define JOB_STYLE_1 "Name (Job)"
#define JOB_STYLE_2 "Name - Job"
#define JOB_STYLE_3 "\[Job\] Name"
#define JOB_STYLE_4 "(Job) Name"

/datum/nttc_configuration
	var/regex/word_blacklist = new("(<iframe|<embed|<script|<svg|<canvas|<video|<audio|onload)", "i") // Blacklist of naughties
	// ALL OF THE JOB CRAP
	/// Associative list of all jobs and their department color classes
	var/all_jobs = list(
		// AI
		JOB_TITLE_AI = "airadio",
		"Android" = "airadio",
		JOB_TITLE_CYBORG = "airadio",
		"Personal AI" = "airadio",
		"Robot" = "airadio",
		// Civilian
		JOB_TITLE_CIVILIAN = "radio",
		// Command (Solo command, not department heads)
		JOB_TITLE_BLUESHIELD = "comradio",
		JOB_TITLE_CAPTAIN = "comradio",
		JOB_TITLE_HOP = "comradio",
		JOB_TITLE_REPRESENTATIVE = "comradio",
		// Engineeering
		JOB_TITLE_CHIEF = "engradio",
		JOB_TITLE_ATMOSTECH = "engradio",
		JOB_TITLE_MECHANIC = "engradio",
		JOB_TITLE_ENGINEER = "engradio",
		JOB_TITLE_ENGINEER_TRAINEE = "engradio",
		// Central Command
		"Emergency Response Team Engineer" = "dsquadradio", // I know this says deathsquad but the class for responseteam is neon green. No.
		"Emergency Response Team Leader" = "dsquadradio",
		"Emergency Response Team Medic" = "dsquadradio",
		"Emergency Response Team Member" = "dsquadradio",
		"Emergency Response Team Officer" = "dsquadradio",
		JOB_TITLE_CCOFFICER = "dsquadradio",
		JOB_TITLE_CCFIELD = "dsquadradio",
		JOB_TITLE_CCSPECOPS = "dsquadradio",
		JOB_TITLE_SYNDICATE = "syndiecom",
		JOB_TITLE_CCSUPREME = "dsquadradio",
		// Medical
		JOB_TITLE_CHEMIST = "medradio",
		JOB_TITLE_CMO = "medradio",
		JOB_TITLE_CORONER = "medradio",
		JOB_TITLE_DOCTOR = "medradio",
		JOB_TITLE_INTERN = "medradio",
		JOB_TITLE_PARAMEDIC = "medradio",
		JOB_TITLE_PSYCHIATRIST = "medradio",
		JOB_TITLE_VIROLOGIST = "medradio",
		// Science
		JOB_TITLE_GENETICIST = "sciradio",
		JOB_TITLE_RD = "sciradio",
		JOB_TITLE_ROBOTICIST = "sciradio",
		JOB_TITLE_SCIENTIST = "sciradio",
		JOB_TITLE_SCIENTIST_STUDENT = "sciradio",
		// Security
		JOB_TITLE_BRIGDOC = "secradio",
		JOB_TITLE_DETECTIVE = "secradio",
		JOB_TITLE_HOS = "secradio",
		JOB_TITLE_LAWYER = "secradio",
		JOB_TITLE_JUDGE = "secradio",
		JOB_TITLE_OFFICER = "secradio",
		JOB_TITLE_PILOT = "secradio",
		JOB_TITLE_WARDEN = "secradio",
		// Supply
		JOB_TITLE_QUARTERMASTER = "supradio",
		JOB_TITLE_CARGOTECH = "supradio",
		JOB_TITLE_MINER = "supradio",
		// Service
		JOB_TITLE_BARBER = "srvradio",
		JOB_TITLE_BARTENDER = "srvradio",
		JOB_TITLE_BOTANIST = "srvradio",
		JOB_TITLE_CHAPLAIN = "srvradio",
		JOB_TITLE_CHEF = "srvradio",
		JOB_TITLE_CLOWN = "srvradio",
		JOB_TITLE_JANITOR = "srvradio",
		JOB_TITLE_LIBRARIAN = "srvradio",
		JOB_TITLE_MIME = "srvradio",
	)
	/// List of Command jobs
	var/list/heads = list(JOB_TITLE_CAPTAIN, JOB_TITLE_HOP, JOB_TITLE_QUARTERMASTER, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_BLUESHIELD, JOB_TITLE_CHIEF, JOB_TITLE_CMO, JOB_TITLE_RD, JOB_TITLE_HOS, JOB_TITLE_JUDGE, JOB_TITLE_AI, "Syndicate Research Director", "Syndicate Comms Officer")
	/// List of ERT jobs
	var/list/ert_jobs = list("Emergency Response Team Officer", "Emergency Response Team Engineer", "Emergency Response Team Medic", "Emergency Response Team Leader", "Emergency Response Team Member")
	/// List of CentComm jobs
	var/list/cc_jobs = list(JOB_TITLE_CCOFFICER, JOB_TITLE_CCFIELD, JOB_TITLE_CCSPECOPS, JOB_TITLE_SYNDICATE, "Nanotrasen Navy Captain", JOB_TITLE_CCSOLGOV, "Soviet Officer", "Soviet Marine Captain", "Soviet Admiral", JOB_TITLE_CCSUPREME)
	/// List of SolGov Marine jobs
	var/list/tsf_jobs = list("Solar Federation Specops Lieutenant", "Solar Federation Specops Marine", "Solar Federation Marine")
	//  List of USSP jobs
	var/list/soviet_jobs = list("Soviet Tourist", "Soviet Conscript", "Soviet Soldier", "Soviet Officer", "Soviet Marine", "Soviet Marine Captain", "Soviet General", "Soviet Engineer", "Soviet Scientist", "Soviet Medic")
	// Defined so code compiles and incase someone has a non-standard job
	var/job_class = "radio"
	// NOW FOR ACTUAL TOGGLES
	/* Simple Toggles */
	var/toggle_jobs = FALSE
	var/toggle_job_color = FALSE
	var/toggle_name_color = FALSE
	var/toggle_command_bold = FALSE

	/* Strings */
	var/setting_language = LANGUAGE_NONE
	var/job_indicator_type = null

	// This tells the datum what is safe to serialize and what's not. It also applies to deserialization.
	var/list/to_serialize = list(
		"toggle_jobs",
		"toggle_job_color",
		"toggle_name_color",
		"job_indicator_type",
		"toggle_command_bold",
		"setting_language"
	)

	// This is used for sanitization.
	var/list/serialize_sanitize = list(
		"toggle_jobs" = "bool",
		"toggle_job_color" = "bool",
		"toggle_name_color" = "bool",
		"job_indicator_type" = "string",
		"toggle_command_bold" = "bool",
		"setting_language" = "string"
	)

	// These are the job card styles
	var/list/job_card_styles = list(
		JOB_STYLE_1, JOB_STYLE_2, JOB_STYLE_3, JOB_STYLE_4
	)

	// List of people who will get blocked out of comms
	var/list/filtering = list()

	// Used to determine what languages are allowable for conversion. Generated during runtime.
	var/list/valid_languages = list("--DISABLE--")

/datum/nttc_configuration/proc/reset()
	toggle_jobs = initial(toggle_jobs)
	toggle_job_color = initial(toggle_job_color)
	toggle_name_color = initial(toggle_name_color)
	toggle_command_bold = initial(toggle_command_bold)
	/* Strings */
	setting_language = initial(setting_language)
	job_indicator_type = initial(job_indicator_type)

/datum/nttc_configuration/proc/update_languages()
	for(var/language_name in GLOB.all_languages)
		var/datum/language/language = GLOB.all_languages[language_name]
		if(language.flags & (HIVEMIND|NONGLOBAL))
			continue
		valid_languages[language] = TRUE

// I'd use serialize() but it's used by another system. This converts the configuration into a JSON string.
/datum/nttc_configuration/proc/nttc_serialize()
	. = list()
	for(var/variable in to_serialize)
		.[variable] = vars[variable]
	. = json_encode(.)

// This loads a configuration from a JSON string.
// Fucking broken as shit, someone help me fix this.
/datum/nttc_configuration/proc/nttc_deserialize(text, var/ckey)
	if(word_blacklist.Find(text)) //uh oh, they tried to be naughty
		message_admins(span_danger("EXPLOIT WARNING: ") + "[ckey] attempted to upload an NTTC configuration containing JS abusable tags!")
		log_admin("EXPLOIT WARNING: [ckey] attempted to upload an NTTC configuration containing JS abusable tags")
		return FALSE
	var/list/var_list = json_decode(text)
	for(var/variable in var_list)
		if(variable in to_serialize) // Don't just accept any random vars jesus christ!
			var/sanitize_method = serialize_sanitize[variable]
			var/variable_value = var_list[variable]
			variable_value = nttc_sanitize(variable_value, sanitize_method)
			if(variable_value != null)
				vars[variable] = variable_value
	return TRUE

// Sanitizing user input. Don't blindly trust the JSON.
/datum/nttc_configuration/proc/nttc_sanitize(variable, sanitize_method)
	if(!sanitize_method)
		return null

	switch(sanitize_method)
		if("bool")
			return variable ? TRUE : FALSE
		// if("table", "array")
		if("array")
			if(!islist(variable))
				return list()
			// Insert html filtering for the regexes here if you're boring
			var/newlist = json_decode(html_decode(json_encode(variable)))
			if(!islist(newlist))
				return null
			return newlist
		if("string")
			return "[variable]"

	return variable

// Primary signal modification. This is where all of the variables behavior are actually implemented.
/datum/nttc_configuration/proc/modify_message(datum/tcomms_message/tcm)
	// Check if they should be blacklisted right off the bat. We can save CPU if the message wont even be processed
	if(tcm.sender_name in filtering)
		tcm.pass = FALSE
	// All job and coloring shit
	if(toggle_job_color || toggle_name_color)
		var/rank = tcm.sender_rank
		job_class = all_jobs[rank]

	if(toggle_name_color)
		var/new_name = "<span class=\"[job_class]\">" + tcm.sender_name + "</span>"
		tcm.sender_name = new_name
		tcm.vname = new_name // this is required because the broadcaster uses this directly if the speaker doesn't have a voice changer on

	if(toggle_jobs)
		var/new_name = ""
		var/job = tcm.sender_job
		if(job in ert_jobs)
			job = "ERT"
		if(toggle_job_color)
			switch(job_indicator_type)
				// These must have trailing spaces. No exceptions.
				if(JOB_STYLE_1)
					new_name = "[tcm.sender_name] <span class=\"[job_class]\">([job])</span> "
				if(JOB_STYLE_2)
					new_name = "[tcm.sender_name] - <span class=\"[job_class]\">[job]</span> "
				if(JOB_STYLE_3)
					new_name = "<span class=\"[job_class]\"><small>\[[job]\]</small></span> [tcm.sender_name] "
				if(JOB_STYLE_4)
					new_name = "<span class=[job_class]>([job])</span> [tcm.sender_name] "
		else
			switch(job_indicator_type)
				if(JOB_STYLE_1)
					new_name = "[tcm.sender_name] ([job]) "
				if(JOB_STYLE_2)
					new_name = "[tcm.sender_name] - [job] "
				if(JOB_STYLE_3)
					new_name = "<small>\[[job]\]</small> [tcm.sender_name] "
				if(JOB_STYLE_4)
					new_name = "([job]) [tcm.sender_name] "

		// Only change the name if they have a job tag set, otherwise everyone becomes unknown, and thats bad
		if(new_name != "")
			tcm.sender_name = new_name
			tcm.vname = new_name // this is required because the broadcaster uses this directly if the speaker doesn't have a voice changer on
	// This is hacky stuff for multilingual messages...
	var/list/message_pieces = tcm.message_pieces

	// Makes heads of staff bold
	if(toggle_command_bold)
		var/rank = tcm.sender_rank
		if((rank in ert_jobs) || (rank in heads) || (rank in cc_jobs))
			for(var/I in 1 to length(message_pieces))
				var/datum/multilingual_say_piece/S = message_pieces[I]
				if(!S.message)
					continue
				if(I == 1 && S.speaking != GLOB.all_languages[LANGUAGE_NOISE]) // Capitalise the first section only, unless it's an emote.
					S.message = "[capitalize(S.message)]"
				S.message = "<b>[S.message]</b>" // Make everything bolded

	// Language Conversion
	if(setting_language && valid_languages[setting_language])
		if(setting_language == "--DISABLE--")
			setting_language = LANGUAGE_NONE
		else
			for(var/datum/multilingual_say_piece/S in message_pieces)
				if(S.speaking != GLOB.all_languages[LANGUAGE_NOISE]) // check if they are emoting, these do not need to be translated
					S.speaking = setting_language

	return tcm

#undef JOB_STYLE_1
#undef JOB_STYLE_2
#undef JOB_STYLE_3
#undef JOB_STYLE_4
