/obj/item/circuit_component/rd_base
	abstract_type = /obj/item/circuit_component/rd_base
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL | CIRCUIT_FLAG_OUTPUT_SIGNAL
	var/obj/machinery/computer/rdconsole/attached_console

/obj/item/circuit_component/rd_base/Destroy()
	disconnect_console()
	return ..()

/obj/item/circuit_component/rd_base/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/rdconsole))
		connect_console(shell)

/obj/item/circuit_component/rd_base/unregister_usb_parent(atom/movable/shell)
	disconnect_console()
	return ..()

/obj/item/circuit_component/rd_base/input_received(datum/port/input/port)
	return

/obj/item/circuit_component/rd_base/proc/connect_console(obj/machinery/computer/rdconsole/console)
	disconnect_console()
	attached_console = console

/obj/item/circuit_component/rd_base/proc/disconnect_console()
	attached_console = null

/obj/item/circuit_component/rd_base/proc/ensure_console()
	if(!attached_console && istype(loc, /obj/machinery/computer/rdconsole))
		connect_console(loc)
	return !QDELETED(attached_console)

/obj/item/circuit_component/rd_search
	parent_type = /obj/item/circuit_component/rd_base
	display_name = "Интерфейс Поиска НИО"
	desc = "Модуль для удаленного поиска чертежей на консоли НИО через USB-соединение."

	var/datum/port/input/input_id
	var/datum/port/input/input_search

	var/datum/port/output/output_found
	var/datum/port/output/output_error
	var/datum/port/output/output_design
	var/datum/port/output/output_all_designs
	var/datum/port/output/output_named_designs

/obj/item/circuit_component/rd_search/populate_ports()
	input_id = add_input_port("ID Чертежа", PORT_TYPE_STRING)
	input_search = add_input_port("Поиск", PORT_TYPE_SIGNAL)

	output_found = add_output_port("Чертеж найден", PORT_TYPE_SIGNAL)
	output_error = add_output_port("Ошибка поиска", PORT_TYPE_SIGNAL)
	output_design = add_output_port("Выход чертежа", PORT_TYPE_DATUM)
	output_all_designs = add_output_port("Список доступных ID чертежей", PORT_TYPE_LIST(PORT_TYPE_STRING))
	output_named_designs = add_output_port("Список названий чертежей", PORT_TYPE_LIST(PORT_TYPE_STRING))

/obj/item/circuit_component/rd_search/trigger_component()
	if(!ensure_console())
		return ..()

	var/list/designs_data = attached_console.usb_get_all_designs()
	output_all_designs.set_output(designs_data["ids"])
	output_named_designs.set_output(designs_data["named"])

	if(input_search.value)
		input_search.value = null
		execute_search()

	return ..()

/obj/item/circuit_component/rd_search/proc/execute_search()
	output_design.set_output(null)
	output_found.set_output(null)
	output_error.set_output(null)

	if(!ensure_console())
		output_error.set_output(COMPONENT_SIGNAL)
		return

	var/search_query = input_id.value
	if(!search_query)
		output_error.set_output(COMPONENT_SIGNAL)
		return

	var/datum/design/found_design = attached_console.usb_find_design(search_query)
	if(found_design)
		output_design.set_output(found_design)
		output_found.set_output(COMPONENT_SIGNAL)
	else
		output_error.set_output(COMPONENT_SIGNAL)
/obj/item/circuit_component/rd_lathe
	parent_type = /obj/item/circuit_component/rd_base
	display_name = "Интерфейс Печати НИО"
	desc = "Модуль автоматической печати чертежей на подключенном оборудовании НИО."

	var/datum/port/input/input_design
	var/datum/port/input/input_print
	var/datum/port/input/input_eject

	var/datum/port/output/output_printed
	var/datum/port/output/output_error
	var/datum/port/output/output_item

	var/obj/item/held_item
	var/datum/design/last_printed_design

/obj/item/circuit_component/rd_lathe/populate_ports()
	input_design = add_input_port("Вход чертежа", PORT_TYPE_DATUM)
	input_print = add_input_port("Печать", PORT_TYPE_SIGNAL)
	input_eject = add_input_port("Выброс", PORT_TYPE_SIGNAL)

	output_printed = add_output_port("Предмет распечатан", PORT_TYPE_SIGNAL)
	output_error = add_output_port("Ошибка печати", PORT_TYPE_SIGNAL)
	output_item = add_output_port("Предмет хранения", PORT_TYPE_DATUM)

/obj/item/circuit_component/rd_lathe/Destroy()
	held_item = null
	last_printed_design = null
	return ..()

/obj/item/circuit_component/rd_lathe/connect_console(obj/machinery/computer/rdconsole/console)
	. = ..()
	if(attached_console)
		RegisterSignal(attached_console, COMSIG_CIRCUIT_RND_PRINT_COMPLETE, PROC_REF(on_print_finished))

/obj/item/circuit_component/rd_lathe/disconnect_console()
	if(attached_console)
		UnregisterSignal(attached_console, COMSIG_CIRCUIT_RND_PRINT_COMPLETE)
	return ..()

