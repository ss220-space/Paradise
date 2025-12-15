// Admin Verbs in this file are special and cannot use the AVD system for some reason or another.

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = ADMIN_CATEGORY_MAIN

	remove_verb(src, /client/proc/show_verbs)
	add_admin_verbs()

	to_chat(src, span_interface("All of your adminverbs are now visible."), confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Show Adminverbs")

/client/proc/readmin()
	set name = "Re-admin self"
	set category = ADMIN_CATEGORY_MAIN
	set desc = "Regain your admin powers."

	var/datum/admins/D = GLOB.admin_datums[ckey]
	var/rank = null
	if(CONFIG_GET(flag/admin_legacy_system))
		//load text from file
		var/list/Lines = world.file2list("config/admins.txt")
		for(var/line in Lines)
			if(findtext(line, "#")) // Skip comments
				continue

			var/list/splitline = splittext(line, " - ")
			if(length(splitline) != 2) // Always 'ckey - rank'
				continue
			if(lowertext(splitline[1]) == ckey)
				rank = splitline[2]
				break
			continue

	else
		if(!SSdbcore.IsConnected())
			to_chat(src, "Warning, MYSQL database is not connected.", confidential=TRUE)
			return

		var/datum/db_query/rank_read = SSdbcore.NewQuery(
			"SELECT rank FROM [format_table_name("admin")] WHERE ckey=:ckey",
			list("ckey" = ckey)
		)

		if(!rank_read.warn_execute())
			qdel(rank_read)
			return FALSE

		while(rank_read.NextRow())
			rank = rank_read.item[1]

		qdel(rank_read)
	if(!D)
		if(CONFIG_GET(flag/admin_legacy_system))
			if(GLOB.admin_ranks[rank] == null)
				error("Error while re-adminning [src], admin rank ([rank]) does not exist.")
				to_chat(src, "Error while re-adminning, admin rank ([rank]) does not exist.", confidential=TRUE)
				return

			D = new(rank, GLOB.admin_ranks[rank], ckey)
		else
			if(!SSdbcore.IsConnected())
				to_chat(src, "Warning, MYSQL database is not connected.", confidential=TRUE)
				return

			var/datum/db_query/admin_read = SSdbcore.NewQuery(
				"SELECT ckey, rank, flags FROM [format_table_name("admin")] WHERE ckey=:ckey",
				list("ckey" = ckey)
			)

			if(!admin_read.warn_execute())
				qdel(admin_read)
				return FALSE

			while(admin_read.NextRow())
				var/admin_ckey = admin_read.item[1]
				var/admin_rank = admin_read.item[2]
				var/flags = admin_read.item[3]
				if(!admin_ckey)
					to_chat(src, "Error while re-adminning, ckey [admin_ckey] was not found in the admin database.", confidential=TRUE)
					qdel(admin_read)
					return
				if(admin_rank == DELETED_RANK) //This person was de-adminned. They are only in the admin list for archive purposes.
					to_chat(src, "Error while re-adminning, ckey [admin_ckey] is not an admin.", confidential=TRUE)
					qdel(admin_read)
					return

				if(istext(flags))
					flags = text2num(flags)
				D = new(admin_rank, flags, ckey)

			qdel(admin_read)

		var/client/C = GLOB.directory[ckey]
		D.associate(C)
		update_active_keybindings()
		update_byond_admin_configs(C.ckey, D.rights)
		message_admins("[key_name_admin(usr)] re-adminned themselves.")
		log_admin("[key_name(usr)] re-adminned themselves.")
		GLOB.de_admins -= ckey
		GLOB.de_mentors -= ckey
		GLOB.de_devs -= ckey
		if(isobserver(mob))
			var/mob/dead/observer/observer = mob
			observer.update_admin_actions()
		to_chat(src, span_interface("You are now an admin."), confidential = TRUE)
		BLACKBOX_LOG_ADMIN_VERB("Re-admin")
		return
	else
		to_chat(src, "You are already an admin.", confidential=TRUE)
		remove_verb(src, /client/proc/readmin)
		GLOB.de_admins -= ckey
		GLOB.de_mentors -= ckey
		GLOB.de_devs -= ckey
		return
