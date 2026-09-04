/datum/overmap_sector_message
	var/id
	var/plaintext = ""
	var/scrambled = ""
	var/encryption_key
	var/sender_name = "Неизвестный"
	var/sector_id
	var/sent_at = 0

/datum/overmap_sector_message/New(body, key, origin_name, from_sector_id)
	id = "omsg_[UID()]"
	plaintext = body
	encryption_key = key
	sender_name = origin_name
	sector_id = from_sector_id
	sent_at = world.time
	if(encryption_key)
		scrambled = overmap_comms_scramble(plaintext)
	else
		scrambled = plaintext

/datum/overmap_comms_cipher
	var/key = ""
	var/label = ""
	var/autodecrypt = FALSE
	var/announce = FALSE

/datum/overmap_comms_cipher/New(cipher_key, cipher_label)
	key = cipher_key
	label = cipher_label || "Канал"

/proc/overmap_comms_scramble(text)
	. = ""
	var/static/list/alphabet = list(
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
		"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
	)
	for(var/i in 1 to length_char(text))
		var/char = copytext_char(text, i, i + 1)
		if(char == " " || char == "\n" || char == "\t")
			. += char
			continue
		. += pick(alphabet)

/proc/overmap_comms_random_key(len = OVERMAP_COMMS_KEY_LEN)
	var/static/list/chars = list(
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
		"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
	)
	. = ""
	for(var/i in 1 to len)
		. += pick(chars)

/proc/overmap_comms_mask_key(key)
	var/len = length_char(key)
	if(len <= 1)
		return key
	if(len == 2)
		return "[copytext_char(key, 1, 2)]*"
	var/stars = ""
	for(var/i in 1 to len - 2)
		stars += "*"
	return "[copytext_char(key, 1, 2)][stars][copytext_char(key, len, len + 1)]"

/obj/machinery/overmap_intercom
	name = "sector comms panel"
	desc = "Настенная панель секторной связи. Рассылает сообщения всем панелям в текущем секторе. Имеет встроенный шифратор."
	icon = 'icons/obj/machines/overmap.dmi'
	icon_state = "sector_intercom"
	anchored = TRUE
	density = FALSE
	idle_power_usage = 20
	active_power_usage = 40
	use_power = IDLE_POWER_USE
	power_channel = EQUIP
	layer = ABOVE_WINDOW_LAYER
	var/obj/overmap/entity/vessel
	var/next_transmit = 0

	var/list/unlocked_message_ids

	var/list/datum/overmap_comms_cipher/known_ciphers
	var/beep_muted = FALSE

	var/saved_send_key = ""

/obj/machinery/overmap_intercom/get_ru_names()
	return alist(
		NOMINATIVE = "панель секторной связи",
		GENITIVE = "панели секторной связи",
		DATIVE = "панели секторной связи",
		ACCUSATIVE = "панель секторной связи",
		INSTRUMENTAL = "панелью секторной связи",
		PREPOSITIONAL = "панели секторной связи",
	)

/obj/machinery/overmap_intercom/Initialize(mapload)
	. = ..()
	unlocked_message_ids = list()
	known_ciphers = list()
	GLOB.overmap_intercoms += src
	snap_to_wall()
	if(SSovermap?.initialized)
		link_vessel()

/obj/machinery/overmap_intercom/setDir(newdir)
	. = ..()
	snap_to_wall()

/obj/machinery/overmap_intercom/shuttleRotate(rotation, params)
	return

/obj/machinery/overmap_intercom/onShuttleMove(turf/oldT, turf/T1, rotation, mob/requester)
	if(light && light_system == COMPLEX_LIGHT)
		update_light()
	var/old_dir = dir
	forceMove(T1)
	if(rotation)
		setDir(angle2dir(rotation + dir2angle(old_dir)))
	else
		snap_to_wall()
	return TRUE

/obj/machinery/overmap_intercom/proc/snap_to_wall()
	pixel_x = 0
	pixel_y = 0
	switch(dir)
		if(NORTH)
			pixel_y = 26
		if(SOUTH)
			pixel_y = -26
		if(EAST)
			pixel_x = 26
		if(WEST)
			pixel_x = -26

/obj/machinery/overmap_intercom/Destroy()
	GLOB.overmap_intercoms -= src
	vessel = null
	unlocked_message_ids = null
	QDEL_LIST(known_ciphers)
	return ..()

/obj/machinery/overmap_intercom/proc/link_vessel()
	var/obj/overmap/entity/resolved = SSovermap?.resolve_vessel(src)
	if(resolved == vessel)
		return
	vessel = resolved

