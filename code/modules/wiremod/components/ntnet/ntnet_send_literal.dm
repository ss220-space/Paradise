/**
 * # NTNet Transmitter List Literal Component
 *
 * Create a list literal and send a data package through NTNet
 *
 * This file is based off of ntnet_send.dm
 * Any changes made to those files should be copied over with discretion
 */
/obj/item/circuit_component/list_literal/ntnet_send
	display_name = "NTNet передатчик списка элементов"
	desc = "Создаёт пакет данных в виде списка литералов и отправляет его через NTNet. \
			Если задан ключ шифрования, передаваемые данные будут приняты \
			только получателями с таким же ключом шифрования."
	category = "NTNet"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// Encryption key
	var/datum/port/input/enc_key

/obj/item/circuit_component/list_literal/ntnet_send/populate_ports()
	. = ..()
	enc_key = add_input_port("Ключ", PORT_TYPE_STRING)

/obj/item/circuit_component/list_literal/ntnet_send/should_receive_input(datum/port/input/port)
	. = ..()
	if(!.)
		return FALSE
	/// If the server is down, don't use power or attempt to send data
	return find_functional_tcomms_core()

/obj/item/circuit_component/list_literal/ntnet_send/input_received(datum/port/input/port)
	. = ..()
	send_ntnet_data(list_output, enc_key.value)
