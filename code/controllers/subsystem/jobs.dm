SUBSYSTEM_DEF(jobs)
	name = "Jobs"
	init_order = INIT_ORDER_JOBS // 9
	wait = 5 MINUTES // Dont ever make this a super low value since EXP updates are calculated from this value
	runlevels = RUNLEVEL_GAME
	offline_implications = "Время игры на профессиях больше не будет сохраняться. Немедленных действий не требуется."
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "jobs"

	//List of all jobs
	var/list/occupations = list()
	var/list/name_occupations = list()	//Dict of all jobs, keys are titles
	var/list/type_occupations = list()	//Dict of all jobs, keys are types
	var/list/prioritized_jobs = list() // List of jobs set to priority by HoP/Captain
	var/list/id_change_records = list() // List of all job transfer records
	var/id_change_counter = 1
	//Players who need jobs
	var/list/unassigned = list()
	/// Used to grant AI job if antag was rolled.
	var/mob/new_player/new_malf
	//Debug info
	var/list/job_debug = list()


/datum/controller/subsystem/jobs/Initialize()
	SetupOccupations()
	return SS_INIT_SUCCESS


// Only fires every 5 minutes
/datum/controller/subsystem/jobs/fire()
	if(!SSdbcore.IsConnected() || !CONFIG_GET(flag/use_exp_tracking))
		return
	batch_update_player_exp(announce = FALSE) // Set this to true if you ever want to inform players about their EXP gains


/datum/controller/subsystem/jobs/proc/SetupOccupations()
	occupations = list()
	var/list/all_jobs = subtypesof(/datum/job)
	if(!all_jobs.len)
		to_chat(world, "<span class='warning'>Ошибка выдачи профессий, датумы профессий не найдены.</span>")
		return

	for(var/J in all_jobs)
		var/datum/job/job = new J()
		if(!job)
			continue
		occupations += job
		name_occupations[job.title] = job
		type_occupations[J] = job

	LoadJobsFile("config/jobs.txt", FALSE)
	LoadJobsFile("config/jobs_highpop.txt", TRUE)


/datum/controller/subsystem/jobs/proc/ApplyHighpopConfig()
	for(var/datum/job/J in occupations)
		if(J.positions_highpop)
			var/positions_lowpop = J.positions_lowpop
			if(!positions_lowpop)
				positions_lowpop = initial(J.total_positions)
			J.total_positions += (J.positions_highpop - positions_lowpop)


/datum/controller/subsystem/jobs/proc/Debug(text)
	if(GLOB.debug2)
		job_debug.Add(text)


/datum/controller/subsystem/jobs/proc/GetJob(rank)
	return name_occupations[rank]

/datum/controller/subsystem/jobs/proc/GetJobType(jobtype)
	return type_occupations[jobtype]

/datum/controller/subsystem/jobs/proc/GetPlayerAltTitle(mob/new_player/player, rank)
	return player.client.prefs.GetPlayerAltTitle(GetJob(rank))

/datum/controller/subsystem/jobs/proc/AssignRole(mob/new_player/player, rank, latejoin = FALSE)
	Debug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
	if(player && player.mind && rank)
		var/datum/job/job = GetJob(rank)
		if(!job)
			return 0
		if(jobban_isbanned(player, rank))
			return 0
		if(!job.player_old_enough(player.client))
			return 0
		if(job.available_in_playtime(player.client))
			return 0
		if(!job.can_novice_play(player.client))
			return 0
		if(job.barred_by_disability(player.client))
			return 0
		if(!job.character_old_enough(player.client))
			return 0
		if(job.species_in_blacklist(player.client))
			return 0

		var/position_limit = job.total_positions
		if(!latejoin)
			position_limit = job.spawn_positions

		if((job.current_positions < position_limit) || position_limit == -1)
			Debug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
			player.mind.assigned_role = rank
			player.mind.role_alt_title = GetPlayerAltTitle(player, rank)

			// JOB OBJECTIVES OH SHIT
			player.mind.job_objectives.Cut()
			for(var/objectiveType in job.required_objectives)
				new objectiveType(player.mind)

			// 50/50 chance of getting optional objectives.
			for(var/objectiveType in job.optional_objectives)
				if(prob(50))
					new objectiveType(player.mind)

			unassigned -= player
			job.current_positions++
			add_game_logs("Игрок [player.mind.key] вошел в раунд с профессией [rank] ([job.current_positions]/[position_limit])", player)
			return 1

	Debug("AR has failed, Player: [player], Rank: [rank]")
	return 0

/datum/controller/subsystem/jobs/proc/FreeRole(rank)	//making additional slot on the fly
	var/datum/job/job = GetJob(rank)
	if(job && job.current_positions >= job.total_positions && job.total_positions != -1)
		job.total_positions++
		return TRUE
	return FALSE