/obj/machinery/overmap_intercom/proc/get_comms_sector()
	if(!vessel)
		link_vessel()
	return vessel?.sector

/obj/machinery/overmap_intercom/proc/find_cipher(key)
	for(var/datum/overmap_comms_cipher/cipher as anything in known_ciphers)
		if(cipher.key == key)
			return cipher
	return null

/obj/machinery/overmap_intercom/proc/on_sector_message(datum/overmap_sector_message/message)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!beep_muted)
		playsound(src, 'sound/machines/twobeep.ogg', 40, FALSE)
	if(message.encryption_key)
		var/datum/overmap_comms_cipher/cipher = find_cipher(message.encryption_key)
		if(cipher)
			if(cipher.autodecrypt)
				unlocked_message_ids[message.id] = TRUE
			if(cipher.announce)
				atom_say("Получено новое сообщение с зашифрованного канала.")
	else
		atom_say("Входящее сообщение от [message.sender_name].")
	refresh_comms_ui()

/obj/machinery/overmap_intercom/proc/refresh_comms_ui()
	SStgui.update_uis(src)

/obj/machinery/overmap_intercom/proc/sanitize_comms_key(raw)
	raw = trim(raw)
	if(!raw)
		return null
	return copytext_char(raw, 1, OVERMAP_COMMS_MAX_KEY + 1)

/obj/machinery/overmap_intercom/proc/message_unlocked(datum/overmap_sector_message/message)
	if(!message?.encryption_key)
		return TRUE
	return unlocked_message_ids[message.id]

/obj/machinery/overmap_intercom/proc/channel_label_for_message(datum/overmap_sector_message/message)
	if(!message?.encryption_key)
		return "Глобально"
	var/datum/overmap_comms_cipher/cipher = find_cipher(message.encryption_key)
	if(cipher)
		return cipher.label
	return "Неизвестный канал"

/obj/machinery/overmap_intercom/proc/ui_message_entry(datum/overmap_sector_message/message)
	var/unlocked = message_unlocked(message)
	return list(
		"id" = message.id,
		"sender" = message.sender_name,
		"time" = DisplayTimeText(max(0, world.time - message.sent_at), 1),
		"encrypted" = !!message.encryption_key,
		"unlocked" = unlocked,
		"channel" = channel_label_for_message(message),
		"text" = unlocked ? message.plaintext : message.scrambled,
	)

/obj/machinery/overmap_intercom/proc/ui_cipher_entry(datum/overmap_comms_cipher/cipher)
	return list(
		"key" = cipher.key,
		"label" = cipher.label,
		"mask" = overmap_comms_mask_key(cipher.key),
		"autodecrypt" = cipher.autodecrypt,
		"announce" = cipher.announce,
	)

/obj/machinery/overmap_intercom/attack_hand(mob/user)
	if(stat & BROKEN)
		return
	if(..())
		return TRUE
	if(stat & NOPOWER)
		to_chat(user, span_warning("Нет питания."))
		return TRUE
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/overmap_intercom/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/overmap_intercom/ui_interact(mob/user, datum/tgui/ui = null)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!vessel)
		link_vessel()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapIntercom", name)
		ui.open()

/obj/machinery/overmap_intercom/ui_data(mob/user)
	var/list/data = list()
	if(!vessel)
		link_vessel()
	var/datum/overmap_sector/sector = get_comms_sector()
	data["linked"] = !!vessel
	data["sector_name"] = sector?.name
	data["vessel_name"] = vessel?.get_overmap_display_name()
	data["cooldown"] = max(0, round((next_transmit - world.time) / 10))
	data["can_send"] = !!sector && !(stat & (NOPOWER|BROKEN)) && world.time >= next_transmit && !vessel?.is_overmap_jammed()
	data["jammed"] = !!vessel?.is_overmap_jammed()
	data["max_body"] = OVERMAP_COMMS_MAX_BODY
	data["key_len"] = OVERMAP_COMMS_KEY_LEN
	data["beep_muted"] = beep_muted
	data["send_key"] = saved_send_key
	var/list/messages = list()
	if(sector)
		for(var/i = length(sector.comms_messages); i >= 1; i--)
			var/datum/overmap_sector_message/message = sector.comms_messages[i]
			messages += list(ui_message_entry(message))
	data["messages"] = messages
	var/list/ciphers = list()
	for(var/datum/overmap_comms_cipher/cipher as anything in known_ciphers)
		ciphers += list(ui_cipher_entry(cipher))
	data["ciphers"] = ciphers
	return data

