SUBSYSTEM_DEF(statpanels)
	name = "Stat Panels"
	wait = 4
	init_order = INIT_ORDER_STATPANELS
	priority = FIRE_PRIORITY_STATPANEL
	flags = SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	var/list/currentrun = list()
	var/list/global_data
	var/list/mc_data

	/// How many subsystem fires between most tab updates
	var/default_wait = 10
	/// How many subsystem fires between updates of the status tab
	var/status_wait = 6
	/// How many subsystem fires between updates of the MC tab
	var/mc_wait = 5
	/// How many full runs this subsystem has completed. used for variable rate refreshes.
	var/num_fires = 0

/datum/controller/subsystem/statpanels/fire(resumed = FALSE)
	if(!resumed)
		num_fires++
		var/datum/map/cached = SSmapping.next_map
		var/round_time = world.time - SSticker.time_game_started
		global_data = list(
			list("Map:", SSmapping.map_datum?.station_short ? SSmapping.map_datum?.station_short : "Loading..."),
			cached ? list("Next Map:", "[cached.station_short]") : null,
			list("Round ID:", "[GLOB.round_id ? GLOB.round_id : "NULL"]"),
			list("Server Time:", "[time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")]"),
			list("[SSticker.time_game_started ? "Round Time" : "Lobby Time"]:", "[round_time > MIDNIGHT_ROLLOVER ? "[round(round_time / MIDNIGHT_ROLLOVER)]:[roundtime2text()]" : roundtime2text()]"),
			list("Station Time:", "[station_time_timestamp()]"),
			list("Time Dilation:", "[round(SStime_track.time_dilation_current, 1)]% AVG:([round(SStime_track.time_dilation_avg_fast, 1)]%, [round(SStime_track.time_dilation_avg, 1)]%, [round(SStime_track.time_dilation_avg_slow, 1)]%)"),
			list("Players Connected:", "[length(GLOB.clients)]"),
			list("Players in Lobby:", "[length(GLOB.new_player_mobs)]")
		)

		if(SSshuttle.emergency)
			var/eta = SSshuttle.emergency.getModeStr()
			if(eta)
				global_data[++global_data.len] = list("[eta]", "[SSshuttle.emergency.getTimerStr()]")
		src.currentrun = GLOB.clients.Copy()
		mc_data = null

	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/client/target = currentrun[length(currentrun)]
		currentrun.len--

		if(!target.stat_panel.is_ready())
			continue

		if(target.stat_tab == "Status" && num_fires % status_wait == 0)
			set_status_tab(target)

		var/holder_check = !isnull(target.holder)

		if(!holder_check || !(target.prefs?.toggles2 & PREFTOGGLE_2_MC_TAB))
			target.stat_panel.send_message("remove_mc_tab", !target.holder ? TRUE : FALSE)

		if(holder_check)
			target.stat_panel.send_message("update_split_admin_tabs", !!(target.prefs.toggles2 & PREFTOGGLE_2_SPLIT_ADMIN_TABS))

		if(holder_check && target.mob && check_rights(R_DEBUG | R_VIEWRUNTIMES, FALSE, target.mob))

			// Shows SDQL2 list
			if(!length(GLOB.sdql2_queries) && ("SDQL2" in target.panel_tabs))
				target.stat_panel.send_message("remove_sdql2")

			else if(length(GLOB.sdql2_queries) && (target.stat_tab == "SDQL2" || !("SDQL2" in target.panel_tabs)) && num_fires % default_wait == 0)
				set_SDQL2_tab(target)

			if(target.prefs?.toggles2 & PREFTOGGLE_2_MC_TAB)
				if(!("MC" in target.panel_tabs))
					target.stat_panel.send_message("add_mc_tab", target.holder.href_token)

				if(target.stat_tab == "MC" && ((num_fires % mc_wait == 0)))
					set_MC_tab(target)


		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/statpanels/proc/set_status_tab(client/target)
	if(!global_data) //statbrowser hasnt fired yet and we were called from immediate_send_stat_data()
		return

	target.stat_panel.send_message("update_stat", list(
		global_data = global_data,
		mob_specific_data = target.mob?.get_status_tab_items(),
	))

/datum/controller/subsystem/statpanels/proc/set_MC_tab(client/target)
	var/turf/eye_turf = get_turf(target.eye)
	var/coord_entry = COORD(eye_turf)
	if(!mc_data)
		generate_mc_data()
	target.stat_panel.send_message("update_mc", list(mc_data = mc_data, coord_entry = coord_entry))

/datum/controller/subsystem/statpanels/proc/set_SDQL2_tab(client/target)
	var/list/sdql2A = list()
	sdql2A[++sdql2A.len] = list("", "Access Global SDQL2 List", GLOB.sdql2_vv_statobj.UID())
	var/list/sdql2B = list()
	for(var/datum/sdql2_query/query as anything in GLOB.sdql2_queries)
		sdql2B = query.generate_stat()

	sdql2A += sdql2B
	target.stat_panel.send_message("update_sdql2", sdql2A)

/datum/controller/subsystem/statpanels/proc/generate_mc_data()
	mc_data = list(
		list("CPU:", Master.formatcpu(world.cpu)),
		list("Map CPU:", Master.formatcpu(world.map_cpu)),
		list("Instances:", "[num2text(length(world.contents), 10)]"),
		list("World Time:", "[world.time]"),
		list("Server Time:", time_stamp()),
		list("Globals:", GLOB.stat_entry(), "[GLOB.UID()]"),
		list("Byond:", "(FPS:[world.fps]) (TickCount:[world.time / world.tick_lag]) (TickDrift:[round(Master.tickdrift, 1)]([round((Master.tickdrift / (world.time / world.tick_lag)) * 100, 0.1)]%)) (Internal Tick Usage: [round(MAPTICK_LAST_INTERNAL_TICK_USAGE, 0.1)]%)"),
		list("Master Controller:", Master.stat_entry(), "[Master.UID()]"),
		list("Failsafe Controller:", Failsafe.stat_entry(), "[Failsafe.UID()]"),
		list("Configuration Controller:", config.stat_entry(), "[config.UID()]"),
		list("","")
	)
	for(var/datum/controller/subsystem/sub_system as anything in Master.subsystems)
		mc_data[++mc_data.len] = list("\[[sub_system.state_letter()]][sub_system.name]", sub_system.stat_entry(), "[sub_system.UID()]")
	mc_data[++mc_data.len] = list("Camera Net", "Cameras: [length(GLOB.cameranet.cameras)] | Chunks: [length(GLOB.cameranet.chunks)]", "[GLOB.cameranet.UID()]")

///immediately update the active statpanel tab of the target client
/datum/controller/subsystem/statpanels/proc/immediate_send_stat_data(client/target)
	if(!target.stat_panel.is_ready())
		return FALSE

	if(target.stat_tab == "Status")
		set_status_tab(target)
		return TRUE

	if(!target.holder)
		return FALSE

	if(target.stat_tab == "MC")
		set_MC_tab(target)
		return TRUE

	if(!length(GLOB.sdql2_queries) && ("SDQL2" in target.panel_tabs))
		target.stat_panel.send_message("remove_sdql2")

	else if(length(GLOB.sdql2_queries) && target.stat_tab == "SDQL2")
		set_SDQL2_tab(target)

/// Stat panel window declaration, we don't usually allow this but tgui windows/panels are exceptions
/* check_grep:ignore */ /client/var/datum/tgui_window/stat_panel
