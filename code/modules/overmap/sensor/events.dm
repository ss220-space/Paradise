/datum/controller/subsystem/overmap/proc/relay_sensor_event(obj/overmap/source, message, kind = "info")
	if(!source || !message)
		return
	var/turf/spot = source.get_overmap_turf()
	if(!spot)
		return
	var/tone = sensor_journal_tone(kind)
	var/display_name = source.get_overmap_display_name()
	for(var/obj/overmap/entity/listener as anything in vessels)
		if(QDELETED(listener) || !listener.can_receive_sensor_log())
			continue
		if(listener.sector != source.sector)
			continue
		var/turf/here = listener.get_overmap_turf()
		if(!here || here.z != spot.z)
			continue
		if(max(abs(here.x - spot.x), abs(here.y - spot.y)) > listener.sensor_journal_range())
			continue
		listener.add_sensor_journal(message, kind, spot, display_name, tone)
