/*
 * A file intended to store various animation procs for re-use.
 * A fair majority of these are copy-pasted from Goon and may not function as expected without tweaking.
 * The spin from being thrown will interrupt most of these animations as will grabs, account for that accordingly.
 */

/**
 * Animates fading an atom to grayscale
 *
 * Arguments:
 * * target - The atom or client to animate
 * * duration - Animation duration in ticks (default: 0.5 SECONDS)
 */
/proc/animate_fade_grayscale(atom/target, duration = 0.5 SECONDS)
	if(!istype(target) && !isclient(target))
		return

	target.color = null
	animate(target, color = MATRIX_GREYSCALE, time = duration, easing = SINE_EASING, flags = ANIMATION_PARALLEL)

/**
 * Animates fading an atom from grayscale to normal color
 *
 * Arguments:
 * * target - The atom or client to animate
 * * duration - Animation duration in ticks (default: 0.5 SECONDS)
 */
/proc/animate_fade_colored(atom/target, duration = 0.5 SECONDS)
	if(!istype(target) && !isclient(target))
		return

	animate(target, color = null, time = duration, easing = SINE_EASING, flags = ANIMATION_PARALLEL)

/**
 * Animates an atom melting downward with a bounce effect
 *
 * Arguments:
 * * target - The atom to animate
 */
/proc/animate_melt_pixel(atom/target)
	if(!istype(target))
		return

	animate(target, pixel_y = 0, time = 5 SECONDS - target.pixel_y, alpha = 175, easing = BOUNCE_EASING)
	animate(alpha = 0, easing = LINEAR_EASING)

/**
 * Animates an atom exploding outward with random rotation and movement
 *
 * Arguments:
 * * target - The atom to animate
 */
/proc/animate_explode_pixel(atom/target)
	if(!istype(target))
		return

	var/rotation_angle = rand(5, 20)
	var/rotation_direction = pick(-1, 1)

	animate(
		target,
		pixel_x = rand(-64, 64),
		pixel_y = rand(-64, 64),
		transform = matrix(rotation_angle * (rotation_direction == 1 ? 1 : -1), MATRIX_ROTATE),
		time = 1 SECONDS,
		alpha = 0,
		easing = SINE_EASING
	)

/**
 * Animates an atom floating up and down with rotation
 *
 * Arguments:
 * * target - The atom to animate
 * * loop_count - Number of animation loops (default: -1 for infinite)
 * * float_speed - Animation speed in ticks (default: 2 SECONDS)
 * * random_rotation - Whether to use random rotation direction (default: TRUE)
 */
/proc/animate_float(atom/target, loop_count = -1, float_speed = 2 SECONDS, random_rotation = TRUE)
	if(!istype(target))
		return

	var/rotation_angle = rand(5, 20)
	var/rotation_direction = 1

	if(random_rotation)
		rotation_direction = pick(-1, 1)

	addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(_animate_float_callback), target, loop_count, float_speed, rotation_angle, rotation_direction), rand(1, 10))

/proc/_animate_float_callback(atom/target, loop_count, float_speed, rotation_angle, rotation_direction)
	animate(
		target,
		pixel_y = 32,
		transform = matrix(rotation_angle * (rotation_direction == 1 ? 1 : -1), MATRIX_ROTATE),
		time = float_speed,
		loop = loop_count,
		easing = SINE_EASING
	)
	animate(
		pixel_y = 0,
		transform = matrix(rotation_angle * (rotation_direction == 1 ? -1 : 1), MATRIX_ROTATE),
		time = float_speed,
		loop = loop_count,
		easing = SINE_EASING
	)

/**
 * Animates an atom levitating slightly with rotation
 *
 * Arguments:
 * * target - The atom to animate
 * * loop_count - Number of animation loops (default: -1 for infinite)
 * * float_speed - Animation speed in ticks (default: 2 SECONDS)
 * * random_rotation - Whether to use random rotation direction (default: TRUE)
 */
/proc/animate_levitate(atom/target, loop_count = -1, float_speed = 2 SECONDS, random_rotation = TRUE)
	if(!istype(target))
		return

	var/rotation_angle = rand(5, 20)
	var/rotation_direction = 1

	if(random_rotation)
		rotation_direction = pick(-1, 1)

	addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(_animate_levitate_callback), target, loop_count, float_speed, rotation_angle, rotation_direction), rand(1, 10))

