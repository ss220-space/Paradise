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

/obj/item/circuit_component/rd_lathe
	display_name = "Интерфейс печати НИО"
	desc = "Модуль автоматической печати чертежей на подключенном оборудовании НИО."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL | CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/input_design
	var/datum/port/input/input_print
	var/datum/port/input/input_eject

	var/datum/port/output/output_printed
	var/datum/port/output/output_error
	var/datum/port/output/output_item

	var/obj/machinery/computer/rdconsole/attached_console
	var/obj/item/held_item = null
	var/datum/design/last_printed_design = null

/obj/item/circuit_component/rd_lathe/populate_ports()
	input_design = add_input_port("Вход чертежа", PORT_TYPE_DATUM)
	input_print = add_input_port("Печать", PORT_TYPE_SIGNAL, trigger = PROC_REF(do_print))
	input_eject = add_input_port("Выброс", PORT_TYPE_SIGNAL, trigger = PROC_REF(do_eject))

	output_printed = add_output_port("Предмет распечатан", PORT_TYPE_SIGNAL)
	output_error = add_output_port("Ошибка печати", PORT_TYPE_SIGNAL)
	output_item = add_output_port("Хранящийся предмет", PORT_TYPE_DATUM)

/obj/item/circuit_component/rd_lathe/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/rdconsole))
		attached_console = shell
		RegisterSignal(attached_console, "usb_print_complete", PROC_REF(on_print_finished))

/obj/item/circuit_component/rd_lathe/unregister_usb_parent(atom/movable/shell)
	if(attached_console)
		UnregisterSignal(attached_console, "usb_print_complete")
	attached_console = null
	return ..()

/obj/item/circuit_component/rd_lathe/proc/do_print(datum/port/input/port, list/return_values)
	if(!attached_console && loc && istype(loc, /obj/machinery/computer/rdconsole))
		attached_console = loc

	if(!attached_console || held_item)
		output_error.set_output(TRUE)
		return

	var/datum/design/D = input_design.value
	if(!istype(D))
		output_error.set_output(TRUE)
		return

	last_printed_design = D

	var/obj/machinery/r_n_d/target_machine = attached_console.linked_lathe
	if(D.build_type & IMPRINTER)
		target_machine = attached_console.linked_imprinter

	var/mob/old_usr = usr
	usr = null

	var/print_success = attached_console.start_machine(target_machine, D.id, 1)

	usr = old_usr

	if(!print_success)
		output_error.set_output(TRUE)

/obj/item/circuit_component/rd_lathe/proc/do_eject(datum/port/input/port, list/return_values)
	if(!attached_console && loc && istype(loc, /obj/machinery/computer/rdconsole))
		attached_console = loc

	if(!attached_console || !held_item || held_item.loc != attached_console)
		held_item = null
		output_item.set_output(null)
		desc = initial(desc)
		output_error.set_output(TRUE)
		return

	var/obj/machinery/r_n_d/target_machine = attached_console.linked_lathe
	if(last_printed_design && (last_printed_design.build_type & IMPRINTER))
		target_machine = attached_console.linked_imprinter

	if(target_machine)
		held_item.forceMove(target_machine.loc)
	else
		held_item.forceMove(attached_console.loc)

	held_item = null
	output_item.set_output(null)
	desc = initial(desc)

/obj/item/circuit_component/rd_lathe/proc/on_print_finished(datum/source, obj/item/printed_result)
	SIGNAL_HANDLER
	if(!printed_result)
		output_error.set_output(TRUE)
		return

	held_item = printed_result
	// Передаем чистый физический объект. Движок Wiremod сам заглянет внутрь предмета
	// и напишет в тултипе его настоящее имя (например, Скальпель или toner cartridge) вместо entity/null!
	output_item.set_output(held_item)
	output_printed.set_output(TRUE)

