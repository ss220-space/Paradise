#define LOG_ERROR(list, error) if(list) { list.Add(error) }

// Determines if a port can have a predefined input value if it is of this type.
GLOBAL_LIST_INIT(circuit_dupe_whitelisted_types, list(
	PORT_TYPE_NUMBER,
	PORT_TYPE_STRING,
	PORT_TYPE_ANY,
	PORT_TYPE_OPTION,
))

/// Loads a circuit based on json data at a location. Can also load usb connections, such as arrest consoles.
/obj/item/integrated_circuit/proc/load_circuit_data(json_data, list/errors)
	var/list/general_data = json_decode(json_data)

	if(!general_data)
		LOG_ERROR(errors, "Invalid json format!")
		return

	load_variables(general_data["variables"])

	admin_only = general_data["admin_only"]

	if(general_data["display_name"])
		set_display_name(general_data["display_name"])

	var/list/circuit_data = general_data["components"]
	var/list/identifiers_to_circuit = load_components(circuit_data, errors)

	load_external_objects(general_data["external_objects"], errors, identifiers_to_circuit)

	for(var/identifier in identifiers_to_circuit)
		var/obj/item/circuit_component/component = identifiers_to_circuit[identifier]
		var/list/component_data = circuit_data[identifier]
		var/list/connections = component_data["connections"]

		component.load_connections(connections, errors, identifiers_to_circuit)

	SEND_SIGNAL(src, COMSIG_CIRCUIT_POST_LOAD)

/obj/item/integrated_circuit/proc/load_components(list/components, list/errors)
	var/list/identifiers_to_circuit
	for(var/identifier in components)
		var/list/component_data = components[identifier]
		var/type = text2path(component_data["type"])
		if(!ispath(type, /obj/item/circuit_component))
			LOG_ERROR(errors, "Invalid path for circuit component, expected [/obj/item/circuit_component], got [type]")
			continue

		var/obj/item/circuit_component/component = load_component(type)
		LAZYADDASSOC(identifiers_to_circuit, identifier, component)
		component.load_data_from_list(component_data)
		SEND_SIGNAL(component, COMSIG_CIRCUIT_COMPONENT_LOAD_DATA, component_data)

		var/list/input_ports_data = component_data["input_ports_stored_data"]
		for(var/port_name in input_ports_data)
			var/datum/port/input/port
			var/list/port_data = input_ports_data[port_name]
			for(var/datum/port/input/port_to_check as anything in component.input_ports)
				if(port_to_check.name == port_name)
					port = port_to_check
					break

			if(!port)
				LOG_ERROR(errors, "Port '[port_name]' not found on [component.type] when trying to set it to a value of [port_data["stored_data"]]!")
				continue

			port.set_input(port_data["stored_data"])

	return identifiers_to_circuit

/obj/item/integrated_circuit/proc/load_variables(list/variable_data)
	for(var/list/variable as anything in variable_data)
		var/variable_name = variable["name"]
		var/datum/circuit_variable/variable_datum = new(variable_name, variable["datatype"])
		circuit_variables[variable_name] = variable_datum

		if(variable["is_assoc_list"])
			assoc_list_variables[variable_name] = variable_datum
			variable_datum.set_value(list())
		else if(variable["is_list"])
			list_variables[variable_name] = variable_datum
			variable_datum.set_value(list())
		else
			modifiable_circuit_variables[variable_name] = variable_datum

/obj/item/integrated_circuit/proc/load_external_objects(list/external_objects, list/identifiers_to_circuit, list/errors)
	for(var/identifier in external_objects)
		var/list/object_data = external_objects[identifier]
		var/type = text2path(object_data["type"])

		if(!ispath(type))
			LOG_ERROR(errors, "Invalid path for external object, expected a path, got [type]")
			continue

		var/atom/movable/object = new type(drop_location())
		var/list/connected_components = list()
		for(var/component_id in object_data["connected_components"])
			var/obj/item/circuit_component/component = identifiers_to_circuit[component_id]
			if(!component)
				continue

			connected_components += component

		SEND_SIGNAL(object, COMSIG_MOVABLE_CIRCUIT_LOADED, src, connected_components)

