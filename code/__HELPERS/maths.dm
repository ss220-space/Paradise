/// The quadratic formula. Returns a list with the solutions, or an empty list if they are imaginary.
/proc/SolveQuadratic(a, b, c)
	ASSERT(a)
	. = list()
	var/d = b*b - 4 * a * c
	var/bottom  = 2 * a
	if(d < 0 || !IS_FINITE__UNSAFE(d) || !IS_FINITE__UNSAFE(bottom))
		return
	var/root = sqrt(d)
	. += (-b + root) / bottom
	if(!d)
		return
	. += (-b - root) / bottom

/// Finds the shortest angle that angle A has to change to get to angle B. Aka, whether to move clock or counterclockwise.
/proc/closer_angle_difference(a, b)
	if(!isnum(a) || !isnum(b))
		return
	a = SIMPLIFY_DEGREES(a)
	b = SIMPLIFY_DEGREES(b)
	var/inc = b - a
	if(inc < 0)
		inc += 360
	var/dec = a - b
	if(dec < 0)
		dec += 360
	. = inc > dec? -dec : inc

#define ACCURACY 10000

/**
 * Converts a uniformly distributed random number into a normally distributed one using the Box-Muller transform
 * Since this method produces two random numbers, one is saved for subsequent calls (making the cost negligible for every second call)
 * This will return +/- decimals, situated about mean with standard deviation stddev
 * 68% chance that the number is within 1stddev
 * 95% chance that the number is within 2stddev
 * 98% chance that the number is within 3stddev...etc
 *
 * Arguments:
 * * mean - The mean (average) of the normal distribution
 * * stddev - The standard deviation of the normal distribution
 */
/proc/gaussian(mean, stddev)
	var/static/saved_gaussian_value
	var/first_random
	var/second_random
	var/calculated_value

	if(saved_gaussian_value != null)
		first_random = saved_gaussian_value
		saved_gaussian_value = null
	else
		do
			first_random = rand(-ACCURACY, ACCURACY) / ACCURACY
			second_random = rand(-ACCURACY, ACCURACY) / ACCURACY
			calculated_value = first_random * first_random + second_random * second_random
		while(calculated_value >= 1 || calculated_value == 0)

		calculated_value = sqrt(-2 * log(calculated_value) / calculated_value)
		first_random *= calculated_value
		saved_gaussian_value = second_random * calculated_value

	return (mean + stddev * first_random)

#undef ACCURACY

/proc/get_turf_in_angle(angle, turf/starting, increments = 1)
	var/pixel_x = 0
	var/pixel_y = 0
	for(var/i in 1 to increments)
		pixel_x += sin(angle)+(ICON_SIZE_X/2)*sin(angle)*2
		pixel_y += cos(angle)+(ICON_SIZE_Y/2)*cos(angle)*2
	var/new_x = starting.x
	var/new_y = starting.y
	while(pixel_x > (ICON_SIZE_X/2))
		pixel_x -= ICON_SIZE_X
		new_x++
	while(pixel_x < -(ICON_SIZE_X/2))
		pixel_x += ICON_SIZE_X
		new_x--
	while(pixel_y > (ICON_SIZE_Y/2))
		pixel_y -= ICON_SIZE_Y
		new_y++
	while(pixel_y < -(ICON_SIZE_Y/2))
		pixel_y += ICON_SIZE_Y
		new_y--
	new_x = clamp(new_x, 0, world.maxx)
	new_y = clamp(new_y, 0, world.maxy)
	return locate(new_x, new_y, starting.z)

/// Returns a list where [1] is all x values and [2] is all y values that overlap between the given pair of rectangles
/proc/get_overlap(x1, y1, x2, y2, x3, y3, x4, y4)
	var/list/region_x1 = list()
	var/list/region_y1 = list()
	var/list/region_x2 = list()
	var/list/region_y2 = list()

	// These loops create loops filled with x/y values that the boundaries inhabit
	// ex: list(5, 6, 7, 8, 9)
	for(var/i in min(x1, x2) to max(x1, x2))
		region_x1["[i]"] = TRUE
	for(var/i in min(y1, y2) to max(y1, y2))
		region_y1["[i]"] = TRUE
	for(var/i in min(x3, x4) to max(x3, x4))
		region_x2["[i]"] = TRUE
	for(var/i in min(y3, y4) to max(y3, y4))
		region_y2["[i]"] = TRUE

	return list(region_x1 & region_x2, region_y1 & region_y2)

/proc/RaiseToPower(num, power)
	if(!power)
		return 1
	return (power-- > 1 ? num * RaiseToPower(num, power) : num)

