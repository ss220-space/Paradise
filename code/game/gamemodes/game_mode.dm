#define NUKE_INTACT 0
#define NUKE_CORE_MISSING 1
#define NUKE_MISSING 2

/*
 * GAMEMODES (by Rastaf0)
 *
 * In the new mode system all special roles are fully supported.
 * You can have proper wizards/traitors/changelings/cultists during any mode.
 * Only two things really depends on gamemode:
 * 1. Starting roles, equipment and preparations
 * 2. Conditions of finishing the round.
 *
 */
/datum/game_mode
	var/name = "invalid"
	var/config_tag = null
	/// Probablity for this mode in secret mode type.
	var/probability = 0
	/// Whether this mode can be voted by players.
	var/votable = TRUE
	/// See nuclearbomb.dm and malfunction.dm
	var/station_was_nuked = FALSE
	/// See nuclearbomb.dm and malfunction.dm
	var/explosion_in_progress = FALSE //sit back and relax
	var/false_report_weight = 0 //How often will this show up incorrectly in a centcom report? --Not used--
	// Jobs it doesn't make sense to be antags. I.E chaplain or AI cultist
	var/list/restricted_jobs = list()
	/// Jobs that can't be antags.
	var/list/protected_jobs = list()
	/// Species that can't be antags.
	var/list/protected_species = list()
	/// Specified associative list of "antag - job" restrictions
	var/list/forbidden_antag_jobs = list()
	/// How many players should press ready for mode to activate.
	var/required_players = 0
	/// How many antagonists are required for mode start.
	var/required_enemies = 0
	/// Legacy code, currently used in heist mode only.
	var/recommended_enemies = 0
	/// Whether ERT call is even allowed in this mode.
	var/ert_disabled = FALSE
	var/newscaster_announcements = null

	/// Lower bound on time before intercept arrives.
	var/const/waittime_l = 60 SECONDS
	/// Upper bound on time before intercept arrives.
	var/const/waittime_h = 180 SECONDS
	var/list/player_draft_log = list()
	var/list/datum/mind/xenos = list()
	var/list/datum/mind/eventmiscs = list()
	var/list/datum/mind/victims = list()	//Свободные жертвы PREVENT/ASSASINATE целей для PROTECT (или не повтора целей)
	/// A list of all station goals for this game mode
	var/list/datum/station_goal/station_goals = list()


/datum/game_mode/proc/announce() //to be calles when round starts
	to_chat(world, "<B>Notice</B>: [src] did not define announce()")


/datum/game_mode/proc/generate_report() //Generates a small text blurb for the gamemode in centcom report
	return "Gamemode report for [name] not set.  Contact a coder."

/**
 * Checks to see if the game can be setup and ran with the current number of players or whatnot.
 */
/datum/game_mode/proc/can_start()
	var/playerC = num_players()

	if(playerC < required_enemies)
		return FALSE

	if(!CONFIG_GET(flag/enable_gamemode_player_limit) || (playerC >= config.mode_required_players[src.config_tag]))
		return TRUE

	return FALSE


/**
 * Attempts to select players for special roles the mode might have.
 */
/datum/game_mode/proc/pre_setup()
	return TRUE


/**
 * Everyone should now be on the station and have their normal gear. This is the place to give the special roles extra things.
 */
/datum/game_mode/proc/post_setup()

	spawn(ROUNDSTART_LOGOUT_REPORT_TIME)
		display_roundstart_logout_report()

	INVOKE_ASYNC(src, PROC_REF(set_mode_in_db)) // Async query, dont bother slowing roundstart

	SScargo_quests.roll_start_quests()
	generate_station_goals()
	GLOB.start_state = new /datum/station_state()
	GLOB.start_state.count()
	return TRUE


/datum/game_mode/proc/set_mode_in_db()	// I wonder what this could do guessing by the name
	if(SSticker?.mode && SSdbcore.IsConnected())
		var/datum/db_query/query_round_game_mode = SSdbcore.NewQuery("UPDATE round SET game_mode=:gm WHERE id=:rid", list(
			"gm" = SSticker.mode.name,
			"rid" = GLOB.round_id
		))
		// We dont do anything with output. Dont bother wrapping with if()
		query_round_game_mode.warn_execute()
		qdel(query_round_game_mode)


