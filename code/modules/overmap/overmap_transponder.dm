GLOBAL_LIST_INIT(overmap_transponder_colors, list(
	"Белый" = COLOR_WHITE,
	"Красный" = COLOR_RED,
	"Жёлтый" = COLOR_YELLOW,
	"Зелёный" = COLOR_GREEN,
	"Голубой" = COLOR_CYAN,
	"Синий" = COLOR_BLUE,
	"Фиолетовый" = COLOR_PURPLE,
	"Оранжевый" = COLOR_ENGINEERING_ORANGE,
	"Серый" = COLOR_SILVER,
))

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

/proc/overmap_iff_id_for_key(key)
	key = trim(key)
	if(!key)
		return null
	if(cmptext(key, SSovermap.iff_key_centcom))
		return OVERMAP_IFF_CENTCOM
	if(cmptext(key, SSovermap.iff_key_syndicate))
		return OVERMAP_IFF_SYNDICATE
	return null

/proc/overmap_iff_label_for_id(id)
	switch(id)
		if(OVERMAP_IFF_GLOBAL)
			return "Глобальный"
		if(OVERMAP_IFF_CENTCOM)
			return "Центком"
		if(OVERMAP_IFF_SYNDICATE)
			return "Синдикат"
	return id

/obj/machinery/transponder
	name = "transponder"
	desc = "Настенный маяк идентификации. Позволяет идентифицировать судно на глобальной карте."
	icon = 'icons/obj/machines/overmap.dmi'
	icon_state = "transponder"
	anchored = TRUE
	density = FALSE
	idle_power_usage = 40
	active_power_usage = 80
	use_power = IDLE_POWER_USE
	power_channel = EQUIP
	layer = ABOVE_WINDOW_LAYER
	var/obj/overmap/entity/vessel
	var/broadcast_name = ""
	var/broadcast_color = COLOR_WHITE
	var/icon_preset = "shuttle_c"
	var/broadcasting = TRUE
	var/distress = FALSE
	var/lock_icon = TRUE
	var/identity_locked = FALSE
	var/list/datum/overmap_iff_channel/iff_channels

	var/list/preset_iff_ids

/obj/machinery/transponder/get_ru_names()
	return alist(
		NOMINATIVE = "транспондер",
		GENITIVE = "транспондера",
		DATIVE = "транспондеру",
		ACCUSATIVE = "транспондер",
		INSTRUMENTAL = "транспондером",
		PREPOSITIONAL = "транспондере",
	)

/obj/machinery/transponder/Initialize(mapload)
	. = ..()
	ensure_iff_channels()
	GLOB.transponders += src
	snap_to_wall()
	if(SSovermap?.initialized)
		link_vessel()

/obj/machinery/transponder/setDir(newdir)
	. = ..()
	snap_to_wall()

/obj/machinery/transponder/shuttleRotate(rotation, params)
	return

/obj/machinery/transponder/onShuttleMove(turf/oldT, turf/T1, rotation, mob/requester)
	if(light && light_system == COMPLEX_LIGHT)
		update_light()
	var/old_dir = dir
	forceMove(T1)
	if(rotation)
		setDir(angle2dir(rotation + dir2angle(old_dir)))
	else
		snap_to_wall()
	return TRUE

/obj/machinery/transponder/proc/snap_to_wall()
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

/obj/machinery/transponder/Destroy()
	GLOB.transponders -= src
	vessel?.unregister_transponder(src)
	vessel = null
	QDEL_LIST(iff_channels)
	return ..()

/obj/machinery/transponder/proc/ensure_iff_channels()
	if(length(iff_channels))
		return
	iff_channels = list()
	iff_channels += new /datum/overmap_iff_channel(OVERMAP_IFF_GLOBAL, overmap_iff_label_for_id(OVERMAP_IFF_GLOBAL), TRUE, TRUE, broadcasting)
	for(var/id in preset_iff_ids)
		iff_channels += new /datum/overmap_iff_channel(id, overmap_iff_label_for_id(id), TRUE, TRUE, TRUE)

/obj/machinery/transponder/proc/find_iff_channel(id)
	ensure_iff_channels()
	for(var/datum/overmap_iff_channel/channel as anything in iff_channels)
		if(channel.id == id)
			return channel
	return null

/obj/machinery/transponder/proc/sync_global_broadcast()
	var/datum/overmap_iff_channel/global_ch = find_iff_channel(OVERMAP_IFF_GLOBAL)
	if(global_ch)
		broadcasting = global_ch.transmit