/proc/_animate_levitate_callback(atom/target, loop_count, float_speed, rotation_angle, rotation_direction)
	animate(
		target,
		pixel_y = 8,
		transform = matrix(rotation_angle * (rotation_direction == 1 ? 1 : -1), MATRIX_ROTATE),
		time = float_speed,
		loop = loop_count,
		easing = SINE_EASING
	)
	animate(pixel_y = 0, transform = null, time = float_speed, loop = loop_count, easing = SINE_EASING)

/**
 * Animates a ghostly presence effect with floating and rotation
 *
 * Arguments:
 * * target - The atom to animate
 * * loop_count - Number of animation loops (default: -1 for infinite)
 * * float_speed - Animation speed in ticks (default: 2 SECONDS)
 * * random_rotation - Whether to use random rotation direction (default: TRUE)
 */
/proc/animate_ghostly_presence(atom/target, loop_count = -1, float_speed = 2 SECONDS, random_rotation = TRUE)
	if(!istype(target))
		return

	var/rotation_angle = rand(5, 20)
	var/rotation_direction = 1

	if(random_rotation)
		rotation_direction = pick(-1, 1)

	addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(_animate_ghostly_presence_callback), target, loop_count, float_speed, rotation_angle, rotation_direction), rand(1, 10))

/proc/_animate_ghostly_presence_callback(atom/target, loop_count, float_speed, rotation_angle, rotation_direction)
	animate(
		target,
		pixel_y = 8,
		transform = matrix(rotation_angle * (rotation_direction == 1 ? 1 : -1), MATRIX_ROTATE),
		time = float_speed,
		loop = loop_count,
		easing = SINE_EASING
	)
	animate(
		pixel_y = 0,
		transform = matrix(rotation_angle * (rotation_direction == 1 ? -1 : 1), MATRIX_ROTATE),
		time = float_speed,
		loop = loop_count,
		easing = SINE_EASING
	)

/**
 * Animates an atom leaping upward while fading and scaling
 *
 * Arguments:
 * * target - The atom to animate
 */
/proc/animate_fading_leap_up(atom/target)
	if(!istype(target))
		return

	var/matrix/scale_matrix = matrix()
	var/remaining_loops = 15

	while(remaining_loops > 0)
		remaining_loops--
		animate(target, transform = scale_matrix, pixel_z = target.pixel_z + 12, alpha = target.alpha - 17, time = 0.1 SECONDS, loop = 1, easing = LINEAR_EASING)
		scale_matrix.Scale(1.2,1.2)
		sleep(1)

	target.alpha = 0

/**
 * Animates an atom leaping downward while appearing and scaling down
 *
 * Arguments:
 * * target - The atom to animate
 */
/proc/animate_fading_leap_down(atom/target)
	if(!istype(target))
		return

	var/matrix/scale_matrix = matrix()
	var/remaining_loops = 15

	scale_matrix.Scale(18,18)

	while(remaining_loops > 0)
		remaining_loops--
		animate(target, transform = scale_matrix, pixel_z = target.pixel_z - 12, alpha = target.alpha + 17, time = 0.1 SECONDS, loop = 1, easing = LINEAR_EASING)
		scale_matrix.Scale(0.8,0.8)
		sleep(1)

	animate(target, transform = scale_matrix, pixel_z = 0, alpha = 255, time = 0.1 SECONDS, loop = 1, easing = LINEAR_EASING)

/**
 * Animates shaking an atom randomly on its tile
 *
 * Arguments:
 * * target - The atom to animate
 * * shake_count - Number of shake iterations (default: 5)
 * * x_amplitude - Maximum horizontal shake distance (default: 2)
 * * y_amplitude - Maximum vertical shake distance (default: 2)
 */
/proc/animate_shake(atom/target, shake_count = 5, x_amplitude = 2, y_amplitude = 2)
	// Wiggles the sprite around on its tile then returns it to normal
	if(!istype(target))
		return

	if(!isnum(shake_count) || !isnum(x_amplitude) || !isnum(y_amplitude))
		return

	shake_count = max(1,min(shake_count,50))
	x_amplitude = max(-32,min(x_amplitude,32))
	y_amplitude = max(-32,min(y_amplitude,32))

	var/negative_x_amplitude = 0 - x_amplitude
	var/negative_y_amplitude = 0 - y_amplitude

	animate(
		target,
		transform = null,
		pixel_y = rand(negative_y_amplitude, y_amplitude),
		pixel_x = rand(negative_x_amplitude, x_amplitude),
		time = 0.1 SECONDS,
		loop = shake_count,
		easing = ELASTIC_EASING,
	)
	addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(_animate_shake_callback), target), shake_count)

