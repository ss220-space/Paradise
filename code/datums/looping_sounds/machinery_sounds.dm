/datum/looping_sound/showering
	start_sound = 'sound/machines/shower/shower_start.ogg'
	start_length = 0.2 SECONDS
	mid_sounds = list(
		'sound/machines/shower/shower_mid1.ogg' = 1,
		'sound/machines/shower/shower_mid2.ogg' = 1,
		'sound/machines/shower/shower_mid3.ogg' = 1,
	)
	mid_length = 1 SECONDS
	end_sound = 'sound/machines/shower/shower_end.ogg'
	volume = 20

/datum/looping_sound/gigadrill
	start_sound = 'sound/machines/engine/engine_start.ogg'
	start_length = 0.3 SECONDS
	mid_sounds = list('sound/machines/engine/engine_mid1.ogg')
	mid_length = 0.3 SECONDS
	end_sound = 'sound/machines/engine/engine_end.ogg'
	volume = 20

/datum/looping_sound/port_gen
	start_sound = 'sound/machines/generator/generator_start.ogg'
	start_length = 0.4 SECONDS
	mid_sounds = list(
		'sound/machines/generator/generator_mid1.ogg',
		'sound/machines/generator/generator_mid2.ogg',
		'sound/machines/generator/generator_mid3.ogg',
	)
	mid_length = 0.4 SECONDS
	end_sound = 'sound/machines/generator/generator_end.ogg'
	volume = 40

/datum/looping_sound/kinesis
	mid_sounds = list('sound/machines/gravgen/gravgen_mid1.ogg' = 1, 'sound/machines/gravgen/gravgen_mid2.ogg' = 1, 'sound/machines/gravgen/gravgen_mid3.ogg' = 1, 'sound/machines/gravgen/gravgen_mid4.ogg' = 1)
	mid_length = 1.8 SECONDS
	extra_range = 10
	volume = 20
	falloff_distance = 2
	falloff_exponent = 5

/datum/looping_sound/supermatter
	mid_sounds = list('sound/machines/sm/loops/calm.ogg')
	mid_length = 6 SECONDS
	volume = 40
	extra_range = 25
	falloff_exponent = 10
	falloff_distance = 5
	vary = TRUE

/datum/looping_sound/destabilized_crystal
	mid_sounds = list('sound/machines/sm/loops/delamming.ogg')
	mid_length = 6 SECONDS
	volume = 55
	extra_range = 15
	vary = TRUE