/**
 * Adjusts a value by a given amount while respecting specified bounds
 * Prevents inadvertently increasing the value in the wrong direction when at bounds
 *
 * Arguments:
 * * original_value - The initial value to adjust
 * * change_amount - The amount to add to the original value (can be positive or negative)
 * * lower_bound - The minimum allowed value
 * * upper_bound - The maximum allowed value
 */
/proc/directional_bounded_sum(original_value, change_amount, lower_bound, upper_bound)
	var/new_value = original_value + change_amount
	if(change_amount > 0)
		if(new_value > upper_bound)
			new_value = max(original_value, upper_bound)
	else if(change_amount < 0)
		if(new_value < lower_bound)
			new_value = min(original_value, lower_bound)
	return new_value

/// Calculates the square root of a number, returning 0 for negative inputs to avoid runtime errors
/proc/sqrtor0(input_number)
	if(input_number < 0)
		return 0
	return sqrt(input_number)

/// MARK: THIS DONT WORK!
/proc/round_down(num)
	if(round(num) != num)
		return round(num--)
	else
		return num

/// Calculate the angle between two movables and the west|east coordinate
/proc/get_angle(atom/movable/start, atom/movable/end)
	if(!start || !end)
		return 0
	var/dy = (ICON_SIZE_Y * end.y + end.pixel_y) - (ICON_SIZE_Y * start.y + start.pixel_y)
	var/dx = (ICON_SIZE_X * end.x + end.pixel_x) - (ICON_SIZE_X * start.x + start.pixel_x)
	return delta_to_angle(dx, dy)

/// Calculate the angle produced by a pair of x and y deltas
/proc/delta_to_angle(x, y)
	if(!y)
		return (x >= 0) ? 90 : 270
	. = arctan(x/y)
	if(y < 0)
		. += 180
	else if(x < 0)
		. += 360

/// Angle between two arbitrary points and horizontal line same as [/proc/get_angle]
/proc/get_angle_raw(start_x, start_y, start_pixel_x, start_pixel_y, end_x, end_y, end_pixel_x, end_pixel_y)
	var/dy = (ICON_SIZE_Y * end_y + end_pixel_y) - (ICON_SIZE_Y * start_y + start_pixel_y)
	var/dx = (ICON_SIZE_X * end_x + end_pixel_x) - (ICON_SIZE_X * start_x + start_pixel_x)
	if(!dy)
		return (dx >= 0) ? 90 : 270
	. = arctan(dx/dy)
	if(dy < 0)
		. += 180
	else if(dx < 0)
		. += 360

/// Get normalized angle (for fix rotation animation bug near 90 and -90 degrees)
/proc/normalize_angle(angle)
	while(angle > 90)
		angle -= 360
	while(angle < -90)
		angle += 360
	return angle

/**
 * Get a list of turfs in a line from `starting_atom` to `ending_atom`.
 *
 * Uses the ultra-fast [Bresenham Line-Drawing Algorithm](https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm).
 */
/proc/get_line(atom/starting_atom, atom/ending_atom)
	var/current_x_step = starting_atom.x//start at x and y, then add 1 or -1 to these to get every turf from starting_atom to ending_atom
	var/current_y_step = starting_atom.y
	var/starting_z = starting_atom.z

	var/list/line = list(get_turf(starting_atom))//get_turf(atom) is faster than locate(x, y, z)

	var/x_distance = ending_atom.x - current_x_step //x distance
	var/y_distance = ending_atom.y - current_y_step

	var/abs_x_distance = abs(x_distance)//Absolute value of x distance
	var/abs_y_distance = abs(y_distance)

	var/x_distance_sign = SIGN(x_distance) //Sign of x distance (+ or -)
	var/y_distance_sign = SIGN(y_distance)

	var/x = abs_x_distance >> 1 //Counters for steps taken, setting to distance/2
	var/y = abs_y_distance >> 1 //Bit-shifting makes me l33t.  It also makes get_line() unnecessarily fast.

	if(abs_x_distance >= abs_y_distance) //x distance is greater than y
		for(var/distance_counter in 0 to (abs_x_distance - 1))//It'll take abs_x_distance steps to get there
			y += abs_y_distance

			if(y >= abs_x_distance) //Every abs_y_distance steps, step once in y direction
				y -= abs_x_distance
				current_y_step += y_distance_sign

			current_x_step += x_distance_sign //Step on in x direction
			line += locate(current_x_step, current_y_step, starting_z)//Add the turf to the list
	else
		for(var/distance_counter in 0 to (abs_y_distance - 1))
			x += abs_x_distance

			if(x >= abs_y_distance)
				x -= abs_y_distance
				current_x_step += x_distance_sign

			current_y_step += y_distance_sign
			line += locate(current_x_step, current_y_step, starting_z)
	return line