/datum/controller/subsystem/jobs/proc/FindOccupationCandidates(datum/job/job, level, flag)
	Debug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
	var/list/candidates = list()
	for(var/mob/new_player/player in unassigned)
		Debug(" - Player: [player] Banned: [jobban_isbanned(player, job.title)] Old Enough: [!job.player_old_enough(player.client)] AvInPlaytime: [job.available_in_playtime(player.client)] Flag && Be Special: [flag] && [player.client.prefs.be_special] Job Department: [player.client.prefs.GetJobDepartment(job, level)] Job Flag: [job.flag] Job Department Flag = [job.department_flag]")
		if(jobban_isbanned(player, job.title))
			Debug("FOC isbanned failed, Player: [player]")
			continue
		if(!job.player_old_enough(player.client))
			Debug("FOC player not old enough, Player: [player]")
			continue
		if(job.available_in_playtime(player.client))
			Debug("FOC player not enough playtime, Player: [player]")
			continue
		if(!job.can_novice_play(player.client))
			Debug("FOC player has too much playtime, Player: [player]")
			continue
		if(job.barred_by_disability(player.client))
			Debug("FOC player has disability rendering them ineligible for job, Player: [player]")
			continue
		if(!job.character_old_enough(player.client))
			Debug("FOC player character not old enough rendering them ineligible for job, Player: [player]")
			continue
		if(flag && !(flag in player.client.prefs.be_special))
			Debug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue
		if(player.mind && (job.title in player.mind.restricted_roles))
			Debug("FOC incompatbile with antagonist role, Player: [player]")
			continue
		if(job.species_in_blacklist(player.client))
			Debug("FOC player character race isn't right for job, Player: [player]")
		if(player.client.prefs.GetJobDepartment(job, level) & job.flag)
			Debug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates

/datum/controller/subsystem/jobs/proc/GiveRandomJob(mob/new_player/player)
	Debug("GRJ Giving random job, Player: [player]")
	for(var/datum/job/job in shuffle(occupations))
		if(!job)
			continue

		if(istype(job, GetJob(JOB_TITLE_CIVILIAN))) // We don't want to give him assistant, that's boring!
			continue

		if(job.title in GLOB.command_positions) //If you want a command position, select it!
			continue

		if(job.title in GLOB.whitelisted_positions) // No random whitelisted job, sorry!
			continue

		if(job.admin_only) // No admin positions either.
			continue

		if(jobban_isbanned(player, job.title))
			Debug("GRJ isbanned failed, Player: [player], Job: [job.title]")
			continue

		if(!job.player_old_enough(player.client))
			Debug("GRJ player not old enough, Player: [player]")
			continue

		if(job.available_in_playtime(player.client))
			Debug("GRJ player not enough playtime, Player: [player]")
			continue

		if(!job.can_novice_play(player.client))
			Debug("GRJ player has too much playtime, Player: [player]")
			continue

		if(job.barred_by_disability(player.client))
			Debug("GRJ player has disability rendering them ineligible for job, Player: [player]")
			continue

		if(!job.character_old_enough(player.client))
			Debug("GRJ player character not old enough rendering them ineligible for job, Player: [player]")
			continue

		if(player.mind && (job.title in player.mind.restricted_roles))
			Debug("GRJ incompatible with antagonist role, Player: [player], Job: [job.title]")
			continue

		if(job.species_in_blacklist(player.client))
			Debug("GRJ player character race rendering them ineligible for job, Player: [player]")
			continue

		if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
			Debug("GRJ Random job given, Player: [player], Job: [job]")
			AssignRole(player, job.title)
			unassigned -= player
			break

/datum/controller/subsystem/jobs/proc/ResetOccupations()
	for(var/mob/new_player/player in GLOB.player_list)
		if(player?.mind)
			player.mind.assigned_role = null
			player.mind.special_role = null
			player.mind.offstation_role = FALSE
	for(var/datum/job/job in occupations)
		job.current_positions = initial(job.current_positions)

///This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until it locates a head or runs out of levels to check
/datum/controller/subsystem/jobs/proc/FillHeadPosition()
	for(var/level = 1 to 3)
		for(var/command_position in GLOB.command_positions)
			var/datum/job/job = GetJob(command_position)
			if(!job)
				continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)
				continue

			var/list/filteredCandidates = list()

			for(var/mob/V in candidates)
				// Log-out during round-start? What a bad boy, no head position for you!
				if(!V.client)
					continue
				filteredCandidates += V

			if(!filteredCandidates.len)
				continue

			var/mob/new_player/candidate = pick(filteredCandidates)
			if(AssignRole(candidate, command_position))
				return 1

	return 0


///This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
/datum/controller/subsystem/jobs/proc/CheckHeadPositions(level)
	for(var/command_position in GLOB.command_positions)
		var/datum/job/job = GetJob(command_position)
		if(!job)
			continue
		var/list/candidates = FindOccupationCandidates(job, level)
		if(!candidates.len)
			continue
		var/mob/new_player/candidate = pick(candidates)
		AssignRole(candidate, command_position)


