SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME
	offline_implications = "The game is no longer aware of when the round ends. Immediate server restart recommended."
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "ticker"

	/// Time the world started, relative to world.time
	var/round_start_time = 0
	/// Time that the round started
	var/time_game_started = 0
	/// Default timeout for if world.Reboot() doesnt have a time specified
	var/const/restart_timeout = 120 SECONDS
	/// Current status of the game. See code\__DEFINES\game.dm
	var/current_state = GAME_STATE_STARTUP
	/// Do we want to force-start as soon as we can
	var/force_start = FALSE
	/// Do we want to force-end as soon as we can
	var/force_ending = FALSE
	/// Leave here at FALSE ! setup() will take care of it when needed for Secret mode -walter0o
	var/hide_mode = FALSE
	/// Our current game mode
	var/datum/game_mode/mode = null
	/// The current pick of lobby music played in the lobby
	var/login_music
	var/login_music_data
	var/selected_lobby_music
	/// List of all minds in the game. Used for objective tracking
	var/list/datum/mind/minds = list()
	/// icon_state the chaplain has chosen for his bible
	var/Bible_icon_state
	/// item_state the chaplain has chosen for his bible
	var/Bible_item_state
	/// Name of the bible
	var/Bible_name
	/// Name of the bible deity
	var/Bible_deity_name
	/// Cult data. Here instead of cult for adminbus purposes
	var/datum/cult_info/cultdat = null
	/// If set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders
	var/random_players = FALSE
	/// Did we broadcast the tip of the round yet?
	var/tipped = FALSE
	/// What will be the tip of the round?
	var/selected_tip
	/// This is used for calculations for the statpanel
	var/pregame_timeleft
	/// If set to TRUE, the round will not restart on it's own
	var/delay_end = FALSE
	/// Global holder for triple AI mode
	var/triai = FALSE
	/// Holder for inital autotransfer vote timer
	var/next_autotransfer = 0
	/// Spam Prevention. Announce round end only once.
	var/round_end_announced = FALSE
	/// Is the ticker currently processing? If FALSE, roundstart is delayed
	var/ticker_going = TRUE
	/// Gamemode result (For things like shadowlings or nukies which can end multiple ways)
	var/mode_result = "undefined"
	/// Server end state (Did we end properly or reboot or nuke or what)
	var/end_state = "undefined"
	/// Time the real reboot kicks in
	var/real_reboot_time = 0
	/// Datum used to generate the end of round scoreboard.
	var/datum/scoreboard/score = null
	/// Do we need to switch pacifism after Greentext
	var/toggle_pacifism = TRUE
	/// Do we need to make ghosts visible after greentext
	var/toogle_gv = TRUE
	/// List of ckeys who had antag rolling issues flagged
	var/list/flagged_antag_rollers = list()

	var/list/randomtips = list()
	var/list/memetips = list()

	var/music_available = 0

/datum/controller/subsystem/ticker/Initialize()
	login_music_data = list()
	login_music = choose_lobby_music()

	if(!login_music)
		to_chat(world, span_boldwarning("Could not load lobby music.")) //yogs end

	randomtips = file2list("strings/tips.txt")
	memetips = file2list("strings/sillytips.txt")
	return SS_INIT_SUCCESS


