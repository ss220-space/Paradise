#define TELECOMMS_RECEPTION_NONE 0
#define TELECOMMS_RECEPTION_SENDER 1
#define TELECOMMS_RECEPTION_RECEIVER 2
#define TELECOMMS_RECEPTION_BOTH 3

/proc/get_frequency_name(display_freq)
	var/freq_text

	// the name of the channel
	switch(display_freq)
		if(SYND_FREQ)
			freq_text = "#unkn"
		if(SYND_TAIPAN_FREQ)
			freq_text = "#noid"
		if(SYNDTEAM_FREQ)
			freq_text = "#unid"
		else
			for(var/channel in SSradio.radiochannels)
				if(SSradio.radiochannels[channel] == display_freq)
					freq_text = channel
					break

	// --- If the frequency has not been assigned a name, just use the frequency as the name ---
	if(!freq_text)
		freq_text = format_frequency(display_freq)

	return freq_text

#undef TELECOMMS_RECEPTION_NONE
#undef TELECOMMS_RECEPTION_SENDER
#undef TELECOMMS_RECEPTION_RECEIVER
#undef TELECOMMS_RECEPTION_BOTH

/proc/radio_announce(message, from, freq, atom/sender = GLOB.global_announcer, follow_target_override) //BS12 EDIT
	if(!SSradio)
		return

	var/datum/radio_frequency/connection = SSradio.return_frequency(freq)

	if(!istype(connection))
		return

	var/jammed = FALSE
	var/turf/sender_loc = get_turf(sender)

	for(var/obj/item/jammer/jammer as anything in GLOB.active_jammers)
		if(get_dist(sender_loc, get_turf(jammer)) >= jammer.range)
			return
		jammed = TRUE
		break

	if(jammed)
		message = Gibberish(message, 100)

	var/list/message_pieces = message_to_multilingual(message)
	// Make us a message datum!
	var/datum/tcomms_message/tcm = new
	tcm.connection = connection
	tcm.sender = sender
	tcm.sender_name = from
	tcm.message_pieces = message_pieces
	tcm.sender_job = "Автоматическое оповещение"
	tcm.vname = "синтезированный голос"
	tcm.data = SIGNALTYPE_AINOTRACK
	// Datum radios dont have a location (obviously)
	tcm.source_level = sender_loc?.z || levels_by_trait(MAIN_STATION)[1] // For anyone that reads this: This used to pull from a LIST from the CONFIG DATUM. WHYYYYYYYYY!!!!!!!! -aa
																			// Assume main station level if we dont have an actual Z level available to us.
	tcm.freq = connection.frequency

	tcm.follow_target = follow_target_override || sender

	// Now put that through the stuff
	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		C.handle_message(tcm)

	qdel(tcm) // Delete the message datum