/datum/controller/subsystem/jobs/proc/FillMalfAIPosition()
	if(!CONFIG_GET(flag/allow_ai))
		return FALSE

	var/datum/job/job = GetJob(JOB_TITLE_AI)
	if(!job)
		return FALSE

	if(new_malf && AssignRole(new_malf, JOB_TITLE_AI))
		return TRUE

/** Proc DivideOccupations
*  fills var "assigned_role" for all ready players.
*  This proc must not have any side effect besides of modifying "assigned_role".
**/
/datum/controller/subsystem/jobs/proc/DivideOccupations()
	// Lets roughly time this
	var/watch = start_watch()
	//Setup new player list and get the jobs list
	Debug("Running DO")

	if(!CONFIG_GET(flag/allow_ai))
		for(var/datum/job/ai/A in occupations)
			A.spawn_positions = 0
	else if(SSticker && SSticker.triai) //Holder for Triumvirate is stored in the ticker, this just processes it
		for(var/datum/job/ai/A in occupations)
			A.spawn_positions = 3

	unassigned = list()
	//Get the players who are ready
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.ready && player.mind && !player.mind.assigned_role)
			unassigned += player

	Debug("DO, Len: [unassigned.len]")
	if(unassigned.len == 0)
		return 0

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	HandleFeedbackGathering()

	if(new_malf)	// code to assign malf AI before civs.
		Debug("DO, Running AI Check")
		FillMalfAIPosition()
		Debug("DO, AI Check end")
		new_malf = null

	//People who wants to be assistants, sure, go on.
	Debug("DO, Running Civilian Check 1")
	var/datum/job/civ = new /datum/job/civilian()
	var/list/civilian_candidates = FindOccupationCandidates(civ, 3)
	Debug("AC1, Candidates: [civilian_candidates.len]")
	for(var/mob/new_player/player in civilian_candidates)
		Debug("AC1 pass, Player: [player]")
		AssignRole(player, JOB_TITLE_CIVILIAN)
		civilian_candidates -= player
	Debug("DO, AC1 end")

	//Select one head
	Debug("DO, Running Head Check")
	FillHeadPosition()
	Debug("DO, Head Check end")

	//Other jobs are now checked
	Debug("DO, Running Standard Check")


	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	var/list/shuffledoccupations = shuffle(occupations)
	for(var/level = 1 to 3)
		//Check the head jobs first each level
		CheckHeadPositions(level)

		// Loop through all unassigned players
		for(var/mob/new_player/player in unassigned)

			// Loop through all jobs
			for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
				if(!job)
					continue

				if(jobban_isbanned(player, job.title))
					Debug("DO isbanned failed, Player: [player], Job:[job.title]")
					continue

				if(!job.player_old_enough(player.client))
					Debug("DO player not old enough, Player: [player], Job:[job.title]")
					continue

				if(job.available_in_playtime(player.client))
					Debug("DO player not enough playtime, Player: [player], Job:[job.title]")
					continue

				if(!job.can_novice_play(player.client))
					Debug("DO player has too much playtime, Player: [player], Job:[job.title]")
					continue

				if(job.barred_by_disability(player.client))
					Debug("DO player has disability rendering them ineligible for job, Player: [player], Job:[job.title]")
					continue

				if(!job.character_old_enough(player.client))
					Debug("DO player character not old enough rendering them ineligible for job, Player: [player], Job:[job.title]")
					continue

				if(player.mind && (job.title in player.mind.restricted_roles))
					Debug("DO incompatible with antagonist role, Player: [player], Job:[job.title]")
					continue
				if(job.species_in_blacklist(player.client))
					Debug("DO player character race rendering them ineligible for job, Player: [player]")
					continue

				// If the player wants that job on this level, then try give it to him.
				if(player.client.prefs.GetJobDepartment(job, level) & job.flag)

					// If the job isn't filled
					if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
						Debug("DO pass, Player: [player], Level:[level], Job:[job.title]")
						Debug(" - Job Flag: [job.flag] Job Department: [player.client.prefs.GetJobDepartment(job, level)] Job Current Pos: [job.current_positions] Job Spawn Positions = [job.spawn_positions]")
						AssignRole(player, job.title)
						unassigned -= player
						break

	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/mob/new_player/player in unassigned)
		if(player.client.prefs.alternate_option == GET_RANDOM_JOB)
			GiveRandomJob(player)

	Debug("DO, Standard Check end")

	Debug("DO, Running AC2")

	// Antags, who have to get in, come first
	for(var/mob/new_player/player in unassigned)
		if(player.mind.special_role)
			if(player.client.prefs.alternate_option != BE_ASSISTANT)
				GiveRandomJob(player)
				if(player in unassigned)
					AssignRole(player, JOB_TITLE_CIVILIAN)
			else
				AssignRole(player, JOB_TITLE_CIVILIAN)

	// Then we assign what we can to everyone else.
	for(var/mob/new_player/player in unassigned)
		if(player.client.prefs.alternate_option == BE_ASSISTANT)
			Debug("AC2 Assistant located, Player: [player]")
			AssignRole(player, JOB_TITLE_CIVILIAN)
		else if(player.client.prefs.alternate_option == RETURN_TO_LOBBY)
			to_chat(player, "<span class='danger'>Unfortunately, none of the round start roles you selected had a free slot. Please join the game by using \"Join Game!\" button and selecting a role with a free slot.</span>")
			player.ready = 0
			unassigned -= player

	log_debug("Dividing Occupations took [stop_watch(watch)]s")
	return 1

