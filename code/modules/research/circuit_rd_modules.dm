/obj/item/circuit_component/rd_search
	display_name = "Интерфейс Поиска РНД"
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
	input_search = add_input_port("Поиск", PORT_TYPE_SIGNAL)

	output_found = add_output_port("Чертеж найден", PORT_TYPE_SIGNAL)
	output_error = add_output_port("Ошибка поиска", PORT_TYPE_SIGNAL)
	output_design = add_output_port("Выход чертежа", PORT_TYPE_DATUM)
	output_all_designs = add_output_port("Список доступных чертежей", PORT_TYPE_LIST(PORT_TYPE_STRING))

/obj/item/circuit_component/rd_search/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/rdconsole))
		attached_console = shell

/obj/item/circuit_component/rd_search/unregister_usb_parent(atom/movable/shell)
	attached_console = null
	return ..()

/obj/item/circuit_component/rd_search/input_received(datum/port/input/port)
	if(port == input_search)
		execute_search()

/obj/item/circuit_component/rd_search/trigger_component()
	if(!attached_console && loc && istype(loc, /obj/machinery/computer/rdconsole))
		attached_console = loc

	if(!attached_console)
		return ..()

	var/list/designs_list = attached_console.usb_get_all_designs()
	output_all_designs.set_output(designs_list)

	execute_search()
	return ..()

/obj/item/circuit_component/rd_search/proc/execute_search()
	if(!attached_console && loc && istype(loc, /obj/machinery/computer/rdconsole))
		attached_console = loc

	if(!attached_console)
		return

	output_design.set_output(null)
	output_found.set_output(FALSE)
	output_error.set_output(FALSE)

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

/obj/item/circuit_component/rd_lathe
	display_name = "Интерфейс Печати РНД"
	desc = "Модуль автоматической печати чертежей на подключенном оборудовании РНД."
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
	input_print = add_input_port("Печать", PORT_TYPE_SIGNAL)
	input_eject = add_input_port("Выброс", PORT_TYPE_SIGNAL)

	output_printed = add_output_port("Предмет распечатан", PORT_TYPE_SIGNAL)
	output_error = add_output_port("Ошибка печати", PORT_TYPE_SIGNAL)
	output_item = add_output_port("Предмет хранения", PORT_TYPE_DATUM)

/obj/item/circuit_component/rd_lathe/Destroy()
	if(attached_console)
		UnregisterSignal(attached_console, COMSIG_CIRCUIT_RND_PRINT_COMPLETE)
	attached_console = null
	return ..()

/obj/item/circuit_component/rd_lathe/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/rdconsole))
		attached_console = shell
		RegisterSignal(attached_console, COMSIG_CIRCUIT_RND_PRINT_COMPLETE, PROC_REF(on_print_finished))

/obj/item/circuit_component/rd_lathe/unregister_usb_parent(atom/movable/shell)
	if(attached_console)
		UnregisterSignal(attached_console, COMSIG_CIRCUIT_RND_PRINT_COMPLETE)
	attached_console = null
	return ..()

/obj/item/circuit_component/rd_lathe/input_received(datum/port/input/port)
	if(port == input_print)
		execute_print()
	if(port == input_eject)
		execute_eject()

/obj/item/circuit_component/rd_lathe/trigger_component()
	if(input_print.value)
		execute_print()
	if(input_eject.value)
		execute_eject()
	return ..()

/obj/item/circuit_component/rd_lathe/proc/execute_print()
	if(!attached_console && loc && istype(loc, /obj/machinery/computer/rdconsole))
		attached_console = loc

	if(!attached_console || QDELETED(attached_console) || held_item)
		output_error.set_output(TRUE)
		return

	var/datum/design/D = input_design.value
	if(!istype(D))
		output_error.set_output(TRUE)
		return

	var/obj/machinery/r_n_d/target_machine = attached_console.linked_lathe
	if(D.build_type & IMPRINTER)
		target_machine = attached_console.linked_imprinter

	if(!target_machine || QDELETED(target_machine) || target_machine.busy)
		output_error.set_output(TRUE)
		return

	last_printed_design = D

	var/mob/old_usr = usr
	usr = null

	var/print_success = attached_console.start_machine(target_machine, D.id, 1)

	usr = old_usr

	if(!print_success)
		output_error.set_output(TRUE)

// Внутренний чистый прок физического выброса предмета
/obj/item/circuit_component/rd_lathe/proc/execute_eject()
	if(!attached_console && loc && istype(loc, /obj/machinery/computer/rdconsole))
		attached_console = loc

	if(!attached_console || !held_item || held_item.loc != attached_console)
		held_item = null
		output_item.set_output(null)
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
	output_item.set_output(held_item)

	if(held_item)
		desc = "Production module. Stored item: [held_item.name]"

	output_printed.set_output(TRUE)

/obj/item/circuit_component/rd_destructor
	display_name = "Интерфейс Деконструктора РНД"
	desc = "Модуль автоматического разбора предметов для поднятия тех-уровней РНД."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL | CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/input_item
	var/datum/port/input/input_recycle

	var/datum/port/output/output_tech_up
	var/datum/port/output/output_error

	var/obj/machinery/computer/rdconsole/attached_console

/obj/item/circuit_component/rd_destructor/populate_ports()
	input_item = add_input_port("Предмет разбора", PORT_TYPE_DATUM)
	input_recycle = add_input_port("Разбор объекта", PORT_TYPE_SIGNAL)

	output_tech_up = add_output_port("Повышение технологий", PORT_TYPE_SIGNAL)
	output_error = add_output_port("Провал изучений", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/rd_destructor/Destroy()
	attached_console = null
	return ..()

/obj/item/circuit_component/rd_destructor/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/rdconsole))
		attached_console = shell

/obj/item/circuit_component/rd_destructor/unregister_usb_parent(atom/movable/shell)
	attached_console = null
	return ..()

/obj/item/circuit_component/rd_destructor/input_received(datum/port/input/port)
	if(port == input_recycle)
		execute_recycle()

/obj/item/circuit_component/rd_destructor/trigger_component()
	if(input_recycle.value)
		execute_recycle()
	return ..()

/obj/item/circuit_component/rd_destructor/proc/execute_recycle()
	if(!attached_console && loc && istype(loc, /obj/machinery/computer/rdconsole))
		attached_console = loc

	if(!attached_console || QDELETED(attached_console))
		output_error.set_output(TRUE)
		return

	if(!attached_console.linked_destroy || QDELETED(attached_console.linked_destroy))
		output_error.set_output(TRUE)
		return

	var/obj/item/I = input_item.value
	var/result = attached_console.usb_recycle_item(I)

	if(result == -1)
		output_error.set_output(TRUE)
		return

	if(result == TRUE)
		output_tech_up.set_output(TRUE)
	else
		output_error.set_output(TRUE)

	var/obj/item/circuit_component/rd_lathe/lathe = locate() in attached_console
	if(lathe)
		lathe.held_item = null
		if(lathe.output_item)
			lathe.output_item.set_output(null)
		lathe.desc = initial(lathe.desc)
