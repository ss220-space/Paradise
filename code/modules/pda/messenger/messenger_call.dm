GLOBAL_LIST_EMPTY(increw_call_frequencies)

/proc/get_increw_call_frequency()
	var/list/reserved = list(ATMOS_TANKS_FREQ, ATMOS_DISTRO_FREQ, BOT_BEACON_FREQ, BOT_FREQ, AIRLOCK_FREQ, IMPL_FREQ, RSD_FREQ)
	for(var/channel, channel_frequency in SSradio.radiochannels)
		reserved += channel_frequency

	var/list/available = list()
	for(var/frequency in PUBLIC_LOW_FREQ to PUBLIC_HIGH_FREQ step 2)
		if(!(frequency in reserved) && !GLOB.increw_call_frequencies["[frequency]"])
			available += frequency
	return length(available) ? pick(available) : null

/datum/increw_call
	var/datum/messenger_chat/chat
	var/datum/messenger_account/initiator
	var/caller_name
	/// Profile -> call member.
	var/list/members = list()
	var/frequency
	var/active = FALSE
	var/ring_until
	var/ring_timer

/datum/increw_call/New(datum/messenger_chat/chat, datum/messenger_account/initiator, frequency)
	src.chat = chat
	src.initiator = initiator
	src.frequency = frequency
	caller_name = initiator.owner.owner_name
	ring_until = world.time + INCREW_CALL_RING_TIME
	chat.active_call = src
	GLOB.increw_call_frequencies["[frequency]"] = src
	return ..()

/datum/increw_call/Destroy()
	if(ring_timer)
		deltimer(ring_timer)
		ring_timer = null
	for(var/datum/messenger_account/profile as anything in members)
		remove_member(profile, check_quorum = FALSE)
	GLOB.increw_call_frequencies -= "[frequency]"
	if(chat?.active_call == src)
		chat.active_call = null
	chat = null
	initiator = null
	return ..()

/datum/increw_call/proc/add_member(datum/messenger_account/profile, datum/data/pda/app/increw/device, accepted = FALSE)
	var/datum/increw_call_member/member = new(src, profile, device, accepted)
	members[profile] = member
	profile.active_call = src
	device.call_member = member
	if(!accepted)
		member.notify_invite()

/datum/increw_call/proc/remove_member(datum/messenger_account/profile, check_quorum = TRUE)
	var/datum/increw_call_member/member = members[profile]
	if(!member)
		return FALSE

	members -= profile
	if(!member.quiet)
		member.play_tone('sound/machines/deniedbeep.ogg')
	qdel(member)
	if(check_quorum && (length(members) < 2 || (!active && profile == initiator) || (active && count_connected() < 2)))
		qdel(src)
	else if(profile == initiator)
		initiator = null
	return TRUE

/datum/increw_call/proc/count_connected()
	var/count = 0
	for(var/profile, value in members)
		var/datum/increw_call_member/member = value
		if(member.accepted && member.is_available())
			count++
	return count

/datum/increw_call/proc/accept(datum/increw_call_member/member)
	if(member.accepted || world.time >= ring_until)
		return FALSE
	member.accepted = TRUE
	member.quiet = FALSE
	member.device.refresh_alert(member.profile)
	chat.add_message("[member.profile.owner.owner_name] подключился(-ась) к звонку.", event_actor = member.profile)
	if(active)
		member.connect_radio()
	else if(count_connected() >= 2)
		active = TRUE
		for(var/profile, value in members)
			var/datum/increw_call_member/participant = value
			if(participant.accepted && participant.is_available())
				participant.connect_radio()
	return TRUE

/datum/increw_call/proc/decline(datum/increw_call_member/member)
	if(member.accepted || member.quiet || world.time >= ring_until)
		return FALSE
	var/datum/messenger_account/profile = member.profile
	chat.add_message("[profile.owner.owner_name] отклонил(-а) звонок.", event_actor = profile)
	if(!chat.is_group)
		return remove_member(profile)

	member.quiet = TRUE
	member.device.refresh_alert(profile)
	return TRUE

/datum/increw_call/proc/ring()
	ring_timer = null
	for(var/datum/messenger_account/profile, value in members)
		var/datum/increw_call_member/member = value
		if(!member.is_available() || (!member.accepted && world.time >= ring_until))
			remove_member(profile)
			if(QDELETED(src))
				return
		else if(!member.accepted && !member.quiet)
			member.play_tone(member.device.get_call_ringtone_sound(), audible_nearby = TRUE)
		else if(member.accepted && !active)
			member.play_tone('sound/machines/twobeep.ogg')
	ring_timer = addtimer(CALLBACK(src, PROC_REF(ring)), INCREW_CALL_RING_INTERVAL, TIMER_STOPPABLE)