/datum/controller/subsystem/jobs/proc/AssignRank(mob/living/carbon/human/H, rank, joined_late = FALSE)
	if(!H)
		return null
	var/datum/job/job = GetJob(rank)

	H.job = rank

	var/alt_title = null

	if(H.mind)
		H.mind.assigned_role = rank
		alt_title = H.mind.role_alt_title

		CreateMoneyAccount(H, rank, job)
	var/list/L = list()
	L.Add("<B>Вы <span class='red'>[alt_title ? alt_title : rank]</span>.</B>")
	L.Add("<b>На этой должности вы отвечаете непосредственно перед <span class='red'>[replacetext(job.supervisors,"the ","")]</span>. Особые обстоятельства могут это изменить.</b>")
	L.Add("<b>Для получения дополнительной информации о работе на станции, см. <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Standard_Operating_Procedure\">Стандартные Рабочие Процедуры (СРП)</a></b>")
	if(job.is_service)
		L.Add("<b>Будучи работником отдела Обслуживания, убедитесь что прочли <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Standard_Operating_Procedure_&#40;Service&#41\">СРП своего отдела</a></b>")
	if(job.is_supply)
		L.Add("<b>Будучи работником отдела Снабжения, убедитесь что прочли <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Standard_Operating_Procedure_&#40;Supply&#41\">СРП своего отдела</a></b>")
	if(job.is_command)
		L.Add("<b>Будучи важным членом Командования, убедитесь что прочли <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Standard_Operating_Procedure_&#40;Command&#41\">СРП своего отдела</a></b>")
	if(job.is_legal)
		L.Add("<b>Ваша должность требует полного знания <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Space_Law\">Космического Закона</a> и <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Legal_Standard_Operating_Procedure\">Правовых Стандартных Рабочих Процедур</a></b>")
	if(job.is_engineering)
		L.Add("<b>Будучи работником Инженерного отдела, убедитесь что прочли <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Standard_Operating_Procedure_&#40;Engineering&#41\">СРП своего отдела</a></b>")
	if(job.is_medical)
		L.Add("<b>Будучи работником Медицинского отдела, убедитесь что прочли <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Standard_Operating_Procedure_&#40;Medical&#41\">СРП своего отдела</a></b>")
	if(job.is_science)
		L.Add("<b>Будучи работником Научного отдела, убедитесь что прочли <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Standard_Operating_Procedure_&#40;Science&#41\">СРП своего отдела</a></b>")
	if(job.is_security)
		L.Add("<b>Будучи работником Службы Безопасности, вам необходимо знание <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Space_Law\">Космического Закона</a>, <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Legal_Standard_Operating_Procedure\">Правовых СРП</a>, а также <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Standard_Operating_Procedure_&#40;Security&#41\">СРП своего отдела</a></b>")
	if(job.req_admin_notify)
		L.Add("<b>Вы играете на важной для игрового процесса должности. Если вам необходимо покинуть игру, пожалуйста, используйте крио и проинформируйте командование. Если вы не можете это сделать, пожалуйста, проинформируйте админов через админхэлп.</b>")
	if(job.is_novice)
		L.Add("<b>Ваша должность ограничена во всех взаимодействиях с рабочим имуществом отдела и экипажем станции, при отсутствии приставленного к нему квалифицированного сотрудника или полученного разрешения от вышестоящего начальства. Не забудьте ознакомиться с СРП вашей должности. По истечению срока прохождения стажировки, данная должность более не будет вам доступна. Используйте её для обучения, не стесняйтесь задавать вопросы вашим старшим коллегам!</b>")

	to_chat(H, chat_box_green(L.Join("<br>")))

	return H

