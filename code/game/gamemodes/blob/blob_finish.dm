/datum/game_mode/blob/check_finished()
	if(blob_objective.check_completion())//Blob took over
		return FALSE
	return ..()

/datum/game_mode/proc/start_blob_win()
	if(GLOB.security_level == SEC_LEVEL_DELTA)
		return
	update_blob_objective()
	GLOB.event_announcement.Announce("Объект потерян. Причина: распостранение 5-ой биоугрозы. Взведение устройства самоуничтожения персоналом или внешними силами  в данный момент не представляется возможным из-за высокого уровня заражения. Решение: оставить станцию в изоляции до принятия окончательных мер противодействия.",
										 "Отчет об объекте [station_name()]")
	blob_stage = (delay_blob_end)? BLOB_STAGE_POST_END : BLOB_STAGE_END
	if(blob_stage == BLOB_STAGE_END)
		end_game()


/datum/game_mode/proc/delay_blob_win()
	delay_blob_end = TRUE

/datum/game_mode/proc/return_blob_win()
	delay_blob_end = FALSE

/datum/game_mode/proc/declare_blob_completion()
	if(station_was_nuked && blob_stage != BLOB_STAGE_POST_END)
		if(GAMEMODE_IS_BLOB)
			SSticker.mode_result = "blob halfwin - nuke"
			add_game_logs("Blob mode completed with a tie (station destroyed).")
		to_chat(world, "<BR><FONT size = 3><B>Частичная победа блоба!</B></FONT>")
		to_chat(world, "<B>Станция была уничтожена!</B>")
		to_chat(world, "<B>Директива 7-12 успешно выполнена, предотвращая распространение блоба.</B>")
	else if(blob_objective.check_completion())
		if(GAMEMODE_IS_BLOB)
			SSticker.mode_result = "blob win - blob took over"
			add_game_logs("Blob mode completed with a blob victory.")
		to_chat(world, "<BR><FONT size = 3><B>Полная победа блоба!</B></FONT>")
		to_chat(world, "<B>Блоб захватил станцию!</B>")
		to_chat(world, "<B>Вся станция была поглощена блобом.</B>")
	else if(!GLOB.blob_cores.len)
		if(GAMEMODE_IS_BLOB)
			add_game_logs("Blob mode completed with a crew victory.")
			SSticker.mode_result = "blob loss - blob eliminated"
		to_chat(world, "<BR><FONT size = 3><B>Полная победа персонала станции!</B></FONT>")
		to_chat(world, "<B>Экипаж защитил станцию от блоба!</B>")
		to_chat(world, "<B>Инопланетный организм был истреблен.</B>")
	else
		if(GAMEMODE_IS_BLOB)
			add_game_logs("Blob mode completed with a draw.")
			SSticker.mode_result = "draw - the station was not destroyed, blob is alife "
		to_chat(world, "<BR><FONT size = 3><B>Ничья!</B></FONT>")
		to_chat(world, "<B>Экипаж эвакуирован!</B>")
		to_chat(world, "<B>Инопланетный организм не был истреблен.</B>")
	to_chat(world, "<B>Целью блобов было:</B>")
	if(blob_objective.check_completion() && (!station_was_nuked || blob_stage == BLOB_STAGE_POST_END))
		to_chat(world, "<br/>[blob_objective.explanation_text] <font color='green'><B>Успех!</B></font>")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[blob_objective.type]", "SUCCESS"))
	else
		to_chat(world, "<br/>[blob_objective.explanation_text] <font color='red'>Провал.</font>")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[blob_objective.type]", "FAIL"))
	return TRUE


/datum/game_mode/proc/auto_declare_completion_blob()
	var/list/blob_infected = blobs["infected"]
	var/list/blob_offsprings = blobs["offsprings"]
	var/list/blobernauts = blobs["blobernauts"]
	if(blob_infected?.len)
		declare_blob_completion()
		var/text = "<br/><FONT size = 2><B>Блоб[(blob_infected.len > 1 ? "ами были" : "ом был")]:</B></FONT>"

		for(var/datum/mind/blob in blob_infected)
			text += "<br/><b>[blob.key]</b> был <b>[blob.name]</b>"

		if(blob_offsprings?.len)
			text += "<br/><br/><FONT size = 2><B>Потомк[(blob_offsprings.len > 1 ? "ами блоба были" : "ом блоба был")]:</B></FONT>"
			for(var/datum/mind/blob in blob_offsprings)
				text += "<br/><b>[blob.key]</b> был <b>[blob.name]</b>"

		if(blobernauts?.len)
			text += "<br/><br/><FONT size = 2><B>Блобернаут[(blobernauts.len > 1 ? "ами были" : "ом был")]:</B></FONT>"
			for(var/datum/mind/blob in blobernauts)
				text += "<br/><b>[blob.key]</b> был <b>[blob.name]</b>"

		to_chat(world, text)
	return TRUE


/datum/game_mode/proc/end_game()
	if(!SSticker)
		return
	SSticker.current_state = GAME_STATE_FINISHED
