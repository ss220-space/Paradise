#define SOUND_EMITTER_LOCAL "локальный" //Plays the sound like a normal heard sound
#define SOUND_EMITTER_DIRECT "прямой" //Plays the sound directly to hearers regardless of pressure/proximity/et cetera

#define SOUND_EMITTER_RADIUS "радиус" //Plays the sound to everyone in a radius
#define SOUND_EMITTER_ZLEVEL "z-уровень" //Plays the sound to everyone on the z-level
#define SOUND_EMITTER_GLOBAL "глобальный" //Plays the sound to everyone in the game world

//Admin sound emitters with highly customizable functions!
/obj/effect/sound_emitter
	name = "sound emitter"
	desc = "Издаёт звуки, наверное."
	ru_names = list(
		NOMINATIVE = "излучатель звука",
		GENITIVE = "излучателя звука",
		DATIVE = "излучателю звука",
		ACCUSATIVE = "излучатель звука",
		INSTRUMENTAL = "излучателем звука",
		PREPOSITIONAL = "излучателе звука",
	)
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield2"
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	alpha = 175
	var/sound_file //The sound file the emitter plays
	var/sound_volume = 50 //The volume the sound file is played at
	var/play_radius = 3 //Any mobs within this many tiles will hear the sounds played if it's using the appropriate mode
	var/motus_operandi = SOUND_EMITTER_LOCAL //The mode this sound emitter is using
	var/emitter_range = SOUND_EMITTER_ZLEVEL //The range this emitter's sound is heard at; this isn't a number, but a string (see the defines above)
	var/list/hearing_mobs
	var/started = FALSE

/obj/effect/sound_emitter/Destroy(force)
	. = ..()

/obj/effect/sound_emitter/singularity_act()
	return

/obj/effect/sound_emitter/ex_act()
	return

/obj/effect/sound_emitter/examine(mob/user)
	..()
	if(!isobserver(user))
		return
	to_chat(user, span_notice("<b>Звуковой файл:</b> [sound_file ? sound_file : "Не выбран"]"))
	to_chat(user, span_notice("<b>Режим:</b> [motus_operandi]"))
	to_chat(user, span_notice("<b>Дальность:</b> [emitter_range]"))
	to_chat(user, span_notice("<b>Громкость проигрываемого звука [sound_volume]%.</b>"))
	if(user.client.holder)
		to_chat(user, "<b>Alt+ЛКМ для быстрой активации!</b>")

/obj/effect/sound_emitter/attack_ghost(mob/user)
	if(!check_rights_for(user.client, R_SOUNDS))
		examine(user)
		return
	edit_emitter(user)

/obj/effect/sound_emitter/click_alt(mob/user)
	if(check_rights_for(user.client, R_SOUNDS))
		activate(user)
		to_chat(user, span_notice("Звуковой излучатель активирован."))
		return CLICK_ACTION_SUCCESS

/obj/effect/sound_emitter/proc/edit_emitter(mob/user)
	var/dat = ""
	dat += "<b>Маркировка:</b> <a href='byond://?src=[UID()];edit_label=1'>[maptext ? maptext : "Маркировка не установлена!"]</a><br>"

	dat += "<br>"
	dat += "<b>Звуковой файл:</b> <a href='byond://?src=[UID()];edit_sound_file=1'>[sound_file ? sound_file : "Не выбран!"]</a><br>"
	dat += "<b>Громкость:</b> <a href='byond://?src=[UID()];edit_volume=1'>[sound_volume]%</a><br>"
	dat += "<br>"
	dat += "<b>Режим:</b> <a href='byond://?src=[UID()];edit_mode=1'>[motus_operandi]</a><br>"
	if(motus_operandi != SOUND_EMITTER_LOCAL)
		dat += "<b>Дальность:</b> <a href='byond://?src=[UID()];edit_range=1'>[emitter_range]</a>[emitter_range == SOUND_EMITTER_RADIUS ? "<a href='byond://?src=[UID()];edit_radius=1'>[play_radius]-тайловый радиус</a>" : ""]<br>"
	dat += "<br>"
	if(!started)
		dat += "<a href='byond://?src=[UID()];play=1'>Проиграть звук</a> (прерывает звуки других звуковых излучателей)"
	else
		dat += "<a href='byond://?src=[UID()];reload=1'>Перезапустить звук</a>"
		dat += "<a href='byond://?src=[UID()];stop=1'>Остановить звук</a>"
	var/datum/browser/popup = new(user, "emitter", "", 500, 600)
	popup.set_content(dat)
	popup.open()