/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			// This is ran as soon as the MC starts firing, and should only run ONCE, unless startup fails
			round_start_time = world.time + (CONFIG_GET(number/pregame_timestart) SECONDS)
			to_chat(world, "<B><span class='darkmblue'>Welcome to the pre-game lobby!</span></B>")
			to_chat(world, "Please, setup your character and select ready. Game will start in [CONFIG_GET(number/pregame_timestart)] seconds")
			current_state = GAME_STATE_PREGAME
			fire() // TG says this is a good idea
		if(GAME_STATE_PREGAME)
			if(!SSticker.ticker_going) // This has to be referenced like this, and I dont know why. If you dont put SSticker. it will break
				return

			// This is so we dont have sleeps in controllers, because that is a bad, bad thing
			if(!delay_end)
				pregame_timeleft = max(0, round_start_time - world.time) // Normal lobby countdown when roundstart was not delayed
			else
				pregame_timeleft = max(0, pregame_timeleft - 20) // If roundstart was delayed, we should resume the countdown where it left off

			if(pregame_timeleft <= 600 && !tipped) // 60 seconds
				send_tip_of_the_round()
				tipped = TRUE

			if(pregame_timeleft <= 0 || force_start)
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
		if(GAME_STATE_SETTING_UP)
			if(!setup()) // Setup failed
				current_state = GAME_STATE_STARTUP
				Master.SetRunLevel(RUNLEVEL_LOBBY)
		if(GAME_STATE_PLAYING)
			delay_end = FALSE // reset this in case round start was delayed
			mode.process()
			mode.process_job_tasks()

			if(world.time > next_autotransfer)
				SSvote.start_vote(new /datum/vote/crew_transfer)
				next_autotransfer = world.time + CONFIG_GET(number/vote_autotransfer_interval)

			var/game_finished = SSshuttle.emergency.mode == SHUTTLE_ENDGAME || mode.station_was_nuked
			if(CONFIG_GET(flag/continuous_rounds))
				mode.check_finished() // some modes contain var-changing code in here, so call even if we don't uses result
			else
				game_finished |= mode.check_finished()
			if(game_finished || force_ending)
				current_state = GAME_STATE_FINISHED
		if(GAME_STATE_FINISHED)
			current_state = GAME_STATE_FINISHED
			Master.SetRunLevel(RUNLEVEL_POSTGAME) // This shouldnt process more than once, but you never know
			auto_toggle_ooc(TRUE) // Turn it on

			declare_completion()

			addtimer(CALLBACK(src, PROC_REF(call_reboot)), 5 SECONDS)

			if(!SSmapping.next_map) //Next map already selected by admin
				var/list/all_maps = subtypesof(/datum/map)
				for(var/x in all_maps)
					var/datum/map/M = x
					if(initial(M.admin_only))
						all_maps -= M
				switch(CONFIG_GET(string/map_rotate))
					if("rotate")
						for(var/i in 1 to all_maps.len)
							if(istype(SSmapping.map_datum, all_maps[i]))
								var/target_map = all_maps[(i % all_maps.len) + 1]
								SSmapping.next_map = new target_map
								break
					if("random")
						var/target_map = pick(all_maps)
						SSmapping.next_map = new target_map
					if("vote")
						SSvote.start_vote(new /datum/vote/map)
					else
						SSmapping.next_map = SSmapping.map_datum
			if(SSmapping.next_map)
				to_chat(world, "<B>The next map is - [SSmapping.next_map.name]!</B>")


/datum/controller/subsystem/ticker/proc/call_reboot()
	if(mode.station_was_nuked)
		reboot_helper("Station destroyed by Nuclear Device.", "nuke")
	else
		reboot_helper("Round ended.", "proper completion")


