#define HEADPHONE_CASE_RANGE 9
#define HEADPHONE_TRACK_MAX_LENGTH (10 MINUTES)
#define HEADPHONE_FETCH_COOLDOWN (30 SECONDS)
#define HEADPHONE_GLOBAL_FETCH_COOLDOWN (10 SECONDS)
#define HEADPHONE_URL_MAX_LENGTH 300

GLOBAL_LIST_EMPTY(headphone_case_tracks)
GLOBAL_VAR_INIT(headphone_case_fetch_cooldown, 0)

/obj/item/headphone_case
	name = "wireless earbuds case"
	desc = "Кейс беспроводных наушников Nanotrasen. Держит связь с наушниками в радиусе десяти метров."
	icon = 'icons/obj/audio_devices.dmi'
	icon_state = "case_white"
	base_icon_state = "case_white"
	item_state = "case"
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/clothing/ears/earbud/left_bud
	var/obj/item/clothing/ears/earbud/right_bud
	var/left_bud_type = /obj/item/clothing/ears/earbud/left
	var/right_bud_type = /obj/item/clothing/ears/earbud/right
	var/datum/jukebox/headphones/player
	var/powered = FALSE
	var/song_timerid
	COOLDOWN_DECLARE(fetch_cooldown)

/obj/item/headphone_case/get_ru_names()
	return alist(
		NOMINATIVE = "кейс беспроводных наушников",
		GENITIVE = "кейса беспроводных наушников",
		DATIVE = "кейсу беспроводных наушников",
		ACCUSATIVE = "кейс беспроводных наушников",
		INSTRUMENTAL = "кейсом беспроводных наушников",
		PREPOSITIONAL = "кейсе беспроводных наушников",
	)

/obj/item/headphone_case/Initialize(mapload)
	. = ..()
	player = new(src)
	player.set_sound_range(HEADPHONE_CASE_RANGE)
	left_bud = new left_bud_type(src, src)
	right_bud = new right_bud_type(src, src)
	update_icon()

/obj/item/headphone_case/Destroy()
	deltimer(song_timerid)
	QDEL_NULL(left_bud)
	QDEL_NULL(right_bud)
	QDEL_NULL(player)
	return ..()

/obj/item/headphone_case/update_icon_state()
	var/lid_closed = (left_bud?.loc == src) && (right_bud?.loc == src)
	icon_state = "[base_icon_state][lid_closed ? "" : "_open"][powered ? "_on" : ""]"

/obj/item/headphone_case/update_overlays()
	. = ..()
	if((left_bud?.loc == src) && (right_bud?.loc == src))
		return
	if(left_bud?.loc == src)
		. += "[base_icon_state]_left_bud"
	if(right_bud?.loc == src)
		. += "[base_icon_state]_right_bud"

/obj/item/headphone_case/examine(mob/user)
	. = ..()
	. += "Индикатор [powered ? "горит зелёным" : "погашен"]."
	if(player.selection)
		. += "На дисплее: [html_encode(player.selection.song_name)]"

/obj/item/headphone_case/attack_self(mob/user)
	ui_interact(user)

/obj/item/headphone_case/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(used != left_bud && used != right_bud)
		return ..()
	if(!user.drop_from_active_hand())
		return ITEM_INTERACT_SUCCESS
	used.forceMove(src)
	update_icon()
	balloon_alert(user, "наушник в кейсе")
	return ITEM_INTERACT_SUCCESS

/obj/item/headphone_case/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/headphone_case/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HeadphoneCase", name)
		ui.open()

/obj/item/headphone_case/ui_data(mob/user)
	var/list/data = list()
	player.get_ui_data(data)
	data["icon"] = icon
	data["icon_state"] = icon_state
	data["powered"] = powered
	data["playing"] = !isnull(song_timerid)
	var/left_inside = left_bud?.loc == src
	var/right_inside = right_bud?.loc == src
	var/lid_closed = left_inside && right_inside
	data["left_inside"] = left_inside
	data["right_inside"] = right_inside
	data["left_bud_overlay"] = (left_inside && !lid_closed) ? "[base_icon_state]_left_bud" : null
	data["right_bud_overlay"] = (right_inside && !lid_closed) ? "[base_icon_state]_right_bud" : null
	data["left_missing"] = QDELETED(left_bud)
	data["right_missing"] = QDELETED(right_bud)
	data["track_length"] = player.selection?.song_length
	data["cooldown"] = round(COOLDOWN_TIMELEFT(src, fetch_cooldown) / (1 SECONDS))
	data["sources"] = replacetext(replacetext(CONFIG_GET(string/request_internet_allowed), "\\", ""), ",", ", ")
	data["network_available"] = CONFIG_GET(flag/headphone_case_music) && !!CONFIG_GET(string/invoke_youtubedl)
	return data

