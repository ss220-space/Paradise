/obj/item/circuit_component/rd_search
	display_name = "Интерфейс поиска РНД"
	desc = "Модуль для удаленного поиска чертежей на консоли РНД через USB-соединение."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL | CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/input_id
	var/datum/port/input/input_search

	var/datum/port/output/output_found
	var/datum/port/output/output_error
	var/datum/port/output/output_design
	var/datum/port/output/output_all_designs

	var/obj/machinery/computer/rdconsole/attached_console

/obj/item/circuit_component/rd_search/populate_ports()
	input_id = add_input_port("ID Чертежа", PORT_TYPE_STRING)
	input_search = add_input_port("Поиск", PORT_TYPE_SIGNAL, trigger = PROC_REF(do_search))

	output_found = add_output_port("Чертеж найден", PORT_TYPE_SIGNAL)
	output_error = add_output_port("Ошибка поиска", PORT_TYPE_SIGNAL)
	output_design = add_output_port("Выход чертежа", PORT_TYPE_DATUM)
	output_all_designs = add_output_port("Список всех чертежей", PORT_TYPE_LIST(PORT_TYPE_STRING))

/obj/item/circuit_component/rd_search/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/rdconsole))
		attached_console = shell

/obj/item/circuit_component/rd_search/unregister_usb_parent(atom/movable/shell)
	attached_console = null
	return ..()

/obj/item/circuit_component/rd_search/proc/do_search(datum/port/input/port, list/return_values)
	if(!attached_console && loc && istype(loc, /obj/machinery/computer/rdconsole))
		attached_console = loc

	if(!attached_console)
		return

	var/search_id = input_id.value
	if(!search_id || search_id == "")
		output_error.set_output(TRUE)
		return

	var/datum/design/D = attached_console.usb_find_design(lowertext(search_id))
	if(D)
		output_design.set_output(D)
		output_found.set_output(TRUE)
	else
		output_error.set_output(TRUE)

/obj/item/circuit_component/rd_search/trigger_component()
	if(!attached_console && loc && istype(loc, /obj/machinery/computer/rdconsole))
		attached_console = loc

	if(!attached_console)
		return ..()

	var/list/designs_list = attached_console.usb_get_all_designs()
	output_all_designs.set_output(designs_list)
	return ..()
