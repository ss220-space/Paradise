/proc/default_overmap_factions()
	var/static/list/defaults = json_decode(file2text('config/example/overmap_factions.json'))
	return defaults

/datum/controller/subsystem/overmap/proc/prepare_galaxy_factions(list/layout)
	var/list/entries = layout["factions"] || list()
	var/list/ids = list()
	var/static/regex/valid_id = regex("^\[a-zA-Z0-9_-\]{1,64}$")
	var/static/regex/valid_color = regex("^#\[0-9a-fA-F\]{6}$")
	for(var/list/entry as anything in entries)
		var/id = entry["id"]
		if(!istext(id) || !valid_id.Find(id) || id == "neutral" || id == "unknown" || ids[id])
			throw EXCEPTION("Invalid or duplicate galaxy faction ID")
		if(!istext(entry["color"]) || !valid_color.Find(entry["color"]) || !length(trim(entry["name"])))
			throw EXCEPTION("Invalid galaxy faction color or name")
		ids[id] = TRUE
	var/list/defaults = default_overmap_factions()
	for(var/list/entry as anything in defaults)
		if(!ids[entry["id"]])
			entries += list(entry.Copy())
	if(length(entries) > 256 + length(defaults))
		throw EXCEPTION("Galaxy chart has too many factions")
	layout["factions"] = entries

/datum/controller/subsystem/overmap/proc/register_faction(list/entry)
	var/id = entry["id"]
	factions[id] = entry
	faction_options[id] = entry["name"]
	if(!observation_comms_key)
		observation_comms_key = new_comms_key()
	if(!faction_iff_keys[id])
		faction_iff_keys[id] = new_comms_key()
		faction_comms_keys[id] = new_comms_key()
		iff_factions[overmap_faction_iff_id(id)] = id

/datum/controller/subsystem/overmap/proc/new_comms_key()
	var/key = generate_overmap_iff_key()
	while(used_comms_keys[lowertext(key)])
		key = generate_overmap_iff_key()
	used_comms_keys[lowertext(key)] = TRUE
	return key

/datum/controller/subsystem/overmap/proc/is_ship_faction(id)
	return istext(id) && (id == "neutral" || !!factions[id])

/datum/controller/subsystem/overmap/proc/faction_color(id)
	if(id == "neutral")
		return "#a0a0a0"
	var/list/faction = factions[id]
	return faction?["color"]

/proc/overmap_faction_iff_id(faction)
	switch(faction)
		if("nt")
			return OVERMAP_IFF_CENTCOM
		if("syndicate")
			return OVERMAP_IFF_SYNDICATE
	if(SSovermap.factions[faction])
		return "faction_[faction]"

/proc/overmap_faction_prefix(faction)
	var/prefix = GLOB.overmap_faction_prefixes[faction]
	return prefix || uppertext(copytext_char(SSovermap.faction_options[faction] || "UN", 1, 4))
