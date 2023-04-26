/*
 * A file intended to store various animation procs for re-use.
 * A fair majority of these are copy-pasted from Goon and may not function as expected without tweaking.
 * The spin from being thrown will interrupt most of these animations as will grabs, account for that accordingly.
 */

/proc/animate_fade_grayscale(var/atom/A, var/time = 5)
	if(!istype(A) && !istype(A, /client))
		return
	A.color = null
	animate(A, color = MATRIX_GREYSCALE, time = time, easing = SINE_EASING)

/proc/animate_ghostly_presence(var/atom/A, var/loopnum = -1, floatspeed = 20, random_side = 1)
	if(!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	if(random_side)
		side = pick(-1, 1)

	spawn(rand(1,10))
		animate(A, pixel_y = 8, transform = matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
		animate(pixel_y = 0, transform = matrix(floatdegrees * (side == 1 ? -1:1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
