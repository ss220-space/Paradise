/mob/new_player
	var/ready = 0
	var/spawning = 0	//Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers = 0		 //Player counts for the Lobby tab
	var/totalPlayersReady = 0
	universal_speak = 1

	invisibility = INVISIBILITY_ABSTRACT

	density = FALSE
	stat = DEAD


/mob/new_player/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(flags & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags |= INITIALIZED
	GLOB.mob_list += src
	return INITIALIZE_HINT_NORMAL

/mob/new_player/proc/privacy_consent()
	src << browse(null, "window=playersetup")
	var/output = {"<!DOCTYPE html><meta charset="UTF-8">"} + GLOB.join_tos
	output += "<p><a href='byond://?src=[UID()];consent_signed=SIGNED'>Я согласен</A>"
	output += "<p><a href='byond://?src=[UID()];consent_rejected=NOTSIGNED'>Я НЕ согласен</A>"
	src << browse(output,"window=privacy_consent;size=500x300")
	var/datum/browser/popup = new(src, "privacy_consent", "<div align='center'>Политика Конфидициальности</div>", 500, 400)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(0)
	return

/mob/new_player/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	if(SSticker)
		if(!SSticker.hide_mode)
			status_tab_data[++status_tab_data.len] = list("Game Mode:", "[GLOB.master_mode]")
		else
			status_tab_data[++status_tab_data.len] = list("Game Mode:", "Secret")

		if(SSticker.current_state == GAME_STATE_PREGAME)
			status_tab_data[++status_tab_data.len] = list("Time To Start:", SSticker.ticker_going ? deciseconds_to_time_stamp(SSticker.pregame_timeleft) : "DELAYED")

		if(SSticker.current_state == GAME_STATE_PREGAME)
			status_tab_data[++status_tab_data.len] = list("Players Ready:", "[totalPlayersReady]")
			totalPlayersReady = 0
			for(var/mob/new_player/player in GLOB.player_list)
				if(check_rights(R_ADMIN, 0, src))
					status_tab_data[++status_tab_data.len] = list("[player.key]", player.ready ? "(Ready)" : "(Not ready)")
				if(player.ready)
					totalPlayersReady++


/mob/new_player/Topic(href, href_list[])
	if(!client)
		return FALSE

	if(href_list["consent_signed"])
		var/datum/db_query/query = SSdbcore.NewQuery("REPLACE INTO [format_table_name("privacy")] (ckey, datetime, consent) VALUES (:ckey, Now(), 1)", list(
			"ckey" = ckey
		))
		// If the query fails we dont want them permenantly stuck on being unable to accept TOS
		query.warn_execute()
		qdel(query)
		src << browse(null, "window=privacy_consent")
		client.tos_consent = TRUE

	if(href_list["consent_rejected"])
		client.tos_consent = FALSE
		to_chat(usr, "<span class='warning'>You must consent to the terms of service before you can join!</span>")
		var/datum/db_query/query = SSdbcore.NewQuery("REPLACE INTO [format_table_name("privacy")] (ckey, datetime, consent) VALUES (:ckey, Now(), 0)", list(
			"ckey" = ckey
		))
		// If the query fails we dont want them permenantly stuck on being unable to accept TOS
		query.warn_execute()
		qdel(query)

	if(href_list["show_preferences"])
		client.prefs.current_tab = 0
		client.prefs.ShowChoices(src)
		return TRUE

	if(href_list["ready"])
		if(!client.tos_consent)
			to_chat(usr, "<span class='warning'>Вы долнжны согласится с политикой конфидициальноти перед игрой!</span>")
			return FALSE
		if(client.version_blocked)
			client.show_update_notice()
			return FALSE
		if(CONFIG_GET(number/minimum_byondacc_age) && client.byondacc_age <= CONFIG_GET(number/minimum_byondacc_age))
			if(!client.prefs.discord_id || (client.prefs.discord_id && length(client.prefs.discord_id) == 32))
				client.prefs.load_preferences(client)
				to_chat(usr, "<span class='danger'>Вам необходимо привязать дискорд-профиль к аккаунту!</span>")
				to_chat(usr, "<span class='warning'>Нажмите 'Привязка Discord' во вкладке 'Special Verbs' для получения инструкций.</span>")
				return FALSE
		if(!is_used_species_available(client.prefs.species))
			to_chat(usr, "<span class='warning'>Выбранная раса персонажа недоступна для игры в данный момент! Выберите другого персонажа.</span>")
			return FALSE
		if(CONFIG_GET(flag/tts_enabled))
			if(!client.prefs.tts_seed)
				to_chat(usr, "<span class='danger'>Вам необходимо настроить голос персонажа! Не забудьте сохранить настройки.</span>")
				client.prefs.ShowChoices(src)
				return FALSE
			var/datum/tts_seed/seed = SStts.tts_seeds[client.prefs.tts_seed]
			if(client.donator_level < seed.donator_level)
				to_chat(usr, "<span class='danger'>Выбранный голос персонажа более недоступен на текущем уровне подписки!</span>")
				client.prefs.ShowChoices(src)
				return FALSE
		ready = !ready
		client << output(ready, "title_browser:ready")

	if(href_list["skip_antag"])
		client.prefs?.skip_antag = !client.prefs?.skip_antag
		client << output(client.prefs.skip_antag, "title_browser:skip_antag")

	if(href_list["game_preferences"])
		client.prefs.current_tab = 1
		client.prefs.ShowChoices(usr)

	if(href_list["job_preferences"])
		client.prefs.SetChoices(usr)

	if(href_list["wiki"])
		if(tgui_alert(usr, "Открыть вики проекта?", "Вики", list("Да", "Нет")) != "Да")
			return
		client << link(CONFIG_GET(string/wikiurl))

	if(href_list["discord"])
		if(tgui_alert(usr, "Перейти на дискорд сервер?", "Дискорд", list("Да", "Нет")) != "Да")
			return
		client << link(CONFIG_GET(string/discordurl))

	if(href_list["changelog"])
		client.changelog()

	if(href_list["sound_options"])
		client.volume_mixer()

	if(href_list["refresh"])
		src << browse(null, "window=playersetup") //closes the player setup window

	if(href_list["observe"])
		if(!client.tos_consent)
			to_chat(usr, "<span class='warning'>You must consent to the terms of service before you can join!</span>")
			return FALSE
		if(client.version_blocked)
			client.show_update_notice()
			return FALSE
		if(CONFIG_GET(number/minimum_byondacc_age) && client.byondacc_age <= CONFIG_GET(number/minimum_byondacc_age))
			if(!client.prefs.discord_id || (client.prefs.discord_id && length(client.prefs.discord_id) == 32))
				client.prefs.load_preferences(client)
				to_chat(usr, "<span class='danger'>Вам необходимо привязать дискорд-профиль к аккаунту!</span>")
				to_chat(usr, "<span class='warning'>Нажмите 'Привязка Discord' в меню или во вкладке 'Special Verbs' для получения инструкций.</span>")
				return FALSE
		if(!SSticker || SSticker.current_state == GAME_STATE_STARTUP)
			to_chat(usr, "<span class='warning'>You must wait for the server to finish starting before you can join!</span>")
			return FALSE

		if(tgui_alert(src,"Вы уверены что хотите стать наблюдателем?[(CONFIG_GET(flag/respawn_observer) ? "" : " Вы не сможете зайти в раунд за члена экипажа после этого!")]","Наблюдать", list("Да","Нет")) == "Да")
			if(!client)
				return 1
			var/mob/dead/observer/observer = new()
			src << browse(null, "window=playersetup")
			spawning = 1
			// stop_sound_channel(CHANNEL_LOBBYMUSIC)
			client?.tgui_panel?.stop_music()


			observer.started_as_observer = 1
			close_spawn_windows()
			var/obj/O = locate("landmark*Observer-Start")
			to_chat(src, "<span class='notice'>Now teleporting.</span>")
			observer.abstract_move(get_turf(O))
			observer.timeofdeath = world.time // Set the time of death so that the respawn timer works correctly.
			client.prefs.update_preview_icon(1)
			observer.icon = client.prefs.preview_icon
			observer.alpha = 127

			if(client.prefs.be_random_name)
				client.prefs.real_name = random_name(client.prefs.gender,client.prefs.species)
			observer.real_name = client.prefs.real_name
			observer.name = observer.real_name
			observer.key = key
			QDEL_NULL(mind)
			if (CONFIG_GET(flag/respawn_observer)) GLOB.respawnable_list += observer			// If enabled in config - observer cant respawn as Player
			qdel(src)
			return 1

	if(href_list["tos"])
		privacy_consent()
		return FALSE

	if(href_list["late_join"])
		if(!client.tos_consent)
			to_chat(usr, "<span class='warning'>You must consent to the terms of service before you can join!</span>")
			return FALSE
		if(client.version_blocked)
			client.show_update_notice()
			return FALSE
		if(CONFIG_GET(number/minimum_byondacc_age) && client.byondacc_age <= CONFIG_GET(number/minimum_byondacc_age))
			if(!client.prefs.discord_id || (client.prefs.discord_id && length(client.prefs.discord_id) == 32))
				client.prefs.load_preferences(client)
				to_chat(usr, "<span class='danger'>Вам необходимо привязать дискорд-профиль к аккаунту!</span>")
				to_chat(usr, "<span class='warning'>Нажмите 'Привязка Discord' во вкладке 'Special Verbs' для получения инструкций.</span>")
				return FALSE
		if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
			to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished...</span>")
			return
		if(!is_used_species_available(client.prefs.species))
			to_chat(usr, "<span class='warning'>Выбранная раса персонажа недоступна для игры в данный момент! Выберите другого персонажа.</span>")
			return
		if(CONFIG_GET(flag/tts_enabled))
			if(!client.prefs.tts_seed)
				to_chat(usr, "<span class='danger'>Вам необходимо настроить голос персонажа! Не забудьте сохранить настройки.</span>")
				client.prefs.ShowChoices(src)
				return FALSE
			var/datum/tts_seed/seed = SStts.tts_seeds[client.prefs.tts_seed]
			if(client.donator_level < seed.donator_level)
				to_chat(usr, "<span class='danger'>Выбранный голос персонажа более недоступен на текущем уровне подписки!</span>")
				client.prefs.ShowChoices(src)
				return FALSE

		LateChoices()

	if(href_list["manifest"])
		ViewManifest()

	if(href_list["connect_discord"])
		client?.link_discord_account()

	if(href_list["SelectedJob"])

		if(!GLOB.enter_allowed)
			to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
			return

		if(client.prefs.toggles2 & PREFTOGGLE_2_RANDOMSLOT)
			client.prefs.load_random_character_slot(client)

		if(!is_used_species_available(client.prefs.species))
			to_chat(usr, "<span class='warning'>Выбранная раса персонажа недоступна для игры в данный момент! Выберите другого персонажа.</span>")
			return

		//Prevents people rejoining as same character.
		if(!is_admin(usr)) //Админам можно всё
			for(var/C in GLOB.human_names_list)
				var/char_name = client.prefs.real_name
				if(char_name == C)
					to_chat (usr, "<span class='danger'>There is a character that already exists with the same name: <b>[C]</b>, please join with a different one.</span>")
					return

		AttemptLateSpawn(href_list["SelectedJob"],client.prefs.spawnpoint)
		return

	if(!ready && href_list["preference"])
		if(client)
			client.prefs.process_link(src, href_list)

	if(href_list["change_picture"])
		client.admin_change_title_screen()
		return

	if(href_list["leave_notice"])
		client.change_title_screen_notice()
		return

	if(href_list["focus"])
		winset(client, "mapwindow.map", "focus=true")
		return

/mob/new_player/proc/IsJobAvailable(rank)
	var/datum/job/job = SSjobs.GetJob(rank)
	if(!job)	return 0
	if(!job.is_position_available()) return 0
	if(jobban_isbanned(src,rank))	return 0
	if(!job.player_old_enough(client))	return 0
	if(job.admin_only && !(check_rights(R_ADMIN, 0))) return 0
	if(job.available_in_playtime(client))
		return 0
	if(!job.can_novice_play(client))
		return 0

	if(CONFIG_GET(flag/assistant_limit))
		if(job.title == JOB_TITLE_CIVILIAN)
			var/count = 0
			var/datum/job/officer = SSjobs.GetJob(JOB_TITLE_OFFICER)
			var/datum/job/warden = SSjobs.GetJob(JOB_TITLE_WARDEN)
			var/datum/job/hos = SSjobs.GetJob(JOB_TITLE_HOS)
			count += (officer.current_positions + warden.current_positions + hos.current_positions)
			if(job.current_positions > (CONFIG_GET(number/assistant_ratio) * count))
				if(count >= 5) // if theres more than 5 security on the station just let assistants join regardless, they should be able to handle the tide
					return 1
				return 0
	return 1

/mob/new_player/proc/IsAdminJob(rank)
	var/datum/job/job = SSjobs.GetJob(rank)
	if(job.admin_only)
		return 1
	else
		return 0

/mob/new_player/proc/is_used_species_available(species)
	if(has_admin_rights())
		return TRUE
	var/list/available_species = list(SPECIES_HUMAN)
	available_species += CONFIG_GET(str_list/playable_species)
	if(species in available_species)
		return TRUE
	else
		return FALSE

/mob/new_player/proc/IsERTSpawnJob(rank)
	var/datum/job/job = SSjobs.GetJob(rank)
	if(job.spawn_ert)
		return 1
	else
		return 0

/mob/new_player/proc/IsSyndicateCommand(rank)
	var/datum/job/job = SSjobs.GetJob(rank)
	if(job.syndicate_command)
		return 1
	else
		return 0

/mob/new_player/proc/random_job()
	var/jobs_available = list()
	for(var/datum/job/job in SSjobs.occupations)
		if(job && IsJobAvailable(job.title) && !job.barred_by_disability(client))
			jobs_available += job.title
	if(!length(jobs_available))
		return FALSE
	return pick(jobs_available)

/mob/new_player/proc/AttemptLateSpawn(rank,var/spawning_at)
	if(src != usr)
		return FALSE
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>Раунд либо еще не готов, либо уже завершился...</span>")
		return FALSE
	if(!GLOB.enter_allowed)
		to_chat(usr, "<span class='notice'>Администратор заблокировал вход в игру!</span>")
		return FALSE
	if(rank == "RandomJob")
		rank = random_job()
		if(!rank)
			var/msg = "Нет свободных ролей. Пожалуйста, попробуйте позже."
			to_chat(src, msg)
			alert(msg)
			return FALSE
	if(!IsJobAvailable(rank))
		var/msg = "Должность [rank] недоступна. Пожалуйста, попробуйте другую."
		to_chat(src, msg)
		alert(msg)
		return FALSE
	var/datum/job/thisjob = SSjobs.GetJob(rank)
	if(thisjob.barred_by_disability(client))
		var/msg = "Должность [rank] недоступна в связи с инвалидностью персонажа. Пожалуйста, попробуйте другую."
		to_chat(src, msg)
		alert(msg)
		return FALSE
	if(!thisjob.character_old_enough(client))
		var/msg = "Должность [rank] недоступна в связи с недостаточным возрастом персонажа ([client?.prefs.age]). Минимальный возраст - [thisjob.min_age_allowed]"
		to_chat(src, msg)
		alert(msg)
		return FALSE

	if(thisjob.species_in_blacklist(client))
		var/msg = "Должность [rank] недоступна для данной расы. Выберите другую."
		to_chat(src, msg)
		alert(msg)
		return FALSE

	SSjobs.AssignRole(src, rank, 1)

	var/mob/living/character = create_character()	//creates the human and transfers vars and mind
	character = SSjobs.AssignRank(character, rank, 1)					//equips the human

	// AIs don't need a spawnpoint, they must spawn at an empty core
	if(character.mind.assigned_role == JOB_TITLE_AI)
		var/mob/living/silicon/ai/ai_character = character.AIize() // AIize the character, but don't move them yet

		// IsJobAvailable for AI checks that there is an empty core available in this list
		ai_character.moveToEmptyCore()
		AnnounceCyborg(ai_character, rank, "has been downloaded to the empty core in \the [get_area(ai_character)]")

		SSticker.mode.latespawn(ai_character)
		SSticker?.score?.save_silicon_laws(ai_character, additional_info = "latespawn", log_all_laws = TRUE)
		qdel(src)
		return

	//Find our spawning point.
	var/join_message
	var/datum/spawnpoint/S

	if(IsAdminJob(rank))
		if(IsERTSpawnJob(rank))
			character.loc = pick(GLOB.ertdirector)
		else if(IsSyndicateCommand(rank))
			character.loc = pick(GLOB.syndicateofficer)
		else
			character.forceMove(pick(GLOB.aroomwarp))
		join_message = "прибыл"
	else
		if(spawning_at)
			S = GLOB.spawntypes[spawning_at]
		if(S && istype(S))
			if(S.check_job_spawning(rank))
				character.forceMove(pick(S.turfs))
				join_message = S.msg
			else
				to_chat(character, "Your chosen spawnpoint ([S.display_name]) is unavailable for your chosen job. Spawning you at the Arrivals shuttle instead.")
				character.forceMove(pick(GLOB.latejoin))
				join_message = "прибыл на станцию"
		else
			character.forceMove(pick(GLOB.latejoin))
			join_message = "прибыл на станцию"

	character.lastarea = get_area(loc)

	character = SSjobs.EquipRank(character, rank, 1)					//equips the human
	EquipCustomItems(character)

	SSticker.mode.latespawn(character)

	if(character.mind.assigned_role == JOB_TITLE_CYBORG)
		var/mob/living/silicon/robot/R = character
		AnnounceCyborg(character, R.mind.role_alt_title ? R.mind.role_alt_title : JOB_TITLE_CYBORG, join_message)
	else
		SSticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
		if(!IsAdminJob(rank))
			GLOB.data_core.manifest_inject(character)
			AnnounceArrival(character, rank, join_message)
			AddEmploymentContract(character)

			if(GLOB.summon_guns_triggered)
				give_guns(character)
			if(GLOB.summon_magic_triggered)
				give_magic(character)

	if(!thisjob.is_position_available() && (thisjob in SSjobs.prioritized_jobs))
		SSjobs.prioritized_jobs -= thisjob
	qdel(src)


/mob/new_player/proc/AnnounceArrival(mob/living/carbon/human/character, rank, join_message)
	if(SSticker.current_state == GAME_STATE_PLAYING)
		var/ailist[] = list()
		for(var/mob/living/silicon/ai/A in GLOB.alive_mob_list)
			if(A.announce_arrivals)
				ailist += A
		if(ailist.len)
			var/mob/living/silicon/ai/announcer = pick(ailist)
			if(character.mind)
				if((character.mind.assigned_role != JOB_TITLE_CYBORG) && (character.mind.assigned_role != character.mind.special_role))
					var/arrivalmessage = create_announce_message(character, rank, join_message, announcer.arrivalmsg)
					announcer.say(";[arrivalmessage]")

		else
			if(character.mind)
				if((character.mind.assigned_role != JOB_TITLE_CYBORG) && (character.mind.assigned_role != character.mind.special_role))
					var/arrivalmessage = create_announce_message(character, rank, join_message, GLOB.global_announcer_base_text)
					GLOB.global_announcer.autosay(arrivalmessage, "Arrivals Announcement Computer")

/mob/new_player/proc/create_announce_message(mob/living/carbon/human/arrived, rank, join_message, message)
	if(arrived.mind.role_alt_title)
		rank = arrived.mind.role_alt_title
	message = replacetext(message,"$name",arrived.real_name)
	message = replacetext(message,"$rank",rank ? "[rank]" : "visitor")
	message = replacetext(message,"$species",arrived.dna.species.name)
	message = replacetext(message,"$age",num2text(arrived.age))
	message = replacetext(message,"$gender",arrived.gender == FEMALE ? "Female" : "Male")
	message = replacetext(message,"$join_message",join_message)
	return message

/mob/new_player/proc/AddEmploymentContract(mob/living/carbon/human/employee)
	spawn(30)
		for(var/C in GLOB.employmentCabinets)
			var/obj/structure/filingcabinet/employment/employmentCabinet = C
			if(employmentCabinet.populated)
				employmentCabinet.addFile(employee)

/mob/new_player/proc/AnnounceCyborg(var/mob/living/character, var/rank, var/join_message)
	if(SSticker.current_state == GAME_STATE_PLAYING)
		var/ailist[] = list()
		for(var/mob/living/silicon/ai/A in GLOB.alive_mob_list)
			ailist += A
		if(ailist.len)
			var/mob/living/silicon/ai/announcer = pick(ailist)
			if(character.mind)
				if(character.mind.assigned_role != character.mind.special_role)
					var/arrivalmessage = "A new[rank ? " [rank]" : " visitor" ] [join_message ? join_message : "прибыл на станцию"]."
					announcer.say(";[arrivalmessage]")
		else
			if(character.mind)
				if(character.mind.assigned_role != character.mind.special_role)
					// can't use their name here, since cyborg namepicking is done post-spawn, so we'll just say "A new Cyborg has arrived"/"A new Android has arrived"/etc.
					GLOB.global_announcer.autosay("A new[rank ? " [rank]" : " visitor" ] [join_message ? join_message : "прибыл на станцию"].", "Arrivals Announcement Computer")

/mob/new_player/proc/LateChoices()
	var/mills = ROUND_TIME // 1/10 of a second, not real milliseconds but whatever
	//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
	var/mins = (mills % 36000) / 600
	var/hours = mills / 36000

	var/dat = {"<html><meta charset="UTF-8"><body><center>"}
	dat += "Продолжительность раунда: [round(hours)]h [round(mins)]m<br>"
	dat += "<b>Уровень угрозы на станции: [get_security_level_ru_colors()]</b><br>"

	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		dat += "<font color='red'><b>Станция была эвакуирована.</b></font><br>"
	else if((SSshuttle.emergency.mode == SHUTTLE_CALL) || EMERGENCY_AT_LEAST_DOCKED)
		dat += "<font color='red'>В настоящее время станция проходит процедуру эвакуации.</font><br>"

	if(length(SSjobs.prioritized_jobs))
		dat += "<font color='lime'>Станция отметила эти позиции как приоритетные: "
		var/amt = length(SSjobs.prioritized_jobs)
		var/amt_count
		for(var/datum/job/a in SSjobs.prioritized_jobs)
			amt_count++
			if(amt_count != amt)
				dat += " [a.title], "
			else
				dat += " [a.title]. </font><br>"


	var/num_jobs_available = 0
	var/list/activePlayers = list()
	var/list/categorizedJobs = list(
		"Command" = list(jobs = list(), titles = GLOB.command_positions, color = "#aac1ee"),
		"Engineering" = list(jobs = list(), titles = GLOB.engineering_positions, color = "#ffd699"),
		"Security" = list(jobs = list(), titles = GLOB.security_positions, color = "#ff9999"),
		"Miscellaneous" = list(jobs = list(), titles = list(), color = "#ffffff", colBreak = 1),
		"Synthetic" = list(jobs = list(), titles = GLOB.nonhuman_positions, color = "#ccffcc"),
		"Support / Service" = list(jobs = list(), titles = GLOB.service_positions, color = "#cccccc"),
		"Medical" = list(jobs = list(), titles = GLOB.medical_positions, color = "#99ffe6", colBreak = 1),
		"Science" = list(jobs = list(), titles = GLOB.science_positions, color = "#e6b3e6"),
		"Supply" = list(jobs = list(), titles = GLOB.supply_positions, color = "#ead4ae"),
		)
	for(var/datum/job/job in SSjobs.occupations)
		if(job && IsJobAvailable(job.title) && !job.barred_by_disability(client))
			num_jobs_available++
			activePlayers[job] = 0
			var/categorized = 0
			// Only players with the job assigned and AFK for less than 10 minutes count as active
			for(var/mob/M in GLOB.player_list) if(M.mind && M.client && M.mind.assigned_role == job.title && M.client.inactivity <= 10 MINUTES)
				activePlayers[job]++
			for(var/jobcat in categorizedJobs)
				var/list/jobs = categorizedJobs[jobcat]["jobs"]
				if(job.title in categorizedJobs[jobcat]["titles"])
					categorized = 1
					if(jobcat == "Command") // Put captain at top of command jobs
						if(job.title == JOB_TITLE_CAPTAIN)
							jobs.Insert(1, job)
						else
							jobs += job
					else // Put heads at top of non-command jobs
						if(job.title in GLOB.command_positions)
							jobs.Insert(1, job)
						else
							jobs += job
			if(!categorized)
				categorizedJobs["Miscellaneous"]["jobs"] += job

	if(num_jobs_available)
		dat += "Выберите из следующих открытых позиций:<br><br>"
		dat += "<table><tr><td valign='top'>"
		for(var/jobcat in categorizedJobs)
			if(categorizedJobs[jobcat]["colBreak"])
				dat += "</td><td valign='top'>"
			if(length(categorizedJobs[jobcat]["jobs"]) < 1)
				continue
			var/color = categorizedJobs[jobcat]["color"]
			dat += "<fieldset style='border: 2px solid [color]; display: inline'>"
			dat += "<legend align='center' style='color: [color]'>[jobcat]</legend>"
			if(jobcat == "Miscellaneous")
				dat += "<a href='byond://?src=[UID()];SelectedJob=RandomJob'>Random (free jobs)</a><br>"
			for(var/datum/job/job in categorizedJobs[jobcat]["jobs"])
				if(job in SSjobs.prioritized_jobs)
					dat += "<a href='byond://?src=[UID()];SelectedJob=[job.title]'><font color='lime'><B>[job.title] ([job.current_positions]) (Active: [activePlayers[job]])</B></font></a><br>"
				else
					dat += "<a href='byond://?src=[UID()];SelectedJob=[job.title]'>[job.title] ([job.current_positions]) (Active: [activePlayers[job]])</a><br>"
			dat += "</fieldset><br>"

		dat += "</td></tr></table></center>"
	else
		dat += "<br><br><center>Unfortunately, there are no job slots free currently.<BR>Wait a few minutes, then try again.<BR>Or, try observing the round.</center>"
	// Removing the old window method but leaving it here for reference
//		src << browse(dat, "window=latechoices;size=300x640;can_close=1")
	// Added the new browser window method
	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 900, 600)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	popup.add_script("delay_interactivity", 'html/browser/delay_interactivity.js')
	popup.set_content(dat)
	popup.open(0) // 0 is passed to open so that it doesn't use the onclose() proc

