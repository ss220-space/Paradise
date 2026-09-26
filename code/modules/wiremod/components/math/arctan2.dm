/**
 * # Arctangent 2 function
 * A variant of arctan. When given a deltaX and deltaY, returns the angle. I will blow you out of the sky
 */
/obj/item/circuit_component/arctan2
	display_name = "Арктангенс двух компонентов"
	desc = "Компонент арктангенса с двумя параметрами для расчёта любого нужного угла."
	category = "Math"

	/// The input port for the x-offset
	var/datum/port/input/input_port_x
	/// The input port for the y-offset
	var/datum/port/input/input_port_y

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/arctan2/Destroy()
	input_port_x = null
	input_port_y = null
	output = null
	. = ..()

/obj/item/circuit_component/arctan2/populate_ports()
	input_port_x = add_input_port("X", PORT_TYPE_NUMBER)
	input_port_y = add_input_port("Y", PORT_TYPE_NUMBER)
	output = add_output_port("Угол", PORT_TYPE_NUMBER)

/obj/item/circuit_component/arctan2/input_received(datum/port/input/port)
	output.set_output(arctan(input_port_x.value, input_port_y.value))