/**
 * Called by the gameticker.
 */
/datum/game_mode/process(wait)
	return PROCESS_KILL


/**
 * Called by the gameticker.
 */
/datum/game_mode/proc/process_job_tasks()
	var/obj/machinery/message_server/message_server = null
	if(GLOB.message_servers)
		for(var/obj/machinery/message_server/check in GLOB.message_servers)
			if(check.active)
				message_server = check
				break

	for(var/mob/player in GLOB.player_list)

		if(player.mind)
			var/obj/item/pda/pda_owned = null
			for(var/obj/item/pda/check in GLOB.PDAs)
				if(check.owner == player.name)
					pda_owned = check
					break

			var/count = 0
			for(var/datum/job_objective/objective in player.mind.job_objectives)
				count++
				var/msg = ""
				var/pay = 0

				if(objective.per_unit && objective.units_compensated < objective.units_completed)
					var/newunits = objective.units_completed - objective.units_compensated
					msg="We see that you completed [newunits] new unit[newunits > 1 ? "s" : ""] for Task #[count]! "
					pay=objective.completion_payment * newunits
					objective.units_compensated += newunits
					objective.is_completed() // So we don't get many messages regarding completion

				else if(!objective.completed)
					if(objective.is_completed())
						pay = objective.completion_payment
						msg = "Task #[count] completed! "

				if(pay > 0)
					if(player.mind.initial_account)
						player.mind.initial_account.credit(pay, "Payment", "\[CLASSIFIED\] Terminal #[rand(111,333)]", "[command_name()] Payroll")
						msg += "You have been sent the $[pay], as agreed."

					else
						msg += "However, we were unable to send you the $[pay] you're entitled."

					if(message_server && pda_owned)
						message_server.send_pda_message("[pda_owned.owner]", "[command_name()] Payroll", msg)

						var/datum/data/pda/app/messenger/messenger = pda_owned.find_program(/datum/data/pda/app/messenger)
						messenger.notify("<b>Message from [command_name()] (Payroll), </b>\"[msg]\" (<i>Unable to Reply</i>)", 0)
					break


/**
 * Check to be called by ticker
 */
/datum/game_mode/proc/check_finished()
	if((SSshuttle.emergency && SSshuttle.emergency.mode >= SHUTTLE_ENDGAME) || station_was_nuked)
		return TRUE

	return FALSE


/**
 * This is called when the round has ended but not the game, if any cleanup would be necessary in that case.
 */
/datum/game_mode/proc/cleanup()
	return