/obj/effect/sound_emitter/Topic(href, href_list)
	..()
	if(!ismob(usr) || !usr.client || !check_rights_for(usr.client, R_SOUNDS))
		return
	var/mob/user = usr

	if(href_list["stop"])
		deactivate(user)
		if(user)
			log_and_message_admins("deactivated a sound emitter at [COORD(src)]")

	if(href_list["reload"])
		reload(user)
		if(user)
			log_and_message_admins("reloaded a sound emitter with file \"[sound_file]\" at [COORD(src)]")

	if(started)
		to_chat(usr, span_notice("Пока проигрывание звука не остановлено, редактировать излучатель нельзя."))
		edit_emitter(user) //Refresh the UI to see our changes
		return

	if(href_list["play"])
		activate(user)
		if(user)
			log_and_message_admins("activated a sound emitter with file \"[sound_file]\" at [COORD(src)]")

	if(href_list["edit_label"])
		var/new_label = tgui_input_text(user, "Введите маркировку", "Звуковой излучатель", max_length = MAX_NAME_LEN)
		if(!new_label)
			return
		maptext = MAPTEXT(new_label)
		to_chat(user, span_notice("Новая маркировка - [maptext]."))

	if(href_list["edit_sound_file"])
		var/new_file = input(user, "Выберите звуковой файл", "Звуковой излучатель") as null|sound
		if(!new_file)
			return
		sound_file = new_file
		to_chat(user, span_notice("Новый звуковой файл [sound_file]."))

	if(href_list["edit_volume"])
		var/new_volume = tgui_input_number(user, "Введите громкость", "Звуковой излучатель", sound_volume, 100)
		if(isnull(new_volume))
			return
		sound_volume = new_volume
		to_chat(user, span_notice("Громкость установлена на [sound_volume]%."))

	if(href_list["edit_mode"])
		var/new_mode
		var/mode_list = list("Локальный (нормальный звук)" = SOUND_EMITTER_LOCAL, "Прямой (не зависит от окружающей среды/местоположения)" = SOUND_EMITTER_DIRECT)
		new_mode =  tgui_input_list(user, "Выберите режим", "Звуковой излучатель", mode_list)
		if(!new_mode)
			return
		motus_operandi = mode_list[new_mode]
		to_chat(user, span_notice("Выбраный режим - [motus_operandi]."))

	if(href_list["edit_range"])
		var/new_range
		var/range_list = list("Радиус (Все существа в радиусе)" = SOUND_EMITTER_RADIUS, "Z-Уровень (все существа на z-уровне)" = SOUND_EMITTER_ZLEVEL, "Глобальный (все игроки)" = SOUND_EMITTER_GLOBAL)
		new_range = tgui_input_list(user, "Выберите дальность", "Звуковой излучатель", range_list)
		if(!new_range)
			return
		emitter_range = range_list[new_range]
		to_chat(user, span_notice("Выбранная дальность - [emitter_range]."))

	if(href_list["edit_radius"])
		var/new_radius = tgui_input_number(user, "Введите радиус", "Звуковой излучатель", sound_volume, 127)
		if(isnull(new_radius))
			return
		play_radius = new_radius
		to_chat(user, span_notice("Радиус звука установлен на [play_radius]."))
	edit_emitter(user) //Refresh the UI to see our changes

/obj/effect/sound_emitter/proc/reload(mob/user)
	deactivate(user)
	activate(user)

/obj/effect/sound_emitter/proc/deactivate(mob/user)
	if(motus_operandi == SOUND_EMITTER_LOCAL)
		playsound(src, null, sound_volume, FALSE, channel = CHANNEL_ADMIN)
		started = FALSE
		hearing_mobs = null
		flick("shield1", src)
		return

	for(var/mob/M in hearing_mobs)
		if(M.client.prefs.toggles & SOUND_MIDI)
			M.playsound_local(M, null, sound_volume, FALSE, channel = CHANNEL_ADMIN, pressure_affected = FALSE)
	started = FALSE
	hearing_mobs = null
	flick("shield1", src)

/obj/effect/sound_emitter/proc/activate(mob/user)
	hearing_mobs = list()
	if(motus_operandi == SOUND_EMITTER_LOCAL)
		playsound(src, sound_file, sound_volume, FALSE, channel = CHANNEL_ADMIN)
		started = TRUE
		flick("shield1", src)
		return

	switch(emitter_range)
		if(SOUND_EMITTER_RADIUS)
			for(var/mob/M in GLOB.player_list)
				if(get_dist(src, M) <= play_radius)
					hearing_mobs += M
		if(SOUND_EMITTER_ZLEVEL)
			for(var/mob/M in GLOB.player_list)
				if(M.z == z)
					hearing_mobs += M
		if(SOUND_EMITTER_GLOBAL)
			hearing_mobs = GLOB.player_list.Copy()

	for(var/mob/M in hearing_mobs)
		if(M.client.prefs.toggles & SOUND_MIDI)
			M.playsound_local(M, sound_file, sound_volume, FALSE, channel = CHANNEL_ADMIN, pressure_affected = FALSE)
	started = TRUE
	flick("shield1", src)

#undef SOUND_EMITTER_LOCAL
#undef SOUND_EMITTER_DIRECT
#undef SOUND_EMITTER_RADIUS
#undef SOUND_EMITTER_ZLEVEL
#undef SOUND_EMITTER_GLOBAL