/datum/controller/subsystem/ticker/proc/setup()
	cultdat = setupcult()
	score = new()

	// Create and announce mode
	if(GLOB.master_mode == "secret")
		hide_mode = TRUE

	var/list/datum/game_mode/runnable_modes

	if(GLOB.master_mode == "random" || GLOB.master_mode == "secret")
		runnable_modes = config.get_runnable_modes()
		if(!length(runnable_modes))
			to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
			force_start = FALSE
			current_state = GAME_STATE_PREGAME
			Master.SetRunLevel(RUNLEVEL_LOBBY)
			return FALSE
		if(GLOB.secret_force_mode != "secret")
			var/datum/game_mode/M = config.pick_mode(GLOB.secret_force_mode)
			if(M.can_start())
				mode = config.pick_mode(GLOB.secret_force_mode)
		if(!mode)
			mode = pickweight(runnable_modes)
		if(mode)
			var/mtype = mode.type
			mode = new mtype
	else
		mode = config.pick_mode(GLOB.master_mode)

	if(!mode.can_start())
		to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [CONFIG_GET(flag/enable_gamemode_player_limit) ? config.mode_required_players[mode.config_tag] : mode.required_enemies] players needed. Reverting to pre-game lobby.")
		mode = null
		current_state = GAME_STATE_PREGAME
		force_start = FALSE
		Master.SetRunLevel(RUNLEVEL_LOBBY)

		world.check_for_lowpop()

		return FALSE

	// Randomise characters now. This avoids rare cases where a human is set as a changeling then they randomise to an IPC
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.client.prefs.toggles2 & PREFTOGGLE_2_RANDOMSLOT)
			player.client.prefs.load_random_character_slot(player.client)

	// Lets check if people who ready should or shouldnt be
	for(var/mob/new_player/P in GLOB.player_list)
		// Not logged in
		if(!P.client)
			continue
		// Not ready
		if(!P.ready)
			continue
		// Not set to return if nothing available
		if(P.client.prefs.alternate_option != RETURN_TO_LOBBY)
			continue

		var/has_antags = (length(P.client.prefs.be_special) > 0)
		if(!P.client.prefs.check_any_job())
			to_chat(P, "<span class='danger'>You have no jobs enabled, along with return to lobby if job is unavailable. This makes you ineligible for any round start role, please update your job preferences.</span>")
			if(has_antags)
				// We add these to a list so we can deal with them as a batch later
				flagged_antag_rollers |= P.ckey

			P.ready = FALSE

	var/can_continue = FALSE
	can_continue = mode.pre_setup() //Setup special modes
	if(!can_continue)
		QDEL_NULL(mode)
		to_chat(world, "<B>Error setting up [GLOB.master_mode].</B> Reverting to pre-game lobby.")
		current_state = GAME_STATE_PREGAME
		force_start = FALSE
		SSjobs.ResetOccupations()
		Master.SetRunLevel(RUNLEVEL_LOBBY)
		return FALSE

	// Enable highpop slots just before we distribute jobs.
	var/playercount = length(GLOB.clients)
	var/highpop_trigger = CONFIG_GET(number/jobs_high_pop_mode_amount)
	if(playercount >= highpop_trigger)
		log_debug("Playercount: [playercount] versus trigger: [highpop_trigger] - loading highpop job config")
		SSjobs.ApplyHighpopConfig()
	else
		log_debug("Playercount: [playercount] versus trigger: [highpop_trigger] - keeping standard job config")

	SSjobs.DivideOccupations() //Distribute jobs

	if(hide_mode)
		var/list/modes = new
		for(var/datum/game_mode/M in runnable_modes)
			modes += M.name
		modes = sortList(modes)
		to_chat(world, "<B>The current game mode is - Secret!</B>")
		to_chat(world, "<B>Possibilities:</B> [english_list(modes)]")
	else
		mode.announce()

	// Behold, a rough way of figuring out what takes 10 years
	var/watch = start_watch()
	create_characters() // Create player characters and transfer clients
	log_debug("Creating characters took [stop_watch(watch)]s")

	watch = start_watch()
	populate_spawn_points() // Put mobs in their spawn locations
	log_debug("Populating spawn points took [stop_watch(watch)]s")

	// Gather everyones minds
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind)
			minds += player.mind

	watch = start_watch()
	equip_characters() // Apply outfits and loadouts to the characters
	log_debug("Equipping characters took [stop_watch(watch)]s")

	watch = start_watch()
	GLOB.data_core.manifest() // Create the manifest
	log_debug("Manifest creation took [stop_watch(watch)]s")

	// Update the MC and state to game playing
	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)

	// Generate the list of empty playable AI cores in the world
	for(var/obj/effect/landmark/start/S in GLOB.landmarks_list)
		if(S.name != JOB_TITLE_AI)
			continue
		if(locate(/mob/living) in S.loc)
			continue
		GLOB.empty_playable_ai_cores += new /obj/structure/AIcore/deactivated(get_turf(S))


	// Setup pregenerated newsfeeds
	setup_news_feeds()

	// Generate code phrases and responses
	if(!GLOB.syndicate_code_phrase)
		var/list/temp_syndicate_code_phrase = generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(temp_syndicate_code_phrase, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_phrase_regex = codeword_match
		temp_syndicate_code_phrase = jointext(temp_syndicate_code_phrase, ", ")
		GLOB.syndicate_code_phrase = temp_syndicate_code_phrase


	if(!GLOB.syndicate_code_response)
		var/list/temp_syndicate_code_response = generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(temp_syndicate_code_response, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_response_regex = codeword_match
		temp_syndicate_code_response = jointext(temp_syndicate_code_response, ", ")
		GLOB.syndicate_code_response = temp_syndicate_code_response

	// Run post setup stuff
	mode.post_setup()

	// Delete starting landmarks (not AI ones because we need those for AI-ize)
	for(var/obj/effect/landmark/start/S in GLOB.landmarks_list)
		if(S.name != JOB_TITLE_AI)
			qdel(S)

	SSdbcore.SetRoundStart()
	to_chat(world, "<span class='darkmblue'><B>Enjoy the game!</B></span>")
	SEND_SOUND(world, sound('sound/AI/welcome.ogg'))

	if(SSholiday.holidays)
		to_chat(world, "<span class='darkmblue'>and...</span>")
		for(var/holidayname in SSholiday.holidays)
			var/datum/holiday/holiday = SSholiday.holidays[holidayname]
			to_chat(world, "<h4>[holiday.greet()]</h4>")

	SSdiscord.send2discord_simple_noadmins("**\[Info]** Round has started")
	auto_toggle_ooc(FALSE) // Turn it off
	time_game_started = world.time

	if(CONFIG_GET(number/restrict_maint))
		for(var/obj/machinery/door/airlock/maintenance/M in GLOB.airlocks)
			if(M.req_access && M.req_access.len == 1 && M.req_access[1] == ACCESS_MAINT_TUNNELS)
				M.req_access = null
				if(CONFIG_GET(number/restrict_maint) == 1)
					M.req_access = list(ACCESS_BRIG, ACCESS_ENGINE)
				if(CONFIG_GET(number/restrict_maint) == 2)
					M.req_access = list(ACCESS_BRIG)

	// Sets the auto shuttle vote to happen after the config duration
	next_autotransfer = world.time + CONFIG_GET(number/vote_autotransfer_initial)

	for(var/mob/new_player/N in GLOB.mob_list)
		if(N.client)
			SStitle.show_title_screen_to(N.client) // New Title Screen

	#ifdef UNIT_TESTS
	// Run map tests first in case unit tests futz with map state
	GLOB.test_runner.RunMap()
	GLOB.test_runner.Run()
	#endif

	// Do this 10 second after roundstart because of roundstart lag, and make it more visible
	addtimer(CALLBACK(src, PROC_REF(handle_antagfishing_reporting)), 10 SECONDS)
	// We delay gliding adjustment with time dilation to stop stuttering on the round start
	//addtimer(VARSET_CALLBACK(SStime_track, update_gliding, TRUE), 1 MINUTES)
	return TRUE

/datum/controller/subsystem/ticker/proc/choose_lobby_music()
	var/list/songs = CONFIG_GET(str_list/lobby_music)
	if(LAZYLEN(songs))
		selected_lobby_music = pick(songs)

	if(SSholiday.holidays) // What's this? Events are initialized before tickers? Let's do something with that!
		for(var/holidayname in SSholiday.holidays)
			var/datum/holiday/holiday = SSholiday.holidays[holidayname]
			if(LAZYLEN(holiday.lobby_music))
				selected_lobby_music = pick(holiday.lobby_music)
				break

	if(!selected_lobby_music)
		return

	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(world, span_boldwarning("yt-dlp was not configured."))
		log_world("Could not play lobby song because yt-dlp is not configured properly, check the config.")
		return

	var/list/output = world.shelleo("[ytdl] -x --audio-format mp3 --audio-quality 0 --geo-bypass --no-playlist -o \"cache/songs/%(id)s.%(ext)s\" --dump-single-json --no-simulate \"[selected_lobby_music]\"")
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]

	if(!errorlevel)
		var/list/data
		try
			data = json_decode(stdout)
		catch(var/exception/e)
			to_chat(world, span_boldwarning("yt-dlp JSON parsing FAILED."))
			log_world(span_boldwarning("yt-dlp JSON parsing FAILED:"))
			log_world(span_warning("[e]: [stdout]"))
			return
		if(data["title"])
			login_music_data["title"] = data["title"]
			login_music_data["url"] = data["url"]
			login_music_data["link"] = data["webpage_url"]
			login_music_data["path"] = "cache/songs/[data["id"]].mp3"
			login_music_data["title_link"] = data["webpage_url"] ? "<a href=\"[data["webpage_url"]]\">[data["title"]]</a>" : data["title"]

	if(errorlevel)
		to_chat(world, span_boldwarning("yt-dlp failed."))
		log_world("Could not play lobby song [selected_lobby_music]: [stderr]")
		return
	return stdout


/datum/controller/subsystem/ticker/proc/station_explosion_cinematic(station_missed = 0, override = null)

	auto_toggle_ooc(TRUE) // Turn it on

	if(!station_missed)	//nuke kills everyone on z-level 1 to prevent "hurr-durr I survived"
		for(var/mob/M in GLOB.mob_list)
			if(M.stat != DEAD && !(issilicon(M) && override == "AI malfunction"))
				var/turf/T = get_turf(M)
				if(T && is_station_level(T.z) && !istype(M.loc, /obj/structure/closet/secure_closet/freezer))
					M.ghostize()
					M.dust() //no mercy
					CHECK_TICK

	//Now animate the cinematic
	switch(station_missed)
		if(1)	//nuke was nearby but (mostly) missed
			if(mode && !override)
				override = mode.name

			switch(override)
				if("nuclear emergency") //Nuke wasn't on station when it blew up
					play_cinematic(/datum/cinematic/nuke/ops_miss, world)

				if("fake") //The round isn't over, we're just freaking people out for fun
					play_cinematic(/datum/cinematic/nuke/fake, world)

				else
					play_cinematic(/datum/cinematic/nuke/self_destruct_miss, world)

		if(2)	//nuke was nowhere nearby	//TODO: a really distant explosion animation
			play_cinematic(/datum/cinematic/nuke/far_explosion, world)

		else	//station was destroyed
			if(mode && !override)
				override = mode.name
			switch(override)
				if("nuclear emergency") //Nuke Ops successfully bombed the station
					play_cinematic(/datum/cinematic/nuke/ops_victory, world)

				if("AI malfunction") //Malf (screen,explosion,summary)
					play_cinematic(/datum/cinematic/malf, world)

				if("blob") //Station nuked (nuke,explosion,summary)
					play_cinematic(/datum/cinematic/nuke/self_destruct, world)

				else //Station nuked (nuke,explosion,summary)
					play_cinematic(/datum/cinematic/nuke/self_destruct, world)



/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.ready && player.mind)
			if(player.mind.assigned_role == JOB_TITLE_AI)
				player.close_spawn_windows()
				var/mob/living/character = player.create_character()
				var/mob/living/silicon/ai/ai_character = character.AIize()
				ai_character.moveToAILandmark()
				SSticker?.score?.save_silicon_laws(ai_character, additional_info = "job assignment", log_all_laws = TRUE)
			else if(!player.mind.assigned_role)
				continue
			else
				player.create_character()
				qdel(player)