/datum/game_mode/proc/declare_completion()
	var/clients = 0
	var/surviving_humans = 0
	var/surviving_total = 0
	var/ghosts = 0
	var/escaped_humans = 0
	var/escaped_total = 0
	var/escaped_on_pod_1 = 0
	var/escaped_on_pod_2 = 0
	var/escaped_on_pod_3 = 0
	var/escaped_on_pod_5 = 0
	var/escaped_on_shuttle = 0

	var/list/area/escape_locations = list(/area/shuttle/escape, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)

	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME) //shuttle didn't get to centcom
		escape_locations -= /area/shuttle/escape

	for(var/mob/player in GLOB.player_list)
		if(player.client)
			clients++

			var/area/player_area = get_area(player)

			if(ishuman(player))
				if(!player.stat)
					surviving_humans++
					if(player_area?.type in escape_locations)
						escaped_humans++

			if(!player.stat)
				surviving_total++

				if(player_area?.type in escape_locations)
					escaped_total++

				if(player_area?.type == SSshuttle.emergency.areaInstance.type && SSshuttle.emergency.mode >= SHUTTLE_ENDGAME)
					escaped_on_shuttle++

				if(player_area?.type == /area/shuttle/escape_pod1/centcom)
					escaped_on_pod_1++

				if(player_area?.type == /area/shuttle/escape_pod2/centcom)
					escaped_on_pod_2++

				if(player_area?.type == /area/shuttle/escape_pod3/centcom)
					escaped_on_pod_3++

				if(player_area?.type == /area/shuttle/escape_pod5/centcom)
					escaped_on_pod_5++

			if(isobserver(player))
				ghosts++

	if(clients)
		SSblackbox.record_feedback("nested tally", "round_end_stats", clients, list("clients"))
	if(ghosts)
		SSblackbox.record_feedback("nested tally", "round_end_stats", ghosts, list("ghosts"))
	if(surviving_humans)
		SSblackbox.record_feedback("nested tally", "round_end_stats", surviving_humans, list("survivors", "human"))
	if(surviving_total)
		SSblackbox.record_feedback("nested tally", "round_end_stats", surviving_total, list("survivors", "total"))
	if(escaped_humans)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_humans, list("escapees", "human"))
	if(escaped_total)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_total, list("escapees", "total"))
	if(escaped_on_shuttle)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_on_shuttle, list("escapees", "on_shuttle"))
	if(escaped_on_pod_1)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_on_pod_1, list("escapees", "on_pod_1"))
	if(escaped_on_pod_2)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_on_pod_2, list("escapees", "on_pod_2"))
	if(escaped_on_pod_3)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_on_pod_3, list("escapees", "on_pod_3"))
	if(escaped_on_pod_5)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_on_pod_5, list("escapees", "on_pod_5"))

	SSdiscord.send2discord_simple(DISCORD_WEBHOOK_PRIMARY, "A round of [name] has ended - [surviving_total] survivors, [ghosts] ghosts.")
	return FALSE


/**
 * Universal trigger to be called at mob death, nuke explosion, etc. To be called from everywhere.
 */
/datum/game_mode/proc/check_win()
	return FALSE


/**
 * Returns a list of player minds who had the antagonist role set to yes, regardless of recomended_enemies.
 * Jobbans and restricted jobs are checked. Species lock and prefered species are checked. List is already shuffled.
 */
/datum/game_mode/proc/get_players_for_role(role, list/prefered_species)
	var/list/players = list()
	var/list/candidates = list()

	// Assemble a list of active players without jobbans and role enabled
	for(var/mob/new_player/player in GLOB.player_list)
		if(!player.client || !player.ready || !player.has_valid_preferences() \
			|| jobban_isbanned(player, "Syndicate") || jobban_isbanned(player, role) \
			|| !player_old_enough_antag(player.client, role) || player.client.prefs?.skip_antag \
			|| !(role in player.client.prefs.be_special))
			continue

		players += player

	// Shuffle the players list so that it becomes ping-independent.
	players = shuffle(players)

	// Get a list of all the people who want to be the antagonist for this round, except those with incompatible species
	for(var/mob/new_player/player in players)
		if(length(protected_species) && (player.client.prefs.species in protected_species))
			continue
		if(length(restricted_jobs) && (player.mind.assigned_role in restricted_jobs))
			continue
		player_draft_log += "[player.key] had [role] enabled, so we are drafting them."
		candidates += player.mind
		if(length(prefered_species))
			var/prefered_species_mod = prefered_species[player.client.prefs.species]
			if(isnum(prefered_species_mod))
				for (var/i in 1 to prefered_species_mod)	//prefered mod
					candidates += player.mind

	return candidates

/**
 * Works like get_players_for_role, but for alive mobs.
 */
