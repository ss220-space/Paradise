/**
 * # Logic Component
 *
 * General logic unit with AND OR capabilities
 */
/obj/item/circuit_component/not
	display_name = "Отрицание"
	desc = "Компонент, который инвертирует значение входящего объекта."
	category = "Math"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/result
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/not/Destroy()
	input_port = null
	result = null
	. = ..()

/obj/item/circuit_component/not/populate_ports()
	input_port = add_input_port("Ввод", PORT_TYPE_ANY)

	result = add_output_port("Результат", PORT_TYPE_NUMBER)

/obj/item/circuit_component/not/input_received(datum/port/input/port)

	result.set_output(!input_port.value)