/obj/machinery/overmap_intercom/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return TRUE
	switch(action)
		if("relink")
			link_vessel()
			. = TRUE
		if("toggle_beep")
			beep_muted = !beep_muted
			. = TRUE
		if("set_send_key")
			saved_send_key = sanitize_comms_key(params["key"]) || ""
			. = TRUE
		if("use_cipher")
			var/datum/overmap_comms_cipher/cipher = find_cipher(params["key"])
			if(!cipher)
				return TRUE
			saved_send_key = cipher.key
			. = TRUE
		if("add_cipher")
			var/key = sanitize_comms_key(params["key"])
			var/label = copytext_char(trim(strip_html(params["label"])), 1, 32)
			if(!key)
				to_chat(usr, span_warning("Пустой ключ."))
				return TRUE
			if(!label)
				to_chat(usr, span_warning("Укажите название канала."))
				return TRUE
			if(find_cipher(key))
				to_chat(usr, span_notice("Этот ключ уже в списке прослушивания."))
				return TRUE
			known_ciphers += new /datum/overmap_comms_cipher(key, label)
			. = TRUE
		if("remove_cipher")
			var/datum/overmap_comms_cipher/cipher = find_cipher(params["key"])
			if(!cipher)
				return TRUE
			known_ciphers -= cipher
			qdel(cipher)
			. = TRUE
		if("toggle_cipher")
			var/datum/overmap_comms_cipher/cipher = find_cipher(params["key"])
			if(!cipher)
				return TRUE
			if(params["flag"] == "autodecrypt")
				cipher.autodecrypt = !cipher.autodecrypt
			else if(params["flag"] == "announce")
				cipher.announce = !cipher.announce
			. = TRUE
		if("send")
			if(!vessel)
				link_vessel()
			var/datum/overmap_sector/sector = get_comms_sector()
			if(!sector)
				to_chat(usr, span_warning("Нет связи с сектором."))
				return TRUE
			if(vessel.is_overmap_jammed())
				to_chat(usr, span_warning("Помехи гипертранслятора. Передача невозможна."))
				return TRUE
			if(world.time < next_transmit)
				to_chat(usr, span_warning("Передатчик ещё остывает."))
				return TRUE
			var/body = trim(strip_html_properly(params["text"], OVERMAP_COMMS_MAX_BODY, TRUE))
			if(!body)
				to_chat(usr, span_warning("Пустое сообщение."))
				return TRUE
			var/key = sanitize_comms_key(params["key"])
			saved_send_key = key || ""
			var/datum/overmap_sector_message/message = new(body, key, vessel.get_overmap_display_name(), sector.id)
			if(key)
				unlocked_message_ids[message.id] = TRUE
			sector.add_comms_message(message)
			next_transmit = world.time + OVERMAP_COMMS_COOLDOWN
			use_power = ACTIVE_POWER_USE
			addtimer(VARSET_CALLBACK(src, use_power, IDLE_POWER_USE), 2 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(refresh_comms_ui)), OVERMAP_COMMS_COOLDOWN)
			atom_say("Сообщение отправлено[key ? " (шифр)" : ""].")
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 40, FALSE)
			. = TRUE
		if("decrypt")
			var/datum/overmap_sector/sector = get_comms_sector()
			if(!sector)
				return TRUE
			var/msg_id = params["id"]
			var/key = sanitize_comms_key(params["key"])
			if(!msg_id || !key)
				to_chat(usr, span_warning("Нужен ключ шифрования."))
				return TRUE
			var/datum/overmap_sector_message/message
			for(var/datum/overmap_sector_message/entry as anything in sector.comms_messages)
				if(entry.id == msg_id)
					message = entry
					break
			if(!message)
				to_chat(usr, span_warning("Сообщение не найдено."))
				return TRUE
			if(!message.encryption_key)
				to_chat(usr, span_notice("Сообщение не зашифровано."))
				return TRUE
			if(unlocked_message_ids[message.id])
				to_chat(usr, span_notice("Это сообщение уже расшифровано на этой панели."))
				return TRUE
			if(key != message.encryption_key)
				to_chat(usr, span_warning("Ключ не подходит."))
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 40, FALSE)
				return TRUE
			unlocked_message_ids[message.id] = TRUE
			if(!find_cipher(key))
				known_ciphers += new /datum/overmap_comms_cipher(key, "Канал")
			to_chat(usr, span_notice("Сообщение расшифровано на этой панели."))
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 40, FALSE)
			. = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/overmap_intercom, 26, 26)
