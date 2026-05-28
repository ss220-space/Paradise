/**
 * #To Number Component
 *
 * Converts a string into a Number
 */
/obj/item/circuit_component/tonumber
	display_name = "В число"
	desc = "Компонент, преобразующий входные данные в число. \
			Если входные данные содержат текст, он учитывает его только в том случае, если он начинается с цифры. \
			Компонент принимает это число и игнорирует всё остальное."
	category = "String"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/tonumber/Destroy()
	input_port = null
	output = null
	. = ..()

/obj/item/circuit_component/tonumber/populate_ports()
	input_port = add_input_port("Ввод", PORT_TYPE_STRING)
	output = add_output_port("Результат", PORT_TYPE_NUMBER)

/obj/item/circuit_component/tonumber/input_received(datum/port/input/port)
	output.set_output(text2num(input_port.value))