/mob/new_player/proc/create_character()
	spawning = 1
	close_spawn_windows()

	check_prefs_are_sane()
	var/mob/living/carbon/human/new_character = new(loc)
	new_character.lastarea = get_area(loc)

	if(SSticker.random_players || appearance_isbanned(new_character))
		client.prefs.random_character()
		client.prefs.real_name = random_name(client.prefs.gender)
	client.prefs.copy_to(new_character)

	// stop_sound_channel(CHANNEL_LOBBYMUSIC)
	client?.tgui_panel?.stop_music()


	if(mind)
		mind.active = 0					//we wish to transfer the key manually
		if(mind.assigned_role == JOB_TITLE_CLOWN)				//give them a clownname if they are a clown
			new_character.real_name = pick(GLOB.clown_names)	//I hate this being here of all places but unfortunately dna is based on real_name!
			new_character.rename_self(JOB_TITLE_CLOWN)
		else if(mind.assigned_role == JOB_TITLE_MIME)
			new_character.real_name = pick(GLOB.mime_names)
			new_character.rename_self(JOB_TITLE_MIME)
		mind.set_original_mob(new_character)
		mind.transfer_to(new_character)					//won't transfer key since the mind is not active
		GLOB.human_names_list += new_character.real_name


	new_character.key = key		//Manually transfer the key to log them in

	return new_character

