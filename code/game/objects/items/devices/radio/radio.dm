GLOBAL_LIST_INIT(default_internal_channels, list(
	num2text(PUB_FREQ) = list(),
	num2text(AI_FREQ)  = list(ACCESS_CAPTAIN),
	num2text(ERT_FREQ) = list(ACCESS_CENT_SPECOPS),
	num2text(COMM_FREQ)= list(ACCESS_HEADS),
	num2text(ENG_FREQ) = list(ACCESS_ENGINE, ACCESS_ATMOSPHERICS),
	num2text(MED_FREQ) = list(ACCESS_MEDICAL),
	num2text(MED_I_FREQ)=list(ACCESS_MEDICAL),
	num2text(SEC_FREQ) = list(ACCESS_SECURITY),
	num2text(PRS_FREQ) = list(ACCESS_SECURITY),
	num2text(SEC_I_FREQ)=list(ACCESS_SECURITY),
	num2text(SCI_FREQ) = list(ACCESS_RESEARCH),
	num2text(SUP_FREQ) = list(ACCESS_CARGO),
	num2text(SRV_FREQ) = list(ACCESS_HOP, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_CLOWN, ACCESS_MIME),
	num2text(PROC_FREQ)= list(ACCESS_MAGISTRATE, ACCESS_NTREP, ACCESS_LAWYER)
))

GLOBAL_LIST_INIT(default_medbay_channels, list(
	num2text(PUB_FREQ) = list(),
	num2text(MED_FREQ) = list(ACCESS_MEDICAL),
	num2text(MED_I_FREQ) = list(ACCESS_MEDICAL)
))

GLOBAL_LIST_INIT(default_security_channels, list(
	num2text(PUB_FREQ) = list(),
	num2text(SEC_I_FREQ) = list(ACCESS_SECURITY)
))

GLOBAL_LIST_INIT(default_syndicate_channels, list(
	num2text(SYND_FREQ) = list(ACCESS_SYNDICATE),
	num2text(SYND_TAIPAN_FREQ) = list(ACCESS_SYNDICATE)
))

GLOBAL_LIST_INIT(default_pirate_channels, list(
		num2text(PUB_FREQ) = list(),
		num2text(AI_FREQ)  = list(),
		num2text(COMM_FREQ) = list(),
		num2text(ENG_FREQ) = list(),
		num2text(PRS_FREQ) = list(),
		num2text(MED_FREQ) = list(),
		num2text(MED_I_FREQ)= list(),
		num2text(SEC_FREQ) = list(),
		num2text(SEC_I_FREQ) = list(),
		num2text(SCI_FREQ) = list(),
		num2text(SUP_FREQ) = list(),
		num2text(SRV_FREQ) = list()
))

/obj/item/radio
	name = "shortwave radio"
	desc = "Базовая портативная рация, способная взаимодействовать с локальными телекоммуникационными сетями."
	gender = FEMALE
	icon = 'icons/obj/radio.dmi'
	icon_state = "walkietalkie"
	item_state = "walkietalkie"
	belt_icon = "radio"
	dog_fashion = /datum/dog_fashion/back
	suffix = "\[3\]"
	var/last_transmission
	/// tune to frequency to unlock traitor supplies
	var/traitor_frequency = 0
	/// the range which mobs can hear this radio from
	var/canhear_range = 3
	var/datum/wires/radio/wires = null
	var/b_stat = 0

	///if FALSE, broadcasting and listening dont matter and this radio shouldnt do anything
	VAR_PRIVATE/on = TRUE
	///the "default" radio frequency this radio is set to, listens and transmits to this frequency by default. wont work if the channel is encrypted
	VAR_PRIVATE/frequency = PUB_FREQ

	/// Whether the radio will transmit dialogue it hears nearby into its radio channel.
	VAR_PRIVATE/broadcasting = FALSE
	/// Whether the radio is currently receiving radio messages from its radio frequencies.
	VAR_PRIVATE/listening = TRUE

	//the below three vars are used to track listening and broadcasting should they be forced off for whatever reason but "supposed" to be active
	//eg player sets the radio to listening, but an emp or whatever turns it off, its still supposed to be activated but was forced off,
	//when it wears off it sets listening to should_be_listening

	///used for tracking what broadcasting should be in the absence of things forcing it off, eg its set to broadcast but gets emp'd temporarily
	var/should_be_broadcasting = FALSE
	///used for tracking what listening should be in the absence of things forcing it off, eg its set to listen but gets emp'd temporarily
	var/should_be_listening = TRUE

	var/default_frequency = PUB_FREQ

	/// Whether the radio can be re-tuned to restricted channels it has no key for
	var/freerange = FALSE
	/// Whether the radio is able to have its primary frequency changed. Used for radios with weird primary frequencies, like DS, syndi, etc
	var/freqlock = FALSE

	/// Whether the radio broadcasts to everyone within a few tiles, or not
	var/loudspeaker = FALSE
	/// Whether loudspeaker can be toggled by the user
	var/has_loudspeaker = FALSE

	/// see communications.dm for full list. First channes is a "default" for :h
	var/list/channels = list()

	var/list/channels_configs
	/// Holder for the syndicate encryption key if present
	var/obj/item/encryptionkey/syndicate/syndiekey = null
	/// How many times this is disabled by EMPs
	var/disable_timer = 0

	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throw_range = 9
	w_class = WEIGHT_CLASS_SMALL

	materials = list(MAT_METAL=75)

	var/obj/item/encryptionkey/keyslot

	var/const/FREQ_LISTENING = 1

	var/list/internal_channels

	var/list/datum/radio_frequency/secure_radio_connections
	var/datum/radio_frequency/radio_connection

	var/requires_tcomms = FALSE // Does this device require tcomms to work.If TRUE it wont function at all without tcomms. If FALSE, it will work without tcomms, just slowly
	var/instant = FALSE // Should this device instantly communicate if there isnt tcomms

