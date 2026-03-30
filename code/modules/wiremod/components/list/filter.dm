/**
 * # For Each Component
 *
 * Filters
 */
/obj/item/circuit_component/filter_list
	display_name = "Фильтр"
	desc = "Компонент, который просматривает элементы списка и фильтрует их."
	category = "List"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_INSTANT

	/// The list type
	var/datum/port/input/option/list_options

	/// Adds the list to the result
	var/datum/port/input/accept_entry
	/// The list to filter over
	var/datum/port/input/list_to_filter

	/// The current element from the list
	var/datum/port/output/element
	/// The current index from the list
	var/datum/port/output/current_index
	/// A signal that is sent when the list has moved onto the next index.
	var/datum/port/output/on_next_index
	/// The finished list
	var/datum/port/output/finished_list
	/// A signal that is sent when the filtering has finished
	var/datum/port/output/on_finished
	/// A signal that is sent when the filtering has failed
	var/datum/port/output/on_failed

	ui_buttons = list(
		"plus" = "increase",
	)

	/// The limit of iterations before it breaks. Used to prevent from someone iterating a massive list constantly
	var/limit = 300

/obj/item/circuit_component/filter_list/Destroy()
	list_options = null
	accept_entry = null
	list_to_filter = null
	element = null
	current_index = null
	on_next_index = null
	finished_list = null
	on_finished = null
	on_failed = null
	. = ..()

/obj/item/circuit_component/filter_list/populate_options()
	list_options = add_option_port("Тип", GLOB.wiremod_basic_types)

/obj/item/circuit_component/filter_list/pre_input_received(datum/port/input/port)
	if(port != list_options)
		return

	var/new_datatype = list_options.value
	list_to_filter.set_datatype(PORT_TYPE_LIST(new_datatype))
	finished_list.set_datatype(PORT_TYPE_LIST(new_datatype))
	element.set_datatype(new_datatype)

/obj/item/circuit_component/filter_list/populate_ports()
	list_to_filter = add_input_port("Ввод", PORT_TYPE_LIST(PORT_TYPE_ANY))
	accept_entry = add_input_port("Принять запись", PORT_TYPE_SIGNAL, trigger = PROC_REF(accept_entry_port))

	finished_list = add_output_port("Результат", PORT_TYPE_LIST(PORT_TYPE_ANY))
	element = add_output_port("Элемент", PORT_TYPE_ANY)
	current_index = add_output_port("Индекс", PORT_TYPE_NUMBER)
	on_next_index = add_output_port("Следующий индекс", PORT_TYPE_SIGNAL)
	on_finished = add_output_port("По завершении", PORT_TYPE_SIGNAL)
	on_failed = add_output_port("Провал", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/filter_list/proc/accept_entry_port(datum/port/input/port, list/return_values)
	CIRCUIT_TRIGGER
	if(!return_values)
		return

	return_values["accept_entry"] = TRUE

/obj/item/circuit_component/filter_list/input_received(datum/port/input/port)
	var/index = 1
	var/list/filtered_list = list()
	for(var/element_in_list in list_to_filter.value)
		if(index > limit && !parent.admin_only)
			break

		SScircuit_component.queue_instant_run()
		element.set_output(element_in_list)
		current_index.set_output(index)
		on_next_index.set_output(COMPONENT_SIGNAL)
		index += 1
		var/list/result = SScircuit_component.execute_instant_run()
		if(LAZYACCESS(result, "accept_entry"))
			filtered_list += list(element_in_list)
			continue

		balloon_alert_to_viewers("начинает перегреваться!")
		on_failed.set_output(COMPONENT_SIGNAL)
		return


	finished_list.set_output(filtered_list)
	on_finished.set_output(COMPONENT_SIGNAL)