/datum/controller/subsystem/ticker/proc/equip_characters()
	var/captainless = TRUE
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role == JOB_TITLE_CAPTAIN)
				captainless = FALSE
			if(player.mind.assigned_role != player.mind.special_role)
				SSjobs.AssignRank(player, player.mind.assigned_role, FALSE)
				SSjobs.EquipRank(player, player.mind.assigned_role, FALSE)
				EquipCustomItems(player)
	if(captainless)
		for(var/mob/M in GLOB.player_list)
			if(!isnewplayer(M))
				to_chat(M, "Captainship not forced on anyone.")


/datum/controller/subsystem/ticker/proc/send_tip_of_the_round()
	var/m
	if(selected_tip)
		m = selected_tip
	else
		if(randomtips.len && prob(95))
			m = pick(randomtips)
		else if(memetips.len)
			m = pick(memetips)

	if(m)
		to_chat(world, "<span class='purple'><b>Совет раунда: </b>[html_encode(m)]</span>")


/datum/controller/subsystem/ticker/proc/declare_completion()
	GLOB.nologevent = TRUE //end of round murder and shenanigans are legal; there's no need to jam up  past this point.
	if(toogle_gv)
		set_observer_default_invisibility(0) //spooks things up
	//Round statistics report
	var/datum/station_state/ending_station_state = new /datum/station_state()
	ending_station_state.count()
	var/station_integrity = min(round( 100.0 *  GLOB.start_state.score(ending_station_state), 0.1), 100.0)

	to_chat(world, "<BR>[TAB]Shift Duration: <B>[SHIFT_TIME_TEXT()]</B>")
	to_chat(world, "<BR>[TAB]Station Integrity: <B>[mode.station_was_nuked ? "<font color='red'>Destroyed</font>" : "[station_integrity]%"]</B>")
	to_chat(world, "<BR>")

	//Silicon laws report
	for(var/mob/living/silicon/ai/aiPlayer in GLOB.mob_list)
		var/ai_ckey = safe_get_ckey(aiPlayer)

		if(aiPlayer.stat != 2)
			to_chat(world, "<b>[aiPlayer.name] (Played by: [ai_ckey])'s laws at the end of the game were:</b>")
		else
			to_chat(world, "<b>[aiPlayer.name] (Played by: [ai_ckey])'s laws when it was deactivated were:</b>")
		aiPlayer.show_laws(TRUE)

		if(aiPlayer.connected_robots.len)
			var/robolist = "<b>The AI's loyal minions were:</b> "
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				var/robo_ckey = safe_get_ckey(robo)
				robolist += "[robo.name][robo.stat ? " (Deactivated)" : ""] (Played by: [robo_ckey])"
			to_chat(world, "[robolist]")

	var/dronecount = 0

	for(var/mob/living/silicon/robot/robo in GLOB.mob_list)

		if(isdrone(robo))
			dronecount++
			continue

		var/robo_ckey = safe_get_ckey(robo)

		if(!robo.connected_ai)
			if(robo.stat != 2)
				to_chat(world, "<b>[robo.name] (Played by: [robo_ckey]) survived as an AI-less borg! Its laws were:</b>")
			else
				to_chat(world, "<b>[robo.name] (Played by: [robo_ckey]) was unable to survive the rigors of being a cyborg without an AI. Its laws were:</b>")

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				robo.laws.show_laws(world)

	if(dronecount)
		to_chat(world, "<b>There [dronecount>1 ? "were" : "was"] [dronecount] industrious maintenance [dronecount>1 ? "drones" : "drone"] this round.")

	if(mode.eventmiscs.len)
		var/emobtext = ""
		for(var/datum/mind/eventmind in mode.eventmiscs)
			emobtext += printeventplayer(eventmind)
			emobtext += "<br>"
			emobtext += printobjectives(eventmind)
			emobtext += "<br>"
		emobtext += "<br>"
		to_chat(world, emobtext)

	mode.declare_completion()//To declare normal completion.

	//calls auto_declare_completion_* for all modes
	for(var/handler in typesof(/datum/game_mode/proc))
		if(findtext("[handler]","auto_declare_completion_"))
			call(mode, handler)()

	// Display the scoreboard window
	score.scoreboard()

	// Declare the completion of the station goals
	mode.declare_station_goal_completion()

	if(toggle_pacifism)
		GLOB.pacifism_after_gt = TRUE

	//Ask the event manager to print round end information
	SSevents.RoundEnd()

	//make big obvious note in game logs that round ended
	add_game_logs("///////////////////////////////////////////////////////")
	add_game_logs("///////////////////// ROUND ENDED /////////////////////")
	add_game_logs("///////////////////////////////////////////////////////")

	// Add AntagHUD to everyone, see who was really evil the whole time!
	for(var/datum/atom_hud/antag/H in GLOB.huds)
		for(var/m in GLOB.player_list)
			var/mob/M = m
			H.add_hud_to(M)

	// Seal the blackbox, stop collecting info
	SSblackbox.Seal()
	SSdbcore.SetRoundEnd()

	return TRUE


