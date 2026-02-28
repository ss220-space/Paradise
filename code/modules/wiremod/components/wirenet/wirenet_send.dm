/obj/item/circuit_component/wirenet_send
	display_name = "WireNet передатчик"
	desc = "Отправляет пакет данных через WireNet. \
			Если установлен ключ шифрования, переданные данные будут приняты только получателями с таким же ключом шифрования."
	category = "Utility"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// Powernet reference provided by the circuit_component_wirenet_connection component
	var/datum/powernet/connected_powernet

	/// The list type
	var/datum/port/input/option/list_options

	/// Data being sent
	var/datum/port/input/data_package

	/// Encryption key
	var/datum/port/input/enc_key

/obj/item/circuit_component/wirenet_send/Destroy()
	list_options = null
	data_package = null
	enc_key = null
	connected_powernet = null
	. = ..()

/obj/item/circuit_component/wirenet_send/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/circuit_component_wirenet_connection,\
		connection_callback = CALLBACK(src, PROC_REF(on_powernet_connection)),\
		disconnection_callback = CALLBACK(src, PROC_REF(on_powernet_disconnection)),\
	)

/obj/item/circuit_component/wirenet_send/proc/on_powernet_connection(datum/powernet/new_powernet)
	connected_powernet = new_powernet

/obj/item/circuit_component/wirenet_send/proc/on_powernet_disconnection(datum/powernet/old_powernet)
	connected_powernet = null

/obj/item/circuit_component/wirenet_send/populate_options()
	list_options = add_option_port("Тип списка", GLOB.wiremod_basic_types)

/obj/item/circuit_component/wirenet_send/populate_ports()
	data_package = add_input_port("Пакет данных", PORT_TYPE_LIST(PORT_TYPE_ANY))
	enc_key = add_input_port("Ключ", PORT_TYPE_STRING)

/obj/item/circuit_component/wirenet_send/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		data_package.set_datatype(PORT_TYPE_LIST(new_datatype))

/obj/item/circuit_component/wirenet_send/input_received(datum/port/input/port)
	connected_powernet?.data_transmission(data_package.value, enc_key.value, WEAKREF(data_package))
