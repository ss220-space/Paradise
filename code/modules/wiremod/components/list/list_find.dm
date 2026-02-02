/**
 * # List Find Component
 *
 * Finds an element in a list and returns the index.
 */
/obj/item/circuit_component/listin
	display_name = "Список — поиск элемента"
	desc = "Проверяет наличие элемента в списке и возвращает его индекс. \
			В случае возникновения ошибки индексу присваивается значение 0."
	category = "List"

	/// The list type we're checking
	var/datum/port/input/list_type

	/// List to check
	var/datum/port/input/list_to_check
	/// Element to check
	var/datum/port/input/to_check

	/// Signal to say we have found the element.
	var/datum/port/output/found
	/// Signal to say we haven't found the element.
	var/datum/port/output/not_found
	/// Result of the search
	var/datum/port/output/result
	/// Index of the element if found.
	var/datum/port/output/index

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

/obj/item/circuit_component/listin/populate_options()
	list_type = add_option_port("Тип", GLOB.wiremod_basic_types)

/obj/item/circuit_component/listin/populate_ports()
	list_to_check = add_input_port("Список", PORT_TYPE_LIST(PORT_TYPE_ANY))
	to_check = add_input_port("Элемент", PORT_TYPE_ANY)

	found = add_output_port("Успех", PORT_TYPE_SIGNAL)
	not_found = add_output_port("Провал", PORT_TYPE_SIGNAL)
	result = add_output_port("Результат", PORT_TYPE_NUMBER)
	index = add_output_port("Индекс", PORT_TYPE_NUMBER)

/obj/item/circuit_component/listin/pre_input_received(datum/port/input/port)
	. = ..()
	list_to_check.set_datatype(PORT_TYPE_LIST(list_type.value))
	to_check.set_datatype(list_type.value)

/obj/item/circuit_component/listin/input_received(datum/port/input/port, list/return_values)
	var/list/info = list_to_check.value
	if(!info)
		return

	var/data_to_check = to_check.value

	if(isdatum(data_to_check))
		data_to_check = WEAKREF(data_to_check)

	var/actual_result = info.Find(data_to_check)
	index.set_output(actual_result)
	if(actual_result)
		result.set_output(TRUE)
		found.set_output(COMPONENT_SIGNAL)
		return

	result.set_output(FALSE)
	not_found.set_output(COMPONENT_SIGNAL)