/datum/controller/subsystem/jobs/proc/EquipRank(mob/living/carbon/human/H, rank, joined_late = FALSE) // Equip and put them in an area
	if(!H)
		return null

	var/datum/job/job = GetJob(rank)

	H.job = rank

	if(!joined_late)
		var/turf/turf_spawn = null
		var/obj/mark_spawn = null
		for(var/obj/effect/landmark/start/sloc in GLOB.landmarks_list)
			if(sloc.name != rank)
				continue
			if(locate(/mob/living) in sloc.loc)
				continue
			mark_spawn = sloc
			break
		if(!mark_spawn)
			mark_spawn = locate("start*[rank]") // use old stype
		if(!mark_spawn) // No spawn, then spawn on latejoin mark
			log_runtime(EXCEPTION("No landmark start for [rank]."))
			mark_spawn = pick(GLOB.latejoin)
		if(!mark_spawn) // still no spawn, fall back to the arrivals shuttle
			var/list/turf/possible_turfs = list()
			for(var/turf/TS in get_area_turfs(/area/shuttle/arrival/station))
				if(TS.density)
					continue
				for(var/obj/O in TS)
					if(O.density)
						continue
				possible_turfs += TS
			mark_spawn = pick(possible_turfs)

		if(isturf(mark_spawn))
			turf_spawn = mark_spawn
		else if(istype(mark_spawn, /obj/effect/landmark/start) && isturf(mark_spawn.loc))
			turf_spawn = mark_spawn.loc
		else
			message_admins("Couldn't find spawnpoint for [H] [ADMIN_COORDJMP(H)]. Notify mapper about it.")

		if(turf_spawn)
			H.forceMove(turf_spawn)
			// Moving wheelchair if they have one
			if(H.buckled && istype(H.buckled, /obj/structure/chair/wheelchair))
				H.buckled.forceMove(H.loc)
				H.buckled.dir = H.dir

	if(job)
		var/new_mob = job.equip(H)
		if(ismob(new_mob))
			H = new_mob

	if(job && H)
		job.after_spawn(H)

		//Gives glasses to the vision impaired
		if(HAS_TRAIT(H, TRAIT_NEARSIGHTED))
			var/equipped = H.equip_to_slot_or_del(new /obj/item/clothing/glasses/regular(H), ITEM_SLOT_EYES)
			if(equipped != 1)
				var/obj/item/clothing/glasses/G = H.glasses
				if(istype(G) && !G.prescription)
					G.upgrade_prescription()
					H.update_nearsighted_effects()

		if(!issilicon(H))
			// Wheelchair necessary?
			var/obj/item/organ/external/l_foot = H.get_organ(BODY_ZONE_PRECISE_L_FOOT)
			var/obj/item/organ/external/r_foot = H.get_organ(BODY_ZONE_PRECISE_R_FOOT)
			if(!l_foot && !r_foot || (H.client.prefs.disabilities & DISABILITY_FLAG_PARAPLEGIA) && !(H.dna.species.blacklisted_disabilities & DISABILITY_FLAG_PARAPLEGIA))
				var/obj/structure/chair/wheelchair/W = new /obj/structure/chair/wheelchair(H.loc)
				W.buckle_mob(H, TRUE)
	return H


/datum/controller/subsystem/jobs/proc/LoadJobsFile(jobsfile, highpop) //ran during round setup, reads info from jobs.txt -- Urist
	if(!CONFIG_GET(flag/load_jobs_from_txt))
		return

	var/list/jobEntries = file2list(jobsfile)

	for(var/job in jobEntries)
		if(!job)
			continue

		job = trim(job)
		if(!length(job))
			continue

		var/pos = findtext(job, "=")

		if(!pos)
			continue
		var/name = copytext(job, 1, pos)
		var/value = copytext(job, pos + 1)

		if(name && value)
			if(name == JOB_TITLE_AI)  //AI use diferent config
				continue
			var/datum/job/J = GetJob(name)
			if(!J)
				continue
			if(highpop)
				J.positions_highpop = text2num(value)
			else
				J.positions_lowpop = text2num(value)
				J.spawn_positions = J.positions_lowpop
				J.total_positions = J.positions_lowpop

/datum/controller/subsystem/jobs/proc/HandleFeedbackGathering()
	for(var/datum/job/job in occupations)

		var/high = 0 //high
		var/medium = 0 //medium
		var/low = 0 //low
		var/never = 0 //never
		var/banned = 0 //banned
		var/young = 0 //account too young
		var/charyoung = 0 //character too young
		var/disabled = 0 //has disability rendering them ineligible
		for(var/mob/new_player/player in GLOB.player_list)
			if(!(player.ready && player.mind && !player.mind.assigned_role))
				continue //This player is not ready
			if(jobban_isbanned(player, job.title))
				banned++
				continue
			if(!job.player_old_enough(player.client))
				young++
				continue
			if(job.available_in_playtime(player.client))
				young++
				continue
			if(job.barred_by_disability(player.client))
				disabled++
				continue
			if(!job.character_old_enough(player.client))
				charyoung++
				continue
			if(player.client.prefs.GetJobDepartment(job, 1) & job.flag)
				high++
			else if(player.client.prefs.GetJobDepartment(job, 2) & job.flag)
				medium++
			else if(player.client.prefs.GetJobDepartment(job, 3) & job.flag)
				low++
			else never++ //not selected

		SSblackbox.record_feedback("nested tally", "job_preferences", high, list("[job.title]", "high"))
		SSblackbox.record_feedback("nested tally", "job_preferences", medium, list("[job.title]", "medium"))
		SSblackbox.record_feedback("nested tally", "job_preferences", low, list("[job.title]", "low"))
		SSblackbox.record_feedback("nested tally", "job_preferences", never, list("[job.title]", "never"))
		SSblackbox.record_feedback("nested tally", "job_preferences", banned, list("[job.title]", "banned"))
		SSblackbox.record_feedback("nested tally", "job_preferences", young, list("[job.title]", "young"))
		SSblackbox.record_feedback("nested tally", "job_preferences", disabled, list("[job.title]", "disabled"))
		SSblackbox.record_feedback("nested tally", "job_preferences", charyoung, list("[job.title]", "charyoung"))


