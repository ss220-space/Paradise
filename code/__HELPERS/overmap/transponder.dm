/proc/overmap_iff_id_for_key(key)
	key = istext(key) ? trim(key) : null
	if(!key)
		return null
	for(var/faction, cipher in SSovermap.faction_iff_keys)
		if(cmptext(key, cipher))
			return overmap_faction_iff_id(faction)
	return null

/proc/overmap_iff_label_for_id(id)
	switch(id)
		if(OVERMAP_IFF_GLOBAL)
			return "Глобальный"
		if(OVERMAP_IFF_HIJACK)
			return "sys.iff_signal = %ERR#NULL%"
	return SSovermap.faction_options[SSovermap.iff_factions[id]] || id

/proc/generate_overmap_iff_key()
	var/alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	. = ""
	for(var/i in 1 to OVERMAP_IFF_KEY_LEN)
		var/index = rand(1, length(alphabet))
		. += copytext(alphabet, index, index + 1)
