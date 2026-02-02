/**
 * # NFC Transmitter Component
 *
 * Sends a data package through NFC
 * Only the targeted shell will receive the message
 */

/obj/item/circuit_component/nfc_send
	display_name = "NFC передатчик"
	desc = "Отправляет пакет данных через NFC. \
			Если установлен ключ шифрования, переданные данные будут приняты только получателями с таким же ключом шифрования."
	category = "Utility"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// The list type
	var/datum/port/input/option/list_options

	/// The targeted circuit
	var/datum/port/input/target

	/// Data being sent
	var/datum/port/input/data_package

	/// Encryption key
	var/datum/port/input/enc_key

/obj/item/circuit_component/nfc_send/populate_options()
	list_options = add_option_port("Тип списка", GLOB.wiremod_basic_types)

/obj/item/circuit_component/nfc_send/populate_ports()
	data_package = add_input_port("Пакет данных", PORT_TYPE_LIST(PORT_TYPE_ANY))
	enc_key = add_input_port("Ключ", PORT_TYPE_STRING)
	target = add_input_port("Цель", PORT_TYPE_ATOM)

/obj/item/circuit_component/nfc_send/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		data_package.set_datatype(PORT_TYPE_LIST(new_datatype))

/obj/item/circuit_component/nfc_send/input_received(datum/port/input/port)
	if(!isatom(target.value))
		return

	var/atom/target_enty = target.value
	SEND_SIGNAL(target_enty, COMSIG_CIRCUIT_NFC_DATA_SENT, parent, list("data" = data_package.value, "enc_key" = enc_key.value, "port" = WEAKREF(data_package)))