// This is to check that the player only has preferences set that they're supposed to
/mob/new_player/proc/check_prefs_are_sane()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = GLOB.all_species[client.prefs.species]
	if(!chosen_species)
		// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
		log_runtime(EXCEPTION("[src] had species [client.prefs.species], though they weren't supposed to. Setting to Human."), src)
		client.prefs.species = SPECIES_HUMAN

	var/datum/language/chosen_language
	if(client.prefs.language)
		chosen_language = GLOB.all_languages[client.prefs.language]
	if((!chosen_language && client.prefs.language != LANGUAGE_NONE) || (chosen_language && chosen_language.flags & RESTRICTED))
		log_runtime(EXCEPTION("[src] had language [client.prefs.language], though they weren't supposed to. Setting to None."), src)
		client.prefs.language = LANGUAGE_NONE

/mob/new_player/proc/ViewManifest()
	GLOB.generic_crew_manifest.ui_interact(usr)


/mob/new_player/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	return FALSE


/mob/new_player/proc/close_spawn_windows()
	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window
	src << browse(null, "window=preferences") //closes job selection
	src << browse(null, "window=mob_occupation")
	src << browse(null, "window=latechoices") //closes late job selection


/mob/new_player/proc/has_admin_rights()
	return check_rights(R_ADMIN, 0, src)

/mob/new_player/get_gender()
	if(!client || !client.prefs) ..()
	return client.prefs.gender

/mob/new_player/is_ready()
	return ready && ..()

// No hearing announcements
/mob/new_player/can_hear()
	return FALSE

/mob/new_player/mob_negates_gravity()
	return TRUE //no need to calculate if they have gravity.