/datum/game_mode/proc/get_alive_players_for_role(role, list/preferred_species)
	var/list/players = list()
	var/list/candidates = list()

	// Assemble a list of active players without jobbans and role enabled
	for(var/mob/living/carbon/human/player in GLOB.alive_mob_list)
		if(!player.client \
			|| jobban_isbanned(player, "Syndicate") || jobban_isbanned(player, role) \
			|| !player_old_enough_antag(player.client, role) || player.client.prefs?.skip_antag \
			|| !(role in player.client.prefs.be_special))
			continue

		if(player.mind.has_antag_datum(/datum/antagonist) || player.mind.offstation_role || player.mind.special_role)
			continue

		players += player

	// Shuffle the players list so that it becomes ping-independent.
	players = shuffle(players)

	// Get a list of all the people who want to be the antagonist for this round, except those with incompatible species
	for(var/mob/living/carbon/human/player in players)
		if(length(protected_species) && (player.client.prefs.species in protected_species))
			continue
		if(length(restricted_jobs) && (player.mind.assigned_role in restricted_jobs))
			continue
		if(length(forbidden_antag_jobs) && (player.mind.assigned_role in forbidden_antag_jobs[role]))
			continue

		player_draft_log += "[player.key] had [role] enabled, so we are drafting them."
		candidates += player.mind
		if(length(preferred_species))
			var/prefered_species_mod = preferred_species[player.client.prefs.species]
			if(isnum(prefered_species_mod))
				for (var/i in 1 to prefered_species_mod)	//prefered mod
					candidates += player.mind

	return candidates

/datum/game_mode/proc/latespawn(mob/player)


/datum/game_mode/proc/num_players()
	. = 0

	for(var/mob/new_player/player in GLOB.player_list)

		if(player.client && player.ready)
			.++

/proc/num_station_players()
	. = 0
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player)
			continue

		if(player.client && player.mind && !player.mind.offstation_role && !player.mind.special_role)
			.++


/datum/game_mode/proc/num_players_started()
	. = 0

	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player)
			continue

		if(player.client)
			.++


/**
 * Keeps track of all living heads.
 */
/datum/game_mode/proc/get_living_heads()
	. = list()

	for(var/mob/living/carbon/human/player in GLOB.human_list)

		var/list/real_command_positions = GLOB.command_positions.Copy() - "Nanotrasen Representative"
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in real_command_positions))
			. |= player.mind


/**
 * Keeps track of all heads.
 */
/datum/game_mode/proc/get_all_heads()
	. = list()

	for(var/mob/player in GLOB.mob_list)
		if(!player)
			continue

		var/list/real_command_positions = GLOB.command_positions.Copy() - "Nanotrasen Representative"
		if(player.mind && (player.mind.assigned_role in real_command_positions))
			. |= player.mind


/**
 * Keeps track of all living security members.
 */
/datum/game_mode/proc/get_living_sec()
	. = list()

	for(var/mob/living/carbon/human/player in GLOB.human_list)

		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in GLOB.security_positions))
			. |= player.mind


/**
 * Keeps track of all  security members.
 */
/datum/game_mode/proc/get_all_sec()
	. = list()

	for(var/mob/living/carbon/human/player in GLOB.human_list)
		if(!player)
			continue

		if(player.mind && (player.mind.assigned_role in GLOB.security_positions))
			. |= player.mind


/datum/game_mode/proc/check_antagonists_topic(href, href_list[])
	return FALSE


/datum/game_mode/New()
	newscaster_announcements = pick(GLOB.newscaster_standard_feeds)


/**
 * Reports player logouts.
 */
