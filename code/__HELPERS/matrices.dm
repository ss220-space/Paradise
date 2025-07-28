// Brightness (Luminance) of RGB on grayscale. Used for saturation matrix
#define LUM_R 0.3086 //  or  0.2125
#define LUM_G 0.6094 //  or  0.7154
#define LUM_B 0.0820 //  or  0.0721

/// Datum which stores information about a matrix decomposed with decompose().
/datum/decompose_matrix
	///?
	var/scale_x = 1
	///?
	var/scale_y = 1
	///?
	var/rotation = 0
	///?
	var/shift_x = 0
	///?
	var/shift_y = 0

/// Decomposes a matrix into scale, shift and rotation.
///
/// If other operations were applied on the matrix, such as shearing, the result
/// will not be precise.
///
/// Negative scales are now supported. =)
/matrix/proc/decompose()
	var/datum/decompose_matrix/decompose_matrix = new
	. = decompose_matrix
	var/flip_sign = (a*e - b*d < 0)? -1 : 1 // Det < 0 => only 1 axis is flipped - start doing some sign flipping
	// If both axis are flipped, nothing bad happens and Det >= 0, it just treats it like a 180° rotation
	// If only 1 axis is flipped, we need to flip one direction - in this case X, so we flip a, b and the x scaling
	decompose_matrix.scale_x = sqrt(a * a + d * d) * flip_sign
	decompose_matrix.scale_y = sqrt(b * b + e * e)
	decompose_matrix.shift_x = c
	decompose_matrix.shift_y = f
	if(!decompose_matrix.scale_x || !decompose_matrix.scale_y)
		return
	// If only translated, scaled and rotated, a/xs == e/ys and -d/xs == b/xy
	var/cossine = (a/decompose_matrix.scale_x + e/decompose_matrix.scale_y) / 2
	var/sine = (b/decompose_matrix.scale_y - d/decompose_matrix.scale_x) / 2 * flip_sign
	decompose_matrix.rotation = arctan(cossine, sine) * flip_sign

/matrix/proc/TurnTo(old_angle, new_angle)
	. = new_angle - old_angle
	Turn(.) //BYOND handles cases such as -270, 360, 540 etc. DOES NOT HANDLE 180 TURNS WELL, THEY TWEEN AND LOOK LIKE SHIT


/atom/proc/SpinAnimation(speed = 10, loops = -1, clockwise = 1, segments = 3, parallel = TRUE)
	if(!segments)
		return
	var/segment = 360/segments
	if(!clockwise)
		segment = -segment
	var/list/matrices = list()
	for(var/i in 1 to segments-1)
		var/matrix/M = matrix(transform)
		M.Turn(segment*i)
		matrices += M
	var/matrix/last = matrix(transform)
	matrices += last

	speed /= segments

	if(parallel)
		animate(src, transform = matrices[1], time = speed, loops , flags = ANIMATION_PARALLEL)
	else
		animate(src, transform = matrices[1], time = speed, loops)
	for(var/i in 2 to segments) //2 because 1 is covered above
		animate(transform = matrices[i], time = speed)
		//doesn't have an object argument because this is "Stacking" with the animate call above
		//3 billion% intentional

/**
 * Shear the transform on either or both axes.
 * * x - X axis shearing
 * * y - Y axis shearing
 */
/matrix/proc/Shear(x, y)
	return Multiply(matrix(1, x, 0, y, 1, 0))

//Dumps the matrix data in format a-f
/matrix/proc/tolist()
	. = list()
	. += a
	. += b
	. += c
	. += d
	. += e
	. += f

//Dumps the matrix data in a matrix-grid format
/*
  a d 0
  b e 0
  c f 1
*/
/matrix/proc/togrid()
	. = list()
	. += a
	. += d
	. += 0
	. += b
	. += e
	. += 0
	. += c
	. += f
	. += 1

//The X pixel offset of this matrix
/matrix/proc/get_x_shift()
	. = c

