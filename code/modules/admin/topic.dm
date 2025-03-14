/datum/admins/Topic(href, href_list)
	..()

	if(usr.client != src.owner || !check_rights(0))
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		message_admins("[key_name_admin(usr)] has attempted to override the admin panel!")
		return

	if(SSticker.mode && SSticker.mode.check_antagonists_topic(href, href_list))
		check_antagonists()
		return

	if(href_list["rejectadminhelp"])
		if(!check_rights(R_ADMIN|R_MOD))
			return
		var/client/C = locateUID(href_list["rejectadminhelp"])
		if(!isclient(C))
			return

		C << 'sound/effects/adminhelp.ogg'

		to_chat(C, "<span style='color: red; font-size: 4;'><b>- AdminHelp Rejected! -</b></span>", confidential=TRUE)
		to_chat(C, "<span style='color: red;'><b>Your admin help was rejected.</b></span>", confidential=TRUE)
		to_chat(C, "Please try to be calm, clear, and descriptive in admin helps, do not assume the admin has seen any related events, and clearly state the names of anybody you are reporting. If you asked a question, please ensure it was clear what you were asking.", confidential=TRUE)

		message_admins("[key_name_admin(usr)] rejected [key_name_admin(C.mob)]'s admin help")
		log_admin("[key_name(usr)] rejected [key_name(C.mob)]'s admin help")

	if(href_list["openticket"])
		var/ticketID = text2num(href_list["openticket"])
		if(!href_list["is_mhelp"])
			if(!check_rights(SStickets.rights_needed))
				return
			SStickets.showDetailUI(usr, ticketID)
		else
			if(!check_rights(R_MENTOR|R_MOD|R_ADMIN))
				return
			SSmentor_tickets.showDetailUI(usr, ticketID)

	if(href_list["stickyban"])
		stickyban(href_list["stickyban"],href_list)

	if(href_list["makeAntag"])
		switch(href_list["makeAntag"])
			if("1")
				log_admin("[key_name(usr)] has spawned a traitor.")
				if(!makeTraitors())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("2")
				log_admin("[key_name(usr)] has spawned a changeling.")
				if(!makeChangelings())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("3")
				log_admin("[key_name(usr)] has spawned revolutionaries.")
				if(!makeRevs())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("4")
				log_admin("[key_name(usr)] has spawned a cultists.")
				if(!makeCult())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("5")
				log_admin("[key_name(usr)] has spawned a clockers.")
				if(!makeClockwork())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("6")
				log_admin("[key_name(usr)] has spawned a wizard.")
				if(!makeWizard())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("7")
				log_admin("[key_name(usr)] has spawned vampires.")
				if(!makeVampires())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("8")
				log_admin("[key_name(usr)] has spawned vox raiders.")
				if(!makeVoxRaiders())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("9")
				log_admin("[key_name(usr)] has spawned an abductor team.")
				if(!makeAbductorTeam())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("10")
				log_admin("[key_name(usr)] has spawned a space ninja.")
				if(!makeSpaceNinja())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("11")
				log_admin("[key_name(usr)] has spawned a thief.")
				if(!makeThieves())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("12")
				log_admin("[key_name(usr)] has spawned a blob.")
				if(!makeBlobs())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("13")
				log_admin("[key_name(usr)] has spawned a terror spiders.")
				if(!makeTerrorSpiders())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)
			if("14")
				log_admin("[key_name(usr)] has spawned a xemonorphs.")
				if(!makeAliens())
					to_chat(usr, span_warning("К сожалению, желающих было слишком мало."), confidential=TRUE)

	else if(href_list["dbsearchckey"] || href_list["dbsearchadmin"] || href_list["dbsearchip"] || href_list["dbsearchcid"] || href_list["dbsearchbantype"])
		var/adminckey = href_list["dbsearchadmin"]
		var/playerckey = href_list["dbsearchckey"]
		var/playerip = href_list["dbsearchip"]
		var/playercid = href_list["dbsearchcid"]
		var/dbbantype = text2num(href_list["dbsearchbantype"])
		var/match = 0

		if("dbmatch" in href_list)
			match = 1

		DB_ban_panel(playerckey, adminckey, playerip, playercid, dbbantype, match)
		return

	else if(href_list["dbbanedit"])
		var/banedit = href_list["dbbanedit"]
		var/banid = text2num(href_list["dbbanid"])
		if(!banedit || !banid)
			return

		DB_ban_edit(banid, banedit)
		return

	else if(href_list["dbbanaddtype"])

		var/bantype = text2num(href_list["dbbanaddtype"])
		var/banckey = href_list["dbbanaddckey"]
		var/banip = href_list["dbbanaddip"]
		var/bancid = href_list["dbbanaddcid"]
		var/duration = text2num(href_list["dbbadddurationdays"]) BAN_DAYS
		duration += text2num(href_list["dbbadddurationhours"]) BAN_HOURS
		duration += text2num(href_list["dbbadddurationminutes"])
		var/banduration = duration
		var/banjob = href_list["dbbanaddjob"]
		var/banround = href_list["dbbanaddround"]
		var/banreason = href_list["dbbanreason"]
		var/bantype_str

		banckey = ckey(banckey)

		switch(bantype)
			if(BANTYPE_PERMA)
				if(!banckey || !banreason)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey and reason)</span>", confidential=TRUE)
					return
				banduration = null
				banjob = null
				bantype_str = "PERMABAN"
			if(BANTYPE_TEMP)
				if(!banckey || !banreason || !banduration)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey, reason and duration)</span>", confidential=TRUE)
					return
				banjob = null
				bantype_str = "TEMPBAN"
			if(BANTYPE_JOB_PERMA)
				if(!banckey || !banreason || !banjob)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey, reason and job)</span>", confidential=TRUE)
					return
				banduration = null
				bantype_str = "JOB_PERMABAN"
			if(BANTYPE_JOB_TEMP)
				if(!banckey || !banreason || !banjob || !banduration)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey, reason and job)</span>", confidential=TRUE)
					return
				bantype_str = "JOB_TEMPBAN"
			if(BANTYPE_APPEARANCE)
				if(!banckey || !banreason)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey and reason)</span>", confidential=TRUE)
					return
				banduration = null
				banjob = null
				bantype_str = "APPEARANCE_BAN"
			if(BANTYPE_ADMIN_PERMA)
				if(!banckey || !banreason)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey and reason)</span>", confidential=TRUE)
					return
				banduration = null
				banjob = null
				bantype_str = "ADMIN_PERMABAN"
			if(BANTYPE_ADMIN_TEMP)
				if(!banckey || !banreason || !banduration)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey, reason and duration)</span>", confidential=TRUE)
					return
				banjob = null
				bantype_str = "ADMIN_TEMPBAN"

		var/mob/playermob

		for(var/mob/M in GLOB.player_list)
			if(M.ckey == banckey)
				playermob = M
				break

		if(banround)
			banreason = "Round [GLOB.round_id || "NULL"] [CONFIG_GET(string/servername)]: " + banreason
		banreason = "(MANUAL BAN) "+banreason

		if(!playermob)
			if(banip)
				banreason = "[banreason] (CUSTOM IP)"
			if(bancid)
				banreason = "[banreason] (CUSTOM CID)"
		else
			message_admins("Ban process: A mob matching [playermob.ckey] was found at location [COORD(playermob)]. Custom IP and computer id fields replaced with the IP and computer id from the located mob")

		//get jobs for department if specified, otherwise just returnt he one job in a list.
		var/list/joblist = list()
		switch(banjob)
			if("commanddept")
				for(var/jobPos in GLOB.command_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("securitydept")
				for(var/jobPos in GLOB.security_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in GLOB.engineering_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in GLOB.medical_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("sciencedept")
				for(var/jobPos in GLOB.science_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("supportdept")
				for(var/jobPos in GLOB.support_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("nonhumandept")
				joblist += "pAI"
				for(var/jobPos in GLOB.nonhuman_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("whitelistdept")
				for(var/jobPos in GLOB.whitelisted_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			else
				joblist += banjob

		//Add ban for unbanned jobs within joblist
		for(var/job in joblist)
			if(!jobban_isbanned(playermob, job))
				DB_ban_record(bantype, playermob, banduration, banreason, job, null, banckey, banip, bancid )
				log_admin("[key_name(usr)] added [bantype_str][banduration ? " ([banduration]m)" : ""] for [banckey][job ? " from job [job]" : ""] - [banreason]")
			else
				message_admins("Ban process: [playermob.ckey] already job banned from [job]!")


	else if(href_list["editrights"])
		if(!check_rights(R_PERMISSIONS))
			message_admins("[key_name_admin(usr)] attempted to edit the admin permissions without sufficient rights.")
			log_admin("[key_name(usr)] attempted to edit the admin permissions without sufficient rights.")
			return

		var/adm_ckey

		var/task = href_list["editrights"]
		if(task == "add")
			var/new_ckey = ckey(tgui_input_text(usr, "Сикей нового админа", "Добавление админа", null, encode=FALSE))
			if(!new_ckey)	return
			if(new_ckey in GLOB.admin_datums)
				to_chat(usr, "<span style='color: red;'>Ошибка: Topic 'editrights': [new_ckey] уже админ!</span>", confidential=TRUE)
				return
			adm_ckey = new_ckey
			task = "rank"
		else if(task != "show")
			adm_ckey = ckey(href_list["ckey"])
			if(!adm_ckey)
				to_chat(usr, "<span style='color: red;'>Ошибка: Topic 'editrights': Неверный сикей</span>", confidential=TRUE)
				return

		var/datum/admins/D = GLOB.admin_datums[adm_ckey]

		if(task == "remove")
			if(tgui_alert(usr, "Вы уверены что хотите удалить [adm_ckey]?","Внимание!",list("Да", "Отмена")) == "Да")
				if(!D)	return
				GLOB.admin_datums -= adm_ckey
				D.disassociate()

				updateranktodb(adm_ckey, "Игрок")
				message_admins("[key_name_admin(usr)] удалил [adm_ckey] из списка админов")
				log_admin("[key_name(usr)] удалил [adm_ckey] из списка админов")
				log_admin_rank_modification(adm_ckey, "Удален")

		else if(task == "rank")
			var/new_rank
			if(length(GLOB.admin_ranks))
				new_rank = tgui_input_list(usr, "Выберите стандартный ранг или создайте новый", "Выбор ранга", (GLOB.admin_ranks|"*Новый Ранг*"), null)
			else
				CRASH("GLOB.admin_ranks is empty, inform coders")

			var/rights = 0
			if(D)
				rights = D.rights
			switch(new_rank)
				if(null,"") return
				if("*Новый Ранг*")
					new_rank = tgui_input_text(usr, "Введите название нового ранга", "Новый Ранг", null, encode = FALSE)
					if(!new_rank)
						to_chat(usr, "<span style='color: red;'>Ошибка: Topic 'editrights': Неверный ранг</span>", confidential=TRUE)
						return
					if(new_rank in GLOB.admin_ranks)
						rights = GLOB.admin_ranks[new_rank]		//we typed a rank which already exists, use its rights
					else
						GLOB.admin_ranks[new_rank] = 0			//add the new rank to admin_ranks
				else
					rights = GLOB.admin_ranks[new_rank]				//we input an existing rank, use its rights

			if(D)
				D.disassociate()								//remove adminverbs and unlink from client
				D.rank = new_rank								//update the rank
				D.rights = rights								//update the rights based on admin_ranks (default: 0)
			else
				D = new /datum/admins(new_rank, rights, adm_ckey)

			var/client/C = GLOB.directory[adm_ckey]						//find the client with the specified ckey (if they are logged in)
			D.associate(C)											//link up with the client and add verbs

			updateranktodb(adm_ckey, new_rank)
			message_admins("[key_name_admin(usr)] изменил ранг админа [adm_ckey] на [new_rank]")
			log_admin("[key_name(usr)] изменил ранг админа [adm_ckey] на [new_rank]")
			log_admin_rank_modification(adm_ckey, new_rank, rights)

		else if(task == "permissions")
			if(!D)
				return
			var/new_value = input_bitfield(usr, "rights", D.rights)
			if(!new_value)
				return
			var/add_bits = new_value & ~D.rights
			var/removed_bits = D.rights & ~new_value
			D.rights = new_value
			edit_admin_permissions()
			message_admins("[key_name_admin(usr)] переключил флаги админу [adm_ckey]: [add_bits? " ВКЛ - [rights2text(add_bits, " ")]" : ""][removed_bits? " ВЫКЛ - [rights2text(removed_bits, " ")]":""]")
			log_admin("[key_name(usr)] переключил флаги админу [adm_ckey]: [add_bits? " ВКЛ - [rights2text(add_bits, " ")]" : ""][removed_bits? " ВЫКЛ - [rights2text(removed_bits, " ")]":""]")
			log_admin_permission_modification(adm_ckey, new_value )


		edit_admin_permissions()

	else if(href_list["call_shuttle"])

		if(!check_rights(R_ADMIN))
			return

		switch(href_list["call_shuttle"])
			if("1")
				if(EMERGENCY_AT_LEAST_DOCKED)
					return
				SSshuttle.emergency.request()
				log_admin("[key_name(usr)] called the Emergency Shuttle")
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] called the Emergency Shuttle to the station</span>")

			if("2")
				if(EMERGENCY_AT_LEAST_DOCKED)
					return
				switch(SSshuttle.emergency.mode)
					if(SHUTTLE_CALL)
						SSshuttle.emergency.cancel()
						log_admin("[key_name(usr)] sent the Emergency Shuttle back")
						message_admins("<span class='adminnotice'>[key_name_admin(usr)] sent the Emergency Shuttle back</span>")
					else
						SSshuttle.emergency.cancel()
						log_admin("[key_name(usr)] called the Emergency Shuttle")
						message_admins("<span class='adminnotice'>[key_name_admin(usr)] called the Emergency Shuttle to the station</span>")


		href_list["check_antagonist"] = TRUE

	else if(href_list["edit_shuttle_time"])
		if(!check_rights(R_SERVER))	return

		var/timer = tgui_input_number(usr, "Enter new shuttle duration (seconds):", "Edit Shuttle Timeleft", SSshuttle.emergency.timeLeft())
		SSshuttle.emergency.setTimer(timer SECONDS)
		var/time_to_destination = round(SSshuttle.emergency.timeLeft(600))
		log_admin("[key_name(usr)] edited the Emergency Shuttle's timeleft to [timer] seconds")
		GLOB.minor_announcement.Announce("Эвакуационный шаттл достигнет места назначения через [time_to_destination] [declension_ru(time_to_destination,"минуту","минуты","минут")].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] edited the Emergency Shuttle's timeleft to [timer] seconds</span>")
		href_list["check_antagonist"] = TRUE

	else if(href_list["stop_lockdown"])
		if(!check_rights(R_ADMIN))
			return
		if(!you_realy_want_do_this())
			return

		var message = (SSshuttle.emergency.mode == SHUTTLE_STRANDED)?"de-lockdowned and de-strandise the Emergency Shuttle":"de-lockdowned the Emergency Shuttle"
		SSshuttle?.stop_lockdown()
		log_and_message_admins(span_adminnotice("[key_name_admin(usr)] [message]"))
		href_list["check_antagonist"] = TRUE

	else if(href_list["lockdown_shuttle"])
		if(!check_rights(R_ADMIN))
			return

		if(!you_realy_want_do_this())
			return

		SSshuttle?.lockdown_escape()
		log_and_message_admins(span_adminnotice("[key_name_admin(usr)] lockdowned the Emergency Shuttle"))
		href_list["check_antagonist"] = TRUE

	else if(href_list["reload_shuttle"])
		if(!check_rights(R_ADMIN))
			return

		if(!you_realy_want_do_this())
			return

		if(SSshuttle?.reload_shuttle(TRUE))
			log_and_message_admins(span_adminnotice("[key_name_admin(usr)] reloaded the Emergency Shuttle"))
		href_list["check_antagonist"] = TRUE

	else if(href_list["full_lockdown"])
		if(!check_rights(R_ADMIN))
			return

		if(!you_realy_want_do_this())
			return

		GLOB.full_lockdown = !GLOB.full_lockdown
		log_and_message_admins("[GLOB.full_lockdown? "enabled" : "disabled"] Full Lockdown")
		href_list["check_antagonist"] =  TRUE

	else if(href_list["delay_round_end"])
		if(!check_rights(R_SERVER))	return

		SSticker.delay_end = !SSticker.delay_end
		log_and_message_admins("[SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		if(SSticker.delay_end)
			SSticker.real_reboot_time = 0 // If they set this at round end, show the "Reboot was cancelled by an admin" message instantly
		href_list["check_antagonist"] = TRUE

	else if(href_list["simplemake"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locateUID(href_list["mob"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return

		var/delmob = 0
		switch(tgui_alert(usr, "Delete old mob?", "Message", list("Yes", "No", "Cancel")))
			if("Cancel")	return
			if("Yes")		delmob = 1

		switch(href_list["simplemake"])
			if("observer")			M.change_mob_type( /mob/dead/observer , null, null, delmob, 1 )
			if("drone")				M.change_mob_type( /mob/living/carbon/alien/humanoid/drone , null, null, delmob, 1 )
			if("hunter")			M.change_mob_type( /mob/living/carbon/alien/humanoid/hunter , null, null, delmob, 1 )
			if("queen")				M.change_mob_type( /mob/living/carbon/alien/humanoid/queen/large , null, null, delmob, 1 )
			if("sentinel")			M.change_mob_type( /mob/living/carbon/alien/humanoid/sentinel , null, null, delmob, 1 )
			if("larva")				M.change_mob_type( /mob/living/carbon/alien/larva , null, null, delmob, 1 )
			if("human")
				var/posttransformoutfit = usr.client.robust_dress_shop()
				var/mob/living/carbon/human/newmob = M.change_mob_type(/mob/living/carbon/human, null, null, delmob, 1)
				if(posttransformoutfit && istype(newmob))
					newmob.equipOutfit(posttransformoutfit)
			if("slime")				M.change_mob_type( /mob/living/simple_animal/slime , null, null, delmob, 1 )
			if("monkey")			M.change_mob_type( /mob/living/carbon/human/lesser/monkey , null, null, delmob, 1 )
			if("robot")				M.change_mob_type( /mob/living/silicon/robot , null, null, delmob, 1 )
			if("cat")				M.change_mob_type( /mob/living/simple_animal/pet/cat , null, null, delmob, 1 )
			if("runtime")			M.change_mob_type( /mob/living/simple_animal/pet/cat/Runtime , null, null, delmob, 1 )
			if("corgi")				M.change_mob_type( /mob/living/simple_animal/pet/dog/corgi , null, null, delmob, 1 )
			if("crab")				M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob, 1 )
			if("coffee")			M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob, 1 )
			if("parrot")			M.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob, 1 )
			if("polyparrot")		M.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob, 1 )
			if("constructarmoured")	M.change_mob_type( /mob/living/simple_animal/hostile/construct/armoured , null, null, delmob, 1 )
			if("constructbuilder")	M.change_mob_type( /mob/living/simple_animal/hostile/construct/builder , null, null, delmob, 1 )
			if("constructwraith")	M.change_mob_type( /mob/living/simple_animal/hostile/construct/wraith , null, null, delmob, 1 )
			if("shade")				M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob, 1 )

		log_and_message_admins("has used rudimentary transformation on [key_name(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]")


	/////////////////////////////////////new ban stuff
	else if(href_list["unbanf"])
		if(!check_rights(R_BAN))	return

		var/banfolder = href_list["unbanf"]
		GLOB.banlist_savefile.cd = "/base/[banfolder]"
		var/key = GLOB.banlist_savefile["key"]
		if(tgui_alert(usr, "Are you sure you want to unban [key]?", "Confirmation", list("Yes", "No")) == "Yes")
			if(RemoveBan(banfolder))
				unbanpanel()
			else
				tgui_alert(usr, "This ban has already been lifted / does not exist.", "Error", list("Ok"))
				unbanpanel()

	else if(href_list["unbane"])
		if(!check_rights(R_BAN))	return

		UpdateTime()
		var/reason

		var/banfolder = href_list["unbane"]
		GLOB.banlist_savefile.cd = "/base/[banfolder]"
		var/reason2 = GLOB.banlist_savefile["reason"]
		var/temp = GLOB.banlist_savefile["temp"]

		var/minutes = GLOB.banlist_savefile["minutes"]

		var/banned_key = GLOB.banlist_savefile["key"]
		GLOB.banlist_savefile.cd = "/base"

		var/duration

		switch(tgui_alert(usr, "Temporary Ban?",, list("Yes", "No")))
			if("Yes")
				temp = 1
				var/mins = 0
				if(minutes > GLOB.CMinutes)
					mins = minutes - GLOB.CMinutes
				mins = tgui_input_number(usr, "How long (in minutes)? (Default: 1440)", "Ban time", mins ? mins : 1440, max_value = 525599)
				if(!mins)
					return
				minutes = GLOB.CMinutes + mins
				duration = GetExp(minutes)
				reason = tgui_input_text(usr, "Please state the reason", "Reason", reason2, multiline = TRUE, encode = FALSE)
				if(!reason)
					return
			if("No")
				temp = 0
				duration = "Perma"
				reason = tgui_input_text(usr, "Please state the reason", "Reason", reason2, multiline = TRUE, encode = FALSE)
				if(!reason)	return

		log_admin("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		ban_unban_log_save("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		message_admins("<span class='notice'>[key_name_admin(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]</span>")
		GLOB.banlist_savefile.cd = "/base/[banfolder]"
		to_chat(GLOB.banlist_savefile["reason"], reason)
		to_chat(GLOB.banlist_savefile["temp"], temp)
		to_chat(GLOB.banlist_savefile["minutes"], minutes)
		to_chat(GLOB.banlist_savefile["bannedby"], usr.ckey)
		GLOB.banlist_savefile.cd = "/base"
		unbanpanel()

	/////////////////////////////////////new ban stuff

	else if(href_list["appearanceban"])
		if(!check_rights(R_BAN))
			return
		var/mob/M = locateUID(href_list["appearanceban"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		if(!M.ckey)	//sanity
			to_chat(usr, "<span class='warning'>This mob has no ckey</span>", confidential=TRUE)
			return
		var/ban_ckey_param = href_list["dbbanaddckey"]

		var/banreason = appearance_isbanned(M)
		if(banreason)
	/*		if(!CONFIG_GET(flag/ban_legacy_system))
				to_chat(usr, "<span class='warning'>Unfortunately, database based unbanning cannot be done through this panel</span>")
				DB_ban_panel(M.ckey)
				return	*/
			switch(tgui_alert(usr, "Reason: '[banreason]' Remove appearance ban?", "Please Confirm", list("Yes", "No")))
				if("Yes")
					ban_unban_log_save("[key_name(usr)] removed [key_name(M)]'s appearance ban")
					log_admin("[key_name(usr)] removed [key_name(M)]'s appearance ban")
					DB_ban_unban(M.ckey, BANTYPE_APPEARANCE)
					appearance_unban(M)
					message_admins("<span class='notice'>[key_name_admin(usr)] removed [key_name_admin(M)]'s appearance ban</span>")
					to_chat(M, "<span class='warning'><big><b>[usr.client.ckey] has removed your appearance ban.</b></big></span>", confidential=TRUE)

		else switch(tgui_alert(usr, "Appearance ban [M.ckey]?",, list("Yes", "No", "Cancel")))
			if("Yes")
				var/reason = tgui_input_text(usr, "Please state the reason", "Reason", multiline = TRUE, encode = FALSE)
				if(!reason)
					return
				M = admin_ban_mobsearch(M, ban_ckey_param, usr)
				ban_unban_log_save("[key_name(usr)] appearance banned [key_name(M)]. reason: [reason]")
				log_admin("[key_name(usr)] appearance banned [key_name(M)]. \nReason: [reason]")
				DB_ban_record(BANTYPE_APPEARANCE, M, -1, reason)
				appearance_fullban(M, "[reason]; By [usr.ckey] on [time2text(world.realtime)]")
				add_note(M.ckey, "Appearance banned - [reason]", null, usr.ckey, 0)
				message_admins("<span class='notice'>[key_name_admin(usr)] appearance banned [key_name_admin(M)]</span>")
				to_chat(M, "<span class='warning'><big><b>You have been appearance banned by [usr.client.ckey].</b></big></span>", confidential=TRUE)
				to_chat(M, "<span class='danger'>The reason is: [reason]</span>", confidential=TRUE)
				to_chat(M, "<span class='warning'>Appearance ban can be lifted only upon request.</span>", confidential=TRUE)
				if(CONFIG_GET(string/banappeals))
					to_chat(M, "<span class='warning'>To try to resolve this matter head to [CONFIG_GET(string/banappeals)]</span>", confidential=TRUE)
				else
					to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>", confidential=TRUE)
			if("No")
				return

	else if(href_list["jobban2"])
//		if(!check_rights(R_BAN))	return

		var/mob/M = locateUID(href_list["jobban2"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return

		if(!M.ckey)	//sanity
			to_chat(usr, "<span class='warning'>This mob has no ckey</span>", confidential=TRUE)
			return
		if(!SSjobs)
			to_chat(usr, "<span class='warning'>SSjobs has not been setup!</span>", confidential=TRUE)
			return

		var/dat = ""
		var/jobs = ""

	/***********************************WARNING!************************************
				      The jobban stuff looks mangled and disgusting
						      But it looks beautiful in-game
						                -Nodrak
	************************************WARNING!***********************************/
		var/counter = 0
//Regular jobs
	//Command (Blue)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr align='center' bgcolor='ccccff'><th colspan='[length(GLOB.command_positions)]'><a href='byond://?src=[UID()];jobban3=commanddept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Command Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.command_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><span style='color: red;'>[replacetext(job.title, " ", "&nbsp")]</span></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 6) //So things dont get squiiiiished!
				jobs += "</tr><tr>"
				counter = 0
		jobs += "</tr></table>"

	//Security (Red)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffddf0'><th colspan='[length(GLOB.security_positions)]'><a href='byond://?src=[UID()];jobban3=securitydept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Security Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.security_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><span style='color: red;'>[replacetext(job.title, " ", "&nbsp")]</span></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Engineering (Yellow)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='fff5cc'><th colspan='[length(GLOB.engineering_positions)]'><a href='byond://?src=[UID()];jobban3=engineeringdept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Engineering Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.engineering_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><span style='color: red;'>[replacetext(job.title, " ", "&nbsp")]</span></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Medical (White)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeef0'><th colspan='[length(GLOB.medical_positions)]'><a href='byond://?src=[UID()];jobban3=medicaldept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Medical Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.medical_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><span style='color: red;'>[replacetext(job.title, " ", "&nbsp")]</span></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Science (Purple)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='e79fff'><th colspan='[length(GLOB.science_positions)]'><a href='byond://?src=[UID()];jobban3=sciencedept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Science Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.science_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><span style='color: red;'>[replacetext(job.title, " ", "&nbsp")]</span></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Support (Grey)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='dddddd'><th colspan='[length(GLOB.support_positions)]'><a href='byond://?src=[UID()];jobban3=supportdept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Support Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.support_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><span style='color: red;'>[replacetext(job.title, " ", "&nbsp")]</span></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Non-Human (Green)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccffcc'><th colspan='[length(GLOB.nonhuman_positions)+1]'><a href='byond://?src=[UID()];jobban3=nonhumandept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Non-human Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.nonhuman_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><span style='color: red;'>[replacetext(job.title, " ", "&nbsp")]</span></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		//Drone
		if(jobban_isbanned(M, "Drone"))
			jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=Drone;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><span style='color: red;'>Drone</span></a></td>"
		else
			jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=Drone;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Drone</a></td>"

		//pAI
		if(jobban_isbanned(M, "pAI"))
			jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=pAI;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><span style='color: red;'>pAI</span></a></td>"
		else
			jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=pAI;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>pAI</a></td>"

		jobs += "</tr></table>"

	//Antagonist (Orange)
		var/isbanned_dept = jobban_isbanned(M, "Syndicate")
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='byond://?src=[UID()];jobban3=Syndicate;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Antagonist Positions</a></th></tr><tr align='center'>"

		counter = 0
		for(var/role in GLOB.antag_roles)
			if(jobban_isbanned(M, role) || isbanned_dept)
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[role];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><span style='color: red;'>[replacetext(role, " ", "&nbsp")]</span></a></td>"
			else
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[role];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(role, " ", "&nbsp")]</a></td>"
			counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Other races  (BLUE, because I have no idea what other color to make this)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccccff'><th colspan='10'>Other</th></tr><tr align='center'>"

		counter = 0
		for(var/role in GLOB.other_roles)
			if(jobban_isbanned(M, role) || isbanned_dept)
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[role];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><span style='color: red;'>[replacetext(role, " ", "&nbsp")]</span></a></td>"
			else
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[role];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(role, " ", "&nbsp")]</a></td>"
			counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Whitelisted positions
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='dddddd'><th colspan='[length(GLOB.whitelisted_positions)]'><a href='byond://?src=[UID()];jobban3=whitelistdept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Whitelisted Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.whitelisted_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><span style='color: red;'>[replacetext(job.title, " ", "&nbsp")]</span></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='byond://?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

		dat = "<tt>[jobs]</tt>"

		var/datum/browser/popup = new(usr, "jobban2", "Jobban", 1000, 550)
		popup.set_content(dat)
		popup.open(FALSE)
		return

	//JOBBAN'S INNARDS
	else if(href_list["jobban3"])
		if(!check_rights(R_BAN))	return

		var/mob/M = locateUID(href_list["jobban4"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return

		if(M != usr)																//we can jobban ourselves
			if(M.client && M.client.holder && (M.client.holder.rights & R_BAN))		//they can ban too. So we can't ban them
				tgui_alert(usr, "You cannot perform this action. You must be of a higher administrative rank!")
				return

		var/ban_ckey_param = href_list["dbbanaddckey"]

		if(!SSjobs)
			to_chat(usr, "<span class='warning'>SSjobs has not been setup!</span>", confidential=TRUE)
			return

		//get jobs for department if specified, otherwise just returnt he one job in a list.
		var/list/joblist = list()
		switch(href_list["jobban3"])
			if("commanddept")
				for(var/jobPos in GLOB.command_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("securitydept")
				for(var/jobPos in GLOB.security_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in GLOB.engineering_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in GLOB.medical_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("sciencedept")
				for(var/jobPos in GLOB.science_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("supportdept")
				for(var/jobPos in GLOB.support_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("nonhumandept")
				joblist += "pAI"
				for(var/jobPos in GLOB.nonhuman_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("whitelistdept")
				for(var/jobPos in GLOB.whitelisted_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			else
				joblist += href_list["jobban3"]

		//Create a list of unbanned jobs within joblist
		var/list/notbannedlist = list()
		for(var/job in joblist)
			if(!jobban_isbanned(M, job))
				notbannedlist += job

		//Banning comes first
		if(notbannedlist.len) //at least 1 unbanned job exists in joblist so we have stuff to ban.
			switch(tgui_alert(usr, "Temporary Ban of [M.ckey]?",, list("Yes", "No", "Cancel")))
				if("Yes")
					if(CONFIG_GET(flag/ban_legacy_system))
						to_chat(usr, "<span class='warning'>Your server is using the legacy banning system, which does not support temporary job bans. Consider upgrading. Aborting ban.</span>", confidential=TRUE)
						return
					var/mins = tgui_input_number(usr, "How long (in minutes)?", "Ban time", 1440, max_value = 525599)
					if(!mins)
						return
					var/reason = tgui_input_text(usr, "Please state the reason", "Reason", "", multiline = TRUE, encode = FALSE)
					if(!reason)
						return

					var/msg
					M = admin_ban_mobsearch(M, ban_ckey_param, usr)
					for(var/job in notbannedlist)
						ban_unban_log_save("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes. reason: [reason]")
						log_admin("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes")
						DB_ban_record(BANTYPE_JOB_TEMP, M, mins, reason, job)
						jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]") //Legacy banning does not support temporary jobbans.
						if(!msg)
							msg = job
						else
							msg += ", [job]"
					add_note(M.ckey, "Banned  from [msg] - [reason]", null, usr.ckey, 0)
					message_admins("<span class='notice'>[key_name_admin(usr)] banned [key_name_admin(M)] from [msg] for [mins] minutes</span>")
					to_chat(M, "<span class='warning'><big><b>You have been jobbanned by [usr.client.ckey] from: [msg].</b></big></span>", confidential=TRUE)
					to_chat(M, "<span class='danger'>The reason is: [reason]</span>", confidential=TRUE)
					to_chat(M, "<span class='warning'>This jobban will be lifted in [mins] minutes.</span>", confidential=TRUE)
					href_list["jobban2"] = 1 // lets it fall through and refresh
					return 1
				if("No")
					var/reason = tgui_input_text(usr, "Please state the reason", "Reason", "", multiline = TRUE, encode = FALSE)
					if(reason)
						var/msg
						M = admin_ban_mobsearch(M, ban_ckey_param, usr)
						for(var/job in notbannedlist)
							ban_unban_log_save("[key_name(usr)] perma-jobbanned [key_name(M)] from [job]. reason: [reason]")
							log_admin("[key_name(usr)] perma-banned [key_name(M)] from [job]")
							DB_ban_record(BANTYPE_JOB_PERMA, M, -1, reason, job)
							jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]")
							if(!msg)	msg = job
							else		msg += ", [job]"
						add_note(M.ckey, "Banned  from [msg] - [reason]", null, usr.ckey, 0)
						message_admins("<span class='notice'>[key_name_admin(usr)] banned [key_name_admin(M)] from [msg]</span>")
						to_chat(M, "<span class='warning'><big><b>You have been jobbanned by [usr.client.ckey] from: [msg].</b></big></span>", confidential=TRUE)
						to_chat(M, "<span class='danger'>The reason is: [reason]</span>", confidential=TRUE)
						to_chat(M, "<span class='warning'>Jobban can be lifted only upon request.</span>", confidential=TRUE)
						href_list["jobban2"] = 1 // lets it fall through and refresh
						return 1
				if("Cancel")
					return

		//Unbanning joblist
		//all jobs in joblist are banned already OR we didn't give a reason (implying they shouldn't be banned)
		if(joblist.len) //at least 1 banned job exists in joblist so we have stuff to unban.
			if(!CONFIG_GET(flag/ban_legacy_system))
				to_chat(usr, "<span class='warning'>Unfortunately, database based unbanning cannot be done through this panel</span>", confidential=TRUE)
				DB_ban_panel(M.ckey)
				return
			var/msg
			for(var/job in joblist)
				var/reason = jobban_isbanned(M, job)
				if(!reason) continue //skip if it isn't jobbanned anyway
				switch(tgui_alert(usr, "Job: '[job]' Reason: '[reason]' Un-jobban?", "Please Confirm", list("Yes", "No")))
					if("Yes")
						ban_unban_log_save("[key_name(usr)] unjobbanned [key_name(M)] from [job]")
						log_admin("[key_name(usr)] unbanned [key_name(M)] from [job]")
						DB_ban_unban(M.ckey, BANTYPE_JOB_PERMA, job)
						jobban_unban(M, job)
						if(!msg)	msg = job
						else		msg += ", [job]"
					else
						continue
			if(msg)
				message_admins("<span class='notice'>[key_name_admin(usr)] unbanned [key_name_admin(M)] from [msg]</span>")
				to_chat(M, "<span class='warning'><big><b>You have been un-jobbanned by [usr.client.ckey] from [msg].</b></big></span>", confidential=TRUE)
				href_list["jobban2"] = 1 // lets it fall through and refresh
			return 1
		return 0 //we didn't do anything!

	else if(href_list["boot2"])
		var/mob/M = locateUID(href_list["boot2"])
		if(!ismob(M))
			return
		var/client/C = M.client
		if(C == null)
			to_chat(usr, "<span class='warning'>Mob has no client to kick.</span>", confidential=TRUE)
			return
		if(tgui_alert(usr, "Kick [C.ckey]?",, list("Yes", "No")) == "Yes")
			if(C && C.holder && (C.holder.rights & R_BAN))
				to_chat(usr, "<span class='warning'>[key_name_admin(C)] cannot be kicked from the server.</span>", confidential=TRUE)
				return
			to_chat(C, "<span class='warning'>You have been kicked from the server</span>", confidential=TRUE)
			log_and_message_admins("<span class='notice'>booted [key_name_admin(C)].</span>")
			//C = null
			qdel(C)

	else if(href_list["open_logging_view"])
		var/mob/M = locateUID(href_list["open_logging_view"])
		if(ismob(M))
			usr.client.open_logging_view(list(M), TRUE)

	else if(href_list["geoip"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["geoip"])
		if (ismob(M))
			if(!M.client)
				return
			var/dat = ""
			var/client/C = M.client
			if(C.geoip.status != "updated")
				C.geoip.try_update_geoip(C, C.address)
			dat += "<center><b>Ckey:</b> [M.ckey]</center>"
			dat += "<b>Country:</b> [C.geoip.country]<br>"
			dat += "<b>CountryCode:</b> [C.geoip.countryCode]<br>"
			dat += "<b>Region:</b> [C.geoip.region]<br>"
			dat += "<b>Region Name:</b> [C.geoip.regionName]<br>"
			dat += "<b>City:</b> [C.geoip.city]<br>"
			dat += "<b>Timezone:</b> [C.geoip.timezone]<br>"
			dat += "<b>ISP:</b> [C.geoip.isp]<br>"
			dat += "<b>Mobile:</b> [C.geoip.mobile]<br>"
			dat += "<b>Proxy:</b> [C.geoip.proxy]<br>"
			dat += "<b>IP:</b> [C.geoip.ip]<br>"
			dat += "<hr><b>Status:</b> [C.geoip.status]"
			var/datum/browser/popup = new(usr, "geoip", "<div align='center'>GeoIP info</div>", 400, 300)
			popup.set_content(dat)
			popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
			popup.open()
			onclose(usr, "geoip")

	//Player Notes
	else if(href_list["addnote"])
		var/target_ckey = href_list["addnote"]
		add_note(target_ckey)

	else if(href_list["addnoteempty"])
		add_note()

	else if(href_list["removenote"])
		var/note_id = href_list["removenote"]
		if(tgui_alert(usr, "Do you really want to delete this note?", "Note deletion confirmation", list("Yes", "No")) == "Yes")
			remove_note(note_id)

	else if(href_list["editnote"])
		var/note_id = href_list["editnote"]
		edit_note(note_id)

	else if(href_list["shownote"])
		var/target = href_list["shownote"]
		show_note(index = target)

	else if(href_list["nonalpha"])
		var/target = href_list["nonalpha"]
		target = text2num(target)
		show_note(index = target)

	else if(href_list["webtools"])
		var/target_ckey = href_list["webtools"]
		if(CONFIG_GET(string/forum_playerinfo_url))
			var/url_to_open = CONFIG_GET(string/forum_playerinfo_url) + target_ckey
			if(tgui_alert(usr, "Open [url_to_open]",, list("Yes", "No")) == "Yes")
				usr.client << link(url_to_open)

	else if(href_list["shownoteckey"])
		var/target_ckey = href_list["shownoteckey"]
		show_note(target_ckey)

	else if(href_list["notessearch"])
		var/target = href_list["notessearch"]
		show_note(index = target)

	else if(href_list["removejobban"])
		if(!check_rights(R_BAN))	return

		var/t = href_list["removejobban"]
		if(t)
			if((tgui_alert(usr, "Do you want to unjobban [t]?", "Unjobban confirmation", list("Yes", "No")) == "Yes") && t) //No more misclicks! Unless you do it twice.
				log_and_message_admins("<span class='notice'>removed [t]</span>")
				jobban_remove(t)
				href_list["ban"] = 1 // lets it fall through and refresh
				var/t_split = splittext(t, " - ")
				var/key = t_split[1]
				var/job = t_split[2]
				DB_ban_unban(ckey(key), BANTYPE_JOB_PERMA, job)

	else if(href_list["newban"])
		if(!check_rights(R_BAN))	return

		var/mob/M = locateUID(href_list["newban"])
		if(!istype(M, /mob))
			return
		var/ban_ckey_param = href_list["dbbanaddckey"]

		switch(tgui_alert(usr, "Temporary Ban of [M.ckey] / [ban_ckey_param]?",, list("Yes", "No", "Cancel")))
			if("Yes")
				var/mins = tgui_input_number(usr, "How long (in minutes)?", "Ban time", 1440, max_value = 525599)
				if(!mins)
					return
				var/reason = tgui_input_text(usr, "Please state the reason", "Reason", multiline = TRUE, encode = FALSE)
				if(!reason)
					return
				M = admin_ban_mobsearch(M, ban_ckey_param, usr)
				AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
				ban_unban_log_save("[usr.client.ckey] has banned [M.ckey]. - Reason: [reason] - This will be removed in [mins] minutes.")
				to_chat(M, "<span class='warning'><big><b>You have been banned by [usr.client.ckey].\nReason: [reason].</b></big></span>", confidential=TRUE)
				to_chat(M, "<span class='warning'>This is a temporary ban, it will be removed in [mins] minutes.</span>", confidential=TRUE)
				DB_ban_record(BANTYPE_TEMP, M, mins, reason)
				if(M.client)
					M.client.link_forum_account(TRUE)
				if(CONFIG_GET(string/banappeals))
					to_chat(M, "<span class='warning'>To try to resolve this matter head to [CONFIG_GET(string/banappeals)]</span>", confidential=TRUE)
				else
					to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>", confidential=TRUE)
				log_admin("[key_name(usr)] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
				message_admins("<span class='notice'>[key_name_admin(usr)] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.</span>")

				qdel(M.client)
			if("No")
				var/reason = tgui_input_text(usr, "Please state the reason", "Reason", multiline = TRUE, encode = FALSE)
				if(!reason)
					return
				AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0, M.lastKnownIP)
				to_chat(M, "<span class='warning'><big><b>You have been banned by [usr.client.ckey].\nReason: [reason].</b></big></span>", confidential=TRUE)
				to_chat(M, "<span class='warning'>This ban does not expire automatically and must be appealed.</span>", confidential=TRUE)
				if(M.client)
					M.client.link_forum_account(TRUE)
				if(CONFIG_GET(string/banappeals))
					to_chat(M, "<span class='warning'>To try to resolve this matter head to [CONFIG_GET(string/banappeals)]</span>", confidential=TRUE)
				else
					to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>", confidential=TRUE)
				ban_unban_log_save("[usr.client.ckey] has permabanned [M.ckey]. - Reason: [reason] - This ban does not expire automatically and must be appealed.")
				log_admin("[key_name(usr)] has banned [M.ckey].\nReason: [reason]\nThis ban does not expire automatically and must be appealed.")
				message_admins("<span class='notice'>[key_name_admin(usr)] has banned [M.ckey].\nReason: [reason]\nThis ban does not expire automatically and must be appealed.</span>")
				DB_ban_record(BANTYPE_PERMA, M, -1, reason)

				qdel(M.client)
			if("Cancel")
				return


	//Watchlist
	else if(href_list["watchadd"])
		var/target_ckey = href_list["watchadd"]
		usr.client.watchlist_add(target_ckey)

	else if(href_list["watchremove"])
		var/target_ckey = href_list["watchremove"]
		var/confirm = tgui_alert(usr, "Are you sure you want to remove [target_ckey] from the watchlist?", "Confirm Watchlist Removal", list("Yes", "No"))
		if(confirm == "Yes")
			usr.client.watchlist_remove(target_ckey)

	else if(href_list["watchedit"])
		var/target_ckey = href_list["watchedit"]
		usr.client.watchlist_edit(target_ckey)

	else if(href_list["watchaddbrowse"])
		usr.client.watchlist_add(null, 1)

	else if(href_list["watchremovebrowse"])
		var/target_ckey = href_list["watchremovebrowse"]
		usr.client.watchlist_remove(target_ckey, 1)

	else if(href_list["watcheditbrowse"])
		var/target_ckey = href_list["watcheditbrowse"]
		usr.client.watchlist_edit(target_ckey, 1)

	else if(href_list["watchsearch"])
		var/target_ckey = href_list["watchsearch"]
		usr.client.watchlist_show(target_ckey)

	else if(href_list["watchshow"])
		usr.client.watchlist_show()

	else if(href_list["watcheditlog"])
		var/target_ckey = href_list["watcheditlog"]
		var/datum/db_query/query_watchedits = SSdbcore.NewQuery("SELECT edits FROM [CONFIG_GET(string/utility_database)].[format_table_name("watch")] WHERE ckey=:targetkey", list(
			"targetkey" = target_ckey
		))
		if(!query_watchedits.warn_execute())
			qdel(query_watchedits)
			return
		if(query_watchedits.NextRow())
			var/edit_log = query_watchedits.item[1]
			var/datum/browser/popup = new(usr, "watchedits", "Watch List Edit")
			popup.set_content(edit_log)
			popup.open(FALSE)
		qdel(query_watchedits)

	else if(href_list["mute"])
		if(!check_rights(R_ADMIN|R_MOD))
			return

		var/mob/M = locateUID(href_list["mute"])
		if(!istype(M, /mob))	return
		if(!M.client)	return

		var/mute_type = href_list["mute_type"]
		if(istext(mute_type))	mute_type = text2num(mute_type)
		if(!isnum(mute_type))	return

		cmd_admin_mute(M, mute_type)

	else if(href_list["c_mode"])
		if(!check_rights(R_ADMIN))	return

		if(SSticker && SSticker.mode)
			return tgui_alert(usr, "The game has already started.")
		var/dat = {"<b>What mode do you wish to play?</b><hr>"}
		dat += {"<table><tr><td>Minplayers</td><td>Gamemode</td></tr>"}
		for(var/mode in config.modes)
			dat += {"<tr><td>\[[config.mode_required_players[mode]]\]</td><td><a href='byond://?src=[UID()];c_mode2=[mode]'>[config.mode_names[mode]]<a></td></tr>"}
		dat += {"</table><br><a href='byond://?src=[UID()];c_mode2=secret'>Secret<a><br>"}
		dat += {"<a href='byond://?src=[UID()];c_mode2=random'>Random<a><br>"}
		dat += {"Now: [GLOB.master_mode]"}

		var/datum/browser/popup = new(usr, "c_mode", "<div align='center'>Game Mode</div>")
		popup.set_content(dat)
		popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
		popup.open(TRUE)
		onclose(usr, "c_mode")

	else if(href_list["f_secret"])
		if(!check_rights(R_ADMIN))	return

		if(SSticker && SSticker.mode)
			return tgui_alert(usr, "The game has already started.")
		if(GLOB.master_mode != "secret")
			return tgui_alert(usr, "The game mode has to be secret!")
		var/dat = {"<b>What game mode do you want to force secret to be? Use this if you want to change the game mode, but want the players to believe it's secret. This will only work if the current game mode is secret.</b><hr>"}
		dat += {"<table><tr><td>Minplayers</td><td>Gamemode</td></tr>"}
		for(var/mode in config.modes)
			dat += {"<tr><td>\[[config.mode_required_players[mode]]\]</td><td><a href='byond://?src=[UID()];f_secret2=[mode]'>[config.mode_names[mode]]<a></td></tr>"}
		dat += {"</table><br><a href='byond://?src=[UID()];f_secret2=secret'>Random (default)<a><br>"}
		dat += {"Now: [GLOB.secret_force_mode]"}
		var/datum/browser/popup = new(usr, "f_secret", "<div align='center'>Secret Game Mode</div>")
		popup.set_content(dat)
		popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
		popup.open()
		onclose(usr, "f_secret")

	else if(href_list["c_mode2"])
		if(!check_rights(R_ADMIN|R_SERVER))	return

		if(SSticker && SSticker.mode)
			return tgui_alert(usr, "The game has already started.")
		GLOB.master_mode = href_list["c_mode2"]
		log_and_message_admins("<span class='notice'>set the mode as [GLOB.master_mode].</span>")
		to_chat(world, "<span class='boldnotice'>The mode is now: [GLOB.master_mode]</span>")
		Game() // updates the main game menu
		if (tgui_alert(usr, " Хотите ли вы сохранить этот режим как режим по умолчанию?", "Сохранить режим", list("Да", "Нет")) == "Да")
			world.save_mode(GLOB.master_mode)
		.(href, list("c_mode"=1))

	else if(href_list["f_secret2"])
		if(!check_rights(R_ADMIN|R_SERVER))	return

		if(SSticker && SSticker.mode)
			return tgui_alert(usr, "The game has already started.")
		if(GLOB.master_mode != "secret")
			return tgui_alert(usr, "The game mode has to be secret!")
		GLOB.secret_force_mode = href_list["f_secret2"]
		log_and_message_admins("<span class='notice'>set the forced secret mode as [GLOB.secret_force_mode].</span>")
		Game() // updates the main game menu
		.(href, list("f_secret"=1))

	else if(href_list["change_weights"])
		if(!check_rights(R_ADMIN))
			return
		if(SSticker && SSticker.mode)
			return tgui_alert(usr, "The game has already started.")
		if(GLOB.master_mode != "antag-paradise" && GLOB.secret_force_mode != "antag-paradise")
			return tgui_alert(usr, "The game mode has to be Antag Paradise!")

		var/dat = {"<b>Edit the antag weights for minor antagonists. Higher the weight higher the chance for antag to roll. Press reset if you want default behavior.</b><hr>"}
		dat += {"<table><tr><td><b>Antag</b></td><td><b>Weight</b></td></tr>"}
		var/list/antags_list
		if(GLOB.antag_paradise_weights)
			antags_list = GLOB.antag_paradise_weights
		else
			antags_list = CONFIG_GET(keyed_list/antag_paradise_single_antags_weights)
			antags_list = antags_list.Copy()

		for(var/antag in antags_list)
			dat += {"<tr><td>[capitalize(antag)]</td><td><a href='byond://?src=[UID()];change_weights2=weights_normal_[antag]'>\[[antags_list[antag]]\]<a></td></tr>"}

		dat += {"</table><br><b>Edit the antag weights for special antag. Only one antag from below will be chosen for the mode. Rolling NOTHING means no special antag at all.</b><hr>"}
		dat += {"<table><tr><td><b>Antag</b></td><td><b>Weight</b></td></tr>"}
		var/list/special_antags_list = GLOB.antag_paradise_special_weights ? GLOB.antag_paradise_special_weights : config_to_roles(CONFIG_GET(keyed_list/antag_paradise_special_antags_weights))
		for(var/antag in special_antags_list)
			dat += {"<tr><td>[capitalize(antag)]</td><td><a href='byond://?src=[UID()];change_weights2=weights_special_[antag]'>\[[special_antags_list[antag]]\]<a></td></tr>"}

		dat += {"</table><br><b>Edit the chance to roll double antag ([capitalize(ROLE_VAMPIRE)]/[capitalize(ROLE_CHANGELING)]) for [capitalize(ROLE_TRAITOR)].</b><hr>"}
		dat += {"<table><tr><td>Chance = </td><td><a href='byond://?src=[UID()];change_weights2=chance'>[isnull(GLOB.antag_paradise_double_antag_chance) ? "[CONFIG_GET(number/antag_paradise_double_antag_chance)]" : "[GLOB.antag_paradise_double_antag_chance]%"]<a></td></tr></table>"}

		dat += {"<br><a href='byond://?src=[UID()];change_weights2=reset'>Reset everything to default.<a><br>"}

		var/datum/browser/popup = new(usr, "change_weights", "<div align='center'>Antag Paradise Weights</div>", 900, 700)
		popup.set_content(dat)
		popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
		popup.open(TRUE)
		onclose(usr, "change_weights")

	else if(href_list["change_weights2"])
		if(!check_rights(R_ADMIN))
			return
		if(SSticker && SSticker.mode)
			return tgui_alert(usr, "The game has already started.")
		if(GLOB.master_mode != "antag-paradise" && GLOB.secret_force_mode != "antag-paradise")
			return tgui_alert(usr, "The game mode has to be Antag Paradise!")

		var/command = href_list["change_weights2"]
		if(command == "reset")
			GLOB.antag_paradise_weights = null
			GLOB.antag_paradise_special_weights = null
			GLOB.antag_paradise_double_antag_chance = null
			log_and_message_admins(span_notice("resets everything to default in Antag Paradise gamemode."))

		else if(command == "chance")
			var/choice = tgui_input_number(usr, "Adjust the chance for [capitalize(ROLE_TRAITOR)] antag to roll additional role on top", "Double Antag Adjustment", 0, min_value = 0, max_value = 100)
			if(isnull(choice))
				return
			GLOB.antag_paradise_double_antag_chance = choice
			log_and_message_admins(span_notice("set the [choice]% chance to roll double antag for [capitalize(ROLE_TRAITOR)] antagonist in Antag Paradise gamemode."))

		else if(findtext(command, "weights_normal_"))
			if(!GLOB.antag_paradise_weights)
				var/list/antags_list = CONFIG_GET(keyed_list/antag_paradise_single_antags_weights)
				antags_list = antags_list.Copy()
				for(var/key in list(ROLE_TRAITOR, ROLE_VAMPIRE, ROLE_CHANGELING, ROLE_THIEF))
					antags_list[key] = !!(key in antags_list)
				GLOB.antag_paradise_weights = antags_list
			var/antag = replacetext(command, "weights_normal_", "")
			var/choice = tgui_input_number(usr, "Adjust the weight for [capitalize(antag)]", "Antag Weight Adjustment", 0, min_value = 0, max_value = 100)
			if(isnull(choice))
				return
			GLOB.antag_paradise_weights[antag] = choice
			log_and_message_admins(span_notice("set the weight for [capitalize(antag)] as antagonist to [choice] in Antag Paradise gamemode."))

		else if(findtext(command, "weights_special_"))
			if(!GLOB.antag_paradise_special_weights)
				GLOB.antag_paradise_special_weights = config_to_roles(CONFIG_GET(keyed_list/antag_paradise_special_antags_weights))
			var/antag = replacetext(command, "weights_special_", "")
			var/choice = tgui_input_number(usr, "Adjust the weight for [capitalize(antag)]", "Antag Weight Adjustment", 0, min_value = 0, max_value = 100)
			if(isnull(choice))
				return
			GLOB.antag_paradise_special_weights[antag] = choice
			log_and_message_admins(span_notice("set the weight for [capitalize(antag)] as special antagonist to [choice] in Antag Paradise gamemode."))
		.(href, list("change_weights"=1))

	else if(href_list["monkeyone"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["monkeyone"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>", confidential=TRUE)
			return
		if(tgui_alert(usr, "Confirm make monkey?",, list("Yes", "No")) != "Yes")
			return

		log_and_message_admins("<span class='notice'>attempting to monkeyize [key_name_admin(H)]</span>")
		H.monkeyize()

	else if(href_list["forcespeech"])
		if(!check_rights(R_EVENT))
			return

		var/mob/M = locateUID(href_list["forcespeech"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return

		var/speech = tgui_input_text(usr, "What will [key_name(M)] say?.", "Force speech", "", encode = FALSE)// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)	return
		M.say(speech)
		speech = sanitize(speech) // Nah, we don't trust them
		log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
		message_admins("<span class='notice'>[key_name_admin(usr)] forced [key_name_admin(M)] to say: [speech]</span>")

	else if(href_list["sendtoprison"])
		if(!check_rights(R_ADMIN))	return

		if(tgui_alert(usr, "Отправить в админскую тюрьму на остаток раунда?", "Подтверждение", list("Да", "Нет")) != "Да")
			return

		var/mob/M = locateUID(href_list["sendtoprison"])
		if(!istype(M, /mob))
			to_chat(usr, span_warning("Это можно использовать только на объектах типа /mob"), confidential=TRUE)
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, span_warning("Это нельзя использовать на объектах типа /mob/living/silicon/ai"), confidential=TRUE)
			return

		var/turf/prison_cell = pick(GLOB.prisonwarp)
		if(!prison_cell)	return

		var/obj/structure/closet/supplypod/centcompod/prison_warp/pod = new()
		pod.reverse_dropoff_coords = list(prison_cell.x, prison_cell.y, prison_cell.z)
		pod.target = M
		new /obj/effect/pod_landingzone(M, pod)

		log_and_message_admins("sent [key_name_admin(M)] to the prison station.")

	else if(href_list["sendbacktolobby"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["sendbacktolobby"])

		if(!isobserver(M))
			to_chat(usr, "<span class='notice'>You can only send ghost players back to the Lobby.</span>", confidential=TRUE)
			return

		if(!M.client)
			to_chat(usr, "<span class='warning'>[M] doesn't seem to have an active client.</span>", confidential=TRUE)
			return

		if(tgui_alert(usr, "Send [key_name(M)] back to Lobby?", "Message", list("Yes", "No")) != "Yes")
			return

		log_admin("[key_name(usr)] has sent [key_name(M)] back to the Lobby.")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] back to the Lobby.")

		var/mob/new_player/NP = new()
		GLOB.non_respawnable_keys -= M.ckey
		NP.ckey = M.ckey
		qdel(M)

	else if(href_list["eraseflavortext"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["eraseflavortext"])

		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return

		if(!M.client)
			to_chat(usr, "<span class='warning'>[M] doesn't seem to have an active client.</span>", confidential=TRUE)
			return

		if(M.flavor_text == "" && M.client.prefs.flavor_text == "")
			to_chat(usr, "<span class='warning'>[M] has no flavor text set.</span>", confidential=TRUE)
			return

		if(tgui_alert(usr, "Erase [key_name(M)]'s flavor text?", "Message", list("Yes", "No")) != "Yes")
			return

		log_admin("[key_name(usr)] has erased [key_name(M)]'s flavor text.")
		message_admins("[key_name_admin(usr)] has erased [key_name_admin(M)]'s flavor text.")

		// Clears the mob's flavor text
		M.flavor_text = ""

		// Clear and save the DB character's flavor text
		M.client.prefs.flavor_text = ""
		M.client.prefs.save_character(M.client)

	else if(href_list["userandomname"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["userandomname"])

		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return

		if(!M.client)
			to_chat(usr, "<span class='warning'>[M] doesn't seem to have an active client.</span>", confidential=TRUE)
			return

		if(tgui_alert(usr, "Force [key_name(M)] to use a random name?", "Message", list("Yes", "No")) != "Yes")
			return

		log_admin("[key_name(usr)] has forced [key_name(M)] to use a random name.")
		message_admins("[key_name_admin(usr)] has forced [key_name_admin(M)] to use a random name.")

		// Update the mob's name with a random one straight away
		var/random_name = random_name(M.client.prefs.gender, M.client.prefs.species)
		M.rename_character(M.real_name, random_name)

		// Save that random name for next rounds
		M.client.prefs.real_name = random_name
		M.client.prefs.save_character(M.client)

	else if(href_list["cma_admin"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["cma_admin"])
		if(!ishuman(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /human</span>", confidential=TRUE)
			return
		usr.client.change_human_appearance_admin(M)

	else if(href_list["cma_self"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["cma_self"])
		if(!ishuman(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /human</span>", confidential=TRUE)
			return
		usr.client.change_human_appearance_self(M)

	else if(href_list["check_contents"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["check_contents"])
		if(!isliving(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /living</span>", confidential=TRUE)
			return
		usr.client.cmd_admin_check_contents(M)

	else if(href_list["man_up"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["man_up"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		usr.client.man_up(M)

	else if(href_list["select_equip"])
		if(!check_rights(R_EVENT))
			return

		var/mob/M = locateUID(href_list["select_equip"])
		if(!ishuman(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /human</span>", confidential=TRUE)
			return
		usr.client.cmd_admin_dress(M)
	else if(href_list["change_voice"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["change_voice"])
		if(!isliving(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /living</span>", confidential=TRUE)
			return
		var/old_tts_seed = M.tts_seed
		var/new_tts_seed = M.change_voice(usr, override = TRUE)
		if(!new_tts_seed)
			return

		to_chat(M, "<span class='notice'>Your voice has been changed from [old_tts_seed] to [new_tts_seed].</span>", confidential=TRUE)
		log_and_message_admins("has changed [key_name_admin(M)]'s voice from [old_tts_seed] to [new_tts_seed]")

	else if(href_list["update_mob_sprite"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["update_mob_sprite"])
		if(!ishuman(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /human</span>", confidential=TRUE)
			return
		usr.client.update_mob_sprite(M)

	else if(href_list["asays"])
		if(!check_rights(R_ADMIN | R_MOD))
			return

		usr.client.view_asays()

	else if(href_list["msays"])
		if(!check_rights(R_ADMIN | R_MENTOR))
			return

		usr.client.view_msays()

	else if(href_list["devsays"])
		if(!check_rights(R_ADMIN | R_VIEWRUNTIMES))
			return

		usr.client.view_devsays()

	else if(href_list["tdome1"])
		if(!check_rights(R_EVENT))
			return

		if(tgui_alert(usr, "Confirm?", "Message", list("Yes", "No")) != "Yes")
			return

		var/mob/M = locateUID(href_list["tdome1"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/living/silicon/ai</span>", confidential=TRUE)
			return

		for(var/obj/item/I in M)
			M.drop_item_ground(I)

		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)
		M.forceMove(pick(GLOB.tdome1))
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_and_message_admins("has sent [key_name_admin(M)] to the thunderdome. (Team 1)")

	else if(href_list["tdome2"])
		if(!check_rights(R_EVENT))
			return

		if(tgui_alert(usr, "Confirm?", "Message", list("Yes", "No")) != "Yes")
			return

		var/mob/M = locateUID(href_list["tdome2"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/living/silicon/ai</span>", confidential=TRUE)
			return

		for(var/obj/item/I in M)
			M.drop_item_ground(I)

		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)
		M.forceMove(pick(GLOB.tdome2))
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_and_message_admins("has sent [key_name_admin(M)] to the thunderdome. (Team 2)")

	else if(href_list["tdomeadmin"])
		if(!check_rights(R_EVENT))
			return

		if(tgui_alert(usr, "Confirm?", "Message", list("Yes", "No")) != "Yes")
			return

		var/mob/M = locateUID(href_list["tdomeadmin"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/living/silicon/ai</span>", confidential=TRUE)
			return

		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)
		M.forceMove(pick(GLOB.tdomeadmin))
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_and_message_admins("has sent [key_name_admin(M)] to the thunderdome. (Admin.)")

	else if(href_list["tdomeobserve"])
		if(!check_rights(R_EVENT))
			return

		if(tgui_alert(usr, "Confirm?", "Message", list("Yes", "No")) != "Yes")
			return

		var/mob/M = locateUID(href_list["tdomeobserve"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/living/silicon/ai</span>", confidential=TRUE)
			return

		for(var/obj/item/I in M)
			M.drop_item_ground(I)

		if(ishuman(M))
			var/mob/living/carbon/human/observer = M
			observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(observer), ITEM_SLOT_CLOTH_INNER)
			observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(observer), ITEM_SLOT_FEET)
		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)
		M.forceMove(pick(GLOB.tdomeobserve))
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_and_message_admins("has sent [key_name_admin(M)] to the thunderdome. (Observer.)")

	else if(href_list["contractor_stop"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["contractor_stop"])
		if(!istype(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob.</span>", confidential=TRUE)
			return

		var/datum/syndicate_contract/contract = LAZYACCESS(GLOB.prisoner_belongings.prisoners, M)
		if(!contract)
			to_chat(usr, "<span class='warning'>[M] is currently not imprisoned by the Syndicate.</span>", confidential=TRUE)
			return
		if(!contract.prisoner_timer_handle)
			to_chat(usr, "<span class='warning'>[M] is already NOT scheduled to return from the Syndicate Jail.</span>", confidential=TRUE)
			return

		deltimer(contract.prisoner_timer_handle)
		contract.prisoner_timer_handle = null
		to_chat(usr, "Stopped automatic return of [M] from the Syndicate Jail.", confidential=TRUE)
		message_admins("[key_name_admin(usr)] has stopped the automatic return of [key_name_admin(M)] from the Syndicate Jail")
		log_admin("[key_name(usr)] has stopped the automatic return of [key_name(M)] from the Syndicate Jail")

	else if(href_list["contractor_start"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["contractor_start"])
		if(!istype(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob.</span>", confidential=TRUE)
			return

		var/datum/syndicate_contract/contract = LAZYACCESS(GLOB.prisoner_belongings.prisoners, M)
		if(!contract)
			to_chat(usr, "<span class='warning'>[M] is currently not imprisoned by the Syndicate.</span>", confidential=TRUE)
			return
		if(contract.prisoner_timer_handle)
			to_chat(usr, "<span class='warning'>[M] is already scheduled to return from the Syndicate Jail.</span>", confidential=TRUE)
			return

		var/time_seconds = tgui_input_number(usr, "Enter the jail time in seconds:", "Start Syndicate Jail Timer")
		time_seconds = text2num(time_seconds)
		if(time_seconds < 0)
			return

		contract.prisoner_timer_handle = addtimer(CALLBACK(contract, TYPE_PROC_REF(/datum/syndicate_contract, handle_target_return), M), time_seconds * 10, TIMER_STOPPABLE)
		to_chat(usr, "Started automatic return of [M] from the Syndicate Jail in [time_seconds] second\s.", confidential=TRUE)
		message_admins("[key_name_admin(usr)] has started the automatic return of [key_name_admin(M)] from the Syndicate Jail in [time_seconds] second\s")
		log_admin("[key_name(usr)] has started the automatic return of [key_name(M)] from the Syndicate Jail in [time_seconds] second\s")

	else if(href_list["contractor_release"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["contractor_release"])
		if(!istype(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob.</span>", confidential=TRUE)
			return

		var/datum/syndicate_contract/contract = LAZYACCESS(GLOB.prisoner_belongings.prisoners, M)
		if(!contract)
			to_chat(usr, "<span class='warning'>[M] is currently not imprisoned by the Syndicate.</span>", confidential=TRUE)
			return

		deltimer(contract.prisoner_timer_handle)
		contract.handle_target_return(M)
		to_chat(usr, "Immediately returned [M] from the Syndicate Jail.", confidential=TRUE)
		message_admins("[key_name_admin(usr)] has immediately returned [key_name_admin(M)] from the Syndicate Jail")
		log_admin("[key_name(usr)] has immediately returned [key_name(M)] from the Syndicate Jail")


	else if(href_list["aroomwarp"])
		if(!check_rights(R_ADMIN))	return

		if(tgui_alert(usr, "Confirm?", "Message", list("Yes", "No")) != "Yes")
			return

		var/mob/M = locateUID(href_list["aroomwarp"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/living/silicon/ai</span>", confidential=TRUE)
			return

		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)
		M.forceMove(pick(GLOB.aroomwarp))
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the <b>Admin Room!</b>.</span>")
		log_and_message_admins("has sent [key_name_admin(M)] to the Admin Room")

	else if(href_list["togglerespawnability"])
		var/mob/dead/observer/O = locateUID(href_list["togglerespawnability"])
		if(!istype(O))
			to_chat(usr, "This can only be used on instances of type /mob/dead/observer", confidential=TRUE)
			return
		if(!(O in GLOB.respawnable_list))
			GLOB.respawnable_list += O
			log_and_message_admins("allowed [key_name(O)] to respawn!")
		else
			GLOB.respawnable_list -= O
			log_and_message_admins("disallowed [key_name(O)] to respawn!")

	else if(href_list["revive"])
		if(!check_rights(R_REJUVINATE))	return

		var/mob/living/L = locateUID(href_list["revive"])
		if(!istype(L))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living</span>", confidential=TRUE)
			return

		L.revive()
		log_and_message_admins("healed / revived [key_name(L)]")

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>", confidential=TRUE)
			return

		if(tgui_alert(usr, "Confirm make ai?",, list("Yes", "No")) != "Yes")
			return

		log_and_message_admins("AIized [key_name(H)]")
		var/mob/living/silicon/ai/ai_character = H.AIize()
		ai_character.moveToAILandmark()
		SSticker?.score?.save_silicon_laws(ai_character, usr, "admin AIzed user", log_all_laws = TRUE)

	else if(href_list["makesuper"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makesuper"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>", confidential=TRUE)
			return

		if(tgui_alert(usr, "Confirm make superhero?",, list("Yes", "No")) != "Yes")
			return

		usr.client.cmd_admin_super(H)

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>", confidential=TRUE)
			return
		if(tgui_alert(usr, "Confirm make robot?",, list("Yes", "No")) != "Yes")
			return

		usr.client.cmd_admin_robotize(H)

	else if(href_list["makeanimal"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locateUID(href_list["makeanimal"])
		if(isnewplayer(M))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/new_player</span>", confidential=TRUE)
			return
		if(tgui_alert(usr, "Confirm make animal?",, list("Yes", "No")) != "Yes")
			return

		usr.client.cmd_admin_animalize(M)

	else if(href_list["makePAI"])
		if(!check_rights(R_SPAWN))
			return
		var/bespai = FALSE
		var/mob/living/carbon/human/H = locateUID(href_list["makePAI"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human", confidential=TRUE)
			return

		if(tgui_alert(usr, "Confirm make pAI?",, list("Yes", "No")) == "No")
			return

		if(tgui_alert(usr, "pAI or SpAI?",, list("pAI", "SpAI")) == "SpAI")
			bespai = TRUE

		var/painame = "Default"
		var/name = ""
		if(tgui_alert(usr, "Do you want to set their name or let them choose their own name?", "Name Choice", list("Set Name", "Let them choose")) == "Set Name")
			name = sanitize(tgui_input_text(usr, "Enter a name for the new pAI. Default name is [painame].", "pAI Name", painame, encode=FALSE, max_length = MAX_NAME_LEN))
		else
			name = sanitize(tgui_input_text(H, "An admin wants to make you into a pAI. Choose a name. Default is [painame].", "pAI Name", painame, encode=FALSE, max_length = MAX_NAME_LEN))

		if(!name)
			name = painame

		log_and_message_admins("pAIzed [key_name(H)]")
		H.paize(name, bespai)

	else if(href_list["makegorilla"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/M = locateUID(href_list["makegorilla"])
		if(isnewplayer(M))
			to_chat(usr, span_warning("This cannot be used on instances of type /mob/new_player"), confidential=TRUE)
			return

		usr.client.cmd_admin_gorillize(M)

	else if(href_list["incarn_ghost"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/dead/observer/G = locateUID(href_list["incarn_ghost"])
		if(!istype(G))
			to_chat(usr, "<span class='warning'>This will only work on /mob/dead/observer</span>", confidential=TRUE)
			return

		var/posttransformoutfit = usr.client.robust_dress_shop()

		if(!posttransformoutfit)
			return

		var/mob/living/carbon/human/H = G.incarnate_ghost()

		if(posttransformoutfit && istype(H))
			H.equipOutfit(posttransformoutfit)

		log_admin("[key_name(G)] was incarnated by [key_name(owner)]")
		message_admins("[key_name_admin(G)] was incarnated by [key_name_admin(owner)]")

	else if(href_list["togmutate"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/carbon/human/H = locateUID(href_list["togmutate"])
		var/source = href_list["version"]
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return
		var/block=text2num(href_list["block"])
		//testing("togmutate([href_list["block"]] -> [block])")
		usr.client.cmd_admin_toggle_block(H,block)
		if(source == "old")
			show_player_panel(H)
		else
			usr.client.holder.Topic(null, list("showdna" = H.UID()))

		//H.regenerate_icons()

	else if(href_list["adminplayeropts"])
		var/mob/M = locateUID(href_list["adminplayeropts"])

		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return

		show_player_panel(M)

	else if(href_list["adminplayerobservefollow"])
		var/client/client = usr.client
		var/mob/mob = locateUID(href_list["adminplayerobservefollow"])

		client.admin_observe_target(mob)

	else if(href_list["check_antagonist"])
		check_antagonists()

	else if(href_list["check_teams"])
		if(!check_rights(R_ADMIN))
			return

		check_teams()

	else if(href_list["edit_blob_win_count"])
		if(!check_rights(R_ADMIN))
			return
		var/blob_win_count = tgui_input_number(usr, "Ввидите новое число критической массы", "Критическая масса:" , SSticker.mode.blob_win_count)
		if(!blob_win_count)
			return

		if(!SSticker || !SSticker.mode)
			return

		SSticker.mode.blob_win_count = blob_win_count
		SSticker.mode.update_blob_objective()
		log_admin("[key_name(usr)] has enter new blob win count: [blob_win_count]")
		message_admins("[key_name_admin(usr)] enter new blob win count: [blob_win_count]")

	else if(href_list["send_warning"])
		if(!check_rights(R_ADMIN))
			return

		var/message = tgui_input_text(usr, "Введите предупреждение", "Предупреждение", encode = FALSE)
		if(tgui_alert(usr,"Вы действительно хотите отправить предупреждение всем блобам?", "", list("Да", "Нет")) == "Нет")
			return

		if(!SSticker || !SSticker.mode)
			return

		SSticker.mode.show_warning(message)
		log_admin("[key_name(usr)] has send warning to all blobs: [message]")
		message_admins("[key_name_admin(usr)] has send warning to all blobs: [message]")

	else if(href_list["burst_all_blobs"])
		if(!check_rights(R_ADMIN))
			return

		if(tgui_alert(usr,"Вы действительно хотите лопнуть всех блобов?", "", list("Да", "Нет")) == "Нет")
			return

		if(!SSticker || !SSticker.mode)
			return

		SSticker.mode.burst_blobs()
		log_admin("[key_name(usr)] has burst all blobs")
		message_admins("[key_name_admin(usr)] has burst all blobs")

	else if(href_list["delay_blob_end"])
		if(!check_rights(R_ADMIN) || !check_rights(R_EVENT))
			return

		if(!SSticker || !SSticker.mode)
			return

		var/datum/game_mode/mode = SSticker.mode
		if(tgui_alert(usr,"Вы действительно хотите [mode.delay_blob_end? "вернуть" : "преостановить"] конец раунда в случае победы блоба?", "", list("Да", "Нет")) == "Нет")
			return

		if(!mode.delay_blob_end)
			mode.delay_blob_win()
		else
			mode.return_blob_win()

		log_admin("[key_name(usr)] has [mode.delay_blob_end? "stopped" : "returned"] stopped delayed blob win")
		message_admins("[key_name_admin(usr)] has [mode.delay_blob_end? "stopped" : "returned"] delayed blob win")


	else if(href_list["toggle_blob_infinity_points"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSticker || !SSticker.mode)
			return

		var/datum/game_mode/mode = SSticker.mode
		if(tgui_alert(usr,"Вы действительно хотите [mode.is_blob_infinity_points? "убрать" : "вернуть"] бесконечные очки у блобов?", "", list("Да", "Нет")) == "Нет")
			return

		mode.is_blob_infinity_points = !mode.is_blob_infinity_points

		log_admin("[key_name(usr)] has [mode.is_blob_infinity_points? "remove" : "returned"] blob infinity points")
		message_admins("[key_name_admin(usr)] has [mode.is_blob_infinity_points? "remove" : "returned"] blob infinity points")

	else if(href_list["toggle_auto_nuke_codes"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSticker || !SSticker.mode)
			return

		var/datum/game_mode/mode = SSticker.mode
		if(tgui_alert(usr,"Вы действительно хотите [mode.off_auto_nuke_codes? "вернуть" : "убрать"] автоматические коды от ядерной боеголовки?", "", list("Да", "Нет")) == "Нет")
			return

		mode.off_auto_nuke_codes = !mode.off_auto_nuke_codes

		log_admin("[key_name(usr)] has [mode.off_auto_nuke_codes? "remove" : "returned"] automatic nuke codes")
		message_admins("[key_name_admin(usr)] has [mode.off_auto_nuke_codes? "remove" : "returned"] automatic nuke codes")

	else if(href_list["toggle_auto_gamma"])
		if(!check_rights(R_ADMIN) || !check_rights(R_EVENT))
			return

		if(!SSticker || !SSticker.mode)
			return

		var/datum/game_mode/mode = SSticker.mode
		if(tgui_alert(usr,"Вы действительно хотите [mode.off_auto_gamma? "вернуть" : "убрать"] автоматический ГАММА код?", "", list("Да", "Нет")) == "Нет")
			return

		mode.off_auto_gamma = !mode.off_auto_gamma

		log_admin("[key_name(usr)] has [mode.off_auto_gamma? "remove" : "returned"] automatic GAMMA code")
		message_admins("[key_name_admin(usr)] has [mode.off_auto_gamma? "remove" : "returned"] automatic GAMMA code")

	else if(href_list["team_command"])
		if(!check_rights(R_ADMIN))
			return

		var/datum/team/team
		var/datum/mind/member
		if(href_list["team"])
			team = locateUID(href_list["team"])
			if(QDELETED(team))
				to_chat(usr, "<span class='warning'>This team doesn't exist anymore!</span>", confidential=TRUE)
				return

		if(href_list["member"])
			member = locateUID(href_list["member"])
			if(QDELETED(member))
				to_chat(usr, "<span class='warning'>This team member doesn't exist anymore!</span>", confidential=TRUE)
				return

		switch(href_list["team_command"])
			if("communicate")
				team.admin_communicate(usr)

			if("delete_team")
				message_admins("[key_name_admin(usr)] has deleted the '[team.name]' team.")
				log_admin("[key_name_admin(usr)] has deleted the '[team.name]' team.")
				qdel(team)

			if("rename_team")
				team.admin_rename_team(usr)

			if("admin_add_member")
				team.admin_add_member(usr)

			if("remove_member")
				team.admin_remove_member(usr, member)

			if("view_member")
				show_player_panel(member.current)

			if("add_objective")
				team.admin_add_objective(usr)

			if("remove_objective")
				var/datum/objective/objective = locateUID(href_list["objective"])
				if(objective)
					team.admin_remove_objective(usr, objective)
			else
				team.Topic(href, href_list)

		check_teams()

	else if(href_list["randomizename"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locateUID(href_list["randomizename"])
		//exists?
		if( !M )	return
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob", confidential=TRUE)
			return
		if(isobserver(M))
			to_chat(usr, "This can only be used on living", confidential=TRUE)
			return
		//rename mob
		var/old_name = M.real_name
		var/message = "has renamed [key_name_admin(M)] to "
		var/new_name = M.generate_name()
		//rename mind and money account
		if(M.mind)
			M.mind.name  = new_name
			if(M.mind.initial_account)
				M.mind.initial_account.owner_name = new_name
		//rename all ids with mob old name
		var/list/found_ids = M.search_contents_for(/obj/item/card/id)
		if(LAZYLEN(found_ids))
			for(var/obj/item/card/id/ID in found_ids)
				if(ID.registered_name == old_name)
					ID.name = "[new_name]'s ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
					ID.registered_name = new_name
					ID.RebuildHTML()
		//rename all pdas with mob old name
		var/list/found_pdas = M.search_contents_for(/obj/item/pda)
		if(LAZYLEN(found_pdas))
			for(var/obj/item/pda/PDA in found_pdas)
				if(PDA.owner == old_name)
					PDA.update_owner_name(new_name)
					PDA.name = "PDA-[new_name] ([PDA.ownjob])"
		//update the datacore records! This is goig to be a bit costly.
		for(var/list/L in list(GLOB.data_core.general, GLOB.data_core.medical, GLOB.data_core.security, GLOB.data_core.locked))
			for(var/datum/data/record/R in L)
				if(R.fields["name"] == old_name)
					R.fields["name"] = new_name
					if(length(R.fields["id"]) == 32)
						R.fields["id"] = md5("[new_name][M.mind.assigned_role]")
					break

		log_and_message_admins(message + "[new_name].")


	else if(href_list["take_question"])
		var/index = text2num(href_list["take_question"])

		if(href_list["is_mhelp"])
			SSmentor_tickets.takeTicket(index)
		else //Ahelp
			SStickets.takeTicket(index)

	else if(href_list["resolve"])
		if(!check_rights(R_MENTOR|R_MOD|R_ADMIN))
			return
		var/index = text2num(href_list["resolve"])
		if(href_list["is_mhelp"])
			SSmentor_tickets.resolveTicket(index)
		else //Ahelp
			SStickets.resolveTicket(index)

	else if(href_list["autorespond"])
		if(href_list["is_mhelp"])
			to_chat(usr, "<span class='warning'>Auto responses are not available for mentor helps.</span>", confidential=TRUE)
			return
		var/index = text2num(href_list["autorespond"])
		if(!check_rights(R_ADMIN|R_MOD))
			return
		SStickets.autoRespond(index)

	if(href_list["convert_ticket"])
		var/indexNum = text2num(href_list["convert_ticket"])
		if(href_list["is_mhelp"])
			SSmentor_tickets.convert_to_other_ticket(indexNum)
		else
			SStickets.convert_to_other_ticket(indexNum)

	else if(href_list["cult_mindspeak"])
		var/input = tgui_input_text(usr, "Communicate to all the cultists with the voice of [SSticker.cultdat.entity_name]", "Voice of [SSticker.cultdat.entity_name]", encode = FALSE)
		if(!input)
			return

		for(var/datum/mind/H in SSticker.mode.cult)
			if(H.current)
				to_chat(H.current, "<span class='cult'>[SSticker.cultdat.entity_name] murmurs,</span> <span class='cultlarge'>\"[input]\"</span>")

		for(var/mob/dead/observer/O in GLOB.player_list)
			to_chat(O, "<span class='cult'>[SSticker.cultdat.entity_name] murmurs,</span> <span class='cultlarge'>\"[input]\"</span>")

		message_admins("Admin [key_name_admin(usr)] has talked with the Voice of [SSticker.cultdat.entity_name].")
		log_admin("[key_name(usr)] Voice of [SSticker.cultdat.entity_name]: [input]")

	else if(href_list["cult_adjustsacnumber"])
		var/amount = tgui_input_number(usr, "Adjust the amount of sacrifices required before summoning Nar'Sie", "Sacrifice Adjustment", 2)
		if(amount > 0)
			var/datum/game_mode/gamemode = SSticker.mode
			var/old = gamemode.cult_objs.sacrifices_required
			gamemode.cult_objs.sacrifices_required = amount
			message_admins("Admin [key_name_admin(usr)] has modified the amount of cult sacrifices required before summoning from [old] to [amount]")
			log_admin("Admin [key_name_admin(usr)] has modified the amount of cult sacrifices required before summoning from [old] to [amount]")

	else if(href_list["cult_newtarget"])
		if(tgui_alert(usr, "Reroll the cult's sacrifice target?", "Cult Debug", list("Yes", "No")) != "Yes")
			return

		var/datum/game_mode/gamemode = SSticker.mode
		if(!gamemode.cult_objs.find_new_sacrifice_target())
			gamemode.cult_objs.ready_to_summon()

		message_admins("Admin [key_name_admin(usr)] has rerolled the Cult's sacrifice target.")
		log_admin("Admin [key_name_admin(usr)] has rerolled the Cult's sacrifice target.")

	else if(href_list["cult_newsummonlocations"])
		if(tgui_alert(usr, "Reroll the cult's summoning locations?", "Cult Debug", list("Yes", "No")) != "Yes")
			return

		var/datum/game_mode/gamemode = SSticker.mode
		gamemode.cult_objs.obj_summon.find_summon_locations(TRUE)
		if(gamemode.cult_objs.cult_status == NARSIE_NEEDS_SUMMONING) //Only update cultists if they are already have the summon goal since they arent aware of summon spots till then
			for(var/datum/mind/cult_mind in gamemode.cult)
				if(cult_mind && cult_mind.current)
					to_chat(cult_mind.current, "<span class='cult'>The veil has shifted! Our summoning will need to take place elsewhere.</span>")
					to_chat(cult_mind.current, "<span class='cult'>Current goal : [gamemode.cult_objs.obj_summon.explanation_text]</span>")

		message_admins("Admin [key_name_admin(usr)] has rerolled the Cult's sacrifice target.")
		log_admin("Admin [key_name_admin(usr)] has rerolled the Cult's sacrifice target.")

	else if(href_list["cult_unlocknarsie"])
		if(tgui_alert(usr, "Unlock the ability to summon Nar'Sie?", "Cult Debug", list("Yes", "No")) != "Yes")
			return

		var/datum/game_mode/gamemode = SSticker.mode
		gamemode.cult_objs.ready_to_summon()
		message_admins("Admin [key_name_admin(usr)] has unlocked the Cult's ability to summon Nar'Sie.")
		log_admin("Admin [key_name_admin(usr)] has unlocked the Cult's ability to summon Nar'Sie.")

	else if(href_list["clock_mindspeak"])
		var/input = tgui_input_text(usr, "Communicate to all the clockers with the voice of Ratvar", "Voice of Ratvar", encode = FALSE)
		if(!input)
			return

		for(var/datum/mind/H in SSticker.mode.clockwork_cult)
			if(H.current)
				to_chat(H.current, "<span class='clock'>Ratvar murmurs,</span> <span class='clocklarge'>\"[input]\"</span>")

		for(var/mob/dead/observer/O in GLOB.player_list)
			to_chat(O, "<span class='clock'>Ratvar murmurs,</span> <span class='clocklarge'>\"[input]\"</span>")

		message_admins("Admin [key_name_admin(usr)] has talked with the Voice of Ratvar.")
		log_admin("[key_name(usr)] Voice of Ratvar: [input]")

	else if(href_list["clock_adjustpower"])
		var/amount = tgui_input_number(usr, "Adjust the amount of power required before summoning Ratvar", "Power Adjustment", 50000)
		if(amount > 0)
			var/datum/game_mode/gamemode = SSticker.mode
			var/old = gamemode.clocker_objs.power_goal
			gamemode.clocker_objs.power_goal = amount
			message_admins("Admin [key_name_admin(usr)] has modified the amount of clock cult power required before summoning from [old] to [amount]")
			log_admin("Admin [key_name_admin(usr)] has modified the amount of clock cult power required before summoning from [old] to [amount]")

	else if(href_list["clock_adjustbeacon"])
		var/amount = tgui_input_number(usr, "Adjust the amount of beacon required before summoning Ratvar", "Beacon Adjustment", 10)
		if(amount > 0)
			var/datum/game_mode/gamemode = SSticker.mode
			var/old = gamemode.clocker_objs.beacon_goal
			gamemode.clocker_objs.beacon_goal = amount
			message_admins("Admin [key_name_admin(usr)] has modified the amount of clock cult beacon required before summoning from [old] to [amount]")
			log_admin("Admin [key_name_admin(usr)] has modified the amount of clock cult beacon required before summoning from [old] to [amount]")

	else if(href_list["clock_adjustclocker"])
		var/amount = tgui_input_number(usr, "Adjust the amount of clockers required before summoning Ratvar", "Clockers Adjustment", 10)
		if(amount > 0)
			var/datum/game_mode/gamemode = SSticker.mode
			var/old = gamemode.clocker_objs.clocker_goal
			gamemode.clocker_objs.clocker_goal = amount
			message_admins("Admin [key_name_admin(usr)] has modified the amount of clock cult clocker required before summoning from [old] to [amount]")
			log_admin("Admin [key_name_admin(usr)] has modified the amount of clock cult clocker required before summoning from [old] to [amount]")

	else if(href_list["clock_newsummonlocations"])
		if(tgui_alert(usr, "Reroll the Clock cult's summoning locations?", "Clock Cult Debug", list("Yes", "No")) != "Yes")
			return

		var/datum/game_mode/gamemode = SSticker.mode
		gamemode.clocker_objs.obj_summon.find_summon_locations(TRUE)
		if(gamemode.clocker_objs.clock_status == RATVAR_NEEDS_SUMMONING) //Only update cultists if they are already have the summon goal since they arent aware of summon spots till then
			for(var/datum/mind/clock_mind in gamemode.clockwork_cult)
				if(clock_mind && clock_mind.current)
					to_chat(clock_mind.current, "<span class='cult'>The veil has shifted! Our summoning will need to take place elsewhere.</span>")
					to_chat(clock_mind.current, "<span class='cult'>Current goal : [gamemode.clocker_objs.obj_summon.explanation_text]</span>")

		message_admins("Admin [key_name_admin(usr)] has rerolled the Clock Cult's sacrifice target.")
		log_admin("Admin [key_name_admin(usr)] has rerolled the Clock Cult's sacrifice target.")

	else if(href_list["clock_unlockratvar"])
		if(tgui_alert(usr, "Unlock the ability to summon Ratvar?", "Clock Cult Debug", list("Yes", "No")) != "Yes")
			return

		SSticker.mode.clocker_objs.ratvar_is_ready()
		message_admins("Admin [key_name_admin(usr)] has unlocked the Clock Cult's ability to summon Ratvar.")
		log_admin("Admin [key_name_admin(usr)] has unlocked the Clock Cult's ability to summon Ratvar.")

	else if(href_list["adminplayerobservecoodjump"])
		if(!check_rights(R_ADMIN))	return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		var/client/C = usr.client
		if(!isobserver(usr))	C.admin_ghost()
		sleep(2)
		C.jumptocoord(x,y,z)

	else if(href_list["adminchecklaws"])
		output_ai_laws()

	else if(href_list["adminmoreinfo"])
		var/mob/M = locateUID(href_list["adminmoreinfo"])

		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return

		admin_mob_info(M)

	else if(href_list["adminspawncookie"])
		if(!check_rights(R_ADMIN|R_EVENT))	return

		var/mob/living/carbon/human/H = locateUID(href_list["adminspawncookie"])
		if(!ishuman(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>", confidential=TRUE)
			return

		H.equip_to_slot_or_del( new /obj/item/reagent_containers/food/snacks/cookie(H), ITEM_SLOT_HAND_LEFT )
		if(!(istype(H.l_hand,/obj/item/reagent_containers/food/snacks/cookie)))
			H.equip_to_slot_or_del( new /obj/item/reagent_containers/food/snacks/cookie(H), ITEM_SLOT_HAND_RIGHT )
			if(!(istype(H.r_hand,/obj/item/reagent_containers/food/snacks/cookie)))
				log_admin("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
				message_admins("[key_name_admin(H)] has [H.p_their()] hands full, so [H.p_they()] did not receive [H.p_their()] cookie, spawned by [key_name_admin(src.owner)].")
				return
			else
				H.update_inv_r_hand()//To ensure the icon appears in the HUD
		else
			H.update_inv_l_hand()
		log_admin("[key_name(H)] got their cookie, spawned by [key_name(src.owner)]")
		message_admins("[key_name_admin(H)] got [H.p_their()] cookie, spawned by [key_name_admin(src.owner)]")
		SSblackbox.record_feedback("amount", "admin_cookies_spawned", 1)
		to_chat(H, "<span class='notice'>Your prayers have been answered!! You received the <b>best cookie</b>!</span>")

	else if(href_list["BlueSpaceArtillery"])
		if(!check_rights(R_ADMIN|R_EVENT))	return

		var/mob/living/M = locateUID(href_list["BlueSpaceArtillery"])
		usr.client.bluespace_artillery(M)

	else if(href_list["CentcommReply"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["CentcommReply"])

		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return

		usr.client.admin_headset_message(M, "Centcomm")

	else if(href_list["SyndicateReply"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["SyndicateReply"])

		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return

		usr.client.admin_headset_message(M, "Syndicate")

	else if(href_list["HeadsetMessage"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["HeadsetMessage"])

		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return

		usr.client.admin_headset_message(M)

	else if(href_list["EvilFax"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/living/carbon/human/H = locateUID(href_list["EvilFax"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>", confidential=TRUE)
			return
		var/etypes = list("Borgification", "Corgification", "Death By Fire", "Total Brain Death", "Honk Tumor", "Cluwne", "Demote", "Demote with Bot", "Revoke Fax Access", "Angry Fax Machine")
		var/eviltype = tgui_input_list(src.owner, "Which type of evil fax do you wish to send [H]?", "Its good to be baaaad...", etypes)
		if(!(eviltype in etypes))
			return
		var/customname = tgui_input_text(owner, "Pick a title for the evil fax.", "Fax Title",)
		if(!customname)
			customname = "paper"
		var/obj/item/paper/evilfax/P = new /obj/item/paper/evilfax(null)
		var/obj/machinery/photocopier/faxmachine/fax = locate(href_list["originfax"])

		P.name = "Central Command - [customname]"
		P.info = "<b>You <i>really</i> should've known better.</b>"
		P.myeffect = eviltype
		P.mytarget = H
		if(tgui_alert(usr, "Do you want the Evil Fax to activate automatically if [H] tries to ignore it?",, list("Yes", "No")) == "Yes")
			P.activate_on_timeout = 1
		P.stamp(/obj/item/stamp/centcom)
		P.faxmachineid = fax.UID()
		P.forceMove(fax.loc)  // Do not use fax.receivefax(P) here, as it won't preserve the type. Physically teleporting the fax paper is required.
		if(istype(H) && H.stat == CONSCIOUS && (istype(H.l_ear, /obj/item/radio/headset) || istype(H.r_ear, /obj/item/radio/headset)))
			to_chat(H, "<span class='specialnoticebold'>Your headset pings, notifying you that a reply to your fax has arrived.</span>")
		to_chat(src.owner, "You sent a [eviltype] fax to [H]")
		log_admin("[key_name(src.owner)] sent [key_name(H)] a [eviltype] fax")
		message_admins("[key_name_admin(src.owner)] replied to [key_name_admin(H)] with a [eviltype] fax")
	else if(href_list["Bless"])
		if(!check_rights(R_EVENT))
			return
		var/mob/living/M = locateUID(href_list["Bless"])
		if(!istype(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living</span>", confidential=TRUE)
			return
		usr.client.bless(M)
	else if(href_list["Smite"])
		if(!check_rights(R_EVENT))
			return
		var/mob/living/M = locateUID(href_list["Smite"])
		if(!istype(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living</span>", confidential=TRUE)
			return
		usr.client.smite(M)
	else if(href_list["cryossd"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/living/carbon/human/H = locateUID(href_list["cryossd"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>", confidential=TRUE)
			return
		if(!href_list["cryoafk"] && !isLivingSSD(H))
			to_chat(usr, "<span class='warning'>This can only be used on living, SSD players.</span>", confidential=TRUE)
			return
		if(istype(H.loc, /obj/machinery/cryopod))
			var/obj/machinery/cryopod/P = H.loc
			P.despawn_occupant()
			log_admin("[key_name(usr)] despawned [H.job] [H] in cryo.")
			message_admins("[key_name_admin(usr)] despawned [H.job] [H] in cryo.")
		else if(cryo_ssd(H))
			log_admin("[key_name(usr)] sent [H.job] [H] to cryo.")
			message_admins("[key_name_admin(usr)] sent [H.job] [H] to cryo.")
			if(href_list["cryoafk"]) // Warn them if they are send to storage and are AFK
				to_chat(H, "<span class='danger'>The admins have moved you to cryo storage for being AFK. Please eject yourself (right click, eject) out of the cryostorage if you want to avoid being despawned.</span>")
				SEND_SOUND(H, 'sound/effects/adminhelp.ogg')
				if(H.client)
					window_flash(H.client)
	else if(href_list["FaxReplyTemplate"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/living/carbon/human/H = locateUID(href_list["FaxReplyTemplate"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>", confidential=TRUE)
			return
		var/obj/item/paper/P = new /obj/item/paper(null)
		var/obj/machinery/photocopier/faxmachine/fax = locate(href_list["originfax"])
		P.name = "Центральное командование - paper"
		var/stypes = list("Разберитесь с этим сами!","Неразборчивый факс","Факс не подписан","Не сейчас","Вы напрасно тратите наше время", "Продолжайте в том же духе", "Инструкции ОБР")
		var/stype = tgui_input_list(src.owner, "Какой тип заготовленного письма вы хотите отправить [H]?", "Выберите этот документ", stypes)
		var/tmsg = "<span style='font-face: \"Verdana\"; color: black;'><center><img src = 'ntlogo.png'><br><br><br><span style='font-size: 4;'><b>Научная станция NanoTrasen [SSmapping.map_datum.station_short]</b></span><br><br><br><span style='font-size: 4;'>Отчет отдела коммуникаций АКН 'Трурль'</span></center><br><br>"
		if(stype == "Разберитесь с этим сами!")
			tmsg += "Приветствую вас, уважаемый член экипажа. Ваш факс был <b><i>ОТКЛОНЁН</i></b> автоматически службой регистрации факсов АКН 'Трурль'.<br><br>Пожалуйста, действуйте в соответствии со Стандартными Рабочими Процедурами и/или Космическим Законом. Вы полностью обучены справляться с данной ситуацией без вмешательства Центрального Командования.<br><br><i><small>Это автоматическое сообщение.</small>"
		else if(stype == "Неразборчивый факс")
			tmsg += "Приветствую вас, уважаемый член экипажа. Ваш факс был <b><i>ОТКЛОНЁН</i></b> автоматически службой регистрации факсов АКН 'Трурль'.<br><br>Грамматика, синтаксис и/или типография вашего факса находятся на низком уровне и не позволяют нам понять содержание сообщения.<br><br>Пожалуйста, обратитесь к ближайшему словарю и/или тезаурусу и повторите попытку.<br><br><i><small>Это автоматическое сообщение.</small>"
		else if(stype == "Факс не подписан")
			tmsg += "Приветствую вас, уважаемый член экипажа. Ваш факс был <b><i>ОТКЛОНЁН</i></b> автоматически службой регистрации факсов АКН 'Трурль'.<br><br>Ваш факс был неправильно подписан, и поэтому мы не можем подтвердить вашу личность.<br><br>Пожалуйста, подпишите свои факсы перед их отправкой, чтобы мы могли вас идентифицировать.<br><br><i><small>Это автоматическое сообщение.</small>"
		else if(stype == "Не сейчас")
			tmsg += "Приветствую вас, уважаемый член экипажа. Ваш факс был <b><i>ОТКЛОНЁН</i></b> автоматически службой регистрации факсов АКН 'Трурль'.<br><br>Из-за неотложных проблем, связанных с вопросом, превышающим ваш текущий уровень оплаты, мы не можем оказать помощь по любому вопросу, на который ссылается ваш факс.<br><br>Это может быть связано с отключением электроэнергии, бюрократическим аудитом, распространением вредителей, 'Восхождением', быстрым ростом популяции корги или любой другой ситуацией, которая может повлиять на надлежащее функционирование АКН 'Трурль'.<br><br>Пожалуйста, повторите попытку позднее.<br><br><i><small>Это автоматическое сообщение.</small>"
		else if(stype == "Вы напрасно тратите наше время")
			tmsg += "Приветствую вас, уважаемый член экипажа. Ваш факс был <b><i>ОТКЛОНЁН</i></b> автоматически службой регистрации факсов АКН 'Трурль'.<br><br>В интересах предотвращения дальнейшего нерационального использования ресурсов компании, пожалуйста, не тратьте наше время на такую мелкую чушь.<br><br>Пожалуйста, помните, что мы ожидаем, что наши сотрудники будут поддерживать, по крайней мере, полу-достойный уровень профессионализма. Не испытывайте наше терпение.<br><br><i><small>Это автоматическое сообщение.</i></small>"
		else if(stype == "Продолжайте в том же духе")
			tmsg += "Приветствую вас, уважаемый член экипажа. Ваш факс был успешно получено службой регистрации факсов АКН 'Трурль'.<br><br>Мы в АКН 'Трурль' искренне ценим хорошую работу, которую вы здесь проделали, и искренне рекомендуем вам продолжать демонстрировать такую преданность компании.<br><br><i><small>Это точно не автоматическое сообщение.</i></small>"
		else if(stype == "Инструкции ОБР")
			tmsg += "Приветствую вас, уважаемый член экипажа. Ваш факс был <b><i>ОТКЛОНЁН</i></b> автоматически службой регистрации факсов АКН 'Трурль'.<br><br>Пожалуйста, используйте карту, если вы хотите вызвать ОБР.<br><br><i><small>Это автоматическое сообщение.</i></small>"
		else
			return
		tmsg += "</span>"
		P.info = tmsg
		P.stamp(/obj/item/stamp/centcom)
		fax.receivefax(P)
		if(istype(H) && H.stat == CONSCIOUS && (istype(H.l_ear, /obj/item/radio/headset) || istype(H.r_ear, /obj/item/radio/headset)))
			to_chat(H, "<span class='specialnoticebold'>Your headset pings, notifying you that a reply to your fax has arrived.</span>")
		to_chat(src.owner, "You sent a standard '[stype]' fax to [H]", confidential=TRUE)
		log_admin("[key_name(src.owner)] sent [key_name(H)] a standard '[stype]' fax")
		message_admins("[key_name_admin(src.owner)] replied to [key_name_admin(H)] with a standard '[stype]' fax")

	else if(href_list["HONKReply"])
		var/mob/living/carbon/human/H = locateUID(href_list["HONKReply"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>", confidential=TRUE)
			return
		if(!istype(H.l_ear, /obj/item/radio/headset) && !istype(H.r_ear, /obj/item/radio/headset))
			to_chat(usr, "<span class='warning'>The person you are trying to contact is not wearing a headset</span>", confidential=TRUE)
			return

		var/input = tgui_input_text(src.owner, "Please enter a message to reply to [key_name(H)] via [H.p_their()] headset.", "Outgoing message from HONKplanet", "", encode = FALSE)
		if(!input)	return

		to_chat(src.owner, "You sent [input] to [H] via a secure channel.", confidential=TRUE)
		log_admin("[src.owner] replied to [key_name(H)]'s HONKplanet message with the message [input].")
		to_chat(H, "You hear something crackle in your headset for a moment before a voice speaks.  \"Please stand by for a message from your HONKbrothers.  Message as follows, HONK. [input].  Message ends, HONK.\"")

	else if(href_list["ErtReply"])
		if(!check_rights(R_ADMIN))
			return

		if(tgui_alert(src.owner, "Accept or Deny ERT request?", "CentComm Response", list("Accept", "Deny")) == "Deny")
			var/mob/living/carbon/human/H = locateUID(href_list["ErtReply"])
			if(!istype(H))
				to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>", confidential=TRUE)
				return
			if(H.stat != 0)
				to_chat(usr, "<span class='warning'>The person you are trying to contact is not conscious.</span>", confidential=TRUE)
				return
			if(!istype(H.l_ear, /obj/item/radio/headset) && !istype(H.r_ear, /obj/item/radio/headset))
				to_chat(usr, "<span class='warning'>The person you are trying to contact is not wearing a headset</span>", confidential=TRUE)
				return

			var/input = tgui_input_text(src.owner, "Please enter a reason for denying [key_name(H)]'s ERT request.","Outgoing message from CentComm", "", encode = FALSE)
			if(!input)	return
			GLOB.ert_request_answered = TRUE
			to_chat(src.owner, "You sent [input] to [H] via a secure channel.", confidential=TRUE)
			log_admin("[src.owner] denied [key_name(H)]'s ERT request with the message [input].")
			to_chat(H, "<span class='specialnoticebold'>Incoming priority transmission from Central Command. Message as follows,</span><span class='specialnotice'> Your ERT request has been denied for the following reasons: [input].</span>")
		else
			src.owner.response_team()


	else if(href_list["AdminFaxView"])
		if(!check_rights(R_ADMIN))
			return

		var/obj/item/fax = locate(href_list["AdminFaxView"])
		if(istype(fax, /obj/item/paper))
			var/obj/item/paper/P = fax
			P.show_content(usr,1)
		else if(istype(fax, /obj/item/photo))
			var/obj/item/photo/H = fax
			H.show(usr)
		else if(istype(fax, /obj/item/paper_bundle))
			//having multiple people turning pages on a paper_bundle can cause issues
			//open a browse window listing the contents instead
			var/data = ""
			var/obj/item/paper_bundle/bundle = fax

			for(var/page = 1 to length(bundle.papers))
				var/obj/pageobj = bundle.papers[page]
				data += "<a href='byond://?src=[UID()];AdminFaxViewPage=[page];paper_bundle=\ref[bundle]'>Page [page] - [pageobj.name]</a><br>"

			var/datum/browser/popup = new(usr, "PaperBundle[bundle.UID()]", "Fax View")
			popup.include_default_stylesheet = FALSE
			popup.set_content(data)
			popup.open(FALSE)
		else
			to_chat(usr, "<span class='warning'>The faxed item is not viewable. This is probably a bug, and should be reported on the tracker: [fax.type]</span>", confidential=TRUE)

	else if(href_list["AdminFaxViewPage"])
		if(!check_rights(R_ADMIN))
			return

		var/page = text2num(href_list["AdminFaxViewPage"])
		var/obj/item/paper_bundle/bundle = locate(href_list["paper_bundle"])

		if(!bundle) return

		if(istype(bundle.papers[page], /obj/item/paper))
			var/obj/item/paper/P = bundle.papers[page]
			P.show_content(usr, 1)
		else if(istype(bundle.papers[page], /obj/item/photo))
			var/obj/item/photo/H = bundle.papers[page]
			H.show(usr)
		return

	else if(href_list["AdminFaxCreate"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/sender = locate(href_list["AdminFaxCreate"])
		var/obj/machinery/photocopier/faxmachine/fax = locate(href_list["originfax"])
		var/faxtype = href_list["faxtype"]
		var/reply_to = locate(href_list["replyto"])
		var/destination
		var/notify
		var/obj/item/paper/P
		var/use_letterheard = tgui_alert(usr, "Use letterhead? If so, do not add your own header or a footer. Type and format only your actual message.",, list("Yes", "No"))
		switch(use_letterheard)
			if("Yes")
				var/choose_letterheard = tgui_alert(usr, "Which style of header and footer do you want to use?",, list("Nanotrasen", "Syndicate", "USSP"))
				switch(choose_letterheard)
					if("Nanotrasen")
						P = new /obj/item/paper/central_command(null)
					if("Syndicate")
						P = new /obj/item/paper/syndicate(null)
					if("USSP")
						P = new /obj/item/paper/ussp(null)
			if("No")
				P = new /obj/item/paper(null)
		if(!fax)
			var/list/departmentoptions = GLOB.alldepartments + GLOB.hidden_departments + "All Departments"
			destination = tgui_input_list(usr, "To which department?", "Choose a department", departmentoptions)
			if(!destination)
				qdel(P)
				return

			for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
				if(destination != "All Departments" && F.department == destination)
					fax = F


		var/input = tgui_input_text(src.owner, "Please enter a message to send a fax via secure connection. Use <br> for line breaks. Both pencode and HTML work.", "Outgoing message from Centcomm", "", multiline = TRUE, encode = FALSE)
		if(!input)
			qdel(P)
			return
		input = admin_pencode_to_html(html_encode(input)) // Encode everything from pencode to html

		var/customname = tgui_input_text(owner, "Pick a title for the fax.", "Fax Title")
		if(!customname)
			customname = "paper"

		var/stampname
		var/stamptype
		var/stampvalue
		var/sendername
		switch(faxtype)
			if("Central Command")
				stamptype = "icon"
				stampvalue = "cent"
				sendername = command_name()
			if("Syndicate")
				stamptype = "icon"
				stampvalue = "syndicate"
				sendername = "UNKNOWN"
			if("USSP Central Committee")
				stamptype = "icon"
				stampvalue = "ussp"
				sendername = "Первый секретарь народного комиссара космических станций и планетоидов СССП"
			if("Administrator")
				stamptype = tgui_input_list(src.owner, "Pick a stamp type.", "Stamp Type", list("icon", "text", "none"))
				if(stamptype == "icon")
					stampname = tgui_input_list(src.owner, "Pick a stamp icon.", "Stamp Icon", list("centcom", "syndicate", "granted", "denied", "clown", "ussp"))
					switch(stampname)
						if("centcom")
							stampvalue = "cent"
						if("syndicate")
							stampvalue = "syndicate"
						if("granted")
							stampvalue = "ok"
						if("denied")
							stampvalue = "deny"
						if("clown")
							stampvalue = "clown"
						if("ussp")
							stampvalue = "ussp"
				else if(stamptype == "text")
					stampvalue = tgui_input_text(owner, "What should the stamp say?", "Stamp Text")
				else if(stamptype == "none")
					stamptype = ""
				else
					qdel(P)
					return

				sendername = tgui_input_text(owner, "What organization does the fax come from? This determines the prefix of the paper (i.e. Central Command- Title). This is optional.", "Organization",)

		if(sender)
			notify = tgui_alert(src.owner, "Would you like to inform the original sender that a fax has arrived?", "Notify Sender", list("Yes", "No"))

		// Create the reply message
		if(sendername)
			P.name = "[sendername]- [customname]"
		else
			P.name = "[customname]"
		P.info = input
		P.update_icon(UPDATE_ICON_STATE)
		if(stamptype == "icon")
			P.stamp(/obj/item/stamp/centcom, special_stamped = "<img src=large_stamp-[stampvalue].png>", special_icon_state = "stamp-[stampvalue]")
		else if(stamptype == "text")
			P.stamp(/obj/item/stamp, special_stamped = "<i>[stampvalue]</i>", special_icon_state = "stamp-[stampvalue]")

		if(destination != "All Departments")
			if(!fax.receivefax(P))
				to_chat(src.owner, "<span class='warning'>Message transmission failed.</span>", confidential=TRUE)
				return
		else
			for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
				if(is_station_level(F.z))
					spawn(0)
						if(!F.receivefax(P))
							to_chat(src.owner, "<span class='warning'>Message transmission to [F.department] failed.</span>", confidential=TRUE)

		var/datum/fax/admin/A = new /datum/fax/admin()
		A.name = P.name
		A.from_department = faxtype
		if(destination != "All Departments")
			A.to_department = fax.department
		else
			A.to_department = "All Departments"
		A.origin = "Administrator"
		A.message = P
		A.reply_to = reply_to
		A.sent_by = usr
		A.sent_at = world.time

		to_chat(src.owner, "<span class='notice'>Message transmitted successfully.</span>", confidential=TRUE)
		if(notify == "Yes")
			var/mob/living/carbon/human/H = sender
			if(istype(H) && H.stat == CONSCIOUS && (istype(H.l_ear, /obj/item/radio/headset) || istype(H.r_ear, /obj/item/radio/headset)))
				to_chat(sender, "<span class='specialnoticebold'>Your headset pings, notifying you that a reply to your fax has arrived.</span>", confidential=TRUE)
		if(sender)
			log_admin("[key_name(src.owner)] replied to a fax message from [key_name(sender)]: [input]")
			message_admins("[key_name_admin(src.owner)] replied to a fax message from [key_name_admin(sender)] (<a href='byond://?_src_=holder;AdminFaxView=\ref[P]'>VIEW</a>).")
		else
			log_admin("[key_name(src.owner)] sent a fax message to [destination]: [input]")
			message_admins("[key_name_admin(src.owner)] sent a fax message to [destination] (<a href='byond://?_src_=holder;AdminFaxView=\ref[P]'>VIEW</a>).")
		return
	else if(href_list["AdminFaxNotify"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/sender = locate(href_list["AdminFaxNotify"])
		var/mob/living/carbon/human/H = sender
		if(istype(H) && H.stat == CONSCIOUS && (istype(H.l_ear, /obj/item/radio/headset) || istype(H.r_ear, /obj/item/radio/headset)))
			to_chat(sender, "<span class = 'specialnoticebold'>Ваши наушники издают гудки, уведомляя вас о получении ответа на ваш факс.</span>")
		return
	else if(href_list["refreshfaxpanel"])
		if(!check_rights(R_ADMIN))
			return

		fax_panel(usr)

	else if(href_list["getplaytimewindow"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locateUID(href_list["getplaytimewindow"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		cmd_mentor_show_exp_panel(M.client)

	else if(href_list["jumpto"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locateUID(href_list["jumpto"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		usr.client.jumptomob(M)

	else if(href_list["getmob"])
		if(!check_rights(R_ADMIN))	return

		if(tgui_alert(usr, "Confirm?", "Message", list("Yes", "No")) != "Yes")	return
		var/mob/M = locateUID(href_list["getmob"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		usr.client.Getmob(M)

	else if(href_list["sendmob"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locateUID(href_list["sendmob"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		usr.client.sendmob(M)

	else if(href_list["narrateto"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locateUID(href_list["narrateto"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		usr.client.cmd_admin_direct_narrate(M)

	else if(href_list["subtlemessage"])
		if(!check_rights(R_EVENT))
			return

		var/mob/M = locateUID(href_list["subtlemessage"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		usr.client.cmd_admin_subtle_message(M)

	else if(href_list["traitor"])
		if(!check_rights(R_ADMIN|R_MOD))	return

		if(!SSticker || !SSticker.mode)
			tgui_alert(usr, "The game hasn't started yet!")
			return

		var/mob/M = locateUID(href_list["traitor"])
		if(!istype(M, /mob))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>", confidential=TRUE)
			return
		show_traitor_panel(M)

	else if(href_list["create_object"])
		if(!check_rights(R_SPAWN))	return
		return create_object(usr)

	else if(href_list["quick_create_object"])
		if(!check_rights(R_SPAWN))	return
		return quick_create_object(usr)

	else if(href_list["create_turf"])
		if(!check_rights(R_SPAWN))	return
		return create_turf(usr)

	else if(href_list["create_mob"])
		if(!check_rights(R_SPAWN))	return
		return create_mob(usr)

	else if(href_list["dupe_marked_datum"])
		if(!check_rights(R_SPAWN))	return
		return DuplicateObject(marked_datum, perfectcopy=1, newloc=get_turf(usr))

	else if(href_list["object_list"])			//this is the laggiest thing ever
		if(!check_rights(R_SPAWN))	return

		var/atom/loc = usr.loc

		var/dirty_paths
		if(istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if(istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				continue
			paths += path

		if(!paths)
			tgui_alert(usr, "The path list you sent is empty")
			return
		if(length(paths) > 5)
			tgui_alert(usr, "Select fewer object types, (max 5)")
			return

		var/list/offset = splittext(href_list["offset"],",")
		var/number = dd_range(1, 100, text2num(href_list["object_count"]))
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/tmp_dir = href_list["object_dir"]
		var/obj_dir = tmp_dir ? text2num(tmp_dir) : 2
		if(!obj_dir || !(obj_dir in list(1,2,4,8,5,6,9,10)))
			obj_dir = 2
		var/obj_name = sanitize(href_list["object_name"])


		var/atom/target //Where the object will be spawned
		var/where = href_list["object_where"]
		if(!( where in list("onfloor","frompod","inhand","inmarked")))
			where = "onfloor"


		switch(where)

			if("inhand")
				if(!iscarbon(usr) && !isrobot(usr))
					to_chat(usr, "<span class='warning'>Can only spawn in hand when you're a carbon mob or cyborg.</span>", confidential=TRUE)
					where = "onfloor"
				target = usr

			if("onfloor", "frompod")
				switch(href_list["offset_type"])
					if("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if("inmarked")
				if(!marked_datum)
					to_chat(usr, "<span class='warning'>You don't have any object marked. Abandoning spawn.</span>", confidential=TRUE)
					return
				else if(!istype(marked_datum,/atom))
					to_chat(usr, "<span class='warning'>The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn.</span>", confidential=TRUE)
					return
				else
					target = marked_datum

		var/obj/structure/closet/supplypod/centcompod/pod

		if(target)
			if(where == "frompod")
				pod = new()
			for(var/path in paths)
				for(var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N && obj_name)
							N.name = obj_name
					else
						var/atom/O

						if(where == "frompod")
							O = new path(pod)
						else
							O = new path(target)

						if(O)
							O.flags |= ADMIN_SPAWNED
							O.dir = obj_dir
							if(obj_name)
								O.name = obj_name
								if(istype(O,/mob))
									var/mob/M = O
									M.real_name = obj_name
							if(where == "inhand" && isliving(usr) && isitem(O))
								var/mob/living/L = usr
								var/obj/item/I = O
								L.put_in_hands(I)
								if(isrobot(L))
									var/mob/living/silicon/robot/R = L
									if(R.module)
										R.module.modules += I
										I.loc = R.module
										R.module.rebuild()
										R.activate_module(I)
										R.module.fix_modules()
		if(pod)
			new /obj/effect/pod_landingzone(target, pod)

		if(number == 1)
			log_admin("[key_name(usr)] created a [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob) || ispath(path, /obj))
					message_admins("[key_name_admin(usr)] created a [english_list(paths)]")
					break
		else
			log_admin("[key_name(usr)] created [number]ea [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob) || ispath(path, /obj))
					message_admins("[key_name_admin(usr)] created [number]ea [english_list(paths)]")
					break
		return

	else if(href_list["kick_all_from_lobby"])
		if(!check_rights(R_ADMIN))
			return
		if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
			var/afkonly = text2num(href_list["afkonly"])
			if(tgui_alert(usr, "Are you sure you want to kick all [afkonly ? "AFK" : ""] clients from the lobby?", "Confirmation", list("Yes", "Cancel")) != "Yes")
				return
			var/list/listkicked = kick_clients_in_lobby("<span class='danger'>You were kicked from the lobby by an Administrator.</span>", afkonly)

			var/strkicked = ""
			for(var/name in listkicked)
				strkicked += "[name], "
			message_admins("[key_name_admin(usr)] has kicked [afkonly ? "all AFK" : "all"] clients from the lobby. [length(listkicked)] clients kicked: [strkicked ? strkicked : "--"]")
			log_admin("[key_name(usr)] has kicked [afkonly ? "all AFK" : "all"] clients from the lobby. [length(listkicked)] clients kicked: [strkicked ? strkicked : "--"]")
		else
			to_chat(usr, "<span class='warning'>You may only use this when the game is running.</span>", confidential=TRUE)

	else if(href_list["memoeditlist"])
		if(!check_rights(R_SERVER)) return
		var/sql_key = href_list["memoeditlist"]
		var/datum/db_query/query_memoedits = SSdbcore.NewQuery("SELECT edits FROM [CONFIG_GET(string/utility_database)].[format_table_name("memo")] WHERE (ckey=:sql_key)", list(
			"sql_key" = sql_key
		))
		if(!query_memoedits.warn_execute())
			qdel(query_memoedits)
			return
		if(query_memoedits.NextRow())
			var/edit_log = query_memoedits.item[1]
			var/datum/browser/popup = new(usr, "memoeditlist", "Memo Edit")
			popup.set_content(edit_log)
			popup.open(FALSE)

		qdel(query_memoedits)

	else if(href_list["secretsfun"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		var/ok = 0
		switch(href_list["secretsfun"])
			if("sec_clothes")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Remove 'internal' clothing")
				for(var/obj/item/clothing/under/O in world)
					qdel(O)
				ok = 1
			if("sec_all_clothes")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Remove ALL clothing")
				for(var/obj/item/clothing/O in world)
					qdel(O)
				ok = 1
			if("sec_classic1")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Remove firesuits, grilles, and pods")
				for(var/obj/item/clothing/suit/fire/O in world)
					qdel(O)
				for(var/obj/structure/grille/O in world)
					qdel(O)
			if("monkey")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Monkeyize All Humans")
				for(var/thing in GLOB.human_list)
					var/mob/living/carbon/human/H = thing
					spawn(0)
						H.monkeyize()
				ok = 1
			if("corgi")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Corgize All Humans")
				for(var/thing in GLOB.human_list)
					var/mob/living/carbon/human/H = thing
					spawn(0)
						H.corgize()
				ok = 1
			if("honksquad")
				if(usr.client.honksquad())
					SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Team - HONKsquad")
			if("striketeam")
				if(usr.client.strike_team())
					SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Team - Deathsquad")
			if("striketeam_syndicate")
				if(usr.client.syndicate_strike_team())
					SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Team - Syndie Strike Team")
			if("infiltrators_syndicate")
				if(usr.client.syndicate_infiltration_team())
					SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Team - Syndicate Infiltration Team")
			if("gimmickteam")
				if(usr.client.gimmick_team())
					SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Team - Gimmick Team")
			if("customportal")
				if(!check_rights(R_EVENT))
					return

				var/list/settings = list(
					"mainsettings" = list(
					"typepath" = list("desc" = "Тип мобов для спавна", "type" = "datum", "path" = "/mob/living", "subtypesonly" = TRUE, "value" = /mob/living/simple_animal/hostile/poison/bees),
					"amount" = list("desc" = "Число мобов", "type" = "number", "value" = 1),
					"portalnum" = list("desc" = "Число порталов", "type" = "number", "value" = 10),
					"delay" = list("desc" = "Время между порталами(в децесекундах)", "type" = "number", "value" = 50),
					"color" = list("desc" = "Цвет портала", "type" = "color", "value" = "#00FF00"),
					"playlightning" = list("desc" = "Проигрывать звук молнии при оповещении", "type" = "boolean", "value" = "Да"),
					"announce_players" = list("desc" = "Делать оповещении", "type" = "boolean", "value" = "Да"),
					"announcement" = list("desc" = "Оповещение", "type" = "string", "value" = "Массивная блюспейс аномалия зафиксирована вблизи станции %STATION%. Готовьтесь к худшему."),
					)
				)

				message_admins("[key_name(usr)] is creating a custom portal storm...")
				var/list/prefreturn = presentpreflikepicker(usr,"Настройка портального шторма", "Настройка портального шторма", Button1="Старт", width = 600, StealFocus = 1,Timeout = 0, settings=settings)

				if (prefreturn["button"] == 1)
					var/list/prefs = settings["mainsettings"]

					if (prefs["amount"]["value"] < 1 || prefs["portalnum"]["value"] < 1)
						to_chat(usr, "Число порталов для спавна должно быть минимум 1")
						return

					var/pathToSpawn = prefs["typepath"]["value"]
					if (!ispath(pathToSpawn))
						pathToSpawn = text2path(pathToSpawn)

					if (!ispath(pathToSpawn))
						to_chat(usr, "Некорректный тип [pathToSpawn]")
						return

					if (prefs["announce_players"]["value"] == "Да")
						portalAnnounce(prefs["announcement"]["value"], (prefs["playlightning"]["value"] == "Да" ? TRUE : FALSE))

					var/mutable_appearance/storm = mutable_appearance('icons/obj/stationobjs.dmi', "portal-projector0", FLY_LAYER)
					storm.color = prefs["color"]["value"]

					log_and_message_admins("has created a customized portal storm that will spawn [prefs["portalnum"]["value"]] portals, each of them spawning [prefs["amount"]["value"]] of [pathToSpawn]")

					for (var/i in 1 to prefs["portalnum"]["value"])
						var/turf/turf = get_random_station_turf()
						while(iswallturf(turf))
							turf = get_random_station_turf()
						addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(doPortalSpawn), turf, pathToSpawn, prefs["amount"]["value"], storm), i*prefs["delay"]["value"])

			if("tripleAI")
				usr.client.triple_ai()
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Triple AI")

			if("mass_mindswap")
				mass_mindswap()

			if("set_station_name")
				if(!check_rights(R_ADMIN | R_EVENT))
					return

				if(!you_realy_want_do_this())
					return

				var/new_name = tgui_input_text(usr, "Пожалуйста, введите новое название станции.", "Что?", "", encode = FALSE)
				if(!new_name)
					return
				change_station_name(new_name)
				log_and_message_admins("renamed the station to: [new_name].")
				GLOB.event_announcement.Announce("Решением [command_name()] станция переименована в \"[new_name]\".")

			if("set_centcomm_name")
				if(!check_rights(R_ADMIN | R_EVENT))
					return
				if(!you_realy_want_do_this())
					return
				usr.client.cmd_change_command_name()

			if("reset_station_name")
				if(!check_rights(R_ADMIN))
					return
				if(!you_realy_want_do_this())
					return
				var/new_name = new_station_name()
				change_station_name(new_name)
				log_and_message_admins("reset the station name.</span>")
				GLOB.event_announcement.Announce("Решением [command_name()] станция переименована в \"[new_name]\".")

			if("gravity")
				if(!(SSticker && SSticker.mode))
					to_chat(usr, "<span class='warning'>Please wait until the game starts! Not sure how it will work otherwise.</span>", confidential=TRUE)
					return

				var/static/list/gravity_states = list(
					"Default Gravity Handling",
					"Enable Gravity Globally",
					"Disable Gravity Globally",
				)
				var/gravity_state = tgui_input_list(usr, "Enable or disable global gravity state", "Global Gravity State", gravity_states)
				if(!gravity_state)
					return

				var/gravity_announce = tgui_input_text(usr, "Do you wish to make any global announcement?", "Announcement Text", encode = FALSE)
				if(gravity_announce)
					GLOB.event_announcement.Announce("[gravity_announce]")

				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Gravity")

				switch(gravity_state)
					if("Default Gravity Handling")
						GLOB.gravity_is_on = null
						log_and_message_admins("returned global gravity state to default.")
					if("Enable Gravity Globally")
						GLOB.gravity_is_on = TRUE
						log_and_message_admins("toggled global gravity ON.")
					if("Disable Gravity Globally")
						GLOB.gravity_is_on = FALSE
						log_and_message_admins("toggled global gravity OFF.")

				for(var/area/area as anything in GLOB.areas)
					area.gravitychange()

			if("power")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Power All APCs")
				log_and_message_admins("<span class='notice'>made all areas powered</span>")
				power_restore()
			if("unpower")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Depower All APCs")
				log_and_message_admins("<span class='notice'>made all areas unpowered</span>")
				power_failure()
			if("quickpower")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Power All SMESs")
				log_and_message_admins("<span class='notice'>made all SMESs powered</span>")
				power_restore_quick()

			if("prisonwarp")
				if(!SSticker)
					tgui_alert(usr, "The game hasn't started yet!")
					return
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Prison Warp")
				log_and_message_admins("teleported all players to the prison station.")
				for(var/mob/living/carbon/human/human as anything in GLOB.human_list)
					var/turf/loc = get_turf(human)
					var/security = FALSE
					if(!human.client)
						continue
					if(!loc?.z)
						continue
					var/datum/space_level/level = GLOB.space_manager.get_zlev(loc.z)
					if(!(is_station_level(loc.z) || level.name == CENTCOMM) || GLOB.prisonwarped.Find(human)) //don't warp them if they aren't ready or are already there
						continue
					if(human.wear_id)
						var/obj/item/card/id/id = human.get_id_card()
						if(istype(id))
							if(ACCESS_CENT_COMMANDER in id.access)
								continue
							if(ACCESS_SECURITY in id.access)
								security = TRUE
					var/turf/prison_cell = pick((security? GLOB.prisonsecuritywarp : GLOB.prisonwarp))
					if(!prison_cell)
						continue

					var/obj/structure/closet/supplypod/centcompod/prison_warp/pod = new()
					pod.reverse_dropoff_coords = list(prison_cell.x, prison_cell.y, prison_cell.z)
					pod.target = human
					pod.security = security
					new /obj/effect/pod_landingzone(human, pod)

			if("traitor_all")
				if(!SSticker)
					tgui_alert(usr, "The game hasn't started yet!")
					return
				if(!you_realy_want_do_this())
					return
				var/objective_text = sanitize(tgui_input_text(usr, "Enter an objective", encode = FALSE))
				var/datum/objective/objective

				if(objective_text)
					objective = new(objective_text)
					objective.needs_target = FALSE
					objective.antag_menu_name = "Цель предателей"

				if(!objective)
					return

				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Traitor All ([objective])")
				var/datum/antagonist/traitor/antag_datum
				for(var/mob/living/carbon/human/H in GLOB.player_list)
					if(H.stat == 2 || !H.client || !H.mind) continue
					if(is_special_character(H)) continue
					//traitorize(H, objective, 0)
					antag_datum = new
					antag_datum.add_objective(objective)
					H.mind.add_antag_datum(antag_datum)

				for(var/mob/living/silicon/A in GLOB.player_list)
					antag_datum = new
					antag_datum.add_objective(objective)
					A.mind.add_antag_datum(antag_datum)

				log_and_message_admins("<span class='notice'>used everyone is a traitor secret. Objective is [objective]</span>")

			if("togglebombcap")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Bomb Cap")

				var/newBombCap = tgui_input_number(usr, "What would you like the new bomb cap to be. (entered as the light damage range (the 3rd number in common (1,2,3) notation)) Must be between 4 and 128)", "New Bomb Cap", GLOB.max_ex_light_range)
				if(newBombCap < 4)
					return
				if(newBombCap > 128)
					newBombCap = 128

				GLOB.max_ex_devastation_range = round(newBombCap/4)
				GLOB.max_ex_heavy_range = round(newBombCap/2)
				GLOB.max_ex_light_range = newBombCap
				//I don't know why these are their own variables, but fuck it, they are.
				GLOB.max_ex_flash_range = newBombCap
				GLOB.max_ex_flame_range = newBombCap

				message_admins(span_boldannounceooc("[key_name_admin(usr)] changed the bomb cap to [GLOB.max_ex_devastation_range], [GLOB.max_ex_heavy_range], [GLOB.max_ex_light_range]"))
				log_admin("[key_name(usr)] changed the bomb cap to [GLOB.max_ex_devastation_range], [GLOB.max_ex_heavy_range], [GLOB.max_ex_light_range]")

			if("flicklights")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Flicker Lights")
				while(!usr.stat)
//knock yourself out to stop the ghosts
					for(var/mob/M in GLOB.player_list)
						if(M.stat != 2 && prob(25))
							var/area/AffectedArea = get_area(M)
							if(AffectedArea.name != "Space" && AffectedArea.name != "Engine Walls" && AffectedArea.name != "Chemical Lab Test Chamber" && AffectedArea.name != "Escape Shuttle" && AffectedArea.name != "Arrival Area" && AffectedArea.name != "Arrival Shuttle" && AffectedArea.name != "start area" && AffectedArea.name != "Engine Combustion Chamber")
								AffectedArea.power_light = 0
								AffectedArea.power_change()
								spawn(rand(55,185))
									AffectedArea.power_light = 1
									AffectedArea.power_change()
								var/Message = rand(1,4)
								switch(Message)
									if(1)
										M.show_message(text("<span class='notice'>You shudder as if cold...</span>"), 1)
									if(2)
										M.show_message(text("<span class='notice'>You feel something gliding across your back...</span>"), 1)
									if(3)
										M.show_message(text("<span class='notice'>Your eyes twitch, you feel like something you can't see is here...</span>"), 1)
									if(4)
										M.show_message(text("<span class='notice'>You notice something moving out of the corner of your eye, but nothing is there...</span>"), 1)
								for(var/obj/W in orange(5,M))
									if(prob(25) && !W.anchored)
										step_rand(W)
					sleep(rand(100,1000))
				for(var/mob/M in GLOB.player_list)
					if(M.stat != 2)
						M.show_message(text("<span class='notice'>The chilling wind suddenly stops...</span>"), 1)
			if("lightout")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Lights Out")
				log_and_message_admins("has broke a lot of lights")
				var/datum/event/electrical_storm/E = new /datum/event/electrical_storm
				E.lightsoutAmount = 2
			if("blackout")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Black Out")
				log_and_message_admins("broke all lights")
				for(var/obj/machinery/light/L in GLOB.machines)
					L.break_light_tube()
			if("whiteout")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Fix All Lights")
				log_and_message_admins("fixed all lights")
				for(var/obj/machinery/light/L in GLOB.machines)
					L.fix()
					L.switchcount = 0
			if("floorlava")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1,  "Lava Floor")
				SSweather.run_weather(/datum/weather/floor_is_lava)
				message_admins("[key_name_admin(usr)] made the floor lava")
			if("fakelava")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1,  "Lava Floor Fake")
				SSweather.run_weather(/datum/weather/floor_is_lava/fake)
				message_admins("[key_name_admin(usr)] made aesthetic lava on the floor")
			if("weatherashstorm")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1,  "Weather Ash Storm")
				SSweather.run_weather(/datum/weather/ash_storm)
				message_admins("[key_name_admin(usr)] spawned an ash storm on the mining level")
			if("polymorph")
				usr.client.polymorph_all()
			if("stupify")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Mass Braindamage")
				for(var/mob/living/carbon/human/H in GLOB.player_list)
					to_chat(H, "<span class='danger'>You suddenly feel stupid.</span>", confidential=TRUE)
					H.setBrainLoss(60)
				message_admins("[key_name_admin(usr)] made everybody stupid")
			if("fakeguns")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Fake Guns")
				for(var/obj/item/W in world)
					if(isclothing(W) || istype(W, /obj/item/card/id) || istype(W, /obj/item/disk) || istype(W, /obj/item/tank))
						continue
					W.icon = 'icons/obj/weapons/projectile.dmi'
					W.icon_state = "revolver"
					W.item_state = "gun"
				message_admins("[key_name_admin(usr)] made every item look like a gun")
			if("schoolgirl") // nyaa~ How much are you paying attention in reviews?
				if(!check_rights(R_EVENT))
					return

				if(!you_realy_want_do_this())
					return

				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Chinese Cartoons")
				log_and_message_admins("made everything kawaii.")
				for(var/mob/living/carbon/human/human as anything in GLOB.human_list)
					SEND_SOUND(human, 'sound/AI/animes.ogg')
					if(!human.dna.species.nojumpsuit && !isvox(human) && !isplasmaman(human) \
						&& !isshadowling(human) && !isvoxarmalis(human) && !is_space_or_openspace(get_turf(human)))
						var/obj/item/clothing/head/kitty/hat = new
						var/seifuku = pick(typesof(/obj/item/clothing/under/schoolgirl))
						var/obj/item/clothing/under/schoolgirl/uniform = new seifuku
						human.drop_item_ground(human.w_uniform, TRUE, FALSE, TRUE)
						human.equip_to_slot_or_del(uniform, uniform.slot_flags)
						human.drop_item_ground(human.head, TRUE, FALSE, TRUE)
						human.equip_to_slot_or_del(hat, hat.slot_flags)

						ADD_TRAIT(uniform, TRAIT_NODROP, INNATE_TRAIT)
						ADD_TRAIT(hat, TRAIT_NODROP, INNATE_TRAIT)
					var/list/honorifics = list(MALE = list("кун"), FEMALE = list("чан","тан"), NEUTER = list("сан")) //John Robust -> Robust-kun
					var/list/names = splittext(human.real_name," ")
					var/newname = "[names[names.len]]-[pick(honorifics[human.gender])]"
					human.name = newname
					human.real_name = newname

			if("eagles")//
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Egalitarian Station")
				for(var/obj/machinery/door/airlock/W in GLOB.airlocks)
					if(is_station_level(W.z) && !istype(get_area(W), /area/bridge) && !istype(get_area(W), /area/crew_quarters) && !istype(get_area(W), /area/security/prison))
						W.req_access = list()
				message_admins("[key_name_admin(usr)] activated Egalitarian Station mode")
				GLOB.event_announcement.Announce("Активирована блокировка управления шл+юзами. Пожалуйста, воспользуйтесь этим временем, чтобы познакомиться со своими коллегами.", new_sound = 'sound/AI/commandreport.ogg')
			if("onlyone")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Only One")
				usr.client.only_one()
				log_and_message_admins("has triggered HIGHLANDER")
			if("onlyme")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Only Me")
				usr.client.only_me()
			if("onlyoneteam")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Only One Team")
				usr.client.only_one_team()
//				message_admins("[key_name_admin(usr)] has triggered ")
			if("rolldice")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Roll The Dice")
				usr.client.roll_dices()
			if("guns")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Summon Guns")
				var/survivor_probability = 0
				switch(tgui_alert(usr, "Do you want this to create survivors antagonists?", , list("No Antags", "Some Antags", "All Antags!")))
					if("Some Antags")
						survivor_probability = 25
					if("All Antags!")
						survivor_probability = 100

				rightandwrong(SUMMON_GUNS, usr, survivor_probability)
			if("magic")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Summon Magic")
				var/survivor_probability = 0
				switch(tgui_alert(usr, "Do you want this to create survivors antagonists?", , list("No Antags", "Some Antags", "All Antags!")))
					if("Some Antags")
						survivor_probability = 25
					if("All Antags!")
						survivor_probability = 100

				rightandwrong(SUMMON_MAGIC, usr, survivor_probability)
			// The ert armory & tdomereset functions are disabled because they are not needed and the cc is rebuilt.
			/* if("armotyreset")
				var/delete_mobs = alert("Clear all mobs?","Confirm","Yes","No","Cancel")
				if(delete_mobs == "Cancel")
					return
				var/area/ertarmory = locate(/area/centcom/ertarmory)
				if(delete_mobs == "Yes")
					for(var/mob/living/mob in ertarmory)
						qdel(mob) //Clear mobs
				for(var/obj/obj in ertarmory)
					if(!istype(obj,/obj/machinery/camera) && !istype(obj,/obj/machinery/door/poddoor/impassable) && !istype(obj,/obj/machinery/door_control))
						qdel(obj) //Clear objects
				var/area/template = locate(/area/centcom/reset)
				template.copy_contents_to(ertarmory)
				log_admin("[key_name(usr)] reset the ertarmory to default with delete_mobs==[delete_mobs].", 1)
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] reset ertarmory to default with delete_mobs==[delete_mobs].</span>")
			if("armotyreset1")
				var/delete_mobs = alert("Clear all mobs?","Confirm","Yes","No","Cancel")
				if(delete_mobs == "Cancel")
					return
				var/area/ertarmory = locate(/area/centcom/ertarmory)
				if(delete_mobs == "Yes")
					for(var/mob/living/mob in ertarmory)
						qdel(mob) //Clear mobs
				for(var/obj/obj in ertarmory)
					if(!istype(obj,/obj/machinery/camera) && !istype(obj,/obj/machinery/door/poddoor/impassable) && !istype(obj,/obj/machinery/door_control))
						qdel(obj) //Clear objects
				var/area/template = locate(/area/centcom/reset1)
				template.copy_contents_to(ertarmory)
				log_admin("[key_name(usr)] reset the ertarmory to default with delete_mobs==[delete_mobs].", 1)
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] reset ertarmory to default with delete_mobs==[delete_mobs].</span>")
			if("armotyreset2")
				var/delete_mobs = alert("Clear all mobs?","Confirm","Yes","No","Cancel")
				if(delete_mobs == "Cancel")
					return
				var/area/ertarmory = locate(/area/centcom/ertarmory)
				if(delete_mobs == "Yes")
					for(var/mob/living/mob in ertarmory)
						qdel(mob) //Clear mobs
				for(var/obj/obj in ertarmory)
					if(!istype(obj,/obj/machinery/camera) && !istype(obj,/obj/machinery/door/poddoor/impassable) && !istype(obj,/obj/machinery/door_control))
						qdel(obj) //Clear objects
				var/area/template = locate(/area/centcom/reset2)
				template.copy_contents_to(ertarmory)
				log_admin("[key_name(usr)] reset the ertarmory to default with delete_mobs==[delete_mobs].", 1)
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] reset ertarmory to default with delete_mobs==[delete_mobs].</span>")
			if("armotyreset3")
				var/delete_mobs = alert("Clear all mobs?","Confirm","Yes","No","Cancel")
				if(delete_mobs == "Cancel")
					return
				var/area/ertarmory = locate(/area/centcom/ertarmory)
				if(delete_mobs == "Yes")
					for(var/mob/living/mob in ertarmory)
						qdel(mob) //Clear mobs
				for(var/obj/obj in ertarmory)
					if(!istype(obj,/obj/machinery/camera) && !istype(obj,/obj/machinery/door/poddoor/impassable) && !istype(obj,/obj/machinery/door_control))
						qdel(obj) //Clear objects
				var/area/template = locate(/area/centcom/reset3)
				template.copy_contents_to(ertarmory)
				log_admin("[key_name(usr)] reset the ertarmory to default with delete_mobs==[delete_mobs].", 1)
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] reset ertarmory to default with delete_mobs==[delete_mobs].</span>")
			*/
			if("tdomereset")
				var/delete_mobs = tgui_alert(usr, "Clear all mobs?", "Confirm", list("Yes", "No", "Cancel"))
				if(delete_mobs == "Cancel")
					return
				var/area/thunderdome = locate(/area/tdome/arena)
				var/area/team1 = locate(/area/tdome/tdome1)
				var/area/team2 = locate(/area/tdome/tdome2)
				if(delete_mobs == "Yes")
					var/clear_team_spawns = tgui_alert(usr, "Clear mobs on thunderdome spawns too?", "Confirm", list("Yes", "No"))
					if(clear_team_spawns == "Yes")
						for(var/mob/living/mob in team1)
							qdel(mob) //Clear mobs
						for(var/mob/living/mob in team2)
							qdel(mob) //Clear mobs
					for(var/mob/living/mob in thunderdome)
						qdel(mob) //Clear mobs
				for(var/obj/obj in thunderdome)
					if(!istype(obj,/obj/machinery/camera))
						qdel(obj) //Clear objects
				var/area/template = locate(/area/tdome/arena_source)
				template.copy_contents_to(thunderdome)
				log_admin("[key_name(usr)] reset the thunderdome to default with delete_mobs==[delete_mobs].", 1)
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] reset the thunderdome to default with delete_mobs==[delete_mobs].</span>")

			if("tdomestart")
				var/confirmation = tgui_alert(usr, "Start a Thunderdome match?", "Confirm", list("Yes", "No"))
				if(confirmation == "No")
					return
				if(makeThunderdomeTeams())
					log_and_message_admins("<span class='adminnotice'>has started a Thunderdome match!</span>")
				else
					log_and_message_admins("<span class='adminnotice'>tried starting a Thunderdome match, but no ghosts signed up.</span>")

			if("securitylevel0")
				if(!you_realy_want_do_this())
					return
				set_security_level(SEC_LEVEL_GREEN)
				log_and_message_admins("<span class='notice'>change security level to Green.</span>")

			if("securitylevel1")
				if(!you_realy_want_do_this())
					return
				set_security_level(SEC_LEVEL_BLUE)
				log_and_message_admins("<span class='notice'>change security level to Blue.</span>")
			if("securitylevel2")
				if(!you_realy_want_do_this())
					return
				set_security_level(SEC_LEVEL_RED)
				log_and_message_admins("<span class='notice'>change security level to Red.</span>")
			if("securitylevel3")
				if(!you_realy_want_do_this())
					return
				set_security_level(SEC_LEVEL_GAMMA)
				log_and_message_admins("<span class='notice'>change security level to Gamma.</span>")
			if("securitylevel4")
				if(!you_realy_want_do_this())
					return
				set_security_level(SEC_LEVEL_EPSILON)
				log_and_message_admins("<span class='notice'>change security level to Epsilon.</span>")
			if("securitylevel5")
				if(!you_realy_want_do_this())
					return
				set_security_level(SEC_LEVEL_DELTA)
				log_and_message_admins("<span class='notice'>change security level to Delta.</span>")
			if("moveminingshuttle")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Mining Shuttle")
				if(!SSshuttle.toggleShuttle("mining","mining_home","mining_away"))
					message_admins("[key_name_admin(usr)] moved mining shuttle")
					log_admin("[key_name(usr)] moved the mining shuttle")

			if("movelaborshuttle")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Labor Shuttle")
				if(!SSshuttle.toggleShuttle("laborcamp","laborcamp_home","laborcamp_away"))
					message_admins("[key_name_admin(usr)] moved labor shuttle")
					log_admin("[key_name(usr)] moved the labor shuttle")

			if("moveferry")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send CentComm Ferry")
				if(!SSshuttle.toggleShuttle("ferry","ferry_home","ferry_away"))
					message_admins("[key_name_admin(usr)] moved the centcom ferry")
					log_admin("[key_name(usr)] moved the centcom ferry")

			if("gammashuttle")
				if(!you_realy_want_do_this())
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Gamma Armory")
				if(!SSshuttle.toggleShuttle("gamma_shuttle","gamma_home","gamma_away", TRUE))
					message_admins("[key_name_admin(usr)] moved the gamma armory")
					log_admin("[key_name(usr)] moved the gamma armory")
					GLOB.gamma_ship_location = !GLOB.gamma_ship_location

			if("spawn_cargo_crate")
				if(!you_realy_want_do_this())
					return
				create_cargo_crate()

		if(usr)
			log_admin("[key_name(usr)] used secret [href_list["secretsfun"]]")
			if(ok)
				to_chat(world, text("<b>A secret has been activated by []!</b>", usr.key))

	else if(href_list["secretsadmin"])
		if(!check_rights(R_ADMIN))	return

		var/ok = 0
		switch(href_list["secretsadmin"])
			if("list_signalers")
				var/dat = {"<b>Showing last [length(GLOB.lastsignalers)] signalers.</b><hr>"}
				for(var/sig in GLOB.lastsignalers)
					dat += "[sig]<br>"
				var/datum/browser/popup = new(usr, "lastsignalers", "Last Signalers", 800, 500)
				popup.set_content(dat)
				popup.open(FALSE)
			if("list_lawchanges")
				var/dat = {"<b>Showing last [length(GLOB.lawchanges)] law changes.</b><hr>"}
				for(var/sig in GLOB.lawchanges)
					dat += "[sig]<br>"
				var/datum/browser/popup = new(usr, "lawchanges", "Laws Changes", 800, 500)
				popup.set_content(dat)
				popup.open(FALSE)
			if("list_job_debug")
				var/dat = {"<b>Job Debug info.</b><hr>"}
				if(SSjobs)
					for(var/line in SSjobs.job_debug)
						dat += "[line]<br>"
					dat+= "*******<br><br>"
					for(var/datum/job/job in SSjobs.occupations)
						if(!job)	continue
						dat += "job: [job.title], current_positions: [job.current_positions], total_positions: [job.total_positions] <br>"
					var/datum/browser/popup = new(usr, "jobdebug", "Job Debug info", 600, 500)
					popup.set_content(dat)
					popup.open(FALSE)
			if("showailaws")
				output_ai_laws()
			if("manifest")
				var/dat = {"<b>Showing Crew Manifest.</b><hr>"}
				dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
				for(var/thing in GLOB.human_list)
					var/mob/living/carbon/human/H = thing
					if(H.ckey)
						dat += text("<tr><td>[]</td><td>[]</td></tr>", H.name, H.get_assignment())
				dat += "</table>"
				var/datum/browser/popup = new(usr, "manifest", "Crew Manifest", 440, 410)
				popup.set_content(dat)
				popup.open(FALSE)
			if("DNA")
				var/dat = {"<b>Showing DNA from blood.</b><hr>"}
				dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th><th>Race Blood Type</th></tr>"
				for(var/thing in GLOB.human_list)
					var/mob/living/carbon/human/H = thing
					if(H.dna && H.ckey)
						dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.dna.blood_type]</td><td>[H.dna.species.blood_species]</td></tr>"
				dat += "</table>"
				var/datum/browser/popup = new(usr, "DNA", "Blood DNA", 440, 410)
				popup.set_content(dat)
				popup.open(FALSE)

			if("fingerprints")
				var/dat = {"<b>Showing Fingerprints.</b><hr>"}
				dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
				for(var/thing in GLOB.human_list)
					var/mob/living/carbon/human/H = thing
					if(H.ckey)
						if(H.dna && H.dna.uni_identity)
							dat += "<tr><td>[H]</td><td>[md5(H.dna.uni_identity)]</td></tr>"
						else if(H.dna && !H.dna.uni_identity)
							dat += "<tr><td>[H]</td><td>H.dna.uni_identity = null</td></tr>"
						else if(!H.dna)
							dat += "<tr><td>[H]</td><td>H.dna = null</td></tr>"
				dat += "</table>"
				var/datum/browser/popup = new(usr, "fingerprints", "Fingerprints", 440, 410)
				popup.set_content(dat)
				popup.open(FALSE)
			if("night_shift_set")
				var/val = tgui_alert(usr, "What do you want to set night shift to? This will override the automatic system until set to automatic again.", "Night Shift", list("On", "Off", "Automatic"))
				switch(val)
					if("Automatic")
						if(CONFIG_GET(flag/enable_night_shifts))
							SSnightshift.can_fire = TRUE
							SSnightshift.fire()
						else
							SSnightshift.update_nightshift(FALSE, TRUE)
						to_chat(usr, "<span class='notice'>Night shift set to automatic.</span>", confidential=TRUE)
					if("On")
						SSnightshift.can_fire = FALSE
						SSnightshift.update_nightshift(TRUE, FALSE)
						to_chat(usr, "<span class='notice'>Night shift forced on.</span>", confidential=TRUE)
					if("Off")
						SSnightshift.can_fire = FALSE
						SSnightshift.update_nightshift(FALSE, FALSE)
						to_chat(usr, "<span class='notice'>Night shift forced off.</span>", confidential=TRUE)
			else
		if(usr)
			log_admin("[key_name(usr)] used secret [href_list["secretsadmin"]]")
			if(ok)
				to_chat(world, text("<b>A secret has been activated by []!</b>", usr.key))

	else if(href_list["secretscoder"])
		if(!check_rights(R_DEBUG))	return

		switch(href_list["secretscoder"])
			if("spawn_objects")
				var/dat = "<b>Admin Log<hr></b>"
				for(var/l in GLOB.admin_log)
					dat += "<li>[l]</li>"
				if(!GLOB.admin_log.len)
					dat += "No-one has done anything this round!"
				var/datum/browser/popup = new(usr, "admin_log", "Admin Log")
				popup.set_content(dat)
				popup.open(FALSE)
			if("maint_ACCESS_BRIG")
				if(!you_realy_want_do_this())
					return
				for(var/obj/machinery/door/airlock/maintenance/M in GLOB.airlocks)
					if(ACCESS_MAINT_TUNNELS in M.req_access)
						M.req_access = list(ACCESS_BRIG)
				message_admins("[key_name_admin(usr)] made all maint doors brig access-only.")
			if("maint_access_engiebrig")
				if(!you_realy_want_do_this())
					return
				for(var/obj/machinery/door/airlock/maintenance/M in GLOB.airlocks)
					if(ACCESS_MAINT_TUNNELS in M.req_access)
						M.req_access = list()
						M.req_access = list(ACCESS_BRIG,ACCESS_ENGINE)
				message_admins("[key_name_admin(usr)] made all maint doors engineering and brig access-only.")
			if("infinite_sec")
				if(!you_realy_want_do_this())
					return
				var/datum/job/J = SSjobs.GetJob(JOB_TITLE_OFFICER)
				if(!J) return
				J.total_positions = -1
				J.spawn_positions = -1

	if(href_list["secretsmenu"])
		switch(href_list["secretsmenu"])
			if("tab")
				current_tab = text2num(href_list["tab"])
				Secrets(usr)
				return 1

	else if(href_list["viewruntime"])
		var/datum/error_viewer/error_viewer = locate(href_list["viewruntime"])
		if(!istype(error_viewer))
			to_chat(usr, span_warning("That runtime viewer no longer exists."), confidential=TRUE)
			return

		if(href_list["viewruntime_backto"])
			error_viewer.show_to(usr, locateUID(href_list["viewruntime_backto"]), href_list["viewruntime_linear"])
		else
			error_viewer.show_to(usr, null, href_list["viewruntime_linear"])

	else if(href_list["add_station_goal"])
		if(!check_rights(R_EVENT))
			return
		var/list/type_choices = typesof(/datum/station_goal)
		var/picked = tgui_input_list(usr, "Choose goal type", items = type_choices)
		if(!picked)
			return
		var/datum/station_goal/G = new picked()
		if(picked == /datum/station_goal)
			var/newname = tgui_input_text(usr, "Enter goal name:")
			if(!newname)
				return
			G.name = newname
			var/description = tgui_input_text(usr, "Enter [command_name()] message contents:", encode = FALSE, multiline = TRUE)
			if(!description)
				return
			G.report_message = description
		log_and_message_admins("created \"[G.name]\" station goal.")
		SSticker.mode.station_goals += G
		modify_goals()

	else if(href_list["showdetails"])
		if(!check_rights(R_ADMIN))
			return
		var/text = html_decode(href_list["showdetails"])
		var/datum/browser/popup = new(usr, "show_details", "Details", 500, 200)
		popup.set_content("<tt>[replacetext(text, "\n", "<br>")]</tt>")
		popup.open(FALSE)

	// Library stuff
	else if(href_list["library_book_id"])
		var/isbn = text2num(href_list["library_book_id"])

		if(href_list["view_library_book"])
			var/datum/db_query/query_view_book = SSdbcore.NewQuery("SELECT content, title FROM [format_table_name("library")] WHERE id=:isbn", list(
				"isbn" = isbn
			))
			if(!query_view_book.warn_execute())
				qdel(query_view_book)
				return

			var/content = ""
			var/title = ""
			while(query_view_book.NextRow())
				content = query_view_book.item[1]
				title = html_encode(query_view_book.item[2])

			var/dat = {"<pre><code>"}
			dat += "[html_encode(html_to_pencode(content))]"
			dat += "</code></pre>"

			var/datum/browser/popup = new(usr, "admin_view_book", "[title]", 700, 400)
			popup.set_content(dat)
			popup.open(FALSE)

			qdel(query_view_book)
			log_admin("[key_name(usr)] has viewed the book [isbn].")
			message_admins("[key_name_admin(usr)] has viewed the book [isbn].")
			return

		else if(href_list["unflag_library_book"])
			var/datum/db_query/query_unflag_book = SSdbcore.NewQuery("UPDATE [format_table_name("library")] SET flagged = 0 WHERE id=:isbn", list(
				"isbn" = isbn
			))
			if(!query_unflag_book.warn_execute())
				qdel(query_unflag_book)
				return

			qdel(query_unflag_book)
			log_admin("[key_name(usr)] has unflagged the book [isbn].")
			message_admins("[key_name_admin(usr)] has unflagged the book [isbn].")

		else if(href_list["delete_library_book"])
			var/datum/db_query/query_delbook = SSdbcore.NewQuery("DELETE FROM [format_table_name("library")] WHERE id=:isbn", list(
				"isbn" = isbn
			))
			if(!query_delbook.warn_execute())
				qdel(query_delbook)
				return

			qdel(query_delbook)
			log_admin("[key_name(usr)] has deleted the book [isbn].")
			message_admins("[key_name_admin(usr)] has deleted the book [isbn].")

		// Refresh the page
		src.view_flagged_books()

	else if(href_list["create_outfit_finalize"])
		if(!check_rights(R_EVENT))
			return
		create_outfit_finalize(usr,href_list)
	else if(href_list["load_outfit"])
		if(!check_rights(R_EVENT))
			return
		load_outfit(usr)
	else if(href_list["create_outfit_menu"])
		if(!check_rights(R_EVENT))
			return
		create_outfit(usr)
	else if(href_list["delete_outfit"])
		if(!check_rights(R_EVENT))
			return
		var/datum/outfit/O = locate(href_list["chosen_outfit"]) in GLOB.custom_outfits
		delete_outfit(usr,O)
	else if(href_list["save_outfit"])
		if(!check_rights(R_EVENT))
			return
		var/datum/outfit/O = locate(href_list["chosen_outfit"]) in GLOB.custom_outfits
		save_outfit(usr,O)
	else if(href_list["open_ccDB"])
		if(!check_rights(R_ADMIN))
			return
		create_ccbdb_lookup(href_list["open_ccDB"])
	else if(href_list["slowquery"])
		if(!check_rights(R_ADMIN))
			return
		message_admins("[key_name_admin(usr)] started responding to a query hang report") // So multiple admins dont try file the same report
		var/answer = href_list["slowquery"]
		if(answer == "yes")
			log_sql("[usr.key] | Reported a server hang")
			if(tgui_alert(usr, "Had you just pressed any admin buttons which could lag the server?", "Query server hang report", list("Yes", "No")) == "Yes")
				var/response = tgui_input_text(usr, "What were you just doing?", "Query server hang report", encode = FALSE)
				if(response)
					log_sql("[usr.key] | [response]")
		else if(answer == "no")
			log_sql("[usr.key] | Reported no server hang. Please investigate")

	else if(href_list["adminalert"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/about_to_be_banned = locateUID(href_list["adminalert"])
		usr.client.cmd_admin_alert_message(about_to_be_banned)

	else if(href_list["resultspoll"])
		var/datum/poll_question/poll = locate(href_list["resultspoll"]) in GLOB.polls
		var/start_index = text2num(href_list["startat"]) || 0
		poll_results_panel(poll, start_index)

	else if(href_list["showrelatedacc"])
		var/client/C = locate(href_list["client"]) in GLOB.clients
		if(!C)
			to_chat(usr, "No client inside!")
			return
		var/thing_to_check
		if(href_list["showrelatedacc"] == "cid")
			thing_to_check = jointext(C.related_accounts_cid, "<br>")
		else
			thing_to_check = jointext(C.related_accounts_ip, "<br>")


		var/list/dat = list("Related accounts by [uppertext(href_list["showrelatedacc"])]:")
		dat += thing_to_check

		var/datum/browser/popup = new(usr, "related_[C]", "Related dacc", 420, 300)
		popup.set_content(dat.Join("<br>"))
		popup.open(FALSE)

	else if(href_list["showdna"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/carbon/M = locateUID(href_list["showdna"])
		if(!M.dna || !iscarbon(M))
			to_chat(usr, span_warning("It doesn't have DNA nor it's carbon mob!"))
			return

		var/list/body = list()
		body += "<b>DNA Blocks:</b><br><table border='0'><tr><th>&nbsp;</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>"
		for(var/block in 1 to DNA_SE_LENGTH)
			if(!((block - 1) % 5))
				body += "</tr><tr><th>[block - 1]</th>"

			body += "<td>"
			var/gene_name = GLOB.assigned_blocks[block]
			if(gene_name)
				var/text_color = "[M.dna.GetSEState(block) ? "#006600" : "#ff0000"]"
				body += "<a href='byond://?_src_=holder;togmutate=[M.UID()];block=[block];version=new' style='color:[text_color];'>[gene_name]<a><sub>[block]</sub>"
			else
				body += "[block]"
			body += "</td>"
		body += "</tr></table>"

		var/datum/browser/popup = new(usr, "show_dna", "<div align='center'>DNA</div>", 700, 500)
		popup.set_content(body.Join(""))
		popup.set_window_options("can_close=1;window=related_[M];")
		popup.open()
		onclose(usr, "show_dna")

/client/proc/create_eventmob_for(var/mob/living/carbon/human/H, var/killthem = 0)
	if(!check_rights(R_EVENT))
		return
	var/admin_outfits = subtypesof(/datum/outfit/admin)
	var/hunter_outfits = list()
	for(var/type in admin_outfits)
		var/datum/outfit/admin/O = type
		hunter_outfits[initial(O.name)] = type
	var/dresscode = tgui_input_list(usr, "Select type", "Contracted Agents", hunter_outfits)
	if(isnull(dresscode))
		return
	var/datum/outfit/O = hunter_outfits[dresscode]
	message_admins("[key_name_admin(mob)] is sending a ([dresscode]) to [killthem ? "assassinate" : "protect"] [key_name_admin(H)]...")
	var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_traitor")
	var/list/candidates = SSghost_spawns.poll_candidates("Play as a [killthem ? "murderous" : "protective"] [dresscode]?", ROLE_TRAITOR, TRUE, source = source, role_cleanname = "[killthem ? "murderous" : "protective"] [dresscode]")
	if(!candidates.len)
		to_chat(usr, "<span class='warning'>ERROR: Could not create eventmob. No valid candidates.</span>", confidential=TRUE)
		return
	var/mob/C = pick(candidates)
	var/key_of_hunter = C.key
	if(!key_of_hunter)
		to_chat(usr, "<span class='warning'>ERROR: Could not create eventmob. Could not pick key.</span>", confidential=TRUE)
		return
	var/datum/mind/hunter_mind = new /datum/mind(key_of_hunter)
	hunter_mind.active = 1
	var/mob/living/carbon/human/hunter_mob = new /mob/living/carbon/human(pick(GLOB.latejoin))
	hunter_mind.transfer_to(hunter_mob)
	hunter_mob.equipOutfit(O, FALSE)
	var/obj/item/pinpointer/advpinpointer/N = new /obj/item/pinpointer/advpinpointer(hunter_mob)
	hunter_mob.equip_to_slot_or_del(N, ITEM_SLOT_BACKPACK)
	N.setting = 2 //SETTING_OBJECT, not defined here
	N.pinpoint_at(H)
	N.modelocked = TRUE
	if(!locate(/obj/item/implant/dust, hunter_mob))
		var/obj/item/implant/dust/D = new /obj/item/implant/dust(hunter_mob)
		D.implant(hunter_mob)
	if(killthem)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = hunter_mind
		kill_objective.target = H.mind
		kill_objective.explanation_text = "Kill [H.real_name], the [H.mind.assigned_role]."
		hunter_mind.objectives += kill_objective
	else
		var/datum/objective/protect/protect_objective = new
		protect_objective.owner = hunter_mind
		protect_objective.target = H.mind
		protect_objective.explanation_text = "Protect [H.real_name], the [H.mind.assigned_role]."
		hunter_mind.objectives += protect_objective
	SSticker.mode.traitors |= hunter_mob.mind
	to_chat(hunter_mob, "<span class='danger'>ATTENTION:</span> You are now on a mission!")
	to_chat(hunter_mob, "<b>Goal: <span class='danger'>[killthem ? "MURDER" : "PROTECT"] [H.real_name]</span>, currently in [get_area(H.loc)].</b>");
	if(killthem)
		to_chat(hunter_mob, "<b>If you kill [H.p_them()], [H.p_they()] cannot be revived.</b>");
	hunter_mob.mind.special_role = SPECIAL_ROLE_TRAITOR
	var/datum/atom_hud/antag/tatorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	tatorhud.join_hud(hunter_mob)
	set_antag_hud(hunter_mob, "hudsyndicate")

/proc/admin_jump_link(var/atom/target)
	if(!target) return
	// The way admin jump links handle their src is weirdly inconsistent...

	if(isclient(target))
		var/client/C = target
		if(C.mob)
			target = C.mob

	. = ADMIN_FLW(target, "FLW")

	if(isAI(target)) // AI core/eye follow links
		var/mob/living/silicon/ai/A = target
		if(A.client && A.eyeobj) // No point following clientless AI eyes
			. += "|[ADMIN_FLW(A.eyeobj,"EYE")]"
	else if(istype(target, /mob/dead/observer))
		var/mob/dead/observer/O = target
		if(O.mind && O.mind.current)
			. += "|[ADMIN_FLW(O.mind.current,"BDY")]"

/proc/you_realy_want_do_this(mob/user)
	user = user || usr
	var/sure = tgui_alert(user, "Вы действительно хотите сделать это?", "Подтверждение", list("Да", "Нет"))
	return sure == "Да"


/proc/portalAnnounce(announcement, playlightning)
	set waitfor = 0
	if (playlightning)
		sound_to_playing_players('sound/magic/lightning_chargeup.ogg')
		sleep(80)
	GLOB.priority_announcement.Announce(replacetext(announcement, "%STATION%", station_name()))
	if (playlightning)
		sleep(20)
		sound_to_playing_players('sound/magic/lightningbolt.ogg')

/proc/doPortalSpawn(turf/loc, mobtype, numtospawn, portal_appearance)
	loc.flick_overlay_static(portal_appearance, 15)
	playsound(loc, "sparks", rand(80, 100), 1)
	for (var/i in 1 to numtospawn)
		new mobtype(loc)

/datum/admins/proc/mass_mindswap()
	if(!check_rights(R_EVENT) || !you_realy_want_do_this(owner.mob))
		return

	for(var/mob/living/carbon/human/human as anything in GLOB.human_list)
		if(!human.mind)
			continue

		var/mob/living/target = safepick(GLOB.human_list - human)

		if(!target \
		|| !/obj/effect/proc_holder/spell/mind_transfer::valid_target(target, human))
			continue

		/obj/effect/proc_holder/spell/mind_transfer::cast(list(target), human)

	log_and_message_admins("Initiated mass mindswap")
