/datum/game_mode
	var/is_blob_completion_declared = FALSE
	var/blob_win_delayed = FALSE
	var/blob_end_sterted = FALSE
	var/blob_win = FALSE

/datum/game_mode/blob/check_finished()
	if(blob_objective.check_completion())//Blob took over
		return FALSE
	return ..()


/datum/game_mode/blob/declare_completion()
	declare_blob_completion()
	..()
	return TRUE


/datum/game_mode/proc/start_blob_win()
	if(GLOB.security_level == SEC_LEVEL_DELTA)
		return
	blob_end_sterted = TRUE
	blob_win = TRUE
	if(!blob_win_delayed)
		GLOB.event_announcement.Announce("Объект потерян. Причина: распостранение 5-ой биоугрозы. Взведение устройства самоуничтожения персоналом или внешними силами не представляется возможным из-за высокого уровня заражения. Решение: оставить станцию в изоляции до принятия окончательных мер противодействия.",
										 "Отчет об объекте [station_name()]")
		end_game()


/datum/game_mode/proc/delay_blob_win()
	blob_win_delayed = TRUE

/datum/game_mode/proc/declare_blob_completion()
	is_blob_completion_declared = TRUE

	if(station_was_nuked && !blob_win_delayed)
		if(GAMEMODE_IS_BLOB)
			SSticker.mode_result = "blob halfwin - nuke"
			add_game_logs("Blob mode completed with a tie (station destroyed).")
		to_chat(world, "<FONT size = 3><B>Частичная победа блоба!</B></FONT>")
		to_chat(world, "<B>Станция была уничтожена!</B>")
		to_chat(world, "<B>Директива 7-12 успешно выполнена, предотвращая распространение блоба.</B>")
	else if(blob_objective.check_completion() || blob_win_delayed && blob_win)
		if(GAMEMODE_IS_BLOB)
			SSticker.mode_result = "blob win - blob took over"
			add_game_logs("Blob mode completed with a blob victory.")
		to_chat(world, "<FONT size = 3><B>Полная победа блоба!</B></FONT>")
		to_chat(world, "<B>Блоб захватил станцию!</B>")
		to_chat(world, "<B>Вся станция была поглощена блобом.</B>")
	else if(!GLOB.blob_cores.len)
		if(GAMEMODE_IS_BLOB)
			add_game_logs("Blob mode completed with a crew victory.")
			SSticker.mode_result = "blob loss - blob eliminated"
		to_chat(world, "<FONT size = 3><B>Полная победа экипажа!</B></FONT>")
		to_chat(world, "<B>Победа персонала станции!</B>")
		to_chat(world, "<B>Инопланетный организм был истреблен.</B>")
	else
		if(GAMEMODE_IS_BLOB)
			add_game_logs("Blob mode completed with a draw.")
			SSticker.mode_result = "draw - the station was not destroyed, blob is alife "
		to_chat(world, "<FONT size = 3><B>Ничья!</B></FONT>")
		to_chat(world, "<B>Экипаж эвакуирован!</B>")
		to_chat(world, "<B>Инопланетный организм не был истреблен.</B>")
	to_chat(world, "<B>Целью блоба было:</B>")
	if(blob_objective.check_completion())
		to_chat(world, "<br>[blob_objective.explanation_text] <font color='green'><B>Success!</B></font>")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[blob_objective.type]", "SUCCESS"))
	else
		to_chat(world, "<br>[blob_objective.explanation_text] <font color='red'>Fail.</font>")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[blob_objective.type]", "FAIL"))
	return TRUE


/datum/game_mode/proc/auto_declare_completion_blob()
	var/datum/game_mode/blob_mode = src
	if(blob_mode.blob_infected.len)
		if(!is_blob_completion_declared)
			declare_blob_completion()
		var/text = "<FONT size = 2><B>Блоб[(blob_mode.blob_infected.len > 1 ? "ами были" : "ом был")]:</B></FONT>"

		for(var/datum/mind/blob in blob_mode.blob_infected)
			text += "<br><b>[blob.key]</b> был <b>[blob.name]</b>"

		if(blob_mode.blob_offsprings.len)
			text += "<br><FONT size = 2><B>Потомк[(blob_mode.blob_offsprings.len > 1 ? "ами блоба были" : "ом блоба был")]:</B></FONT>"
			for(var/datum/mind/blob in blob_mode.blob_offsprings)
				text += "<br><b>[blob.key]</b> был <b>[blob.name]</b>"

		if(blob_mode.blobernauts.len)
			text += "<br><FONT size = 2><B>Блобернаут[(blob_mode.blobernauts.len > 1 ? "ами были" : "ом был")]:</B></FONT>"
			for(var/datum/mind/blob in blob_mode.blobernauts)
				text += "<br><b>[blob.key]</b> был <b>[blob.name]</b>"

		to_chat(world, text)
	return TRUE


/datum/game_mode/proc/end_game()
	if(!SSticker)
		return
	SSticker.current_state = GAME_STATE_FINISHED
