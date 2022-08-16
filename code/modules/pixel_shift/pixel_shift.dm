#define PIXEL_SHIFT_RANGE 16

/mob/living/key_down(_key, client/user)
	switch(_key)
		if("V")
			shifting = TRUE
			return
	return ..()

/mob/living/key_up(_key, client/user)
	switch(_key)
		if("V")
			shifting = FALSE
			return
	return ..()

/mob
	///Whether the mob is pixel shifted or not
	var/is_shifted
	var/shifting //If we are in the shifting setting.

/mob/proc/unpixel_shift()
	return

/mob/living/unpixel_shift()
	if(is_shifted)
		is_shifted = FALSE
		pixel_x = 0
		pixel_y = 0

/mob/proc/pixel_shift(direction)
	return

/mob/living/pixel_shift(direction)
	switch(direction)
		if(NORTH)
			if(pixel_y <= PIXEL_SHIFT_RANGE)
				pixel_y++
				is_shifted = TRUE
		if(EAST)
			if(pixel_x <= PIXEL_SHIFT_RANGE)
				pixel_x++
				is_shifted = TRUE
		if(SOUTH)
			if(pixel_y >= -PIXEL_SHIFT_RANGE)
				pixel_y--
				is_shifted = TRUE
		if(WEST)
			if(pixel_x >= -PIXEL_SHIFT_RANGE)
				pixel_x--
				is_shifted = TRUE

#undef PIXEL_SHIFT_RANGE