/obj/item/radio/get_ru_names()
	return list(
		NOMINATIVE = "коротковолновая рация",
		GENITIVE = "коротковолновой рации",
		DATIVE = "коротковолновой рации",
		ACCUSATIVE = "коротковолновую рацию",
		INSTRUMENTAL = "коротковолновой рацией",
		PREPOSITIONAL = "коротковолновой рации",
	)

/obj/item/radio/Initialize(mapload)
	wires = new(src)
	. = ..()
	internal_channels = get_internal_channels()
	GLOB.global_radios |= src
	become_hearing_sensitive(ROUNDSTART_TRAIT)
	if(default_frequency < RADIO_LOW_FREQ || default_frequency > RADIO_HIGH_FREQ)
		default_frequency = sanitize_frequency(default_frequency, RADIO_LOW_FREQ, RADIO_HIGH_FREQ)
	set_on(on)
	recalculate_channels()
	set_frequency(default_frequency)

/obj/item/radio/Destroy(force)
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	lose_hearing_sensitivity(ROUNDSTART_TRAIT)
	set_on(FALSE)
	SSradio?.remove_object_all(src)
	LAZYCLEARLIST(secure_radio_connections)
	GLOB.global_radios -= src
	return ..()

/obj/item/radio/dummy/Initialize(mapload)
	. = ..()
	// this is just dummy. We minimalize memmory usage for this object
	Destroy()

//simple getters only because i NEED to enforce complex setter use for these vars for caching purposes but VAR_PROTECTED requires getter usage as well.
//if another decorator is made that doesnt require getters feel free to nuke these and change these vars over to that

///simple getter for the on variable. necessary due to VAR_PROTECTED
/obj/item/radio/proc/is_on()
	return on

///simple getter for the frequency variable. necessary due to VAR_PROTECTED
/obj/item/radio/proc/get_frequency()
	return frequency

///simple getter for the broadcasting variable. necessary due to VAR_PROTECTED
/obj/item/radio/proc/get_broadcasting()
	return broadcasting

///simple getter for the listening variable. necessary due to VAR_PROTECTED
/obj/item/radio/proc/get_listening()
	return listening

//now for setters for the above protected vars

/**
 * setter for the listener var, adds or removes this radio from the global radio list if we are also on
 *
 * * new_listening - the new value we want to set listening to
 * * actual_setting - whether or not the radio is supposed to be listening, sets should_be_listening to the new listening value if true, otherwise just changes listening
 */
/obj/item/radio/proc/set_listening(new_listening, actual_setting = TRUE)
	if(!on)
		return
	var/old_listening = listening
	listening = new_listening

	if(old_listening == listening)
		return

	if(actual_setting)
		should_be_listening = listening

	if(listening)
		recalculate_channels()
		return

	reset_channels()

