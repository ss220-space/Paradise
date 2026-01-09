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
	return Turn(new_angle - old_angle) //BYOND handles cases such as -270, 360, 540 etc. DOES NOT HANDLE 180 TURNS WELL, THEY TWEEN AND LOOK LIKE SHIT

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

///Dumps the matrix data in format a-f
/matrix/proc/tolist()
	. = list()
	. += a
	. += b
	. += c
	. += d
	. += e
	. += f

/**
 * Dumps the matrix data in a matrix-grid format
 * a d 0
 * b e 0
 * c f 1
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

///The X pixel offset of this matrix
/matrix/proc/get_x_shift()
	. = c

///The Y pixel offset of this matrix
/matrix/proc/get_y_shift()
	. = f

///The angle of this matrix
/matrix/proc/get_angle()
	. = -ATAN2(a,d)

/**
 * Documenting a couple of potentially useful color matrices here to inspire ideas
 *
 * // Greyscale - indentical to saturation @ 0
 * list(LUMA_R,LUMA_R,LUMA_R,0, LUMA_G,LUMA_G,LUMA_G,0, LUMA_B,LUMA_B,LUMA_B,0, 0,0,0,1, 0,0,0,0)
 *
 * // Color inversion
 * list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0)
 *
 * // Sepiatone
 * list(0.393,0.349,0.272,0, 0.769,0.686,0.534,0, 0.189,0.168,0.131,0, 0,0,0,1, 0,0,0,0)
 *
 */
// MARK: COLOUR MATRICES
/// Changes distance hues have from grey while maintaining the overall lightness. Greys are unaffected.
/// 1 is identity, 0 is greyscale, >1 oversaturates colors
/proc/color_matrix_saturation(saturation_value)
	var/inverse_value = 1 - saturation_value
	var/red_component = round(LUMA_R * inverse_value, 0.001)
	var/green_component = round(LUMA_G * inverse_value, 0.001)
	var/blue_component = round(LUMA_B * inverse_value, 0.001)

	return list(
		red_component + saturation_value, red_component, red_component, 0,
		green_component, green_component + saturation_value, green_component, 0,
		blue_component, blue_component, blue_component + saturation_value, 0,
		0, 0, 0, 1,
		0, 0, 0, 0,
	)

/// Moves all colors angle degrees around the color wheel while maintaining intensity of the color and not affecting greys
/// 0 is identity, 120 moves reds to greens, 240 moves reds to blues
/proc/color_matrix_rotate_hue(rotation_angle)
	var/sine_value = sin(rotation_angle)
	var/cosine_value = cos(rotation_angle)
	var/cosine_inverse_third = 0.333 * (1 - cosine_value)
	var/sqrt3_times_sine = sqrt(3) * sine_value

	return list(
		round(cosine_value + cosine_inverse_third, 0.001),
		round(cosine_inverse_third + sqrt3_times_sine, 0.001),
		round(cosine_inverse_third - sqrt3_times_sine, 0.001),
		0,
		round(cosine_inverse_third - sqrt3_times_sine, 0.001),
		round(cosine_value + cosine_inverse_third, 0.001),
		round(cosine_inverse_third + sqrt3_times_sine, 0.001),
		0,
		round(cosine_inverse_third + sqrt3_times_sine, 0.001),
		round(cosine_inverse_third - sqrt3_times_sine, 0.001),
		round(cosine_value + cosine_inverse_third, 0.001),
		0,
		0, 0, 0, 1,
		0, 0, 0, 0
	)

// These next three rotate values about one axis only
// x is the red axis, y is the green axis, z is the blue axis.
/proc/color_matrix_rotate_x(rotation_angle)
	var/sine_value = round(sin(rotation_angle), 0.001)
	var/cosine_value = round(cos(rotation_angle), 0.001)
	return list(
		1, 0, 0, 0,
		0, cosine_value, sine_value, 0,
		0, -sine_value, cosine_value, 0,
		0, 0, 0, 1,
		0, 0, 0, 0,
	)

/proc/color_matrix_rotate_y(rotation_angle)
	var/sine_value = round(sin(rotation_angle), 0.001)
	var/cosine_value = round(cos(rotation_angle), 0.001)
	return list(
		cosine_value, 0, -sine_value, 0,
		0, 1, 0, 0,
		sine_value, 0, cosine_value, 0,
		0, 0, 0, 1,
		0, 0, 0, 0,
	)

/proc/color_matrix_rotate_z(rotation_angle)
	var/sine_value = round(sin(rotation_angle), 0.001)
	var/cosine_value = round(cos(rotation_angle), 0.001)
	return list(
		cosine_value, sine_value, 0, 0,
		-sine_value, cosine_value, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
		0, 0, 0, 0,
	)

