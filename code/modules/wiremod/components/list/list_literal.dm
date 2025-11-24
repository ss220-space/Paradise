/**
 * # List Literal Component
 *
 * Return a list literal.
 */
/obj/item/circuit_component/list_literal
	display_name = "Список — элемент"
	desc = "Компонент, который создает список на основе любых введённых вами данных."
	category = "List"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The list type
	var/datum/port/input/option/list_options

	/// The inputs used to create the list
	var/list/datum/port/input/entry_ports = list()
	/// The result from the output
	var/datum/port/output/list_output

	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove",
	)

	var/max_list_count = 100

/obj/item/circuit_component/list_literal/populate_options()
	list_options = add_option_port("Тип", GLOB.wiremod_basic_types)

/obj/item/circuit_component/list_literal/pre_input_received(datum/port/input/port)
	if(port != list_options)
		return

	var/new_datatype = list_options.value
	list_output.set_datatype(PORT_TYPE_LIST(new_datatype))

	for(var/datum/port/input/port_to_set as anything in entry_ports)
		port_to_set.set_datatype(new_datatype)

/obj/item/circuit_component/list_literal/populate_ports()
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = entry_ports, \
		add_action = "add", \
		remove_action = "remove", \
		port_type = PORT_TYPE_ANY, \
		prefix = "Ввод", \
		minimum_amount = 1, \
		maximum_amount = 20 \
	)
	list_output = add_output_port("Результат", PORT_TYPE_LIST(PORT_TYPE_ANY), order = 1.1)

/obj/item/circuit_component/list_literal/input_received(datum/port/input/port)
	var/list/new_literal = list()
	var/datum/circuit_datatype/handler = GLOB.circuit_datatypes[list_options.value]
	for(var/datum/port/input/entry_port as anything in entry_ports)
		var/value = entry_port.value
		// To prevent people from infinitely making lists to crash the server
		if(islist(value) && get_list_count(value, max_list_count) >= max_list_count)
			balloon_alert_to_viewers("начинает перегреваться!")
			return

		var/value_to_add = handler.convert_value(list_output, value)
		if(isdatum(value_to_add))
			value_to_add = WEAKREF(value_to_add)

		new_literal += list(value_to_add)

	list_output.set_output(new_literal)