/datum/controller/subsystem/jobs/proc/CreateMoneyAccount(mob/living/H, rank, datum/job/job)
	var/money_amount = rand(job.min_start_money, job.max_start_money)
	var/datum/money_account/M = create_account(H.real_name, money_amount, null, job, TRUE)
	if (H.dna)
		GLOB.dna2account[H.dna] = M
	var/remembered_info = ""

	remembered_info += "<b>Номер вашего аккаунта:</b> #[M.account_number]<br>"
	remembered_info += "<b>ПИН вашего аккаунта:</b> [M.remote_access_pin]<br>"
	remembered_info += "<b>Баланс вашего аккаунта:</b> $[M.money]<br>"

	if(M.transaction_log.len)
		var/datum/transaction/T = M.transaction_log[1]
		remembered_info += "<b>Ваш аккаунт был создан:</b> [T.time], [T.date] на [T.source_terminal]<br>"
	H.mind.store_memory(remembered_info)

	// If they're head, give them the account info for their department
	if(job && job.head_position)
		remembered_info = ""
		var/datum/money_account/department_account = GLOB.department_accounts[job.department]

		if(department_account)
			remembered_info += "<b>Номер аккаунта вашего отдела:</b> #[department_account.account_number]<br>"
			remembered_info += "<b>ПИН аккаунта вашего отдела:</b> [department_account.remote_access_pin]<br>"
			remembered_info += "<b>Баланс аккаунта вашего отдела:</b> $[department_account.money]<br>"

		H.mind.store_memory(remembered_info)

	H.mind.initial_account = M

	H.mind.initial_account.insurance_type = job.insurance_type
	switch (job.insurance_type)
		if (INSURANCE_TYPE_NONE)
			H.mind.initial_account.insurance = INSURANCE_NONE
		if (INSURANCE_TYPE_BUDGETARY)
			H.mind.initial_account.insurance = INSURANCE_BUDGETARY
		if (INSURANCE_TYPE_STANDART)
			H.mind.initial_account.insurance = INSURANCE_STANDART
		if (INSURANCE_TYPE_EXTENDED)
			H.mind.initial_account.insurance = INSURANCE_EXTENDED
		if (INSURANCE_TYPE_DELUXE)
			H.mind.initial_account.insurance = INSURANCE_DELUXE
		if (INSURANCE_TYPE_NT_SPECIAL)
			H.mind.initial_account.insurance = INSURANCE_NT_SPECIAL

	spawn(0)
		to_chat(H, "<span class='boldnotice'>Номер вашего аккаунта: [M.account_number], ПИН вашего аккаунта: [M.remote_access_pin]</span>")

/datum/controller/subsystem/jobs/proc/format_jobs_for_id_computer(obj/item/card/id/tgtcard)
	var/list/jobs_to_formats = list()
	if(tgtcard)
		var/mob/M = tgtcard.getPlayer()
		for(var/datum/job/job in occupations)
			if(tgtcard.rank && tgtcard.rank == job.title)
				jobs_to_formats[job.title] = "green" // the job they already have is pre-selected
			else if(tgtcard.assignment == "Demoted" || tgtcard.assignment == "Terminated")
				jobs_to_formats[job.title] = "grey"
			else if(!job.would_accept_job_transfer_from_player(M))
				jobs_to_formats[job.title] = "grey" // jobs which are karma-locked and not unlocked for this player are discouraged
			else if((job.title in GLOB.command_positions) && istype(M) && M.client && job.available_in_playtime(M.client))
				jobs_to_formats[job.title] = "grey" // command jobs which are playtime-locked and not unlocked for this player are discouraged
			else if(job.total_positions && !job.current_positions && job.title != JOB_TITLE_CIVILIAN)
				jobs_to_formats[job.title] = "teal" // jobs with nobody doing them at all are encouraged
			else if(job.total_positions >= 0 && job.current_positions >= job.total_positions)
				jobs_to_formats[job.title] = "grey" // jobs that are full (no free positions) are discouraged
		if(tgtcard.assignment == "Demoted" || tgtcard.assignment == "Terminated")
			jobs_to_formats["Custom"] = "grey"
	return jobs_to_formats