/proc/_animate_shake_callback(atom/target)
	animate(
		target,
		transform = null,
		pixel_y = 0,
		pixel_x = 0,
		time = 0.1 SECONDS,
		loop = 1,
		easing = LINEAR_EASING,
	)

/**
 * Animates a teleportation effect with scaling and color change
 *
 * Arguments:
 * * target - The atom to animate
 */
/proc/animate_teleport(atom/target)
	if(!istype(target))
		return

	var/matrix/scale_matrix = matrix(1, 3, MATRIX_SCALE)

	animate(target, transform = scale_matrix, pixel_y = 32, time = 1 SECONDS, alpha = 50, easing = CIRCULAR_EASING)

	scale_matrix.Scale(0,4)

	animate(transform = scale_matrix, time = 0.5 SECONDS, color = COLOR_BLUE, alpha = 0, easing = CIRCULAR_EASING)
	animate(transform = null, time = 0.5 SECONDS, color = COLOR_WHITE, alpha = 255, pixel_y = 0, easing = ELASTIC_EASING)

/**
 * Animates a wizard-style teleportation effect
 *
 * Arguments:
 * * target - The atom to animate
 */
/proc/animate_teleport_wiz(atom/target)
	if(!istype(target))
		return

	var/matrix/scale_matrix = matrix(0, 4, MATRIX_SCALE)

	animate(target, color = COLOR_BLUE_VERY_LIGHT, time = 2 SECONDS, alpha = 70, easing = LINEAR_EASING)
	animate(transform = scale_matrix, pixel_y = 32, time = 2 SECONDS, color = COLOR_BLUE, alpha = 0, easing = CIRCULAR_EASING)
	animate(time = 0.8 SECONDS, transform = scale_matrix, alpha = 5) //Do nothing, essentially
	animate(transform = null, time = 5, color = COLOR_WHITE, alpha = 255, pixel_y = 0, easing = ELASTIC_EASING)

/**
 * Animates a simple rainbow color cycle (red, green, blue)
 *
 * Arguments:
 * * target - The atom to animate
 */
/proc/animate_rainbow_glow_old(atom/target)
	if(!istype(target))
		return

	animate(target, color = COLOR_RED, time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = COLOR_VIBRANT_LIME, time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = COLOR_BLUE, time = rand(5,10), loop = -1, easing = LINEAR_EASING)

/**
 * Animates a full rainbow color cycle
 *
 * Arguments:
 * * target - The atom to animate
 */
/proc/animate_rainbow_glow(atom/target)
	if(!istype(target))
		return

	animate(target, color = COLOR_RED, time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = COLOR_YELLOW, time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = COLOR_VIBRANT_LIME, time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = COLOR_CYAN, time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = COLOR_BLUE, time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = COLOR_MAGENTA, time = rand(5,10), loop = -1, easing = LINEAR_EASING)

/**
 * Animates fading to a specific color fill
 *
 * Arguments:
 * * target - The atom to animate
 * * target_color - The color to fade to
 * * duration - Animation duration in ticks
 */
/proc/animate_fade_to_color_fill(atom/target, target_color, duration)
	if(!istype(target) || !target_color || !duration)
		return

	animate(target, color = target_color, time = duration, easing = LINEAR_EASING)

/**
 * Animates flashing between a specific color and white
 *
 * Arguments:
 * * target - The atom to animate
 * * flash_color - The color to flash to
 * * loop_count - Number of flash cycles
 * * duration - Animation duration per cycle in ticks
 */
/proc/animate_flash_color_fill(atom/target, flash_color, loop_count, duration)
	if(!istype(target) || !flash_color || !duration || !loop_count)
		return

	animate(target, color = flash_color, time = duration, easing = LINEAR_EASING)
	animate(color = COLOR_WHITE, time = 5, loop = loop_count, easing = LINEAR_EASING)

/**
 * Animates flashing between a specific color and the original color
 *
 * Arguments:
 * * target - The atom to animate
 * * flash_color - The color to flash to
 * * loop_count - Number of flash cycles
 * * duration - Animation duration per cycle in ticks
 */
/proc/animate_flash_color_fill_inherit(atom/target, flash_color, loop_count, duration)
	if(!istype(target) || !flash_color || !duration || !loop_count)
		return

	var/original_color = target.color

	animate(target, color = flash_color, time = duration, loop = loop_count, easing = LINEAR_EASING)
	animate(target, color = original_color, time = duration, loop = loop_count, easing = LINEAR_EASING)

