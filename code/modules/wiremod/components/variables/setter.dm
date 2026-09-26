/**
 * # Setter Component
 *
 * Stores the current input when triggered into a variable.
 */
/obj/item/circuit_component/variable/setter
	display_name = "Сеттер переменной"
	desc = "Компонент, который задаёт переменную глобально в схеме."

	/// The input to store
	var/datum/port/input/input_port

/obj/item/circuit_component/variable/setter/Destroy()
	input_port = null
	. = ..()

/obj/item/circuit_component/variable/setter/trigger
	display_name = "Установщик переменной вызова"
	desc = "Компонент, который задаёт переменную глобально в схеме. \
			Требует входные сигналы и обеспечивает выходной сигнал."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/variable/setter/get_variable_list(obj/item/integrated_circuit/integrated_circuit)
	return integrated_circuit.modifiable_circuit_variables

/obj/item/circuit_component/variable/setter/populate_ports()
	input_port = add_input_port("Ввод", PORT_TYPE_ANY)

/obj/item/circuit_component/variable/setter/pre_input_received(datum/port/input/port)
	. = ..()
	if(port != variable_name)
		return

	input_port.set_datatype(current_variable.datatype)

/obj/item/circuit_component/variable/setter/input_received(datum/port/input/port)
	if(!current_variable)
		return

	current_variable.set_value(input_port.value)