/datum/controller/subsystem/jobs/proc/log_job_transfer(transferee, oldvalue, newvalue, whodidit, reason)
	id_change_records["[id_change_counter]"] = list(
		"transferee" = transferee,
		"oldvalue" = oldvalue,
		"newvalue" = newvalue,
		"whodidit" = whodidit,
		"timestamp" = station_time_timestamp(),
		"reason" = reason
	)
	id_change_counter++

/datum/controller/subsystem/jobs/proc/slot_job_transfer(oldtitle, newtitle)
	var/datum/job/oldjobdatum = SSjobs.GetJob(oldtitle)
	var/datum/job/newjobdatum = SSjobs.GetJob(newtitle)
	if(istype(oldjobdatum) && oldjobdatum.current_positions > 0 && istype(newjobdatum))
		if(!(oldjobdatum.title in GLOB.command_positions) && !(newjobdatum.title in GLOB.command_positions))
			oldjobdatum.current_positions--
			newjobdatum.current_positions++

/datum/controller/subsystem/jobs/proc/account_job_transfer(name_owner, job_title, salary_capcap = TRUE)

	var/datum/money_account/account_job = get_account_with_name(name_owner)

	if(account_job)
		account_job.linked_job = SSjobs.GetJob(job_title)
		account_job.salary_payment_active = salary_capcap

/datum/controller/subsystem/jobs/proc/notify_dept_head(jobtitle, antext)
	// Used to notify the department head of jobtitle X that their employee was brigged, demoted or terminated
	if(!jobtitle || !antext)
		return
	var/datum/job/tgt_job = GetJob(jobtitle)
	if(!tgt_job)
		return
	if(!tgt_job.department_head[1])
		return
	var/boss_title = tgt_job.department_head[1]
	var/obj/item/pda/target_pda
	for(var/obj/item/pda/check_pda in GLOB.PDAs)
		if(check_pda.ownrank == boss_title)
			target_pda = check_pda
			break
	if(!target_pda)
		return
	var/datum/data/pda/app/messenger/PM = target_pda.find_program(/datum/data/pda/app/messenger)
	if(PM && PM.can_receive())
		PM.notify("<b>Автоматическое Оповещение: </b>\"[antext]\" (Невозможно Ответить)", 0) // the 0 means don't make the PDA flash

/datum/controller/subsystem/jobs/proc/notify_by_name(target_name, antext)
	// Used to notify a specific crew member based on their real_name
	if(!target_name || !antext)
		return
	var/obj/item/pda/target_pda
	for(var/obj/item/pda/check_pda in GLOB.PDAs)
		if(check_pda.owner == target_name)
			target_pda = check_pda
			break
	if(!target_pda)
		return
	var/datum/data/pda/app/messenger/PM = target_pda.find_program(/datum/data/pda/app/messenger)
	if(PM && PM.can_receive())
		PM.notify("<b>Автоматическое Оповещение: </b>\"[antext]\" (Невозможно Ответить)", 0) // the 0 means don't make the PDA flash

/datum/controller/subsystem/jobs/proc/format_job_change_records(centcom)
	var/list/formatted = list()
	for(var/thisid in id_change_records)
		var/thisrecord = id_change_records[thisid]
		if(thisrecord["deletedby"] && !centcom)
			continue
		var/list/newlist = list()
		for(var/lkey in thisrecord)
			newlist[lkey] = thisrecord[lkey]
		formatted.Add(list(newlist))
	return formatted


/datum/controller/subsystem/jobs/proc/delete_log_records(sourceuser, delete_all)
	. = 0
	if(!sourceuser)
		return
	var/list/new_id_change_records = list()
	for(var/thisid in id_change_records)
		var/thisrecord = id_change_records[thisid]
		if(!thisrecord["deletedby"])
			if(delete_all || thisrecord["whodidit"] == sourceuser)
				thisrecord["deletedby"] = sourceuser
				.++
		new_id_change_records["[id_change_counter]"] = thisrecord
		id_change_counter++
	id_change_records = new_id_change_records

