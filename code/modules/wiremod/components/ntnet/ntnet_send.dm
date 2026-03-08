/**
 * # NTNet Transmitter Component
 *
 * Sends a data package through NTNet
 */

/obj/item/circuit_component/ntnet_send
	display_name = "NTNet передатчик"
	desc = "Отправляет пакет данных через NTNet. \
			Если установлен ключ шифрования, переданные данные будут приняты \
			только получателями с таким же ключом шифрования."
	category = "NTNet"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// The list type
	var/datum/port/input/option/list_options

	/// Data being sent
	var/datum/port/input/data_package

	/// Encryption key
	var/datum/port/input/enc_key

/obj/item/circuit_component/ntnet_send/Destroy()
	list_options = null
	data_package = null
	enc_key = null
	. = ..()

/obj/item/circuit_component/ntnet_send/populate_options()
	list_options = add_option_port("Тип списка", GLOB.wiremod_basic_types)

/obj/item/circuit_component/ntnet_send/populate_ports()
	data_package = add_input_port("Пакет данных", PORT_TYPE_LIST(PORT_TYPE_ANY))
	enc_key = add_input_port("Ключ", PORT_TYPE_STRING)

/obj/item/circuit_component/ntnet_send/should_receive_input(datum/port/input/port)
	. = ..()
	if(!.)
		return FALSE
	/// If the server is down, don't use power or attempt to send data
	return find_functional_tcomms_core()

/obj/item/circuit_component/ntnet_send/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		data_package.set_datatype(PORT_TYPE_LIST(new_datatype))

/obj/item/circuit_component/ntnet_send/input_received(datum/port/input/port)
	send_ntnet_data(data_package, enc_key.value)
