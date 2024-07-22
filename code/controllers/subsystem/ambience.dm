/// The subsystem used to play ambience to users every now and then, makes them real excited.
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	flags = SS_BACKGROUND | SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "ambience"
	///Assoc list of listening client - next ambience time
	var/list/ambience_listening_clients = list()
	var/list/client_old_areas = list()
	var/list/currentrun = list()


/datum/controller/subsystem/ambience/proc/remove_ambience_client(client/to_remove)
	ambience_listening_clients -= to_remove
	client_old_areas -= to_remove
	currentrun -= to_remove

/datum/controller/subsystem/ambience/fire(resumed)
	if(!resumed)
		currentrun = ambience_listening_clients.Copy()
	var/list/cached_clients = currentrun

	while(cached_clients.len)
		var/client/client_iterator = cached_clients[cached_clients.len]
		cached_clients.len--

		if(isnull(client_iterator))
			ambience_listening_clients -= client_iterator
			client_old_areas -= client_iterator
			continue

		//Check to see if the client isn't held by a new player
		var/mob/client_mob = client_iterator?.mob
		if(!client_mob || isnewplayer(client_mob))
			continue

		if(!client_mob.can_hear()) //WHAT? I CAN'T HEAR YOU
			client_iterator.white_noise_playing = FALSE
			client_mob.stop_sound_channel(CHANNEL_BUZZ)
			continue

		var/area/current_area = get_area(client_mob)

		if(ambience_listening_clients[client_iterator] > world.time)
			if(!((client_old_areas?[client_iterator] != current_area) && prob(5)))
				continue

		if(!current_area) //Something's gone horribly wrong
			stack_trace("[key_name(client_mob)] has somehow ended up in nullspace.")
			ambience_listening_clients -= client_iterator
			continue

		if(client_iterator.white_noise_playing == FALSE && client_iterator.prefs.sound & SOUND_BUZZ)
			client_iterator.white_noise_playing = TRUE
			SEND_SOUND(client_iterator.mob, sound('sound/ambience/shipambience.ogg', repeat = TRUE, wait = FALSE, volume = 35 * client_iterator.prefs.get_channel_volume(CHANNEL_BUZZ), channel = CHANNEL_BUZZ))

		var/ambience = safepick(current_area.ambientsounds)
		if(!ambience)
			continue

		SEND_SOUND(client_iterator.mob, sound(ambience, repeat = 0, wait = 0, volume = 25 * client_iterator.prefs.get_channel_volume(CHANNEL_AMBIENCE), channel = CHANNEL_AMBIENCE))


		ambience_listening_clients[client_iterator] = world.time + rand(current_area.min_ambience_cooldown, current_area.max_ambience_cooldown)

		if(client_iterator)
			client_old_areas[client_iterator] = current_area

		if(MC_TICK_CHECK)
			return

