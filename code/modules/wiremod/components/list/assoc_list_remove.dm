/**
 * # Associative List Remove Component
 *
 * Removes an element from an assoc list.
 */
/obj/item/circuit_component/variable/assoc_list/list_remove
	display_name = "Ассоциативный список — удалить"
	desc = "Удаляет ключ из ассоциативного списка переменных."
	category = "List"

	/// Key to remove to the list
	var/datum/port/input/to_remove

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/variable/assoc_list/list_remove/populate_ports()
	to_remove = add_input_port("Удалить", PORT_TYPE_STRING)

/obj/item/circuit_component/variable/assoc_list/list_remove/input_received(datum/port/input/port, list/return_values)
	if(!current_variable)
		return
	var/list/info = current_variable.value
	var/value_to_remove = to_remove.value

	info -= value_to_remove
