/obj/item/circuit_component/rd_interface
	display_name = "Интерфейс R&D консоли"
	desc = "Позволяет удаленно искать шаблоны по техническому ID и отправлять их на печать по USB."
	category = "Машины"
	circuit_flags = 0

	var/datum/port/input/tech_id
	var/datum/port/input/search_trigger
	var/datum/port/input/print_trigger

	var/datum/port/output/found_signal
	var/datum/port/output/search_error_signal
	var/datum/port/output/printed_signal
	var/datum/port/output/print_error_signal

	var/obj/machinery/computer/rdconsole/attached_console

/obj/item/circuit_component/rd_interface/Destroy()
	if(attached_console)
		unregister_usb_parent(attached_console)
	attached_console = null
	return ..()

/obj/item/circuit_component/rd_interface/populate_ports()
	tech_id        = add_input_port("Технический ID предмета", PORT_TYPE_STRING)
	search_trigger = add_input_port("Вызов", PORT_TYPE_SIGNAL)
	print_trigger  = add_input_port("Печать", PORT_TYPE_SIGNAL)

	found_signal        = add_output_port("Предмет найден", PORT_TYPE_SIGNAL)
	search_error_signal = add_output_port("Ошибка поиска", PORT_TYPE_SIGNAL)
	printed_signal      = add_output_port("Предмет распечатан", PORT_TYPE_SIGNAL)
	print_error_signal  = add_output_port("Ошибка печати", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/rd_interface/get_ui_notices()
	. = ..()
	. += create_ui_notice("Подключено к R&D", "blue")

/obj/item/circuit_component/rd_interface/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/rdconsole))
		attached_console = shell

/obj/item/circuit_component/rd_interface/unregister_usb_parent(atom/movable/shell)
	attached_console = null
	return ..()

/obj/item/circuit_component/rd_interface/input_received(datum/port/input/port)
	if(!attached_console)
		return

	if(port == search_trigger)
		INVOKE_ASYNC(src, .proc/do_search)
		return

	if(port == print_trigger)
		INVOKE_ASYNC(src, .proc/do_print)
		return

/obj/item/circuit_component/rd_interface/proc/do_search()
	found_signal.set_output(FALSE)
	search_error_signal.set_output(FALSE)

	var/search_value = tech_id.value
	if(!search_value || search_value == "" || search_value == "null")
		search_error_signal.set_output(TRUE)
		return

	search_value = lowertext(search_value)
	var/datum/design/found_design = null

	if(attached_console.files && attached_console.files.known_designs)
		for(var/design_id in attached_console.files.known_designs)
			var/datum/design/check_d = attached_console.files.known_designs[design_id]
			if(check_d && (lowertext(check_d.id) == search_value || lowertext(check_d.name) == search_value))
				found_design = check_d
				break

	if(found_design)
		attached_console.saved_wire_design = found_design
		found_signal.set_output(TRUE)
	else
		attached_console.saved_wire_design = null
		search_error_signal.set_output(TRUE)

/obj/item/circuit_component/rd_interface/proc/do_print()
	printed_signal.set_output(FALSE)
	print_error_signal.set_output(FALSE)

	if(!attached_console.saved_wire_design)
		print_error_signal.set_output(TRUE)
		return

	var/datum/design/D = attached_console.saved_wire_design
	var/obj/machinery/r_n_d/protolathe/lathe = attached_console.linked_lathe
	if(D.build_type & IMPRINTER)
		lathe = attached_console.linked_imprinter

	if(!lathe || lathe.busy)
		print_error_signal.set_output(TRUE)
		return

	var/list/efficient_mats = list()
	for(var/MAT in D.materials)
		efficient_mats[MAT] = D.materials[MAT] * lathe.efficiency_coeff

	if(!lathe.materials.has_materials(efficient_mats, 1))
		print_error_signal.set_output(TRUE)
		return

	lathe.materials.use_amount(efficient_mats, 1)
	flick("[lathe.base_icon_state]_work", lathe)

	if(D.build_type & IMPRINTER)
		playsound(lathe.loc, 'sound/machines/rnd_machines/circuitprinter_print.ogg', 50, TRUE, -1)
	else
		playsound(lathe.loc, 'sound/machines/rnd_machines/lathe_print.ogg', 50, TRUE, -1)

	var/obj/new_item = new D.build_path(lathe.loc)
	if(isitem(new_item))
		var/obj/item/I = new_item
		I.update_materials_coeff(lathe.efficiency_coeff)

	printed_signal.set_output(TRUE)