/**
 * setter for broadcasting that makes us not hearing sensitive if not broadcasting and hearing sensitive if broadcasting
 * hearing sensitive in this case only matters for the purposes of listening for words said in nearby tiles, talking into us directly bypasses hearing
 *
 * * new_broadcasting- the new value we want to set broadcasting to
 * * actual_setting - whether or not the radio is supposed to be broadcasting, sets should_be_broadcasting to the new value if true, otherwise just changes broadcasting
 */
/obj/item/radio/proc/set_broadcasting(new_broadcasting, actual_setting = TRUE)
	if(!on)
		return

	broadcasting = new_broadcasting
	if(actual_setting)
		should_be_broadcasting = broadcasting

	if(broadcasting) //we dont need hearing sensitivity if we arent broadcasting, because talk_into doesnt care about hearing
		become_hearing_sensitive(INNATE_TRAIT)
		return
	lose_hearing_sensitivity(INNATE_TRAIT)

/obj/item/radio/proc/get_internal_channels()
	return GLOB.default_internal_channels

///setter for the on var that sets both broadcasting and listening to off or whatever they were supposed to be
/obj/item/radio/proc/set_on(new_on)

	on = new_on

	if(on)
		set_broadcasting(should_be_broadcasting)//set them to whatever theyre supposed to be
		set_listening(should_be_listening)
		return

	set_broadcasting(FALSE, actual_setting = FALSE)//fake set them to off
	set_listening(FALSE, actual_setting = FALSE)

/obj/item/radio/proc/set_frequency(new_frequency)
	SEND_SIGNAL(src, COMSIG_RADIO_NEW_FREQUENCY, args)
	SSradio.remove_object(src, frequency)
	radio_connection = null
	if(new_frequency)
		frequency = new_frequency

	if(listening && on)
		radio_connection = SSradio.add_object(src, frequency, RADIO_CHAT)

/obj/item/radio/emag_act(mob/user)
	if(!user.mind.special_role && !is_admin(user) || !hidden_uplink)
		var/turf/T = get_turf(loc)

		if(ismob(loc))
			var/mob/M = loc
			M.show_message(span_danger("Ваша [declent_ru(NOMINATIVE)] взрывается!"), 1)

		if(T)
			T.hotspot_expose(700, 125)
			explosion(T, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flash_range = 3, cause = src)
		qdel(src)
	else
		hidden_uplink.trigger(user)

/obj/item/radio/attack_ghost(mob/user)
	return interact(user)

/obj/item/radio/attack_self(mob/user)
	ui_interact(user)

/obj/item/radio/interact(mob/user)
	if(!user)
		return 0
	if(b_stat)
		wires.Interact(user)
	ui_interact(user)

/obj/item/radio/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Radio", capitalize(declent_ru(NOMINATIVE)))
		ui.open()

/obj/item/radio/ui_data(mob/user)
	var/list/data = list()

	data["broadcasting"] = broadcasting
	data["listening"] = listening
	data["frequency"] = frequency
	data["minFrequency"] = freerange ? RADIO_LOW_FREQ : PUBLIC_LOW_FREQ
	data["maxFrequency"] = freerange ? RADIO_HIGH_FREQ : PUBLIC_HIGH_FREQ
	data["canReset"] = frequency == initial(frequency) ? FALSE : TRUE
	data["freqlock"] = freqlock
	data["schannels"] = list_secure_channels(user)
	data["ichannels"] = list_internal_channels(user)

	data["has_loudspeaker"] = has_loudspeaker
	data["loudspeaker"] = loudspeaker
	return data