/obj/machinery/transponder/proc/link_vessel()
	var/obj/overmap/entity/resolved = SSovermap?.resolve_vessel(src)
	if(!resolved)
		return
	if(vessel && vessel != resolved)
		vessel.unregister_transponder(src)
	vessel = resolved
	if(identity_locked && !broadcast_name)
		broadcast_name = station_name()
	if(!broadcast_name && resolved.name && resolved.name != OVERMAP_UNKNOWN_NAME)
		broadcast_name = resolved.name
	resolved.register_transponder(src)

/obj/machinery/transponder/proc/is_transmitting()
	if(distress)
		return TRUE
	if(stat & (NOPOWER|BROKEN))
		return FALSE
	return broadcasting

/obj/machinery/transponder/proc/set_distress(enabled)
	distress = enabled
	if(distress)
		use_power = ACTIVE_POWER_USE
	else
		use_power = IDLE_POWER_USE
	vessel?.sync_transponder()
	if(vessel)
		vessel.announce_sensor_event("Сигнал бедствия [distress ? "включён" : "выключен"]: [vessel.get_overmap_display_name()]", "distress")

/obj/machinery/transponder/power_change(forced = FALSE)
	. = ..()
	vessel?.sync_transponder()

/obj/machinery/transponder/attack_hand(mob/user)
	if(stat & BROKEN)
		return
	if(..())
		return TRUE
	if(stat & NOPOWER)
		to_chat(user, span_warning("Нет питания."))
		return
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/transponder/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/transponder/click_alt(mob/user)
	if(!user.Adjacent(src) || user.incapacitated())
		return CLICK_ACTION_BLOCKING
	set_distress(!distress)
	to_chat(user, span_notice("Сигнал бедствия [distress ? "включён" : "выключен"]."))
	user.visible_message(span_warning("[user] [distress ? "активирует" : "глушит"] аварийный маяк на [declent_ru(PREPOSITIONAL)]."))
	return CLICK_ACTION_SUCCESS

/obj/machinery/transponder/ui_interact(mob/user, datum/tgui/ui = null)
	if(stat & (NOPOWER|BROKEN))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapTransponder", name)
		ui.open()

/obj/machinery/transponder/ui_data(mob/user)
	var/list/data = list()
	data["linked"] = !!vessel
	data["broadcast_name"] = broadcast_name
	data["broadcast_color"] = broadcast_color
	data["broadcasting"] = broadcasting
	data["distress"] = distress
	data["identity_locked"] = identity_locked
	data["powered"] = !(stat & NOPOWER)
	data["transmitting"] = is_transmitting()
	var/list/colors = list()
	for(var/color_name in GLOB.overmap_transponder_colors)
		colors += list(list(
			"name" = color_name,
			"color" = GLOB.overmap_transponder_colors[color_name],
		))
	data["colors"] = colors
	var/list/channels = list()
	ensure_iff_channels()
	for(var/datum/overmap_iff_channel/channel as anything in iff_channels)
		channels += list(list(
			"id" = channel.id,
			"label" = channel.label,
			"permanent" = channel.permanent,
			"receive" = channel.receive,
			"transmit" = channel.transmit,
			"tone" = channel.id,
		))
	data["channels"] = channels
	return data

/obj/machinery/transponder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return TRUE
	switch(action)
		if("set_name")
			if(identity_locked)
				return TRUE
			var/new_name = copytext(trim(strip_html(params["name"])), 1, MAX_NAME_LEN)
			if(!new_name)
				return TRUE
			broadcast_name = new_name
			vessel?.sync_transponder()
			. = TRUE
		if("set_color")
			var/new_color = GLOB.overmap_transponder_colors[params["name"]]
			if(!new_color)
				for(var/color_name in GLOB.overmap_transponder_colors)
					if(GLOB.overmap_transponder_colors[color_name] == params["color"])
						new_color = GLOB.overmap_transponder_colors[color_name]
						break
			if(!new_color)
				return TRUE
			broadcast_color = new_color
			vessel?.sync_transponder()
			. = TRUE
		if("toggle_broadcast")
			var/datum/overmap_iff_channel/global_ch = find_iff_channel(OVERMAP_IFF_GLOBAL)
			if(global_ch)
				global_ch.transmit = !global_ch.transmit
				broadcasting = global_ch.transmit
			else
				broadcasting = !broadcasting
			vessel?.sync_transponder()
			if(vessel)
				vessel.announce_sensor_event("Транспондер [broadcasting ? "включён" : "выключен"]: [vessel.get_overmap_display_name()]", "iff")
			. = TRUE
		if("toggle_channel")
			var/datum/overmap_iff_channel/channel = find_iff_channel(params["id"])
			if(!channel)
				return TRUE
			if(params["side"] == "receive")
				channel.receive = !channel.receive
			else
				channel.transmit = !channel.transmit
			sync_global_broadcast()
			vessel?.sync_transponder()
			. = TRUE
		if("add_key")
			var/id = overmap_iff_id_for_key(params["key"])
			if(!id)
				to_chat(usr, span_warning("Ключ шифрования не принят."))
				return TRUE
			if(find_iff_channel(id))
				to_chat(usr, span_notice("Этот ключ уже в списке."))
				return TRUE
			iff_channels += new /datum/overmap_iff_channel(id, overmap_iff_label_for_id(id), FALSE, TRUE, FALSE)
			to_chat(usr, span_notice("Ключ принят: [overmap_iff_label_for_id(id)]."))
			vessel?.sync_transponder()
			. = TRUE
		if("remove_channel")
			var/datum/overmap_iff_channel/channel = find_iff_channel(params["id"])
			if(!channel || channel.permanent)
				return TRUE
			iff_channels -= channel
			qdel(channel)
			vessel?.sync_transponder()
			. = TRUE
		if("toggle_distress")
			set_distress(!distress)
			. = TRUE
		if("relink")
			link_vessel()
			. = TRUE

