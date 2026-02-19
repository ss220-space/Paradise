/// subtype that accepts weighted lists
/datum/sound_effect/assoc

/datum/sound_effect/assoc/return_sfx()
	return pick_weight_classic(file_paths)

/datum/sound_effect/assoc/cat_meow
	key = SFX_CAT_MEOW
	file_paths = list(
		'sound/mobs/non-humanoids/cat/cat_meow1.ogg' = 33,
		'sound/mobs/non-humanoids/cat/cat_meow2.ogg' = 33,
		'sound/mobs/non-humanoids/cat/cat_meow3.ogg' = 33,
		'sound/mobs/non-humanoids/cat/oranges_meow1.ogg' = 1,
	)
