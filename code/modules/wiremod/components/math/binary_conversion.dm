/**
 * # Binary Conversion Component
 *
 * Return an array of binary digits from a number input.
 */
/obj/item/circuit_component/binary_conversion
	display_name = "Двоичное преобразование"
	desc = "Разбивает десятичное число на массив двоичных цифр или битов, \
			представленных как 1 или 0 и часто используемых в логических или двоичных операциях, \
			таких как \"И\", \"ИЛИ\" и \"ИСКЛ. ИЛИ\"."
	category = "Math"

	/// One number
	var/datum/port/input/number

	/// Many binary digits
	var/list/datum/port/bit_array = list()

	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove",
	)


/obj/item/circuit_component/binary_conversion/populate_ports()
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = bit_array, \
		add_action = "add", \
		remove_action = "remove", \
		is_output = TRUE, \
		port_type = PORT_TYPE_NUMBER, \
		prefix = "Бит", \
		minimum_amount = 1, \
		maximum_amount = MAX_BITFIELD_SIZE \
	)
	number = add_input_port("Число", PORT_TYPE_NUMBER, order = 1.1)

/obj/item/circuit_component/binary_conversion/input_received(datum/port/input/port)
	if(!length(bit_array))
		return

	var/to_convert = number.value
	var/is_negative
	if(number.value < 0)
		is_negative = TRUE
		to_convert = -to_convert
	var/len = length(bit_array)
	for(var/iteration in 1 to len)
		var/datum/port/output/bit = bit_array[iteration]
		if(iteration == 1 && is_negative)
			bit.set_output(1)
			continue
		bit.set_output(!!(to_convert & (1<< (len - iteration))))