/// Returns a matrix addition of first_matrix with second_matrix
/proc/color_matrix_add(list/first_matrix, list/second_matrix)
	if(!istype(first_matrix) || !istype(second_matrix))
		return COLOR_MATRIX_IDENTITY
	if(length(first_matrix) != 20 || length(second_matrix) != 20)
		return COLOR_MATRIX_IDENTITY
	var/list/output_matrix = list()
	output_matrix.len = 20
	for(var/index in 1 to 20)
		output_matrix[index] = first_matrix[index] + second_matrix[index]
	return output_matrix

/// Returns a matrix multiplication of first_matrix with second_matrix
/proc/color_matrix_multiply(list/first_matrix, list/second_matrix)
	if(!istype(first_matrix) || !istype(second_matrix))
		return COLOR_MATRIX_IDENTITY
	if(length(first_matrix) != 20 || length(second_matrix) != 20)
		return COLOR_MATRIX_IDENTITY
	var/list/output_matrix = list()
	output_matrix.len = 20
	var/column_index = 1
	var/row_index = 1
	var/row_offset = 0
	for(row_index in 1 to 5)
		row_offset = (row_index - 1) * 4
		for(column_index in 1 to 4)
			output_matrix[row_offset + column_index] = round( \
				first_matrix[row_offset + 1] * second_matrix[column_index] + \
				first_matrix[row_offset + 2] * second_matrix[column_index + 4] + \
				first_matrix[row_offset + 3] * second_matrix[column_index + 8] + \
				first_matrix[row_offset + 4] * second_matrix[column_index + 12] + \
				(row_index == 5 ? second_matrix[column_index + 16] : 0), \
				0.001, \
			)
	return output_matrix

/**
 * Converts RGB shorthands into RGBA matrices complete of constants rows (ergo a 20 keys list in byond).
 * if return_identity_on_fail is true, stack_trace is called instead of CRASH, and an identity is returned.
 */
/proc/color_to_full_rgba_matrix(color_input, return_identity_on_fail = TRUE)
	if(!color_input)
		return COLOR_MATRIX_IDENTITY
	if(istext(color_input))
		var/list/color_components = rgb2num(color_input)
		if(!color_components)
			var/error_message = "Invalid/unsupported color ([color_input]) argument in color_to_full_rgba_matrix()"
			if(return_identity_on_fail)
				stack_trace(error_message)
				return COLOR_MATRIX_IDENTITY
			CRASH(error_message)
		return list(
			color_components[1] / 255, 0, 0, 0,
			0, color_components[2] / 255, 0, 0,
			0, 0, color_components[3] / 255, 0,
			0, 0, 0, length(color_components) > 3 ? color_components[4] / 255 : 1,
			0, 0, 0, 0,
		)
	if(!islist(color_input)) // invalid format
		CRASH("Invalid/unsupported color ([color_input]) argument in color_to_full_rgba_matrix()")
	var/list/input_components = color_input
	switch(length(input_components))
		if(3 to 5) // row-by-row hexadecimals
			. = list()
			for(var/element_index in 1 to length(input_components))
				var/list/rgb_values = rgb2num(input_components[element_index])
				for(var/channel_value in rgb_values)
					. += channel_value / 255
				if(length(rgb_values) % 4) // RGB has no alpha instruction
					. += element_index != 4 ? 0 : 1
			if(length(input_components) < 4) // missing both alphas and constants rows
				. += list(0, 0, 0, 1, 0, 0, 0, 0)
			else if(length(input_components) < 5) // missing constants row
				. += list(0, 0, 0, 0)
		if(9 to 12) // RGB
			. = list(
				input_components[1], input_components[2], input_components[3], 0,
				input_components[4], input_components[5], input_components[6], 0,
				input_components[7], input_components[8], input_components[9], 0,
				0, 0, 0, 1,
			)
			for(var/constant_index in 1 to 3) // missing constants row
				. += length(input_components) < 9 + constant_index ? 0 : input_components[9 + constant_index]
			. += 0
		if(16 to 20) // RGBA
			. = input_components.Copy()
			if(length(input_components) < 20) // missing constants row
				for(var/missing_component_index in 1 to 20 - length(input_components))
					. += 0
		else
			var/error_message = "Invalid/unsupported color (list of length [length(input_components)]) argument in color_to_full_rgba_matrix()"
			if(return_identity_on_fail)
				stack_trace(error_message)
				return COLOR_MATRIX_IDENTITY
			CRASH(error_message)
