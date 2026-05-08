GLOBAL_LIST_EMPTY(all_radios)

/proc/add_radio(obj/item/radio, freq)
	if(!freq || !radio)
		return
	if(!GLOB.all_radios["[freq]"])
		GLOB.all_radios["[freq]"] = list(radio)
		return freq

	GLOB.all_radios["[freq]"] |= radio
	return freq

/proc/remove_radio(obj/item/radio, freq)
	if(!freq || !radio)
		return
	if(!GLOB.all_radios["[freq]"])
		return

	GLOB.all_radios["[freq]"] -= radio

/proc/remove_radio_all(obj/item/radio)
	for(var/freq in GLOB.all_radios)
		GLOB.all_radios["[freq]"] -= radio

/datum/radio_frequency
	/// The frequency of this radio frequency. Of course.
	var/frequency
	/// List of filters -> list of devices
	var/list/list/datum/weakref/devices = list()
	var/custom = FALSE

/// If range > 0, only post to devices on the same z_level and within range
/// Use range = -1, to restrain to the same z_level without limiting range
/datum/radio_frequency/proc/post_signal(obj/source, datum/signal/signal, filter = null, range = null)
	// If checking range, find the source turf
	var/turf/start_point
	if(range)
		start_point = get_turf(source)
		if(!start_point)
			qdel(signal)
			return

	if(filter)
		send_to_filter(source, signal, filter, start_point, range)
		send_to_filter(source, signal, RADIO_DEFAULT, start_point, range)
	else
		// Broadcast the signal to everyone!
		for(var/next_filter in devices)
			send_to_filter(source, signal, next_filter, start_point, range)

/// Sends a signal to all machines belonging to a given filter. Should be called by post_signal()
/datum/radio_frequency/proc/send_to_filter(obj/source, datum/signal/signal, filter, turf/start_point = null, range = null)
	if(range && !start_point)
		return

	for(var/datum/weakref/device_ref as anything in devices[filter])
		var/obj/device = device_ref.resolve()
		if(!device)
			devices[filter] -= device_ref
			continue
		if(device == source)
			continue
		if(range)
			var/turf/end_point = get_turf(device)
			if(!end_point)
				continue
			if(start_point.z != end_point.z || get_dist(start_point, end_point) > range)
				continue

		device.receive_signal(signal, TRANSMISSION_RADIO, frequency)

/// Handles adding a listener to the radio frequency.
/datum/radio_frequency/proc/add_listener(obj/device, filter)
	if(!filter)
		filter = RADIO_DEFAULT

	var/datum/weakref/new_listener = WEAKREF(device)
	if(isnull(new_listener))
		return stack_trace("null, non-datum, or qdeleted device")
	var/list/devices_line = devices[filter]
	if(!devices_line)
		devices[filter] = devices_line = list()
	devices_line += new_listener

/// Handles removing a listener from this radio frequency.
/datum/radio_frequency/proc/remove_listener(obj/device)
	for(var/devices_filter in devices)
		var/list/devices_line = devices[devices_filter]
		if(!devices_line)
			devices -= devices_filter
		devices_line -= WEAKREF(device)
		if(!length(devices_line))
			devices -= devices_filter

/datum/signal
	/// The source of this signal.
	var/obj/source
	/// The frequency on which this signal was emitted.
	var/frequency = 0
	/// The method through which this signal was transmitted.
	/// See all of the `TRANSMISSION_X` in `code/__DEFINES/radio.dm` for
	/// all of the possible options.
	var/transmission_method
	/// The data carried through this signal. Defaults to `null`, otherwise it's
	/// an associative list of (string, any).
	var/list/data
	/// Logging data, used for logging purposes. Makes sense, right?
	var/logging_data

	var/encryption
	var/mob/user // for logging

/datum/signal/New(data, transmission_method = TRANSMISSION_RADIO, logging_data = null)
	src.data = data || list()
	src.transmission_method = transmission_method
	src.logging_data = logging_data

/// Callback used by objects to react to incoming radio signals
/obj/proc/receive_signal(datum/signal/signal, receive_method, receive_param)
	return