/obj/item/radio/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE
	switch(action)
		if("frequency")
			if(freqlock)
				return
			var/tune = params["tune"]
			var/adjust = text2num(params["adjust"])
			if(tune == "reset")
				tune = initial(frequency)
			else if(adjust)
				tune = frequency + adjust * 10
			else if(text2num(tune) != null)
				tune = tune * 10
			else
				. = FALSE
			if(hidden_uplink)
				if(hidden_uplink.check_trigger(usr, frequency, traitor_frequency))
					close_window(usr, "radio")
			if(.)
				set_frequency(sanitize_frequency(tune, freerange))

		if("ichannel") // change primary frequency to an internal channel authorized by access
			if(freqlock)
				return
			var/freq = params["ichannel"]
			if(has_channel_access(usr, num2text(freq)))
				set_frequency(freq)

		if("listen")
			set_listening(!listening)

		if("broadcast")
			set_broadcasting(!broadcasting)

		if("channel")
			var/channel = params["channel"]
			if(!(channel in channels))
				return
			if(channels[channel] & FREQ_LISTENING)
				channels[channel] &= ~FREQ_LISTENING
			else
				channels[channel] |= FREQ_LISTENING
			LAZYSET(channels_configs, channel, channels[channel])

		if("loudspeaker")
			// Toggle loudspeaker mode, AKA everyone around you hearing your radio.
			if(has_loudspeaker)
				loudspeaker = !loudspeaker
				if(loudspeaker)
					canhear_range = 3
				else
					canhear_range = 0
		else
			. = FALSE
	if(.)
		add_fingerprint(usr)

/obj/item/radio/proc/list_secure_channels(mob/user)
	var/list/dat = list()
	for(var/channel in channels)
		dat[channel] = channels[channel] & FREQ_LISTENING
	return dat

/obj/item/radio/proc/list_internal_channels(mob/user)
	var/list/dat = list()
	if(freqlock)
		return dat
	for(var/internal_chan in internal_channels)
		var/freqnum = text2num(internal_chan)
		var/freqname = get_frequency_name(freqnum)
		if(has_channel_access(user, internal_chan))
			dat[freqname] = freqnum // unlike secure_channels, this is set to the freq number so Radio.js can use it as an arg
	return dat

/obj/item/radio/proc/has_channel_access(mob/user, freq)
	if(!user)
		return FALSE

	if(!(freq in internal_channels))
		return FALSE

	if(isrobot(user))
		return FALSE // cyborgs and drones are not allowed to remotely re-tune intercomms, etc

	return user.has_internal_radio_channel_access(user, internal_channels[freq])

/mob/proc/has_internal_radio_channel_access(mob/user, list/req_accesses)
	var/obj/item/card/id/I = user.get_id_card()
	return has_access(req_accesses, TRUE, I ? I.GetAccess() : list())

/mob/living/silicon/has_internal_radio_channel_access(mob/user, list/req_accesses)
	return has_access(req_accesses, TRUE, get_all_accesses())

/mob/living/simple_animal/demon/pulse_demon/has_internal_radio_channel_access(mob/user, list/req_accesses)
	return has_access(req_accesses, TRUE, get_all_accesses())

/mob/dead/observer/has_internal_radio_channel_access(mob/user, list/req_accesses)
	return can_admin_interact()

/obj/item/radio/proc/ToggleBroadcast()
	set_broadcasting(!broadcasting && !(wires.is_cut(WIRE_RADIO_TRANSMIT) || wires.is_cut(WIRE_RADIO_SIGNAL)))

/obj/item/radio/proc/ToggleReception()
	set_listening(!listening && !(wires.is_cut(WIRE_RADIO_RECEIVER) || wires.is_cut(WIRE_RADIO_SIGNAL)))

/obj/item/radio/sec
	name = "security shortwave radio"
	desc = "Базовая портативная рация, способная взаимодействовать с локальными телекоммуникационными сетями. Специальная модель для сотрудников службы безопасности."
	icon_state = "walkietalkie_sec"
	item_state = "walkietalkie_sec"
	default_frequency = SEC_FREQ

/obj/item/radio/sec/get_ru_names()
	return list(
		NOMINATIVE = "коротковолновая рация СБ",
		GENITIVE = "коротковолновой рации СБ",
		DATIVE = "коротковолновой рации СБ",
		ACCUSATIVE = "коротковолновую рацию СБ",
		INSTRUMENTAL = "коротковолновой рацией СБ",
		PREPOSITIONAL = "коротковолновой рации СБ",
	)

// Interprets the message mode when talking into a radio, possibly returning a connection datum
/obj/item/radio/proc/handle_message_mode(mob/living/M, list/message_pieces, message_mode)
	// Otherwise, if a channel is specified, look for it.
	// If a channel isn't specified, send to common.
	if(!message_mode || message_mode == HEADSET_MODE)
		return radio_connection || RADIO_CONNECTION_FAIL

	if(channels && length(channels))
		if(message_mode == DEPARTMENT_FREQ_NAME) // Department radio shortcut
			message_mode = channels[1]

		if(channels[message_mode]) // only broadcast if the channel is set on
			return LAZYACCESS(secure_radio_connections, message_mode)

	// If we were to send to a channel we don't have, drop it.
	return RADIO_CONNECTION_FAIL

