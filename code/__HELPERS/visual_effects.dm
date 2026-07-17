/**
 * Causes the passed atom / image to appear floating,
 * playing a simple animation where they move up and down by 2 pixels (looping)
 *
 * In most cases you should NOT call this manually, instead use [/datum/element/movetype_handler]!
 * This is just so you can apply the animation to things which can be animated but are not movables (like images)
 */
#define DO_FLOATING_ANIM(target) \
	animate(target, pixel_z = 2, time = 1 SECONDS, loop = -1, flags = ANIMATION_RELATIVE); \
	animate(pixel_z = -2, time = 1 SECONDS, flags = ANIMATION_RELATIVE)

/**
 * Stops the passed atom / image from appearing floating
 * (Living mobs also have a 'body_position_pixel_y_offset' variable that has to be taken into account here)
 *
 * In most cases you should NOT call this manually, instead use [/datum/element/movetype_handler]!
 * This is just so you can apply the animation to things which can be animated but are not movables (like images)
 */
#define STOP_FLOATING_ANIM(target) \
	var/__final_pixel_z = 0; \
	if(ismovable(target)) { \
		var/atom/movable/__movable_target = target; \
		__final_pixel_z += __movable_target.base_pixel_z; \
	}; \
	if(isliving(target)) { \
		var/mob/living/__living_target = target; \
		__final_pixel_z += __living_target.has_offset(pixel = PIXEL_Z_OFFSET); \
	}; \
	animate(target, pixel_z = __final_pixel_z, time = 1 SECONDS)

/// The duration of the animate call in mob/living/update_transform
#define UPDATE_TRANSFORM_ANIMATION_TIME (0.2 SECONDS)

/// Similar to shake but more spasm-y and jerk-y
/atom/proc/spasm_animation(loops = -1)
	var/list/transforms = list(
		matrix(transform).Translate(-1, 0),
		matrix(transform).Translate(0, 1),
		matrix(transform).Translate(1, 0),
		matrix(transform).Translate(0, -1),
		matrix(transform),
	)

	animate(src, transform = transforms[1], time = 0.1, loop = loops)
	animate(transform = transforms[2], time = 0.1)
	animate(transform = transforms[3], time = 0.2)
	animate(transform = transforms[4], time = 0.3)
	animate(transform = transforms[5], time = 0.1)

///Animates source spinning around itself. For docmentation on the args, check atom/proc/SpinAnimation()
/atom/proc/do_spin_animation(speed = 1 SECONDS, loops = -1, segments = 3, angle = 120, parallel = TRUE, tag = null)
	var/list/matrices = list()
	for(var/i in 1 to segments-1)
		var/matrix/segment_matrix = matrix(transform)
		segment_matrix.Turn(angle*i)
		matrices += segment_matrix
	var/matrix/last = matrix(transform)
	matrices += last

	speed /= segments

	if(parallel)
		animate(src, transform = matrices[1], time = speed, loop = loops, flags = ANIMATION_PARALLEL, tag = tag)
	else
		animate(src, transform = matrices[1], time = speed, loop = loops)
	for(var/i in 2 to segments) //2 because 1 is covered above
		animate(transform = matrices[i], time = speed)
		//doesn't have an object argument because this is "Stacking" with the animate call above
		//3 billion% intentional