/**
 * Formats a number into a list representing the si unit.
 * Access the coefficient with [SI_COEFFICIENT], and access the unit with [SI_UNIT].
 *
 * Supports SI exponents between 1e-15 to 1e15, but properly handles numbers outside that range as well.
 * Arguments:
 * * value - The number to convert to text. Can be positive or negative.
 * * unit - The base unit of the number, such as "Pa" or "W".
 * * maxdecimals - Maximum amount of decimals to display for the final number. Defaults to 1.
 * Returns: [SI_COEFFICIENT = si unit coefficient, SI_UNIT = prefixed si unit.]
 */
/proc/siunit_isolated(value, unit, maxdecimals = 1)
	var/static/list/prefixes = list("q","r","y","z","a","f","p","n","μ","m","","k","M","G","T","P","E","Z","Y","R","Q")

	// We don't have prefixes beyond this point
	// and this also captures value = 0 which you can't compute the logarithm for
	// and also byond numbers are floats and doesn't have much precision beyond this point anyway
	if(abs(value) < 1e-30)
		. = list(SI_COEFFICIENT = 0, SI_UNIT = " [unit]")
		return

	var/exponent = clamp(log(10, abs(value)), -30, 30) // Calculate the exponent and clamp it so we don't go outside the prefix list bounds
	var/divider = 10 ** (round(exponent / 3) * 3) // Rounds the exponent to nearest SI unit and power it back to the full form
	var/coefficient = round(value / divider, 10 ** -maxdecimals) // Calculate the coefficient and round it to desired decimals
	var/prefix_index = round(exponent / 3) + 11 // Calculate the index in the prefixes list for this exponent

	// An edge case which happens if we round 999.9 to 0 decimals for example, which gets rounded to 1000
	// In that case, we manually swap up to the next prefix if there is one available
	if(coefficient >= 1000 && prefix_index < 21)
		coefficient /= 1e3
		prefix_index++

	var/prefix = prefixes[prefix_index]
	. = list(SI_COEFFICIENT = coefficient, SI_UNIT = " [prefix][unit]")

/// Format an energy value in prefixed joules. DONT USE IT!
/proc/display_joules(units)
	return siunit(units, "J", 3)

/**
 * Format a power value in prefixed watts.
 * Converts from energy if convert is true.
 *
 * Arguments:
 * * power - The value of power to format.
 * * convert -  Whether to convert this from joules.
 * * datum/controller/subsystem/scheduler -  used in the conversion
 *
 * Returns - The string containing the formatted power.
 */
/proc/display_power(power, convert = TRUE, datum/controller/subsystem/scheduler = SSmachines)
	power = convert ? energy_to_power(power, scheduler) : power
	return siunit(power, "W", 3)

/**
 * Format an energy value in prefixed joules.
 *
 * Arguments:
 * * units - the value to convert
 */
/proc/display_energy(units)
	return siunit(units, "J", 3)

/**
 * Converts the joule to the watt, assuming SSmachines tick rate.
 *
 * Arguments:
 * * joules - the value in joules to convert
 * * datum/controller/subsystem/scheduler - the subsystem whos wait time is used in the conversion
 */
/proc/energy_to_power(joules, datum/controller/subsystem/scheduler = SSmachines)
	return joules * (1 SECONDS) / scheduler.wait

/**
 * Converts the watt to the joule, assuming SSmachines tick rate.
 *
 * Arguments:
 * * joules - the value in joules to convert
 * * datum/controller/subsystem/scheduler - the subsystem whos wait time is used in the conversion
 */
/proc/power_to_energy(watts, datum/controller/subsystem/scheduler = SSmachines)
	return watts * scheduler.wait / (1 SECONDS)

/**
 * Generates a bit triplet by selecting three unique numbers from 1 to 9 and setting corresponding bits
 * Returns a number with three bits set based on the selected numbers
 */
/proc/make_bit_triplet()
	var/list/available_numbers = list(1, 2, 3, 4, 5, 6, 7, 8, 9)
	var/bit_triplet_value = 0
	for(var/iteration = 0, iteration < 3, iteration++)
		var/selected_number = pick(available_numbers)
		available_numbers -= selected_number
		bit_triplet_value += (1 << selected_number)
	return bit_triplet_value

/**
 * Ensures a value is between a minimum and maximum, clamping it if necessary
 *
 * Arguments:
 * * low_bound - The minimum allowed value
 * * middle_value - The value to clamp
 * * high_bound - The maximum allowed value
 */
/proc/between(low_bound, middle_value, high_bound)
	return max(min(middle_value, high_bound), low_bound)

/**
 * Clamps a number to the specified range
 *
 * Arguments:
 * * low_bound - The minimum allowed value
 * * high_bound - The maximum allowed value
 * * input_number - The number to clamp
 */
/proc/dd_range(low_bound, high_bound, input_number)
	return max(low_bound, min(high_bound, input_number))
