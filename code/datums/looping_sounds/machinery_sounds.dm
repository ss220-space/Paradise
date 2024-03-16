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


///// KITCHEN MACHINERY /////

/datum/looping_sound/kitchen/microwave
	start_sound = 'sound/machines/kitchen/microwave_start.ogg'
	start_length = 10
	mid_sounds = list('sound/machines/kitchen/microwave_mid1.ogg' = 10, 'sound/machines/kitchen/microwave_mid2.ogg' = 1)
	mid_length = 15
	end_sound = 'sound/machines/kitchen/microwave_end.ogg'
	volume = 100

/datum/looping_sound/kitchen/deep_fryer
	start_sound = 'sound/machines/kitchen/deep_fryer_immerse.ogg'
	start_length = 10
	mid_sounds = list('sound/machines/kitchen/deep_fryer_1.ogg' = 1, 'sound/machines/kitchen/deep_fryer_2.ogg' = 1)
	mid_length = 9
	end_sound = 'sound/machines/kitchen/deep_fryer_emerge.ogg'
	volume = 5

/datum/looping_sound/kitchen/oven
	start_sound = 'sound/machines/kitchen/oven_loop_start.ogg'
	start_length = 11
	mid_sounds = list('sound/machines/kitchen/oven_loop_mid.ogg' = 1)
	mid_length = 12
	end_sound = 'sound/machines/kitchen/oven_loop_end.ogg'
	volume = 70

/datum/looping_sound/kitchen/grill
	start_sound = 'sound/machines/kitchen/grill_start.ogg'
	start_length = 13
	mid_sounds = list('sound/machines/kitchen/grill_mid.ogg' = 1)
	mid_length = 20
	end_sound = 'sound/machines/kitchen/grill_end.ogg'
	volume = 50
