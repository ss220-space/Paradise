/datum/controller/subsystem/overmap/proc/ensure_comms_keys()
	if(observation_comms_key)
		return
	var/list/used = list(iff_key_centcom, iff_key_syndicate)
	observation_comms_key = generate_overmap_iff_key()
	while(observation_comms_key in used)
		observation_comms_key = generate_overmap_iff_key()
	used += observation_comms_key
	for(var/faction in GLOB.overmap_faction_prefixes)
		if(faction == "neutral" || faction == "unknown")
			continue
		var/key = generate_overmap_iff_key()
		while(key in used)
			key = generate_overmap_iff_key()
		used += key
		faction_comms_keys[faction] = key

/datum/controller/subsystem/overmap/proc/print_roundstart_comms_keys()
	for(var/obj/machinery/computer/communications/console as anything in GLOB.shuttle_caller_list)
		if(istype(console))
			console.print_overmap_key()
	for(var/obj/machinery/overmap_intercom/console as anything in GLOB.overmap_intercoms)
		console.print_overmap_key()

/datum/controller/subsystem/overmap/proc/print_comms_key(atom/console, obj/overmap/entity/host)
	var/turf/spot = get_turf(console)
	if(!spot || !observation_comms_key)
		return FALSE
	var/faction = host ? overmap_ai_faction(host, TRUE) : is_station_level(spot.z) ? "nt" : "unknown"
	var/is_station = (host && host == station_entity) || (!host && is_station_level(spot.z))
	var/body = ""
	if(is_station)
		body += "<b>Наблюдательный пост — ключ текущей смены:</b><br>[html_encode(observation_comms_key)]<br><br>"
	var/key = faction_comms_keys[faction]
	if(key)
		body += "<b>Канал [html_encode(GLOB.overmap_faction_prefixes[faction])]:</b><br>[html_encode(key)]<br><br>"
	if(!body)
		return FALSE
	var/obj/item/paper/overmap_keys/sheet = new(spot)
	sheet.info = body + "Введите ключ в панели секторной связи. Ключи действуют только в текущей смене."
	sheet.update_icon()
	return TRUE

/obj/item/paper/overmap_keys
	name = "sector communications keys"
	gender = PLURAL
	desc = "TEMP123TEMP"

/obj/item/paper/overmap_keys/get_ru_names()
	return alist(
		NOMINATIVE = "ключи секторной связи",
		GENITIVE = "ключей секторной связи",
		DATIVE = "ключам секторной связи",
		ACCUSATIVE = "ключи секторной связи",
		INSTRUMENTAL = "ключами секторной связи",
		PREPOSITIONAL = "ключах секторной связи",
	)

/obj/machinery/computer/communications/proc/print_overmap_key()
	if(overmap_key_printed)
		return
	overmap_key_printed = SSovermap.print_comms_key(src, SSovermap.resolve_vessel(src))

/obj/machinery/overmap_intercom/proc/print_overmap_key()
	if(overmap_key_printed)
		return
	link_vessel()
	overmap_key_printed = SSovermap.print_comms_key(src, vessel)

/obj/overmap/entity/proc/traffic_identity()
	var/class_code = registration_class
	var/number = registration_id
	var/obj/overmap/entity/virtual_structure/ai/craft = src
	if(istype(craft))
		class_code = craft.registration_class || craft.mapped_ship_class || ship_ai?.profile.ship_class
		number = craft.registration_id
	if(shuttle && istype(shuttle.areaInstance, /area/shuttle))
		var/area/shuttle/ship_area = shuttle.areaInstance
		class_code ||= ship_area.overmap_ship_class
	var/static/regex/registration = regex(@"^[A-Z]+-([A-Z]+)-([0-9]{3})( |$)")
	if(registration.Find(identity_name || name))
		class_code ||= registration.group[1]
		number ||= registration.group[2]
	if(!number)
		if(!traffic_number)
			traffic_number = add_zero("[rand(0, 999)]", 3)
		number = traffic_number
	return list("class" = class_code || "не определён", "number" = number, "faction" = overmap_ai_faction(src, TRUE))