/**
 * Animates a clown spell effect with scaling and color change
 *
 * Arguments:
 * * target - The atom to animate
 */
/proc/animate_clownspell(atom/target)
	if(!istype(target))
		return

	animate(target, transform = matrix(1.3, MATRIX_SCALE), time = 0.5 SECONDS, color = COLOR_VIBRANT_LIME, easing = BACK_EASING)
	animate(transform = null, time = 0.5 SECONDS, color = COLOR_WHITE, easing = ELASTIC_EASING)

/**
 * Animates wiggling an atom randomly then resetting to original position
 *
 * Arguments:
 * * target - The atom to animate
 * * loop_count - Number of wiggle cycles
 * * speed - Animation speed in ticks
 * * x_variance - Maximum horizontal wiggle distance
 * * y_variance - Maximum vertical wiggle distance
 */
/proc/animate_wiggle_then_reset(atom/target, loop_count = 5, speed = 0.5 SECONDS, x_variance = 3, y_variance = 3)
	if(!istype(target) || !loop_count || !speed)
		return

	animate(target, pixel_x = rand(-x_variance, x_variance), pixel_y = rand(-y_variance, y_variance), time = speed * 2, loop = loop_count, easing = rand(2,7))
	animate(pixel_x = 0, pixel_y = 0, time = speed, easing = rand(2,7))

/**
 * Animates spinning an atom in the specified direction
 *
 * Arguments:
 * * target - The atom to animate
 * * direction - Spin direction "L" for left, "R" for right
 * * spin_duration - Duration per quarter turn in ticks
 * * loop_count - Number of spin cycles (default: -1 for infinite)
 */
/proc/animate_spin(atom/target, direction = "L", spin_duration = 0.1 SECONDS, looping = -1)
	if(!istype(target))
		return

	var/matrix/original_transform = target.transform
	var/turn_angle = -90

	if(direction == "R")
		turn_angle = 90

	animate(target, transform = matrix(original_transform, turn_angle, MATRIX_ROTATE | MATRIX_MODIFY), time = spin_duration, loop = looping)
	animate(transform = matrix(original_transform, turn_angle, MATRIX_ROTATE | MATRIX_MODIFY), time = spin_duration, loop = looping)
	animate(transform = matrix(original_transform, turn_angle, MATRIX_ROTATE | MATRIX_MODIFY), time = spin_duration, loop = looping)
	animate(transform = matrix(original_transform, turn_angle, MATRIX_ROTATE | MATRIX_MODIFY), time = spin_duration, loop = looping)

/**
 * Animates a shockwave effect with rotation and vertical movement
 *
 * Arguments:
 * * target - The atom to animate
 */
/proc/animate_shockwave(atom/target)
	if(!istype(target))
		return
	var/rotation_strength = rand(10, 20)
	var/original_y_position = target.pixel_y
	animate(target, transform = matrix(rotation_strength, MATRIX_ROTATE), pixel_y = 16, time = 0.2 SECONDS, color = "#eeeeee", easing = BOUNCE_EASING)
	animate(transform = matrix(-rotation_strength, MATRIX_ROTATE), pixel_y = original_y_position, time = 0.2 SECONDS, color = COLOR_WHITE, easing = BOUNCE_EASING)
	animate(transform = null, time = 0.3 SECONDS, easing = BOUNCE_EASING)

/**
 * Animates a rumbling effect by translating the atom in four directions
 *
 * Arguments:
 * * target - The atom to animate
 */
/proc/animate_rumble(atom/target)
	var/static/list/translation_matrices

	if(!translation_matrices)
		var/matrix/left_matrix = matrix()
		var/matrix/up_matrix = matrix()
		var/matrix/right_matrix = matrix()
		var/matrix/down_matrix = matrix()
		left_matrix.Translate(-1, 0)
		up_matrix.Translate(0, 1)
		right_matrix.Translate(1, 0)
		down_matrix.Translate(0, -1)
		translation_matrices = list(left_matrix, up_matrix, right_matrix, down_matrix)

	animate(target, transform = translation_matrices[1], time = 0.02 SECONDS, loop = -1)
	animate(transform = translation_matrices[2], time = 0.01 SECONDS)
	animate(transform = translation_matrices[3], time = 0.02 SECONDS)
	animate(transform = translation_matrices[4], time = 0.03 SECONDS)
