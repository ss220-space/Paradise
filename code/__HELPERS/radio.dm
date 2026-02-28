/// Ensure the frequency is within bounds of what it should be sending/receiving at
/proc/sanitize_frequency(frequency, low = PUBLIC_LOW_FREQ, high = PUBLIC_HIGH_FREQ)
	frequency = round(frequency)
	frequency = max(low, frequency)
	frequency = min(high, frequency)
	if((frequency % 2) == 0) //Ensure the last digit is an odd number
		frequency += 1
	return frequency

/// Format frequency by moving the decimal.
/proc/format_frequency(frequency)
	frequency = text2num(frequency)
	return "[round(frequency / 10)].[frequency % 10]"
