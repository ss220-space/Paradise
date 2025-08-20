/// subtype that accepts weighted lists
/datum/sound_effect/assoc

/datum/sound_effect/assoc/return_sfx()
	return pick_weight_classic(file_paths)

// Template
/*
/datum/sound_effect/assoc/name
	key = SFX_
	file_paths = list(
		'sound/sound1.ogg' = num,
		'sound/sound2.ogg' = num
	)
*/
