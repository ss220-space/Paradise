/// Security helpers to ensure you cant arbitrarily load stuff from disk
/proc/wrap_file(filepath)
	if(IsAdminAdvancedProcCall())
		// Admins shouldnt fuck with this
		to_chat(usr, span_boldannounceooc("File load blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to load files via advanced proc-call")
		return

	return file(filepath)

/proc/wrap_file2text(filepath)
	if(IsAdminAdvancedProcCall())
		// Admins shouldnt fuck with this
		to_chat(usr, span_boldannounceooc("File load blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to load files via advanced proc-call")
		return

	return file2text(filepath)

///checks if a file exists and contains text
///returns text as a string if these conditions are met
/proc/return_file_text(filename)
	if(fexists(filename) == 0)
		error("File not found ([filename])")
		return

	var/text = wrap_file2text(filename)
	if(!text)
		error("File empty ([filename])")
		return

	return text

///Sends resource files to client cache
/client/proc/getFiles()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Shelleo blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to call Shelleo via advanced proc-call")
		return

	for(var/file in args)
		src << browse_rsc(file)

/client/proc/browse_files(root="data/logs/", max_iterations=10, list/valid_extensions=list(".txt",".log",".htm"))
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Shelleo blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to call Shelleo via advanced proc-call")
		return

	// wow why was this ever a parameter
	root = "data/logs/"
	var/path = root

	for(var/i=0, i<max_iterations, i++)
		var/list/choices = flist(path)
		if(path != root)
			choices.Insert(1,"/")

		var/choice = tgui_input_list(src, "Choose a file to access:", "Download", choices, null)
		switch(choice)
			if(null)
				return
			if("/")
				path = root
				continue
		path += choice

		if(copytext(path,-1,0) != "/")		//didn't choose a directory, no need to iterate again
			break

	var/extension = copytext(path,-4,0)
	if(!fexists(path) || !(extension in valid_extensions))
		to_chat(src, span_red("Error: browse_files(): File not found/Invalid file([path])."))
		return

	return path

#define FTPDELAY 200 // 200 tick delay to discourage spam
#define ADMIN_FTPDELAY_MODIFIER 0.5 // Admins get to spam files faster since we ~trust~ them!

/**
 * This proc is a failsafe to prevent spamming of file requests.
 * It is just a timer that only permits a download every [FTPDELAY] ticks.
 * This can be changed by modifying FTPDELAY's value above.
 *
 * PLEASE USE RESPONSIBLY, Some log files can reach sizes of 4MB!
 */
/client/proc/file_spam_check()
	var/time_to_wait = GLOB.fileaccess_timer - world.time
	if(time_to_wait > 0)
		to_chat(src, span_red("Error: file_spam_check(): Spam. Please wait [DisplayTimeText(time_to_wait)]."))
		return TRUE
	var/delay = FTPDELAY
	if(holder)
		delay *= ADMIN_FTPDELAY_MODIFIER
	GLOB.fileaccess_timer = world.time + delay
	return FALSE

#undef FTPDELAY
#undef ADMIN_FTPDELAY_MODIFIER

/**
 * Takes a directory and returns every file within every sub directory.
 * If extensions_filter is provided then only files that end in that extension are given back.
 * If extensions_filter is a list, any file that matches at least one entry is given back.
 */
/proc/pathwalk(path, extensions_filter)
	var/list/jobs = list(path)
	var/list/filenames = list()

	while(length(jobs))
		var/current_dir = pop(jobs)
		var/list/new_filenames = flist(current_dir)

		for(var/new_filename in new_filenames)
			// if filename ends in / it is a directory, append to currdir
			if(findtext(new_filename, "/", -1))
				jobs += "[current_dir][new_filename]"
				continue

			// if no extension filter, add filename and continue
			if(!extensions_filter)
				filenames += "[current_dir][new_filename]"
				continue

			// handle list of extensions
			if(islist(extensions_filter))
				for(var/allowed_extension in extensions_filter)
					if(endswith(new_filename, allowed_extension))
						filenames += "[current_dir][new_filename]"
						break
				continue

			// handle single extension
			if(endswith(new_filename, extensions_filter))
				filenames += "[current_dir][new_filename]"

	return filenames

/// Save file as an external file then md5 it.
/// Used because md5ing files stored in the rsc sometimes gives incorrect md5 results.
/// https://www.byond.com/forum/post/2611357
/proc/md5asfile(file)
	var/static/notch = 0
	// Its importaint this code can handle md5filepath sleeping instead of hard blocking, if it's converted to use rust_g.
	var/filename = "tmp/md5asfile.[world.realtime].[world.timeofday].[world.time].[world.tick_usage].[notch]"
	notch = WRAP(notch+1, 0, 2**15)
	fcopy(file, filename)
	. = rustlib_hash_file(RUSTLIB_HASH_MD5, filename)
	fdel(filename)

/**
 * Sanitizes the name of each node in the path.
 *
 * Im case you are wondering when to use this proc and when to use SANITIZE_FILENAME,
 *
 * You use SANITIZE_FILENAME to sanitize the name of a file [e.g. example.txt]
 *
 * You use sanitize_filepath sanitize the path of a file [e.g. root/node/example.txt]
 *
 * If you use SANITIZE_FILENAME to sanitize a file path things will break.
 */
/proc/sanitize_filepath(path)
	. = ""
	var/delimiter = "/" //Very much intentionally hardcoded
	var/list/all_nodes = splittext(path, delimiter)
	for(var/node in all_nodes)
		if(.)
			. += delimiter // Add the delimiter before each successive node.
		. += SANITIZE_FILENAME(node)

/**
 * Verifys wether a string or file ends with a given file type.
 *
 * this does not at all check the actual type of the file, a user could just rename it
 *
 * Arguments:
 * * file - A string or file. No checks for if this file ACCTALLY exists
 * * file_types - A list of strings to check against [e.g. list("ogg" = TRUE, "mp3" = TRUE)]
 */
/proc/is_file_type_in_list(file, file_types = list())
	var/extstart = findlasttext("[file]", ".")
	if(!extstart)
		return FALSE
	var/ext = copytext("[file]", extstart + 1)
	if(file_types[ext])
		return TRUE

/**
 * Verifys wether a string or file ends with a given file type
 *
 * this does not at all check the actual type of the file, a user could just rename it
 *
 * Arguments:
 * * file - A string or file. No checks for if this file ACCTALLY exists
 * * file_type - A string to check against [e.g. "ogg"]
 */
/proc/is_file_type(file, file_type)
	var/extstart = findlasttext("[file]", ".")
	if(!extstart)
		return FALSE
	var/ext = copytext("[file]", extstart + 1)
	if(ext == file_type)
		return TRUE

/proc/strip_filepath_extension(file, file_types)
	var/extstart = findlasttext("[file]", ".")
	if(!extstart)
		return "[file]"
	var/ext = copytext("[file]", extstart + 1)
	if(ext in file_types)
		return copytext("[file]", 1, extstart)
	return "[file]"