/obj/item/headphone_case/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("power")
			toggle_power()
			return TRUE

		if("eject")
			dispense_bud(user, params["side"] == "left" ? left_bud : right_bud)
			return TRUE

		if("play")
			load_track(user, params["url"])
			return TRUE

		if("replay")
			if(powered && player.selection)
				play_track(player.selection)
			return TRUE

		if("stop")
			stop_music()
			return TRUE

		if("volume")
			player.set_new_volume(text2num(params["volume"]))
			return TRUE

/obj/item/headphone_case/proc/toggle_power()
	powered = !powered
	if(!powered)
		stop_music()
	playsound(src, powered ? 'sound/machines/terminal_on.ogg' : 'sound/machines/terminal_off.ogg', 20, TRUE)
	update_icon(UPDATE_ICON_STATE)

/obj/item/headphone_case/proc/dispense_bud(mob/user, obj/item/clothing/ears/earbud/bud)
	if(QDELETED(bud) || bud.loc != src)
		return
	user.put_in_hands(bud)
	update_icon()

/obj/item/headphone_case/proc/get_wearers()
	var/list/wearers = list()
	var/mob/left_wearer = left_bud?.get_wearer()
	var/mob/right_wearer = right_bud?.get_wearer()
	if(left_wearer)
		wearers |= left_wearer
	if(right_wearer)
		wearers |= right_wearer
	return wearers

/obj/item/headphone_case/proc/bud_worn(mob/wearer)
	if(!powered || isnull(song_timerid) || player.has_listener(wearer))
		return
	player.add_listener(wearer)

/obj/item/headphone_case/proc/bud_removed(mob/wearer)
	if(left_bud?.get_wearer() == wearer || right_bud?.get_wearer() == wearer)
		return
	player.drop_listener(wearer)

/obj/item/headphone_case/proc/load_track(mob/user, url)
	if(!powered)
		to_chat(user, span_warning("Кейс выключен."))
		return
	if(!CONFIG_GET(flag/headphone_case_music) || !CONFIG_GET(string/invoke_youtubedl))
		to_chat(user, span_warning("Медиасеть станции недоступна."))
		return
	if(!COOLDOWN_FINISHED(src, fetch_cooldown) || !CLIENT_COOLDOWN_FINISHED(GLOB, headphone_case_fetch_cooldown))
		to_chat(user, span_warning("Кейс ещё обрабатывает предыдущий запрос."))
		return
	if(check_mute(user.get_account_ckey(), MUTE_INTERNET_REQUEST))
		to_chat(user, span_warning("Вам запрещено включать музыку."))
		return

	if(!istext(url))
		return
	url = trim(url)
	if(!findtext(url, GLOB.is_http_protocol) || length(url) > HEADPHONE_URL_MAX_LENGTH)
		to_chat(user, span_warning("Кейс принимает только http(s) ссылки."))
		return

	var/allowed_sites = CONFIG_GET(string/request_internet_allowed)
	var/regex/allowed_regex = regex(replacetext(allowed_sites, ",", "|"), "i")
	if(!allowed_regex.Find(url))
		to_chat(user, span_warning("Кейс не знает такого источника."))
		return

	COOLDOWN_START(src, fetch_cooldown, HEADPHONE_FETCH_COOLDOWN)
	CLIENT_COOLDOWN_START(GLOB, headphone_case_fetch_cooldown, HEADPHONE_GLOBAL_FETCH_COOLDOWN)

	var/youtubedl = CONFIG_GET(string/invoke_youtubedl)
	var/datum/web_sound_info/sound_info = get_web_sound_info(youtubedl, url)
	if(QDELETED(src) || QDELETED(user) || !powered)
		return
	if(!sound_info.success)
		to_chat(user, span_warning("Кейс не смог достучаться до трека."))
		log_game("[key_name(user)] failed to fetch [url] through [type]: [sound_info.error_message]")
		return

	var/track_length = sound_info.duration * 1 SECONDS
	if(!track_length)
		to_chat(user, span_warning("Кейс не берёт прямые трансляции."))
		return
	if(track_length > HEADPHONE_TRACK_MAX_LENGTH)
		to_chat(user, span_warning("Трек длиннее [DisplayTimeText(HEADPHONE_TRACK_MAX_LENGTH)], в память кейса он не влезет."))
		return

	var/datum/track/track = GLOB.headphone_case_tracks[sound_info.id]
	if(!track)
		var/datum/web_sound_download/download = download_web_sound(youtubedl, url, sound_info.id)
		if(QDELETED(src) || QDELETED(user) || !powered)
			return
		if(!download.success || !fexists(download.file_path))
			to_chat(user, span_warning("Кейс не смог скачать трек."))
			log_game("[key_name(user)] failed to download [url] through [type]: [download.error_message]")
			return
		var/song_file = file(download.file_path)
		if(!IS_SOUND_FILE_SAFE(song_file))
			to_chat(user, span_warning("Кейс не понимает этот формат."))
			return
		track = new(sound_info.title, song_file, SSsounds.get_sound_length(song_file) || track_length)
		GLOB.headphone_case_tracks[sound_info.id] = track

	play_track(track)

	var/display_url = html_encode(url)
	add_game_logs("started web sound [url] in [type] ([UID()])", user)
	message_admins("[key_name_admin(user)] played web sound in a headphone case: [span_linkify(display_url)] [ADMIN_STOP_HEADPHONES(src)] [ADMIN_LOOKUPFLW(user)]")
	SSblackbox.record_feedback("nested tally", "headphone_case_url", 1, list("[user.ckey]", "[url]"))

