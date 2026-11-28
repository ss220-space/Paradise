/datum/overmap_iff_channel
	var/id
	var/label
	var/permanent = FALSE
	var/receive = FALSE
	var/transmit = FALSE

/datum/overmap_iff_channel/New(channel_id, channel_label, is_permanent = FALSE, do_receive = FALSE, do_transmit = FALSE)
	id = channel_id
	label = channel_label
	permanent = is_permanent
	receive = do_receive
	transmit = do_transmit
