ADMIN_VERB(upload_jukebox_music, R_SOUNDS, "Jukebox Upload Music", "Загрузить .ogg файл для воспроизведения через музыкальный автомат.", ADMIN_CATEGORY_SERVER)
	var/file = input(user, "Выберите .ogg файл для загрузки в музыкальный автомат.") as sound|null
	if(!file)
		return

	// we could theorticly support other sound types but OGG is the better format from what I am aware and I am 100% sure its length is properly fetched.
	if(!IS_OGG_FILE(file))
		tgui_alert(user, "Неверный тип файла. Пожалуйста, выберите OGG файл.", "Ошибка загрузки", list("Ок"))
		return

	var/list/track_data = splittext(file, "+")
	if(length(track_data) < 2)
		if(tgui_alert(user, "В названии трека не указан интервал бита в децисекундах, например: SS13+5.ogg. Продолжить?", "Подтверждение", list("Да", "Нет")) != "Да")
			return
	if(length(track_data) > 2)
		tgui_alert(user, "В названии должны быть только заголовок и интервал бита в децисекундах, например: SS13+5.ogg", "Ошибка загрузки", list("Ок"))
		return

	var/clean_name = SANITIZE_FILENAME("[file]")
	var/save_path = "[CONFIG_JUKEBOX_SOUNDS][clean_name]"

	// Copy uploaded file to the server
	fcopy(file, save_path)

	var/msg = "[key_name_admin(user)] uploaded [clean_name] to the jukebox!"
	message_admins(msg)
	log_admin(msg)
	SSblackbox.record_feedback("associative", "jukebox_upload", 1, list("round_id" = "[GLOB.round_id]", "uploader" = "[key_name_admin(user)]", "uploaded" = "[clean_name]"))
	to_chat(user, span_notice("[clean_name] успешно загружен!"))

ADMIN_VERB(browse_jukebox_music, R_SOUNDS, "Jukebox Browse Music", "Просмотр музыкальных файлов для модерации.", ADMIN_CATEGORY_SERVER)
	var/list/files = flist(CONFIG_JUKEBOX_SOUNDS)
	// Filter out things that are not sound files, like the exclude
	for(var/thing in files)
		if(!IS_SOUND_FILE(thing))
			files -= thing
	if(!length(files))
		to_chat(user, span_warning("Загруженных треков не найдено."))
		return

	var/choice = tgui_input_list(user, "Выберите трек:", "Выбор музыки автомата", files)
	if(!choice)
		return

	var/path = "[CONFIG_JUKEBOX_SOUNDS][choice]"

	switch(tgui_alert(user, "Воспроизвести, Удалить или Скачать?", choice, list("Воспроизвести", "Удалить", "Скачать")))
		if("Воспроизвести")
			SEND_SOUND(user, sound(path))
		if("Удалить")
			fdel(path)
			var/msg = "[key_name_admin(user)] deleted [choice] from the jukebox!"
			message_admins(msg)
			log_admin(msg)
			SSblackbox.record_feedback("associative", "jukebox_deletion", 1, list("round_id" = "[GLOB.round_id]", "deletor" = "[key_name_admin(user)]", "deleted" = "[choice]"))
		if("Скачать")
			user << ftp(WRAP_FILE(path))
		else
			return