/obj/item/headphone_case/proc/play_track(datum/track/track)
	stop_music()
	player.selection = track
	player.start_music(get_wearers())
	song_timerid = addtimer(CALLBACK(src, PROC_REF(stop_music)), track.song_length, TIMER_STOPPABLE|TIMER_DELETE_ME)

/obj/item/headphone_case/proc/stop_music()
	if(!isnull(song_timerid))
		deltimer(song_timerid)
		song_timerid = null
	player.unlisten_all()
	player.start_time = 0
	player.end_time = 0

/obj/item/headphone_case/black
	icon_state = "case_black"
	base_icon_state = "case_black"
	left_bud_type = /obj/item/clothing/ears/earbud/left/black
	right_bud_type = /obj/item/clothing/ears/earbud/right/black

/obj/item/clothing/ears/earbud
	name = "wireless earbud"
	desc = "Беспроводной наушник Nanotrasen. Работает только рядом со своим кейсом."
	icon = 'icons/obj/audio_devices.dmi'
	abstract_type = /obj/item/clothing/ears/earbud
	sprite_sheets = null
	onmob_sheets = list(
		ITEM_SLOT_EAR_LEFT_STRING = 'icons/mob/clothing/audio_devices.dmi',
		ITEM_SLOT_EAR_RIGHT_STRING = 'icons/mob/clothing/audio_devices.dmi',
	)
	var/obj/item/headphone_case/case

/obj/item/clothing/ears/earbud/get_ru_names()
	return alist(
		NOMINATIVE = "беспроводной наушник",
		GENITIVE = "беспроводного наушника",
		DATIVE = "беспроводному наушнику",
		ACCUSATIVE = "беспроводной наушник",
		INSTRUMENTAL = "беспроводным наушником",
		PREPOSITIONAL = "беспроводном наушнике",
	)

/obj/item/clothing/ears/earbud/Initialize(mapload, obj/item/headphone_case/case)
	. = ..()
	src.case = case

/obj/item/clothing/ears/earbud/Destroy()
	if(case)
		if(case.left_bud == src)
			case.left_bud = null
		if(case.right_bud == src)
			case.right_bud = null
		case = null
	return ..()

/obj/item/clothing/ears/earbud/examine(mob/user)
	. = ..()
	if(isnull(case))
		. += span_warning("Наушник не привязан ни к одному кейсу.")

/obj/item/clothing/ears/earbud/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot & ITEM_SLOT_EARS)
		case?.bud_worn(user)

/obj/item/clothing/ears/earbud/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	case?.bud_removed(user)

/obj/item/clothing/ears/earbud/proc/get_wearer()
	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer))
		return null
	return (wearer.l_ear == src || wearer.r_ear == src) ? wearer : null

/obj/item/clothing/ears/earbud/left
	icon_state = "earbud_white_l"
	item_state = "earbud_white_l"

/obj/item/clothing/ears/earbud/left/black
	icon_state = "earbud_black_l"
	item_state = "earbud_black_l"

/obj/item/clothing/ears/earbud/right
	icon_state = "earbud_white_r"
	item_state = "earbud_white_r"

/obj/item/clothing/ears/earbud/right/black
	icon_state = "earbud_black_r"
	item_state = "earbud_black_r"

/datum/jukebox/headphones
	requires_range_check = FALSE
	positional = FALSE
	mute_preference = NONE
	volume = 40

/datum/jukebox/headphones/New(atom/new_parent)
	sound_channel = SSsounds.reserve_sound_channel_for_datum(src)
	return ..()

/datum/jukebox/headphones/init_songs()
	return list()

/datum/jukebox/headphones/start_music(list/wearers)
	start_time = world.time
	end_time = start_time + selection.song_length
	build_song_sound()
	for(var/mob/wearer as anything in wearers)
		register_listener(wearer)

/datum/jukebox/headphones/register_listener(mob/new_listener)
	if(active_song_sound)
		active_song_sound.offset = (world.time - start_time) / (1 SECONDS)
	. = ..()
	if(active_song_sound)
		active_song_sound.offset = null

/datum/jukebox/headphones/proc/add_listener(mob/listener)
	register_listener(listener)

/datum/jukebox/headphones/proc/drop_listener(mob/listener)
	deregister_listener(listener)

#undef HEADPHONE_CASE_RANGE
#undef HEADPHONE_TRACK_MAX_LENGTH
#undef HEADPHONE_FETCH_COOLDOWN
#undef HEADPHONE_GLOBAL_FETCH_COOLDOWN
#undef HEADPHONE_URL_MAX_LENGTH
