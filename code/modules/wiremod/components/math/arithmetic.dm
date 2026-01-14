#define COMP_ARITHMETIC_ADD "Сложение"
#define COMP_ARITHMETIC_SUBTRACT "Вычитание"
#define COMP_ARITHMETIC_MULTIPLY "Умножение"
#define COMP_ARITHMETIC_DIVIDE "Деление"
#define COMP_ARITHMETIC_MODULO "Деление по модулю"
#define COMP_ARITHMETIC_MIN "Минимум"
#define COMP_ARITHMETIC_MAX "Максимум"
#define COMP_ARITHMETIC_EXPONENTIATION "Возведение в степень"

/**
 * # Arithmetic Component
 *
 * General arithmetic unit with add/sub/mult/divide capabilities
 * This one only works with numbers.
 */
/obj/item/circuit_component/arithmetic
	display_name = "Арифметика"
	desc = "Компонент с возможностями общих арифметических операций."
	category = "Math"

	var/datum/port/input/option/arithmetic_option

	/// The result from the output
	var/datum/port/output/output

	var/list/arithmetic_ports
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL
	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove",
	)

/obj/item/circuit_component/arithmetic/populate_options()
	var/static/component_options = list(
		COMP_ARITHMETIC_ADD,
		COMP_ARITHMETIC_SUBTRACT,
		COMP_ARITHMETIC_MULTIPLY,
		COMP_ARITHMETIC_DIVIDE,
		COMP_ARITHMETIC_MODULO,
		COMP_ARITHMETIC_MIN,
		COMP_ARITHMETIC_MAX,
		COMP_ARITHMETIC_EXPONENTIATION,
	)
	arithmetic_option = add_option_port("Параметр", component_options)

/obj/item/circuit_component/arithmetic/populate_ports()
	arithmetic_ports = list()
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = arithmetic_ports, \
		add_action = "add", \
		remove_action = "remove", \
		port_type = PORT_TYPE_NUMBER, \
		prefix = "Число", \
		minimum_amount = 2 \
	)
	output = add_output_port("Результат", PORT_TYPE_NUMBER, order = 1.1)

/obj/item/circuit_component/arithmetic/input_received(datum/port/input/port)
	var/list/ports = arithmetic_ports.Copy()
	var/datum/port/input/first_port = popleft(ports)
	var/result = first_port.value

	for(var/datum/port/input/input_port as anything in ports)
		var/value = input_port.value
		if(isnull(value))
			continue

		switch(arithmetic_option.value)
			if(COMP_ARITHMETIC_ADD)
				result += value

			if(COMP_ARITHMETIC_SUBTRACT)
				result -= value

			if(COMP_ARITHMETIC_MULTIPLY)
				result *= value

			if(COMP_ARITHMETIC_DIVIDE)
				// Protect from div by zero errors.
				if(value == 0)
					result = null
					break

				result /= value

			if(COMP_ARITHMETIC_MODULO)
				result %= value

			if(COMP_ARITHMETIC_MAX)
				result = max(result, value)

			if(COMP_ARITHMETIC_MIN)
				result = min(result, value)

			if(COMP_ARITHMETIC_EXPONENTIATION)
				result = result ** value

	output.set_output(result)

#undef COMP_ARITHMETIC_ADD
#undef COMP_ARITHMETIC_SUBTRACT
#undef COMP_ARITHMETIC_MULTIPLY
#undef COMP_ARITHMETIC_DIVIDE
#undef COMP_ARITHMETIC_MODULO
#undef COMP_ARITHMETIC_MIN
#undef COMP_ARITHMETIC_MAX
#undef COMP_ARITHMETIC_EXPONENTIATION