/obj/item/radio/talk_into(mob/living/M, list/message_pieces, channel, verbage = "говор%(ит,ят)%")
	if(!on)
		return FALSE // the device has to be on
	//  Fix for permacell radios, but kinda eh about actually fixing them.
	if(!M || !message_pieces)
		return FALSE

	//  Uncommenting this. To the above comment:
	//	The permacell radios aren't suppose to be able to transmit, this isn't a bug and this "fix" is just making radio wires useless. -Giacom
	if(wires.is_cut(WIRE_RADIO_TRANSMIT)) // The device has to have all its wires and shit intact
		return FALSE

	if(!M.IsVocal()  || M.cannot_speak_loudly())
		return FALSE

	if(M.is_muzzled())
		var/obj/item/organ/internal/cyberimp/mouth/translator/translator = M.get_organ_slot(INTERNAL_ORGAN_SPEECH_TRANSLATOR)
		if(translator) // you can't speak in radio with translator and gag
			return FALSE

		var/obj/item/clothing/mask/muzzle/muzzle = M.wear_mask
		if(muzzle.radio_mute)
			return FALSE

	var/jammed = FALSE
	var/turf/position = get_turf(src)
	for(var/obj/item/jammer/jammer as anything in GLOB.active_jammers)
		if(get_dist(position, get_turf(jammer)) < jammer.range)
			jammed = TRUE
			break

	var/message_mode = handle_message_mode(M, message_pieces, channel)
	switch(message_mode) //special cases
		// This is if the connection fails
		if(RADIO_CONNECTION_FAIL)
			return FALSE
		// This is if were using either a binary key, or a hivemind through a headset somehow. Dont ask.
		if(RADIO_CONNECTION_NON_SUBSPACE)
			return TRUE

	if(!istype(message_mode, /datum/radio_frequency)) //if not a special case, it should be returning a radio connection
		return

	var/datum/radio_frequency/connection = message_mode

	// ||-- The mob's name identity --||
	var/displayname = M.name	// grab the display name (name you get when you hover over someone's icon)
	var/voicemask = 0 // the speaker is wearing a voice mask
	var/jobname // the mob's "job"
	var/rankname // the formatting to be used for the mob's job

	if(jammed)
		Gibberish_all(message_pieces, 100)

	// --- Human: use their actual job ---
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		jobname = H.get_assignment()
		rankname = H.get_authentification_rank()

	// --- Carbon Nonhuman ---
	else if(iscarbon(M)) // Nonhuman carbon mob
		jobname = "Без ID"

	// --- AI ---
	else if(isAI(M))
		jobname = JOB_TITLE_AI

	// --- Cyborg ---
	else if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		jobname = R.mind.role_alt_title ? R.mind.role_alt_title : JOB_TITLE_CYBORG

	// --- Personal AI (pAI) ---
	else if(ispAI(M))
		var/mob/living/silicon/pai/pai = M
		displayname = pai.radio_name
		jobname = pai.radio_rank

	// --- Cogscarab ---
	else if(iscogscarab(M))
		jobname = UNKNOWN_STATUS_RUS

	// --- Unidentifiable mob ---
	else
		jobname = UNKNOWN_STATUS_RUS

	// --- Modifications to the mob's identity ---

	// The mob is disguising their identity:
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		displayname = H.voice
		if(H.voice != M.real_name)
			voicemask = TRUE

	if(syndiekey?.change_voice && connection.frequency == SYND_FREQ)
		displayname = syndiekey.fake_name
		jobname = UNKNOWN_STATUS_RUS
		rankname = UNKNOWN_STATUS_RUS
		voicemask = TRUE

	// Copy the message pieces so we can safely edit comms line without affecting the actual line
	var/list/message_pieces_copy = list()
	for(var/datum/multilingual_say_piece/S in message_pieces)
		message_pieces_copy += new /datum/multilingual_say_piece(S.speaking, S.message)

	// Make us a message datum!
	var/datum/tcomms_message/tcm = new
	tcm.sender_name = displayname
	tcm.sender_job = jobname
	tcm.sender_rank = rankname
	tcm.message_pieces = message_pieces_copy
	tcm.source_level = position.z
	tcm.freq = connection.frequency
	tcm.vmask = voicemask
	tcm.needs_tcomms = requires_tcomms
	tcm.connection = connection
	tcm.vname = M.voice_name
	tcm.sender = M
	tcm.verbage = verbage
	// Now put that through the stuff
	var/handled = FALSE
	if(connection)
		for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
			if(C.handle_message(tcm))
				handled = TRUE
				qdel(tcm) // Delete the message datum
				return TRUE

	// If we dont need tcomms and we have no connection
	if(!requires_tcomms && !handled)
		// If they dont need tcomms for their signal, set the type to intercoms
		tcm.data = SIGNALTYPE_INTERCOM_SBR
		tcm.zlevels = list(position.z)
		if(!instant)
			// Simulate two seconds of lag
			addtimer(CALLBACK(src, PROC_REF(broadcast_callback), tcm), 2 SECONDS)
		else
			// Nukeops + Deathsquad headsets are instant and should work the same, whether there is comms or not
			broadcast_message(tcm)
			qdel(tcm) // Delete the message datum
		return TRUE

	// If we didnt get here, oh fuck
	qdel(tcm) // Delete the message datum
	return FALSE

