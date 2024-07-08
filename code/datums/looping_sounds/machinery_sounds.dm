/datum/looping_sound/showering
	start_sound = 'sound/machines/shower/shower_start.ogg'
	start_length = 2
	mid_sounds = list('sound/machines/shower/shower_mid1.ogg' = 1,'sound/machines/shower/shower_mid2.ogg' = 1,'sound/machines/shower/shower_mid3.ogg' = 1)
	mid_length = 10
	end_sound = 'sound/machines/shower/shower_end.ogg'
	volume = 20

/datum/looping_sound/gigadrill
	start_sound = 'sound/machines/engine/engine_start.ogg'
	start_length = 3
	mid_sounds = list('sound/machines/engine/engine_mid1.ogg')
	mid_length = 3
	end_sound = 'sound/machines/engine/engine_end.ogg'
	volume = 20


/datum/looping_sound/kinesis
	mid_sounds = list('sound/machines/gravgen/gravgen_mid1.ogg' = 1, 'sound/machines/gravgen/gravgen_mid2.ogg' = 1, 'sound/machines/gravgen/gravgen_mid3.ogg' = 1, 'sound/machines/gravgen/gravgen_mid4.ogg' = 1)
	mid_length = 1.8 SECONDS
	extra_range = 10
	volume = 20
	falloff_distance = 2
	falloff_exponent = 5

