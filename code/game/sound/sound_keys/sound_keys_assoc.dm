/// subtype that accepts weighted lists
/datum/sound_effect/assoc

/datum/sound_effect/assoc/return_sfx()
	return pick_weight(file_paths)

// TEMPLATE
/*
/datum/sound_effect/assoc/*name
	key = *SFX_
	file_paths = list(
		'sound/*name.ogg' = *num,
		'sound/*name.ogg' = *num
	)
*/