/obj/item/radio/hear_talk(mob/M as mob, list/message_pieces, verb = "говор%(ит,ят)%")
	. = ..()
	if(!broadcasting)
		return

	if(get_dist(src, M) > canhear_range)
		return

	talk_into(M, message_pieces, null, genderize_decode(M, verb))

// To the person who asks "Why is this in a callback?"
// You see, if you use QDEL_IN on the tcm and on broadcast_message()
// The timer SS races itself and the message can be deleted before its sent
// Having both in this callback removes that risk
/obj/item/radio/proc/broadcast_callback(datum/tcomms_message/tcm)
	broadcast_message(tcm)
	qdel(tcm) // Delete the message datum

/obj/item/radio/proc/receive_range(freq, level)
	// check if this radio can receive on the given frequency, and if so,
	// what the range is in which mobs will hear the radio
	// returns: -1 if can't receive, range otherwise

	if(!is_listening())
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(!position || !(position.z in level))
			return -1
	if(freq in SSradio.ANTAG_FREQS)
		if(!(syndiekey))//Checks to see if it's allowed on that frequency, based on the encryption keys
			return -1
		if(freq == SYND_TAIPAN_FREQ && !istype(syndiekey, /obj/item/encryptionkey/syndicate/taipan)) //Чтобы тайпановскую частоту, слышали только тайпановцы
			return -1

	if(!freq) //received on main frequency
		if(!listening)
			return -1
	else if(syndiekey && !(freq in SSradio.syndicate_blacklist))
		return canhear_range
	else
		var/accept = (freq==frequency && listening)
		if(!accept)
			for(var/ch_name in channels)
				var/datum/radio_frequency/RF = LAZYACCESS(secure_radio_connections, ch_name)
				if(RF.frequency==freq && (channels[ch_name]&FREQ_LISTENING))
					accept = 1
					break
		if(!accept)
			return -1
	return canhear_range

/obj/item/radio/proc/send_hear(freq, level)
	var/range = receive_range(freq, level)
	if(range > -1)
		return get_hearers_in_view(canhear_range, src)

/obj/item/radio/proc/is_listening()
	var/is_listening = TRUE
	if(!on)
		is_listening = FALSE
	if(!wires || wires.is_cut(WIRE_RADIO_RECEIVER))
		is_listening = FALSE
	if(!listening)
		is_listening = FALSE

	return is_listening

/obj/item/radio/proc/send_announcement()
	if(is_listening())
		return get_hearers_in_view(canhear_range, src)

	return null

/obj/item/radio/examine(mob/user)
	. = ..()
	if(in_range(src, user) || loc == user)
		if(b_stat)
			. += span_notice("Может быть прикреплено или модифицировано.")
		else
			. += span_notice("Не может быть прикреплено или модифицировано.")
		. += span_notice("Используйте <b>Ctrl+Shift+ЛКМ</b>, чтобы переключить динамик.<br/>Используйте <b>Alt+ЛКМ</b>, чтобы переключить микрофон.")

