/**
 * # Concatenate Component
 *
 * General string concatenation component. Puts strings together.
 */
/obj/item/circuit_component/concat
	display_name = "Объединить"
	desc = "Компонент, объединяющий строки."
	category = "String"

	var/list/datum/port/input/concat_ports = list()

	/// The result from the output
	var/datum/port/output/output
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove",
	)

/obj/item/circuit_component/concat/Destroy()
	LAZYCLEARLIST(concat_ports)
	output = null
	. = ..()

/obj/item/circuit_component/concat/populate_ports()
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = concat_ports, \
		add_action = "add", \
		remove_action = "remove", \
		port_type = PORT_TYPE_STRING, \
		prefix = "Строка", \
		minimum_amount = 2 \
	)

	output = add_output_port("Результат", PORT_TYPE_STRING, order = 1.1)

/obj/item/circuit_component/concat/input_received(datum/port/input/port)

	var/result = ""
	for(var/datum/port/input/input_port as anything in concat_ports)
		var/value = input_port.value
		if(isnull(value))
			continue

		result += "[value]"

	output.set_output(result)