/datum/controller/subsystem/ticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING


/datum/controller/subsystem/ticker/proc/IsRoundInProgress()
	return current_state == GAME_STATE_PLAYING


/datum/controller/subsystem/ticker/proc/setup_news_feeds()
	var/datum/feed_channel/newChannel = new /datum/feed_channel
	newChannel.channel_name = "Public Station Announcements"
	newChannel.author = "Automated Announcement Listing"
	newChannel.icon = "bullhorn"
	newChannel.frozen = TRUE
	newChannel.admin_locked = TRUE
	GLOB.news_network.channels += newChannel

	newChannel = new /datum/feed_channel
	newChannel.channel_name = "Nyx Daily"
	newChannel.author = "CentComm Minister of Information"
	newChannel.icon = "meteor"
	newChannel.frozen = TRUE
	newChannel.admin_locked = TRUE
	GLOB.news_network.channels += newChannel

	newChannel = new /datum/feed_channel
	newChannel.channel_name = "The Gibson Gazette"
	newChannel.author = "Editor Mike Hammers"
	newChannel.icon = "star"
	newChannel.frozen = TRUE
	newChannel.admin_locked = TRUE
	GLOB.news_network.channels += newChannel

	for(var/loc_type in subtypesof(/datum/trade_destination))
		var/datum/trade_destination/D = new loc_type
		GLOB.weighted_randomevent_locations[D] = D.viable_random_events.len
		GLOB.weighted_mundaneevent_locations[D] = D.viable_mundane_events.len


