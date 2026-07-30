/**
 * Returns a DB-friendly version of a volume mixer list.
 *
 * Arguments
 * * vm - The volume mixer list to serialize.
 */
/datum/preferences/proc/serialize_volume_mixer(list/vm)
	var/list/temp = list()
	for(var/channel in vm)
		if(!get_channel_name(text2num(channel)))
			continue
		temp["[channel]"] = vm[channel]
	return json_encode(temp)

/**
 * Returns a volume mixer list from text, usually from the DB.
 *
 * Failure to deserialize will return the current value.
 *
 * Arguments
 * * vmt - The volume mixer list to deserialize.
 */
/datum/preferences/proc/deserialize_volume_mixer(vmt)
	if(!istext(vmt))
		return volume_mixer
	var/list/vm = json_decode(vmt)
	if(!islist(vm))
		return volume_mixer
	var/list/temp = list()
	// Ensure the default values are present
	for(var/channel in volume_mixer)
		temp[channel] = volume_mixer[channel]
	for(var/channel in vm)
		if(!get_channel_name(text2num(channel)))
			continue
		temp[channel] = vm[channel]
	return temp

/**
 * Changes a channel's volume then queues it for DB save.
 *
 * Arguments:
 * * channel - The channel whose volume to change.
 * * volume - The new volume, clamped between 0 and 100.
 * * debounce_save - Whether to debounce the save call to prevent spamming of DB calls.
 */
/datum/preferences/proc/set_channel_volume(channel, volume, debounce_save = TRUE)
	if(!get_channel_name(channel))
		return
	volume = clamp(volume, 0, 100)
	volume_mixer["[channel]"] = volume

	apply_channel_volume(channel, volume)

	if(!debounce_save)
		if(volume_mixer_saving)
			deltimer(volume_mixer_saving)
		save_volume_mixer()
		return
	volume_mixer_saving = addtimer(CALLBACK(src, PROC_REF(save_volume_mixer)), 3 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)

/// Pushes the new volume to whatever is currently playing on the given channel.
/datum/preferences/proc/apply_channel_volume(channel, volume)
	var/client/owner = parent
	var/mob/owner_mob = owner?.mob

	// Update only loops parented to our mob — other players' loops on the same channel
	// would push their volume onto our client.
	var/updated_looping = FALSE
	for(var/datum/looping_sound/looping in GLOB.looping_sounds)
		if(looping.sound_channel != channel)
			continue
		if(looping.parent != owner_mob)
			continue
		send_volume_update(channel, looping.volume * volume / 100)
		updated_looping = TRUE
	if(updated_looping)
		return

	// Ambient buzz isn't a /datum/looping_sound — re-fire it so the new volume takes effect.
	if(channel == CHANNEL_BUZZ)
		if(owner_mob)
			owner.current_ambient_sound = null
			owner_mob.refresh_looping_ambience()
		return

	// Jukebox sounds are positional — let active jukeboxes re-emit a proper sound (with x/z)
	// instead of clobbering the channel via a flat send_volume_update that resets directionality.
	if(channel == CHANNEL_JUKEBOX)
		if(!isnull(owner_mob))
			SEND_SIGNAL(owner_mob, COMSIG_MOB_JUKEBOX_PREFERENCE_APPLIED)
		return

	send_volume_update(channel, volume)

/datum/preferences/proc/send_volume_update(channel, volume)
	var/sound/update = sound(null, channel = channel, volume = volume)
	update.status = SOUND_UPDATE
	SEND_SOUND(parent, update)

/**
 * Returns a volume multiplier for the given channel, from 0 to 1 (default).
 *
 * Arguments:
 * * channel - The channel whose volume to get.
 */
/datum/preferences/proc/get_channel_volume(channel)
	if(!istext(channel))
		channel = "[channel]"
	if(isnull(volume_mixer[channel]))
		return 1
	return clamp(volume_mixer[channel] / 100, 0, 1)

/client/verb/volume_mixer()
	set name = "Микшер громкости"
	set category = VERB_CATEGORY_SPECIALVERBS

	var/datum/ui_module/volume_mixer/VM = new()
	VM.ui_interact(usr)