/proc/display_roundstart_logout_report()
	var/msg = "<span class='notice'>Roundstart logout report</span>\n\n"
	for(var/mob/living/mob_living in GLOB.mob_list)

		if(mob_living.ckey)
			var/found = FALSE
			for(var/client/mob_client in GLOB.clients)
				if(mob_client.ckey == mob_living.ckey)
					found = TRUE
					break
			if(!found)
				msg += "<b>[mob_living.name]</b> ([mob_living.ckey]), the [mob_living.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(mob_living.ckey && mob_living.client)
			if(mob_living.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))	//Connected, but inactive (alt+tabbed or something)
				msg += "<b>[mob_living.name]</b> ([mob_living.ckey]), the [mob_living.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				continue //AFK client

			if(mob_living.stat)
				if(mob_living.suiciding)	//Suicider
					msg += "<b>[mob_living.name]</b> ([mob_living.ckey]), the [mob_living.job] (<font color='red'><b>Suicide</b></font>)\n"
					SSjobs.FreeRole(mob_living.job)
					message_admins("<b>[key_name_admin(mob_living)]</b>, the [mob_living.job] has been freed due to (<font color='#ffcc00'><b>Early Round Suicide</b></font>)\n")
					continue //Disconnected client

				if(mob_living.stat == UNCONSCIOUS)
					msg += "<b>[mob_living.name]</b> ([mob_living.ckey]), the [mob_living.job] (Dying)\n"
					continue //Unconscious

				if(mob_living.stat == DEAD)
					msg += "<b>[mob_living.name]</b> ([mob_living.ckey]), the [mob_living.job] (Dead)\n"
					continue //Dead

			continue //Happy connected client

		for(var/mob/dead/observer/observer in GLOB.mob_list)
			if(observer.mind && (observer.mind.is_original_mob(mob_living) || observer.mind.current == mob_living))
				if(mob_living.stat == DEAD)
					if(mob_living.suiciding)	//Suicider
						msg += "<b>[mob_living.name]</b> ([ckey(observer.mind.key)]), the [mob_living.job] (<font color='red'><b>Suicide</b></font>)\n"
						continue //Disconnected client

					else
						msg += "<b>[mob_living.name]</b> ([ckey(observer.mind.key)]), the [mob_living.job] (Dead)\n"
						continue //Dead mob, ghost abandoned

				else
					if(observer.can_reenter_corpse)
						msg += "<b>[mob_living.name]</b> ([ckey(observer.mind.key)]), the [mob_living.job] (<font color='red'><b>This shouldn't appear.</b></font>)\n"
						continue //Lolwhat

					else
						msg += "<b>[mob_living.name]</b> ([ckey(observer.mind.key)]), the [mob_living.job] (<font color='red'><b>Ghosted</b></font>)\n"
						SSjobs.FreeRole(mob_living.job)
						message_admins("<b>[key_name_admin(mob_living)]</b>, the [mob_living.job] has been freed due to (<font color='#ffcc00'><b>Early Round Ghosted While Alive</b></font>)\n")
						continue //Ghosted while alive

	for(var/mob/mob in GLOB.mob_list)

		if(check_rights(R_ADMIN, FALSE, mob))
			to_chat(mob, msg)


/**
 * Announces objectives/generic antag text.
 */
/proc/show_generic_antag_text(datum/mind/player)
	if(player?.current)
		to_chat(player.current, "You are an antagonist! <font color=blue>Within the rules,</font> \
		try to act as an opposing force to the crew. Further RP and try to make sure \
		other players have <i>fun</i>! If you are confused or at a loss, always adminhelp, \
		and before taking extreme actions, please try to also contact the administration! \
		Think through your actions and make the roleplay immersive! <b>Please remember all \
		rules aside from those without explicit exceptions apply to antagonists.</b>")


