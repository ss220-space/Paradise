/**
 * # Getter Component
 *
 * Gets the current value from a variable.
 */
/obj/item/circuit_component/variable/getter
	display_name = "Геттер переменной"
	desc = "Компонент, который получает глобальную переменную в схеме."

	/// The value of the variable
	var/datum/port/output/value
	should_listen = TRUE

/obj/item/circuit_component/variable/getter/Destroy()
	value = null
	. = ..()

/obj/item/circuit_component/variable/getter/populate_ports()
	value = add_output_port("Значение", PORT_TYPE_ANY)

/obj/item/circuit_component/variable/getter/pre_input_received(datum/port/input/port)
	. = ..()
	if(!current_variable)
		return

	value.set_datatype(current_variable.datatype)
	value.set_value(current_variable.value)
