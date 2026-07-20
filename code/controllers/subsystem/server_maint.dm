#define PING_BUFFER_TIME 25

SUBSYSTEM_DEF(server_maint)
	name = "Server Tasks"
	wait = 6
	ss_flags = SS_POST_FIRE_TIMING
	priority = FIRE_PRIORITY_SERVER_MAINT
	init_stage = INITSTAGE_EARLY
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	var/list/currentrun

/datum/controller/subsystem/server_maint/PreInit()
	world.hub_password = "" //quickly! before the hubbies see us.

/datum/controller/subsystem/server_maint/Initialize()
	if(fexists("tmp/"))
		fdel("tmp/")

	if(CONFIG_GET(flag/hub))
		world.update_hub_visibility(TRUE)

	var/datum/tgs_version/tgsversion = world.TgsVersion()
	if(tgsversion)
		SSblackbox.record_feedback("text", "server_tools", 1, tgsversion.raw_parameter)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/server_maint/fire(resumed = FALSE)
	if(!resumed)
		if(list_clear_nulls(GLOB.clients))
			log_world("Found a null in clients list!")
		src.currentrun = GLOB.clients.Copy()

	var/list/currentrun = src.currentrun
	var/round_started = SSticker.HasRoundStarted()

	var/kick_inactive = CONFIG_GET(flag/kick_inactive)
	var/afk_period
	if(kick_inactive)
		afk_period = CONFIG_GET(number/afk_period)
	while(length(currentrun))
		var/client/processing_client = currentrun[length(currentrun)]
		currentrun.len--
		//handle kicking inactive players
		if(round_started && kick_inactive && !processing_client.holder && processing_client.is_afk(afk_period))
			var/cmob = processing_client.mob
			if(!isnewplayer(cmob) /* || !SSticker.queued_players.Find(cmob)*/)
				log_access_afk(processing_client)
				to_chat(processing_client, span_userdanger("You have been inactive for more than [DisplayTimeText(afk_period)] and have been disconnected.</span><br><span class='danger'>You may reconnect via the button in the file menu or by <b><u><a href='byond://winset?command=.reconnect'>clicking here to reconnect</a></u></b>."))
				QDEL_IN(processing_client, 1) //to ensure they get our message before getting disconnected
				continue

		if(MC_TICK_CHECK) //one day, when ss13 has 1000 people per server, you guys are gonna be glad I added this tick check
			return

/datum/controller/subsystem/server_maint/Shutdown()
	if(fexists("tmp/"))
		fdel("tmp/")
	kick_clients_in_lobby(span_boldannounceooc("The round came to an end with you in the lobby."), TRUE) //second parameter ensures only afk clients are kicked
	var/server = CONFIG_GET(string/server)
	for(var/client/user as anything in GLOB.clients)
		if(!user)
			continue
		user?.tgui_panel?.send_roundrestart()
		if(server) //if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			user << link("byond://[server]")


/datum/controller/subsystem/server_maint/proc/UpdateHubStatus()
	if(!CONFIG_GET(flag/hub) || !CONFIG_GET(number/max_hub_pop))
		return FALSE //no point, hub / auto hub controls are disabled

	var/max_pop = CONFIG_GET(number/max_hub_pop)

	if(GLOB.clients.len > max_pop)
		world.update_hub_visibility(FALSE)
	else
		world.update_hub_visibility(TRUE)
#undef PING_BUFFER_TIME