/obj/machinery/transponder/station
	name = "station transponder"
	desc = "Станционный маяк идентификации."
	broadcast_color = COLOR_WHITE
	icon_preset = "station"
	lock_icon = TRUE
	identity_locked = TRUE

/obj/machinery/transponder/station/Initialize(mapload)
	broadcast_name = station_name()
	. = ..()
	if(vessel)
		vessel.sync_transponder()

/obj/machinery/transponder/lavaland
	name = "Lavaland transponder"
	desc = "Маяк идентификации шахтёрской станции на Лаваленде."
	broadcast_name = "Лаваленд"
	broadcast_color = COLOR_WHITE
	icon_preset = "station"
	lock_icon = TRUE
	identity_locked = TRUE

/obj/machinery/transponder/lavaland/link_vessel()
	if(SSovermap?.lavaland_entity)
		if(vessel && vessel != SSovermap.lavaland_entity)
			vessel.unregister_transponder(src)
		vessel = SSovermap.lavaland_entity
		if(!broadcast_name)
			broadcast_name = "Шахтерский аванпост"
		SSovermap.lavaland_entity.register_transponder(src)
		return
	return ..()

/obj/machinery/transponder/lavaland/Initialize(mapload)
	if(!broadcast_name)
		broadcast_name = "Шахтерский аванпост"
	. = ..()
	if(vessel)
		vessel.sync_transponder()

/obj/machinery/transponder/centcom
	name = "CentCom transponder"
	desc = "Маяк идентификации Центрального командования. Ключ шифрования центкомма уже прошит."
	broadcast_color = COLOR_COMMAND_BLUE
	preset_iff_ids = list(OVERMAP_IFF_CENTCOM)

/obj/machinery/transponder/centcom/station
	name = "CentCom station overmap transponder"
	desc = "Станционный маяк Центрального командования."
	broadcast_name = "Центральное командование"
	icon_preset = "station"
	lock_icon = TRUE
	identity_locked = TRUE

/obj/machinery/transponder/syndicate
	name = "Syndicate overmap transponder"
	desc = "Маяк идентификации Синдиката. Ключ шифрования Синдиката уже прошит."
	broadcast_color = COLOR_RED
	broadcasting = FALSE
	preset_iff_ids = list(OVERMAP_IFF_SYNDICATE)

/obj/machinery/transponder/syndicate/station
	name = "Syndicate station overmap transponder"
	desc = "Станционный маяк Синдиката."
	broadcast_name = "База синдиката"
	icon_preset = "station"
	lock_icon = TRUE
	identity_locked = TRUE

/obj/machinery/transponder/universal
	name = "universal overmap transponder"
	desc = "Универсальный маяк идентификации. Прошиты ключи и Центкома, и Синдиката."
	broadcast_color = COLOR_PURPLE
	preset_iff_ids = list(OVERMAP_IFF_CENTCOM, OVERMAP_IFF_SYNDICATE)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/transponder, 26, 26)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/transponder/station, 26, 26)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/transponder/lavaland, 26, 26)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/transponder/centcom, 26, 26)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/transponder/centcom/station, 26, 26)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/transponder/syndicate, 26, 26)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/transponder/syndicate/station, 26, 26)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/transponder/universal, 26, 26)
