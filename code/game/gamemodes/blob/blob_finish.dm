/datum/game_mode/blob/check_finished()
	if(infected_crew.len > burst)//Some blobs have yet to burst
		return 0
	if(blobwincount <= GLOB.blobs.len)//Blob took over
		return 1
	if(!GLOB.blob_cores.len) // blob is dead
		return 1
	return ..()


/datum/game_mode/blob/declare_completion()
	if(blobwincount <= GLOB.blobs.len)
		SSticker.mode_result = "Блоб победил - Блоб одержал верх"
		log_game("Режим Блоб завершен победой Блоба.")

	else if(station_was_nuked)
		SSticker.mode_result = "Блоб почти победил - Ядерный Взрыв"
		log_game("Режим Блоб завершен ньчией. (Станция уничтожена)")

	else if(!GLOB.blob_cores.len)
		SSticker.mode_result = "Блоб проиграл - Блоб уничтожен."
		log_game("Режим Блоб завершился победой экипажа.")
		to_chat(world, "<span class='notice'>Перезагрузка через 30 секунд</span>")
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_blob()
	if(GAMEMODE_IS_BLOB)
		var/datum/game_mode/blob/blob_mode = src
		if(blob_mode.infected_crew.len)
			var/text = "<FONT size = 2><B>Блоб [(blob_mode.infected_crew.len > 1 ? "s were" : " was")]:</B></FONT>"

			for(var/datum/mind/blob in blob_mode.infected_crew)
				text += "<br><b>[blob.key]</b> был <b>[blob.name]</b>"
			to_chat(world, text)
		return 1