/obj/item/circuit_component/proc/load_connections(list/connections, list/errors, list/identifiers_to_circuit)
	for(var/port_name in connections)
		var/datum/port/input/port = find_input_port_by_name(port_name)

		if(!port)
			LOG_ERROR(errors, "Port [port_name] not found for [type].")
			continue

		var/list/connection_data = connections[port_name]

		// The || list(connected_data) is for backwards compatibility with when inputs could only be connected to up to one output.
		for(var/list/output_data in (connection_data["connected_ports"] || list(connection_data)))
			var/obj/item/circuit_component/connected_component = identifiers_to_circuit[output_data["component_id"]]
			if(!connected_component)
				LOG_ERROR(errors, "No connected component found for [type] for port [connection_data["port_name"]]. (connected component identifier: [connection_data["component_id"]])")
				continue

			var/datum/port/output/output_port = connected_component.find_output_port_by_name(output_data["port_name"])

			if(!output_port)
				LOG_ERROR(errors, "No output port found for [type] for port [output_data["port_name"]] on component [connected_component.type]")
				continue

			port.connect(output_port)

#undef LOG_ERROR

/// Converts a circuit into json.
/obj/item/integrated_circuit/proc/convert_to_json()
	var/list/external_objects = list() // Objects that are connected to a component. These objects will be linked to the components.
	var/list/circuit_data
	for(var/obj/item/circuit_component/component as anything in attached_components)
		SEND_SIGNAL(component, COMSIG_CIRCUIT_COMPONENT_SAVE, external_objects)

		var/identifier = component.UID()
		var/list/connections = list()
		var/list/input_ports_stored_data = list()

		component.save_connections_to_list(connections)
		component.save_ports_values_to_list(input_ports_stored_data, TRUE)

		var/list/component_data = list()
		LAZYADDASSOC(component_data, "connections", connections)
		LAZYADDASSOC(component_data, "input_ports_stored_data", input_ports_stored_data)
		LAZYADDASSOC(component_data, "type", component.type)

		SEND_SIGNAL(component, COMSIG_CIRCUIT_COMPONENT_SAVE_DATA, component_data)
		component.save_data_to_list(component_data)
		LAZYADDASSOC(circuit_data, identifier, component_data)

	var/list/general_data = list()
	general_data["components"] = circuit_data
	general_data["external_objects"] = external_objects
	general_data["display_name"] = display_name
	general_data["admin_only"] = admin_only

	general_data["variables"] = get_variables_data()

	SEND_SIGNAL(src, COMSIG_CIRCUIT_PRE_SAVE_TO_JSON, general_data)

	return json_encode(general_data)

/obj/item/integrated_circuit/proc/get_variables_data()
	var/list/variables
	for(var/variable_identifier in circuit_variables)
		var/list/new_data = list()
		var/datum/circuit_variable/variable = circuit_variables[variable_identifier]
		new_data["name"] = variable.name
		new_data["datatype"] = variable.datatype

		if(variable_identifier in assoc_list_variables)
			new_data["is_assoc_list"] = TRUE
		else if(variable_identifier in list_variables)
			new_data["is_list"] = TRUE

		LAZYADD(variables, list(new_data))

	return variables

/obj/item/integrated_circuit/proc/load_component(type)
	var/obj/item/circuit_component/component = new type(src)
	add_component(component)
	return component

/// Saves data to a list. Shouldn't be used unless you are quite literally saving the data of a component to a list. Input value is the list to save the data to
/obj/item/circuit_component/proc/save_data_to_list(list/component_data)
	component_data["rel_x"] = rel_x
	component_data["rel_y"] = rel_y

/// Loads data from a list
/obj/item/circuit_component/proc/load_data_from_list(list/component_data)
	rel_x = component_data["rel_x"]
	rel_y = component_data["rel_y"]

#define JSON_FROM_FILE "Файл"
#define JSON_FROM_STRING "Прямой ввод"
ADMIN_VERB(load_circuit, R_VAREDIT, "Load Circuit", "Loads a circuit from a file or direct input.", ADMIN_CATEGORY_FUN)
	var/list/errors = list()

	var/option = tgui_alert(user, "Загрузить из файла или напрямую?", "Загрузка схемы", list(JSON_FROM_FILE, JSON_FROM_STRING))
	var/txt
	switch(option)
		if(JSON_FROM_FILE)
			txt = file2text(input(user, "Укажите файл") as null|file)
		if(JSON_FROM_STRING)
			txt = input(user, "Введите JSON-строку", "Прямой ввод") as message|null

	if(!txt)
		return

	var/obj/item/integrated_circuit/loaded/circuit = new(user.mob.drop_location())
	circuit.load_circuit_data(txt, errors)

	if(!length(errors))
		return

	to_chat(user, span_warning("<b>При компиляции данных схемы были обнаружены следующие ошибки:</b>"))
	for(var/error in errors)
		to_chat(user, span_warning(error))

#undef JSON_FROM_FILE
#undef JSON_FROM_STRING