/proc/show_objectives(datum/mind/player)
	if(!player?.current)
		return

	var/obj_count = 1
	to_chat(player.current, span_notice("Your current objectives:"))
	for(var/datum/objective/objective in player.get_all_objectives())
		to_chat(player.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++


/proc/get_nuke_code()
	var/nukecode = "ERROR"
	for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
		if(bomb?.r_code && is_station_level(bomb.z))
			nukecode = bomb.r_code
	return nukecode


/proc/get_nuke_status()
	var/nuke_status = NUKE_MISSING
	for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
		if(is_station_level(bomb.z))
			nuke_status = NUKE_CORE_MISSING
			if(bomb.core)
				nuke_status = NUKE_INTACT
	return nuke_status


/datum/game_mode/proc/replace_jobbanned_player(mob/living/player, role_type)
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as a [role_type]?", role_type, FALSE, 10 SECONDS)
	var/mob/dead/observer/theghost = null
	if(length(candidates))
		theghost = pick(candidates)
		to_chat(player, span_userdanger("Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!"))
		message_admins("[key_name_admin(theghost)] has taken control of ([key_name_admin(player)]) to replace a jobbanned player.")
		log_game("[theghost.key] has taken control of ([player.key]) to replace a jobbanned for [role_type] player.")
		player.ghostize()
		player.key = theghost.key
	else
		log_game("[player] ([player.key] has been converted into [role_type] with an active antagonist jobban for said role since no ghost has volunteered to take player's place.")
		message_admins("[player] ([player.key] has been converted into [role_type] with an active antagonist jobban for said role since no ghost has volunteered to take [player.p_their()] place.")
		to_chat(player, span_dangerbigger("You have been converted into [role_type] with an active jobban. Any further violations of the rules on your part are likely to result in a permanent ban."))

/proc/printplayer(datum/mind/player, flee_check)
	var/jobtext = ""
	if(player.assigned_role)
		jobtext = " the <b>[player.assigned_role]</b>"

	var/text = "<b>[player.get_display_key()]</b> was <b>[player.name]</b>[jobtext] and"
	if(player.current)
		if(player.current.stat == DEAD)
			text += " <span class='redtext'>died</span>"
		else
			text += " <span class='greentext'>survived</span>"

		if(flee_check)
			var/turf/player_turf = get_turf(player.current)
			if(!player_turf || !is_station_level(player_turf.z))
				text += " while <span class='redtext'>fleeing the station</span>"

		if(player.current.real_name != player.name)
			text += " as <b>[player.current.real_name]</b>"

	else
		text += " <span class='redtext'>had [player.p_their()] body destroyed</span>"

	return text


/proc/printeventplayer(datum/mind/player)
	var/text = "<b>[player.get_display_key()]</b> was <b>[player.name]</b>"
	if(player.special_role != SPECIAL_ROLE_EVENTMISC)
		text += " the [player.special_role]"

	text += " and"

	if(player.current)
		if(player.current.stat == DEAD)
			text += " <b>died</b>"
		else
			text += " <b>survived</b>"

	else
		text += " <b>had [player.p_their()] body destroyed</b>"

	return text


/proc/printobjectives(datum/mind/player)
	var/list/objective_parts = list()

	var/count = 1
	for(var/datum/objective/objective in player.get_all_objectives())
		if(objective.check_completion())
			objective_parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='greentext'>Success!</span>"
		else
			objective_parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
		count++

	return objective_parts.Join("<br>")


/datum/game_mode/proc/generate_station_goals()
	var/list/possible = list()

	for(var/T in subtypesof(/datum/station_goal))
		var/datum/station_goal/goal = new T
		if(config_tag in goal.gamemode_blacklist)
			continue

		possible += goal

	var/goal_weights = 0
	while(length(possible) && goal_weights < STATION_GOAL_BUDGET)
		var/datum/station_goal/picked_goal = pick_n_take(possible)
		goal_weights += picked_goal.weight
		station_goals += picked_goal

	if(length(station_goals))
		send_station_goals_message()


/datum/game_mode/proc/send_station_goals_message()

	var/list/goals = list()
	for(var/datum/station_goal/goal in station_goals)

		var/message_text = "<div style='text-align:center;'><img src = ntlogo.png>"
		message_text += "<h3>Приказания [command_name()]</h3></div><hr>"
		message_text += "<b>Особые указания для [station_name()]</b><br><br>"
		goal.on_report()
		message_text += goal.get_report()
		print_command_report(message_text, "Приказания [command_name()]", FALSE, goal)
		goals += goal.name

	log_game("Station goals at round start were: [english_list(goals)].")


/datum/game_mode/proc/declare_station_goal_completion()
	for(var/datum/station_goal/goal in station_goals)
		if(!goal)
			continue

		goal.print_result()


/datum/game_mode/proc/update_eventmisc_icons_added(datum/mind/mob_mind)
	var/datum/atom_hud/antag/antaghud = GLOB.huds[ANTAG_HUD_EVENTMISC]
	antaghud.join_hud(mob_mind.current)
	set_antag_hud(mob_mind.current, "hudevent")


/datum/game_mode/proc/update_eventmisc_icons_removed(datum/mind/mob_mind)
	var/datum/atom_hud/antag/antaghud = GLOB.huds[ANTAG_HUD_EVENTMISC]
	antaghud.leave_hud(mob_mind.current)
	set_antag_hud(mob_mind.current, null)


#undef NUKE_INTACT
#undef NUKE_CORE_MISSING
#undef NUKE_MISSING
