/obj/item/circuit_component/wirenet_receive
	display_name = "WireNet приёмник"
	desc = "Получает пакеты данных через WireNet. \
			Если установлен ключ шифрования, будут приниматься только сигналы с таким же ключом шифрования."
	category = "Utility"

	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL //trigger_output

	/// The list type
	var/datum/port/input/option/list_options

	/// Data being received
	var/datum/port/output/data_package

	/// Encryption key
	var/datum/port/input/enc_key

/obj/item/circuit_component/wirenet_receive/Destroy()
	list_options = null
	data_package = null
	enc_key = null
	. = ..()

/obj/item/circuit_component/wirenet_receive/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/circuit_component_wirenet_connection,\
		connection_callback = CALLBACK(src, PROC_REF(on_powernet_connection)),\
		disconnection_callback = CALLBACK(src, PROC_REF(on_powernet_disconnection)),\
	)

/obj/item/circuit_component/wirenet_receive/proc/on_powernet_connection(datum/powernet/new_powernet)
	RegisterSignal(new_powernet, COMSIG_POWERNET_CIRCUIT_TRANSMISSION, PROC_REF(on_circuit_transmission))

/obj/item/circuit_component/wirenet_receive/proc/on_powernet_disconnection(datum/powernet/old_powernet)
	UnregisterSignal(old_powernet, COMSIG_POWERNET_CIRCUIT_TRANSMISSION)

/obj/item/circuit_component/wirenet_receive/populate_options()
	list_options = add_option_port("Тип", GLOB.wiremod_basic_types)

/obj/item/circuit_component/wirenet_receive/populate_ports()
	data_package = add_output_port("Пакет данных", PORT_TYPE_LIST(PORT_TYPE_ANY))
	enc_key = add_input_port("Ключ", PORT_TYPE_STRING)

/obj/item/circuit_component/wirenet_receive/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		data_package.set_datatype(PORT_TYPE_LIST(new_datatype))

/obj/item/circuit_component/wirenet_receive/proc/on_circuit_transmission(_source, list/data)
	SIGNAL_HANDLER

	if(data["enc_key"] != enc_key.value)
		return

	var/datum/weakref/ref = data["port"]
	var/datum/port/input/port = ref?.resolve()
	if(!port)
		return

	var/datum/circuit_datatype/datatype_handler = data_package.datatype_handler
	if(!datatype_handler?.can_receive_from_datatype(port.datatype))
		return

	data_package.set_output(data["data"])
	trigger_output.set_output(COMPONENT_SIGNAL)
