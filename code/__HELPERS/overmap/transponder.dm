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
		if(OVERMAP_IFF_HIJACK)
			return "sys.iff_signal = %ERR#NULL%"
	return id

/proc/generate_overmap_iff_key()
	var/alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	. = ""
	for(var/i in 1 to OVERMAP_IFF_KEY_LEN)
		var/index = rand(1, length(alphabet))
		. += copytext(alphabet, index, index + 1)