/obj/item/radio/click_alt(mob/user)
	set_broadcasting(!broadcasting)
	balloon_alert(user, "микрофон [broadcasting ? "включён" : "выключен"]")
	return CLICK_ACTION_SUCCESS

/obj/item/radio/CtrlShiftClick(mob/user) //weird checks
	if(!Adjacent(user))
		return
	if(!iscarbon(usr) && !isrobot(usr))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		balloon_alert(user, "невозможно!")
		return
	set_listening(!listening)
	balloon_alert(user, "динамик [listening ? "включён" : "выключен"]")

/obj/item/radio/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	user.set_machine(src)
	b_stat = !b_stat
	if(b_stat)
		balloon_alert(user, "модификация возможна!")
	else
		balloon_alert(user, "модификация невозможна!")
	updateDialog()

/obj/item/radio/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	interact(user)

/obj/item/radio/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	interact(user)

/obj/item/radio/emp_act(severity)
	set_on(FALSE)
	disable_timer++
	addtimer(CALLBACK(src, PROC_REF(enable_radio)), rand(100, 200))
	..()

/obj/item/radio/proc/enable_radio()
	if(disable_timer > 0)
		disable_timer--
	if(!disable_timer)
		set_on(TRUE)

/obj/item/radio/proc/recalculate_channels(setDescription = TRUE)
	reset_channels()

	load_channels()

	load_channel_configs()

	if(!listening)
		return

	for(var/channel_name in channels)
		if(!SSradio)
			make_broken()
			return
		LAZYSET(secure_radio_connections, channel_name, SSradio.add_object(src, SSradio.radiochannels[channel_name], RADIO_CHAT))

	set_frequency(frequency)

/obj/item/radio/proc/make_broken()
	return

/obj/item/radio/proc/load_channels()
	var/list/base_channels = get_base_channels()
	if(!LAZYLEN(base_channels))
		return
	list_clear_nulls(base_channels)
	for(var/channel_name in base_channels)
		if(channel_name in channels)
			continue
		channels[channel_name] = base_channels[channel_name]

/obj/item/radio/proc/get_base_channels()
	return keyslot?.channels

/obj/item/radio/proc/load_keyslot(obj/item/encryptionkey/key)
	return

/obj/item/radio/proc/load_channel_configs()
	for(var/channel in channels_configs)
		if(!(channel in channels))
			continue
		channels[channel] = channels_configs[channel]

/obj/item/radio/proc/reset_channels()
	channels = list()
	secure_radio_connections = null
	radio_connection = null
	SSradio.remove_object_all(src)

///////////////////////////////
//////////Borg Radios//////////
///////////////////////////////
//Giving borgs their own radio to have some more room to work with -Sieve

/obj/item/radio/borg
	name = "Cyborg Radio"
	desc = "Радио-компонент, предназначенный для использования в роботизированных системах."
	icon = 'icons/obj/robot_component.dmi' // Cyborgs radio icons should look like the component.
	icon_state = "radio"
	has_loudspeaker = TRUE
	canhear_range = 0
	dog_fashion = null
	freqlock = TRUE // don't let cyborgs change the default channel of their internal radio away from common
	var/mob/living/silicon/robot/myborg = null // Cyborg which owns this radio. Used for power checks

/obj/item/radio/borg/get_ru_names()
	return list(
		NOMINATIVE = "рация робота",
		GENITIVE = "рации робота",
		DATIVE = "рации робота",
		ACCUSATIVE = "рацию робота",
		INSTRUMENTAL = "рацией робота",
		PREPOSITIONAL = "рации робота",
	)

/obj/item/radio/borg/syndicate
	keyslot = new /obj/item/encryptionkey/syndicate/nukeops
	default_frequency = SYND_FREQ

/obj/item/radio/borg/syndicate/taipan
	keyslot = new /obj/item/encryptionkey/syndicate/taipan/borg

/obj/item/radio/borg/syndicate/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(. == UI_UPDATE && istype(user, /mob/living/silicon/robot/syndicate))
		. = UI_INTERACTIVE

/obj/item/radio/borg/Destroy()
	myborg = null
	return ..()

/obj/item/radio/borg/syndicate/Initialize(mapload)
	. = ..()
	syndiekey = keyslot
	freqlock = TRUE

/obj/item/radio/borg/deathsquad
	default_frequency = DTH_FREQ

