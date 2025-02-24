/datum/event/blob
	announceWhen	= 180
	endWhen			= 240

/datum/event/blob/announce(false_alarm)
	if(false_alarm)
		GLOB.event_announcement.Announce("Подтверждена вспышка биологической угрозы 5-го уровня на борту [station_name()]. Весь персонал обязан локализовать угрозу.", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/AI/outbreak5.ogg')

/datum/event/blob/start()
	processing = FALSE //so it won't fire again in next tick

	var/turf/T = pick(GLOB.blobstart)
	if(!T)
		return kill()
	var/num_blobs = round((num_station_players() / BLOB_PLAYERS_PER_CORE)) + 1
	if(!SSticker?.mode?.make_blobized_mouses(num_blobs))
		log_and_message_admins("Warning: Could not spawn any mobs for event Blob")
		return kill()
	processing = TRUE // Let it naturally end, if it runs successfully
