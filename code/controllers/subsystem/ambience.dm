/// The subsystem used to play ambience to users every now and then, makes them real excited.
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	ss_flags = SS_BACKGROUND | SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS

	///Assoc list of listening client - next ambience time
	var/list/ambience_listening_clients = list()
	var/list/client_old_areas = list()
	/// Cache for sanic speed
	var/list/currentrun = list()

/datum/controller/subsystem/ambience/fire(resumed)
	if(!resumed)
		currentrun = ambience_listening_clients.Copy()
	var/list/cached_clients = currentrun

	while(length(cached_clients))
		var/client/client_iterator = cached_clients[length(cached_clients)]
		cached_clients.len--

		//Check to see if the client exists and isn't held by a new player
		if(isnull(client_iterator))
			continue
		var/mob/client_mob = client_iterator.mob
		if(!client_mob)
			ambience_listening_clients -= client_iterator
			client_old_areas -= client_iterator
			continue
		if(isnewplayer(client_mob))
			continue

		if(HAS_TRAIT(client_mob, TRAIT_DEAF)) //WHAT? I CAN'T HEAR YOU
			continue

		//Check to see if the client-mob is in a valid area
		var/area/current_area = get_area(client_mob)
		if(!current_area) //Something's gone horribly wrong
			stack_trace("[key_name(client_mob)] has somehow ended up in nullspace. WTF did you do?")
			remove_ambience_client(client_iterator)
			continue

		if(ambience_listening_clients[client_iterator] > world.time)
			if(!(current_area.forced_ambience && (client_old_areas?[client_iterator] != current_area) && prob(5)))
				continue

		//Run play_ambience() on the client-mob and set a cooldown
		ambience_listening_clients[client_iterator] = world.time + current_area.play_ambience(client_mob)

		//We REALLY don't want runtimes in SSambience
		if(client_iterator)
			client_old_areas[client_iterator] = current_area

		if(MC_TICK_CHECK)
			return

///Attempts to play an ambient sound to a mob, returning the cooldown in deciseconds
/area/proc/play_ambience(mob/target, sound/override_sound, volume = 27)
	var/sound/new_sound = override_sound || pick(ambientsounds)
	if(!new_sound) // Dont try to play a sound if we dont have any.
		return 1 MINUTES
	/// volume modifier for ambience as set by the player in preferences.
	var/volume_modifier = target.client?.prefs.get_channel_volume(CHANNEL_AMBIENCE)
	new_sound = sound(new_sound, repeat = 0, wait = 0, volume = volume * volume_modifier, channel = CHANNEL_AMBIENCE)
	SEND_SOUND(target, new_sound)

	var/sound_length = SSsounds.get_sound_length(new_sound.file)
	if(!sound_length)
		// This will cause sounds to cut into eachother if the sound is longer then the min_ambience_cooldown
		stack_trace("play_ambience failed to get soundlength from [new_sound] with a file of [new_sound.file].")
	return sound_length + rand(min_ambience_cooldown, max_ambience_cooldown)

/datum/controller/subsystem/ambience/proc/remove_ambience_client(client/to_remove)
	ambience_listening_clients -= to_remove
	client_old_areas -= to_remove
	currentrun -= to_remove

/**
 * Ambience buzz handling called by either area/Enter() or refresh_looping_ambience()
 */
/mob/proc/update_ambience_area(area/new_area)
	var/old_tracked_area = ambience_tracked_area
	if(old_tracked_area)
		UnregisterSignal(old_tracked_area, COMSIG_AREA_POWER_CHANGE)
		ambience_tracked_area = null
	if(!client)
		return
	if(!new_area)
		return
	ambience_tracked_area = new_area
	RegisterSignal(ambience_tracked_area, COMSIG_AREA_POWER_CHANGE, PROC_REF(refresh_looping_ambience), TRUE)

	refresh_looping_ambience()

/mob/proc/refresh_looping_ambience()
	SIGNAL_HANDLER

	if(!client || isobserver(client.mob)) // If a tree falls in the woods. sadboysuss: Don't refresh for ghosts, it sounds bad
		return

	var/area/my_area = get_area(src)
	var/sound_to_use = my_area?.ambient_buzz
	var/volume_modifier = client?.prefs.get_channel_volume(CHANNEL_BUZZ)

	if(!sound_to_use || !volume_modifier)
		SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = CHANNEL_BUZZ))
		client.current_ambient_sound = null
		return

	if(HAS_TRAIT(src, TRAIT_DEAF)) // Can the mob hear?
		SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = CHANNEL_BUZZ))
		client.current_ambient_sound = null
		return

	// Station ambience is dependent on a functioning and charged APC with environment power enabled.
	for(var/obj/machinery/power/apc/current_apc as anything in my_area.apc)
		if(!is_mining_level(my_area.z) && ((!current_apc || !current_apc.operating || !current_apc.cell?.charge && my_area.requires_power || !my_area.power_environ)))
			SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = CHANNEL_BUZZ))
			client.current_ambient_sound = null
			return

		if(sound_to_use == client.current_ambient_sound) // Don't reset current loops
			return

		client.current_ambient_sound = sound_to_use
		SEND_SOUND(src, sound(my_area.ambient_buzz, repeat = 1, wait = 0, volume = my_area.ambient_buzz_vol * volume_modifier, channel = CHANNEL_BUZZ))