/obj/item/radio/borg/deathsquad/Initialize(mapload)
	. = ..()
	freqlock = TRUE

/obj/item/radio/borg/ert
	keyslot = new /obj/item/encryptionkey/ert
	default_frequency = ERT_FREQ

/obj/item/radio/borg/ert/Initialize(mapload)
	. = ..()
	freqlock = TRUE

/obj/item/radio/borg/ert/specops
	keyslot = new /obj/item/encryptionkey/centcom

/obj/item/radio/borg/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/encryptionkey))
		add_fingerprint(user)
		user.set_machine(src)
		if(keyslot)
			balloon_alert(user, "слот для ключа занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return .()
		keyslot = I
		recalculate_channels()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/radio/borg/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	user.set_machine(src)
	if(keyslot)
		for(var/ch_name in channels)
			SSradio.remove_object(src, SSradio.radiochannels[ch_name])
			LAZYSET(secure_radio_connections, ch_name, null)

		if(keyslot)
			var/turf/T = get_turf(user)
			if(T)
				keyslot.loc = T
				keyslot = null

		recalculate_channels()
		balloon_alert(user, "ключ извлечён")
		I.play_tool_sound(user, I.tool_volume)

	else
		balloon_alert(user, "слот для ключа пуст!")

/obj/item/radio/borg/reset_channels()
	. = ..()
	syndiekey = null

/obj/item/radio/borg/load_channels()
	. = ..()
	load_keyslot(keyslot)

/obj/item/radio/borg/load_keyslot(obj/item/encryptionkey/key)
	if(!key)
		return

	if(!key.syndie)
		return

	syndiekey = key

/obj/item/radio/borg/get_base_channels()
	var/mob/living/silicon/robot/robot = loc
	return robot?.module?.channels | keyslot?.channels

/obj/item/radio/borg/make_broken()
	name = "broken radio"
	ru_names = list(
		NOMINATIVE = "сломанная рация",
		GENITIVE = "сломанной рации",
		DATIVE = "сломанной рации",
		ACCUSATIVE = "сломанную рацию",
		INSTRUMENTAL = "сломанной рацией",
		PREPOSITIONAL = "сломанной рации",
	)

/obj/item/radio/borg/interact(mob/user)
	if(!on)
		return
	. = ..()

/obj/item/radio/off
	should_be_listening = FALSE

/obj/item/radio/phone
	name = "phone"
	desc = "Телефон, подключённый к внутренней системе связи станции. Несколько старомодно для 26 века."
	gender = MALE
	icon = 'icons/obj/items.dmi'
	icon_state = "red_phone"
	drop_sound = 'sound/items/handling/drop/phone_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/phone_pickup.ogg'
	dog_fashion = null

/obj/item/radio/phone/get_ru_names()
	return list(
		NOMINATIVE = "телефон",
		GENITIVE = "телефона",
		DATIVE = "телефону",
		ACCUSATIVE = "телефон",
		INSTRUMENTAL = "телефоном",
		PREPOSITIONAL = "телефоне",
	)

/obj/item/radio/phone/medbay
	name = "medbay phone"
	desc = "Телефон, настроенный на медицинскую частоту системы связи станции. Дзинь."
	default_frequency = MED_I_FREQ

/obj/item/radio/phone/medbay/get_ru_names()
	return list(
		NOMINATIVE = "медицинский телефон",
		GENITIVE = "медицинского телефона",
		DATIVE = "медицинскому телефону",
		ACCUSATIVE = "медицинский телефон",
		INSTRUMENTAL = "медицинским телефоном",
		PREPOSITIONAL = "медицинском телефоне",
	)

/obj/item/radio/phone/medbay/get_internal_channels()
	return GLOB.default_medbay_channels

/obj/item/radio/bot
	tts_seed = null

/obj/item/radio/phone/ussp
	name = "Red phone"
	desc = "Телефон, подключённый к частоте СССП в пределах сектора."
	has_loudspeaker = TRUE
	default_frequency = SOV_FREQ

/obj/item/radio/phone/ussp/get_ru_names()
	return list(
		NOMINATIVE = "красный телефон",
		GENITIVE = "красного телефона",
		DATIVE = "красному телефону",
		ACCUSATIVE = "красный телефон",
		INSTRUMENTAL = "красным телефоном",
		PREPOSITIONAL = "красном телефоне",
	)