/datum/increw_call/proc/get_ui_data(datum/increw_call_member/member)
	var/connected = member.accepted && active
	var/state = "incoming"
	if(member.accepted)
		state = connected ? "connected" : "ringing"

	return list(
		"id" = UID(),
		"state" = state,
		"chat_name" = chat.get_display_name(member.profile),
		"caller_name" = caller_name,
		"is_group" = chat.is_group,
		"connected_count" = connected ? count_connected() : 0,
		"frequency" = connected ? format_frequency(frequency) : null,
		"mic_on" = connected && member.radio?.get_broadcasting(),
		"quiet" = member.quiet,
	)

/datum/increw_call_member
	var/datum/increw_call/call_session
	var/datum/messenger_account/profile
	var/datum/data/pda/app/increw/device
	var/mob/living/user
	var/obj/item/radio/increw/radio
	var/accepted = FALSE
	var/quiet = FALSE

/datum/increw_call_member/New(datum/increw_call/call_session, datum/messenger_account/profile, datum/data/pda/app/increw/device, accepted)
	src.call_session = call_session
	src.profile = profile
	src.device = device
	src.accepted = accepted
	user = device.pda.loc
	return ..()

/datum/increw_call_member/Destroy()
	if(device.pda)
		UnregisterSignal(device.pda, COMSIG_MOVABLE_HEAR)
	QDEL_NULL(radio)
	device.call_member = null
	profile.active_call = null
	if(!QDELETED(device.pda))
		device.refresh_alert(device.get_profile(device.pda.loc))
	call_session = null
	profile = null
	device = null
	user = null
	return ..()

/datum/increw_call_member/proc/is_available()
	var/obj/item/pda/pda = device?.pda
	return !QDELETED(pda) && user?.client && user.stat != DEAD && device.is_signed_in_as(profile, user)

/datum/increw_call_member/proc/notify_invite()
	var/chat_name = html_encode(call_session.chat.get_display_name(profile))
	var/caller_name = html_encode(call_session.caller_name)
	to_chat(user, span_notice("InCrew: [caller_name] вызывает вас в «[chat_name]». Откройте InCrew, чтобы ответить."))
	device.refresh_alert(profile)

/datum/increw_call_member/proc/play_tone(sound_file, audible_nearby = FALSE)
	if(!is_available() || device.pda.silent)
		return
	if(audible_nearby)
		playsound(
			device.pda,
			sound_file,
			45,
			FALSE,
			extrarange = INCREW_CALL_RING_RANGE - SOUND_RANGE,
			ignore_walls = FALSE,
		)
		return
	user.playsound_local(get_turf(user), sound_file, 45, FALSE, pressure_affected = FALSE)

/datum/increw_call_member/proc/connect_radio()
	radio = new(device.pda, src, call_session.frequency)
	RegisterSignal(device.pda, COMSIG_MOVABLE_HEAR, PROC_REF(relay_speech))
	play_tone('sound/machines/terminal_prompt_confirm.ogg')

/datum/increw_call_member/proc/relay_speech(obj/item/pda/source, mob/speaker, list/message_pieces)
	SIGNAL_HANDLER
	// Speech reaches the PDA in the inventory, not the radio inside it.
	if(speaker == user)
		radio?.talk_into(user, message_pieces, null)

/obj/item/radio/increw
	name = "InCrew radio"
	freqlock = TRUE
	canhear_range = 0
	instant = TRUE
	var/datum/increw_call_member/call_member

/obj/item/radio/increw/Initialize(mapload, datum/increw_call_member/call_member, frequency)
	src.call_member = call_member
	if(frequency)
		default_frequency = frequency
	. = ..()
	if(!call_member)
		return INITIALIZE_HINT_QDEL
	set_broadcasting(TRUE)

/obj/item/radio/increw/Destroy(force)
	call_member = null
	return ..()

/obj/item/radio/increw/get_internal_channels()
	return list()

/obj/item/radio/increw/talk_into(mob/living/speaker, list/message_pieces, channel, verbage)
	if(!call_member?.is_available() || speaker != call_member.user || !get_broadcasting())
		return FALSE
	return ..()

/obj/item/radio/increw/can_receive(freq, level)
	return call_member?.is_available() && ..()

/obj/item/radio/increw/deliver()
	return call_member?.is_available() ? list(call_member.user) : list()
