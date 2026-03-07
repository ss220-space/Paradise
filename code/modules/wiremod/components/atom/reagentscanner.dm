/**
 * # Reagents Scanner
 *
 * Returns the reagentss of an atom
 */
/obj/item/circuit_component/reagentscanner
	display_name = "Сканер веществ"
	desc = "Выводит список веществ, обнаруженных внутри контейнера."
	category = "Entity"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	// The entity to scan
	var/datum/port/input/input_port
	/// The result from the output
	var/datum/port/output/result

	var/max_range = 5

/obj/item/circuit_component/reagentscanner/Destroy()
	input_port = null
	result = null
	. = ..()

/obj/item/circuit_component/reagentscanner/get_ui_notices()
	. = ..()
	. += create_ui_notice("Максимальная дальность: [max_range] тайл[DECL_CREDIT(max_range)]", "orange", "info")
	. += create_table_notices(list(
		"reagent",
		"volume",
		))

/obj/item/circuit_component/reagentscanner/populate_ports()
	input_port = add_input_port("Объект", PORT_TYPE_ATOM)
	result = add_output_port("Вещества", PORT_TYPE_TABLE)

/obj/item/circuit_component/reagentscanner/input_received(datum/port/input/port)
	var/atom/entity = input_port.value
	var/turf/location = get_location()
	if(!istype(entity) || !IN_GIVEN_RANGE(location, entity, max_range))
		result.set_output(null)
		return
	var/list/new_table = list()
	for(var/datum/reagent/reagent as anything in entity.reagents?.reagent_list)
		var/list/entry = list()
		entry["reagent"] = reagent.name
		entry["volume"] = reagent.volume
		new_table += list(entry)
	result.set_output(new_table)