//The Y pixel offset of this matrix
/matrix/proc/get_y_shift()
	. = f


/// A color matrix allows us to set the color of an atom in a list form, thus allowing us to change color in more flexible ways. For example, we can set the brightness and contrast of the bloom and exposure of lamps
/datum/color_matrix
	var/list/matrix

/// Value can be color as text (e.g. "#735184") that will set matrix to be the same color / number that will set the saturation of matrix / the color list itself, contrast as number, brightness as number
/datum/color_matrix/New(value, contrast = 1, brightness = null)
	..()
	if(istext(value))
		set_color(value, contrast, brightness)
	else if(isnum(value))
		set_saturation(value, contrast, brightness)
	else
		matrix = value

/datum/color_matrix/proc/reset()
	matrix = list(1, 0, 0,
				0, 1, 0,
				0, 0, 1)

/datum/color_matrix/proc/get(contrast = 1)
	var/list/mat = matrix
	mat = mat.Copy()

	for(var/i = 1 to min(length(mat), 12))
		mat[i] *= contrast
	return mat

/datum/color_matrix/proc/set_saturation(saturation, contrast = 1, brightness = null)
	var/r_adjustment = (1 - saturation) * LUM_R
	var/g_adjustment = (1 - saturation) * LUM_G
	var/b_adjustment = (1 - saturation) * LUM_B

	matrix = list(contrast * (r_adjustment + saturation),	contrast * (r_adjustment),				contrast * (r_adjustment),
				contrast * (g_adjustment),				contrast * (g_adjustment + saturation),	contrast * (g_adjustment),
				contrast * (b_adjustment),				contrast * (b_adjustment),				contrast * (b_adjustment + saturation))
	set_brightness(brightness)

/datum/color_matrix/proc/set_brightness(brightness)
	if(isnull(brightness))
		return

	if(!matrix)
		reset()

	var/matrix_length = length(matrix)

	// Here we have CCM matrix of type:
	// | rr rg rb |
	// | gr gg gb |
	// | br bg bb |
	// with no brightness row, just append it.
	if(matrix_length == 9)
		matrix += list(brightness, brightness, brightness)
		return

	// Here we have CCM matrix of type:
	// | rr rg rb ra |
	// | gr gg gb ga |
	// | br bg bb ba |
	// | ar ag ab aa |
	// with no brightness row, just append it.
	if(matrix_length == 16)
		matrix += list(brightness, brightness, brightness, 0)
		return

	// We already have brightness row, just override.
	if(matrix_length == 12)
		for(var/i = matrix_length to matrix_length - 3 step -1)
			matrix[i] = brightness
		return

	// Just brightness matrix, override.
	if(matrix_length == 3)
		for(var/i = 1 to matrix_length)
			matrix[i] = brightness
		return

	CRASH("Couldn't figure out how to apply brightness to a matrix of length: [matrix_length]")

/// Handles values from 00 to FF.
/datum/color_matrix/proc/hex2value(hex)
	var/const/radix = 16
	var/num1 = text2num(hex[1], radix)
	var/num2 = text2num(hex[2], radix)

	if(!isnum(num1) || !isnum(num2))
		CRASH("Invalid hex value: [hex]")

	return num1 * radix + num2

/datum/color_matrix/proc/set_color(color_hex, contrast = 1, brightness = null)
	var/rr = hex2value(copytext(color_hex, 2, 4)) / 255
	var/gg = hex2value(copytext(color_hex, 4, 6)) / 255
	var/bb = hex2value(copytext(color_hex, 6, 8)) / 255

	rr = round(rr * 1000) / 1000 * contrast
	gg = round(gg * 1000) / 1000 * contrast
	bb = round(bb * 1000) / 1000 * contrast

	matrix = list(rr, gg, bb,
				rr, gg, bb,
				rr, gg, bb)

	set_brightness(brightness)

#undef LUM_R
#undef LUM_G
#undef LUM_B