/obj/item/circuit_component/rd_lathe/trigger_component()
	if(input_print.value)
		input_print.value = null
		execute_print()

	if(input_eject.value)
		input_eject.value = null
		execute_eject()

	return ..()

/obj/item/circuit_component/rd_lathe/proc/eject_held_item()
	if(!held_item)
		return FALSE

	if(!QDELETED(held_item) && attached_console && held_item.loc == attached_console)
		var/obj/machinery/r_n_d/target_machine = attached_console.linked_lathe
		if(last_printed_design && (last_printed_design.build_type & IMPRINTER))
			target_machine = attached_console.linked_imprinter
		var/atom/drop_location = target_machine ? target_machine.loc : attached_console.loc
		held_item.forceMove(drop_location)

	held_item = null
	output_item.set_output(null)
	desc = initial(desc)
	return TRUE

/obj/item/circuit_component/rd_lathe/proc/execute_print()
	output_printed.set_output(null)
	output_error.set_output(null)

	if(!ensure_console())
		output_error.set_output(COMPONENT_SIGNAL)
		return

	eject_held_item()

	var/datum/design/target_design = input_design.value
	if(!istype(target_design))
		output_error.set_output(COMPONENT_SIGNAL)
		return

	var/obj/machinery/r_n_d/target_machine = attached_console.linked_lathe
	if(target_design.build_type & IMPRINTER)
		target_machine = attached_console.linked_imprinter

	if(QDELETED(target_machine) || target_machine.busy)
		output_error.set_output(COMPONENT_SIGNAL)
		return

	last_printed_design = target_design
	if(!attached_console.start_machine(target_machine, target_design.id, 1, null) && !target_machine.busy)
		output_error.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/rd_lathe/proc/execute_eject()
	output_error.set_output(null)

	if(!ensure_console() || !eject_held_item())
		output_error.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/rd_lathe/proc/on_print_finished(datum/source, obj/item/printed_result)
	SIGNAL_HANDLER
	if(!printed_result)
		output_error.set_output(COMPONENT_SIGNAL)
		return

	held_item = printed_result
	output_item.set_output(held_item)
	desc = "Модуль печати. Хранящийся предмет: [held_item.name]"
	output_printed.set_output(COMPONENT_SIGNAL)
/obj/item/circuit_component/rd_destructor
	parent_type = /obj/item/circuit_component/rd_base
	display_name = "Интерфейс Деконструктора НИО"
	desc = "Модуль автоматической разборки предметов, повышающий уровень технологий НИО."

	var/datum/port/input/input_item
	var/datum/port/input/input_recycle

	var/datum/port/output/output_tech_up
	var/datum/port/output/output_error
	var/datum/port/output/output_item_inserted

/obj/item/circuit_component/rd_destructor/populate_ports()
	input_item = add_input_port("Предмет разбора", PORT_TYPE_DATUM)
	input_recycle = add_input_port("Разбор объекта", PORT_TYPE_SIGNAL)

	output_tech_up = add_output_port("Повышение технологий", PORT_TYPE_SIGNAL)
	output_error = add_output_port("Провал изучений", PORT_TYPE_SIGNAL)
	output_item_inserted = add_output_port("Предмет загружен", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/rd_destructor/connect_console(obj/machinery/computer/rdconsole/console)
	. = ..()
	if(attached_console?.linked_destroy)
		RegisterSignal(attached_console.linked_destroy, COMSIG_ATOM_ENTERED, PROC_REF(on_destroyer_entered))

/obj/item/circuit_component/rd_destructor/disconnect_console()
	if(attached_console?.linked_destroy)
		UnregisterSignal(attached_console.linked_destroy, COMSIG_ATOM_ENTERED)
	return ..()

/obj/item/circuit_component/rd_destructor/trigger_component()
	if(input_recycle.value)
		input_recycle.value = null
		execute_recycle()

	return ..()

/obj/item/circuit_component/rd_destructor/proc/execute_recycle()
	output_tech_up.set_output(null)
	output_error.set_output(null)

	if(!ensure_console())
		output_error.set_output(COMPONENT_SIGNAL)
		return

	var/obj/item/item_to_recycle = input_item.value
	if(QDELETED(item_to_recycle))
		item_to_recycle = null

	var/result = attached_console.usb_recycle_item(item_to_recycle)
	if(result)
		output_tech_up.set_output(COMPONENT_SIGNAL)
	else
		output_error.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/rd_destructor/proc/on_destroyer_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(!isitem(arrived))
		return
	if(!attached_console?.linked_destroy)
		return
	if(attached_console.linked_destroy.busy && attached_console.linked_destroy.loaded_item)
		return
	addtimer(CALLBACK(src, PROC_REF(trigger_item_inserted), arrived), 1.1 SECONDS)

/obj/item/circuit_component/rd_destructor/proc/trigger_item_inserted(obj/item/arrived)
	if(QDELETED(arrived) || !attached_console?.linked_destroy)
		return
	if(attached_console.linked_destroy.loaded_item != arrived || attached_console.linked_destroy.busy)
		return
	output_item_inserted.set_output(COMPONENT_SIGNAL)
