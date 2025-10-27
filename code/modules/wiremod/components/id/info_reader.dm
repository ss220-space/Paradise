/obj/item/circuit_component/id_info_reader
	display_name = "Чтение ID"
	desc = "Компонент, который считывает имя, должность и возраст с ID-карты субъекта."
	category = "ID"

	/// The input port
	var/datum/port/input/target

	/// The name registered on the ID
	var/datum/port/output/name_port

	/// The rank registered on the ID
	var/datum/port/output/rank_port

	/// The age registered on the ID
	var/datum/port/output/age_port

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/max_range = 1

/obj/item/circuit_component/id_info_reader/get_ui_notices()
	. = ..()
	. += create_ui_notice("Максимальная дальность: [max_range] тайл[DECL_CREDIT(max_range)].", "orange", "info")

/obj/item/circuit_component/id_info_reader/populate_ports()
	target = add_input_port("Цель", PORT_TYPE_ATOM)
	name_port = add_output_port("Имя", PORT_TYPE_STRING)
	rank_port = add_output_port("Должность", PORT_TYPE_STRING)
	age_port = add_output_port("Возраст", PORT_TYPE_NUMBER)


/obj/item/circuit_component/id_info_reader/input_received(datum/port/input/port)
	var/obj/item/card/id/target_item = target.value
	var/turf/current_turf = get_location()
	var/turf/target_turf = get_turf(target_item)
	if(!istype(target_item) || get_dist(current_turf, target_turf) > max_range || current_turf.z != target_turf.z)
		name_port.set_output(null)
		rank_port.set_output(null)
		age_port.set_output(null)
		return
	name_port.set_output(target_item.registered_name)
	rank_port.set_output(target_item.assignment)
	age_port.set_output(target_item.age)
