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


/datum/looping_sound/supermatter
	mid_sounds = list('sound/machines/sm/loops/calm.ogg' = 1)
	mid_length = 60
	volume = 40
	extra_range = 25
	falloff_exponent = 10
	falloff_distance = 5
	vary = TRUE

/datum/looping_sound/destabilized_crystal
	mid_sounds = list('sound/machines/sm/loops/delamming.ogg' = 1)
	mid_length = 60
	volume = 55
	extra_range = 15
	vary = TRUE

/datum/looping_sound/port_gen
	start_sound = 'sound/machines/generator/generator_start.ogg'
	start_length = 4
	mid_sounds = list('sound/machines/generator/generator_mid1.ogg' = 1, 'sound/machines/generator/generator_mid2.ogg' = 1, 'sound/machines/generator/generator_mid3.ogg' = 1)
	mid_length = 4
	end_sound = 'sound/machines/generator/generator_end.ogg'
	volume = 40