// Easy handler to make rebooting the world not a massive sleep in world/Reboot()
/datum/controller/subsystem/ticker/proc/reboot_helper(reason, end_string, delay)
	// Admins delayed round end. Just alert and dont bother with anything else.
	if(delay_end)
		to_chat(world, span_boldannounceooc("An admin has delayed the round end."))
		return

	if(!isnull(delay))
		// Delay time was present. Use that.
		delay = max(0, delay)
	else
		// Use default restart timeout
		delay = restart_timeout

	to_chat(world, span_boldannounceooc("Rebooting world in [delay/10] [delay > 10 ? "seconds" : "second"]. [reason]"))

	real_reboot_time = world.time + delay
	UNTIL(world.time > real_reboot_time) // Hold it here

	// And if we re-delayed, bail again
	if(delay_end)
		to_chat(world, span_boldannounceooc("Reboot was cancelled by an admin."))
		return

	if(end_string)
		end_state = end_string

	// Play a haha funny noise
	var/round_end_sound = pick(GLOB.round_end_sounds)
	var/sound_length = GLOB.round_end_sounds[round_end_sound]
	world << sound(round_end_sound, volume = 80)
	sleep(sound_length)

	world.Reboot()


// Timers invoke this async
/datum/controller/subsystem/ticker/proc/handle_antagfishing_reporting()

	// Dont need to do anything
	if(!length(flagged_antag_rollers))
		return

	// Report on things
	var/list/log_text = list("The following players attempted to roll antag with no jobs: ")

	for(var/ckey in flagged_antag_rollers)
		log_admin("[ckey] just got booted back to lobby with no jobs, but antags enabled.")
		log_text += "<small>- <a href='byond://?priv_msg=[ckey]'>[ckey]</a></small>"

	log_text += "Investigation is advised."

	message_admins(log_text.Join("<br>"))

	flagged_antag_rollers.Cut()