// This proc will update all players EXP at once. It will calculate amount of time to add dynamically based on the SS fire time.
/datum/controller/subsystem/jobs/proc/batch_update_player_exp(announce = FALSE)
	// Right off the bat
	var/start_time = start_watch()
	// First calculate minutes
	var/divider = 10 // By default, 10 deciseconds in 1 second
	if(flags & SS_TICKER)
		divider = 20 // If this SS ever gets made into a ticker SS, account for that

	var/minutes = (wait / divider) / 60 // Calculate minutes based on the SS wait time (How often this proc fires)

	// Step 1: Get us a list of clients to process
	var/list/client/clients_to_process = GLOB.clients.Copy() // This is copied so that clients joining in the middle of this dont break things
	Debug("Starting EXP update for [length(clients_to_process)] clients. (Adding [minutes] minutes)")

	var/list/datum/db_query/select_queries = list() // List of SELECT queries to mass grab EXP.

	for(var/i in clients_to_process)
		var/client/C = i
		if(!C)
			continue // If a client logs out in the middle of this

		var/datum/db_query/exp_read = SSdbcore.NewQuery(
			"SELECT exp FROM [format_table_name("player")] WHERE ckey=:ckey",
			list("ckey" = C.ckey)
		)

		select_queries[C.ckey] = exp_read

	var/list/read_records = list()
	// Explanation for parameters:
	// TRUE: We want warnings if these fail
	// FALSE: Do NOT qdel() queries here, otherwise they wont be read. At all.
	// TRUE: This is an assoc list, so it needs to prepare for that
	// FALSE: We dont want to logspam
	SSdbcore.MassExecute(select_queries, TRUE, FALSE, TRUE, FALSE) // Batch execute so we can take advantage of async magic

	for(var/i in clients_to_process)
		var/client/C = i
		if(!C)
			continue // If a client logs out in the middle of this

		if(select_queries[C.ckey]) // This check should not be necessary, but I am paranoid
			while(select_queries[C.ckey].NextRow())
				read_records[C.ckey] = params2list(select_queries[C.ckey].item[1])

	QDEL_LIST_ASSOC_VAL(select_queries) // Clean stuff up

	var/list/play_records = list()

	var/list/datum/db_query/player_update_queries = list() // List of queries to update player EXP
	var/list/datum/db_query/playtime_history_update_queries = list() // List of queries to update the playtime history table

	for(var/i in clients_to_process)
		var/client/C = i
		if(!C)
			continue // If a client logs out in the middle of this
		// Get us a container
		play_records[C.ckey] = list()
		for(var/rtype in GLOB.exp_jobsmap)
			if(text2num(read_records[C.ckey][rtype]))
				play_records[C.ckey][rtype] = text2num(read_records[C.ckey][rtype])
			else
				play_records[C.ckey][rtype] = 0


		var/myrole
		if(C.mob.mind)
			if(C.mob.mind.playtime_role)
				myrole = C.mob.mind.playtime_role
			else if(C.mob.mind.assigned_role)
				myrole = C.mob.mind.assigned_role

		var/added_living = 0
		var/added_ghost = 0
		if(C.mob.stat == CONSCIOUS && myrole)
			play_records[C.ckey][EXP_TYPE_LIVING] += minutes
			added_living += minutes

			if(announce)
				to_chat(C.mob, "<span class='notice'>You got: [minutes] Living EXP!</span>")

			for(var/category in GLOB.exp_jobsmap)
				if(GLOB.exp_jobsmap[category]["titles"])
					if(myrole in GLOB.exp_jobsmap[category]["titles"])
						play_records[C.ckey][category] += minutes
						if(announce)
							to_chat(C.mob, "<span class='notice'>You got: [minutes] [category] EXP!</span>")

			if(C.mob.mind.special_role)
				play_records[C.ckey][EXP_TYPE_SPECIAL] += minutes
				if(announce)
					to_chat(C.mob, "<span class='notice'>You got: [minutes] Special EXP!</span>")

		else if(isobserver(C.mob))
			play_records[C.ckey][EXP_TYPE_GHOST] += minutes
			added_ghost += minutes
			if(announce)
				to_chat(C.mob, "<span class='notice'>You got: [minutes] Ghost EXP!</span>")
		else
			continue

		var/new_exp = list2params(play_records[C.ckey])

		C.prefs.exp = new_exp

		var/datum/db_query/update_query = SSdbcore.NewQuery(
			"UPDATE [format_table_name("player")] SET exp =:newexp, lastseen=NOW() WHERE ckey=:ckey",
			list(
				"newexp" = new_exp,
				"ckey" = C.ckey
			)
		)

		player_update_queries += update_query

		var/datum/db_query/update_query_history = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("playtime_history")] (ckey, date, time_living, time_ghost)
			VALUES (:ckey, CURDATE(), :addedliving, :addedghost)
			ON DUPLICATE KEY UPDATE time_living=time_living + VALUES(time_living), time_ghost=time_ghost + VALUES(time_ghost)"},
			list(
				"ckey" = C.ckey,
				"addedliving" = added_living,
				"addedghost" = added_ghost
			)
		)

		playtime_history_update_queries += update_query_history


	// warn=TRUE, qdel=TRUE, assoc=FALSE, log=FALSE
	SSdbcore.MassExecute(player_update_queries, TRUE, TRUE, FALSE, FALSE) // Batch execute so we can take advantage of async magic
	SSdbcore.MassExecute(playtime_history_update_queries, TRUE, TRUE, FALSE, FALSE)

	Debug("Successfully updated all EXP data in [stop_watch(start_time)]s")
